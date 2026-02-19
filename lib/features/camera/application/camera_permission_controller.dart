import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/logging/app_logger.dart';

final cameraPermissionControllerProvider =
    StateNotifierProvider<CameraPermissionController, PermissionStatus>(
  (ref) => CameraPermissionController(),
);

class CameraPermissionController extends StateNotifier<PermissionStatus> {
  CameraPermissionController() : super(PermissionStatus.denied) {
    refreshStatus();
  }

  Future<void> refreshStatus() async {
    try {
      final status = await Permission.camera.status;
      state = status;
      AppLogger.info('Stato permesso camera: $status');
    } catch (error) {
      AppLogger.error('Errore lettura stato permesso camera: $error');
      state = PermissionStatus.denied;
    }
  }

  Future<void> requestPermission() async {
    try {
      final status = await Permission.camera.request();
      state = status;
      if (status == PermissionStatus.granted) {
        AppLogger.info('Permesso camera concesso');
      } else {
        AppLogger.warn('Permesso camera non concesso: $status');
      }
    } catch (error) {
      AppLogger.error('Errore richiesta permesso camera: $error');
      state = PermissionStatus.denied;
    }
  }
}
