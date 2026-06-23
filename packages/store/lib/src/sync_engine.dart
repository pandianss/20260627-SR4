import 'package:domain/domain.dart';
import 'package:grading/grading.dart';
import 'package:srs/srs.dart';

import 'event.dart';
import 'storage_interfaces.dart';

/// Content pack deltas returned by the sync endpoint (epic E4.3).
class ContentPackDelta {
  final List<Exam> exams;
  final List<Paper> papers;
  final List<Module> modules;
  final List<Lesson> lessons;
  final List<QuestionBase> questions;
  final List<Asset> assets;
  final List<Stimulus> stimuli;

  const ContentPackDelta({
    this.exams = const [],
    this.papers = const [],
    this.modules = const [],
    this.lessons = const [],
    this.questions = const [],
    this.assets = const [],
    this.stimuli = const [],
  });

  factory ContentPackDelta.fromJson(Map<String, dynamic> j) => ContentPackDelta(
        exams: (j['exams'] as List?)
                ?.map((e) => Exam.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        papers: (j['papers'] as List?)
                ?.map((e) => Paper.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        modules: (j['modules'] as List?)
                ?.map((e) => Module.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        lessons: (j['lessons'] as List?)
                ?.map((e) => Lesson.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        questions: (j['questions'] as List?)
                ?.map((e) =>
                    QuestionBase.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        assets: (j['assets'] as List?)
                ?.map((e) => Asset.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
        stimuli: (j['stimuli'] as List?)
                ?.map((e) => Stimulus.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'exams': exams.map((e) => e.toJson()).toList(),
        'papers': papers.map((e) => e.toJson()).toList(),
        'modules': modules.map((e) => e.toJson()).toList(),
        'lessons': lessons.map((e) => e.toJson()).toList(),
        'questions': questions.map((e) => e.toJson()).toList(),
        'assets': assets.map((e) => e.toJson()).toList(),
        'stimuli': stimuli.map((e) => e.toJson()).toList(),
      };
}

/// Request envelope for synchronization (epic E4.4).
class SyncRequest {
  final String userId;
  final List<SrsEvent> unsyncedEvents;
  final Map<String, int> heldContentPackVersions; // contentId -> version

  const SyncRequest({
    required this.userId,
    required this.unsyncedEvents,
    required this.heldContentPackVersions,
  });

  factory SyncRequest.fromJson(Map<String, dynamic> j) => SyncRequest(
        userId: j['userId'] as String,
        unsyncedEvents: (j['unsyncedEvents'] as List)
            .map((e) => SrsEvent.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        heldContentPackVersions:
            (j['heldContentPackVersions'] as Map).cast<String, int>(),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'unsyncedEvents': unsyncedEvents.map((e) => e.toJson()).toList(),
        'heldContentPackVersions': heldContentPackVersions,
      };
}

/// Response envelope for synchronization (epic E4.4).
class SyncResponse {
  final List<String> acceptedEventUlids;
  final List<SrsState> authoritativeStates;
  final ContentPackDelta contentPackDelta;

  const SyncResponse({
    required this.acceptedEventUlids,
    required this.authoritativeStates,
    required this.contentPackDelta,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> j) => SyncResponse(
        acceptedEventUlids: (j['acceptedEventUlids'] as List)
            .map((e) => e.toString())
            .toList(),
        authoritativeStates: (j['authoritativeStates'] as List)
            .map((e) => SrsState.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        contentPackDelta: ContentPackDelta.fromJson(
            (j['contentPackDelta'] as Map).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
        'acceptedEventUlids': acceptedEventUlids,
        'authoritativeStates': authoritativeStates.map((s) => s.toJson()).toList(),
        'contentPackDelta': contentPackDelta.toJson(),
      };
}

/// Maps grading correctness to FSRS rating.
Rating ratingFromCorrectness(Correctness c) => switch (c) {
      Correctness.correct => Rating.good,
      Correctness.partial => Rating.hard,
      Correctness.incorrect ||
      Correctness.pending ||
      Correctness.unanswered =>
        Rating.again,
    };

/// Authoritative projection engine. Replays events in chronological order to
/// construct the deterministic current SrsState (epic E4.4).
SrsState? projectSrsState({
  required String userId,
  required String itemId,
  required List<SrsEvent> events,
  required Scheduler scheduler,
  required String examContext,
}) {
  if (events.isEmpty) return null;

  // Ensure strict chronological ordering
  final sortedEvents = List<SrsEvent>.from(events)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  SrsState? state;

  for (final event in sortedEvents) {
    if (event is CardReviewedEvent) {
      if (state == null) {
        state = scheduler.init(event.timestamp, event.rating);
      } else {
        state = scheduler.review(state, event.rating, event.timestamp);
      }
      // Card review clears the high priority / mock error status once reviewed
      state = state.copyWith(isHighPriority: false);
    } else if (event is QuestionAnsweredEvent) {
      final rating = ratingFromCorrectness(event.correctness);
      if (state == null) {
        state = scheduler.init(event.timestamp, rating);
      } else {
        state = scheduler.review(state, rating, event.timestamp);
      }
      state = state.copyWith(isHighPriority: false);
    } else if (event is MockSubmittedEvent) {
      // Check if this item had an incorrect answer in the mock
      final matchedAnswer = event.answers
          .where((a) => a.questionId == itemId)
          .firstOrNull;

      if (matchedAnswer != null &&
          matchedAnswer.correctness != Correctness.correct) {
        // Mock error: re-inject as high priority lapse
        if (state == null) {
          state = scheduler.init(event.timestamp, Rating.again);
        } else {
          state = scheduler.review(state, Rating.again, event.timestamp);
        }
        state = state.copyWith(isHighPriority: true);
      }
    }
  }

  return state?.copyWith(
    userId: userId,
    itemId: itemId,
    examContext: examContext,
  );
}

/// Client-side sync driver (epic E4.4).
class ClientSyncEngine {
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final ContentStore contentStore;
  final SyncCursorStore cursorStore;

  ClientSyncEngine({
    required this.eventStore,
    required this.stateStore,
    required this.contentStore,
    required this.cursorStore,
  });

  /// Gathers unsynced events and content pack metadata.
  Future<SyncRequest> prepareSyncRequest(String userId,
      Map<String, int> heldContentPackVersions) async {
    final unsynced = await eventStore.getUnsyncedEvents(userId);
    return SyncRequest(
      userId: userId,
      unsyncedEvents: unsynced,
      heldContentPackVersions: heldContentPackVersions,
    );
  }

  /// Reconciles sync results back into local stores.
  Future<void> applySyncResponse(SyncResponse response, String userId,
      DateTime syncTime) async {
    // 1. Mark events as synced
    if (response.acceptedEventUlids.isNotEmpty) {
      await eventStore.markEventsAsSynced(
          response.acceptedEventUlids, syncTime);
    }

    // 2. Overwrite SrsStates with authoritative server project states
    for (final state in response.authoritativeStates) {
      await stateStore.saveState(state);
    }

    // 3. Write content pack delta updates to the local database
    final delta = response.contentPackDelta;
    for (final exam in delta.exams) {
      await contentStore.saveExam(exam);
    }
    for (final paper in delta.papers) {
      await contentStore.savePaper(paper);
    }
    for (final mod in delta.modules) {
      await contentStore.saveModule(mod);
    }
    for (final lesson in delta.lessons) {
      await contentStore.saveLesson(lesson);
    }
    for (final q in delta.questions) {
      await contentStore.saveQuestion(q);
    }
    for (final asset in delta.assets) {
      await contentStore.saveAsset(asset);
    }
    for (final stimulus in delta.stimuli) {
      await contentStore.saveStimulus(stimulus);
    }

    // 4. Advance cursor
    await cursorStore.setLastSyncTime(userId, syncTime);
  }
}

/// Server-side authoritative sync processor (epic E4.4).
class ServerSyncEngine {
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final ContentStore contentStore;
  final Scheduler scheduler;

  ServerSyncEngine({
    required this.eventStore,
    required this.stateStore,
    required this.contentStore,
    required this.scheduler,
  });

  /// Processes sync request: logs events, projects state, computes deltas.
  Future<SyncResponse> processSyncRequest(SyncRequest request) async {
    final String userId = request.userId;
    final List<String> accepted = [];
    final Set<String> modifiedItemIds = {};
    String activeContext = '';

    // 1. Save new events (idempotence is built into eventStore.appendEvent)
    for (final event in request.unsyncedEvents) {
      await eventStore.appendEvent(event);
      accepted.add(event.clientUlid);
      activeContext = event.examContext;

      if (event is CardReviewedEvent) {
        modifiedItemIds.add(event.itemId);
      } else if (event is QuestionAnsweredEvent) {
        modifiedItemIds.add(event.questionId);
      } else if (event is MockSubmittedEvent) {
        // Mock error items
        for (final ans in event.answers) {
          if (ans.correctness != Correctness.correct) {
            modifiedItemIds.add(ans.questionId);
          }
        }
      }
    }

    // 2. Re-project authoritative SrsStates for affected items
    final List<SrsState> authoritativeStates = [];
    for (final itemId in modifiedItemIds) {
      final history = await eventStore.getEventsForItem(userId, itemId);
      final projected = projectSrsState(
        userId: userId,
        itemId: itemId,
        events: history,
        scheduler: scheduler,
        examContext: activeContext,
      );
      if (projected != null) {
        await stateStore.saveState(projected);
        authoritativeStates.add(projected);
      }
    }

    // 3. Compute content pack deltas (deltas return items where server version > client held version)
    final List<Exam> deltaExams = [];
    final List<Paper> deltaPapers = [];
    final List<Module> deltaModules = [];
    final List<Lesson> deltaLessons = [];
    final List<QuestionBase> deltaQuestions = [];

    for (final entry in request.heldContentPackVersions.entries) {
      final key = entry.key; // e.g. examId, moduleId, lessonId
      final clientVersion = entry.value;

      // Check Exams
      final exam = await contentStore.getExam(key);
      if (exam != null && exam.version > clientVersion) {
        deltaExams.add(exam);
        continue;
      }

      // Check Lessons
      final lesson = await contentStore.getLesson(key);
      if (lesson != null && lesson.version > clientVersion) {
        deltaLessons.add(lesson);
        // Also send updated questions for this lesson
        final questions = await contentStore.getQuestionsByLesson(lesson.id);
        deltaQuestions.addAll(questions);
        continue;
      }
    }

    return SyncResponse(
      acceptedEventUlids: accepted,
      authoritativeStates: authoritativeStates,
      contentPackDelta: ContentPackDelta(
        exams: deltaExams,
        papers: deltaPapers,
        modules: deltaModules,
        lessons: deltaLessons,
        questions: deltaQuestions,
      ),
    );
  }
}
