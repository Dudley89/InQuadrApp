class Monument {
  const Monument({
    required this.id,
    required this.name,
    required this.description,
    required this.deepDive,
    required this.accessibility,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String description;
  final String deepDive;
  final List<String> accessibility;
  final double latitude;
  final double longitude;
}
