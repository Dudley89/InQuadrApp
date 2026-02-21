import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';
import '../shared/widgets/startup_permission_requester.dart';

class InQuadraApp extends StatelessWidget {
  const InQuadraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InQuadra',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) {
        return StartupGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
