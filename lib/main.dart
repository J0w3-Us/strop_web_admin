import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/app.dart';
import 'package:strop_admin_panel/core/providers/dashboard_provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider()..loadInitialData(),
        ),
        ChangeNotifierProvider(create: (_) => TeamProvider()..load()),
      ],
      child: const MyApp(),
    ),
  );
}
