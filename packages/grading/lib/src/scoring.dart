import 'package:domain/domain.dart';

/// A component (subject/paper) score, used to evaluate the exam pass rule.
class ComponentScore {
  final String code;
  final double scored;
  final double max;

  const ComponentScore({
    required this.code,
    required this.scored,
    required this.max,
  });

  double get percent => max > 0 ? scored / max * 100 : 0;
}

class PassOutcome {
  final bool passed;
  final String reason;
  final double aggregatePercent;

  const PassOutcome({
    required this.passed,
    required this.reason,
    required this.aggregatePercent,
  });
}

/// Evaluates an exam [PassRule] against per-component scores (epic E2.3).
///
/// Handles JAIIB's two-path rule: pass if **every** component meets
/// `perComponentMin`, OR (alternative) every component meets a lower bar
/// (e.g. 45%) AND the aggregate meets `aggregateMin` (e.g. 50%).
PassOutcome evaluatePass(List<ComponentScore> components, PassRule rule) {
  final totalScored = components.fold<double>(0, (a, c) => a + c.scored);
  final totalMax = components.fold<double>(0, (a, c) => a + c.max);
  final aggregate = totalMax > 0 ? totalScored / totalMax * 100 : 0.0;

  final path1 = rule.perComponentMin == null
      ? true
      : components.every((c) => c.percent >= rule.perComponentMin!);

  var path2 = false;
  final alt = rule.alternativeAggregate;
  if (alt != null) {
    path2 = components.every((c) => c.percent >= alt.perComponentMin) &&
        aggregate >= alt.aggregateMin;
  }

  var passed = path1 || path2;
  if (rule.overallMin != null && aggregate < rule.overallMin!) {
    passed = false;
  }

  final String reason;
  if (passed && path1) {
    reason = rule.perComponentMin == null
        ? 'No per-component minimum'
        : 'Each component met ${_fmt(rule.perComponentMin!)}%';
  } else if (passed && path2) {
    reason = 'Aggregate path: each component >= '
        '${_fmt(alt!.perComponentMin)}% and aggregate '
        '${_fmt(aggregate)}% >= ${_fmt(alt.aggregateMin)}%';
  } else {
    reason = 'Did not meet per-component or aggregate thresholds';
  }

  return PassOutcome(
    passed: passed,
    reason: reason,
    aggregatePercent: aggregate,
  );
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
