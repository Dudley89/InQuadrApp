class Monument {
  const Monument({
    required this.id,
    required this.name,
    required this.description,
    required this.deepDive,
    required this.accessibility,
  });

  final String id;
  final String name;
  final String description;
  final String deepDive;
  final List<String> accessibility;
}
