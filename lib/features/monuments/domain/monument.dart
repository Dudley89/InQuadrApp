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
    this.locality,
    this.address,
    this.municipality,
    this.province,
    this.region,
    this.country,
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
  final String? locality;
  final String? address;
  final String? municipality;
  final String? province;
  final String? region;
  final String? country;

  factory Monument.fromJson(Map<String, Object?> json) {
    return Monument(
      id: json['id']! as String,
      idGlobal: (json['idGlobal']! as num).toInt(),
      name: json['name']! as String,
      description: json['description']! as String,
      deepDive: json['deepDive'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      accessibility: (json['accessibility'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
      latitude: (json['latitude']! as num).toDouble(),
      longitude: (json['longitude']! as num).toDouble(),
      locality: json['locality'] as String?,
      address: json['address'] as String?,
      municipality: json['municipality'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
    );
  }
}
