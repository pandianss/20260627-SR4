import 'package:domain/domain.dart';
import 'package:srs/srs.dart';

import 'event.dart';
import 'storage_interfaces.dart';

class MemoryContentStore implements ContentStore {
  final Map<String, Exam> _exams = {};
  final Map<String, Paper> _papers = {};
  final Map<String, Module> _modules = {};
  final Map<String, Lesson> _lessons = {};
  final Map<String, QuestionBase> _questions = {};
  final Map<String, Asset> _assets = {};
  final Map<String, Stimulus> _stimuli = {};

  @override
  Future<void> saveExam(Exam exam) async => _exams[exam.id] = exam;

  @override
  Future<Exam?> getExam(String id) async => _exams[id];

  @override
  Future<Exam?> getExamByCode(String code) async {
    for (final exam in _exams.values) {
      if (exam.code == code) return exam;
    }
    return null;
  }

  @override
  Future<void> savePaper(Paper paper) async => _papers[paper.id] = paper;

  @override
  Future<Paper?> getPaper(String id) async => _papers[id];

  @override
  Future<List<Paper>> getPapersByExam(String examCode) async =>
      _papers.values.where((p) => p.examCode == examCode).toList();

  @override
  Future<void> saveModule(Module module) async => _modules[module.id] = module;

  @override
  Future<Module?> getModule(String id) async => _modules[id];

  @override
  Future<List<Module>> getModulesByPaper(String paperId) async =>
      _modules.values.where((m) => m.paperId == paperId).toList();

  @override
  Future<void> saveLesson(Lesson lesson) async => _lessons[lesson.id] = lesson;

  @override
  Future<Lesson?> getLesson(String id) async => _lessons[id];

  @override
  Future<List<Lesson>> getLessonsByModule(String moduleId) async =>
      _lessons.values.where((l) => l.moduleId == moduleId).toList();

  @override
  Future<void> saveQuestion(QuestionBase question) async =>
      _questions[question.id] = question;

  @override
  Future<QuestionBase?> getQuestion(String id) async => _questions[id];

  @override
  Future<List<QuestionBase>> getQuestionsByLesson(String lessonId) async {
    final lesson = _lessons[lessonId];
    if (lesson == null) return const [];
    return lesson.probeQuestionIds
        .map((qid) => _questions[qid])
        .whereType<QuestionBase>()
        .toList();
  }

  @override
  Future<void> saveAsset(Asset asset) async => _assets[asset.id] = asset;

  @override
  Future<Asset?> getAsset(String id) async => _assets[id];

  @override
  Future<void> saveStimulus(Stimulus stimulus) async => _stimuli[stimulus.id] = stimulus;

  @override
  Future<Stimulus?> getStimulus(String id) async => _stimuli[id];

  @override
  Future<List<Stimulus>> getAllStimuli() async => _stimuli.values.toList();
}

class MemoryEventLogStore implements EventLogStore {
  final List<SrsEvent> _events = [];
  final Map<String, DateTime> _syncedEvents = {};

  @override
  Future<void> appendEvent(SrsEvent event) async {
    // Prevent duplicate appends if clientUlid matches
    if (_events.any((e) => e.clientUlid == event.clientUlid)) {
      return;
    }
    _events.add(event);
  }

  @override
  Future<List<SrsEvent>> getUnsyncedEvents(String userId) async => _events
      .where((e) => e.userId == userId && !_syncedEvents.containsKey(e.clientUlid))
      .toList();

  @override
  Future<void> markEventsAsSynced(List<String> clientUlids, DateTime syncedAt) async {
    for (final ulid in clientUlids) {
      _syncedEvents[ulid] = syncedAt;
    }
  }

  @override
  Future<List<SrsEvent>> getEventsForItem(String userId, String itemId) async {
    final List<SrsEvent> filtered = [];
    for (final event in _events) {
      if (event.userId != userId) continue;

      if (event is CardReviewedEvent && event.itemId == itemId) {
        filtered.add(event);
      } else if (event is QuestionAnsweredEvent && event.questionId == itemId) {
        // standalone question scheduled directly
        filtered.add(event);
      } else if (event is MockSubmittedEvent &&
          event.answers.any((a) => a.questionId == itemId)) {
        filtered.add(event);
      }
    }
    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  @override
  Future<List<SrsEvent>> getAllEvents(String userId) async {
    final list = _events.where((e) => e.userId == userId).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }
}

class MemorySrsStateStore implements SrsStateStore {
  final Map<String, SrsState> _states = {};

  String _key(String userId, String itemId) => '${userId}::${itemId}';

  @override
  Future<void> saveState(SrsState state) async =>
      _states[_key(state.userId, state.itemId)] = state;

  @override
  Future<SrsState?> getState(String userId, String itemId) async =>
      _states[_key(userId, itemId)];

  @override
  Future<List<SrsState>> getAllStates(String userId) async =>
      _states.values.where((s) => s.userId == userId).toList();

  @override
  Future<List<SrsState>> getStatesForExam(String userId, String examContext) async =>
      _states.values.where((s) => s.userId == userId && s.examContext == examContext).toList();
}

class MemorySyncCursorStore implements SyncCursorStore {
  final Map<String, DateTime> _cursors = {};

  @override
  Future<DateTime?> getLastSyncTime(String userId) async => _cursors[userId];

  @override
  Future<void> setLastSyncTime(String userId, DateTime time) async =>
      _cursors[userId] = time;
}
