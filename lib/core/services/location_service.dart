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

  /// Tek seferlik konum alır. Önce son bilinen konum denenir (hızlı açılış).
  Future<LocationFix> getCurrentPosition({
    Duration timeout = const Duration(seconds: 20),
    bool preferLastKnown = true,
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
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null &&
          last.timestamp.difference(DateTime.now()).abs() <
              const Duration(hours: 12)) {
        return _toFix(last);
      }
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        ),
      );
      return _toFix(position);
    } on TimeoutException {
      AppLog.warning('Konum alma zaman aşımına uğradı');
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) return _toFix(last);
      throw AppException.timeout('Konum alınamadı.');
    } catch (error, stackTrace) {
      AppLog.error('Konum alınamadı', error: error, stackTrace: stackTrace);
      throw AppException.network('Konum alınamadı.');
    }
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
