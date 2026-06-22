import 'content.dart';
import 'localized.dart';
import 'question.dart';

enum Severity { error, warning }

class ValidationIssue {
  final Severity severity;
  final String path;
  final String message;

  const ValidationIssue(this.severity, this.path, this.message);

  bool get isError => severity == Severity.error;

  @override
  String toString() => '[${severity.name.toUpperCase()}] $path: $message';
}

class ValidationResult {
  final List<ValidationIssue> issues;

  const ValidationResult(this.issues);

  List<ValidationIssue> get errors =>
      issues.where((i) => i.isError).toList(growable: false);
  List<ValidationIssue> get warnings =>
      issues.where((i) => !i.isError).toList(growable: false);

  /// No errors — warnings are allowed. This is the publish gate (epic E1.3):
  /// content may only move to `published` when [publishable] is true.
  bool get publishable => errors.isEmpty;
  bool get isValid => errors.isEmpty;
}

/// Validates content against structural rules and the calm/micro authoring
/// guidelines, and enforces multilingual completeness for [requiredLanguages].
class ContentValidator {
  final List<String> requiredLanguages;

  const ContentValidator({this.requiredLanguages = const ['en']});

  ValidationResult validateQuestion(QuestionBase q) {
    final issues = <ValidationIssue>[];
    final p = 'question:${q.id}';

    if (q.defaultMarks <= 0) {
      issues.add(ValidationIssue(Severity.error, p, 'defaultMarks must be > 0'));
    }
    if (q.defaultNegativeMarks < 0) {
      issues.add(
          ValidationIssue(Severity.error, p, 'defaultNegativeMarks must be >= 0'));
    }
    if (q.difficulty < 1 || q.difficulty > 5) {
      issues.add(ValidationIssue(Severity.warning, p, 'difficulty should be 1..5'));
    }

    _checkLangs(issues, p, 'explanation', q.explanation);

    final expected = _expectedGradingMode(q.payload);
    if (expected != null && q.gradingMode != expected) {
      issues.add(ValidationIssue(
          Severity.warning,
          p,
          'gradingMode "${q.gradingMode.wire}" is unusual for ${q.payload.type} '
          '(expected "${expected.wire}")'));
    }

    if (q.payload is PassageRef &&
        (q.stimulusId == null || q.stimulusId!.isEmpty)) {
      issues.add(ValidationIssue(
          Severity.error, p, 'passage_ref question must reference a stimulusId'));
    }

    _validatePayload(issues, p, q.payload);
    return ValidationResult(issues);
  }

  /// Whether [q] passes the publish gate.
  bool canPublish(QuestionBase q) => validateQuestion(q).publishable;

  ValidationResult validateLesson(Lesson l) {
    final issues = <ValidationIssue>[];
    final p = 'lesson:${l.id}';

    _checkLangs(issues, p, 'title', l.title);

    if (l.cards.isEmpty) {
      issues.add(ValidationIssue(Severity.error, p, 'lesson has no cards'));
    } else if (l.cards.length < 4 || l.cards.length > 6) {
      issues.add(ValidationIssue(Severity.warning, p,
          'lesson should have 4-6 cards (has ${l.cards.length})'));
    }

    if (l.probeQuestionIds.isEmpty) {
      issues.add(ValidationIssue(Severity.error, p, 'lesson has no probe questions'));
    }
    if (l.estMinutes > 6) {
      issues.add(ValidationIssue(Severity.warning, p,
          'lesson est ${l.estMinutes} min exceeds the ~5 min calm target'));
    }

    final cardIds = l.cards.map((c) => c.id).toList();
    if (cardIds.toSet().length != cardIds.length) {
      issues.add(ValidationIssue(Severity.error, p, 'duplicate card ids'));
    }

    // Calm/micro rule: concept cards should be visual-first.
    for (final c in l.cards.where((c) => c.kind == CardKind.concept)) {
      final hasVisual = c.blocks.any((b) => b is! TextBlock);
      if (!hasVisual) {
        issues.add(ValidationIssue(Severity.warning, p,
            'concept card "${c.id}" is text-only (prefer a visual block)'));
      }
    }

    return ValidationResult(issues);
  }

  GradingMode? _expectedGradingMode(QuestionPayload pl) => switch (pl) {
        McqSingle() || TrueFalse() || MatchPairs() => GradingMode.autoExact,
        NumericEntry() || NumericMultiStep() => GradingMode.autoNumeric,
        PassageRef(:final inner) => _expectedGradingMode(inner),
      };

  void _validatePayload(
      List<ValidationIssue> issues, String p, QuestionPayload pl) {
    switch (pl) {
      case McqSingle(:final stem, :final options, :final correctOptionId):
        _checkLangs(issues, p, 'stem', stem);
        if (options.length < 2) {
          issues.add(
              ValidationIssue(Severity.error, p, 'mcq_single needs >= 2 options'));
        }
        final ids = options.map((o) => o.id).toList();
        if (ids.toSet().length != ids.length) {
          issues.add(ValidationIssue(
              Severity.error, p, 'mcq_single option ids must be unique'));
        }
        if (!ids.contains(correctOptionId)) {
          issues.add(ValidationIssue(Severity.error, p,
              'correctOptionId "$correctOptionId" is not among the options'));
        }
        for (final o in options) {
          _checkLangs(issues, p, 'option:${o.id}', o.content);
        }
      case TrueFalse(:final stem):
        _checkLangs(issues, p, 'stem', stem);
      case MatchPairs(:final stem, :final left, :final right, :final correct):
        _checkLangs(issues, p, 'stem', stem);
        if (left.isEmpty || right.isEmpty) {
          issues.add(ValidationIssue(
              Severity.error, p, 'match_pairs needs left and right items'));
        }
        final leftIds = left.map((o) => o.id).toSet();
        final rightIds = right.map((o) => o.id).toSet();
        correct.forEach((l, r) {
          if (!leftIds.contains(l)) {
            issues.add(ValidationIssue(Severity.error, p,
                'match_pairs mapping references unknown left "$l"'));
          }
          if (!rightIds.contains(r)) {
            issues.add(ValidationIssue(Severity.error, p,
                'match_pairs mapping references unknown right "$r"'));
          }
        });
        for (final l in leftIds) {
          if (!correct.containsKey(l)) {
            issues.add(ValidationIssue(
                Severity.warning, p, 'match_pairs left "$l" has no mapping'));
          }
        }
      case NumericEntry(:final stem, :final tolerance):
        _checkLangs(issues, p, 'stem', stem);
        if (tolerance.amount < 0) {
          issues.add(ValidationIssue(
              Severity.error, p, 'numeric tolerance.amount must be >= 0'));
        }
      case NumericMultiStep(:final stem, :final steps):
        _checkLangs(issues, p, 'stem', stem);
        if (steps.isEmpty) {
          issues.add(ValidationIssue(
              Severity.error, p, 'numeric_multistep needs >= 1 step'));
        }
        for (final s in steps) {
          _checkLangs(issues, p, 'step:${s.id}', s.prompt);
          if (s.tolerance < 0) {
            issues.add(ValidationIssue(
                Severity.error, p, 'step "${s.id}" tolerance must be >= 0'));
          }
        }
      case PassageRef(:final inner):
        _validatePayload(issues, p, inner);
    }
  }

  void _checkLangs(
      List<ValidationIssue> issues, String p, String field, LocalizedString s) {
    if (s.isEmpty) {
      issues.add(ValidationIssue(Severity.error, p, '$field is empty'));
      return;
    }
    for (final lang in requiredLanguages) {
      if (!s.hasLanguage(lang)) {
        issues.add(ValidationIssue(
            Severity.error, p, '$field is missing language "$lang"'));
      }
    }
  }
}
