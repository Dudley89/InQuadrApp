import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/monument_recognition_profile.dart';
import 'local_monument_recognition_profiles.dart';

final monumentRecognitionProfilesProvider =
    Provider<List<MonumentRecognitionProfile>>((ref) {
  return localMonumentRecognitionProfiles;
});

final recognitionProfileByMonumentIdProvider =
    Provider.family<MonumentRecognitionProfile?, String>((ref, id) {
  final profiles = ref.watch(monumentRecognitionProfilesProvider);
  for (final profile in profiles) {
    if (profile.monumentId == id) {
      return profile;
    }
  }
  return null;
});
