import 'package:domain/domain.dart';
import 'package:test/test.dart';

QuestionBase _mcq({
  String id = 'q',
  String correct = 'b',
  LocalizedString? explanation,
}) =>
    QuestionBase(
      id: id,
      gradingMode: GradingMode.autoExact,
      explanation: explanation ?? LocalizedString({'en': 'because'}),
      payload: McqSingle(
        stem: LocalizedString({'en': 'Q?'}),
        options: [
          QuestionOption(id: 'a', content: LocalizedString({'en': 'A'})),
          QuestionOption(id: 'b', content: LocalizedString({'en': 'B'})),
        ],
        correctOptionId: correct,
      ),
    );

void main() {
  const v = ContentValidator(requiredLanguages: ['en']);

  group('publish gate', () {
    test('a well-formed mcq is publishable', () {
      final r = v.validateQuestion(_mcq());
      expect(r.isValid, isTrue, reason: r.errors.join('\n'));
      expect(v.canPublish(_mcq()), isTrue);
    });

    test('mcq with a correctOptionId not in options fails', () {
      final r = v.validateQuestion(_mcq(correct: 'zzz'));
      expect(r.publishable, isFalse);
      expect(r.errors.any((e) => e.message.contains('correctOptionId')), isTrue);
    });

    test('passage_ref without a stimulusId fails', () {
      final q = QuestionBase(
        id: 'q_pr',
        gradingMode: GradingMode.autoNumeric,
        explanation: LocalizedString({'en': 'x'}),
        payload: PassageRef(
          innerType: 'numeric',
          inner: NumericEntry(
            stem: LocalizedString({'en': '?'}),
            answerValue: 1,
            tolerance: const NumericTolerance(
                kind: ToleranceKind.absolute, amount: 0.1),
          ),
        ),
      );
      final r = v.validateQuestion(q);
      expect(r.errors.any((e) => e.message.contains('stimulusId')), isTrue);
    });

    test('empty explanation fails (it is the teaching moment)', () {
      final r = v.validateQuestion(_mcq(explanation: const LocalizedString({})));
      expect(r.errors.any((e) => e.message.contains('explanation')), isTrue);
    });
  });

  group('multilingual completeness', () {
    test('missing a required language is an error', () {
      const v2 = ContentValidator(requiredLanguages: ['en', 'hi']);
      final q = QuestionBase(
        id: 'q_lang',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({'en': 'x'}), // no hi
        payload: TrueFalse(
          stem: LocalizedString({'en': 'true?', 'hi': 'सही?'}),
          answer: true,
        ),
      );
      final r = v2.validateQuestion(q);
      expect(r.errors.any((e) => e.message.contains('missing language "hi"')),
          isTrue);
    });
  });

  group('lesson rules', () {
    test('a calm 4-card lesson with a visual concept card is valid', () {
      final lesson = Lesson(
        id: 'l1',
        moduleId: 'm1',
        title: LocalizedString({'en': 'Cash reserve ratio'}),
        estMinutes: 5,
        probeQuestionIds: ['q_crr_holder'],
        cards: [
          Card(
              id: 'c1',
              kind: CardKind.intro,
              blocks: [TextBlock(LocalizedString({'en': 'intro'}))]),
          Card(
              id: 'c2',
              kind: CardKind.concept,
              srsEligible: true,
              blocks: [
                TextBlock(LocalizedString({'en': 'CRR'})),
                const FormulaBlock('CRR = 0.045 \\times D'),
              ]),
          Card(
              id: 'c3',
              kind: CardKind.concept,
              srsEligible: true,
              blocks: [const ChartBlock({'type': 'bar_segment'})]),
          Card(
              id: 'c4',
              kind: CardKind.recap,
              blocks: [TextBlock(LocalizedString({'en': 'recap'}))]),
        ],
      );
      final r = v.validateLesson(lesson);
      expect(r.isValid, isTrue, reason: r.errors.join('\n'));
    });

    test('a text-only concept card warns but does not block', () {
      final lesson = Lesson(
        id: 'l2',
        moduleId: 'm1',
        title: LocalizedString({'en': 'T'}),
        probeQuestionIds: ['q1'],
        cards: [
          Card(
              id: 'c1',
              kind: CardKind.intro,
              blocks: [TextBlock(LocalizedString({'en': 'i'}))]),
          Card(
              id: 'c2',
              kind: CardKind.concept,
              blocks: [TextBlock(LocalizedString({'en': 'text only'}))]),
          Card(
              id: 'c3',
              kind: CardKind.concept,
              blocks: [const FormulaBlock('x=1')]),
          Card(
              id: 'c4',
              kind: CardKind.recap,
              blocks: [TextBlock(LocalizedString({'en': 'r'}))]),
        ],
      );
      final r = v.validateLesson(lesson);
      expect(r.isValid, isTrue);
      expect(r.warnings.any((w) => w.message.contains('text-only')), isTrue);
    });

    test('a lesson with no probe questions fails', () {
      final lesson = Lesson(
        id: 'l3',
        moduleId: 'm1',
        title: LocalizedString({'en': 'T'}),
        cards: [
          Card(id: 'c1', kind: CardKind.intro, blocks: [
            TextBlock(LocalizedString({'en': 'i'}))
          ]),
        ],
      );
      final r = v.validateLesson(lesson);
      expect(r.publishable, isFalse);
      expect(r.errors.any((e) => e.message.contains('probe questions')), isTrue);
    });
  });
}
