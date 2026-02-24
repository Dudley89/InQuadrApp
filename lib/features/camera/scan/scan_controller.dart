import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/logging/app_logger.dart';
import '../../settings/application/settings_providers.dart';
import '../data/monument_recognition_providers.dart';
import '../recognition/recognizer.dart';
import 'scan_state.dart';

class ScanController extends StateNotifier<ScanState> {
  ScanController(this._ref, this._recognizer) : super(ScanState.initial());

  static const threshold = 0.75;
  static const streakRequired = 3;
  static const scanIntervalMs = 600;

  final Ref _ref;
  final MonumentRecognizer _recognizer;

  Timer? _timer;
  CameraController? _cameraController;
  bool _started = false;

  String? _lastId;
  int _streak = 0;

  void start(CameraController controller) {
    _cameraController = controller;

    if (_started) {
      return;
    }

    _started = true;
    state = state.copyWith(
      isEnabled: true,
      isLocked: false,
      isBusy: false,
      message: 'Scansione automatica attiva...',
    );

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: scanIntervalMs),
      (_) => _onTick(),
    );
  }

  void stop() {
    if (!_started && _timer == null && state.isEnabled == false) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _started = false;

    if (!state.isEnabled && !state.isBusy && state.message == 'Scansione ferma') {
      return;
    }

    state = state.copyWith(
      isEnabled: false,
      isBusy: false,
      message: 'Scansione ferma',
    );
  }

  void retry() {
    _resetStreak();
    state = ScanState.initial().copyWith(
      message: 'Scansione riavviata...',
    );

    final controller = _cameraController;
    if (controller != null) {
      _started = false;
      start(controller);
    }
  }

  Future<void> _onTick() async {
    if (!state.isEnabled || state.isLocked || state.isBusy) {
      return;
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isTakingPicture) {
      return;
    }

    state = state.copyWith(isBusy: true, message: 'Analisi in corso...');

    try {
      final picture = await controller.takePicture();
      final bytes = await File(picture.path).readAsBytes();
      final result = await _recognizer.recognize(bytes);
      _handleResult(result);
    } catch (error) {
      AppLogger.error('Errore riconoscimento: $error');
      _resetStreak();
      state = state.copyWith(message: 'Errore riconoscimento');
    } finally {
      if (!state.isLocked) {
        state = state.copyWith(isBusy: false);
      }
    }
  }

  void _handleResult(RecognitionResult result) {
    if (result.status == RecognitionStatus.recognized &&
        result.monumentId != null &&
        result.confidence >= _effectiveThresholdFor(result.monumentId!)) {
      _registerRecognized(result.monumentId!, result.confidence);
      return;
    }

    _resetStreak();
    state = state.copyWith(
      message: 'Nessun riconoscimento stabile',
      lockedMonumentId: null,
      lockedConfidence: 0,
    );
  }

  double _effectiveThresholdFor(String monumentId) {
    final profile = _ref.read(recognitionProfileByMonumentIdProvider(monumentId));
    return profile?.matchThreshold ?? threshold;
  }

  void _registerRecognized(String monumentId, double confidence) {
    if (_lastId == monumentId) {
      _streak += 1;
    } else {
      _lastId = monumentId;
      _streak = 1;
    }

    if (_streak >= streakRequired) {
      state = state.copyWith(
        isLocked: true,
        isEnabled: false,
        isBusy: false,
        lockedMonumentId: monumentId,
        lockedConfidence: confidence,
        message: 'Monumento riconosciuto',
      );

      final hapticEnabled = _ref.read(hapticOnRecognizeProvider);
      if (hapticEnabled) {
        scheduleMicrotask(() async {
          try {
            await HapticFeedback.lightImpact();
          } catch (_) {}
          try {
            await HapticFeedback.mediumImpact();
          } catch (_) {}
        });
      }

      _timer?.cancel();
      _timer = null;
      _started = false;
      return;
    }

    state = state.copyWith(
      message: 'Riconoscimento stabile: $_streak/$streakRequired',
    );
  }

  void _resetStreak() {
    _lastId = null;
    _streak = 0;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
