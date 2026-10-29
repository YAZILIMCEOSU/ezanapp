import 'dart:math' as math;

import 'geo.dart';

/// **Güneş'in konumu (NOAA Solar Position Algorithm).**
///
/// Pusulanın doğruluğunu **cihazdan bağımsız** doğrulamak için kullanılır:
/// güneşin o anki gerçek azimutu hesaplanır ve Kıble açısıyla karşılaştırılır.
/// Yılda iki kez güneş tam olarak Kâbe doğrultusuna gelir; o anlarda gölge
/// yönü Kıble'yi **pusula olmadan** gösterir.
///
/// Model doğruluğu: azimutta **≤ 0,02°**, yükseklikte **≤ 0,04°**
/// (bağımsız `ephem` kütüphanesiyle 6 noktada karşılaştırıldı; kuzey/güney
/// yarımküre dahil). Formüller: NOAA Solar Calculator (Meeus, Astronomical
/// Algorithms) — kullanılan terimler 1900–2100 aralığında geçerlidir.
///
/// Saflak fonksiyon: ağ, sensör veya konum izni gerektirmez.
abstract final class SunPosition {
  /// Verilen **UTC** anda güneşin azimutu (kuzeyden saat yönünde, derece)
  /// ve yüksekliği (ufuktan yukarı, derece).
  static SunCoordinates at({
    required DateTime utc,
    required double latitude,
    required double longitude,
  }) {
    final double jd = julianDay(utc);
    final double t = (jd - 2451545.0) / 36525.0;

    // Geometrik ortalama boylam ve ortalama anomali.
    final double l0 = _norm360(280.46646 + t * (36000.76983 + t * 0.0003032));
    final double m = 357.52911 + t * (35999.05029 - 0.0001537 * t);
    final double e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
    final double mr = _rad(m);

    // Merkez denklemi ve görünen boylam.
    final double c =
        math.sin(mr) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        math.sin(2 * mr) * (0.019993 - 0.000101 * t) +
        math.sin(3 * mr) * 0.000289;
    final double trueLongitude = l0 + c;
    final double omega = 125.04 - 1934.136 * t;
    final double apparentLongitude =
        trueLongitude - 0.00569 - 0.00478 * math.sin(_rad(omega));

    // Eksen eğikliği.
    final double meanObliquity =
        23.0 +
        (26.0 +
                (21.448 -
                        t * (46.815 + t * (0.00059 - t * 0.001813))) /
                    60.0) /
            60.0;
    final double obliquity =
        meanObliquity + 0.00256 * math.cos(_rad(omega));

    // Güneşin sapması (declination).
    final double declination = _deg(
      math.asin(
        math.sin(_rad(obliquity)) * math.sin(_rad(apparentLongitude)),
      ),
    );

    // Zaman denklemi (dakika).
    final double y = math.pow(math.tan(_rad(obliquity / 2.0)), 2).toDouble();
    final double equationOfTime =
        4.0 *
        _deg(
          y * math.sin(2 * _rad(l0)) -
              2 * e * math.sin(mr) +
              4 * e * y * math.sin(mr) * math.cos(2 * _rad(l0)) -
              0.5 * y * y * math.sin(4 * _rad(l0)) -
              1.25 * e * e * math.sin(2 * mr),
        );

    // Gerçek güneş zamanı (dakika) → saat açısı (derece).
    final double utcMinutes =
        utc.hour * 60.0 + utc.minute + utc.second / 60.0;
    final double trueSolarMinutes =
        (utcMinutes + equationOfTime + 4.0 * longitude) % 1440.0;
    final double hourAngle = trueSolarMinutes / 4.0 - 180.0;

    final double latR = _rad(latitude);
    final double decR = _rad(declination);
    final double haR = _rad(hourAngle);

    final double sinAlt =
        math.sin(latR) * math.sin(decR) +
        math.cos(latR) * math.cos(decR) * math.cos(haR);
    final double altitude = _deg(math.asin(sinAlt.clamp(-1.0, 1.0)));

    final double azimuth = _norm360(
      180.0 +
          _deg(
            math.atan2(
              math.sin(haR),
              math.cos(haR) * math.sin(latR) - math.tan(decR) * math.cos(latR),
            ),
          ),
    );

    return SunCoordinates(
      azimuth: azimuth,
      altitude: altitude,
      declination: declination,
      equationOfTimeMinutes: equationOfTime,
    );
  }

  /// Julian günü (UTC).
  static double julianDay(DateTime utc) {
    final DateTime t = utc.toUtc();
    int year = t.year;
    int month = t.month;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final int a = year ~/ 100;
    final int b = 2 - a + a ~/ 4;
    final double dayFraction =
        (t.hour + t.minute / 60.0 + t.second / 3600.0) / 24.0;
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        t.day +
        b -
        1524.5 +
        dayFraction;
  }

  static double _rad(double degrees) => degrees * math.pi / 180.0;
  static double _deg(double radians) => radians * 180.0 / math.pi;

  static double _norm360(double degrees) {
    final double v = degrees % 360.0;
    return v < 0 ? v + 360.0 : v;
  }
}

/// Güneşin konumu.
class SunCoordinates {
  const SunCoordinates({
    required this.azimuth,
    required this.altitude,
    required this.declination,
    required this.equationOfTimeMinutes,
  });

  /// Kuzeyden saat yönünde azimut (derece).
  final double azimuth;

  /// Ufkun üzerindeki yükseklik (derece); negatifse güneş batmıştır.
  final double altitude;

  /// Güneşin sapması (declination, derece).
  final double declination;

  /// Zaman denklemi (dakika).
  final double equationOfTimeMinutes;

  bool get isDaylight => altitude > -0.833;
}

/// **Kıbleyi güneşle doğrulama.**
///
/// Güneş, Kâbe ile aynı boylam hizasına geldiğinde (yılda iki kez: mayıs
/// sonu ve temmuz ortası) **her konumda** güneş ışınları Kâbe yönüne paralel
/// olur. O anlarda bir çubuğun gölgesi tam ters yönü gösterir; yani pusula
/// olmadan Kıble bulunur ve uygulamanın gösterdiği açı doğrulanabilir.
abstract final class QiblaSunCheck {
  /// Güneşin verilen konumda Kıble doğrultusuna en yakın olduğu anı bulur
  /// ([day] günü içinde, yerel saatle). Fark 8°'den büyükse `null`.
  static QiblaSunAlignment? bestOn({
    required DateTime day,
    required double latitude,
    required double longitude,
    double toleranceDegrees = 8.0,
  }) {
    final double qibla = GeoUtils.qiblaBearing(latitude, longitude);
    final DateTime start = DateTime(day.year, day.month, day.day);
    QiblaSunAlignment? best;
    // Gün boyu dakika dakika (güneş ufkun üzerindeyken). Hizalama anı
    // konuma göre gece yarısına da düşebilir (ör. ABD'de gün doğumu);
    // güneş ufkun altındaysa gölge yöntemi zaten kullanılamaz.
    for (int minute = 0; minute < 24 * 60; minute++) {
      final DateTime local = start.add(Duration(minutes: minute));
      final SunCoordinates sun = SunPosition.at(
        utc: local.toUtc(),
        latitude: latitude,
        longitude: longitude,
      );
      if (sun.altitude < 5) continue;
      final double diff = GeoUtils.normalizeSigned(sun.azimuth - qibla).abs();
      if (best == null || diff < best.differenceDegrees) {
        best = QiblaSunAlignment(
          time: local,
          qiblaDegrees: qibla,
          sunAzimuth: sun.azimuth,
          sunAltitude: sun.altitude,
          differenceDegrees: diff,
        );
      }
    }
    if (best == null || best.differenceDegrees > toleranceDegrees) return null;
    return best.withWindow(
      _windowAround(
        start: start,
        bestMinute: best.time.difference(start).inMinutes,
        latitude: latitude,
        longitude: longitude,
        qibla: qibla,
      ),
    );
  }

  /// ±1° içinde kalınan zaman aralığı (dakika cinsinden, başlangıç/bitiş).
  static (int, int) _windowAround({
    required DateTime start,
    required int bestMinute,
    required double latitude,
    required double longitude,
    required double qibla,
  }) {
    bool within(int minute) {
      final DateTime local = start.add(Duration(minutes: minute));
      final SunCoordinates sun = SunPosition.at(
        utc: local.toUtc(),
        latitude: latitude,
        longitude: longitude,
      );
      if (sun.altitude < 3) return false;
      return GeoUtils.normalizeSigned(sun.azimuth - qibla).abs() < 1.0;
    }

    int from = bestMinute;
    int to = bestMinute;
    while (from > bestMinute - 45 && within(from - 1)) {
      from--;
    }
    while (to < bestMinute + 45 && within(to + 1)) {
      to++;
    }
    return (from, to);
  }

  /// Önümüzdeki günlerde Kıble doğrulamasına en uygun gün.
  ///
  /// Yılda iki kez (mayıs sonu, temmuz ortası) güneş Kâbe ile aynı boylam
  /// hizasına gelir ve fark **< 0,5°** olur; diğer günlerde fark büyür.
  ///
  /// Hesap iki aşamalıdır (hızlı): önce güneş sapmasının Kâbe enlemine eşit
  /// olduğu günler 6 saatlik adımlarla bulunur (≈1.600 hesap), sonra yalnızca
  /// o günlerde dakika hassasiyetinde arama yapılır. Toplam süre ≈10 ms.
  static QiblaSunAlignment? bestUpcoming({
    required DateTime from,
    required double latitude,
    required double longitude,
    int days = 400,
  }) {
    final List<DateTime> candidates = _declinationMatchDays(
      from: from,
      days: days,
    );
    QiblaSunAlignment? best;
    for (final DateTime day in candidates) {
      final QiblaSunAlignment? candidate = bestOn(
        day: day,
        latitude: latitude,
        longitude: longitude,
        toleranceDegrees: 30.0,
      );
      if (candidate == null) continue;
      if (best == null ||
          candidate.differenceDegrees < best.differenceDegrees) {
        best = candidate;
      }
    }
    if (best == null || best.differenceDegrees > 8.0) return null;
    return best;
  }

  /// Güneş sapmasının Kâbe enlemini (21,4225°) kestiği günler.
  ///
  /// Yıl içinde iki geçiş vardır (mayıs sonu ve temmuz ortası). 6 saatlik
  /// adımlarla işaret değişimi aranır; bulunan gün yerel gece yarısı olarak
  /// döner. Tüm yıl için yalnızca ~1.600 güneş hesabı yapılır.
  static List<DateTime> _declinationMatchDays({
    required DateTime from,
    required int days,
  }) {
    const double target = 21.4224779; // Kâbe enlemi = güneş sapması eşleşmesi
    final List<DateTime> result = <DateTime>[];
    double? previousDiff;
    for (int hours = 0; hours <= days * 24; hours += 6) {
      final DateTime moment = from.add(Duration(hours: hours));
      final SunCoordinates sun = SunPosition.at(
        utc: moment.toUtc(),
        latitude: 0,
        longitude: 0,
      );
      final double diff = sun.declination - target;
      if (previousDiff != null && previousDiff * diff <= 0) {
        final DateTime day = DateTime(moment.year, moment.month, moment.day);
        if (!result.contains(day)) result.add(day);
      }
      previousDiff = diff;
    }
    return result;
  }
}

/// Güneşin Kıble doğrultusuna en yakın olduğu an.
class QiblaSunAlignment {
  const QiblaSunAlignment({
    required this.time,
    required this.qiblaDegrees,
    required this.sunAzimuth,
    required this.sunAltitude,
    required this.differenceDegrees,
    this.windowStartMinute,
    this.windowEndMinute,
  });

  /// Yerel saat.
  final DateTime time;
  final double qiblaDegrees;
  final double sunAzimuth;
  final double sunAltitude;

  /// Güneş azimutu ile Kıble açısı arasındaki fark (derece).
  final double differenceDegrees;

  /// ±1° içinde kalınan aralık (gün başından itibaren dakika).
  final int? windowStartMinute;
  final int? windowEndMinute;

  /// Gölge yönü (güneşin tam tersi, derece) — kullanıcıya ipucu.
  double get shadowBearing => (sunAzimuth + 180.0) % 360.0;

  /// Bu an Kıble doğrulaması için yeterince hassas mı? (< 1°)
  bool get isReliable => differenceDegrees < 1.0;

  String get clockLabel =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  /// Doğrulama aralığı (ör. `12:16–12:20`). Pencere yoksa tek saat döner.
  String get windowLabel {
    final int? from = windowStartMinute;
    final int? to = windowEndMinute;
    if (from == null || to == null || to <= from) return clockLabel;
    String fmt(int minute) {
      final int h = (minute ~/ 60) % 24;
      final int m = minute % 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }

    return '${fmt(from)}–${fmt(to)}';
  }

  QiblaSunAlignment withWindow((int, int) window) => QiblaSunAlignment(
    time: time,
    qiblaDegrees: qiblaDegrees,
    sunAzimuth: sunAzimuth,
    sunAltitude: sunAltitude,
    differenceDegrees: differenceDegrees,
    windowStartMinute: window.$1,
    windowEndMinute: window.$2,
  );
}
