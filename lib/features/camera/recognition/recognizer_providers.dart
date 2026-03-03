import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_monument_recognizer.dart';
import 'recognizer.dart';

final monumentRecognizerProvider = Provider<MonumentRecognizer>((ref) {
  final recognizer = MockMonumentRecognizer(ref);
  recognizer.warmUp();
  ref.onDispose(recognizer.dispose);
  return recognizer;
});
