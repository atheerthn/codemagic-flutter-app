class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() => country.isNotEmpty ? '$name, $country' : name;

  @override
  bool operator ==(Object other) =>
      other is City &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
