import 'dart:math' as math;

import 'scheduler.dart';
import 'srs_state.dart';

/// FSRS (Free Spaced Repetition Scheduler) — the default scheduler (epic E3.1).
///
/// Implements the FSRS-4.5 memory model: a forgetting curve parameterised by
/// stability `S` and difficulty `D`, with stability updated differently on
/// recall vs. lapse. Ships with published default weights; per-user weight
/// optimisation is a later enhancement (technical-spec §15.1). Behaviour is
/// validated by invariant tests (interval ordering and growth, lapse reset).
class Fsrs implements Scheduler {
  /// FSRS-4.5 default weights (w0..w16).
  static const List<double> defaultWeights = [
    0.4872, 1.4003, 3.7145, 13.8206, 5.1618, 1.2298, 0.8975, 0.0310,
    1.6474, 0.1367, 1.0461, 2.1072, 0.0793, 0.3246, 1.5870, 0.2272, 2.8755,
  ];

  final List<double> w;
  final double requestRetention;
  final double maximumIntervalDays;

  const Fsrs({
    this.w = defaultWeights,
    this.requestRetention = 0.9,
    this.maximumIntervalDays = 36500,
  });

  static const double _decay = -0.5;
  static const double _factor = 19.0 / 81.0; // so R(S, S) == 0.9
  static const double _minIntervalDays = 1.0 / 24; // 1 hour
  static const double _minStability = 0.1;

  @override
  SrsState init(DateTime now, Rating rating) {
    final g = rating.grade;
    final s = math.max(_minStability, w[g - 1]);
    final d = _initDifficulty(g);
    return SrsState(
      stability: s,
      difficulty: d,
      lastReview: now,
      due: _due(now, _interval(s)),
      reps: 1,
      lapses: rating == Rating.again ? 1 : 0,
      phase: rating == Rating.again ? SrsPhase.relearning : SrsPhase.review,
    );
  }

  @override
  SrsState review(SrsState state, Rating rating, DateTime now) {
    final elapsedDays =
        math.max(0.0, now.difference(state.lastReview).inSeconds / 86400.0);
    final r = _retrievability(elapsedDays, state.stability);
    final g = rating.grade;
    final newD = _nextDifficulty(state.difficulty, g);

    final double newS;
    final SrsPhase phase;
    var lapses = state.lapses;
    if (rating == Rating.again) {
      newS = math.max(
          _minStability, _stabilityAfterLapse(state.difficulty, state.stability, r));
      phase = SrsPhase.relearning;
      lapses += 1;
    } else {
      newS = math.max(_minStability,
          _stabilityAfterRecall(state.difficulty, state.stability, r, g));
      phase = SrsPhase.review;
    }

    return state.copyWith(
      stability: newS,
      difficulty: newD,
      lastReview: now,
      due: _due(now, _interval(newS)),
      reps: state.reps + 1,
      lapses: lapses,
      phase: phase,
    );
  }

  // --- FSRS internals ---

  double _retrievability(double elapsedDays, double stability) =>
      math.pow(1 + _factor * elapsedDays / stability, _decay).toDouble();

  double _interval(double stability) {
    final ivl = stability /
        _factor *
        (math.pow(requestRetention, 1 / _decay).toDouble() - 1);
    return ivl.clamp(_minIntervalDays, maximumIntervalDays);
  }

  double _initDifficulty(int g) => (w[4] - (g - 3) * w[5]).clamp(1.0, 10.0);

  double _nextDifficulty(double d, int g) {
    final delta = d - w[6] * (g - 3);
    final reverted = w[7] * _initDifficulty(4) + (1 - w[7]) * delta;
    return reverted.clamp(1.0, 10.0);
  }

  double _stabilityAfterRecall(double d, double s, double r, int g) {
    final hardPenalty = g == Rating.hard.grade ? w[15] : 1.0;
    final easyBonus = g == Rating.easy.grade ? w[16] : 1.0;
    final inc = math.exp(w[8]) *
        (11 - d) *
        math.pow(s, -w[9]).toDouble() *
        (math.exp(w[10] * (1 - r)) - 1) *
        hardPenalty *
        easyBonus;
    return s * (1 + inc);
  }

  double _stabilityAfterLapse(double d, double s, double r) =>
      w[11] *
      math.pow(d, -w[12]).toDouble() *
      (math.pow(s + 1, w[13]).toDouble() - 1) *
      math.exp(w[14] * (1 - r));

  DateTime _due(DateTime now, double intervalDays) =>
      now.add(Duration(minutes: (intervalDays * 1440).round()));
}
