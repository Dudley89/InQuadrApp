import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/logging/app_logger.dart';
import 'camera_permission_controller.dart';

final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  final cameras = await availableCameras();
  AppLogger.info('Fotocamere disponibili: ${cameras.length}');
  return cameras;
});

final cameraPreviewControllerProvider =
    FutureProvider.autoDispose<CameraController>((ref) async {
  final status = ref.watch(cameraPermissionControllerProvider);
  if (status != PermissionStatus.granted) {
    throw StateError('Permesso fotocamera non concesso');
  }

  final cameras = await ref.watch(availableCamerasProvider.future);
  if (cameras.isEmpty) {
    throw StateError('Nessuna fotocamera disponibile sul dispositivo');
  }

  final controller = CameraController(
    cameras.first,
    ResolutionPreset.medium,
    enableAudio: false,
  );

  await controller.initialize();
  AppLogger.info('Preview camera inizializzata');

  ref.onDispose(() async {
    await controller.dispose();
    AppLogger.info('Preview camera rilasciata');
  });

  return controller;
});
