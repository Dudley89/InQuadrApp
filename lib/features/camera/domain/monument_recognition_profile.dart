class MonumentRecognitionProfile {
  const MonumentRecognitionProfile({
    required this.monumentId,
    required this.matchThreshold,
    this.radiusMeters,
    required this.embeddings,
    required this.referenceImages,
  });

  final String monumentId;
  final double matchThreshold;
  final double? radiusMeters;
  final List<List<double>> embeddings;
  final List<String> referenceImages;
}
