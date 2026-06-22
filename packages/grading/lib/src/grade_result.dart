enum Correctness { correct, partial, incorrect, pending, unanswered }

/// The format-agnostic outcome of grading, before exam marking is applied.
/// [credit] is the fraction correct in `[0, 1]` (1 = fully correct).
class RawGrade {
  final Correctness correctness;
  final double credit;
  final Map<String, double>? perPart;

  const RawGrade(this.correctness, this.credit, [this.perPart]);

  static const correct = RawGrade(Correctness.correct, 1.0);
  static const incorrect = RawGrade(Correctness.incorrect, 0.0);
  static const unanswered = RawGrade(Correctness.unanswered, 0.0);
}

/// The graded outcome after exam marking (marks / negative marks) is applied.
class GradeResult {
  final double score; // marks awarded; may be negative if negative marking
  final double maxScore;
  final Correctness correctness;
  final Map<String, double>? perPart;

  const GradeResult({
    required this.score,
    required this.maxScore,
    required this.correctness,
    this.perPart,
  });

  bool get isCorrect => correctness == Correctness.correct;

  Map<String, dynamic> toJson() => {
        'score': score,
        'maxScore': maxScore,
        'correctness': correctness.name,
        if (perPart != null) 'perPart': perPart,
      };
}
