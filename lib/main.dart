import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/app.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/core/providers/auth_provider.dart';
import 'package:strop_admin_panel/core/services/api_client.dart';
import 'package:strop_admin_panel/domain/auth/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar la API real
  ApiClient.instance.init(baseUrl: 'http://localhost:3000');
  AuthRepository.instance.enableApi(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadFromStorage(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider()..fetchDashboardData(),
        ),
        ChangeNotifierProvider(create: (_) => TeamProvider()..fetchTeamData()),
      ],
      child: const MyApp(),
    ),
  );
}
