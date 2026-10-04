import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../models/hijri_date.dart';

/// Hicri takvim dönüştürücü — Ümmü'l-Kurâ veri kümesi (1343-1500 H).
///
/// Veri `assets/data/hijri_ummalqura.json` içinde ay başlangıçları
/// (JDN farkları) olarak saklanır; toplam ~2 KB'dır ve tamamen çevrimdışı
/// çalışır. Diyanet'in yayımladığı hicri tarihlerle aynı aralıktadır.
class HijriCalendar {
  HijriCalendar._({
    required this.baseHijriYear,
    required this.baseHijriMonth,
    required this.baseJulianDay,
    required List<int> monthLengths,
  }) : _monthLengths = monthLengths;

  final int baseHijriYear;
  final int baseHijriMonth;
  final int baseJulianDay;
  final List<int> _monthLengths;

  static HijriCalendar? _instance;

  /// Uygulama açılışında bir kez yüklenir.
  static Future<HijriCalendar> load({AssetBundle? bundle}) async {
    if (_instance != null) return _instance!;
    final AssetBundle assets = bundle ?? rootBundle;
    final String raw =
        await assets.loadString('assets/data/hijri_ummalqura.json');
    final Map<String, Object?> json =
        (jsonDecode(raw) as Map).cast<String, Object?>();
    final String encoded = json['monthLengths'] as String;
    final int zero = '0'.codeUnitAt(0);
    final List<int> lengths =
        encoded.codeUnits.map((int code) => code - zero + 27).toList();
    final DateTime base = DateTime.parse(json['baseGregorian'] as String);
    _instance = HijriCalendar._(
      baseHijriYear: json['baseHijriYear'] as int,
      baseHijriMonth: json['baseHijriMonth'] as int,
      baseJulianDay: gregorianToJulianDay(base.year, base.month, base.day),
      monthLengths: lengths,
    );
    AppLog.debug('Hicri takvim yüklendi: ${lengths.length} ay');
    return _instance!;
  }

  /// Test edilebilirlik için örnek veri ile oluşturma.
  factory HijriCalendar.forTesting({
    required int baseHijriYear,
    required int baseHijriMonth,
    required int baseJulianDay,
    required List<int> monthLengths,
  }) =>
      HijriCalendar._(
        baseHijriYear: baseHijriYear,
        baseHijriMonth: baseHijriMonth,
        baseJulianDay: baseJulianDay,
        monthLengths: monthLengths,
      );

  /// Desteklenen aralık kontrolü.
  bool get supportsFullRange => _monthLengths.length > 1500 * 12;

  /// Miladi tarihi hicri tarihe çevirir.
  HijriDate toHijri(DateTime date, {int dayOffset = 0}) {
    final int jdn = gregorianToJulianDay(date.year, date.month, date.day);
    int remaining = jdn - baseJulianDay;
    int year = baseHijriYear;
    int month = baseHijriMonth;
    int index = 0;

    if (remaining < 0) {
      // Aralık dışı: yaklaşık dönüşüm (ortalama ay uzunluğu 29.53 gün)
      final int approxMonths = (remaining / 29.530588).floor();
      final int total =
          baseHijriYear * 12 + (baseHijriMonth - 1) + approxMonths;
      return _buildDate(total ~/ 12, total % 12 + 1, 1, date, dayOffset);
    }

    while (index < _monthLengths.length && remaining >= _monthLengths[index]) {
      remaining -= _monthLengths[index];
      index++;
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    if (index >= _monthLengths.length) {
      final int total = baseHijriYear * 12 +
          (baseHijriMonth - 1) +
          (_monthLengths.length) +
          (remaining / 29.530588).floor();
      return _buildDate(total ~/ 12, total % 12 + 1, 1, date, dayOffset);
    }
    return _buildDate(year, month, remaining + 1 + dayOffset, date, dayOffset);
  }

  HijriDate _buildDate(
      int year, int month, int day, DateTime gregorian, int dayOffset) {
    // Ay taşmalarını normalize et.
    int y = year;
    int m = month;
    int d = day;
    // Ümmü'l-Kurâ ayları 29 veya 30 gündür; dayOffset eklendiğinde taşabilir.
    if (d < 1) {
      m -= 1;
      if (m < 1) {
        m = 12;
        y -= 1;
      }
      d += 30;
    } else if (d > 30) {
      final int length = _monthLength(y, m);
      if (d > length) {
        d -= length;
        m += 1;
        if (m > 12) {
          m = 1;
          y += 1;
        }
      }
    }
    return HijriDate(
      year: y,
      month: m,
      day: d,
      weekday: AppTime.turkishWeekdays[gregorian.weekday - 1],
    );
  }

  int _monthLength(int year, int month) {
    final int index = (year - baseHijriYear) * 12 + (month - baseHijriMonth);
    if (index < 0 || index >= _monthLengths.length) return 30;
    return _monthLengths[index];
  }

  /// Hicri ayın uzunluğu (29/30 gün).
  int monthLength(HijriDate date) => _monthLength(date.year, date.month);

  /// Hicri yılın toplam gün sayısı.
  int yearLength(int hijriYear) {
    int total = 0;
    for (int m = 1; m <= 12; m++) {
      total += _monthLength(hijriYear, m);
    }
    return total;
  }

  /// Hicri tarihi miladi tarihe çevirir.
  DateTime toGregorian(HijriDate hijri) {
    int days = 0;
    int year = baseHijriYear;
    int month = baseHijriMonth;
    while (year < hijri.year || (year == hijri.year && month < hijri.month)) {
      days += _monthLength(year, month);
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
      if (days > 80000) break; // güvenlik sınırı
    }
    days += (hijri.day - 1);
    return julianDayToGregorian(baseJulianDay + days);
  }

  /// Ramazan başlangıcı (1 Ramazan) miladi tarih.
  DateTime ramadanStart(int hijriYear) =>
      toGregorian(HijriDate(year: hijriYear, month: 9, day: 1));

  /// Ramazan sonu (30 Ramazan).
  DateTime ramadanEnd(int hijriYear) =>
      toGregorian(HijriDate(year: hijriYear, month: 9, day: 29));

  /// Bir ramazan gününün sahur/imsak ve iftar günü olup olmadığı.
  bool isRamadan(DateTime gregorian) => toHijri(gregorian).isRamadan;

  /// Kadir gecesi tahmini (27. gece).
  DateTime kadirNight(int hijriYear) =>
      toGregorian(HijriDate(year: hijriYear, month: 9, day: 27));

  static int gregorianToJulianDay(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final int a = y ~/ 100;
    final int b = 2 - a + a ~/ 4;
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;
  }

  static DateTime julianDayToGregorian(int julianDay) {
    final int a = julianDay + 32044;
    final int b = (4 * a + 3) ~/ 146097;
    final int c = a - (146097 * b) ~/ 4;
    final int d = (4 * c + 3) ~/ 1461;
    final int e = c - (1461 * d) ~/ 4;
    final int m = (5 * e + 2) ~/ 153;
    final int day = e - (153 * m + 2) ~/ 5 + 1;
    final int month = m + 3 - 12 * (m ~/ 10);
    final int year = 100 * b + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }
}
