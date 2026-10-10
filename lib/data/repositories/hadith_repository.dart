import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/text_normalizer.dart';
import '../models/hadith_models.dart';

/// Hadis verisi: Riyâzü's-sâlihîn (1900 hadis, Arapça + Türkçe + kaynak künyesi).
///
/// Hadisler gömülüdür: çevrimdışı okunur, aranır ve favorilere eklenir.
class HadithRepository {
  HadithRepository(this._database, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AppDatabase _database;
  final AssetBundle _bundle;

  HadithCollection? _collection;
  List<Hadith>? _hadiths;
  List<Hadith>? _dailyPool;

  Future<HadithCollection> collection() async {
    await _ensureLoaded();
    return _collection!;
  }

  Future<List<Hadith>> all() async {
    await _ensureLoaded();
    return _hadiths!;
  }

  Future<void> _ensureLoaded() async {
    if (_hadiths != null) return;
    try {
      final String raw = await _bundle.loadString(
        'assets/data/hadith_riyazus_salihin.json',
      );
      final Map<String, Object?> json = (jsonDecode(raw) as Map)
          .cast<String, Object?>();
      _collection = HadithCollection.fromJson(json);
      final List<Object?> items = (json['hadiths'] as List?) ?? <Object?>[];
      _hadiths = items
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                Hadith.fromJson(m.cast<String, Object?>()),
          )
          .toList();
      _dailyPool = _hadiths!
          .where(
            (Hadith h) => h.turkish.length > 180 && h.turkish.length < 1200,
          )
          .toList();
      AppLog.debug('Hadis verisi yüklendi: ${_hadiths!.length} kayıt');
    } catch (error, stackTrace) {
      AppLog.error(
        'Hadis verisi yüklenemedi',
        error: error,
        stackTrace: stackTrace,
      );
      _collection = const HadithCollection(
        name: 'Riyâzü\'s-sâlihîn',
        author: '',
        translator: '',
        count: 0,
        topics: <String>[],
        note: '',
      );
      _hadiths = <Hadith>[];
      _dailyPool = <Hadith>[];
    }
  }

  /// Belirli bir hadis.
  Future<Hadith?> byId(int id) async {
    await _ensureLoaded();
    for (final Hadith hadith in _hadiths!) {
      if (hadith.id == id) return hadith;
    }
    return null;
  }

  /// Günün hadisi: aynı gün içinde deterministik seçim yapılır.
  Future<Hadith?> dailyHadith(DateTime date) async {
    await _ensureLoaded();
    final List<Hadith> pool = (_dailyPool?.isNotEmpty ?? false)
        ? _dailyPool!
        : _hadiths!;
    if (pool.isEmpty) return null;
    final int dayIndex = _dayOfYear(date);
    final int index = ((dayIndex * 7919) + date.year * 31) % pool.length;
    return pool[index];
  }

  /// Rastgele hadis (keşfet butonu).
  Future<Hadith?> random({math.Random? random}) async {
    await _ensureLoaded();
    final List<Hadith> pool = (_dailyPool?.isNotEmpty ?? false)
        ? _dailyPool!
        : _hadiths!;
    if (pool.isEmpty) return null;
    return pool[(random ?? math.Random()).nextInt(pool.length)];
  }

  /// Konuya göre hadisler.
  Future<List<Hadith>> byTopic(String topic) async {
    await _ensureLoaded();
    if (topic == 'Tümü') return _hadiths!;
    return _hadiths!.where((Hadith h) => h.topics.contains(topic)).toList();
  }

  /// Hadis arama: Türkçe metin, Arapça metin ve kaynak künyesinde arar.
  Future<List<Hadith>> search(String query) async {
    await _ensureLoaded();
    final String needle = normalize(query);
    if (needle.length < 2) return <Hadith>[];
    return _hadiths!
        .where(
          (Hadith h) =>
              normalize(h.turkish).contains(needle) ||
              h.arabic.contains(query.trim()) ||
              normalize(h.reference).contains(needle) ||
              normalize(h.primarySource).contains(needle),
        )
        .toList();
  }

  /// Türkçe diakritik duyarsız normalizasyon (ortak yardımcıya devreder).
  static String normalize(String value) => TextNormalizer.normalize(value);

  // ------------------------------------------------------------- Favoriler

  Future<Set<int>> favoriteIds() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'hadith_favorites',
    );
    return rows
        .map((Map<String, Object?> row) => row['hadith_id']! as int)
        .toSet();
  }

  Future<List<Hadith>> favorites() async {
    final Set<int> ids = await favoriteIds();
    await _ensureLoaded();
    return _hadiths!.where((Hadith h) => ids.contains(h.id)).toList();
  }

  Future<bool> toggleFavorite(int id) async {
    final bool exists = (await _database.raw.query(
      'hadith_favorites',
      where: 'hadith_id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    )).isNotEmpty;
    if (exists) {
      await _database.raw.delete(
        'hadith_favorites',
        where: 'hadith_id = ?',
        whereArgs: <Object?>[id],
      );
      return false;
    }
    await _database.raw.insert('hadith_favorites', <String, Object?>{
      'hadith_id': id,
      'collection': 'riyazus_salihin',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  static int _dayOfYear(DateTime date) =>
      date.difference(DateTime(date.year)).inDays + 1;
}
