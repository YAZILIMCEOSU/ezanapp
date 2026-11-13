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

  Future<List<PrayerTimesDay>> getRange(
    String locationKey,
    DateTime start,
    DateTime end,
  ) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'prayer_times_cache',
      where: 'district_id = ? AND date >= ? AND date <= ?',
      whereArgs: <Object?>[locationKey, _dateKey(start), _dateKey(end)],
      orderBy: 'date ASC',
    );
    // Bozuk/eski şema satırları sessizce atlanır; tek bir hatalı kayıt
    // yüzünden bütün önbellek okunamaz hâle gelmez.
    return rows
        .map(_fromRow)
        .whereType<PrayerTimesDay>()
        .toList(growable: false);
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

  Map<String, Object?> _toRow(String locationKey, PrayerTimesDay day) =>
      <String, Object?>{
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

  /// Veritabanı satırını modele çevirir; satır bozuksa `null` döner.
  ///
  /// Önceden `DateTime.parse` / `int.parse` doğrudan çağrılıyordu: eski şema
  /// ya da yarım yazılmış bir satır **FormatException** fırlatıyor ve vakit
  /// önbelleğinin tamamı okunamıyordu ("vakitler yüklenemedi" ekranı).
  PrayerTimesDay? _fromRow(Map<String, Object?> row) {
    final Object? rawDate = row['date'];
    if (rawDate is! String) return null;
    final DateTime? parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return null;
    final DateTime date = DateTime(parsed.year, parsed.month, parsed.day);

    DateTime? build(String key) {
      final Object? raw = row[key];
      if (raw is! String) return null;
      final List<String> parts = raw.split(':');
      if (parts.length != 2) return null;
      final int? hour = int.tryParse(parts[0]);
      final int? minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    final Map<Prayer, DateTime> times = <Prayer, DateTime>{};
    for (final Prayer prayer in Prayer.values) {
      final DateTime? time = build(prayer.key);
      // Eksik vakitli bir gün yanlış geri sayıma yol açar; hiç dönmemek
      // (ağ/hesap yedeğine düşmek) daha doğrudur.
      if (time == null) return null;
      times[prayer] = time;
    }

    final Object? fetchedAt = row['fetched_at'];
    final Object? rawSource = row['source'];
    final Object? rawHijri = row['hijri'];

    return PrayerTimesDay(
      date: date,
      times: times,
      // **Düzeltme:** kaynak bilgisi `'cache'` olarak eziliyordu. Bu yüzden
      // önbellekten okunan resmî Diyanet verisi "resmî" sayılmıyor, Hanefî
      // ikindi kaydırması uygulanmıyordu (ekran 15:46, bildirim 16:26 gibi
      // tutarsızlık). Kaynak olduğu gibi korunur; ekranda "Kayıtlı veri"
      // yazılmasını repository kendi `copyWith(source: 'cache')` çağrısıyla
      // yapar.
      source: rawSource is String ? rawSource : 'diyanet',
      hijriDate: rawHijri is String ? rawHijri : null,
      cachedAt: fetchedAt is int
          ? DateTime.fromMillisecondsSinceEpoch(fetchedAt)
          : null,
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _time(DateTime? value) {
    if (value == null) return '00:00';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
