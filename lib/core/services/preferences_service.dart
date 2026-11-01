import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../utils/logger.dart';

/// Tercihler için ince bir sarmalayıcı.
///
/// Tüm okuma/yazmalar tek noktadan geçer; böylece test edilebilirlik ve
/// hata toleransı sağlanır (bozuk JSON veya platform kanalı hatası
/// uygulamayı çökertmez; SQLite + bellek içi yedek otomatik devreye girer).
class PreferencesService {
  PreferencesService(
    this._prefs, {
    this._database,
    Map<String, Object?>? initialFallback,
  }) {
    if (initialFallback != null) {
      _fallback.addAll(initialFallback);
    }
  }

  final SharedPreferences? _prefs;
  final AppDatabase? _database;
  final Map<String, Object?> _fallback = <String, Object?>{};

  static Future<PreferencesService> create({AppDatabase? database}) async {
    final Map<String, Object?> initialFallback = <String, Object?>{};
    if (database != null) {
      try {
        final List<Map<String, Object?>> rows = await database.raw.query(
          'app_kv_store',
        );
        for (final Map<String, Object?> row in rows) {
          final String? k = row['k'] as String?;
          final String? raw = row['v'] as String?;
          if (k != null && raw != null) {
            try {
              initialFallback[k] = jsonDecode(raw);
            } catch (_) {
              initialFallback[k] = raw;
            }
          }
        }
      } catch (_) {}
    }

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (error) {
      AppLog.warning(
        'SharedPreferences başlatılamadı, SQLite yedek deposu kullanılıyor: $error',
      );
    }
    return PreferencesService(
      prefs,
      database: database,
      initialFallback: initialFallback,
    );
  }

  Future<void> _saveToDb(String key, Object? value) async {
    final AppDatabase? db = _database;
    if (db == null) return;
    try {
      await db.raw.insert('app_kv_store', <String, Object?>{
        'k': key,
        'v': jsonEncode(value),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<void> _removeFromDb(String key) async {
    final AppDatabase? db = _database;
    if (db == null) return;
    try {
      await db.raw.delete(
        'app_kv_store',
        where: 'k = ?',
        whereArgs: <Object?>[key],
      );
    } catch (_) {}
  }

  bool getBool(String key, {bool defaultValue = false}) {
    if (_fallback.containsKey(key)) {
      final Object? mem = _fallback[key];
      if (mem is bool) return mem;
    }
    try {
      final bool? v = _prefs?.getBool(key);
      if (v != null) return v;
    } catch (_) {}
    return defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    _fallback[key] = value;
    await _saveToDb(key, value);
    try {
      await _prefs?.setBool(key, value);
    } catch (_) {}
  }

  int getInt(String key, {int defaultValue = 0}) {
    if (_fallback.containsKey(key)) {
      final Object? mem = _fallback[key];
      if (mem is int) return mem;
    }
    try {
      final int? v = _prefs?.getInt(key);
      if (v != null) return v;
    } catch (_) {}
    return defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    _fallback[key] = value;
    await _saveToDb(key, value);
    try {
      await _prefs?.setInt(key, value);
    } catch (_) {}
  }

  double getDouble(String key, {double defaultValue = 0}) {
    if (_fallback.containsKey(key)) {
      final Object? mem = _fallback[key];
      if (mem is num) return mem.toDouble();
    }
    try {
      final double? v = _prefs?.getDouble(key);
      if (v != null) return v;
    } catch (_) {}
    return defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    _fallback[key] = value;
    await _saveToDb(key, value);
    try {
      await _prefs?.setDouble(key, value);
    } catch (_) {}
  }

  String? getString(String key) {
    if (_fallback.containsKey(key)) {
      final Object? mem = _fallback[key];
      if (mem is String) return mem;
    }
    try {
      final String? v = _prefs?.getString(key);
      if (v != null) return v;
    } catch (_) {}
    return null;
  }

  Future<void> setString(String key, String value) async {
    _fallback[key] = value;
    await _saveToDb(key, value);
    try {
      await _prefs?.setString(key, value);
    } catch (_) {}
  }

  List<String> getStringList(String key) {
    if (_fallback.containsKey(key)) {
      final Object? mem = _fallback[key];
      if (mem is List) {
        return mem.map((Object? e) => '$e').toList();
      }
    }
    try {
      final List<String>? v = _prefs?.getStringList(key);
      if (v != null) return v;
    } catch (_) {}
    return <String>[];
  }

  Future<void> setStringList(String key, List<String> value) async {
    final List<String> copy = List<String>.from(value);
    _fallback[key] = copy;
    await _saveToDb(key, copy);
    try {
      await _prefs?.setStringList(key, copy);
    } catch (_) {}
  }

  /// JSON nesnesi okur; bozuksa null döner.
  Map<String, Object?>? getJson(String key) {
    final String? raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, Object?>();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, Object?> value) =>
      setString(key, jsonEncode(value));

  List<Map<String, Object?>> getJsonList(String key) {
    final String? raw = getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, Object?>>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<Object?, Object?>>()
            .map((Map<Object?, Object?> e) => e.cast<String, Object?>())
            .toList();
      }
      return <Map<String, Object?>>[];
    } catch (_) {
      return <Map<String, Object?>>[];
    }
  }

  Future<void> setJsonList(String key, List<Map<String, Object?>> value) =>
      setString(key, jsonEncode(value));

  Future<void> remove(String key) async {
    _fallback.remove(key);
    await _removeFromDb(key);
    try {
      await _prefs?.remove(key);
    } catch (_) {}
  }

  Future<void> clear() async {
    _fallback.clear();
    final AppDatabase? db = _database;
    if (db != null) {
      try {
        await db.raw.delete('app_kv_store');
      } catch (_) {}
    }
    try {
      await _prefs?.clear();
    } catch (_) {}
  }

  /// Belirli bir ön ek ile başlayan anahtarları siler (ör. kullanıcı çıkışı).
  Future<void> removeWhere(bool Function(String key) predicate) async {
    final Set<String> allKeys = <String>{..._fallback.keys};
    try {
      final Set<String>? prefKeys = _prefs?.getKeys();
      if (prefKeys != null) allKeys.addAll(prefKeys);
    } catch (_) {}
    final List<String> keys = allKeys.where(predicate).toList();
    for (final String key in keys) {
      await remove(key);
    }
  }
}
