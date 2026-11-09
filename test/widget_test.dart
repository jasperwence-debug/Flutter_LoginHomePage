import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Full AuthPage registration, validation, login, and logout flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const LoginRegisterApp());

    // 1. Initially on Login page
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('QuickPass Portal'), findsOneWidget);

    // 2. Switch to Registration page
    await tester.ensureVisible(find.text('No account yet? Register'));
    await tester.tap(find.text('No account yet? Register'));
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsWidgets);
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    // 3. Test validation: Empty fields submitted
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);

    // 4. Test validation: Password shorter than 8 characters (Student requirement)
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Juan Dela Cruz');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'juan@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), '1234567'); // 7 chars
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), '1234567');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    // 5. Test validation: Password mismatch
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'flutter123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'different123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);

    // 6. Successful Registration
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'flutter123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
        find.text('Registration successful! Please log in.'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Fast-forward past SnackBar 4s timeout and fade-out
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // 7. Login with wrong password
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'juan@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'wrongpass123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Incorrect email or password.'), findsOneWidget);

    // Fast-forward past SnackBar 4s timeout and fade-out
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // 8. Successful Login
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'juan@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'flutter123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Verify Welcome Screen
    expect(find.text('Welcome, Juan Dela Cruz!'), findsOneWidget);
    expect(find.text('juan@example.com'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // 9. Logout
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
