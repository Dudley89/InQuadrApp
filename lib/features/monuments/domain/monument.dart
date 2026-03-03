class Monument {
  const Monument({
    required this.id,
    required this.idGlobal,
    required this.name,
    required this.description,
    required this.deepDive,
    required this.imageUrl,
    required this.accessibility,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final int idGlobal;
  final String name;
  final String description;
  final String deepDive;
  final String imageUrl;
  final List<String> accessibility;
  final double latitude;
  final double longitude;
}
