import 'package:flutter/foundation.dart';

/// Ramazan günlük kaydı.
@immutable
class RamadanDayLog {
  const RamadanDayLog({
    required this.date,
    this.fasted = false,
    this.tarawih = false,
    this.quranPages = 0,
    this.note,
  });

  final DateTime date;
  final bool fasted;
  final bool tarawih;
  final int quranPages;
  final String? note;

  factory RamadanDayLog.fromRow(Map<String, Object?> row) => RamadanDayLog(
        date: DateTime.parse(row['date']! as String),
        fasted: (row['fasted'] as num?)?.toInt() == 1,
        tarawih: (row['tarawih'] as num?)?.toInt() == 1,
        quranPages: (row['quran_pages'] as num?)?.toInt() ?? 0,
        note: row['note'] as String?,
      );

  RamadanDayLog copyWith(
          {bool? fasted, bool? tarawih, int? quranPages, String? note}) =>
      RamadanDayLog(
        date: date,
        fasted: fasted ?? this.fasted,
        tarawih: tarawih ?? this.tarawih,
        quranPages: quranPages ?? this.quranPages,
        note: note ?? this.note,
      );
}

/// Hatim takibi için cüz durumu.
enum JuzStatus {
  pending('Okunmadı'),
  reading('Okunuyor'),
  done('Okundu');

  const JuzStatus(this.label);

  final String label;

  static JuzStatus fromName(String? name) =>
      JuzStatus.values.firstWhere((JuzStatus s) => s.name == name,
          orElse: () => JuzStatus.pending);
}

/// Tek bir cüzün durumu.
@immutable
class JuzProgress {
  const JuzProgress({
    required this.juz,
    required this.status,
    this.surah,
    this.ayah,
    this.updatedAt,
  });

  final int juz;
  final JuzStatus status;
  final int? surah;
  final int? ayah;
  final DateTime? updatedAt;

  factory JuzProgress.fromRow(Map<String, Object?> row) => JuzProgress(
        juz: row['juz']! as int,
        status: JuzStatus.fromName(row['status'] as String?),
        surah: (row['surah'] as num?)?.toInt(),
        ayah: (row['ayah'] as num?)?.toInt(),
        updatedAt: row['updated_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (row['updated_at'] as num).toInt()),
      );
}

/// Kaza orucu kaydı.
@immutable
class KazaFast {
  const KazaFast({
    required this.id,
    required this.completed,
    this.dueDate,
    this.note,
    this.completedAt,
  });

  final int id;
  final bool completed;
  final String? dueDate;
  final String? note;
  final DateTime? completedAt;

  factory KazaFast.fromRow(Map<String, Object?> row) => KazaFast(
        id: row['id']! as int,
        completed: (row['completed'] as num?)?.toInt() == 1,
        dueDate: row['due_date'] as String?,
        note: row['note'] as String?,
        completedAt: row['completed_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (row['completed_at'] as num).toInt()),
      );
}

/// Ramazan ayı özeti.
@immutable
class RamadanSummary {
  const RamadanSummary({
    required this.totalDays,
    required this.fastedDays,
    required this.tarawihDays,
    required this.quranPages,
    required this.completedJuz,
    required this.pendingKaza,
  });

  final int totalDays;
  final int fastedDays;
  final int tarawihDays;
  final int quranPages;
  final int completedJuz;
  final int pendingKaza;

  double get fastRatio => totalDays == 0 ? 0 : fastedDays / totalDays;
}
