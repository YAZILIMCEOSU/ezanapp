import 'package:sqflite/sqflite.dart';

import '../../core/db/app_database.dart';
import '../models/prayer.dart';
import '../models/prayer_times_day.dart';

/// Vakitlerin yerel önbelleği (SQLite).
///
/// Son başarılı veri her zaman saklanır; internet yoksa uygulama bu veriyi
/// gösterir ve "önbellek" etiketiyle bilgilendirir.
class PrayerTimesCache {
  PrayerTimesCache(this._database);

  final AppDatabase _database;

  Future<void> saveMany(String locationKey, List<PrayerTimesDay> days) async {
    if (days.isEmpty) return;
    final Batch batch = _database.raw.batch();
    for (final PrayerTimesDay day in days) {
      batch.insert(
        'prayer_times_cache',
        _toRow(locationKey, day),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> save(String locationKey, PrayerTimesDay day) =>
      saveMany(locationKey, <PrayerTimesDay>[day]);

  Future<PrayerTimesDay?> get(String locationKey, DateTime date) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'prayer_times_cache',
      where: 'district_id = ? AND date = ?',
      whereArgs: <Object?>[locationKey, _dateKey(date)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<List<PrayerTimesDay>> getRange(String locationKey, DateTime start, DateTime end) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'prayer_times_cache',
      where: 'district_id = ? AND date >= ? AND date <= ?',
      whereArgs: <Object?>[locationKey, _dateKey(start), _dateKey(end)],
      orderBy: 'date ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<DateTime?> lastFetch(String locationKey) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'prayer_times_cache',
      columns: <String>['fetched_at'],
      where: 'district_id = ?',
      whereArgs: <Object?>[locationKey],
      orderBy: 'fetched_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final int? millis = rows.first['fetched_at'] as int?;
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Eski kayıtları temizler (varsayılan: 60 günden eski).
  Future<int> pruneOlderThan({int days = 60}) async {
    final DateTime threshold = DateTime.now().subtract(Duration(days: days));
    return _database.raw.delete(
      'prayer_times_cache',
      where: 'date < ?',
      whereArgs: <Object?>[_dateKey(threshold)],
    );
  }

  Map<String, Object?> _toRow(String locationKey, PrayerTimesDay day) => <String, Object?>{
        'district_id': locationKey,
        'date': _dateKey(day.date),
        'imsak': _time(day.times[Prayer.imsak]),
        'gunes': _time(day.times[Prayer.gunes]),
        'ogle': _time(day.times[Prayer.ogle]),
        'ikindi': _time(day.times[Prayer.ikindi]),
        'aksam': _time(day.times[Prayer.aksam]),
        'yatsi': _time(day.times[Prayer.yatsi]),
        'source': day.source,
        'hijri': day.hijriDate,
        'fetched_at': (day.cachedAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

  PrayerTimesDay _fromRow(Map<String, Object?> row) {
    final DateTime date = DateTime.parse(row['date']! as String);
    DateTime build(String key) {
      final List<String> parts = (row[key]! as String).split(':');
      return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
    }

    return PrayerTimesDay(
      date: date,
      times: <Prayer, DateTime>{
        Prayer.imsak: build('imsak'),
        Prayer.gunes: build('gunes'),
        Prayer.ogle: build('ogle'),
        Prayer.ikindi: build('ikindi'),
        Prayer.aksam: build('aksam'),
        Prayer.yatsi: build('yatsi'),
      },
      source: 'cache',
      hijriDate: row['hijri'] as String?,
      cachedAt: DateTime.fromMillisecondsSinceEpoch(row['fetched_at']! as int),
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _time(DateTime? value) {
    if (value == null) return '00:00';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
