import 'dart:math' as math;

import '../constants/app_constants.dart';

/// Coğrafi hesaplamalar: kıble yönü, mesafe, açı normalizasyonu.
abstract final class GeoUtils {
  static const double _deg2rad = math.pi / 180.0;
  static const double _rad2deg = 180.0 / math.pi;

  /// 0-360 aralığına indirger.
  static double normalizeDegrees(double degrees) {
    final double value = degrees % 360.0;
    return value < 0 ? value + 360.0 : value;
  }

  /// -180..180 aralığına indirger (yön farkı için).
  static double normalizeSigned(double degrees) {
    double value = normalizeDegrees(degrees);
    if (value > 180) value -= 360;
    return value;
  }

  /// Kâbe'ye olan yön (kuzeyden saat yönünde, derece).
  ///
  /// Büyük daire (initial bearing) formülü kullanılır.
  static double qiblaBearing(double latitude, double longitude) {
    final double lat1 = latitude * _deg2rad;
    const double lat2 = AppConstants.kaabaLat * _deg2rad;
    final double deltaLon = (AppConstants.kaabaLng - longitude) * _deg2rad;
    final double y = math.sin(deltaLon);
    final double x =
        math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(deltaLon);
    return normalizeDegrees(math.atan2(y, x) * _rad2deg);
  }

  /// Kâbe'ye kuş uçuşu mesafe (km) — haversine.
  static double distanceToKaabaKm(double latitude, double longitude) {
    const double earthRadiusKm = 6371.0088;
    final double dLat = (AppConstants.kaabaLat - latitude) * _deg2rad;
    final double dLon = (AppConstants.kaabaLng - longitude) * _deg2rad;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latitude * _deg2rad) *
            math.cos(AppConstants.kaabaLat * _deg2rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Kâbe'nin ufukta görünmesi gereken yükseklik açısı (0'a çok yakın).
  static double horizonElevationDegrees(double latitude, double longitude,
      {double altitudeMeters = 0}) {
    final double distanceKm = distanceToKaabaKm(latitude, longitude);
    if (distanceKm < 1) return 90;
    final double heightKm = 277.0 / 1000.0 + altitudeMeters / 1000.0;
    return math.atan(heightKm / distanceKm) * _rad2deg;
  }

  /// İki koordinat aynı mı (yaklaşık)?
  static bool samePlace(double lat1, double lon1, double lat2, double lon2,
          {double tolerance = 0.02}) =>
      (lat1 - lat2).abs() < tolerance && (lon1 - lon2).abs() < tolerance;

  /// Yaklaşık UTC saat dilimi farkı (boylama göre, tam saat).
  static double approximateTimeZoneOffset(double longitude) {
    final double raw = longitude / 15.0;
    return raw.roundToDouble().clamp(-12.0, 14.0);
  }

  /// Türkiye için yaz saati uygulaması: 2016'dan beri kalıcı UTC+3.
  static double turkeyTimeZoneOffset(DateTime date) => 3.0;
}
