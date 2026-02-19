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
    final status = await Permission.camera.status;
    state = status;
    AppLogger.info('Stato permesso camera: $status');
  }

  Future<void> requestPermission() async {
    final status = await Permission.camera.request();
    state = status;
    if (status == PermissionStatus.granted) {
      AppLogger.info('Permesso camera concesso');
    } else {
      AppLogger.warn('Permesso camera non concesso: $status');
    }
  }
}
