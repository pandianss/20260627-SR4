import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';
import 'package:app/components/button.dart';
import 'package:app/components/card.dart';
import 'package:app/components/pill.dart';
import 'package:app/components/progress_ring.dart';
import 'package:app/components/option_chip.dart';
import 'package:app/components/rating_buttons.dart';
import 'package:app/theme/tokens.dart';
import 'package:srs/srs.dart';

void main() {
  group('Calm Design System Components Tests', () {
    testWidgets('CalmButton primary and secondary render correct text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: Column(
              children: [
                CalmButton.primary(
                  text: 'Primary Action',
                  onPressed: () {},
                ),
                CalmButton.secondary(
                  text: 'Secondary Action',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);
    });

    testWidgets('CalmCard renders content and border decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: const Scaffold(
            body: CalmCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppTokens.dark.bgSurface));
      expect(decoration.borderRadius, equals(BorderRadius.circular(14)));
    });

    testWidgets('CalmPill renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: const Scaffold(
            body: CalmPill(label: 'Active'),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('CalmProgressRing paints custom arc', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: const Scaffold(
            body: CalmProgressRing(progress: 0.5),
          ),
        ),
      );

      expect(find.byType(CalmProgressRing), findsOneWidget);
    });

    testWidgets('CalmOptionChip renders labels and icons depending on state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: Column(
              children: [
                const CalmOptionChip(
                  identifier: 'A',
                  label: 'Option A',
                  state: OptionChipState.unselected,
                ),
                CalmOptionChip(
                  identifier: 'B',
                  label: 'Option B',
                  state: OptionChipState.correct,
                  onTap: () {},
                ),
                const CalmOptionChip(
                  identifier: 'C',
                  label: 'Option C',
                  state: OptionChipState.wrong,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('Option C'), findsOneWidget);

      // Verify B has check icon and C has cancel icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('CalmRatingButtons displays all choices', (tester) async {
      Rating? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: Scaffold(
            body: CalmRatingButtons(
              onRatingSelected: (r) => selectedRating = r,
            ),
          ),
        ),
      );

      expect(find.text('Again'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);

      // Tap Again and check rating selection
      await tester.tap(find.text('Again'));
      expect(selectedRating, equals(Rating.again));
    });
  });

  group('App Flow & Onboarding Navigation Tests', () {
    testWidgets('Onboarding flow advances and boots main screen', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Step 0: Welcome Screen
      expect(find.text('Calm Prep'), findsOneWidget);
      expect(find.text('Start Preparation'), findsOneWidget);
      expect(find.text('Choose your exam'), findsNothing);

      // Tap "Start Preparation"
      await tester.tap(find.text('Start Preparation'));
      await tester.pumpAndSettle();

      // Step 1: Create Account
      expect(find.text('Create your account'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'test@bank.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Step 2: Pick Exam
      expect(find.text('Choose your exam'), findsOneWidget);
      expect(find.text('JAIIB'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap "Next"
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Step 2: Set Exam Date
      expect(find.text('Set your exam date'), findsOneWidget);
      expect(find.text('Begin Studying'), findsOneWidget);

      // Tap "Begin Studying" to complete onboarding
      await tester.tap(find.text('Begin Studying'));
      await tester.pumpAndSettle();

      // Should now render MainLayout / HomeScreen
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text("Today's 5 minutes"), findsOneWidget);
      expect(find.text('Begin'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Mocks'), findsOneWidget);
    });
  });
}
