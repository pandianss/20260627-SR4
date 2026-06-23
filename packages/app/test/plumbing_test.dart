import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/screens/onboarding_screen.dart';
import 'package:app/services/analytics_service.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/theme/tokens.dart';
import 'package:store/store.dart';
import 'package:domain/domain.dart';

void main() {
  group('Onboarding Authentication (E9.1) Tests', () {
    testWidgets('Validation errors for empty or invalid email/password', (tester) async {
      bool onCompleteCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: OnboardingScreen(
            onComplete: (date, email, token, examCode) {
              onCompleteCalled = true;
            },
          ),
        ),
      );

      // Start preparation page
      expect(find.text('Start Preparation'), findsOneWidget);
      await tester.tap(find.text('Start Preparation'));
      await tester.pumpAndSettle();

      // Screen 1: Create your account
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next with empty email and password
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);

      // Enter invalid email (no @)
      await tester.enterText(find.byType(TextField).first, 'invalidemail');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);

      // Enter valid email but password < 6 characters
      await tester.enterText(find.byType(TextField).first, 'test@bank.com');
      await tester.enterText(find.byType(TextField).last, '12345');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Password must be at least 6 characters.'), findsOneWidget);

      // Enter valid email and password >= 6 characters
      await tester.enterText(find.byType(TextField).last, '123456');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should advance to next step (Choose your exam)
      expect(find.text('Please enter a valid email address.'), findsNothing);
      expect(find.text('Password must be at least 6 characters.'), findsNothing);
      expect(find.text('Choose your exam'), findsOneWidget);
      expect(onCompleteCalled, isFalse);
    });

    testWidgets('Successful onboarding emits correct user data and mock token', (tester) async {
      DateTime? completedDate;
      String? completedEmail;
      String? completedToken;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: OnboardingScreen(
            onComplete: (date, email, token, examCode) {
              completedDate = date;
              completedEmail = email;
              completedToken = token;
            },
          ),
        ),
      );

      // Welcome Screen
      await tester.tap(find.text('Start Preparation'));
      await tester.pumpAndSettle();

      // Create Account Screen
      await tester.enterText(find.byType(TextField).first, 'developer@sbi.co.in');
      await tester.enterText(find.byType(TextField).last, 'pass123');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Choose Exam Screen
      expect(find.text('Choose your exam'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Set Exam Date Screen
      expect(find.text('Set your exam date'), findsOneWidget);
      await tester.tap(find.text('Begin Studying'));
      await tester.pumpAndSettle();

      expect(completedEmail, equals('developer@sbi.co.in'));
      expect(completedToken, startsWith('JWT_dummy_token_'));
      expect(completedDate, isNotNull);
    });
  });

  group('Analytics Service (E9.2) Tests', () {
    late MemoryContentStore contentStore;
    late MemoryEventLogStore eventStore;
    late AnalyticsService analyticsService;
    const String userId = 'user_analytics_test';

    setUp(() async {
      contentStore = MemoryContentStore();
      eventStore = MemoryEventLogStore();
      analyticsService = AnalyticsService(
        contentStore: contentStore,
        eventStore: eventStore,
      );

      // Seed mock content pack data for calculateAnalytics lesson count checks
      final exam = const Exam(
        id: 'ex_ppb',
        code: 'JAIIB',
        name: 'JAIIB Exam',
        body: 'IIBF',
        paperIds: ['p_ppb'],
      );
      await contentStore.saveExam(exam);

      final paper = const Paper(
        id: 'p_ppb',
        examCode: 'JAIIB',
        name: LocalizedString({'en': 'Principles & Practices of Banking'}),
        moduleIds: ['m_ppb_a'],
      );
      await contentStore.savePaper(paper);

      final module = const Module(
        id: 'm_ppb_a',
        paperId: 'p_ppb',
        name: LocalizedString({'en': 'Module A'}),
        topicTags: ['tag1'],
        lessonIds: ['lesson1', 'lesson2'],
      );
      await contentStore.saveModule(module);
    });

    test('Empty store returns zero stats', () async {
      final stats = await analyticsService.calculateAnalytics(userId);
      expect(stats.dau, 0);
      expect(stats.mau, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.d1Retention, 0.0);
      expect(stats.d7Retention, 0.0);
      expect(stats.completedLessonsCount, 0);
      expect(stats.completionRate, 0.0);
      expect(stats.averageMockScore, 0.0);
      expect(stats.mockAttemptsCount, 0);
    });

    test('Records lesson views, calculates DAU/MAU and lesson completion rates', () async {
      final now = DateTime.now();
      // Add a lesson viewed event today
      await eventStore.appendEvent(LessonViewedEvent(
        clientUlid: 'ulid_1',
        userId: userId,
        timestamp: now,
        examContext: 'JAIIB',
        lessonId: 'lesson1',
      ));

      var stats = await analyticsService.calculateAnalytics(userId);
      expect(stats.dau, 1);
      expect(stats.mau, 1);
      expect(stats.completedLessonsCount, 1);
      // 1 out of 2 lessons seeded
      expect(stats.completionRate, 0.5);

      // Add a second event for same lesson on same day - DAU/MAU & count should not double count
      await eventStore.appendEvent(LessonViewedEvent(
        clientUlid: 'ulid_2',
        userId: userId,
        timestamp: now.add(const Duration(minutes: 5)),
        examContext: 'JAIIB',
        lessonId: 'lesson1',
      ));

      stats = await analyticsService.calculateAnalytics(userId);
      expect(stats.dau, 1);
      expect(stats.completedLessonsCount, 1);

      // Add a different lesson viewed event on another day (yesterday)
      await eventStore.appendEvent(LessonViewedEvent(
        clientUlid: 'ulid_3',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 1)),
        examContext: 'JAIIB',
        lessonId: 'lesson2',
      ));

      stats = await analyticsService.calculateAnalytics(userId);
      expect(stats.dau, 2);
      expect(stats.completedLessonsCount, 2);
      expect(stats.completionRate, 1.0);
    });

    test('Calculates D1/D7 Retention', () async {
      final baseDate = DateTime(2026, 6, 1);

      // Day 0
      await eventStore.appendEvent(LessonViewedEvent(
        clientUlid: 'u0',
        userId: userId,
        timestamp: baseDate,
        examContext: 'JAIIB',
        lessonId: 'lesson1',
      ));

      // Day 1
      await eventStore.appendEvent(LessonViewedEvent(
        clientUlid: 'u1',
        userId: userId,
        timestamp: baseDate.add(const Duration(days: 1)),
        examContext: 'JAIIB',
        lessonId: 'lesson1',
      ));

      // Day 7
      await eventStore.appendEvent(LessonViewedEvent(
        clientUlid: 'u7',
        userId: userId,
        timestamp: baseDate.add(const Duration(days: 7)),
        examContext: 'JAIIB',
        lessonId: 'lesson2',
      ));

      final stats = await analyticsService.calculateAnalytics(userId);
      expect(stats.d1Retention, 1.0);
      expect(stats.d7Retention, 1.0);
    });

    test('Calculates mock metrics correctly', () async {
      final now = DateTime.now();
      // First mock: score 60/100, pass
      await eventStore.appendEvent(MockSubmittedEvent(
        clientUlid: 'm1',
        userId: userId,
        timestamp: now,
        examContext: 'JAIIB',
        mockResultId: 'res1',
        paperId: 'p_ppb',
        score: 60.0,
        maxScore: 100.0,
        passed: true,
        answers: [],
      ));

      // Second mock: score 40/100, fail
      await eventStore.appendEvent(MockSubmittedEvent(
        clientUlid: 'm2',
        userId: userId,
        timestamp: now.add(const Duration(minutes: 10)),
        examContext: 'JAIIB',
        mockResultId: 'res2',
        paperId: 'p_ppb',
        score: 40.0,
        maxScore: 100.0,
        passed: false,
        answers: [],
      ));

      final stats = await analyticsService.calculateAnalytics(userId);
      expect(stats.mockAttemptsCount, 2);
      expect(stats.averageMockScore, closeTo(0.5, 0.001)); // (0.6 + 0.4) / 2 = 0.5
      expect(stats.mockPassRate, 0.5); // 1 passed out of 2 attempts
    });
  });

  group('Notification Service (E9.3) Tests', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('Default settings are correct', () {
      final settings = notificationService.settings;
      expect(settings.enabled, isTrue);
      expect(settings.hour, 20);
      expect(settings.minute, 0);
    });

    test('Update settings is successful', () {
      notificationService.updateSettings(enabled: false, hour: 19, minute: 45);
      final settings = notificationService.settings;
      expect(settings.enabled, isFalse);
      expect(settings.hour, 19);
      expect(settings.minute, 45);
    });

    test('Simulate notification triggers appropriately', () {
      // Enabled, reviews due > 0 -> should trigger
      final msg = notificationService.simulateNotificationTrigger(5);
      expect(msg, equals('5 reviews due — 3 min'));

      // Enabled, reviews due <= 0 -> should not trigger
      final noReviewsMsg = notificationService.simulateNotificationTrigger(0);
      expect(noReviewsMsg, isNull);

      // Disabled, reviews due > 0 -> should not trigger
      notificationService.updateSettings(enabled: false, hour: 20, minute: 0);
      final disabledMsg = notificationService.simulateNotificationTrigger(5);
      expect(disabledMsg, isNull);
    });
  });
}
