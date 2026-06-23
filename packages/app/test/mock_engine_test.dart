import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:grading/grading.dart';
import 'package:app/screens/mock_player_screen.dart';
import 'package:app/screens/mock_result_screen.dart';
import 'package:app/theme/tokens.dart';
import 'package:app/components/progress_ring.dart';

void main() {
  group('Mock Engine: Assembly Tests', () {
    test('assembleMock selects correct counts and difficulty mix', () {
      final q1 = const QuestionBase(
        id: 'q1',
        difficulty: 1,
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({}),
        topicTags: ['crr'],
        payload: McqSingle(
          stem: LocalizedString({}),
          options: [],
          correctOptionId: '',
        ),
      );

      final q2 = const QuestionBase(
        id: 'q2',
        difficulty: 1,
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({}),
        topicTags: ['crr'],
        payload: McqSingle(
          stem: LocalizedString({}),
          options: [],
          correctOptionId: '',
        ),
      );

      final q3 = const QuestionBase(
        id: 'q3',
        difficulty: 2,
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({}),
        topicTags: ['slr'],
        payload: McqSingle(
          stem: LocalizedString({}),
          options: [],
          correctOptionId: '',
        ),
      );

      final bank = [q1, q2, q3];

      final blueprint = const MockBlueprint(
        id: 'bp_test',
        name: 'Test Mock',
        picks: [
          MockPick(
            topicTags: ['crr', 'slr'],
            count: 2,
            difficultyMix: {1: 0.5, 2: 0.5},
          ),
        ],
        shuffle: false,
      );

      final assembled = assembleMock(blueprint, bank);

      expect(assembled.length, equals(2));
      // Assembled should have one of difficulty 1 and one of difficulty 2
      final diff1Count = assembled.where((q) => q.difficulty == 1).length;
      final diff2Count = assembled.where((q) => q.difficulty == 2).length;
      expect(diff1Count, equals(1));
      expect(diff2Count, equals(1));
    });

    test('assembleMock groups caselets together sequentially', () {
      final q1 = const QuestionBase(
        id: 'q1',
        difficulty: 1,
        stimulusId: 'stim_a',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({}),
        topicTags: ['crr'],
        payload: McqSingle(stem: LocalizedString({}), options: [], correctOptionId: ''),
      );

      final q2 = const QuestionBase(
        id: 'q2',
        difficulty: 1,
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({}),
        topicTags: ['slr'],
        payload: McqSingle(stem: LocalizedString({}), options: [], correctOptionId: ''),
      );

      final q3 = const QuestionBase(
        id: 'q3',
        difficulty: 1,
        stimulusId: 'stim_a',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({}),
        topicTags: ['crr'],
        payload: McqSingle(stem: LocalizedString({}), options: [], correctOptionId: ''),
      );

      // Raw order: q1 (caselet), q2 (standalone), q3 (caselet)
      final bank = [q1, q2, q3];

      final blueprint = const MockBlueprint(
        id: 'bp_test',
        name: 'Test Mock',
        picks: [
          MockPick(
            topicTags: [],
            count: 3,
            difficultyMix: {1: 1.0},
          ),
        ],
        shuffle: false,
      );

      final assembled = assembleMock(blueprint, bank);

      expect(assembled.length, equals(3));
      // Grouping should bring q1 and q3 next to each other
      final first = assembled[0];
      final second = assembled[1];
      final third = assembled[2];

      if (first.id == 'q2') {
        expect(second.stimulusId, equals('stim_a'));
        expect(third.stimulusId, equals('stim_a'));
      } else {
        expect(first.stimulusId, equals('stim_a'));
        expect(second.stimulusId, equals('stim_a'));
        expect(third.id, equals('q2'));
      }
    });
  });

  group('Mock Engine: Pass Rules & Scoring Tests', () {
    test('evaluatePass handles JAIIB cutoff and aggregate outcomes', () {
      final rule = const PassRule(
        perComponentMin: 50,
        alternativeAggregate: AlternativeAggregate(perComponentMin: 45, aggregateMin: 50),
      );

      // Path 1 Pass: meets 50% cutoff
      final result1 = evaluatePass([
        const ComponentScore(code: 'PPB', scored: 50, max: 100),
      ], rule);
      expect(result1.passed, isTrue);
      expect(result1.reason, contains('Each component met 50%'));

      // Path 2 Pass: aggregate >= 50% and all >= 45%
      final result2 = evaluatePass([
        const ComponentScore(code: 'PPB', scored: 48, max: 100),
        const ComponentScore(code: 'AFB', scored: 52, max: 100),
      ], rule);
      expect(result2.passed, isTrue);
      expect(result2.reason, contains('Aggregate path'));

      // Fail: component below 45%
      final result3 = evaluatePass([
        const ComponentScore(code: 'PPB', scored: 44, max: 100),
        const ComponentScore(code: 'AFB', scored: 58, max: 100),
      ], rule);
      expect(result3.passed, isFalse);
    });
  });

  group('Mock Engine: Widget Player and Results Tests', () {
    final qMock = const QuestionBase(
      id: 'q_mock_1',
      topicTags: ['crr'],
      difficulty: 1,
      gradingMode: GradingMode.autoExact,
      explanation: LocalizedString({'en': 'Explanation text'}),
      payload: McqSingle(
        stem: LocalizedString({'en': 'Question?'}),
        options: [
          QuestionOption(id: 'opt_a', content: LocalizedString({'en': 'Option A'})),
          QuestionOption(id: 'opt_b', content: LocalizedString({'en': 'Option B'})),
        ],
        correctOptionId: 'opt_a',
      ),
    );

    final blueprint = const MockBlueprint(
      id: 'bp_test_widget',
      name: 'Widget Mock Test',
      picks: [
        MockPick(topicTags: [], count: 1, difficultyMix: {1: 1.0})
      ],
      timingFromPaper: 'PPB',
    );

    final examConfig = const ExamConfig(
      examCode: 'JAIIB',
      papers: [
        PaperConfig(paperCode: 'PPB', durationMin: 120),
      ],
      passRule: PassRule(perComponentMin: 50),
    );

    testWidgets('MockPlayerScreen loads, records answers, flags, and triggers submission dialog', (tester) async {
      final contentStore = MemoryContentStore();
      final eventStore = MemoryEventLogStore();
      final stateStore = MemorySrsStateStore();
      final scheduler = const Fsrs();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: MockPlayerScreen(
            blueprint: blueprint,
            questions: [qMock],
            stimuli: const [],
            userId: 'test_user',
            contentStore: contentStore,
            eventStore: eventStore,
            stateStore: stateStore,
            scheduler: scheduler,
            examName: 'JAIIB',
            examConfig: examConfig,
          ),
        ),
      );

      expect(find.text('Widget Mock Test'), findsOneWidget);
      expect(find.text('Question?'), findsOneWidget);

      // Select Answer (Option A)
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Flag for review
      await tester.tap(find.text('Flag Question'));
      await tester.pumpAndSettle();

      // Tap Submit Exam button (in bottom bar or top actions)
      await tester.tap(find.text('Submit Exam'));
      await tester.pumpAndSettle();

      // Should show submit dialog
      expect(find.text('Submit Mock Exam?'), findsOneWidget);

      // Confirm Submit
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Submit'),
        ),
      );
      await tester.pumpAndSettle();

      // Should load MockResultScreen and calculate results
      expect(find.byType(MockResultScreen), findsOneWidget);
    });

    testWidgets('MockResultScreen displays scores, weakness map, and schedules SRS relearning', (tester) async {
      final contentStore = MemoryContentStore();
      final eventStore = MemoryEventLogStore();
      final stateStore = MemorySrsStateStore();
      final scheduler = const Fsrs();

      // Seed state store
      final state = SrsState(
        stability: 1.0,
        difficulty: 3.0,
        due: DateTime.now(),
        lastReview: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'test_user',
        itemId: 'q_mock_1',
        examContext: 'JAIIB',
      );
      await stateStore.saveState(state);

      // Option B chosen (incorrect response)
      final responses = {'q_mock_1': const McqResponse('opt_b')};

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: MockResultScreen(
            blueprint: blueprint,
            questions: [qMock],
            responses: responses,
            userId: 'test_user',
            contentStore: contentStore,
            eventStore: eventStore,
            stateStore: stateStore,
            scheduler: scheduler,
            examName: 'JAIIB',
            examConfig: examConfig,
          ),
        ),
      );

      // Wait for grading to finish
      await tester.pumpAndSettle();

      expect(find.text('FAILED'), findsOneWidget);
      expect(find.text('Topic Weakness Analysis'), findsOneWidget);
      expect(find.text('CRR'), findsOneWidget); // Topic tag capitalized

      // SRS state of q_mock_1 should be updated to high priority relearning item (lapsed)
      final updatedState = await stateStore.getState('test_user', 'q_mock_1');
      expect(updatedState, isNotNull);
      expect(updatedState!.isHighPriority, isTrue);

      // Event log should contain MockSubmittedEvent
      final events = await eventStore.getAllEvents('test_user');
      expect(events.length, equals(1));
      expect(events[0], isA<MockSubmittedEvent>());
    });
  });
}
