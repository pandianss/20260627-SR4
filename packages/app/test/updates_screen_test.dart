import 'dart:convert';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/app_scope.dart';
import 'package:app/data/learning_repository.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/services/updates_service.dart';
import 'package:app/screens/updates_screen.dart';
import 'package:app/theme/tokens.dart';

void main() {
  testWidgets(
      'Updates tab renders curated regulator updates from the bundled seed',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    final repo = LearningRepository(
      content: MemoryContentStore(),
      events: MemoryEventLogStore(),
      states: MemorySrsStateStore(),
      scheduler: const Fsrs(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(AppTokens.light),
        home: AppScope(
          repository: repo,
          userId: 'u',
          examName: 'CAIIB',
          examDate: DateTime.now().add(const Duration(days: 30)),
          examConfig: const ExamConfig(examCode: 'CAIIB'),
          notificationService: NotificationService(),
          updatesService: UpdatesService(),
          isPremium: false,
          child: const UpdatesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Header + disclaimer render.
    expect(find.text('Regulatory updates'), findsOneWidget);
    expect(find.textContaining('official notification'), findsOneWidget);

    // The newest update renders at the top of the (virtualized) list.
    expect(find.text('Revised Digital Lending Guidelines issued'),
        findsOneWidget);
    // Issuing-body filter chips render (plus an "All" reset per filter row).
    expect(find.text('RBI'), findsWidgets);
    expect(find.text('IIBF'), findsWidgets);
    expect(find.text('All'), findsWidgets);
  });

  group('UpdatesService tests', () {
    test('uses configured feedUrl when specified', () async {
      final mockClient = MockClient((req) async {
        return http.Response(
          '{"version": 1, "generatedAt": "2026-06-27T08:32:00Z", "updates": []}',
          200,
        );
      });
      final service = UpdatesService(feedUrl: 'https://example.com/feed.json', client: mockClient);
      final res = await service.load(forceRefresh: true);
      expect(res.source, UpdatesSource.network);
      expect(res.feed.updates, isEmpty);
    });

    test('filters updates to last 3 months, falling back to 5 items if empty', () async {
      final mockClient = MockClient((req) async {
        final nowStr = DateTime.now().toIso8601String().split('T')[0];
        final fourMonthsAgoStr = DateTime.now().subtract(const Duration(days: 120)).toIso8601String().split('T')[0];
        return http.Response(
          jsonEncode({
            "version": 1,
            "generatedAt": "2026-06-27T08:32:00Z",
            "updates": [
              {
                "id": "u-1",
                "regulator": "RBI",
                "title": "Fresh Update",
                "summary": "...",
                "category": "Cat",
                "priority": "normal",
                "publishedAt": nowStr,
                "sourceUrl": "..."
              },
              {
                "id": "u-2",
                "regulator": "SEBI",
                "title": "Old Update",
                "summary": "...",
                "category": "Cat",
                "priority": "normal",
                "publishedAt": fourMonthsAgoStr,
                "sourceUrl": "..."
              }
            ]
          }),
          200,
        );
      });
      final service = UpdatesService(feedUrl: 'https://example.com/feed.json', client: mockClient);
      final res = await service.load(forceRefresh: true);
      expect(res.feed.updates.length, equals(1));
      expect(res.feed.updates.first.id, equals('u-1'));
    });
  });
}

