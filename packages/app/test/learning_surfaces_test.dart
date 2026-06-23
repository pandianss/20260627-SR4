import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:grading/grading.dart';
import 'package:app/components/block_renderer.dart';
import 'package:app/components/question_renderer.dart';
import 'package:app/components/caselet_renderer.dart';
import 'package:app/screens/lesson_player_screen.dart';
import 'package:app/screens/review_screen.dart';
import 'package:app/theme/tokens.dart';
import 'package:app/components/option_chip.dart';
import 'package:app/components/rating_buttons.dart';

void main() {
  group('Epic E6: ContentBlockRenderer Widget Tests', () {
    testWidgets('Renders Text, Formula, and Chart blocks correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: const Scaffold(
            body: Column(
              children: [
                ContentBlockRenderer(block: TextBlock(LocalizedString({'en': 'Mock Text Content'}))),
                ContentBlockRenderer(block: FormulaBlock('x^2 + y^2 = z^2')),
                ContentBlockRenderer(block: ChartBlock({'type': 'bar'})),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Mock Text Content'), findsOneWidget);
      expect(find.text('x^2 + y^2 = z^2'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('Epic E6: QuestionRenderer Widget Tests', () {
    testWidgets('MCQ Question flow: selection, grading, HUD feedback, and explanation', (tester) async {
      final question = QuestionBase(
        id: 'q_mcq',
        gradingMode: GradingMode.autoExact,
        explanation: const LocalizedString({'en': 'An explanation of the CRR formula.'}),
        payload: const McqSingle(
          stem: LocalizedString({'en': 'What is CRR?'}),
          options: [
            QuestionOption(id: 'opt_a', content: LocalizedString({'en': 'Option A'})),
            QuestionOption(id: 'opt_b', content: LocalizedString({'en': 'Option B'})),
          ],
          correctOptionId: 'opt_a',
        ),
      );

      Response? checkedResponse;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuestionRenderer(
                question: question,
                onAnswerChecked: (resp) => checkedResponse = resp,
                onContinue: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('What is CRR?'), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('An explanation of the CRR formula.'), findsNothing);

      // Select option B (incorrect option)
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      // Tap Check Answer button
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      expect(checkedResponse, isA<McqResponse>());
      expect((checkedResponse as McqResponse).optionId, equals('opt_b'));

      // Explanation and Correctness HUD should show up
      expect(find.text('An explanation of the CRR formula.'), findsOneWidget);
      expect(find.text('Incorrect'), findsOneWidget);
    });

    testWidgets('True/False Question flow: selection and grading', (tester) async {
      final question = QuestionBase(
        id: 'q_tf',
        gradingMode: GradingMode.autoExact,
        explanation: const LocalizedString({'en': 'Explanation for True/False.'}),
        payload: const TrueFalse(
          stem: LocalizedString({'en': 'True or False?'}),
          answer: true,
        ),
      );

      Response? checkedResponse;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuestionRenderer(
                question: question,
                onAnswerChecked: (resp) => checkedResponse = resp,
                onContinue: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('True or False?'), findsOneWidget);

      // Tap True
      await tester.tap(find.text('True'));
      await tester.pumpAndSettle();

      // Tap Check
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      expect(checkedResponse, isA<TrueFalseResponse>());
      expect((checkedResponse as TrueFalseResponse).value, isTrue);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('Explanation for True/False.'), findsOneWidget);
    });

    testWidgets('Numeric Entry flow: typing input and checking answer', (tester) async {
      final question = QuestionBase(
        id: 'q_num',
        gradingMode: GradingMode.autoNumeric,
        explanation: const LocalizedString({'en': 'Numeric explanation.'}),
        payload: const NumericEntry(
          stem: LocalizedString({'en': 'Enter 4.5'}),
          answerValue: 4.5,
          unit: '%',
          tolerance: NumericTolerance(kind: ToleranceKind.absolute, amount: 0.0),
        ),
      );

      Response? checkedResponse;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuestionRenderer(
                question: question,
                onAnswerChecked: (resp) => checkedResponse = resp,
                onContinue: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Enter 4.5'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);

      // Type numeric value
      await tester.enterText(find.byType(TextField), '4.5');
      await tester.pump();

      // Tap Check
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      expect(checkedResponse, isA<NumericResponse>());
      expect((checkedResponse as NumericResponse).value, equals(4.5));
      expect(find.text('Correct'), findsOneWidget);
    });

    testWidgets('MatchPairs flow: dropdown matching mapping', (tester) async {
      final question = QuestionBase(
        id: 'q_match',
        gradingMode: GradingMode.autoExact,
        explanation: const LocalizedString({'en': 'Match explanation.'}),
        payload: const MatchPairs(
          stem: LocalizedString({'en': 'Match left to right'}),
          left: [
            QuestionOption(id: 'L1', content: LocalizedString({'en': 'Asset'})),
          ],
          right: [
            QuestionOption(id: 'R1', content: LocalizedString({'en': 'Liability'})),
          ],
          correct: {'L1': 'R1'},
        ),
      );

      Response? checkedResponse;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuestionRenderer(
                question: question,
                onAnswerChecked: (resp) => checkedResponse = resp,
                onContinue: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Match left to right'), findsOneWidget);
      expect(find.text('Asset'), findsOneWidget);

      // Tap dropdown trigger directly by its type
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Tap the dropdown option
      await tester.tap(find.text('Liability').last);
      await tester.pumpAndSettle();

      // Tap Check
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      expect(checkedResponse, isA<MatchResponse>());
      expect((checkedResponse as MatchResponse).mapping['L1'], equals('R1'));
    });
  });

  group('Epic E6: CaseletRenderer Widget Tests', () {
    testWidgets('Renders pinned stimulus scenario and advances child questions', (tester) async {
      final stimulus = const Stimulus(
        id: 'stim_1',
        kind: StimulusKind.caselet,
        content: LocalizedString({'en': 'Stimulus Scenario Text Content.'}),
      );

      final question = QuestionBase(
        id: 'q_child',
        stimulusId: 'stim_1',
        gradingMode: GradingMode.autoExact,
        explanation: const LocalizedString({'en': 'Explanation.'}),
        payload: const TrueFalse(
          stem: LocalizedString({'en': 'Child Question?'}),
          answer: true,
        ),
      );

      String? answeredQid;
      Response? answeredResp;
      bool isComplete = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: SingleChildScrollView(
              child: CaseletRenderer(
                stimulus: stimulus,
                childQuestions: [question],
                onQuestionAnswered: (qid, resp) {
                  answeredQid = qid;
                  answeredResp = resp;
                },
                onComplete: () => isComplete = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Caselet Scenario'), findsOneWidget);
      expect(find.text('Stimulus Scenario Text Content.'), findsOneWidget);
      expect(find.text('Child Question?'), findsOneWidget);

      // Select option
      await tester.tap(find.text('True'));
      await tester.pumpAndSettle();

      // Check answer
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      expect(answeredQid, equals('q_child'));
      expect(answeredResp, isA<TrueFalseResponse>());

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(isComplete, isTrue);
    });
  });

  group('Epic E6: LessonPlayerScreen Widget Tests', () {
    testWidgets('Swipe through card deck and complete retrieval questions', (tester) async {
      final lesson = const Lesson(
        id: 'les_test',
        moduleId: 'm_test',
        title: LocalizedString({'en': 'Unit Test Lesson'}),
        cards: [
          Card(
            id: 'c1',
            kind: CardKind.concept,
            blocks: [TextBlock(LocalizedString({'en': 'First Concept Card'}))],
          ),
          Card(
            id: 'c2',
            kind: CardKind.concept,
            blocks: [TextBlock(LocalizedString({'en': 'Second Concept Card'}))],
          ),
        ],
      );

      final question = QuestionBase(
        id: 'q_test',
        gradingMode: GradingMode.autoExact,
        explanation: const LocalizedString({'en': 'Explanation.'}),
        payload: const TrueFalse(
          stem: LocalizedString({'en': 'Retrieval Question'}),
          answer: true,
        ),
      );

      List<SrsEvent>? completedEvents;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: LessonPlayerScreen(
            lesson: lesson,
            questions: [question],
            stimuli: const [],
            userId: 'test_user',
            onComplete: (events) => completedEvents = events,
          ),
        ),
      );

      // Card 1
      expect(find.text('First Concept Card'), findsOneWidget);
      expect(find.text('Next Card'), findsOneWidget);

      // Go to Card 2
      await tester.tap(find.text('Next Card'));
      await tester.pumpAndSettle();

      expect(find.text('Second Concept Card'), findsOneWidget);
      expect(find.text('Start Practice'), findsOneWidget);

      // Go to Questions
      await tester.tap(find.text('Start Practice'));
      await tester.pumpAndSettle();

      expect(find.text('Retrieval Question'), findsOneWidget);

      // Select Answer
      await tester.tap(find.text('True'));
      await tester.pumpAndSettle();

      // Check
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      // Continue to finish
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(completedEvents, isNotNull);
      expect(completedEvents!.length, equals(2));
      expect(completedEvents![0], isA<QuestionAnsweredEvent>());
      expect(completedEvents![1], isA<LessonViewedEvent>());
    });
  });

  group('Epic E6: ReviewScreen Widget Tests', () {
    testWidgets('Presents due deck, flips card, registers FSRS review rating and events', (tester) async {
      final contentStore = MemoryContentStore();
      final eventStore = MemoryEventLogStore();
      final stateStore = MemorySrsStateStore();
      final scheduler = const Fsrs();

      final exam = const Exam(id: 'ex_rev', code: 'ex_rev', name: 'Exam', body: 'Body');
      await contentStore.saveExam(exam);

      final paper = const Paper(
        id: 'p_rev',
        examCode: 'ex_rev',
        name: LocalizedString({'en': 'Paper'}),
        moduleIds: ['m_rev'],
      );
      await contentStore.savePaper(paper);

      final module = const Module(
        id: 'm_rev',
        paperId: 'p_rev',
        name: LocalizedString({'en': 'Module'}),
        lessonIds: ['les_rev'],
      );
      await contentStore.saveModule(module);

      final lesson = const Lesson(
        id: 'les_rev',
        moduleId: 'm_rev',
        title: LocalizedString({'en': 'Spaced Review Lesson'}),
        cards: [
          Card(
            id: 'card_rev_1',
            kind: CardKind.concept,
            blocks: [TextBlock(LocalizedString({'en': 'FSRS Spaced Review Detail'}))],
            srsEligible: true,
          ),
        ],
      );
      await contentStore.saveLesson(lesson);

      final state = SrsState(
        stability: 1.0,
        difficulty: 3.0,
        due: DateTime.now().subtract(const Duration(minutes: 5)),
        lastReview: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'test_user',
        itemId: 'card_rev_1',
        examContext: 'ex_rev',
      );
      await stateStore.saveState(state);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: ReviewScreen(
            userId: 'test_user',
            examContext: 'ex_rev',
            contentStore: contentStore,
            eventStore: eventStore,
            stateStore: stateStore,
            scheduler: scheduler,
          ),
        ),
      );

      // Loading state ends
      await tester.pumpAndSettle();

      expect(find.text('Active Recall Prompt'), findsOneWidget);
      expect(find.text('Reveal Answer'), findsOneWidget);

      // Reveal back card
      await tester.tap(find.text('Reveal Answer'));
      await tester.pumpAndSettle();

      expect(find.text('FSRS Spaced Review Detail'), findsOneWidget);
      expect(find.byType(CalmRatingButtons), findsOneWidget);

      // Grade as Good
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      // Memory state should be saved to store
      final updatedState = await stateStore.getState('test_user', 'card_rev_1');
      expect(updatedState, isNotNull);
      expect(updatedState!.reps, equals(1));

      // Review event appended
      final events = await eventStore.getAllEvents('test_user');
      expect(events.length, equals(1));
      expect(events[0], isA<CardReviewedEvent>());
      expect((events[0] as CardReviewedEvent).rating, equals(Rating.good));

      // Finished queue screen should display
      expect(find.text('All caught up!'), findsOneWidget);
    });
  });
}
