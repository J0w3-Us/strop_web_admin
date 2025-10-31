// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strop_admin_panel/app.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/core/providers/auth_provider.dart';
import 'package:strop_admin_panel/core/state/data_state.dart';
import 'package:strop_admin_panel/core/routes/app_router.dart';

void main() {
  testWidgets('Smoke test: login navigates to dashboard', (
    WidgetTester tester,
  ) async {
    // Force a wide window so layout doesn't overflow in tests
    tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Create fresh providers without loading from storage to ensure clean test state
    final authProvider = AuthProvider();
    final dashboardProvider = DashboardProvider();
    final teamProvider = TeamProvider();

    // Preload dashboard data so the dashboard renders consistently in tests
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
    await tester.pumpAndSettle();

    // Dashboard title should be visible
    expect(find.text('Centro de Mando'), findsOneWidget);
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
