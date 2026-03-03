import 'package:flutter_riverpod/flutter_riverpod.dart';

final autoRecognitionEnabledProvider = StateProvider<bool>((ref) => true);
final showConfidenceProvider = StateProvider<bool>((ref) => true);
final hapticOnRecognizeProvider = StateProvider<bool>((ref) => true);
final tipsVisibleProvider = StateProvider<bool>((ref) => true);
