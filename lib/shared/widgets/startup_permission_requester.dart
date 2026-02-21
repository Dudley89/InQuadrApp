import 'dart:io';
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
    extends ConsumerState<StartupPermissionRequester>
    with WidgetsBindingObserver {
  bool _didRequest = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestStartupPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestStartupPermissions(force: true);
    }
  }

  Future<void> _requestStartupPermissions({bool force = false}) async {
    if (_didRequest && !force) {
      return;
    }
    _didRequest = true;

    AppLogger.info('Richiesta permessi iniziale (camera + posizione + connettività)');

    await ref.read(cameraPermissionControllerProvider.notifier).requestPermission();
    final cameraStatus = ref.read(cameraPermissionControllerProvider);

    PermissionStatus locationStatus = PermissionStatus.denied;
    try {
      locationStatus = await Permission.locationWhenInUse.request();
      AppLogger.info('Stato permesso posizione: $locationStatus');
    } catch (error) {
      AppLogger.error('Errore richiesta permesso posizione: $error');
    }

    final hasNetwork = await _checkInternetConnectivity();

    final hasCameraPermission = cameraStatus == PermissionStatus.granted;
    final hasLocationPermission = locationStatus == PermissionStatus.granted;

    if (!hasCameraPermission || !hasLocationPermission || !hasNetwork) {
      await _showMissingPermissionsDialog();
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasNetwork = results.any((item) => item != ConnectivityResult.none);
      if (hasNetwork) {
        AppLogger.info('Connettività internet disponibile: $results');
      } else {
        AppLogger.warn('Nessuna connettività internet (Wi-Fi/dati) allo startup');
      }
      return hasNetwork;
    } catch (error) {
      AppLogger.error('Errore controllo connettività internet: $error');
      return false;
    }
  }

  Future<void> _showMissingPermissionsDialog() async {
    if (!mounted || _isDialogOpen) {
      return;
    }
    _isDialogOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: const Text(
          'Autorizzazioni necessarie per far funzionare l\'applicazione.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _isDialogOpen = false;
    if (Platform.isAndroid) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
