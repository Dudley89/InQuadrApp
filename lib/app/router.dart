import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/camera/presentation/camera_screen.dart';
import '../features/monuments/presentation/monument_detail_screen.dart';
import '../features/monuments/presentation/monuments_list_screen.dart';
import '../features/startup/presentation/startup_gate_screen.dart';
import '../shared/logging/app_logger.dart';
import '../shared/widgets/home_screen.dart';

class AppRoutePaths {
  static const startup = '/startup';
  static const home = '/home';
  static const camera = '/camera';
  static const monuments = '/monuments';
  static const monument = '/monument';
}

final appRouter = GoRouter(
  initialLocation: AppRoutePaths.startup,
  observers: [RouteLoggerObserver()],
  routes: [
    GoRoute(
      path: AppRoutePaths.startup,
      builder: (context, state) => const StartupGateScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.camera,
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.monuments,
      builder: (context, state) => const MonumentsListScreen(),
    ),
    GoRoute(
      path: '${AppRoutePaths.monument}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return MonumentDetailScreen(monumentId: id);
      },
    ),
  ],
);

class RouteLoggerObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info(
      'Navigazione: ${previousRoute?.settings.name ?? 'none'} -> ${route.settings.name ?? route.runtimeType}',
    );
    super.didPush(route, previousRoute);
  }
}
