import 'package:domain/domain.dart';
import 'package:grading/grading.dart';
import 'package:srs/srs.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

void main() {
  group('Store & Sync Engine Tests', () {
    final now = DateTime.utc(2026, 6, 23, 10, 0, 0);
    const fsrs = Fsrs();

    test('SrsEvent Subclasses should round-trip through JSON correctly', () {
      final events = <SrsEvent>[
        LessonViewedEvent(
          clientUlid: 'ulid_l1',
          userId: 'usr_1',
          timestamp: now,
          examContext: 'jaiib_2026',
          lessonId: 'les_ppb_crr',
        ),
        CardReviewedEvent(
          clientUlid: 'ulid_c1',
          userId: 'usr_1',
          timestamp: now.add(const Duration(minutes: 5)),
          examContext: 'jaiib_2026',
          itemId: 'card_crr',
          rating: Rating.good,
        ),
        QuestionAnsweredEvent(
          clientUlid: 'ulid_q1',
          userId: 'usr_1',
          timestamp: now.add(const Duration(minutes: 10)),
          examContext: 'jaiib_2026',
          questionId: 'q_slr',
          response: const McqResponse('opt_a'),
          correctness: Correctness.correct,
          marksAwarded: 1.0,
        ),
        MockSubmittedEvent(
          clientUlid: 'ulid_m1',
          userId: 'usr_1',
          timestamp: now.add(const Duration(minutes: 30)),
          examContext: 'jaiib_2026',
          mockResultId: 'res_1',
          paperId: 'ppb_paper',
          score: 85.0,
          maxScore: 100.0,
          passed: true,
          answers: [
            const MockAnswerSummary(
              questionId: 'q_slr',
              correctness: Correctness.correct,
              score: 1.0,
            ),
            const MockAnswerSummary(
              questionId: 'q_crr_holder',
              correctness: Correctness.incorrect,
              score: 0.0,
            ),
          ],
        ),
      ];

      for (final event in events) {
        final json = event.toJson();
        final deserialized = SrsEvent.fromJson(json);

        expect(deserialized.type, equals(event.type));
        expect(deserialized.clientUlid, equals(event.clientUlid));
        expect(deserialized.userId, equals(event.userId));
        expect(deserialized.timestamp, equals(event.timestamp));
        expect(deserialized.examContext, equals(event.examContext));

        if (event is LessonViewedEvent) {
          expect((deserialized as LessonViewedEvent).lessonId, equals(event.lessonId));
        } else if (event is CardReviewedEvent) {
          expect((deserialized as CardReviewedEvent).itemId, equals(event.itemId));
          expect(deserialized.rating, equals(event.rating));
        } else if (event is QuestionAnsweredEvent) {
          expect((deserialized as QuestionAnsweredEvent).questionId, equals(event.questionId));
          expect(deserialized.correctness, equals(event.correctness));
          expect(deserialized.marksAwarded, equals(event.marksAwarded));
        } else if (event is MockSubmittedEvent) {
          final deserializedMock = deserialized as MockSubmittedEvent;
          expect(deserializedMock.mockResultId, equals(event.mockResultId));
          expect(deserializedMock.score, equals(event.score));
          expect(deserializedMock.answers.length, equals(event.answers.length));
          expect(deserializedMock.answers[1].questionId, equals(event.answers[1].questionId));
          expect(deserializedMock.answers[1].correctness, equals(event.answers[1].correctness));
        }
      }
    });

    test('Authoritative SrsState projection should replay history chronologically', () {
      final events = <SrsEvent>[
        CardReviewedEvent(
          clientUlid: 'ulid_1',
          userId: 'usr_1',
          timestamp: now,
          examContext: 'jaiib_2026',
          itemId: 'card_crr',
          rating: Rating.good,
        ),
        CardReviewedEvent(
          clientUlid: 'ulid_2',
          userId: 'usr_1',
          timestamp: now.add(const Duration(days: 4)),
          examContext: 'jaiib_2026',
          itemId: 'card_crr',
          rating: Rating.good,
        ),
      ];

      // Replay projection
      final state = projectSrsState(
        userId: 'usr_1',
        itemId: 'card_crr',
        events: events,
        scheduler: fsrs,
        examContext: 'jaiib_2026',
      );

      expect(state, isNotNull);
      expect(state!.reps, equals(2));
      expect(state.lapses, equals(0));
      expect(state.stability, greaterThan(w[2])); // grew larger than w[2] (3.7145)
      expect(state.lastReview, equals(now.add(const Duration(days: 4))));
    });

    test('Mock Error loop should re-inject wrong questions as high priority relearning', () {
      final events = <SrsEvent>[
        // First, answer correctly (creates state)
        QuestionAnsweredEvent(
          clientUlid: 'ulid_q1',
          userId: 'usr_1',
          timestamp: now,
          examContext: 'jaiib_2026',
          questionId: 'q_crr_holder',
          response: const McqResponse('opt_a'),
          correctness: Correctness.correct,
          marksAwarded: 1.0,
        ),
        // Then, submit a mock with an incorrect answer for this question
        MockSubmittedEvent(
          clientUlid: 'ulid_m1',
          userId: 'usr_1',
          timestamp: now.add(const Duration(days: 5)),
          examContext: 'jaiib_2026',
          mockResultId: 'res_1',
          paperId: 'ppb_paper',
          score: 40.0,
          maxScore: 100.0,
          passed: false,
          answers: [
            const MockAnswerSummary(
              questionId: 'q_crr_holder',
              correctness: Correctness.incorrect, // WRONG!
              score: 0.0,
            ),
          ],
        ),
      ];

      final state = projectSrsState(
        userId: 'usr_1',
        itemId: 'q_crr_holder',
        events: events,
        scheduler: fsrs,
        examContext: 'jaiib_2026',
      );

      expect(state, isNotNull);
      expect(state!.reps, equals(2));
      expect(state.lapses, equals(1));
      expect(state.phase, equals(SrsPhase.relearning));
      expect(state.isHighPriority, isTrue); // High priority re-injection!
    });

    test('Sync Loop client-server integration should synchronize logs and reconcile states', () async {
      // 1. Setup server databases
      final serverEventStore = MemoryEventLogStore();
      final serverStateStore = MemorySrsStateStore();
      final serverContentStore = MemoryContentStore();

      // Seed content on server
      final exam = const Exam(id: 'ex_ppb', code: 'PPB', name: 'Principles of Banking', body: '', version: 2);
      final lesson = const Lesson(id: 'les_1', moduleId: 'mod_1', title: LocalizedString({'en': 'Lesson 1'}), version: 2, probeQuestionIds: ['q_1']);
      final question = const QuestionBase(
        id: 'q_1',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({'en': 'Expl'}),
        payload: McqSingle(stem: LocalizedString({'en': 'Stem'}), options: [], correctOptionId: 'opt_1'),
      );
      await serverContentStore.saveExam(exam);
      await serverContentStore.saveLesson(lesson);
      await serverContentStore.saveQuestion(question);

      final serverEngine = ServerSyncEngine(
        eventStore: serverEventStore,
        stateStore: serverStateStore,
        contentStore: serverContentStore,
        scheduler: fsrs,
      );

      // 2. Setup client databases
      final clientEventStore = MemoryEventLogStore();
      final clientStateStore = MemorySrsStateStore();
      final clientContentStore = MemoryContentStore();
      final clientCursorStore = MemorySyncCursorStore();

      final clientEngine = ClientSyncEngine(
        eventStore: clientEventStore,
        stateStore: clientStateStore,
        contentStore: clientContentStore,
        cursorStore: clientCursorStore,
      );

      // Seed unsynced event locally on client
      final newEvent = CardReviewedEvent(
        clientUlid: 'client_ulid_123',
        userId: 'usr_student',
        timestamp: now,
        examContext: 'jaiib_2026',
        itemId: 'q_1',
        rating: Rating.good,
      );
      await clientEventStore.appendEvent(newEvent);

      // Client requests sync. Sends current event + indicates it holds ex_ppb and les_1 at version 1 (outdated)
      final request = await clientEngine.prepareSyncRequest(
        'usr_student',
        {'ex_ppb': 1, 'les_1': 1},
      );

      expect(request.unsyncedEvents.length, equals(1));
      expect(request.unsyncedEvents.first.clientUlid, equals('client_ulid_123'));

      // Server processes request
      final response = await serverEngine.processSyncRequest(request);

      expect(response.acceptedEventUlids, contains('client_ulid_123'));
      expect(response.authoritativeStates.length, equals(1));
      expect(response.authoritativeStates.first.itemId, equals('q_1'));

      // Verify server pulled delta updates because client version (1) was less than server version (2)
      expect(response.contentPackDelta.exams.length, equals(1));
      expect(response.contentPackDelta.exams.first.id, equals('ex_ppb'));
      expect(response.contentPackDelta.lessons.length, equals(1));
      expect(response.contentPackDelta.lessons.first.id, equals('les_1'));
      expect(response.contentPackDelta.questions.length, equals(1));
      expect(response.contentPackDelta.questions.first.id, equals('q_1'));

      // Client applies response
      final syncTime = now.add(const Duration(seconds: 1));
      await clientEngine.applySyncResponse(response, 'usr_student', syncTime);

      // Verify client event store has no unsynced events left
      final unsyncedLeft = await clientEventStore.getUnsyncedEvents('usr_student');
      expect(unsyncedLeft, isEmpty);

      // Verify client local state was updated with server projected SrsState
      final localState = await clientStateStore.getState('usr_student', 'q_1');
      expect(localState, isNotNull);
      expect(localState!.stability, equals(response.authoritativeStates.first.stability));

      // Verify content is now saved locally
      final localExam = await clientContentStore.getExam('ex_ppb');
      expect(localExam, isNotNull);
      expect(localExam!.version, equals(2));

      // Verify cursor is updated
      final lastSync = await clientCursorStore.getLastSyncTime('usr_student');
      expect(lastSync, equals(syncTime));
    });

    test('Sync engine processSyncRequest should be idempotent on duplicate events', () async {
      final serverEventStore = MemoryEventLogStore();
      final serverStateStore = MemorySrsStateStore();
      final serverContentStore = MemoryContentStore();

      final serverEngine = ServerSyncEngine(
        eventStore: serverEventStore,
        stateStore: serverStateStore,
        contentStore: serverContentStore,
        scheduler: fsrs,
      );

      final event = CardReviewedEvent(
        clientUlid: 'client_ulid_123',
        userId: 'usr_student',
        timestamp: now,
        examContext: 'jaiib_2026',
        itemId: 'q_1',
        rating: Rating.good,
      );

      final request1 = SyncRequest(
        userId: 'usr_student',
        unsyncedEvents: [event],
        heldContentPackVersions: const {},
      );

      final response1 = await serverEngine.processSyncRequest(request1);
      expect(response1.acceptedEventUlids, contains('client_ulid_123'));

      // Upload same event again
      final response2 = await serverEngine.processSyncRequest(request1);
      // It is accepted but server store has only 1 copy of the event (idempotency)
      expect(response2.acceptedEventUlids, contains('client_ulid_123'));
      final allEvents = await serverEventStore.getAllEvents('usr_student');
      expect(allEvents.length, equals(1));
    });

    test('Conflict resolution: replaying reviews chronologically guarantees identical results regardless of push order', () async {
      // Device A has review at now (good)
      final eventA = CardReviewedEvent(
        clientUlid: 'ulid_A',
        userId: 'usr_student',
        timestamp: now,
        examContext: 'jaiib_2026',
        itemId: 'q_1',
        rating: Rating.good,
      );

      // Device B has review at now + 5 min (again)
      final eventB = CardReviewedEvent(
        clientUlid: 'ulid_B',
        userId: 'usr_student',
        timestamp: now.add(const Duration(minutes: 5)),
        examContext: 'jaiib_2026',
        itemId: 'q_1',
        rating: Rating.again,
      );

      // Case 1: Replayed in timestamp order
      final state1 = projectSrsState(
        userId: 'usr_student',
        itemId: 'q_1',
        events: [eventB, eventA], // passed out of order
        scheduler: fsrs,
        examContext: 'jaiib_2026',
      );

      // Case 2: Replayed in correct order originally
      final state2 = projectSrsState(
        userId: 'usr_student',
        itemId: 'q_1',
        events: [eventA, eventB],
        scheduler: fsrs,
        examContext: 'jaiib_2026',
      );

      // Assert they are identical
      expect(state1, isNotNull);
      expect(state2, isNotNull);
      expect(state1!.stability, equals(state2!.stability));
      expect(state1.due, equals(state2.due));
      expect(state1.lapses, equals(state2.lapses));
    });
  });
}

// FSRS weight array for validation
const List<double> w = [
  0.4872, 1.4003, 3.7145, 13.8206, 5.1618, 1.2298, 0.8975, 0.0310,
  1.6474, 0.1367, 1.0461, 2.1072, 0.0793, 0.3246, 1.5870, 0.2272, 2.8755,
];
