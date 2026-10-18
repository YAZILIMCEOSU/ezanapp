import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../errors/app_exception.dart';
import '../utils/logger.dart';

/// Konum izni ve okuma durumu.
enum LocationStatus {
  granted('İzin verildi'),
  denied('İzin verilmedi'),
  deniedForever('Kalıcı olarak reddedildi'),
  serviceDisabled('Konum servisi kapalı');

  const LocationStatus(this.label);

  final String label;
}

/// Konum okuma sonucu.
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.altitudeMeters,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? altitudeMeters;
  final DateTime? timestamp;

  /// Kıble ve vakit hesabı için kaba ama yeterli doğruluk sınırı (km).
  bool get isPreciseEnough => (accuracyMeters ?? 0) < 50000;
}

/// GPS üzerinden konum sağlayıcı.
class LocationService {
  const LocationService();

  Future<LocationStatus> checkStatus() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationStatus.serviceDisabled;
      final LocationPermission permission = await Geolocator.checkPermission();
      return switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationStatus.granted,
        LocationPermission.deniedForever => LocationStatus.deniedForever,
        LocationPermission.denied => LocationStatus.denied,
        _ => LocationStatus.denied,
      };
    } catch (error, stackTrace) {
      AppLog.error(
        'Konum durumu okunamadı',
        error: error,
        stackTrace: stackTrace,
      );
      return LocationStatus.serviceDisabled;
    }
  }

  Future<LocationStatus> requestPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationStatus.serviceDisabled;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationStatus.granted,
        LocationPermission.deniedForever => LocationStatus.deniedForever,
        _ => LocationStatus.denied,
      };
    } catch (error, stackTrace) {
      AppLog.error(
        'Konum izni istenemedi',
        error: error,
        stackTrace: stackTrace,
      );
      return LocationStatus.denied;
    }
  }

  /// Tek seferlik konum alır. Açık alanda uydu GPS, bina içinde Wi-Fi/hücresel
  /// konum yedeğiyle hızlı ve kesintisiz koordinat döndürür.
  Future<LocationFix> getCurrentPosition({
    Duration timeout = const Duration(seconds: 6),
    bool preferLastKnown = false,
  }) async {
    final LocationStatus status = await requestPermission();
    switch (status) {
      case LocationStatus.serviceDisabled:
        throw AppException.locationDisabled();
      case LocationStatus.denied:
      case LocationStatus.deniedForever:
        throw AppException.permission('Konum');
      case LocationStatus.granted:
        break;
    }

    if (preferLastKnown) {
      try {
        final Position? last = await Geolocator.getLastKnownPosition();
        if (last != null &&
            last.timestamp.difference(DateTime.now()).abs() <
                const Duration(minutes: 3)) {
          return _toFix(last);
        }
      } catch (_) {}
    }

    // 1. Öncelik: Yüksek doğruluklu GPS (5-6 sn içinde kilitlenirse tam sokak konumu).
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      return _toFix(position);
    } catch (_) {
      // Bina içinde uydu sinyali zayıfsa 2. öncelik olarak Wi-Fi / Baz istasyonu
      // (medium/low accuracy) konumuna düşülür; 0.5 sn içinde yanıt verir.
    }

    try {
      final Position netPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return _toFix(netPos);
    } catch (_) {}

    try {
      final Position lowPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 4),
        ),
      );
      return _toFix(lowPos);
    } catch (_) {}

    try {
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) return _toFix(last);
    } catch (error, stackTrace) {
      AppLog.error('Konum alınamadı', error: error, stackTrace: stackTrace);
    }
    throw AppException.timeout('Konum alınamadı.');
  }

  /// Konum açıkken yer değişimini (ör. >=350m) canlı izler.
  Stream<LocationFix> watchPosition({int distanceFilterMeters = 350}) async* {
    final LocationStatus status = await checkStatus();
    if (status != LocationStatus.granted) return;
    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      ),
    ).map(_toFix);
  }

  LocationFix _toFix(Position position) => LocationFix(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
    altitudeMeters: position.altitude,
    timestamp: position.timestamp,
  );

  /// Ayarlar sayfasından konum ayarlarını açmak için.
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  /// İki nokta arası mesafe (km).
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) => Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
}
