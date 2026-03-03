import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../recognition/recognizer_providers.dart';
import 'scan_controller.dart';
import 'scan_state.dart';

final scanControllerProvider =
    StateNotifierProvider.autoDispose<ScanController, ScanState>((ref) {
  final recognizer = ref.watch(monumentRecognizerProvider);
  final controller = ScanController(ref, recognizer);

  ref.onDispose(controller.stop);

  return controller;
});
