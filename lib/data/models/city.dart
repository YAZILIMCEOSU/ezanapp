import 'package:flutter/foundation.dart';

/// Konum belirleme biçimi.
enum LocationMode {
  gps('Otomatik (GPS)', 'Bulunduğunuz konuma göre vakitler hesaplanır'),
  manual('Manuel şehir', 'Seçtiğiniz şehre göre vakitler gösterilir');

  const LocationMode(this.label, this.description);

  final String label;
  final String description;

  static LocationMode fromName(String? name) =>
      LocationMode.values.firstWhere((LocationMode m) => m.name == name, orElse: () => LocationMode.gps);
}

/// Bir şehir/ilçe kaydı.
@immutable
class City {
  const City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.province,
    this.country = 'Türkiye',
    this.timeZoneOffsetHours = 3.0,
    this.isTurkish = true,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? province;
  final String country;
  final double timeZoneOffsetHours;
  final bool isTurkish;

  /// Görüntülenecek tam ad: "İlçe, İl" veya "Şehir, Ülke".
  String get displayName {
    if (isTurkish && province != null && province != name) {
      return '$name, $province';
    }
    if (!isTurkish) return '$name, $country';
    return name;
  }

  String get subtitle => isTurkish ? (province ?? country) : country;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'lat': latitude,
        'lon': longitude,
        'province': province,
        'country': country,
        'tz': timeZoneOffsetHours,
        'isTurkish': isTurkish,
      };

  factory City.fromJson(Map<String, Object?> json) => City(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        latitude: (json['lat'] as num?)?.toDouble() ?? 0,
        longitude: (json['lon'] as num?)?.toDouble() ?? 0,
        province: json['province'] as String?,
        country: json['country'] as String? ?? 'Türkiye',
        timeZoneOffsetHours: (json['tz'] as num?)?.toDouble() ?? 3.0,
        isTurkish: json['isTurkish'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      other is City && other.id == id && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(id, latitude, longitude);

  @override
  String toString() => 'City($name, $latitude, $longitude)';
}

/// Kullanıcının seçili konumu (şehir + GPS).
@immutable
class UserLocation {
  const UserLocation({
    required this.mode,
    required this.latitude,
    required this.longitude,
    this.city,
    this.updatedAt,
    this.gpsAccuracyMeters,
  });

  final LocationMode mode;
  final double latitude;
  final double longitude;
  final City? city;
  final DateTime? updatedAt;
  final double? gpsAccuracyMeters;

  String get label => city?.displayName ?? 'Mevcut konum';

  String get coordinates =>
      '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';

  UserLocation copyWith({LocationMode? mode, double? latitude, double? longitude, City? city}) =>
      UserLocation(
        mode: mode ?? this.mode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        city: city ?? this.city,
        updatedAt: DateTime.now(),
        gpsAccuracyMeters: gpsAccuracyMeters,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'mode': mode.name,
        'lat': latitude,
        'lon': longitude,
        'city': city?.toJson(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory UserLocation.fromJson(Map<String, Object?> json) => UserLocation(
        mode: LocationMode.fromName(json['mode'] as String?),
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lon'] as num).toDouble(),
        city: json['city'] == null
            ? null
            : City.fromJson((json['city']! as Map<Object?, Object?>).cast<String, Object?>()),
        updatedAt: json['updatedAt'] == null ? null : DateTime.tryParse(json['updatedAt'] as String),
      );
}
