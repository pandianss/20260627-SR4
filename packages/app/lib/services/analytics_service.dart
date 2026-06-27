import 'package:store/store.dart';

class UserAnalytics {
  final int dau;
  final int mau;
  final int currentStreak;
  final int longestStreak;
  final double d1Retention; // 0.0 or 1.0
  final double d7Retention; // 0.0 or 1.0
  final int completedLessonsCount;
  final double completionRate;
  final double averageMockScore;
  final int mockAttemptsCount;
  final double mockPassRate;

  const UserAnalytics({
    required this.dau,
    required this.mau,
    required this.currentStreak,
    required this.longestStreak,
    required this.d1Retention,
    required this.d7Retention,
    required this.completedLessonsCount,
    required this.completionRate,
    required this.averageMockScore,
    required this.mockAttemptsCount,
    required this.mockPassRate,
  });
}

class AnalyticsService {
  final EventLogStore eventStore;
  final ContentStore contentStore;

  AnalyticsService({
    required this.eventStore,
    required this.contentStore,
  });

  /// [now] overrides the reference "today" used for the streak calculation
  /// (defaults to the wall clock) — pass it for deterministic tests.
  Future<UserAnalytics> calculateAnalytics(String userId, {DateTime? now}) async {
    final events = await eventStore.getAllEvents(userId);
    if (events.isEmpty) {
      return const UserAnalytics(
        dau: 0,
        mau: 0,
        currentStreak: 0,
        longestStreak: 0,
        d1Retention: 0,
        d7Retention: 0,
        completedLessonsCount: 0,
        completionRate: 0,
        averageMockScore: 0,
        mockAttemptsCount: 0,
        mockPassRate: 0,
      );
    }

    // Sort events by timestamp
    final sorted = List<SrsEvent>.from(events)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Get unique days and months (local date formatting)
    final Set<String> activeDays = {};
    final Set<String> activeMonths = {};
    for (final e in sorted) {
      final dateStr = "${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}";
      final monthStr = "${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}";
      activeDays.add(dateStr);
      activeMonths.add(monthStr);
    }

    final dau = activeDays.length;
    final mau = activeMonths.length;

    // Calculate Streak
    final List<DateTime> uniqueDates = activeDays.map((d) => DateTime.parse(d)).toList()..sort();
    int currentStreak = 0;
    int longestStreak = 0;
    
    if (uniqueDates.isNotEmpty) {
      final today = now ?? DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      final lastActiveDate = uniqueDates.last;
      bool isStreakActive = lastActiveDate == todayDate || lastActiveDate == yesterdayDate;

      if (isStreakActive) {
        currentStreak = 1;
        for (int i = uniqueDates.length - 1; i > 0; i--) {
          final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
          if (diff == 1) {
            currentStreak++;
          } else if (diff > 1) {
            break;
          }
        }
      }

      // Calculate longest streak
      int tempStreak = 1;
      longestStreak = 1;
      for (int i = 1; i < uniqueDates.length; i++) {
        final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }

    // Calculate D1 / D7 Retention relative to first active date
    double d1Retention = 0.0;
    double d7Retention = 0.0;
    if (uniqueDates.isNotEmpty) {
      final firstDate = uniqueDates.first;
      for (final date in uniqueDates) {
        final diff = date.difference(firstDate).inDays;
        if (diff == 1) d1Retention = 1.0;
        if (diff == 7) d7Retention = 1.0;
      }
    }

    // Lesson Completions
    final completedLessons = sorted
        .whereType<LessonViewedEvent>()
        .map((e) => e.lessonId)
        .toSet();
    final completedCount = completedLessons.length;

    // Total lessons in content store (query modules)
    int totalLessons = 0;
    try {
      final exam = await contentStore.getExamByCode('JAIIB');
      if (exam != null) {
        for (final pid in exam.paperIds) {
          final paper = await contentStore.getPaper(pid);
          if (paper != null) {
            for (final mid in paper.moduleIds) {
              final mod = await contentStore.getModule(mid);
              if (mod != null) {
                totalLessons += mod.lessonIds.length;
              }
            }
          }
        }
      }
    } catch (_) {}
    if (totalLessons == 0) totalLessons = 2; // fallback to our 2 seeded lessons

    final completionRate = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;

    // Mock Attempts
    final mockSubmissions = sorted.whereType<MockSubmittedEvent>().toList();
    final mockAttemptsCount = mockSubmissions.length;
    double totalMockScorePercent = 0.0;
    int mockPassCount = 0;

    for (final mock in mockSubmissions) {
      if (mock.maxScore > 0) {
        totalMockScorePercent += (mock.score / mock.maxScore);
      }
      if (mock.passed) {
        mockPassCount++;
      }
    }

    final averageMockScore = mockAttemptsCount > 0 ? (totalMockScorePercent / mockAttemptsCount) : 0.0;
    final mockPassRate = mockAttemptsCount > 0 ? (mockPassCount / mockAttemptsCount) : 0.0;

    return UserAnalytics(
      dau: dau,
      mau: mau,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      d1Retention: d1Retention,
      d7Retention: d7Retention,
      completedLessonsCount: completedCount,
      completionRate: completionRate,
      averageMockScore: averageMockScore,
      mockAttemptsCount: mockAttemptsCount,
      mockPassRate: mockPassRate,
    );
  }
}
