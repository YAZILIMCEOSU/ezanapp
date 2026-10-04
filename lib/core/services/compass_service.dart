import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../utils/geo.dart';
import '../utils/logger.dart';

/// Pusula ölçümü.
class CompassReading {
  const CompassReading({
    required this.heading,
    required this.accuracy,
    this.tilt = 0,
    this.roll = 0,
    this.qiblaDirection,
    this.differenceToQibla,
  });

  /// Manyetik kuzeye göre yön (0-360).
  final double heading;

  /// Tahmini hata payı (derece).
  final double accuracy;

  /// Telefonun öne/arkaya eğimi.
  final double tilt;

  /// Telefonun yana yatması.
  final double roll;

  /// Kıble yönü (kuzeyden saat yönünde).
  final double? qiblaDirection;

  /// Kıbleye göre sapma (-180..180).
  final double? differenceToQibla;

  bool get isAligned =>
      differenceToQibla != null && differenceToQibla!.abs() <= 5;

  bool get isClose =>
      differenceToQibla != null && differenceToQibla!.abs() <= 12;

  /// Kalibrasyon gerekiyor mu? (düşük doğruluk veya aşırı eğim)
  bool get needsCalibration => accuracy > 20 || tilt.abs() > 45;

  CompassReading withQibla(double qiblaDirection) {
    final double difference = GeoUtils.normalizeSigned(
      qiblaDirection - heading,
    );
    return CompassReading(
      heading: heading,
      accuracy: accuracy,
      tilt: tilt,
      roll: roll,
      qiblaDirection: qiblaDirection,
      differenceToQibla: difference,
    );
  }
}

/// Cihaz sensörlerinden pusula verisi okur.
///
/// Android tarafında yerel kanal (`ezanai/sensors`) üzerinden çalışır;
/// sensör yoksa `isSupported` false döner ve arayüz manyetik olmayan
/// (kullanıcı döndürmeli) kıble moduna geçer.
class CompassService {
  CompassService({EventChannel? channel, MethodChannel? methodChannel})
    : _channel = channel ?? const EventChannel('ezanai/sensors'),
      _methods = methodChannel ?? const MethodChannel('ezanai/sensors/methods');

  final EventChannel _channel;
  final MethodChannel _methods;

  StreamSubscription<Object?>? _subscription;
  final StreamController<CompassReading?> _controller =
      StreamController<CompassReading?>.broadcast();

  Stream<CompassReading?> get readings => _controller.stream;

  bool _isSupported = true;
  bool get isSupported => _isSupported;

  bool _started = false;

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

  void start({double? qiblaDirection}) {
    if (_started) return;
    _started = true;
    try {
      _subscription = _channel.receiveBroadcastStream().listen(
        (Object? event) {
          if (event is Map) {
            final Map<Object?, Object?> map = event;
            final double heading = (map['heading'] as num?)?.toDouble() ?? 0;
            final double accuracy = (map['accuracy'] as num?)?.toDouble() ?? 0;
            final double tilt = (map['tilt'] as num?)?.toDouble() ?? 0;
            final double roll = (map['roll'] as num?)?.toDouble() ?? 0;
            CompassReading reading = CompassReading(
              heading: GeoUtils.normalizeDegrees(heading),
              accuracy: accuracy,
              tilt: tilt,
              roll: roll,
            );
            if (qiblaDirection != null) {
              reading = reading.withQibla(qiblaDirection);
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
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  /// Kalibrasyon yardımı: telefonu 8 çizer gibi hareket ettirme önerisi için
  /// ölçüm kararlılığını değerlendirir.
  static double headingStability(List<double> recentHeadings) {
    if (recentHeadings.length < 3) return 180;
    final double mean =
        recentHeadings.reduce((double a, double b) => a + b) /
        recentHeadings.length;
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
