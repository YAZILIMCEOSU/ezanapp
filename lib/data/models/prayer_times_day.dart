import 'package:flutter/foundation.dart';

import 'prayer.dart';

/// Bir güne ait namaz vakitleri.
@immutable
class PrayerTimesDay {
  const PrayerTimesDay({
    required this.date,
    required this.times,
    required this.source,
    this.hijriDate,
    this.cachedAt,
    this.imsakNote,
  });

  final DateTime date;
  final Map<Prayer, DateTime> times;

  /// Verinin kaynağı: `diyanet`, `aladhan`, `calculation`, `cache`.
  final String source;
  final String? hijriDate;
  final DateTime? cachedAt;
  final String? imsakNote;

  DateTime? timeOf(Prayer prayer) => times[prayer];

  /// İmsak günün ilk vakti mi? (gece yarısından sonra hesaplanan günlerde)
  bool get startsBeforeMidnight => (times[Prayer.imsak]?.hour ?? 0) < 4;

  /// Verilen ana göre bir sonraki vakit.
  PrayerTime? nextPrayer(DateTime now) {
    for (final Prayer prayer in Prayer.values) {
      final DateTime? time = times[prayer];
      if (time != null && time.isAfter(now)) {
        return PrayerTime(prayer: prayer, time: time, source: source);
      }
    }
    return null;
  }

  /// Verilen anda içinde bulunulan vakit.
  Prayer currentPrayer(DateTime now) {
    Prayer current = Prayer.yatsi;
    for (final Prayer prayer in Prayer.values) {
      final DateTime? time = times[prayer];
      if (time != null && !time.isAfter(now)) {
        current = prayer;
      }
    }
    return current;
  }

  /// Sonraki vakte kalan süre; gün bittiyse null.
  Duration? remainingTo(PrayerTime next, DateTime now) {
    if (next.time.isBefore(now)) return null;
    return next.time.difference(now);
  }

  /// Vakitler sıralı mı? (bozuk veri denetimi)
  bool get isSane {
    final List<DateTime?> list = Prayer.values.map((Prayer p) => times[p]).toList();
    for (final DateTime? value in list) {
      if (value == null) return false;
    }
    for (int i = 1; i < list.length; i++) {
      if (!list[i]!.isAfter(list[i - 1]!)) return false;
    }
    return true;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'date': date.toIso8601String(),
        'source': source,
        'hijri': hijriDate,
        'cachedAt': cachedAt?.toIso8601String(),
        'times': <String, String>{
          for (final MapEntry<Prayer, DateTime> entry in times.entries)
            entry.key.key: entry.value.toIso8601String(),
        },
      };

  factory PrayerTimesDay.fromJson(Map<String, Object?> json) {
    final Map<String, Object?> raw = (json['times'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
    return PrayerTimesDay(
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String? ?? 'unknown',
      hijriDate: json['hijri'] as String?,
      cachedAt: json['cachedAt'] == null ? null : DateTime.tryParse(json['cachedAt'] as String),
      times: <Prayer, DateTime>{
        for (final Prayer prayer in Prayer.values)
          if (raw[prayer.key] != null) prayer: DateTime.parse(raw[prayer.key]! as String),
      },
    );
  }

  PrayerTimesDay copyWith({
    DateTime? date,
    Map<Prayer, DateTime>? times,
    String? source,
    String? hijriDate,
    DateTime? cachedAt,
  }) =>
      PrayerTimesDay(
        date: date ?? this.date,
        times: times ?? this.times,
        source: source ?? this.source,
        hijriDate: hijriDate ?? this.hijriDate,
        cachedAt: cachedAt ?? this.cachedAt,
      );

  /// Bir aylık tablo için yardımcı: kaynak etiketinin okunabilir karşılığı.
  String get sourceLabel => switch (source) {
        'diyanet' => 'Diyanet verisi',
        'aladhan' => 'Uluslararası servis',
        'calculation' => 'Çevrimdışı hesap',
        'cache' => 'Önbellek',
        _ => source,
      };
}
