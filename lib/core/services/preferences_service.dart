import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Tercihler için ince bir sarmalayıcı.
///
/// Tüm okuma/yazmalar tek noktadan geçer; böylece test edilebilirlik ve
/// hata toleransı sağlanır (bozuk JSON uygulamayı çökertmez).
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async =>
      PreferencesService(await SharedPreferences.getInstance());

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  double getDouble(String key, {double defaultValue = 0}) {
    try {
      return _prefs.getDouble(key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<String> getStringList(String key) {
    try {
      return _prefs.getStringList(key) ?? <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

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

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clear() => _prefs.clear();

  /// Belirli bir ön ek ile başlayan anahtarları siler (ör. kullanıcı çıkışı).
  Future<void> removeWhere(bool Function(String key) predicate) async {
    final List<String> keys = _prefs.getKeys().where(predicate).toList();
    for (final String key in keys) {
      await _prefs.remove(key);
    }
  }
}
