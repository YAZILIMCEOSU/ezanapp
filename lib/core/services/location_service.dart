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

  /// Konumun yaşı (bilinmiyorsa çok büyük kabul edilir).
  Duration get age {
    final DateTime? at = timestamp;
    if (at == null) return const Duration(days: 3650);
    final Duration diff = DateTime.now().difference(at);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Vakit hesabı için **taze** sayılır mı? (10 dakika)
  bool get isFresh => age < LocationService.freshWindow;

  /// Kıble ve vakit hesabı için kaba ama yeterli doğruluk sınırı (km).
  bool get isPreciseEnough => (accuracyMeters ?? 0) < 50000;

  /// İlçe eşleştirmesi için yeterince hassas mı? (2 km)
  ///
  /// Kaba (baz istasyonu) konum ilçe sınırında yanlış ilçeye düşebilir;
  /// yanlış ilçe ise Diyanet'in resmî vakitlerini 1–2 dakika kaydırır.
  bool get isDistrictAccurate => (accuracyMeters ?? 999999) <= 2000;

  @override
  String toString() =>
      'LocationFix(${latitude.toStringAsFixed(5)}, '
      '${longitude.toStringAsFixed(5)} ±${accuracyMeters?.round()} m)';
}

/// GPS üzerinden konum sağlayıcı.
///
/// **Hız politikası:** İlk açılışta kullanıcı vakitleri beklemesin diye
/// sırayla en hızlı yöntemler denenir:
///
/// 1. İşletim sisteminin **son bilinen konumu** (≈10 ms).
/// 2. **Düşük doğruluk** (Wi-Fi/baz istasyonu, ≈0,5–1 sn).
/// 3. Orta doğruluk (≈1–2 sn).
/// 4. Yüksek doğruluk (uydu, ≈3–6 sn) — yalnızca kalan süre kadar.
///
/// Toplam süre [defaultBudget] ile sınırlıdır; hiçbiri olmazsa eski de olsa
/// son bilinen konum döner. Hassas konum gerektiğinde [refineInBackground]
/// çağrılır ve sonuç geldiğinde ekran kendiliğinden güncellenir.
class LocationService {
  LocationService();

  /// Bu süreden yeni konum "taze" sayılır ve yeniden GPS beklemeden kullanılır.
  static const Duration freshWindow = Duration(minutes: 10);

  /// GPS için toplam süre bütçesi (kullanıcıyı bekletmemek için).
  static const Duration defaultBudget = Duration(seconds: 9);

  /// İzin durumu önbelleği: her konum isteğinde platform kanalı çağırmayı
  /// önler (ölçüm: `checkStatus + requestPermission` ≈ 40–120 ms).
  static const Duration _statusTtl = Duration(seconds: 20);

  LocationStatus? _cachedStatus;
  DateTime? _statusCheckedAt;

  void _rememberStatus(LocationStatus status) {
    _cachedStatus = status;
    _statusCheckedAt = DateTime.now();
  }

  /// Önbelleği atlayarak gerçek izin durumunu okur.
  Future<LocationStatus> checkStatus({bool force = false}) async {
    final DateTime? at = _statusCheckedAt;
    final LocationStatus? cached = _cachedStatus;
    if (!force && cached != null && at != null) {
      if (DateTime.now().difference(at) < _statusTtl) return cached;
    }
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _rememberStatus(LocationStatus.serviceDisabled);
        return LocationStatus.serviceDisabled;
      }
      final LocationPermission permission = await Geolocator.checkPermission();
      final LocationStatus status = _map(permission);
      _rememberStatus(status);
      return status;
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
      if (!serviceEnabled) {
        _rememberStatus(LocationStatus.serviceDisabled);
        return LocationStatus.serviceDisabled;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final LocationStatus status = _map(permission);
      _rememberStatus(status);
      return status;
    } catch (error, stackTrace) {
      AppLog.error(
        'Konum izni istenemedi',
        error: error,
        stackTrace: stackTrace,
      );
      return LocationStatus.denied;
    }
  }

  static LocationStatus _map(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationStatus.granted,
        LocationPermission.deniedForever => LocationStatus.deniedForever,
        _ => LocationStatus.denied,
      };

  /// Sistem önbelleğindeki son bilinen konumu beklemeden (≈10 ms) döndürür.
  Future<LocationFix?> getLastKnownFastPosition({
    bool requireFresh = false,
  }) async {
    try {
      final LocationStatus status = await checkStatus();
      if (status != LocationStatus.granted) return null;
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last == null) return null;
      final LocationFix fix = _toFix(last);
      if (requireFresh && !fix.isFresh) return null;
      return fix;
    } catch (_) {}
    return null;
  }

  /// Tek seferlik konum alır.
  ///
  /// [preferLastKnown] `true` ise 10 dakikadan yeni son bilinen konum anında
  /// döner (uygulama açılışında vakitler hemen görünür).
  Future<LocationFix> getCurrentPosition({
    Duration budget = defaultBudget,
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

    // 1) Taze son bilinen konum: hiç GPS beklemeden dön.
    if (preferLastKnown) {
      final LocationFix? last = await getLastKnownFastPosition(
        requireFresh: true,
      );
      if (last != null) return last;
    }

    final DateTime deadline = DateTime.now().add(budget);

    // 2) Kademeli doğruluk: hızlıdan hassasa.
    final List<({LocationAccuracy accuracy, Duration slice})> attempts =
        <({LocationAccuracy accuracy, Duration slice})>[
          (
            accuracy: LocationAccuracy.low,
            slice: Duration(milliseconds: budget.inMilliseconds ~/ 4),
          ),
          (
            accuracy: LocationAccuracy.medium,
            slice: Duration(milliseconds: budget.inMilliseconds * 35 ~/ 100),
          ),
          (
            accuracy: LocationAccuracy.high,
            slice: Duration(milliseconds: budget.inMilliseconds * 40 ~/ 100),
          ),
        ];

    for (final ({LocationAccuracy accuracy, Duration slice}) attempt
        in attempts) {
      final Duration remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) break;
      final Duration limit = attempt.slice < remaining
          ? attempt.slice
          : remaining;
      try {
        final Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: attempt.accuracy,
            timeLimit: limit,
          ),
        );
        return _toFix(position);
      } catch (_) {
        // Sonraki (daha hassas) denemeye geç.
      }
    }

    // 3) Hiçbiri olmadıysa eski de olsa son bilinen konum.
    final LocationFix? stale = await getLastKnownFastPosition();
    if (stale != null) {
      AppLog.warning(
        'Canlı konum alınamadı; son bilinen konum kullanıldı '
        '(${stale.age.inMinutes} dk önce)',
      );
      return stale;
    }
    throw const AppException(
      'Konum alınamadı. Açık alanda tekrar deneyin veya şehir seçin.',
    );
  }

  /// Arka planda yüksek doğruluklu taze konum ister.
  ///
  /// Kaba konumla hesaplanan vakitler ekranda kalırken bu çağrı tamamlanınca
  /// ilçe yeniden eşleştirilir; kullanıcı hiçbir şey beklemez.
  Future<LocationFix?> refineInBackground({
    Duration budget = const Duration(seconds: 12),
  }) async {
    final LocationStatus status = await checkStatus();
    if (status != LocationStatus.granted) return null;
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: budget,
        ),
      );
      return _toFix(position);
    } catch (_) {
      return null;
    }
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

  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) => Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
}
