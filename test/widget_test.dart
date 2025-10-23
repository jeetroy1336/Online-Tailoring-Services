import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minor_project/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BeautifulLoginScreen()));

    expect(find.text('Email or Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Don’t have an account? Sign up'), findsOneWidget);
  });
}