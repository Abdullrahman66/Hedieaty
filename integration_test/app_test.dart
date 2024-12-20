import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project_2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("User opens the app, logs in, and navigates to the home page", (tester) async {
    // Start the app
    await app.main();
    await tester.pumpAndSettle(); // Wait for the app to settle

    // Verify LoginPage is displayed
    expect(find.byType(TextField), findsNWidgets(2));

    // Enter email and password
    await tester.enterText(find.byType(TextField).at(0), "abdo@gmail.com");
    await tester.enterText(find.byType(TextField).at(1), "1234567");

    // Tap the login button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(seconds: 5));


    // Check if BottomNavigationBar exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Check if HomePage is the default tab
    expect(find.text("Friends List"), findsOneWidget);
  });
}