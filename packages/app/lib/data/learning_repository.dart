import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';

/// Orchestrates content, events, SRS state, and the scheduler for the UI.
/// Screens call these high-level methods instead of holding the data-flow
/// logic themselves (which keeps the widgets thin and the logic testable).
class LearningRepository {
  final ContentStore content;
  final EventLogStore events;
  final SrsStateStore states;
  final Scheduler scheduler;

  const LearningRepository({
    required this.content,
    required this.events,
    required this.states,
    required this.scheduler,
  });

  // --- Home ---

  /// Home dashboard data for [examCode]: the next un-completed lesson (with its
  /// paper/module names), overall progress, and today's study state.
  Future<HomeData> homeData(String examCode, String userId) async {
    final all = await events.getAllEvents(userId);
    final completed =
        all.whereType<LessonViewedEvent>().map((e) => e.lessonId).toSet();
    final now = DateTime.now();
    final studiedToday = all.any((e) =>
        e.timestamp.year == now.year &&
        e.timestamp.month == now.month &&
        e.timestamp.day == now.day);

    Lesson? first;
    Lesson? next;
    String firstPaper = '', firstModule = '', nextPaper = '', nextModule = '';
    var total = 0;

    final exam = await content.getExamByCode(examCode);
    if (exam != null) {
      final papers = await content.getPapersByExam(exam.code);
      for (final paper in papers) {
        final modules = await content.getModulesByPaper(paper.id);
        for (final mod in modules) {
          final lessons = await content.getLessonsByModule(mod.id);
          for (final l in lessons) {
            total++;
            if (first == null) {
              first = l;
              firstPaper = paper.name.resolve('en');
              firstModule = mod.name.resolve('en');
            }
            if (next == null && !completed.contains(l.id)) {
              next = l;
              nextPaper = paper.name.resolve('en');
              nextModule = mod.name.resolve('en');
            }
          }
        }
      }
    }

    return HomeData(
      nextLesson: next ?? first,
      paperName: next != null ? nextPaper : firstPaper,
      moduleName: next != null ? nextModule : firstModule,
      completedCount: completed.length,
      totalLessons: total,
      studiedToday: studiedToday,
    );
  }

  Future<Lesson?> getLesson(String id) => content.getLesson(id);

  Future<List<QuestionBase>> getLessonQuestions(String lessonId) =>
      content.getQuestionsByLesson(lessonId);

  /// Full catalog tree for the content browser: papers → modules → lessons,
  /// plus the set of completed lesson IDs for the given user.
  Future<CatalogData> browseCatalog(String examCode, String userId) async {
    final all = await events.getAllEvents(userId);
    final completed =
        all.whereType<LessonViewedEvent>().map((e) => e.lessonId).toSet();

    final exam = await content.getExamByCode(examCode);
    final papers = <Paper>[];
    final modulesByPaper = <String, List<Module>>{};
    final lessonsByModule = <String, List<Lesson>>{};

    if (exam != null) {
      final ps = await content.getPapersByExam(exam.code);
      for (final paper in ps) {
        papers.add(paper);
        final mods = await content.getModulesByPaper(paper.id);
        modulesByPaper[paper.id] = mods;
        for (final mod in mods) {
          lessonsByModule[mod.id] = await content.getLessonsByModule(mod.id);
        }
      }
    }

    return CatalogData(
      papers: papers,
      modulesByPaper: modulesByPaper,
      lessonsByModule: lessonsByModule,
      completed: completed,
    );
  }

  /// Persist a completed lesson's events, then re-project the SRS state of each
  /// touched item from its full event history.
  Future<void> applyLessonCompletion(
      String userId, String examContext, List<SrsEvent> lessonEvents) async {
    for (final e in lessonEvents) {
      await events.appendEvent(e);
    }
    final itemIds = <String>{};
    for (final e in lessonEvents) {
      if (e is CardReviewedEvent) {
        itemIds.add(e.itemId);
      } else if (e is QuestionAnsweredEvent) {
        itemIds.add(e.questionId);
      }
    }
    for (final itemId in itemIds) {
      final itemEvents = await events.getEventsForItem(userId, itemId);
      final next = projectSrsState(
        userId: userId,
        itemId: itemId,
        events: itemEvents,
        scheduler: scheduler,
        examContext: examContext,
      );
      if (next != null) await states.saveState(next);
    }
  }

  // --- Mocks ---

  static const _fallbackBlueprint = MockBlueprint(
    id: 'bp_ppb_full',
    name: 'Principles & practices of banking — full mock',
    picks: [MockPick(topicTags: [], count: 2, difficultyMix: {1: 0.5, 2: 0.5})],
    shuffle: true,
    timingFromPaper: 'PPB',
  );

  /// Build a practice mock from the full question bank of the loaded exam.
  Future<MockAssembly> assembleMockForExam(ExamConfig config) async {
    final blueprint = config.mockBlueprints.firstOrNull ?? _fallbackBlueprint;
    final pool = await content.getAllQuestions();
    if (pool.isEmpty) {
      return MockAssembly(blueprint: blueprint, questions: const []);
    }
    return MockAssembly(
        blueprint: blueprint, questions: assembleMock(blueprint, pool));
  }

  // --- Reviews ---

  /// Load the due spaced-repetition queue plus the cards needed to render it.
  ///
  /// A card enters review once its lesson has been studied (a [LessonViewedEvent]
  /// exists): cards already in the SRS contribute their scheduled state, and
  /// studied-but-not-yet-reviewed cards are enrolled as new items due now — so
  /// finishing a lesson populates the review deck. Probe-question states are
  /// intentionally excluded (they aren't card-flip reviewable).
  Future<DueReviews> loadDueReviews(
    String userId,
    String examContext, {
    int budget = 15,
  }) async {
    final allStates = await states.getStatesForExam(userId, examContext);
    final stateByItem = {for (final s in allStates) s.itemId: s};
    final allEvents = await events.getAllEvents(userId);
    final studiedLessons = allEvents
        .whereType<LessonViewedEvent>()
        .map((e) => e.lessonId)
        .toSet();
    final now = DateTime.now();

    final items = <String, LearnableItem>{};
    final cards = <String, Card>{};
    final reviewStates = <SrsState>[];

    final exam = await content.getExamByCode(examContext) ??
        await content.getExam('ex_ppb');
    if (exam != null) {
      final papers = await content.getPapersByExam(exam.code);
      for (final paper in papers) {
        final modules = await content.getModulesByPaper(paper.id);
        for (final mod in modules) {
          final lessons = await content.getLessonsByModule(mod.id);
          for (final lesson in lessons) {
            for (final card in lesson.cards) {
              if (!card.srsEligible) continue;
              cards[card.id] = card;
              items[card.id] = LearnableItem(
                id: card.id,
                kind: LearnableItemKind.card,
                refId: card.id,
                topicTags: mod.topicTags,
                examContexts: [exam.code],
              );
              final existing = stateByItem[card.id];
              if (existing != null) {
                reviewStates.add(existing);
              } else if (studiedLessons.contains(lesson.id)) {
                // Studied but never reviewed → enroll as a new item, due now.
                reviewStates.add(SrsState(
                  stability: 0,
                  difficulty: 5,
                  due: now,
                  lastReview: now,
                  reps: 0,
                  phase: SrsPhase.newItem,
                  userId: userId,
                  itemId: card.id,
                  examContext: examContext,
                ));
              }
            }
          }
        }
      }
    }

    final due = buildDueQueue(
      states: reviewStates,
      items: items,
      now: now,
      budget: budget,
    );
    return DueReviews(states: due, cards: cards);
  }

  /// Apply a recall rating: log the event and re-project the item's SRS state
  /// from its full history (so a card's first review is initialised correctly).
  Future<SrsState> applyReview(
      String userId, String examContext, SrsState state, Rating rating) async {
    final now = DateTime.now();
    await events.appendEvent(CardReviewedEvent(
      clientUlid: 'ulid_rev_${state.itemId}_${now.millisecondsSinceEpoch}',
      userId: userId,
      timestamp: now,
      examContext: examContext,
      itemId: state.itemId,
      rating: rating,
    ));
    final itemEvents = await events.getEventsForItem(userId, state.itemId);
    final next = projectSrsState(
      userId: userId,
      itemId: state.itemId,
      events: itemEvents,
      scheduler: scheduler,
      examContext: examContext,
    );
    if (next != null) await states.saveState(next);
    return next ?? state;
  }
}

class HomeData {
  final Lesson? nextLesson;
  final String paperName;
  final String moduleName;
  final int completedCount;
  final int totalLessons;
  final bool studiedToday;
  const HomeData({
    required this.nextLesson,
    required this.paperName,
    required this.moduleName,
    required this.completedCount,
    required this.totalLessons,
    required this.studiedToday,
  });
}

class MockAssembly {
  final MockBlueprint blueprint;
  final List<QuestionBase> questions;
  const MockAssembly({required this.blueprint, required this.questions});
  bool get isEmpty => questions.isEmpty;
}

class DueReviews {
  final List<SrsState> states;
  final Map<String, Card> cards;
  const DueReviews({required this.states, required this.cards});
}

class CatalogData {
  final List<Paper> papers;
  final Map<String, List<Module>> modulesByPaper;
  final Map<String, List<Lesson>> lessonsByModule;
  final Set<String> completed;
  const CatalogData({
    required this.papers,
    required this.modulesByPaper,
    required this.lessonsByModule,
    required this.completed,
  });
}
