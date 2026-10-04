import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../core/db/app_database.dart';
import '../hijri/hijri_calendar.dart';
import '../models/city.dart';
import '../models/hijri_date.dart';
import '../models/prayer.dart';
import '../models/prayer_times_day.dart';
import '../models/ramadan_models.dart';
import '../prayer/prayer_calculator.dart';
import '../prayer/prayer_times_repository.dart';

/// Ramazan modülü verisi: imsakiye, sahur/iftar, günlük kayıt, hatim, kaza orucu.
class RamadanRepository {
  RamadanRepository(this._database, this._prayerTimes, this._hijri);

  final AppDatabase _database;
  final PrayerTimesRepository _prayerTimes;
  final HijriCalendar _hijri;

  /// Bugünün hicri tarihi.
  HijriDate todayHijri({int dayOffset = 0}) =>
      _hijri.toHijri(DateTime.now(), dayOffset: dayOffset);

  /// Ramazan ayında mıyız?
  bool get isRamadan => todayHijri().isRamadan;

  /// Bu yılın Ramazan başlangıcı ve bitişi.
  ({DateTime start, DateTime end}) ramadanWindow() {
    final HijriDate today = todayHijri();
    final int hijriYear = today.month >= 9 ? today.year : today.year;
    return (
      start: _hijri.ramadanStart(hijriYear),
      end: _hijri.toGregorian(HijriDate(year: hijriYear, month: 10, day: 1)),
    );
  }

  /// Ramazan gün sayısı (kalan gün dahil).
  int ramadanDayNumber() {
    final HijriDate today = todayHijri();
    if (!today.isRamadan) return 0;
    return today.day;
  }

  /// Sahur/iftar geri sayımı için bugünün ve yarının vakitleri.
  Future<
    ({
      PrayerTimesDay today,
      PrayerTimesDay tomorrow,
      DateTime imsak,
      DateTime iftar,
    })
  >
  todayTimes({
    required UserLocation location,
    required CalculationMethod method,
  }) async {
    final DateTime now = DateTime.now();
    final PrayerTimesDay today = await _prayerTimes.getDay(
      location: location,
      date: now,
      method: method,
    );
    final PrayerTimesDay tomorrow = await _prayerTimes.getDay(
      location: location,
      date: now.add(const Duration(days: 1)),
      method: method,
    );
    final DateTime imsak =
        tomorrow.times[Prayer.imsak] ??
        today.times[Prayer.imsak] ??
        DateTime(now.year, now.month, now.day, 5);
    final DateTime iftar =
        today.times[Prayer.aksam] ?? DateTime(now.year, now.month, now.day, 19);
    return (today: today, tomorrow: tomorrow, imsak: imsak, iftar: iftar);
  }

  /// Ramazan imsakiyesi (tüm ay).
  Future<List<PrayerTimesDay>> imsakiye({
    required UserLocation location,
    required CalculationMethod method,
  }) async {
    final ({DateTime start, DateTime end}) window = ramadanWindow();
    return _prayerTimes.getRange(
      location: location,
      startDate: window.start,
      endDate: window.end.subtract(const Duration(days: 1)),
      method: method,
    );
  }

  // ------------------------------------------------------------ Günlük kayıt

  Future<RamadanDayLog?> dayLog(DateTime date) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ramadan_log',
      where: 'date = ?',
      whereArgs: <Object?>[_dateKey(date)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RamadanDayLog.fromRow(rows.first);
  }

  Future<void> saveDayLog(RamadanDayLog log) async {
    await _database.raw.insert('ramadan_log', <String, Object?>{
      'date': _dateKey(log.date),
      'fasted': log.fasted ? 1 : 0,
      'tarawih': log.tarawih ? 1 : 0,
      'quran_pages': log.quranPages,
      'note': log.note,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Ramazan ayı boyunca tutulan günler.
  Future<List<RamadanDayLog>> monthLogs() async {
    final ({DateTime start, DateTime end}) window = ramadanWindow();
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ramadan_log',
      where: 'date >= ? AND date <= ?',
      whereArgs: <Object?>[_dateKey(window.start), _dateKey(window.end)],
      orderBy: 'date ASC',
    );
    return rows.map(RamadanDayLog.fromRow).toList();
  }

  // ------------------------------------------------------------------- Hatim

  Future<List<JuzProgress>> juzProgress() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'hatim_progress',
      orderBy: 'juz ASC',
    );
    if (rows.isEmpty) {
      return <JuzProgress>[
        for (int juz = 1; juz <= 30; juz++)
          JuzProgress(juz: juz, status: JuzStatus.pending),
      ];
    }
    final Map<int, JuzProgress> byJuz = <int, JuzProgress>{
      for (final Map<String, Object?> row in rows)
        (row['juz']! as int): JuzProgress.fromRow(row),
    };
    return <JuzProgress>[
      for (int juz = 1; juz <= 30; juz++)
        byJuz[juz] ?? JuzProgress(juz: juz, status: JuzStatus.pending),
    ];
  }

  Future<void> updateJuz(
    int juz,
    JuzStatus status, {
    int? surah,
    int? ayah,
  }) async {
    await _database.raw.insert('hatim_progress', <String, Object?>{
      'juz': juz,
      'status': status.name,
      'surah': surah,
      'ayah': ayah,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> completedJuzCount() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'hatim_progress',
      where: 'status = ?',
      whereArgs: <Object?>[JuzStatus.done.name],
    );
    return rows.length;
  }

  Future<void> resetHatim() => _database.raw.delete('hatim_progress');

  /// Bir sonraki okunacak cüz.
  Future<int?> nextJuz() async {
    final List<JuzProgress> progress = await juzProgress();
    for (final JuzProgress juz in progress) {
      if (juz.status != JuzStatus.done) return juz.juz;
    }
    return null;
  }

  // ------------------------------------------------------------ Kaza orucu

  Future<List<KazaFast>> kazaFasts() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'kaza_fasts',
      orderBy: 'completed ASC, id ASC',
    );
    return rows.map(KazaFast.fromRow).toList();
  }

  Future<int> addKazaFast({
    String? dueDate,
    String? note,
    int count = 1,
  }) async {
    int inserted = 0;
    for (int i = 0; i < count; i++) {
      await _database.raw.insert('kaza_fasts', <String, Object?>{
        'due_date': dueDate,
        'note': note,
        'completed': 0,
      });
      inserted++;
    }
    return inserted;
  }

  Future<void> completeKazaFast(int id, {bool completed = true}) async {
    await _database.raw.update(
      'kaza_fasts',
      <String, Object?>{
        'completed': completed ? 1 : 0,
        'completed_at': completed
            ? DateTime.now().millisecondsSinceEpoch
            : null,
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> deleteKazaFast(int id) => _database.raw.delete(
    'kaza_fasts',
    where: 'id = ?',
    whereArgs: <Object?>[id],
  );

  Future<int> pendingKazaCount() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'kaza_fasts',
      where: 'completed = 0',
    );
    return rows.length;
  }

  /// Ramazan özeti.
  Future<RamadanSummary> summary({int totalDays = 30}) async {
    final List<RamadanDayLog> logs = await monthLogs();
    return RamadanSummary(
      totalDays: totalDays,
      fastedDays: logs.where((RamadanDayLog l) => l.fasted).length,
      tarawihDays: logs.where((RamadanDayLog l) => l.tarawih).length,
      quranPages: logs.fold(
        0,
        (int sum, RamadanDayLog l) => sum + l.quranPages,
      ),
      completedJuz: await completedJuzCount(),
      pendingKaza: await pendingKazaCount(),
    );
  }

  /// Özel günler (Kadir gecesi, bayram, arefe) için yaklaşan tarihler.
  List<({String title, DateTime date, String description})>
  upcomingSpecialDays({int limit = 6}) {
    final HijriDate today = todayHijri();
    final List<({String title, DateTime date, String description})> upcoming =
        <({String title, DateTime date, String description})>[];
    for (int yearOffset = 0; yearOffset <= 1; yearOffset++) {
      final int hijriYear = today.year + yearOffset;
      for (final IslamicDay day in IslamicDays.all) {
        final DateTime date = _hijri.toGregorian(
          HijriDate(year: hijriYear, month: day.hijriMonth, day: day.hijriDay),
        );
        if (date.isBefore(DateTime.now())) continue;
        upcoming.add((
          title: day.title,
          date: date,
          description: day.description,
        ));
      }
    }
    upcoming.sort(
      (
        ({String title, DateTime date, String description}) a,
        ({String title, DateTime date, String description}) b,
      ) => a.date.compareTo(b.date),
    );
    return upcoming.take(limit).toList();
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
