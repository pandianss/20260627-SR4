import 'dart:math' as math;

import 'scheduler.dart';
import 'srs_state.dart';

enum ExamScheduleMode { retention, consolidation, cram }

/// Decorator for a [Scheduler] that clamps and compresses intervals based on the
/// proximity of the learner's exam date (epic E3.3).
class DeadlineAwareScheduler implements Scheduler {
  final Scheduler delegate;
  final DateTime examDate;

  const DeadlineAwareScheduler({
    required this.delegate,
    required this.examDate,
  });

  /// Evaluates the scheduling mode based on the remaining days until the exam.
  ExamScheduleMode getMode(DateTime now) {
    final remainingDays = examDate.difference(now).inSeconds / 86400.0;
    if (remainingDays > 56) {
      return ExamScheduleMode.retention;
    } else if (remainingDays > 14) {
      return ExamScheduleMode.consolidation;
    } else {
      return ExamScheduleMode.cram;
    }
  }

  /// Weakness classification to trigger consolidation compression.
  bool isWeak(SrsState state, Rating rating) {
    return state.difficulty > 5.0 ||
        state.lapses > 0 ||
        state.stability < 14.0 ||
        rating == Rating.again ||
        rating == Rating.hard ||
        state.isHighPriority;
  }

  @override
  SrsState init(DateTime now, Rating rating) {
    final baseState = delegate.init(now, rating);
    return _applyClamping(baseState, rating, now);
  }

  @override
  SrsState review(SrsState state, Rating rating, DateTime now) {
    final baseState = delegate.review(state, rating, now);
    return _applyClamping(baseState, rating, now);
  }

  SrsState _applyClamping(SrsState state, Rating rating, DateTime now) {
    final remainingSeconds = examDate.difference(now).inSeconds;
    final remainingDays = math.max(0.0, remainingSeconds / 86400.0);

    final baseIntervalDays =
        state.due.difference(state.lastReview).inSeconds / 86400.0;
    double newIntervalDays = baseIntervalDays;

    final mode = getMode(now);

    if (mode == ExamScheduleMode.consolidation) {
      if (isWeak(state, rating)) {
        // Compress interval so the item is seen at least twice before the exam.
        final targetMaxInterval = remainingDays / 2.0;
        newIntervalDays = math.min(newIntervalDays, targetMaxInterval);
      }
    } else if (mode == ExamScheduleMode.cram) {
      // Prioritize full syllabus review; compress all intervals to at most 1 day.
      newIntervalDays = math.min(newIntervalDays, 1.0);
    }

    // Never schedule past the exam date.
    newIntervalDays = math.min(newIntervalDays, remainingDays);

    // Keep FSRS minimum of 1 hour unless remaining time is shorter.
    final minInterval = math.min(1.0 / 24.0, remainingDays);
    newIntervalDays = math.max(minInterval, newIntervalDays);

    final newDue = state.lastReview
        .add(Duration(seconds: (newIntervalDays * 86400.0).round()));

    // Strict ceiling at the exam date.
    final finalDue = newDue.isAfter(examDate) ? examDate : newDue;

    return state.copyWith(due: finalDue);
  }
}
