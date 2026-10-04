import 'package:flutter/foundation.dart';

/// Zikir tanımı (gömülü veri veya kullanıcı tanımı).
@immutable
class Zikir {
  const Zikir({
    required this.key,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.defaultTarget,
    this.virtue = '',
    this.reference = '',
    this.isCustom = false,
  });

  final String key;
  final String name;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int defaultTarget;
  final String virtue;
  final String reference;
  final bool isCustom;

  static const List<int> targetOptions = <int>[33, 34, 99, 100, 500, 1000];

  factory Zikir.fromJson(Map<String, Object?> json) => Zikir(
        key: json['key'] as String,
        name: json['name'] as String,
        arabic: json['arabic'] as String? ?? '',
        transliteration: json['transliteration'] as String? ?? '',
        meaning: json['meaning'] as String? ?? '',
        defaultTarget: (json['target'] as num?)?.toInt() ?? 33,
        virtue: json['virtue'] as String? ?? '',
        reference: json['reference'] as String? ?? '',
      );

  Zikir copyWith(
          {String? key,
          String? name,
          String? arabic,
          String? transliteration,
          String? meaning,
          int? defaultTarget}) =>
      Zikir(
        key: key ?? this.key,
        name: name ?? this.name,
        arabic: arabic ?? this.arabic,
        transliteration: transliteration ?? this.transliteration,
        meaning: meaning ?? this.meaning,
        defaultTarget: defaultTarget ?? this.defaultTarget,
        virtue: virtue,
        reference: reference,
        isCustom: isCustom,
      );
}

/// Zikir oturumu (bir hedefe yönelik sayım).
@immutable
class ZikirSession {
  const ZikirSession({
    required this.id,
    required this.zikirKey,
    required this.target,
    required this.count,
    required this.startedAt,
    this.finishedAt,
  });

  final int id;
  final String zikirKey;
  final int target;
  final int count;
  final DateTime startedAt;
  final DateTime? finishedAt;

  bool get isCompleted => count >= target;

  double get progress => target == 0 ? 0 : (count / target).clamp(0.0, 1.0);

  Duration get duration => (finishedAt ?? DateTime.now()).difference(startedAt);

  factory ZikirSession.fromRow(Map<String, Object?> row) => ZikirSession(
        id: row['id']! as int,
        zikirKey: row['zikir_key']! as String,
        target: row['target']! as int,
        count: row['count']! as int,
        startedAt:
            DateTime.fromMillisecondsSinceEpoch(row['started_at']! as int),
        finishedAt: row['finished_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['finished_at']! as int),
      );
}

/// Günlük zikir özeti.
@immutable
class ZikirDailySummary {
  const ZikirDailySummary({
    required this.date,
    required this.totalCount,
    required this.sessions,
    required this.byZikir,
    required this.target,
  });

  final DateTime date;
  final int totalCount;
  final int sessions;
  final Map<String, int> byZikir;
  final int target;

  double get progress =>
      target == 0 ? 0 : (totalCount / target).clamp(0.0, 1.0);

  bool get targetReached => totalCount >= target;
}

/// Haftalık/aylık istatistik için tek gün kaydı.
@immutable
class ZikirStatPoint {
  const ZikirStatPoint({required this.date, required this.count});

  final DateTime date;
  final int count;
}
