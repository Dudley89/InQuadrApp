import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutePaths.home);
            break;
          case 1:
            context.go(AppRoutePaths.camera);
            break;
          case 2:
            context.go(AppRoutePaths.monuments);
            break;
          case 3:
            context.go(AppRoutePaths.settings);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.center_focus_strong),
          label: 'Scansiona',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_city),
          label: 'Monumenti',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Impostazioni',
        ),
      ],
    );
  }
}
