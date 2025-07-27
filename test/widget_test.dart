// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comp/main.dart'; // Adjust the import based on your project structure

void main() {
  testWidgets('Navigate to SquatPage and add an attempt', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(PowerliftingApp());

    // Verify that the home page is displayed
    expect(find.text('Select Lifting Type'), findsOneWidget);
    expect(find.text('Powerlifting'), findsOneWidget);
    expect(find.text('Weightlifting'), findsOneWidget);

    // Tap the Powerlifting button to navigate to SquatPage
    await tester.tap(find.text('Powerlifting'));
    await tester.pumpAndSettle(); // Wait for the navigation animation to complete

    // Verify that the SquatPage is displayed
    expect(find.text('Powerlifting - Squat'), findsOneWidget);
    expect(find.text('Lifter Name'), findsOneWidget);
    expect(find.text('Attempt Weight'), findsOneWidget);

    // Enter a lifter name
    await tester.enterText(find.byType(TextField).first, 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), '100'); // Enter attempt weight

    // Select 'Passed' for the attempt result
    await tester.tap(find.byType(DropdownButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Passed').last); // Select 'Passed'
    await tester.pumpAndSettle();

    // Tap the 'Add' button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that the attempt was added
    expect(find.text('1'), findsOneWidget); // Check if the first attempt is displayed
    expect(find.text('100'), findsOneWidget); // Check if the weight is displayed
    expect(find.text('Passed'), findsOneWidget); // Check if the result is displayed
  });
}