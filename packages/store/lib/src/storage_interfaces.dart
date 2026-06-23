import 'package:domain/domain.dart';
import 'package:srs/srs.dart';
import 'event.dart';

/// Database contract for content management (epic E4.1 / E4.3).
abstract interface class ContentStore {
  Future<void> saveExam(Exam exam);
  Future<Exam?> getExam(String id);
  Future<Exam?> getExamByCode(String code);

  Future<void> savePaper(Paper paper);
  Future<Paper?> getPaper(String id);
  Future<List<Paper>> getPapersByExam(String examCode);

  Future<void> saveModule(Module module);
  Future<Module?> getModule(String id);
  Future<List<Module>> getModulesByPaper(String paperId);

  Future<void> saveLesson(Lesson lesson);
  Future<Lesson?> getLesson(String id);
  Future<List<Lesson>> getLessonsByModule(String moduleId);

  Future<void> saveQuestion(QuestionBase question);
  Future<QuestionBase?> getQuestion(String id);
  Future<List<QuestionBase>> getQuestionsByLesson(String lessonId);

  Future<void> saveAsset(Asset asset);
  Future<Asset?> getAsset(String id);

  Future<void> saveStimulus(Stimulus stimulus);
  Future<Stimulus?> getStimulus(String id);
  Future<List<Stimulus>> getAllStimuli();
}

/// Database contract for append-only event sourcing logs (epic E4.1 / E4.2).
abstract interface class EventLogStore {
  /// Appends a new event locally.
  Future<void> appendEvent(SrsEvent event);

  /// Retrieves all events for a user that haven't been synchronized yet.
  Future<List<SrsEvent>> getUnsyncedEvents(String userId);

  /// Marks a batch of events as synced.
  Future<void> markEventsAsSynced(List<String> clientUlids, DateTime syncedAt);

  /// Retrieves chronological event logs for a specific item (for state projection).
  Future<List<SrsEvent>> getEventsForItem(String userId, String itemId);

  /// Retrieves all historical events for a user.
  Future<List<SrsEvent>> getAllEvents(String userId);
}

/// Database contract for FSRS scheduling states (epic E4.1 / E3.2).
abstract interface class SrsStateStore {
  Future<void> saveState(SrsState state);
  Future<SrsState?> getState(String userId, String itemId);
  Future<List<SrsState>> getAllStates(String userId);
  Future<List<SrsState>> getStatesForExam(String userId, String examContext);
}

/// Database contract for tracking cursor sync bookmarks (epic E4.1).
abstract interface class SyncCursorStore {
  Future<DateTime?> getLastSyncTime(String userId);
  Future<void> setLastSyncTime(String userId, DateTime time);
}
