import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wasteless_app/screens/onboarding/login_signup_screen.dart';

void main() {
  testWidgets('login/signup screen renders primary actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginSignupScreen()));

    expect(find.text('WasteLess'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
