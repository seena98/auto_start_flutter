// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:auto_start_flutter_example/main.dart';

void main() {
  testWidgets('Verify UI elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the app bar title is present.
    expect(find.text('Auto Start Flutter Example'), findsOneWidget);
    
    // Verify that buttons are present.
    expect(find.text('Check Battery Optimization'), findsOneWidget);
    expect(find.text('Open Auto Start Settings'), findsOneWidget);
  });
}
