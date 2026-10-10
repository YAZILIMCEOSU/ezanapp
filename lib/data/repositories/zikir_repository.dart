import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../models/dua_models.dart';
import '../models/zikir_models.dart';

/// Tesbih/zikir verisi: gömülü zikirler, sayımlar, hedefler ve istatistikler.
class ZikirRepository {
  ZikirRepository(this._database, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AppDatabase _database;
  final AssetBundle _bundle;

  List<Zikir>? _zikirler;
  DuaCatalog? _duaCatalog;

  /// Gömülü zikir listesi.
  Future<List<Zikir>> zikirler() async {
    if (_zikirler != null) return _zikirler!;
    try {
      final String raw = await _bundle.loadString(
        'assets/data/adhkar/adhkar.json',
      );
      final Map<String, Object?> json = (jsonDecode(raw) as Map)
          .cast<String, Object?>();
      final List<Object?> items = (json['zikirler'] as List?) ?? <Object?>[];
      _zikirler = items
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                Zikir.fromJson(m.cast<String, Object?>()),
          )
          .toList();
    } catch (error, stackTrace) {
      AppLog.error(
        'Zikir verisi yüklenemedi',
        error: error,
        stackTrace: stackTrace,
      );
      _zikirler = <Zikir>[];
    }
    return _zikirler!;
  }

  /// Tüm dualar (kategorilenmiş katalog).
  ///
  /// Dosya bir kez okunur ve bellekte tutulur; ekranlar bu katalog üzerinden
  /// kategori ve arama yapar.
  Future<DuaCatalog> duaCatalog() async {
    if (_duaCatalog != null) return _duaCatalog!;
    try {
      final Map<String, Object?> json = await _loadAdhkar();
      final List<Dua> dualar = ((json['dualar'] as List?) ?? <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                Dua.fromJson(m.cast<String, Object?>()),
          )
          .where((Dua dua) => dua.key.isNotEmpty && dua.name.isNotEmpty)
          .toList();
      final List<DuaCategory> categories =
          ((json['dua_categories'] as List?) ?? <Object?>[])
              .whereType<Map<Object?, Object?>>()
              .map(
                (Map<Object?, Object?> m) =>
                    DuaCategory.fromJson(m.cast<String, Object?>()),
              )
              .toList();
      _duaCatalog = DuaCatalog(categories: categories, dualar: dualar);
    } catch (error, stackTrace) {
      AppLog.error(
        'Dua verisi yüklenemedi',
        error: error,
        stackTrace: stackTrace,
      );
      _duaCatalog = const DuaCatalog(
        categories: <DuaCategory>[],
        dualar: <Dua>[],
      );
    }
    return _duaCatalog!;
  }

  /// Günlük dua (deterministik seçim).
  Future<Dua?> dailyDua(DateTime date) async {
    final DuaCatalog catalog = await duaCatalog();
    if (catalog.isEmpty) return null;
    final int index =
        (date.difference(DateTime(date.year)).inDays + date.year * 3) %
        catalog.dualar.length;
    return catalog.dualar[index];
  }

  Map<String, Object?>? _adhkarCache;

  Future<Map<String, Object?>> _loadAdhkar() async {
    if (_adhkarCache != null) return _adhkarCache!;
    final String raw = await _bundle.loadString(
      'assets/data/adhkar/adhkar.json',
    );
    _adhkarCache = (jsonDecode(raw) as Map).cast<String, Object?>();
    return _adhkarCache!;
  }

  // ------------------------------------------------------------- Favori dualar

  Future<Set<String>> duaFavoriteKeys() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'dua_favorites',
    );
    return rows
        .map((Map<String, Object?> row) => row['dua_key']! as String)
        .toSet();
  }

  Future<bool> isDuaFavorite(String key) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'dua_favorites',
      where: 'dua_key = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Favori durumunu değiştirir; yeni durumu döner.
  Future<bool> toggleDuaFavorite(String key) async {
    if (await isDuaFavorite(key)) {
      await _database.raw.delete(
        'dua_favorites',
        where: 'dua_key = ?',
        whereArgs: <Object?>[key],
      );
      return false;
    }
    await _database.raw.insert('dua_favorites', <String, Object?>{
      'dua_key': key,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  Future<List<Dua>> favoriteDualar() async {
    final Set<String> keys = await duaFavoriteKeys();
    if (keys.isEmpty) return <Dua>[];
    final DuaCatalog catalog = await duaCatalog();
    return catalog.dualar.where((Dua dua) => keys.contains(dua.key)).toList();
  }

  /// Kullanıcı tanımlı zikirler.
  Future<List<Zikir>> customZikirler() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'zikir_custom',
      orderBy: 'created_at DESC',
    );
    return rows
        .map(
          (Map<String, Object?> row) => Zikir(
            key: row['key']! as String,
            name: row['name']! as String,
            arabic: row['arabic'] as String? ?? '',
            transliteration: row['transliteration'] as String? ?? '',
            meaning: row['meaning'] as String? ?? '',
            defaultTarget: row['default_target'] as int? ?? 33,
            isCustom: true,
          ),
        )
        .toList();
  }

  Future<void> addCustomZikir(Zikir zikir) async {
    await _database.raw.insert('zikir_custom', <String, Object?>{
      'key': zikir.key,
      'name': zikir.name,
      'arabic': zikir.arabic,
      'transliteration': zikir.transliteration,
      'meaning': zikir.meaning,
      'default_target': zikir.defaultTarget,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCustomZikir(String key) => _database.raw.delete(
    'zikir_custom',
    where: 'key = ?',
    whereArgs: <Object?>[key],
  );

  // --------------------------------------------------------------- Sayımlar

  /// Yalnızca günlük zikir toplamını artırır (her tesbih dokunuşunda çağrılır).
  Future<void> incrementDailyCount(
    String zikirKey,
    int count, {
    DateTime? now,
  }) async {
    if (count <= 0) return;
    await _incrementDaily(zikirKey, count, now ?? DateTime.now());
  }

  /// Tamamlanan bir zikir turunu (oturumunu) kaydeder.
  Future<int> recordSession(
    String zikirKey,
    int count, {
    int target = 0,
    DateTime? now,
  }) async {
    if (count <= 0) return 0;
    final DateTime timestamp = now ?? DateTime.now();
    return _database.raw.insert('zikir_sessions', <String, Object?>{
      'zikir_key': zikirKey,
      'target': target,
      'count': count,
      'started_at': timestamp
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch,
      'finished_at': timestamp.millisecondsSinceEpoch,
    });
  }

  /// Bir zikir sayımını hem oturum hem günlük özet olarak kaydeder.
  Future<int> recordCount(String zikirKey, int count, {int target = 0}) async {
    if (count <= 0) return 0;
    final DateTime now = DateTime.now();
    final int id = await recordSession(
      zikirKey,
      count,
      target: target,
      now: now,
    );
    await _incrementDaily(zikirKey, count, now);
    return id;
  }

  Future<void> _incrementDaily(String zikirKey, int count, DateTime now) async {
    final String date = _dateKey(now);
    await _database.raw.rawInsert(
      '''
      INSERT INTO zikir_daily (date, zikir_key, count) VALUES (?, ?, ?)
      ON CONFLICT(date, zikir_key) DO UPDATE SET count = count + excluded.count
      ''',
      <Object?>[date, zikirKey, count],
    );
  }

  /// Bugünün özeti.
  Future<ZikirDailySummary> todaySummary({int target = 500}) async {
    final DateTime now = DateTime.now();
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'zikir_daily',
      where: 'date = ?',
      whereArgs: <Object?>[_dateKey(now)],
    );
    final Map<String, int> byZikir = <String, int>{
      for (final Map<String, Object?> row in rows)
        row['zikir_key']! as String: (row['count'] as num?)?.toInt() ?? 0,
    };
    final int total = byZikir.values.fold(
      0,
      (int sum, int value) => sum + value,
    );
    final int sessions = (await _database.raw.query(
      'zikir_sessions',
      where: 'started_at >= ?',
      whereArgs: <Object?>[
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      ],
    )).length;
    return ZikirDailySummary(
      date: now,
      totalCount: total,
      sessions: sessions,
      byZikir: byZikir,
      target: target,
    );
  }

  /// Son N günün sayımları (grafik için).
  Future<List<ZikirStatPoint>> history({int days = 14}) async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'zikir_daily',
      where: 'date >= ?',
      whereArgs: <Object?>[_dateKey(start)],
      orderBy: 'date ASC',
    );
    final Map<String, int> totals = <String, int>{};
    for (final Map<String, Object?> row in rows) {
      final String date = row['date']! as String;
      totals[date] =
          (totals[date] ?? 0) + ((row['count'] as num?)?.toInt() ?? 0);
    }
    final List<ZikirStatPoint> points = <ZikirStatPoint>[];
    for (int i = 0; i < days; i++) {
      final DateTime day = start.add(Duration(days: i));
      points.add(ZikirStatPoint(date: day, count: totals[_dateKey(day)] ?? 0));
    }
    return points;
  }

  /// Zikir bazında toplam istatistik.
  Future<Map<String, int>> totalsByZikir({int days = 30}) async {
    final DateTime start = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'zikir_daily',
      where: 'date >= ?',
      whereArgs: <Object?>[_dateKey(start)],
    );
    final Map<String, int> totals = <String, int>{};
    for (final Map<String, Object?> row in rows) {
      final String key = row['zikir_key']! as String;
      totals[key] = (totals[key] ?? 0) + ((row['count'] as num?)?.toInt() ?? 0);
    }
    return totals;
  }

  /// Tüm zamanların toplamı.
  Future<int> totalCount() async {
    final List<Map<String, Object?>> dailyRows = await _database.raw.rawQuery(
      'SELECT COALESCE(SUM(count), 0) AS total FROM zikir_daily',
    );
    final List<Map<String, Object?>> sessionRows = await _database.raw.rawQuery(
      'SELECT COALESCE(SUM(count), 0) AS total FROM zikir_sessions',
    );
    final int dailyTotal = (dailyRows.first['total'] as num?)?.toInt() ?? 0;
    final int sessionTotal = (sessionRows.first['total'] as num?)?.toInt() ?? 0;
    return dailyTotal >= sessionTotal ? dailyTotal : sessionTotal;
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
