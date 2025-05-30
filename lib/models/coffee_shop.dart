class CoffeeShop {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  CoffeeShop({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory CoffeeShop.fromMap(Map<String, dynamic> map) {
    return CoffeeShop(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  CoffeeShop copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) {
    return CoffeeShop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'CoffeeShop{id: $id, name: $name, latitude: $latitude, longitude: $longitude, isFavorite: $isFavorite}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoffeeShop &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
