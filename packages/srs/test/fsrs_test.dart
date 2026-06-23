import 'package:srs/srs.dart';
import 'package:test/test.dart';

void main() {
  group('Fsrs Scheduler Math & State Transitions', () {
    const fsrs = Fsrs();
    final now = DateTime.utc(2026, 6, 23, 10, 0, 0);

    test('init with Rating.good should set expected initial stability and difficulty', () {
      final state = fsrs.init(now, Rating.good);

      // w[2] is 3.7145
      expect(state.stability, closeTo(3.7145, 0.0001));
      // difficulty = w[4] - (grade - 3) * w[5] = 5.1618 - (3 - 3) * 1.2298 = 5.1618
      expect(state.difficulty, closeTo(5.1618, 0.0001));
      expect(state.reps, equals(1));
      expect(state.lapses, equals(0));
      expect(state.phase, equals(SrsPhase.review));
      expect(state.lastReview, equals(now));
      expect(state.due.isAfter(now), isTrue);
    });

    test('init with Rating.again should set lapse metrics and relearning phase', () {
      final state = fsrs.init(now, Rating.again);

      // w[0] is 0.4872
      expect(state.stability, closeTo(0.4872, 0.0001));
      // difficulty = 5.1618 - (1 - 3) * 1.2298 = 5.1618 + 2.4596 = 7.6214
      expect(state.difficulty, closeTo(7.6214, 0.0001));
      expect(state.reps, equals(1));
      expect(state.lapses, equals(1));
      expect(state.phase, equals(SrsPhase.relearning));
    });

    test('review with Rating.good should grow stability and increment reps', () {
      final initialState = fsrs.init(now, Rating.good);
      final nextTime = now.add(const Duration(days: 4)); // review 4 days later

      final nextState = fsrs.review(initialState, Rating.good, nextTime);

      expect(nextState.reps, equals(2));
      expect(nextState.lapses, equals(0));
      expect(nextState.stability, greaterThan(initialState.stability));
      expect(nextState.lastReview, equals(nextTime));
      expect(nextState.due.isAfter(nextTime), isTrue);
    });

    test('review with Rating.again should reset stability and increment lapses', () {
      final initialState = fsrs.init(now, Rating.good);
      final nextTime = now.add(const Duration(days: 4));

      final nextState = fsrs.review(initialState, Rating.again, nextTime);

      expect(nextState.reps, equals(2));
      expect(nextState.lapses, equals(1));
      expect(nextState.stability, lessThan(initialState.stability));
      expect(nextState.phase, equals(SrsPhase.relearning));
    });

    test('SrsState JSON serialization round-trip', () {
      final state = SrsState(
        stability: 4.5,
        difficulty: 3.2,
        due: DateTime.utc(2026, 6, 25, 12, 0, 0),
        lastReview: DateTime.utc(2026, 6, 23, 12, 0, 0),
        reps: 3,
        lapses: 1,
        phase: SrsPhase.review,
        userId: 'usr_123',
        itemId: 'itm_abc',
        examContext: 'jaiib_2026',
        isHighPriority: true,
      );

      final json = state.toJson();
      final roundTrip = SrsState.fromJson(json);

      expect(roundTrip.stability, equals(state.stability));
      expect(roundTrip.difficulty, equals(state.difficulty));
      expect(roundTrip.due, equals(state.due));
      expect(roundTrip.lastReview, equals(state.lastReview));
      expect(roundTrip.reps, equals(state.reps));
      expect(roundTrip.lapses, equals(state.lapses));
      expect(roundTrip.phase, equals(state.phase));
      expect(roundTrip.userId, equals(state.userId));
      expect(roundTrip.itemId, equals(state.itemId));
      expect(roundTrip.examContext, equals(state.examContext));
      expect(roundTrip.isHighPriority, equals(state.isHighPriority));
    });

    test('LearnableItem JSON serialization round-trip', () {
      const item = LearnableItem(
        id: 'lrn_1',
        kind: LearnableItemKind.card,
        refId: 'card_crr',
        probeQuestionIds: ['q_crr_1', 'q_crr_2'],
        topicTags: ['regulation', 'banking'],
        examContexts: ['jaiib_2026'],
      );

      final json = item.toJson();
      final roundTrip = LearnableItem.fromJson(json);

      expect(roundTrip.id, equals(item.id));
      expect(roundTrip.kind, equals(item.kind));
      expect(roundTrip.refId, equals(item.refId));
      expect(roundTrip.probeQuestionIds, equals(item.probeQuestionIds));
      expect(roundTrip.topicTags, equals(item.topicTags));
      expect(roundTrip.examContexts, equals(item.examContexts));
    });
  });
}
