import 'dart:math';

import 'package:domain/domain.dart';

import 'grade_result.dart';
import 'response.dart';

/// Thrown when a [Response] doesn't match the question payload it's graded
/// against — a programming error (the UI built the wrong response type).
class ResponseTypeMismatch implements Exception {
  final String message;
  ResponseTypeMismatch(this.message);
  @override
  String toString() => 'ResponseTypeMismatch: $message';
}

/// Deterministic auto-grader for the objective question types (epic E2.1/E2.2).
/// Runs identically on-device (instant feedback) and on the server
/// (authoritative). Produces a [RawGrade]; exam marking is applied separately.
class Grader {
  const Grader();

  RawGrade grade(QuestionBase question, Response? response) {
    if (response == null) return RawGrade.unanswered;
    return gradePayload(question.payload, response);
  }

  RawGrade gradePayload(QuestionPayload payload, Response response) {
    switch (payload) {
      case McqSingle(:final correctOptionId):
        final r = _expect<McqResponse>(response, payload.type);
        return r.optionId == correctOptionId
            ? RawGrade.correct
            : RawGrade.incorrect;

      case TrueFalse(:final answer):
        final r = _expect<TrueFalseResponse>(response, payload.type);
        return r.value == answer ? RawGrade.correct : RawGrade.incorrect;

      case MatchPairs(:final correct, :final partialCredit):
        final r = _expect<MatchResponse>(response, payload.type);
        final perPart = <String, double>{};
        var right = 0;
        correct.forEach((left, expectedRight) {
          final ok = r.mapping[left] == expectedRight;
          perPart[left] = ok ? 1 : 0;
          if (ok) right++;
        });
        final total = correct.length;
        if (total > 0 && right == total) {
          return RawGrade(Correctness.correct, 1, perPart);
        }
        if (right > 0 && partialCredit == PartialCredit.perPair) {
          return RawGrade(Correctness.partial, right / total, perPart);
        }
        return RawGrade(Correctness.incorrect, 0, perPart);

      case NumericEntry(:final answerValue, :final tolerance):
        final r = _expect<NumericResponse>(response, payload.type);
        return withinTolerance(r.value, answerValue, tolerance)
            ? RawGrade.correct
            : RawGrade.incorrect;

      case NumericMultiStep(:final steps):
        final r = _expect<MultiStepResponse>(response, payload.type);
        final perPart = <String, double>{};
        var ok = 0;
        for (final s in steps) {
          final v = r.steps[s.id];
          final good = v != null && (v - s.answer).abs() <= s.tolerance + _eps;
          perPart[s.id] = good ? 1 : 0;
          if (good) ok++;
        }
        if (steps.isNotEmpty && ok == steps.length) {
          return RawGrade(Correctness.correct, 1, perPart);
        }
        if (ok > 0) {
          return RawGrade(Correctness.partial, ok / steps.length, perPart);
        }
        return RawGrade(Correctness.incorrect, 0, perPart);

      case PassageRef(:final inner):
        // Accept either a wrapped PassageResponse or the inner response directly.
        final Response target =
            response is PassageResponse ? response.inner : response;
        return gradePayload(inner, target);
    }
  }

  /// Whether [given] is within [tolerance] of [expected].
  bool withinTolerance(double given, double expected, NumericTolerance t) {
    switch (t.kind) {
      case ToleranceKind.absolute:
        return (given - expected).abs() <= t.amount + _eps;
      case ToleranceKind.relative:
        return (given - expected).abs() <= expected.abs() * t.amount + _eps;
      case ToleranceKind.decimals:
        final f = pow(10, t.amount.toInt()).toDouble();
        return (given * f).round() == (expected * f).round();
    }
  }

  T _expect<T extends Response>(Response r, String forType) {
    if (r is T) return r;
    throw ResponseTypeMismatch(
        'Expected a response for "$forType" but got "${r.type}"');
  }

  static const _eps = 1e-9;
}
