import 'package:srs/srs.dart';
import 'package:test/test.dart';

void main() {
  group('DeadlineAwareScheduler Clamping & Modes', () {
    const fsrs = Fsrs();
    final now = DateTime.utc(2026, 6, 23, 10, 0, 0);

    test('Retention Mode (>8 weeks) should preserve FSRS intervals and clamp to examDate', () {
      // Exam in 60 days (8.5 weeks)
      final examDate = now.add(const Duration(days: 60));
      final scheduler = DeadlineAwareScheduler(delegate: fsrs, examDate: examDate);

      // Normal first review of a brand-new item (Rating.good)
      final state = scheduler.init(now, Rating.good);

      // In retention mode, the interval shouldn't be compressed.
      // Base stability for Good is 3.7145, resulting interval is ~3.7 days
      final intervalDays = state.due.difference(now).inSeconds / 86400.0;
      expect(intervalDays, closeTo(3.7, 0.5));
      expect(state.due.isAfter(examDate), isFalse);

      // Force a huge interval by setting stability high and reviewing
      final highStabilityState = SrsState(
        stability: 100.0, // base FSRS would schedule ~100 days out
        difficulty: 3.0,
        due: now,
        lastReview: now.subtract(const Duration(days: 10)),
        reps: 5,
      );

      final reviewedState = scheduler.review(highStabilityState, Rating.good, now);
      // It should be strictly clamped to examDate (60 days from now)
      expect(reviewedState.due, equals(examDate));
    });

    test('Consolidation Mode (2-8 weeks) should compress intervals for weak items', () {
      // Exam in 30 days (~4.2 weeks)
      final examDate = now.add(const Duration(days: 30));
      final scheduler = DeadlineAwareScheduler(delegate: fsrs, examDate: examDate);

      // 1. Non-weak item (Rating.easy, low difficulty) -> should not compress (base interval ~13.8 days)
      final nonWeakState = scheduler.init(now, Rating.easy);
      final nonWeakInterval = nonWeakState.due.difference(now).inSeconds / 86400.0;
      expect(nonWeakInterval, closeTo(13.8, 0.5));

      // 2. Weak item (Rating.again) -> should compress interval to <= remainingDays / 2 (i.e. <= 15 days)
      final weakState = scheduler.init(now, Rating.again);
      final weakInterval = weakState.due.difference(now).inSeconds / 86400.0;
      // Base interval for Again is ~0.48 days, which is already < 15 days, so it remains ~0.48 days.
      expect(weakInterval, closeTo(0.48, 0.1));

      // 3. High stability but weak item (difficulty > 5, lapses > 0) -> interval should be compressed to 15 days
      final highStabilityWeakState = SrsState(
        stability: 80.0, // base FSRS would schedule >80 days
        difficulty: 6.0, // weak because difficulty > 5
        due: now,
        lastReview: now.subtract(const Duration(days: 10)),
        reps: 5,
        lapses: 1,
      );

      final reviewedWeak = scheduler.review(highStabilityWeakState, Rating.good, now);
      final reviewedInterval = reviewedWeak.due.difference(now).inSeconds / 86400.0;
      // Remaining days is 30, so compressed interval limit is 15.0 days.
      expect(reviewedInterval, closeTo(15.0, 0.1));
    });

    test('Cram Mode (<2 weeks) should compress all intervals to at most 1 day', () {
      // Exam in 10 days (1.4 weeks)
      final examDate = now.add(const Duration(days: 10));
      final scheduler = DeadlineAwareScheduler(delegate: fsrs, examDate: examDate);

      // Even for Rating.easy (which normally has a 13.8-day interval), it should be compressed to <= 1.0 day
      final state = scheduler.init(now, Rating.easy);
      final interval = state.due.difference(now).inSeconds / 86400.0;
      expect(interval, closeTo(1.0, 0.01));
      expect(state.due.isAfter(examDate), isFalse);
    });

    test('Exam date is today or passed -> clamp to examDate and keep at least 1 hour or remaining time', () {
      final examDate = now.add(const Duration(minutes: 30)); // 30 minutes from now
      final scheduler = DeadlineAwareScheduler(delegate: fsrs, examDate: examDate);

      final state = scheduler.init(now, Rating.good);
      expect(state.due, equals(examDate));
    });
  });
}
