import 'package:domain/domain.dart';
import 'package:grading/grading.dart';
import 'package:test/test.dart';

void main() {
  const grader = Grader();

  QuestionBase mcq(String correct) => QuestionBase(
        id: 'q',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({'en': 'x'}),
        payload: McqSingle(
          stem: LocalizedString({'en': 'Q'}),
          options: [
            QuestionOption(id: 'a', content: LocalizedString({'en': 'A'})),
            QuestionOption(id: 'b', content: LocalizedString({'en': 'B'})),
          ],
          correctOptionId: correct,
        ),
      );

  group('Grader', () {
    test('mcq_single correct / incorrect / unanswered', () {
      expect(grader.grade(mcq('b'), McqResponse('b')).correctness,
          Correctness.correct);
      expect(grader.grade(mcq('b'), McqResponse('a')).correctness,
          Correctness.incorrect);
      expect(grader.grade(mcq('b'), null).correctness, Correctness.unanswered);
    });

    test('true_false', () {
      final q = QuestionBase(
        id: 'tf',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({'en': 'x'}),
        payload: TrueFalse(stem: LocalizedString({'en': 'Q'}), answer: true),
      );
      expect(grader.grade(q, TrueFalseResponse(true)).correctness,
          Correctness.correct);
      expect(grader.grade(q, TrueFalseResponse(false)).correctness,
          Correctness.incorrect);
    });

    test('match_pairs full, partial (per_pair), and none', () {
      MatchPairs mp(PartialCredit pc) => MatchPairs(
            stem: LocalizedString({'en': 'Q'}),
            left: [
              QuestionOption(id: 'l1', content: LocalizedString({'en': 'CRR'})),
              QuestionOption(id: 'l2', content: LocalizedString({'en': 'SLR'})),
            ],
            right: [
              QuestionOption(id: 'r1', content: LocalizedString({'en': 'RBI'})),
              QuestionOption(id: 'r2', content: LocalizedString({'en': 'Bank'})),
            ],
            correct: {'l1': 'r1', 'l2': 'r2'},
            partialCredit: pc,
          );
      final full = grader.gradePayload(
          mp(PartialCredit.perPair), MatchResponse({'l1': 'r1', 'l2': 'r2'}));
      expect(full.correctness, Correctness.correct);

      final partial = grader.gradePayload(
          mp(PartialCredit.perPair), MatchResponse({'l1': 'r1', 'l2': 'r1'}));
      expect(partial.correctness, Correctness.partial);
      expect(partial.credit, closeTo(0.5, 1e-9));

      final none = grader.gradePayload(
          mp(PartialCredit.none), MatchResponse({'l1': 'r1', 'l2': 'r1'}));
      expect(none.correctness, Correctness.incorrect);
    });

    test('numeric tolerance: absolute, relative, decimals', () {
      NumericEntry num(NumericTolerance t) => NumericEntry(
            stem: LocalizedString({'en': 'Q'}),
            answerValue: 100,
            tolerance: t,
          );
      // absolute +/- 0.5
      final abs = num(const NumericTolerance(kind: ToleranceKind.absolute, amount: 0.5));
      expect(grader.gradePayload(abs, NumericResponse(100.4)).correctness,
          Correctness.correct);
      expect(grader.gradePayload(abs, NumericResponse(100.6)).correctness,
          Correctness.incorrect);
      // relative 5%
      final rel = num(const NumericTolerance(kind: ToleranceKind.relative, amount: 0.05));
      expect(grader.gradePayload(rel, NumericResponse(103)).correctness,
          Correctness.correct);
      expect(grader.gradePayload(rel, NumericResponse(106)).correctness,
          Correctness.incorrect);
      // decimals: round to 0 decimals
      final dec = num(const NumericTolerance(kind: ToleranceKind.decimals, amount: 0));
      expect(grader.gradePayload(dec, NumericResponse(100.4)).correctness,
          Correctness.correct);
      expect(grader.gradePayload(dec, NumericResponse(100.6)).correctness,
          Correctness.incorrect);
    });

    test('numeric_multistep: all, partial, none', () {
      final q = NumericMultiStep(
        stem: LocalizedString({'en': 'Compute'}),
        steps: [
          NumericStep(
              id: 's1', prompt: LocalizedString({'en': 'a'}), answer: 10, tolerance: 0.01),
          NumericStep(
              id: 's2', prompt: LocalizedString({'en': 'b'}), answer: 4.5, tolerance: 0.01),
        ],
      );
      expect(
          grader.gradePayload(q, MultiStepResponse({'s1': 10, 's2': 4.5})).correctness,
          Correctness.correct);
      final partial =
          grader.gradePayload(q, MultiStepResponse({'s1': 10, 's2': 9}));
      expect(partial.correctness, Correctness.partial);
      expect(partial.credit, closeTo(0.5, 1e-9));
      expect(
          grader.gradePayload(q, MultiStepResponse({'s1': 1, 's2': 9})).correctness,
          Correctness.incorrect);
    });

    test('passage_ref delegates to inner (wrapped or direct)', () {
      final pr = PassageRef(
        innerType: 'numeric',
        inner: NumericEntry(
          stem: LocalizedString({'en': 'CRR amount?'}),
          answerValue: 4.5,
          tolerance: const NumericTolerance(kind: ToleranceKind.absolute, amount: 0.01),
        ),
      );
      expect(
          grader.gradePayload(pr, PassageResponse(NumericResponse(4.5))).correctness,
          Correctness.correct);
      expect(grader.gradePayload(pr, NumericResponse(4.5)).correctness,
          Correctness.correct);
      expect(grader.gradePayload(pr, NumericResponse(9)).correctness,
          Correctness.incorrect);
    });

    test('mismatched response type throws', () {
      expect(() => grader.grade(mcq('b'), NumericResponse(1)),
          throwsA(isA<ResponseTypeMismatch>()));
    });
  });

  group('marking', () {
    test('JAIIB: no negative marking — wrong scores 0', () {
      const rule = MarkingRule(marks: 1, negativeMarks: 0, allowPartial: false);
      expect(gradeQuestion(mcq('b'), McqResponse('a'), rule).score, 0);
      expect(gradeQuestion(mcq('b'), McqResponse('b'), rule).score, 1);
      expect(gradeQuestion(mcq('b'), null, rule).correctness,
          Correctness.unanswered);
    });

    test('with negative marking — wrong deducts', () {
      const rule = MarkingRule(marks: 1, negativeMarks: 0.25);
      final r = gradeQuestion(mcq('b'), McqResponse('a'), rule);
      expect(r.score, closeTo(-0.25, 1e-9));
      expect(r.correctness, Correctness.incorrect);
    });

    test('all-or-nothing: partial credit not awarded when disallowed', () {
      final raw = const RawGrade(Correctness.partial, 0.5);
      const rule = MarkingRule(marks: 2, negativeMarks: 0, allowPartial: false);
      final r = applyMarking(raw, rule, answered: true);
      expect(r.correctness, Correctness.incorrect);
      expect(r.score, 0);
    });

    test('partial credit awarded pro-rata when allowed', () {
      final raw = const RawGrade(Correctness.partial, 0.5);
      const rule = MarkingRule(marks: 2, negativeMarks: 0, allowPartial: true);
      final r = applyMarking(raw, rule, answered: true);
      expect(r.correctness, Correctness.partial);
      expect(r.score, closeTo(1.0, 1e-9));
    });
  });
}
