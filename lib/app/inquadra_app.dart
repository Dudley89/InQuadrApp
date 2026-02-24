import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

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
    );
  }
}
