import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
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

    // Items from the bundled sample pack render with regulator badges.
    expect(find.text('MPC keeps the policy repo rate unchanged at 6.50%'),
        findsOneWidget);
    expect(find.text('IIBF'), findsOneWidget);
    expect(find.text('RBI'), findsWidgets);
  });
}
