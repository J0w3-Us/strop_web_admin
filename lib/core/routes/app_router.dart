import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strop_admin_panel/feactures/auth/presentaciones/screens/login_screens.dart';
import 'package:strop_admin_panel/feactures/dashboard/screens/dashboard_screen.dart';
import 'package:strop_admin_panel/feactures/layout/screens/main_layout_screen.dart';
import 'package:strop_admin_panel/feactures/projects/screens/project_list_screen.dart';
import 'package:strop_admin_panel/feactures/projects/screens/project_detail_screen.dart';
import 'package:strop_admin_panel/feactures/projects/screens/project_detail_view_screen.dart';
import 'package:strop_admin_panel/feactures/settings/screens/account_settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/core/providers/auth_provider.dart';

/// Configuración central del enrutador usando go_router
class AppRouter {
  AppRouter._();

  static late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final loggingIn = state.uri.path == '/login';
      if (!auth.isAuthenticated && !loggingIn) return '/login';
      if (auth.isAuthenticated && loggingIn) return '/app/dashboard';
      return null;
    },
    routes: <RouteBase>[
      // Ruta de login (sin layout)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),

      // App shell con rutas anidadas
      ShellRoute(
        builder: (context, state, child) =>
            MainLayoutScreen(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/app/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/app/projects',
            name: 'projects',
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'project-detail',
                builder: (context, state) =>
                    ProjectDetailViewScreen(id: state.pathParameters['id']!),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'project-edit',
                builder: (context, state) =>
                    ProjectDetailScreen(id: state.pathParameters['id']),
              ),
            ],
          ),
          // Rutas placeholder para demo
          GoRoute(
            path: '/app/incidents',
            name: 'incidents',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Incidencias'),
          ),
          GoRoute(
            path: '/app/authorizations',
            name: 'authorizations',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Autorizaciones'),
          ),
          // Ruta de configuración de cuenta
          GoRoute(
            path: '/app/settings',
            name: 'settings',
            builder: (context, state) => const AccountSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

// Redirect reads AuthProvider from the BuildContext; no extra listener class required.

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          '$title (en construcción)',
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF0A2C52),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
