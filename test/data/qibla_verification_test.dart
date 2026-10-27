import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:ezanai/core/services/compass_service.dart';
import 'package:ezanai/core/utils/geo.dart';
import 'package:ezanai/core/utils/qibla_math.dart';
import 'package:ezanai/core/utils/wmm.dart';

/// **Kıble Doğrulama Testi — 4 aşamalı kontrol.**
///
/// Bu dosya, Kıble Pusulası'nın "0 hata" iddiasını dört ayrı katmanda
/// doğrular. Referans değerler NOAA/NCEI **WMM-2025** modelinin resmî
/// katsayılarıyla bağımsız bir uygulamada (pygeomag) hesaplanmıştır.
///
/// 1. **Matematik katmanı:** Kâbe kerterizi ve WMM-2025 manyetik sapması.
/// 2. **Sensör katmanı:** Ham manyetik açı → gerçek kuzey → Kıble farkı
///    zincirinin işaret ve sarmal (0/360) davranışı.
/// 3. **Arayüz katmanı:** e-Diyanet kadran geometrisi (sabit 12 yönü oku,
///    `qibla - heading` rozet açısı, dönüş yönü, hizalama eşiği).
/// 4. **Uçtan uca senaryo:** Bağcılar, İstanbul, Londra, Sidney ve New York
///    için telefonun farklı açılarda tutulduğu gerçek kullanım simülasyonu.
void main() {
  group('1) Matematik katmanı — WMM-2025 manyetik sapması', () {
    // Değerler: pygeomag + resmî WMM_2025.COF, 2026.8 ondalık yılı.
    const List<(String, double, double, double)> wmmReferences =
        <(String, double, double, double)>[
          ('İstanbul', 41.0082, 28.9784, 6.079),
          ('Bağcılar', 41.0339, 28.8567, 6.073),
          ('Küçükçekmece', 41.0002, 28.7800, 6.060),
          ('Ankara', 39.9334, 32.8597, 6.174),
          ('İzmir', 38.4237, 27.1428, 5.525),
          ('Trabzon', 41.0027, 39.7168, 6.703),
          ('Van', 38.4891, 43.4089, 6.058),
          ('Mekke', 21.4224779, 39.8251832, 3.502),
          ('Londra', 51.5074, -0.1278, 1.213),
          ('New York', 40.7128, -74.0060, -12.462),
          ('Sidney', -33.8688, 151.2093, 12.827),
          ('Tokyo', 35.6762, 139.6503, -7.943),
          ('Jakarta', -6.2088, 106.8456, 0.650),
          ('Dubai', 25.2048, 55.2708, 2.239),
          ('Kuala Lumpur', 3.1390, 101.6869, 0.032),
          ('Paris', 48.8566, 2.3522, 2.089),
        ];

    test('WMM-2025 modeli 16 şehirde NOAA referansıyla eşleşir', () {
      for (final (String name, double lat, double lon, double expected)
          in wmmReferences) {
        final double got = Wmm2025.declinationAtYear(lat, lon, 2026.8);
        expect(
          got,
          closeTo(expected, 0.15),
          reason: '$name sapması referansla uyuşmuyor (beklenen $expected°)',
        );
      }
    });

    test('sapma işareti ve büyüklüğü jeofiziksel olarak tutarlı', () {
      // Türkiye'de doğu sapması ~+6°, Avustralya'da ~+13°, ABD'de batı (-).
      expect(Wmm2025.declinationAtYear(41.0339, 28.8567, 2026.8), inInclusiveRange(5.5, 6.6));
      expect(Wmm2025.declinationAtYear(-33.8688, 151.2093, 2026.8), inInclusiveRange(12.0, 13.6));
      expect(Wmm2025.declinationAtYear(40.7128, -74.0060, 2026.8), inInclusiveRange(-13.3, -11.6));
      // Türkiye genelinde tüm il merkezleri 4°–8° aralığında kalmalı.
      const List<List<double>> turkey = <List<double>>[
        <double>[41.0082, 28.9784],
        <double>[39.9334, 32.8597],
        <double>[38.4237, 27.1428],
        <double>[37.0000, 35.3213],
        <double>[41.0027, 39.7168],
        <double>[38.4891, 43.4089],
        <double>[36.8969, 30.7133],
        <double>[40.1885, 29.0610],
      ];
      for (final List<double> p in turkey) {
        final double decl = GeoUtils.magneticDeclination(p[0], p[1]);
        expect(decl, inInclusiveRange(4.0, 8.0));
      }
    });

    test('model geçerlilik aralığı dışında çökmek yerine sabitlenir', () {
      expect(Wmm2025.declinationAtYear(41.0, 29.0, 2400.0), isFinite);
      expect(Wmm2025.declinationAtYear(41.0, 29.0, 1980.0), isFinite);
      expect(Wmm2025.declinationAtYear(double.nan, 29.0, 2026.0), 0.0);
      // Kutuplarda (gimbal lock) NaN üretmemeli.
      expect(Wmm2025.declinationAtYear(89.9, 0.0, 2026.0), isFinite);
      expect(Wmm2025.declinationAtYear(-89.9, 180.0, 2026.0), isFinite);
    });

    test('ondalık yıl çevrimi doğru', () {
      expect(Wmm2025.decimalYear(DateTime(2025, 1, 1)), closeTo(2025.0, 0.01));
      final double mid = Wmm2025.decimalYear(DateTime(2025, 7, 2, 12));
      expect(mid, closeTo(2025.5, 0.02));
      expect(Wmm2025.modelId, contains('WMM-2025'));
    });
  });

  group('2) Kâbe kerterizi (qibla bearing) referansları', () {
    test('dünya şehirleri için bilinen Kıble açıları', () {
      // Kaynak: büyük daire (initial bearing) formülü, Kâbe 21.4225/39.8252.
      const List<(String, double, double, double)> refs =
          <(String, double, double, double)>[
            ('Bağcılar', 41.0339, 28.8567, 151.37),
            ('İstanbul', 41.0082, 28.9784, 151.62),
            ('Londra', 51.5074, -0.1278, 118.99),
            ('New York', 40.7128, -74.0060, 58.48),
            ('Jakarta', -6.2088, 106.8456, 295.15),
            ('Paris', 48.8566, 2.3522, 119.16),
            ('Sidney', -33.8688, 151.2093, 277.50),
            ('Tokyo', 35.6762, 139.6503, 293.02),
          ];
      for (final (String name, double lat, double lon, double expected)
          in refs) {
        expect(
          GeoUtils.qiblaBearing(lat, lon),
          closeTo(expected, 0.35),
          reason: '$name Kıble açısı referansla uyuşmuyor',
        );
      }
    });

    test('Kâbe üzerinde açı 0° (kuzeye) döner, antipodda tanımsız değil', () {
      final double atKaaba = GeoUtils.qiblaBearing(21.4224779, 39.8251832);
      expect(GeoUtils.normalizeSigned(atKaaba), closeTo(0.0, 0.01));
      expect(GeoUtils.qiblaBearing(-21.4224779, -140.1748168), isFinite);
    });

    test('dijital pusula açısı gerçek kuzey açısıyla birebir aynıdır', () {
      for (final List<double> p in <List<double>>[
        <double>[41.0339, 28.8567],
        <double>[41.0082, 28.9784],
        <double>[51.5074, -0.1278],
        <double>[-33.8688, 151.2093],
      ]) {
        expect(
          GeoUtils.compassQiblaBearing(p[0], p[1]),
          closeTo(GeoUtils.qiblaBearing(p[0], p[1]), 1e-9),
        );
      }
    });
  });

  group('3) Sensör katmanı — manyetik → gerçek kuzey zinciri', () {
    test('manyetik sapma gerçek kuzeye eklenir (Bağcılar)', () {
      const double lat = 41.0339;
      const double lon = 28.8567;
      final double qibla = GeoUtils.qiblaBearing(lat, lon);
      final double decl = GeoUtils.magneticDeclination(lat, lon);
      final double magneticQibla = GeoUtils.normalizeDegrees(qibla - decl);

      final CompassReading reading = CompassReading(
        heading: magneticQibla,
        magneticHeading: magneticQibla,
        accuracy: 3.0,
      ).withQibla(qibla, declination: decl);

      expect(reading.heading, closeTo(qibla, 0.001));
      expect(reading.differenceToQibla, closeTo(0.0, 0.001));
      expect(reading.isAligned, isTrue);
    });

    test('0/360 sarmalaması doğru çalışır (batıya dönük kullanıcı)', () {
      // Gerçek kuzeye göre 358°'ye bakan kullanıcı, Kıble 2° iken 4° sağa dönmeli.
      final CompassReading r = const CompassReading(
        heading: 358,
        magneticHeading: 358,
        accuracy: 2,
      ).withQibla(2, declination: 0);
      expect(r.differenceToQibla, closeTo(4.0, 1e-9));
      expect(GeoUtils.normalizeSigned(-10), closeTo(-10, 1e-9));
      expect(GeoUtils.normalizeDegrees(-10), closeTo(350, 1e-9));
    });

    test('withQibla iki kez uygulansa da sonucu bozmaz (çift düzeltme yok)', () {
      const double qibla = 151.37;
      const double decl = 6.073;
      const CompassReading raw = CompassReading(
        heading: qibla - decl,
        magneticHeading: qibla - decl,
        accuracy: 3,
      );
      final CompassReading once = raw.withQibla(qibla, declination: decl);
      final CompassReading twice = once.withQibla(qibla, declination: decl);
      expect(twice.heading, closeTo(once.heading, 1e-9));
      expect(twice.differenceToQibla, closeTo(once.differenceToQibla!, 1e-9));
    });

    test('fark -180..180 aralığında ve en kısa yolu gösterir', () {
      for (int heading = 0; heading < 360; heading += 5) {
        final CompassReading r = CompassReading(
          heading: heading.toDouble(),
          magneticHeading: heading.toDouble(),
          accuracy: 3,
        ).withQibla(151.37, declination: 0);
        expect(r.differenceToQibla!.abs(), lessThanOrEqualTo(180.0));
        expect(
          GeoUtils.normalizeDegrees(heading.toDouble() + r.differenceToQibla!),
          closeTo(151.37, 1e-6),
        );
      }
    });

    test('hizalama ve yakınlık eşikleri doğru', () {
      CompassReading at(double diff) => const CompassReading(
        heading: 145.0,
        magneticHeading: 145.0,
        accuracy: 3,
      ).withQibla(145.0 + diff, declination: 0);
      expect(at(0).isAligned, isTrue);
      expect(at(4.9).isAligned, isTrue);
      expect(at(5.1).isAligned, isFalse);
      expect(at(5.1).isClose, isTrue);
      expect(at(12.1).isClose, isFalse);
    });

    test('geçersiz sensör paketleri reddedilir', () {
      expect(
        CompassService.isValidSensorPayload(<Object?, Object?>{
          'heading': 10.0,
          'accuracy': 3.0,
        }),
        isTrue,
      );
      expect(
        CompassService.isValidSensorPayload(<Object?, Object?>{
          'heading': double.nan,
          'accuracy': 3.0,
        }),
        isFalse,
      );
      expect(
        CompassService.isValidSensorPayload(<Object?, Object?>{
          'heading': 10.0,
          'accuracy': 3.0,
          'tilt': double.infinity,
        }),
        isFalse,
      );
    });
  });

  group('4) Arayüz katmanı — e-Diyanet kadran geometrisi', () {
    test('Kâbe rozeti her açıda doğru yerde durur', () {
      for (int heading = 0; heading < 360; heading += 3) {
        final double badge = QiblaMath.badgeScreenAngle(
          qibla: 151.37,
          heading: heading.toDouble(),
        );
        expect(badge.abs(), lessThanOrEqualTo(180.0));
        // Rozet açısı, kadranın dönüşüyle aynı ekran konumuna oturur.
        expect(
          GeoUtils.normalizeDegrees(heading + badge),
          closeTo(151.37, 1e-6),
        );
      }
    });

    test('kuzey etiketi telefonla birlikte döner', () {
      expect(QiblaMath.dialRotation(heading: 0), closeTo(0, 1e-9));
      expect(QiblaMath.dialRotation(heading: 90), closeTo(-90, 1e-9));
      expect(QiblaMath.dialRotation(heading: 270), closeTo(90, 1e-9));
    });

    test('hizalama yalnızca Kâbe yönünde gerçekleşir', () {
      expect(
        QiblaMath.isAligned(qibla: 151.37, heading: 151.37),
        isTrue,
      );
      expect(
        QiblaMath.isAligned(qibla: 151.37, heading: 151.37 + 4.9),
        isTrue,
      );
      expect(
        QiblaMath.isAligned(qibla: 20.0, heading: 200.0),
        isFalse,
      );
      // Rozet tam ters yönde: 180° fark asla hizalı sayılmaz.
      expect(QiblaMath.isAligned(qibla: 10.0, heading: 190.0), isFalse);
    });

    test('dönüş yönü işareti kullanıcıya doğru tarafı söyler', () {
      expect(QiblaMath.turnDirection(qibla: 151.37, heading: 100), 1);
      expect(QiblaMath.turnDirection(qibla: 151.37, heading: 200), -1);
      expect(QiblaMath.turnDirection(qibla: 151.37, heading: 151.0), 0);
      // 350° → 10° farkı +20° (sağa) olmalı, -340° değil.
      expect(QiblaMath.turnDirection(qibla: 10, heading: 350), 1);
      expect(QiblaMath.guidanceText(qibla: 10, heading: 350), contains('sağa'));
    });

    test('harita vektörü ekran koordinatında Kâbe yönünü gösterir', () {
      final math.Point<double> north = QiblaMath.screenVector(
        qibla: 0,
        heading: 0,
      );
      expect(north.x, closeTo(0, 1e-9));
      expect(north.y, closeTo(-1, 1e-9)); // ekranda yukarı
      final math.Point<double> east = QiblaMath.screenVector(
        qibla: 90,
        heading: 0,
      );
      expect(east.x, closeTo(1, 1e-9)); // ekranda sağa
      expect(east.y, closeTo(0, 1e-9));
    });
  });

  group('5) Uçtan uca gerçek kullanım senaryoları', () {
    /// Sensörün manyetik kuzeye göre ölçtüğü açı [magneticHeading] iken
    /// ekranda ne gösterileceğini üretir.
    CompassReading simulate({
      required double lat,
      required double lon,
      required double magneticHeading,
    }) {
      final double qibla = GeoUtils.qiblaBearing(lat, lon);
      final double decl = GeoUtils.magneticDeclination(lat, lon);
      return CompassReading(
        heading: GeoUtils.normalizeDegrees(magneticHeading + decl),
        magneticHeading: magneticHeading,
        accuracy: 3,
      ).withQibla(qibla, declination: decl);
    }

    test('Bağcılar: kullanıcı telefonu Kâbe yönüne çevirdiğinde hizalanır', () {
      const double lat = 41.0339;
      const double lon = 28.8567;
      final double decl = GeoUtils.magneticDeclination(lat, lon);
      final double magQibla =
          GeoUtils.normalizeDegrees(GeoUtils.qiblaBearing(lat, lon) - decl);

      final CompassReading aligned =
          simulate(lat: lat, lon: lon, magneticHeading: magQibla);
      expect(aligned.isAligned, isTrue);
      expect(aligned.differenceToQibla!.abs(), lessThan(0.01));

      // 30° sağa dönükken rozet 30° solda görünmeli (ekranda ok ile hizasız).
      final CompassReading turned =
          simulate(lat: lat, lon: lon, magneticHeading: magQibla + 30);
      expect(turned.differenceToQibla, closeTo(-30, 0.01));
      expect(turned.isAligned, isFalse);
      expect(
        QiblaMath.badgeScreenAngle(
          qibla: GeoUtils.qiblaBearing(lat, lon),
          heading: turned.heading,
        ),
        closeTo(-30, 0.01),
      );
    });

    test('kuzey yarımküre ve güney yarımküre şehirlerinde tutarlı', () {
      const Map<String, List<double>> cities = <String, List<double>>{
        'İstanbul': <double>[41.0082, 28.9784],
        'Londra': <double>[51.5074, -0.1278],
        'New York': <double>[40.7128, -74.0060],
        'Sidney': <double>[-33.8688, 151.2093],
        'Tokyo': <double>[35.6762, 139.6503],
      };
      for (final MapEntry<String, List<double>> e in cities.entries) {
        final double lat = e.value[0];
        final double lon = e.value[1];
        final double qibla = GeoUtils.qiblaBearing(lat, lon);
        final double decl = GeoUtils.magneticDeclination(lat, lon);
        final double magQibla = GeoUtils.normalizeDegrees(qibla - decl);
        final CompassReading r =
            simulate(lat: lat, lon: lon, magneticHeading: magQibla);
        expect(r.isAligned, isTrue, reason: '${e.key} hizalanmadı');
        // Ham manyetik hedef her zaman 0-360 aralığında olmalı.
        expect(magQibla, inInclusiveRange(0.0, 360.0));
      }
    });

    test('30° yanlış sapma kullanılsa bile hata 30° ile sınırlı kalır', () {
      const double lat = 41.0339;
      const double lon = 28.8567;
      final double qibla = GeoUtils.qiblaBearing(lat, lon);
      final double wrongDecl = GeoUtils.magneticDeclination(lat, lon) - 30.0;
      const double magnetic = 145.0;
      final CompassReading r = CompassReading(
        heading: GeoUtils.normalizeDegrees(magnetic + wrongDecl),
        magneticHeading: magnetic,
        accuracy: 3,
      ).withQibla(qibla, declination: wrongDecl);
      expect(r.differenceToQibla!.abs(), closeTo(30, 0.01));
    });
  });
}
