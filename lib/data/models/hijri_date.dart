import 'package:flutter/foundation.dart';

import '../../core/utils/app_time.dart';

/// Hicri takvim tarihi.
@immutable
class HijriDate {
  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    this.weekday,
  });

  final int year;
  final int month;
  final int day;
  final String? weekday;

  String get monthName => AppTime.hijriMonths[(month - 1).clamp(0, 11)];

  /// "12 Ramazan 1447"
  String get formatted => '$day $monthName $year';

  /// "12 Ramazan 1447 · Cuma"
  String get longFormatted => weekday == null ? formatted : '$formatted · $weekday';

  bool get isRamadan => month == 9;
  bool get isDhulHijjah => month == 12;
  bool get isMuharram => month == 1;
  bool get isShaban => month == 8;
  bool get isRajab => month == 7;

  HijriDate copyWith({int? year, int? month, int? day, String? weekday}) => HijriDate(
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
        weekday: weekday ?? this.weekday,
      );

  @override
  bool operator ==(Object other) =>
      other is HijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => formatted;
}

/// Hicri takvimde önemli gün/geceler.
class IslamicDay {
  const IslamicDay({
    required this.title,
    required this.description,
    required this.hijriMonth,
    required this.hijriDay,
    this.isFastingDay = false,
  });

  final String title;
  final String description;
  final int hijriMonth;
  final int hijriDay;
  final bool isFastingDay;

  bool matches(HijriDate hijri) => hijri.month == hijriMonth && hijri.day == hijriDay;
}

/// Yıl içindeki önemli İslami günler.
abstract final class IslamicDays {
  static const List<IslamicDay> all = <IslamicDay>[
    IslamicDay(
      title: 'Aşure Günü',
      description: 'Muharrem ayının 10. günü. Oruç tutulması müstehap kabul edilir.',
      hijriMonth: 1,
      hijriDay: 10,
      isFastingDay: true,
    ),
    IslamicDay(
      title: 'Regâib Kandili',
      description: 'Recep ayının ilk Cuma gecesi.',
      hijriMonth: 7,
      hijriDay: 1,
    ),
    IslamicDay(
      title: 'Mîraç Kandili',
      description: 'Recep ayının 27. gecesi.',
      hijriMonth: 7,
      hijriDay: 27,
    ),
    IslamicDay(
      title: 'Berat Kandili',
      description: 'Şaban ayının 15. gecesi.',
      hijriMonth: 8,
      hijriDay: 15,
    ),
    IslamicDay(
      title: 'Ramazan Başlangıcı',
      description: 'Ramazan ayının ilk günü.',
      hijriMonth: 9,
      hijriDay: 1,
      isFastingDay: true,
    ),
    IslamicDay(
      title: 'Kadir Gecesi',
      description: 'Ramazan ayının 27. gecesi — bin aydan hayırlı gece.',
      hijriMonth: 9,
      hijriDay: 27,
    ),
    IslamicDay(
      title: 'Ramazan Bayramı 1. Gün',
      description: 'Şevval ayının 1. günü.',
      hijriMonth: 10,
      hijriDay: 1,
    ),
    IslamicDay(
      title: 'Arefe Günü',
      description: 'Zilhicce ayının 9. günü — hac arefesi, oruç tutulması müstehaptır.',
      hijriMonth: 12,
      hijriDay: 9,
      isFastingDay: true,
    ),
    IslamicDay(
      title: 'Kurban Bayramı 1. Gün',
      description: 'Zilhicce ayının 10. günü.',
      hijriMonth: 12,
      hijriDay: 10,
    ),
  ];

  /// Arefe dışındaki önemli oruç günleri.
  static const List<IslamicDay> fastingDays = <IslamicDay>[
    IslamicDay(
      title: 'Şaban Orucu',
      description: 'Şaban ayında çokça oruç tutmak sünnettir.',
      hijriMonth: 8,
      hijriDay: 1,
      isFastingDay: true,
    ),
    IslamicDay(
      title: 'Zilhicce’nin İlk Günleri',
      description: 'Zilhicce’nin ilk dokuz günü oruç tutulması faziletlidir.',
      hijriMonth: 12,
      hijriDay: 1,
      isFastingDay: true,
    ),
  ];

  static List<IslamicDay> onDate(HijriDate hijri) =>
      all.where((IslamicDay d) => d.matches(hijri)).toList();
}
