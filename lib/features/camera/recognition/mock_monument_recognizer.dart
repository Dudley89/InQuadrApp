import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../monuments/application/monuments_providers.dart';
import '../../monuments/data/local_monuments.dart';
import 'recognizer.dart';

class MockMonumentRecognizer implements MonumentRecognizer {
  MockMonumentRecognizer(this._ref) : _random = Random();

  final Ref _ref;
  final Random _random;

  @override
  Future<void> warmUp() async {
    return;
  }

  @override
  Future<void> dispose() async {
    return;
  }

  @override
  Future<RecognitionResult> recognize(Uint8List jpegBytes) async {
    final featured = _ref.read(featuredMonumentProvider);
    final targetId = featured.id.isNotEmpty ? featured.id : localMonuments.first.id;

    if (_random.nextDouble() < 0.40) {
      final confidence = 0.80 + (_random.nextDouble() * 0.15);
      return RecognitionResult(
        monumentId: targetId,
        confidence: confidence,
        status: RecognitionStatus.recognized,
      );
    }

    final confidence = 0.20 + (_random.nextDouble() * 0.40);
    return RecognitionResult(
      monumentId: null,
      confidence: confidence,
      status: RecognitionStatus.notRecognized,
    );
  }
}
