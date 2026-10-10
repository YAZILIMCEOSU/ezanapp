import 'package:flutter/foundation.dart';

import 'prayer.dart';

/// Aktif vakit, sıradaki vakit ve geri sayım için tek doğruluk kaynağı.
///
/// Kart başlığı (`currentPrayer`), geri sayım sayacı (`nextPrayer`, `remaining`),
/// ilerleme çubuğu (`progress`) ve vakit listesi (`activeDay`) aynı anda bu
/// modelden beslenir; böylece ekranlar arasında veya yatsı sonrası / gece yarısı
/// geçişlerinde tutarsızlık oluşmaz.
@immutable
class PrayerScheduleSnapshot {
  const PrayerScheduleSnapshot({
    required this.activeDay,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.remaining,
    required this.progress,
    required this.isAfterIsha,
    required this.rolledOverToTomorrow,
  });

  /// Vakit listesinde gösterilecek aktif gün.
  final PrayerTimesDay activeDay;

  /// Şu anda içinde bulunulan vakit.
  final Prayer currentPrayer;

  /// Sıradaki vakit (yatsı sonrasında ertesi günün imsak vakti).
  final PrayerTime? nextPrayer;

  /// Sıradaki vakte kalan süre.
  final Duration remaining;

  /// Önceki vakitten sıradaki vakte ilerleme oranı (0.0 .. 1.0).
  final double progress;

  /// Bugünün yatsı vakti geçti ve sıradaki vakit yarının imsakı mı?
  final bool isAfterIsha;

  /// Gece yarısı geçildiği için aktif gün yarına devretti mi?
  final bool rolledOverToTomorrow;

  /// Bugün ve yarın verisinden verilen [now] anı için tutarlı anlık görüntü üretir.
  static PrayerScheduleSnapshot resolve({
    required PrayerTimesDay day,
    PrayerTimesDay? tomorrow,
    required DateTime now,
  }) {
    final bool sameAsTomorrow =
        tomorrow != null &&
        now.year == tomorrow.date.year &&
        now.month == tomorrow.date.month &&
        now.day == tomorrow.date.day;

    final PrayerTimesDay activeDay = sameAsTomorrow ? tomorrow : day;
    final Prayer current = activeDay.currentPrayer(now);
    PrayerTime? next = activeDay.nextPrayer(now);
    bool afterIsha = false;

    if (next == null && !sameAsTomorrow && tomorrow != null) {
      final DateTime? tomorrowImsak = tomorrow.timeOf(Prayer.imsak);
      if (tomorrowImsak != null && tomorrowImsak.isAfter(now)) {
        next = PrayerTime(
          prayer: Prayer.imsak,
          time: tomorrowImsak,
          source: tomorrow.source,
        );
        afterIsha = true;
      }
    }

    final Duration remaining =
        next == null || !next.time.isAfter(now)
        ? Duration.zero
        : next.time.difference(now);

    final double progress = next == null
        ? 1.0
        : _computeProgress(
            activeDay: activeDay,
            day: day,
            current: current,
            next: next,
            now: now,
            sameAsTomorrow: sameAsTomorrow,
          );

    return PrayerScheduleSnapshot(
      activeDay: activeDay,
      currentPrayer: current,
      nextPrayer: next,
      remaining: remaining,
      progress: progress,
      isAfterIsha: afterIsha,
      rolledOverToTomorrow: sameAsTomorrow,
    );
  }

  static double _computeProgress({
    required PrayerTimesDay activeDay,
    required PrayerTimesDay day,
    required Prayer current,
    required PrayerTime next,
    required DateTime now,
    required bool sameAsTomorrow,
  }) {
    DateTime? previous;
    final int currentIndex = current.index;
    for (int i = currentIndex; i >= 0; i--) {
      final DateTime? candidate = activeDay.times[Prayer.values[i]];
      if (candidate != null && !candidate.isAfter(now)) {
        previous = candidate;
        break;
      }
    }
    // Gece yarısından sonra henüz imsak girmediyse başlangıç önceki günün yatsısıdır.
    if (previous == null && sameAsTomorrow) {
      previous = day.times[Prayer.yatsi];
    }
    if (previous == null) {
      final DateTime? imsak = activeDay.times[Prayer.imsak];
      if (imsak != null && now.isBefore(imsak)) {
        previous = DateTime(now.year, now.month, now.day);
      }
    }
    if (previous == null) return 0.0;
    final int totalSeconds = next.time.difference(previous).inSeconds;
    if (totalSeconds <= 0) return 1.0;
    final double ratio = now.difference(previous).inSeconds / totalSeconds;
    return ratio.clamp(0.0, 1.0);
  }
}

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
    final List<DateTime?> list = Prayer.values
        .map((Prayer p) => times[p])
        .toList();
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
    final Map<String, Object?> raw =
        (json['times'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
    return PrayerTimesDay(
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String? ?? 'unknown',
      hijriDate: json['hijri'] as String?,
      cachedAt: json['cachedAt'] == null
          ? null
          : DateTime.tryParse(json['cachedAt'] as String),
      times: <Prayer, DateTime>{
        for (final Prayer prayer in Prayer.values)
          if (raw[prayer.key] != null)
            prayer: DateTime.parse(raw[prayer.key]! as String),
      },
    );
  }

  PrayerTimesDay copyWith({
    DateTime? date,
    Map<Prayer, DateTime>? times,
    String? source,
    String? hijriDate,
    DateTime? cachedAt,
  }) => PrayerTimesDay(
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
