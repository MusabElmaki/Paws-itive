import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:utm_pawsitive/features/feature_pages.dart';

void main() {
  testWidgets('auth entry screen renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    expect(find.text('UTM Paws-itive'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });
}
