import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/camera/presentation/camera_screen.dart';
import '../features/monuments/presentation/monument_detail_screen.dart';
import '../shared/logging/app_logger.dart';
import '../shared/widgets/home_screen.dart';

class AppRoutePaths {
  static const home = '/';
  static const camera = '/camera';
  static const monument = '/monument';
}

final appRouter = GoRouter(
  observers: [RouteLoggerObserver()],
  routes: [
    GoRoute(
      path: AppRoutePaths.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.camera,
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.monument,
      builder: (context, state) => const MonumentDetailScreen(),
    ),
  ],
);

class RouteLoggerObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigazione: ${previousRoute?.settings.name ?? 'none'} -> ${route.settings.name ?? route.runtimeType}');
    super.didPush(route, previousRoute);
  }
}
