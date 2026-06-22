import 'package:domain/domain.dart';

import 'grade_result.dart';
import 'grader.dart';
import 'response.dart';

/// The marks/negative-marks/partial-credit rule applied to one question,
/// derived from a [SectionConfig] + the exam's [GradingProfile] (epic E2.3).
class MarkingRule {
  final double marks;
  final double negativeMarks;
  final bool allowPartial;

  const MarkingRule({
    required this.marks,
    this.negativeMarks = 0,
    this.allowPartial = false,
  });

  factory MarkingRule.fromSection(
    SectionConfig section, {
    bool allowPartial = false,
  }) =>
      MarkingRule(
        marks: section.marksPerQuestion,
        negativeMarks: section.negativeMarks,
        allowPartial: allowPartial,
      );
}

/// Applies exam marking to a [RawGrade]. Unanswered scores 0 (never negative);
/// correct scores full marks; partial scores pro-rata only when allowed,
/// otherwise it is treated as incorrect; incorrect deducts negative marks.
GradeResult applyMarking(
  RawGrade g,
  MarkingRule rule, {
  required bool answered,
}) {
  if (!answered || g.correctness == Correctness.unanswered) {
    return GradeResult(
      score: 0,
      maxScore: rule.marks,
      correctness: Correctness.unanswered,
      perPart: g.perPart,
    );
  }
  if (g.correctness == Correctness.pending) {
    return GradeResult(
      score: 0,
      maxScore: rule.marks,
      correctness: Correctness.pending,
      perPart: g.perPart,
    );
  }
  if (g.credit >= 1.0) {
    return GradeResult(
      score: rule.marks,
      maxScore: rule.marks,
      correctness: Correctness.correct,
      perPart: g.perPart,
    );
  }
  if (g.credit > 0 && rule.allowPartial) {
    return GradeResult(
      score: rule.marks * g.credit,
      maxScore: rule.marks,
      correctness: Correctness.partial,
      perPart: g.perPart,
    );
  }
  // Wrong, or partial credit not allowed for this exam (IIBF = all-or-nothing).
  return GradeResult(
    score: -rule.negativeMarks,
    maxScore: rule.marks,
    correctness: Correctness.incorrect,
    perPart: g.perPart,
  );
}

/// Grade a single question end to end: auto-grade, then apply marking.
GradeResult gradeQuestion(
  QuestionBase question,
  Response? response,
  MarkingRule rule, {
  Grader grader = const Grader(),
}) {
  final raw = grader.grade(question, response);
  return applyMarking(raw, rule, answered: response != null);
}
