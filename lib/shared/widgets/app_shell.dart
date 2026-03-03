import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    var normalized = location.split('?').first;
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized == AppRoutePaths.home) {
      return 0;
    }
    if (normalized.startsWith(AppRoutePaths.camera)) {
      return 1;
    }
    if (normalized == AppRoutePaths.monuments ||
        normalized.startsWith('${AppRoutePaths.monument}/')) {
      return 2;
    }
    if (normalized.startsWith(AppRoutePaths.settings)) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(selectedIndex: selectedIndex),
    );
  }
}
