import 'package:flutter/material.dart';
import 'package:strop_admin_panel/core/routes/app_router.dart';
import 'package:strop_admin_panel/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Strop Web',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      routerConfig: AppRouter.router,
    );
  }
}
