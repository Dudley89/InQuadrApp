import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/camera/application/camera_permission_controller.dart';
import '../logging/app_logger.dart';

class StartupPermissionRequester extends ConsumerStatefulWidget {
  const StartupPermissionRequester({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StartupPermissionRequester> createState() =>
      _StartupPermissionRequesterState();
}

class _StartupPermissionRequesterState
    extends ConsumerState<StartupPermissionRequester> {
  bool _didRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestStartupPermissions();
    });
  }

  Future<void> _requestStartupPermissions() async {
    if (_didRequest) {
      return;
    }
    _didRequest = true;

    AppLogger.info('Richiesta permessi iniziale (camera + posizione + connettività)');

    await ref.read(cameraPermissionControllerProvider.notifier).requestPermission();

    try {
      final locationStatus = await Permission.locationWhenInUse.request();
      AppLogger.info('Stato permesso posizione: $locationStatus');
    } catch (error) {
      AppLogger.error('Errore richiesta permesso posizione: $error');
    }

    await _checkInternetConnectivity();
  }

  Future<void> _checkInternetConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasNetwork = results.any((item) => item != ConnectivityResult.none);
      if (hasNetwork) {
        AppLogger.info('Connettività internet disponibile: $results');
      } else {
        AppLogger.warn('Nessuna connettività internet (Wi-Fi/dati) allo startup');
      }
    } catch (error) {
      AppLogger.error('Errore controllo connettività internet: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
