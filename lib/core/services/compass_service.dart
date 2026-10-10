import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../utils/geo.dart';
import '../utils/logger.dart';

/// Pusula ölçümü.
///
/// [magneticHeading] sensörden gelen ham manyetik kuzey açısıdır (0-360°).
/// [declination] bulunulan konumdaki manyetik sapma açısıdır (Doğu +).
/// [heading] ise gerçek coğrafi kuzeye göre düzeltilmiş cihaz yönüdür ve
/// [qiblaDirection] (gerçek kuzeye göre Kâbe açısı) ile birebir aynı referans
/// sistemindedir.
class CompassReading {
  const CompassReading({
    required this.heading,
    required this.accuracy,
    this.magneticHeading,
    this.declination = 0,
    this.tilt = 0,
    this.roll = 0,
    this.fieldStrengthMicroTesla,
    this.stabilityDegrees = 0,
    this.qiblaDirection,
    this.differenceToQibla,
  });

  /// Gerçek kuzeye (veya sapma 0 ise manyetik kuzeye) göre yön (0-360°).
  final double heading;

  /// Sensörün ölçtüğü ham manyetik kuzey yönü (0-360°).
  final double? magneticHeading;

  /// Uygulanan manyetik sapma açısı (derece, Doğu +).
  final double declination;

  /// Tahmini hata payı (derece).
  final double accuracy;

  /// Telefonun öne/arkaya eğimi (derece).
  final double tilt;

  /// Telefonun yana yatması (derece).
  final double roll;

  /// Manyetik alan şiddeti (µT). Dünya'nın normal alanı ~25–65 µT aralığındadır.
  final double? fieldStrengthMicroTesla;

  /// Son ölçümlerin açısal kararsızlığı (standart sapma, derece).
  final double stabilityDegrees;

  /// Kıble yönü (gerçek kuzeyden saat yönünde, 0-360°).
  final double? qiblaDirection;

  /// Kıbleye göre sapma (-180..180°).
  final double? differenceToQibla;

  /// Sensör değerleri sayısal olarak geçerli mi?
  bool get isValid =>
      heading.isFinite &&
      heading >= 0 &&
      heading <= 360 &&
      accuracy.isFinite &&
      accuracy >= 0 &&
      tilt.isFinite &&
      roll.isFinite;

  bool get isAligned =>
      differenceToQibla != null && differenceToQibla!.abs() <= 5;

  bool get isClose =>
      differenceToQibla != null && differenceToQibla!.abs() <= 12;

  /// Manyetik parazit var mı? (normal dışı µT alanı veya yüksek açısal sıçrama)
  bool get hasMagneticInterference =>
      (fieldStrengthMicroTesla != null &&
          fieldStrengthMicroTesla!.isFinite &&
          (fieldStrengthMicroTesla! < 22.0 ||
              fieldStrengthMicroTesla! > 68.0)) ||
      stabilityDegrees > 22.0;

  /// Telefon aşırı eğik mi tutuluyor?
  bool get isTilted => tilt.abs() > 45 || roll.abs() > 45;

  /// Kalibrasyon veya tutuş düzeltmesi gerekiyor mu?
  bool get needsCalibration =>
      accuracy > 20 || hasMagneticInterference || isTilted;

  /// Kullanıcıya gösterilecek anlaşılır kalibrasyon/parazit yönlendirmesi.
  String get calibrationMessage {
    if (hasMagneticInterference) {
      return 'Manyetik parazit algılandı: metal masa, mıknatıslı kılıf veya '
          'elektronik cihazlardan uzaklaşın ve telefonu havada 8 çizer gibi hareket ettirin.';
    }
    if (isTilted) {
      return 'Telefon eğik tutuluyor: doğru pusula ölçümü için telefonu '
          'yere paralel (düz) konuma getirin.';
    }
    return 'Pusula kalibrasyonu gerekiyor: telefonu havada birkaç kez 8 çizer '
        'gibi hareket ettirin ve metal eşyalardan uzaklaşın.';
  }

  /// Kıble yönü ve isteğe bağlı manyetik sapma ile güncellenmiş ölçüm döner.
  CompassReading withQibla(double qiblaDirection, {double? declination}) {
    final double rawMagnetic = magneticHeading ?? heading;
    final double appliedDeclination = declination ?? this.declination;
    final double trueHeading = GeoUtils.normalizeDegrees(
      rawMagnetic + appliedDeclination,
    );
    final double difference = GeoUtils.normalizeSigned(
      qiblaDirection - trueHeading,
    );
    return CompassReading(
      heading: trueHeading,
      magneticHeading: rawMagnetic,
      declination: appliedDeclination,
      accuracy: accuracy,
      tilt: tilt,
      roll: roll,
      fieldStrengthMicroTesla: fieldStrengthMicroTesla,
      stabilityDegrees: stabilityDegrees,
      qiblaDirection: qiblaDirection,
      differenceToQibla: difference,
    );
  }
}

/// Cihaz sensörlerinden pusula verisi okur.
///
/// Android tarafında yerel kanal (`ezanai/sensors`) üzerinden çalışır;
/// sensör yoksa `isSupported` false döner ve arayüz manyetik olmayan
/// (derece/harita tabanlı) kıble moduna geçer.
class CompassService {
  CompassService({EventChannel? channel, MethodChannel? methodChannel})
    : _channel = channel ?? const EventChannel('ezanai/sensors'),
      _methods = methodChannel ?? const MethodChannel('ezanai/sensors/methods');

  final EventChannel _channel;
  final MethodChannel _methods;

  StreamSubscription<Object?>? _subscription;
  final StreamController<CompassReading?> _controller =
      StreamController<CompassReading?>.broadcast();
  final List<double> _recentHeadings = <double>[];

  Stream<CompassReading?> get readings => _controller.stream;

  bool _isSupported = true;
  bool get isSupported => _isSupported;

  bool _started = false;
  double? _qiblaDirection;
  double _declination = 0;

  /// Ham sensör paketinin geçerli sayısal değerler içerdiğini doğrular.
  static bool isValidSensorPayload(Map<Object?, Object?> map) {
    final Object? rawHeading = map['heading'];
    final Object? rawAccuracy = map['accuracy'];
    if (rawHeading is! num || rawAccuracy is! num) return false;
    final double heading = rawHeading.toDouble();
    final double accuracy = rawAccuracy.toDouble();
    if (!heading.isFinite || !accuracy.isFinite || accuracy < 0) return false;
    final Object? rawTilt = map['tilt'];
    final Object? rawRoll = map['roll'];
    if (rawTilt is num && !rawTilt.toDouble().isFinite) return false;
    if (rawRoll is num && !rawRoll.toDouble().isFinite) return false;
    return true;
  }

  /// Sensör var mı kontrolü (izin gerekmez).
  Future<bool> checkSupport() async {
    try {
      final bool? has = await _methods.invokeMethod<bool>('hasCompass');
      _isSupported = has ?? false;
    } on PlatformException catch (error) {
      AppLog.warning('Pusula desteği sorgulanamadı: ${error.message}');
      _isSupported = false;
    } on MissingPluginException {
      // Testlerde/emülatörde kanal bulunmayabilir.
      _isSupported = false;
    }
    return _isSupported;
  }

  void start({double? qiblaDirection, double declination = 0}) {
    _qiblaDirection = qiblaDirection ?? _qiblaDirection;
    _declination = declination;
    if (_started) return;
    _started = true;
    try {
      _subscription = _channel.receiveBroadcastStream().listen(
        (Object? event) {
          if (event is Map) {
            final Map<Object?, Object?> map = event;
            if (!isValidSensorPayload(map)) {
              if (!_controller.isClosed) _controller.add(null);
              return;
            }
            final double rawHeading = GeoUtils.normalizeDegrees(
              (map['heading'] as num).toDouble(),
            );
            final double accuracy = (map['accuracy'] as num).toDouble();
            final double tilt = (map['tilt'] as num?)?.toDouble() ?? 0;
            final double roll = (map['roll'] as num?)?.toDouble() ?? 0;
            final double? fieldStrength = (map['fieldStrength'] as num?)
                ?.toDouble();

            _recentHeadings.add(rawHeading);
            if (_recentHeadings.length > 8) {
              _recentHeadings.removeAt(0);
            }
            final double stability = _recentHeadings.length >= 4
                ? headingStability(_recentHeadings)
                : 0;

            final double trueHeading = GeoUtils.normalizeDegrees(
              rawHeading + _declination,
            );

            CompassReading reading = CompassReading(
              heading: trueHeading,
              magneticHeading: rawHeading,
              declination: _declination,
              accuracy: accuracy,
              tilt: tilt,
              roll: roll,
              fieldStrengthMicroTesla:
                  fieldStrength != null && fieldStrength.isFinite
                  ? fieldStrength
                  : null,
              stabilityDegrees: stability,
            );
            if (_qiblaDirection != null) {
              reading = reading.withQibla(
                _qiblaDirection!,
                declination: _declination,
              );
            }
            if (!_controller.isClosed) _controller.add(reading);
          }
        },
        onError: (Object error) {
          AppLog.warning('Pusula akışı hata verdi', error: error);
          if (!_controller.isClosed) _controller.add(null);
        },
        cancelOnError: false,
      );
    } on PlatformException catch (error) {
      AppLog.warning('Pusula başlatılamadı: ${error.message}');
      _isSupported = false;
    } on MissingPluginException {
      _isSupported = false;
    }
  }

  Future<void> stop() async {
    _started = false;
    _recentHeadings.clear();
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  /// Kalibrasyon yardımı: telefonu 8 çizer gibi hareket ettirme önerisi için
  /// ölçüm kararlılığını (dairesel standart sapma, derece) değerlendirir.
  static double headingStability(List<double> recentHeadings) {
    if (recentHeadings.length < 3) return 180;
    double sumSin = 0;
    double sumCos = 0;
    for (final double h in recentHeadings) {
      final double rad = h * math.pi / 180.0;
      sumSin += math.sin(rad);
      sumCos += math.cos(rad);
    }
    final double mean = GeoUtils.normalizeDegrees(
      math.atan2(
            sumSin / recentHeadings.length,
            sumCos / recentHeadings.length,
          ) *
          180.0 /
          math.pi,
    );
    final double variance =
        recentHeadings
            .map(
              (double h) =>
                  math.pow(GeoUtils.normalizeSigned(h - mean), 2).toDouble(),
            )
            .reduce((double a, double b) => a + b) /
        recentHeadings.length;
    return math.sqrt(variance);
  }
}
