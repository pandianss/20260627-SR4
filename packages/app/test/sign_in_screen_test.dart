import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/screens/sign_in_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/theme/tokens.dart';

void main() {
  Widget wrap(AuthService auth) => MaterialApp(
        theme: buildTheme(AppTokens.light),
        home: SignInScreen(authService: auth),
      );

  testWidgets('offers all three methods and switches between modes',
      (tester) async {
    await tester.pumpWidget(wrap(AuthService(auth: MockFirebaseAuth())));
    await tester.pumpAndSettle();

    // Google + email/phone toggle present, email mode by default.
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('New here? Create account'), findsOneWidget);

    // Switch to "create account".
    await tester.tap(find.text('New here? Create account'));
    await tester.pump();
    expect(find.text('Create account'), findsOneWidget);

    // Switch to phone mode → reveals the send-code step.
    await tester.tap(find.text('Phone'));
    await tester.pump();
    expect(find.text('Send code'), findsOneWidget);
  });
}
