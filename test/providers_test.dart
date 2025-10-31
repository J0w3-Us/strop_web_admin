import 'package:flutter_test/flutter_test.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/core/state/data_state.dart';

void main() {
  group('Provider Architecture Tests', () {
    test('Dashboard provider loads data successfully', () async {
      final provider = DashboardProvider();

      // Initially should be in initial state
      expect(provider.state, DataState.initial);

      // Fetch data
      await provider.fetchDashboardData();

      // Should be in success state with data
      expect(provider.state, DataState.success);
      expect(provider.projects, isNotNull);
    });

    test('Team provider loads data successfully', () async {
      final provider = TeamProvider();

      // Initially should be in initial state
      expect(provider.state, DataState.initial);

      // Fetch data
      await provider.fetchTeamData();

      // Should be in success state with data
      expect(provider.state, DataState.success);
      expect(provider.users, isNotNull);
    });

    test('Repository delays are removed for faster tests', () async {
      final stopwatch = Stopwatch()..start();

      final provider = DashboardProvider();
      await provider.fetchDashboardData();

      stopwatch.stop();

      // Should complete quickly (under 100ms) since delays are removed
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(provider.state, DataState.success);
    });

    test('Data models are properly structured', () async {
      final dashboardProvider = DashboardProvider();
      await dashboardProvider.fetchDashboardData();

      // Test that projects exist and have basic structure
      expect(dashboardProvider.projects, isNotEmpty);

      final project = dashboardProvider.projects.first;
      expect(project.id, isNotEmpty);
      expect(project.name, isNotEmpty);
    });
  });
}
