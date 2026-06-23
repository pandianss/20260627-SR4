import 'package:srs/srs.dart';
import 'package:test/test.dart';

void main() {
  group('buildDueQueue Logic & Interleaving', () {
    final now = DateTime.utc(2026, 6, 23, 10, 0, 0);

    // Mock learnable items in different topics
    final items = {
      'itm_a1': const LearnableItem(
        id: 'itm_a1',
        kind: LearnableItemKind.card,
        refId: 'c1',
        topicTags: ['accounting'],
      ),
      'itm_a2': const LearnableItem(
        id: 'itm_a2',
        kind: LearnableItemKind.card,
        refId: 'c2',
        topicTags: ['accounting'],
      ),
      'itm_e1': const LearnableItem(
        id: 'itm_e1',
        kind: LearnableItemKind.card,
        refId: 'c3',
        topicTags: ['esi'],
      ),
      'itm_e2': const LearnableItem(
        id: 'itm_e2',
        kind: LearnableItemKind.card,
        refId: 'c4',
        topicTags: ['esi'],
      ),
      'itm_r1': const LearnableItem(
        id: 'itm_r1',
        kind: LearnableItemKind.card,
        refId: 'c5',
        topicTags: ['reasoning'],
      ),
      'itm_r2': const LearnableItem(
        id: 'itm_r2',
        kind: LearnableItemKind.card,
        refId: 'c6',
        topicTags: ['reasoning'],
      ),
    };

    test('should filter out items not due', () {
      final List<SrsState> states = [
        SrsState(
          stability: 5.0,
          difficulty: 3.0,
          due: now.subtract(const Duration(days: 1)), // due yesterday (should include)
          lastReview: now.subtract(const Duration(days: 6)),
          itemId: 'itm_a1',
          reps: 2,
        ),
        SrsState(
          stability: 5.0,
          difficulty: 3.0,
          due: now.add(const Duration(days: 1)), // due tomorrow (should filter out)
          lastReview: now.subtract(const Duration(days: 4)),
          itemId: 'itm_e1',
          reps: 2,
        ),
      ];

      final queue = buildDueQueue(
        states: states,
        items: items,
        now: now,
        budget: 10,
      );

      expect(queue.length, equals(1));
      expect(queue.first.itemId, equals('itm_a1'));
    });

    test('should prioritize high priority and relearning items', () {
      final List<SrsState> states = [
        SrsState(
          stability: 10.0,
          difficulty: 3.0,
          due: now.subtract(const Duration(days: 2)), // overdue ratio = 2/10 = 0.2
          lastReview: now.subtract(const Duration(days: 12)),
          itemId: 'itm_a1',
          reps: 2,
        ),
        SrsState(
          stability: 10.0,
          difficulty: 3.0,
          due: now.subtract(const Duration(days: 2)), // overdue ratio = 0.2 + 20 (high priority)
          lastReview: now.subtract(const Duration(days: 12)),
          itemId: 'itm_e1',
          reps: 2,
          isHighPriority: true,
        ),
        SrsState(
          stability: 10.0,
          difficulty: 3.0,
          due: now.subtract(const Duration(days: 2)), // overdue ratio = 0.2 + 10 (relearning)
          lastReview: now.subtract(const Duration(days: 12)),
          itemId: 'itm_r1',
          reps: 2,
          phase: SrsPhase.relearning,
        ),
      ];

      final queue = buildDueQueue(
        states: states,
        items: items,
        now: now,
        budget: 10,
      );

      expect(queue.length, equals(3));
      // order should be: highPriority (itm_e1) -> relearning (itm_r1) -> regular (itm_a1)
      expect(queue[0].itemId, equals('itm_e1'));
      expect(queue[1].itemId, equals('itm_r1'));
      expect(queue[2].itemId, equals('itm_a1'));
    });

    test('should apply topic accuracy (weakness) multiplier and weights', () {
      final List<SrsState> states = [
        SrsState(
          stability: 10.0,
          difficulty: 3.0,
          due: now.subtract(const Duration(days: 2)), // overdue ratio = 0.2. Topic 'accounting'
          lastReview: now.subtract(const Duration(days: 12)),
          itemId: 'itm_a1',
          reps: 2,
        ),
        SrsState(
          stability: 10.0,
          difficulty: 3.0,
          due: now.subtract(const Duration(days: 2)), // overdue ratio = 0.2. Topic 'esi'
          lastReview: now.subtract(const Duration(days: 12)),
          itemId: 'itm_e1',
          reps: 2,
        ),
      ];

      // ESI has 0% accuracy (multiplier = 1 + (1 - 0) * 2 = 3.0x) -> priority = 0.6
      // Accounting has 100% accuracy (multiplier = 1 + (1 - 1) * 2 = 1.0x) -> priority = 0.2
      final queue = buildDueQueue(
        states: states,
        items: items,
        now: now,
        budget: 10,
        topicAccuracy: {
          'esi': 0.0,
          'accounting': 1.0,
        },
      );

      expect(queue.length, equals(2));
      expect(queue[0].itemId, equals('itm_e1')); // ESI should come first due to low accuracy
      expect(queue[1].itemId, equals('itm_a1'));
    });

    test('should interleave topics to avoid consecutive duplicate topics', () {
      // Create 2 accounting items, 2 esi items, and 2 reasoning items
      final List<SrsState> states = [
        SrsState(stability: 10.0, difficulty: 3.0, due: now.subtract(const Duration(days: 5)), lastReview: now.subtract(const Duration(days: 15)), itemId: 'itm_a1', reps: 2), // Accounting, priority ~ 0.5
        SrsState(stability: 10.0, difficulty: 3.0, due: now.subtract(const Duration(days: 4)), lastReview: now.subtract(const Duration(days: 14)), itemId: 'itm_a2', reps: 2), // Accounting, priority ~ 0.4
        SrsState(stability: 10.0, difficulty: 3.0, due: now.subtract(const Duration(days: 1)), lastReview: now.subtract(const Duration(days: 11)), itemId: 'itm_e1', reps: 2), // ESI, priority ~ 0.1
        SrsState(stability: 10.0, difficulty: 3.0, due: now.subtract(const Duration(days: 2)), lastReview: now.subtract(const Duration(days: 12)), itemId: 'itm_e2', reps: 2), // ESI, priority ~ 0.2
        SrsState(stability: 10.0, difficulty: 3.0, due: now.subtract(const Duration(days: 3)), lastReview: now.subtract(const Duration(days: 13)), itemId: 'itm_r1', reps: 2), // Reasoning, priority ~ 0.3
        SrsState(stability: 10.0, difficulty: 3.0, due: now.subtract(const Duration(days: 1, hours: 12)), lastReview: now.subtract(const Duration(days: 11, hours: 12)), itemId: 'itm_r2', reps: 2), // Reasoning, priority ~ 0.15
      ];

      final queue = buildDueQueue(
        states: states,
        items: items,
        now: now,
        budget: 6,
      );

      expect(queue.length, equals(6));

      // Verify that no two consecutive items share the same topic
      for (int i = 0; i < queue.length - 1; i++) {
        final t1 = items[queue[i].itemId]!.topicTags.first;
        final t2 = items[queue[i + 1].itemId]!.topicTags.first;
        expect(t1, isNot(equals(t2)), reason: 'Consecutive items at $i and ${i+1} have the same topic: $t1');
      }
    });
  });
}
