// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:strop_admin_panel/app.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';

void main() {
  testWidgets('Smoke test: login navigates to dashboard', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(
      ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider(), child: const MyApp()),
    );

    // Expect login screen content
    expect(find.text('Bienvenido a Strop'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);

    // Tap the login button and wait for navigation
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pumpAndSettle();

    // Dashboard title should be visible
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
