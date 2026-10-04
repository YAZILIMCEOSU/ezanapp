import 'package:flutter/material.dart';

import '../../design/app_colors.dart';

/// Günlük altı vakit.
enum Prayer {
  imsak(
    'İmsak',
    'İmsak',
    'İmsak vakti girdi',
    Icons.nightlight_round,
    AppColors.imsak,
    'imsak',
  ),
  gunes(
    'Güneş',
    'Güneş',
    'Güneş doğdu',
    Icons.wb_twilight_rounded,
    AppColors.gunes,
    'gunes',
  ),
  ogle(
    'Öğle',
    'Öğle',
    'Öğle vakti girdi',
    Icons.wb_sunny_rounded,
    AppColors.ogle,
    'ogle',
  ),
  ikindi(
    'İkindi',
    'İkindi',
    'İkindi vakti girdi',
    Icons.wb_sunny_outlined,
    AppColors.ikindi,
    'ikindi',
  ),
  aksam(
    'Akşam',
    'Akşam',
    'Akşam vakti girdi',
    Icons.brightness_4_rounded,
    AppColors.aksam,
    'aksam',
  ),
  yatsi(
    'Yatsı',
    'Yatsı',
    'Yatsı vakti girdi',
    Icons.dark_mode_rounded,
    AppColors.yatsi,
    'yatsi',
  );

  const Prayer(
    this.label,
    this.shortLabel,
    this.notificationTitle,
    this.icon,
    this.color,
    this.key,
  );

  final String label;
  final String shortLabel;
  final String notificationTitle;
  final IconData icon;
  final Color color;
  final String key;

  /// Ezan okunan vakitler (güneş hariç).
  bool get hasAdhan => this != Prayer.gunes;

  /// Namaz kılınan vakitler.
  bool get isPrayerTime => this != Prayer.gunes;

  /// Ertesi gün için bildirim gerekli mi (imsak).
  bool get isNextDay => this == Prayer.imsak;

  static Prayer fromKey(String key) => Prayer.values.firstWhere(
    (Prayer p) => p.key == key,
    orElse: () => Prayer.imsak,
  );

  static const List<Prayer> adhanTimes = <Prayer>[
    Prayer.imsak,
    Prayer.ogle,
    Prayer.ikindi,
    Prayer.aksam,
    Prayer.yatsi,
  ];
}

/// Bir vaktin hesaplanmış/indirilmiş zamanı.
class PrayerTime {
  const PrayerTime({
    required this.prayer,
    required this.time,
    required this.source,
  });

  final Prayer prayer;
  final DateTime time;
  final String source;

  int get minutes => time.hour * 60 + time.minute;

  Map<String, Object?> toJson() => <String, Object?>{
    'prayer': prayer.key,
    'time': time.toIso8601String(),
    'source': source,
  };

  factory PrayerTime.fromJson(Map<String, Object?> json) => PrayerTime(
    prayer: Prayer.fromKey(json['prayer'] as String? ?? 'imsak'),
    time: DateTime.parse(json['time'] as String),
    source: json['source'] as String? ?? 'unknown',
  );
}
