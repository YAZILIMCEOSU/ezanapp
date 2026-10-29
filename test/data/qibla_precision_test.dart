import 'dart:math' as math;

import 'package:ezanai/core/services/compass_service.dart';
import 'package:ezanai/core/utils/geo.dart';
import 'package:ezanai/core/utils/qibla_math.dart';
import 'package:ezanai/core/utils/sun_position.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Kıble doğrulama — 2. tur: astronomi (güneş) referansı.**
///
/// Bu dosya, Kıble açısını ve pusula matematiğini **bağımsız bir kaynakla**
/// (güneşin gökyüzündeki gerçek konumu) karşılaştırır. Referans değerler
/// `ephem` (Astronomical Algorithms, Meeus) kütüphanesiyle hesaplanmıştır;
/// yani test, uygulama kodu kendi kendini onaylamıyor, dış kaynakla
/// karşılaştırıyor.
///
/// Kapsam:
/// 1. Kâbe yönü (great-circle) — 5 şehir, ephem ile aynı sonuç.
/// 2. Güneş konumu (azimut/yükseklik) — ephem ile ±0,1° içinde.
/// 3. **Kıble günü** — güneş ile Kâbe aynı hizada; fark < 0,2° olmalı.
/// 4. Tutuş (pose) mantığı — dik tutuş artık hata sayılmaz.
void main() {
  const double kaabaLat = 21.4224779;
  const double kaabaLon = 39.8251832;

  /// Bağımsız referans: `ephem` ile üretilen kıble açıları.
  /// (ad, enlem, boylam, beklenen açı)
  const List<(String, double, double, double)> qiblaReference =
      <(String, double, double, double)>[
        ('Bağcılar', 41.0339, 28.8567, 151.3708),
        ('İstanbul', 41.0082, 28.9784, 151.6230),
        ('Ankara', 39.9334, 32.8597, 160.1710),
        ('New York', 40.7128, -74.0060, 58.4820),
        ('Sidney', -33.8688, 151.2093, 277.4990),
      ];

  group('1. Kâbe yönü (great-circle) — ephem referansı', () {
    for (final (String name, double lat, double lon, double expected)
        in qiblaReference) {
      test('$name kıble açısı ±0,01° içinde', () {
        final double actual = GeoUtils.qiblaBearing(lat, lon);
        expect(
          GeoUtils.normalizeSigned(actual - expected).abs(),
          lessThan(0.01),
          reason: '$name için beklenen $expected°, bulunan $actual°',
        );
      });
    }

    test('Kâbe tam karşısında açı tanımsız ama sonlu kalır', () {
      final double atKaaba = GeoUtils.qiblaBearing(kaabaLat, kaabaLon);
      expect(atKaaba.isFinite, isTrue);
    });

    test('Kutup noktalarında sonlu değer döner (çökme yok)', () {
      expect(GeoUtils.qiblaBearing(90, 0).isFinite, isTrue);
      expect(GeoUtils.qiblaBearing(-90, 0).isFinite, isTrue);
    });
  });

  group('2. Güneş konumu — ephem referansı', () {
    test('İstanbul 21 Haziran 2026 12:00 (TRT)', () {
      // ephem: azimut 136.82°, yükseklik 67.67°
      final SunCoordinates sun = SunPosition.at(
        utc: DateTime.utc(2026, 6, 21, 9),
        latitude: 41.0082,
        longitude: 28.9784,
      );
      expect(sun.azimuth, closeTo(136.82, 0.05));
      expect(sun.altitude, closeTo(67.67, 0.05));
    });

    test('21 Aralık 2026 12:00 — kış gündönümü, düşük güneş', () {
      final SunCoordinates sun = SunPosition.at(
        utc: DateTime.utc(2026, 12, 21, 9),
        latitude: 41.0082,
        longitude: 28.9784,
      );
      // ephem: azimut 164.413°, yükseklik 23.995° (kışın güneş alçak)
      expect(sun.azimuth, closeTo(164.413, 0.1));
      expect(sun.altitude, closeTo(23.995, 0.1));
      expect(sun.isDaylight, isTrue);
    });

    test('Gece yarısı güneş ufkun altındadır', () {
      // ephem: yükseklik -20.316° (yaz gecesi astronomik karanlık)
      final SunCoordinates sun = SunPosition.at(
        utc: DateTime.utc(2026, 6, 21, 0),
        latitude: 41.0082,
        longitude: 28.9784,
      );
      expect(sun.altitude, closeTo(-20.316, 0.1));
      expect(sun.altitude, lessThan(0));
      expect(sun.isDaylight, isFalse);
    });

    test('Güney yarımkürede yön doğru (Sidney öğlen güneşi kuzeyde)', () {
      final SunCoordinates sun = SunPosition.at(
        utc: DateTime.utc(2026, 6, 21, 2),
        latitude: -33.8688,
        longitude: 151.2093,
      );
      // Haziran: güney yarımkürede kış, güneş kuzeyde (ephem: 359.152°).
      expect(sun.azimuth, closeTo(359.152, 1.0));
      expect(sun.altitude, closeTo(32.711, 0.1));
    });

    test('Julian günü bilinen değerle uyumlu (J2000)', () {
      expect(
        SunPosition.julianDay(DateTime.utc(2000, 1, 1, 12)),
        closeTo(2451545.0, 1e-6),
      );
    });
  });

  group('3. Kıble Günü — güneş Kâbe doğrultusunda', () {
    test('28 Mayıs 2026: İstanbul için fark < 0,2°', () {
      final QiblaSunAlignment? a = QiblaSunCheck.bestOn(
        day: DateTime(2026, 5, 28),
        latitude: 41.0082,
        longitude: 28.9784,
      );
      expect(a, isNotNull);
      expect(a!.differenceDegrees, lessThan(0.2));
      expect(a.isReliable, isTrue);
      // ephem: 09:17:58 UTC = 12:17 TRT
      expect(a.time.hour, 12);
      expect(a.time.minute, inInclusiveRange(14, 21));
      expect(a.windowLabel, contains('–'));
    });

    test('15 Temmuz 2026: Ankara ve Bağcılar için fark < 0,2°', () {
      final QiblaSunAlignment? ankara = QiblaSunCheck.bestOn(
        day: DateTime(2026, 7, 15),
        latitude: 39.9334,
        longitude: 32.8597,
      );
      final QiblaSunAlignment? bagcilar = QiblaSunCheck.bestOn(
        day: DateTime(2026, 7, 15),
        latitude: 41.0339,
        longitude: 28.8567,
      );
      expect(ankara, isNotNull);
      expect(bagcilar, isNotNull);
      expect(ankara!.differenceDegrees, lessThan(0.2));
      expect(bagcilar!.differenceDegrees, lessThan(0.2));
      // ephem transit (Kâbe): 09:26:42 UTC = 12:26 TRT
      expect(ankara.time.hour, 12);
      expect(ankara.time.minute, inInclusiveRange(23, 30));
    });

    test('Önümüzdeki uygun gün 8° içinde bulunur ve hızlıdır', () {
      final Stopwatch sw = Stopwatch()..start();
      final QiblaSunAlignment? best = QiblaSunCheck.bestUpcoming(
        from: DateTime(2026, 3, 1),
        latitude: 41.0082,
        longitude: 28.9784,
      );
      sw.stop();
      expect(best, isNotNull);
      expect(best!.differenceDegrees, lessThan(0.5));
      expect(best.isReliable, isTrue);
      // Arama yılda iki kez eşleşir; ilk uygun gün mayıs sonudur.
      expect(best.time.month, inInclusiveRange(5, 8));
      // Performans: UI iş parçacığını kilitlemez.
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });

    test('Kıble günü gölge yönü Kıble ile aynı (180° fark)', () {
      final QiblaSunAlignment? a = QiblaSunCheck.bestOn(
        day: DateTime(2026, 5, 28),
        latitude: 41.0082,
        longitude: 28.9784,
      );
      expect(a, isNotNull);
      final double shadowDiff = GeoUtils.normalizeSigned(
        a!.shadowBearing - a.qiblaDegrees,
      ).abs();
      // Güneş Kıble yönündeyse gölge tam tersidir.
      expect(shadowDiff, greaterThan(179.0));
    });

    test('Güneşin ufkun üzerinde olduğu her yerde fark < 0,3°', () {
      // O an güneş ufkun üzerindeyse Kıble Günü **konumdan bağımsız** çalışır.
      const List<(String, double, double)> observable =
          <(String, double, double)>[
            ('İstanbul', 41.0082, 28.9784),
            ('Bağcılar', 41.0339, 28.8567),
            ('Ankara', 39.9334, 32.8597),
            ('Londra', 51.5074, -0.1278),
            ('Berlin', 52.52, 13.405),
            ('Paris', 48.8566, 2.3522),
          ];
      for (final (String name, double lat, double lon) in observable) {
        final QiblaSunAlignment? a = QiblaSunCheck.bestOn(
          day: DateTime(2026, 5, 28),
          latitude: lat,
          longitude: lon,
        );
        expect(a, isNotNull, reason: name);
        expect(a!.differenceDegrees, lessThan(0.3), reason: name);
      }
    });

    test('Güneş ufkun altındaysa yöntem uygulanamaz (dürüst davranış)', () {
      // New York'ta o an güneş batmıştır; uygulama "yaklaşmıyor" demeli,
      // yanlış bir saat önermemeli.
      final QiblaSunAlignment? ny = QiblaSunCheck.bestOn(
        day: DateTime(2026, 5, 28),
        latitude: 40.7128,
        longitude: -74.0060,
        toleranceDegrees: 8,
      );
      expect(ny == null || ny.differenceDegrees > 1.0, isTrue);

      final QiblaSunAlignment? sydney = QiblaSunCheck.bestOn(
        day: DateTime(2026, 5, 28),
        latitude: -33.8688,
        longitude: 151.2093,
        toleranceDegrees: 8,
      );
      expect(sydney == null || sydney.differenceDegrees > 1.0, isTrue);
    });
  });

  group('4. Tutuş (pose) ve hassasiyet mantığı', () {
    test('Dik tutuş geçerli kullanımdır, kalibrasyon istemez', () {
      const CompassReading upright = CompassReading(
        heading: 151,
        accuracy: 4,
        tilt: 78,
        pose: 'upright',
        poseWeight: 0.9,
      );
      expect(upright.isUprightPose, isTrue);
      expect(upright.isTilted, isTrue);
      expect(upright.needsCalibration, isFalse);
    });

    test('Geçiş açısı (±45°) uyarı üretir', () {
      const CompassReading blend = CompassReading(
        heading: 151,
        accuracy: 4,
        tilt: 45,
        pose: 'blend',
        poseWeight: 0.5,
      );
      expect(blend.isBlendPose, isTrue);
      expect(blend.needsCalibration, isTrue);
      expect(blend.calibrationMessage, contains('eğik'));
    });

    test('Yatay sağlıklı ölçümde uyarı yok', () {
      const CompassReading flat = CompassReading(
        heading: 151,
        accuracy: 4,
        tilt: 4,
      );
      expect(flat.needsCalibration, isFalse);
      expect(flat.pose, 'flat');
    });

    test('withQibla poz bilgisini kaybetmez', () {
      const CompassReading reading = CompassReading(
        heading: 10,
        accuracy: 5,
        pose: 'upright',
        poseWeight: 0.8,
        magneticHeading: 8,
      );
      final CompassReading withQibla = reading.withQibla(151.6);
      expect(withQibla.pose, 'upright');
      expect(withQibla.poseWeight, 0.8);
      expect(withQibla.qiblaDirection, 151.6);
    });

    test('Kadran dönüşü ve rozet açısı birbirini tutar', () {
      const double heading = 37.0;
      const double qibla = 151.4;
      // Kadran saat yönünün tersine döner (kuzey doğru tarafta görünsün).
      expect(QiblaMath.dialRotation(heading: heading), -heading);
      // Rozet, telefondan Kâbe yönüne olan fark kadar döner.
      expect(
        QiblaMath.badgeScreenAngle(qibla: qibla, heading: heading),
        closeTo(114.4, 1e-6),
      );
      // Hizalandığında fark 0, sağa/sola yönlendirme doğru.
      expect(QiblaMath.isAligned(qibla: qibla, heading: qibla), isTrue);
      expect(QiblaMath.turnDirection(qibla: qibla, heading: 100), 1);
      expect(QiblaMath.turnDirection(qibla: qibla, heading: 200), -1);
      expect(
        QiblaMath.guidanceText(qibla: qibla, heading: qibla),
        contains('Kâbe yönündesiniz'),
      );
    });
  });

  group('5. Sayısal dayanıklılık', () {
    test('Aşırı enlem/boylam değerleri NaN üretmez', () {
      for (final (double lat, double lon) in <(double, double)>[
        (0, 0),
        (89.9, 179.9),
        (-89.9, -179.9),
        (21.4224779, 39.8251832),
      ]) {
        final SunCoordinates sun = SunPosition.at(
          utc: DateTime.utc(2026, 5, 28, 9),
          latitude: lat,
          longitude: lon,
        );
        expect(sun.azimuth.isNaN, isFalse);
        expect(sun.altitude.isNaN, isFalse);
        expect(sun.azimuth, inInclusiveRange(0, 360));
        expect(sun.altitude, inInclusiveRange(-90, 90));
      }
    });

    test('Azimut her zaman 0–360 aralığında normalize', () {
      for (final DateTime t in <DateTime>[
        DateTime.utc(2026, 1, 1, 0),
        DateTime.utc(2026, 3, 20, 6),
        DateTime.utc(2026, 9, 23, 18),
        DateTime.utc(2026, 12, 31, 23, 59),
      ]) {
        final SunCoordinates sun = SunPosition.at(
          utc: t,
          latitude: 41,
          longitude: 29,
        );
        expect(sun.azimuth, greaterThanOrEqualTo(0));
        expect(sun.azimuth, lessThan(360));
      }
    });

    test('Kıble açısı ile güneş azimutu arasındaki fark simetriktir', () {
      const double a = 10;
      const double b = 350;
      expect(GeoUtils.normalizeSigned(a - b), closeTo(20, 1e-9));
      expect(
        math.cos(GeoUtils.normalizeSigned(b - a) * math.pi / 180),
        lessThan(1),
      );
    });
  });
}
