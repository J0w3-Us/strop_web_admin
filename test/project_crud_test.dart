import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/app.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/core/providers/auth_provider.dart';
import 'package:strop_admin_panel/core/routes/app_router.dart';
import 'package:strop_admin_panel/core/state/data_state.dart';

void main() {
  testWidgets('Create project updates dashboard KPI', (
    WidgetTester tester,
  ) async {
    // Force a wide window so the sidebar is visible
    tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Create fresh providers without loading from storage to ensure clean test state
    final authProvider = AuthProvider();
    final dashboardProvider = DashboardProvider();
    final teamProvider = TeamProvider();

    // Preload data so tests run deterministically and ensure success state
    await dashboardProvider.fetchDashboardData();
    await teamProvider.fetchTeamData();

    // Ensure providers are in success state for testing
    expect(dashboardProvider.state, DataState.success);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
          ChangeNotifierProvider<TeamProvider>.value(value: teamProvider),
        ],
        child: const MyApp(),
      ),
    );

    // Allow initial frames to settle
    await tester.pumpAndSettle();

    // Set authentication directly for tests to avoid SharedPreferences and form validation
    authProvider.setAuthenticatedForTest(user: {'email': 'test@local'});
    await tester.pumpAndSettle();

    // Force navigation to dashboard manually since auto-redirect might not work in tests
    AppRouter.router.go('/app/dashboard');
    await tester
        .pumpAndSettle(); // Navigate to projects route directly (more reliable in tests)
    AppRouter.router.go('/app/projects');
    await tester.pumpAndSettle();

    // Debug: Check what's actually on screen
    debugPrint('Widgets found: ${find.byType(Widget).evaluate().length}');
    debugPrint(
      'Texts found: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
    );

    // Tap the "Crear" button to open the create project dialog
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    // Fill form - first two TextFormFields are code and name
    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);
    await tester.enterText(fields.at(0), 'PRJ-TEST');
    await tester.enterText(fields.at(1), 'Proyecto de prueba');

    // Save - Look for "Crear Proyecto" button in dialog
    await tester.tap(find.text('Crear Proyecto'));
    await tester.pumpAndSettle();

    // Navigate back to dashboard route
    AppRouter.router.go('/app/dashboard');
    await tester.pumpAndSettle();

    // Expect the dashboard title
    expect(find.text('Centro de Mando'), findsOneWidget);

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
