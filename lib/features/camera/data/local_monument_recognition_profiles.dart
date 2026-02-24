import '../../monuments/data/local_monuments.dart';
import '../domain/monument_recognition_profile.dart';

const _defaultThreshold = 0.75;

final localMonumentRecognitionProfiles = <MonumentRecognitionProfile>[
  for (final monument in localMonuments)
    MonumentRecognitionProfile(
      monumentId: monument.id,
      matchThreshold: _defaultThreshold,
      radiusMeters: 300,
      embeddings: const [],
      referenceImages: [monument.imageUrl],
    ),
];
