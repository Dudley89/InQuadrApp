import 'dart:typed_data';

abstract class MonumentRecognizer {
  Future<RecognitionResult> recognize(Uint8List jpegBytes);
  Future<void> warmUp();
  Future<void> dispose();
}

enum RecognitionStatus { recognized, notRecognized, busy, error }

class RecognitionResult {
  const RecognitionResult({
    required this.monumentId,
    required this.confidence,
    required this.status,
    this.errorMessage,
  });

  final String? monumentId;
  final double confidence;
  final RecognitionStatus status;
  final String? errorMessage;
}
