import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/app.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/routes/app_router.dart';

void main() {
  testWidgets('Create project updates dashboard KPI', (WidgetTester tester) async {
    // Force a wide window so the sidebar is visible
    tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
    tester.binding.window.devicePixelRatioTestValue = 1.0;


    await tester.pumpWidget(
      ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider(), child: const MyApp()),
    );

    await tester.pumpAndSettle();

    // Login
    expect(find.text('Bienvenido a Strop'), findsOneWidget);
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pumpAndSettle();

    // Navigate to projects route directly (more reliable in tests)
    AppRouter.router.go('/app/projects');
    await tester.pumpAndSettle();

    // Navigate directly to project creation route (more reliable in tests)
    AppRouter.router.go('/app/projects/new');
    await tester.pumpAndSettle();

    // Fill form - first two TextFormFields are code and name
    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);
    await tester.enterText(fields.at(0), 'PRJ-TEST');
    await tester.enterText(fields.at(1), 'Proyecto de prueba');

    // Save
    await tester.tap(find.text('Guardar'));
    // Wait for async repository delays and snackbars
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Navigate back to dashboard route
    AppRouter.router.go('/app/dashboard');
    await tester.pumpAndSettle();

    // Expect the KPI to show 1
    expect(find.text('1'), findsWidgets);

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
