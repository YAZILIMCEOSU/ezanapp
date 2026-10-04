import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../models/quran_models.dart';

/// Kur'an-ı Kerim verisi: gömülü Arapça metin + Türkçe meal.
///
/// - 114 surenin tamamı cihazda saklanır (toplam ~2,2 MB): çevrimdışı okuma.
/// - Ayet bazlı arama ve sure listesi yerel olarak çalışır.
/// - Favoriler, son okunan ayet ve okuma geçmişi SQLite'ta tutulur.
class QuranRepository {
  QuranRepository(this._database, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AppDatabase _database;
  final AssetBundle _bundle;

  List<Surah>? _surahs;
  final Map<int, SurahContent> _cache = <int, SurahContent>{};

  /// Sure listesi (tek seferlik yükleme).
  Future<List<Surah>> surahs() async {
    if (_surahs != null) return _surahs!;
    final String raw = await _bundle.loadString('assets/data/surah_meta.json');
    final Map<String, Object?> json = (jsonDecode(raw) as Map)
        .cast<String, Object?>();
    final List<Object?> items = (json['surahs'] as List?) ?? <Object?>[];
    _surahs = items
        .whereType<Map<Object?, Object?>>()
        .map(
          (Map<Object?, Object?> m) =>
              Surah.fromJson(m.cast<String, Object?>()),
        )
        .toList();
    return _surahs!;
  }

  Future<Surah?> surah(int number) async {
    final List<Surah> all = await surahs();
    for (final Surah surah in all) {
      if (surah.number == number) return surah;
    }
    return null;
  }

  /// Sure içeriği (Arapça + Türkçe). Tekrar çağrıldığında bellekten döner.
  Future<SurahContent> loadSurah(int number) async {
    final SurahContent? cached = _cache[number];
    if (cached != null) return cached;
    final Surah? meta = await surah(number);
    if (meta == null) {
      return const SurahContent(
        surah: Surah(
          number: 0,
          nameArabic: '',
          nameTurkish: 'Bilinmeyen',
          meaning: '',
          transliteration: '',
          verseCount: 0,
          revelation: '',
          juzStart: null,
        ),
        ayahs: <Ayah>[],
      );
    }
    try {
      final String raw = await _bundle.loadString(
        'assets/data/quran/$number.json',
      );
      final Map<String, Object?> json = (jsonDecode(raw) as Map)
          .cast<String, Object?>();
      final List<String> arabic = (json['ar'] as List<Object?>).cast<String>();
      final List<String> turkish = (json['tr'] as List<Object?>).cast<String>();
      final List<Ayah> ayahs = <Ayah>[
        for (int i = 0; i < arabic.length; i++)
          Ayah(
            surah: number,
            number: i + 1,
            arabic: arabic[i],
            turkish: i < turkish.length ? turkish[i] : '',
          ),
      ];
      final SurahContent content = SurahContent(surah: meta, ayahs: ayahs);
      _cache[number] = content;
      return content;
    } catch (error, stackTrace) {
      AppLog.error(
        'Sure yüklenemedi: $number',
        error: error,
        stackTrace: stackTrace,
      );
      return SurahContent(surah: meta, ayahs: const <Ayah>[]);
    }
  }

  /// Belirli bir ayet.
  Future<Ayah?> ayah(int surah, int number) async {
    final SurahContent content = await loadSurah(surah);
    for (final Ayah ayah in content.ayahs) {
      if (ayah.number == number) return ayah;
    }
    return null;
  }

  /// Metin arama: Arapça, meal ve sure adı üzerinde çalışır.
  ///
  /// Türkçe aramada diakritik duyarsız (ı/İ/ş/ğ farkı gözetmez) eşleştirme yapılır.
  Future<List<AyahSearchResult>> search(String query, {int limit = 60}) async {
    final String needle = _normalize(query);
    if (needle.length < 2) return <AyahSearchResult>[];
    final List<AyahSearchResult> results = <AyahSearchResult>[];
    final List<Surah> all = await surahs();

    for (final Surah surah in all) {
      if (results.length >= limit) break;
      final bool nameMatches =
          _normalize(surah.nameTurkish).contains(needle) ||
          _normalize(surah.meaning).contains(needle) ||
          surah.transliteration.toLowerCase().contains(needle);
      final SurahContent content = await loadSurah(surah.number);
      for (final Ayah ayah in content.ayahs) {
        if (results.length >= limit) break;
        final bool matches =
            _normalize(ayah.turkish).contains(needle) ||
            ayah.arabic.contains(query.trim()) ||
            (nameMatches && ayah.number == 1);
        if (matches) {
          results.add(
            AyahSearchResult(
              ayah: ayah,
              surah: surah,
              matchedName: nameMatches,
            ),
          );
        }
      }
    }
    return results;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('û', 'u')
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll('’', '')
      .replaceAll("'", '')
      .trim();

  // ---------------------------------------------------------------- Favoriler

  Future<List<QuranBookmark>> bookmarks() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'quran_bookmarks',
      orderBy: 'created_at DESC',
    );
    return rows.map(QuranBookmark.fromRow).toList();
  }

  Future<bool> isBookmarked(int surah, int ayahNumber) async {
    final int count = (await _database.raw.query(
      'quran_bookmarks',
      where: 'surah = ? AND ayah = ?',
      whereArgs: <Object?>[surah, ayahNumber],
      limit: 1,
    )).length;
    return count > 0;
  }

  Future<void> toggleBookmark(int surah, int ayahNumber, {String? note}) async {
    if (await isBookmarked(surah, ayahNumber)) {
      await _database.raw.delete(
        'quran_bookmarks',
        where: 'surah = ? AND ayah = ?',
        whereArgs: <Object?>[surah, ayahNumber],
      );
      return;
    }
    await _database.raw.insert('quran_bookmarks', <String, Object?>{
      'surah': surah,
      'ayah': ayahNumber,
      'note': note,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: null);
  }

  // ------------------------------------------------------------ Okuma geçmişi

  Future<void> saveProgress(int surah, int lastAyah) async {
    await _database.raw.insert('reading_progress', <String, Object?>{
      'surah': surah,
      'last_ayah': lastAyah,
      'read_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ReadingProgress?> lastProgress() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'reading_progress',
      orderBy: 'read_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReadingProgress.fromRow(rows.first);
  }

  Future<List<ReadingProgress>> history({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'reading_progress',
      orderBy: 'read_at DESC',
      limit: limit,
    );
    return rows.map(ReadingProgress.fromRow).toList();
  }

  /// Hatim hedefi için: hangi cüzlerin okunduğu cüz başlangıçlarından hesaplanır.
  Future<int> completedJuzCount() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'reading_progress',
      orderBy: 'read_at DESC',
    );
    final Set<int> juzs = <int>{};
    for (final Map<String, Object?> row in rows) {
      final int surah = row['surah']! as int;
      final int ayah = row['last_ayah']! as int;
      final int juz = _juzOf(surah, ayah);
      if (juz > 0) juzs.add(juz);
    }
    return juzs.length;
  }

  /// Sure/ayet → cüz eşlemesi (standart mushaf tertibi).
  static int _juzOf(int surah, int ayah) {
    for (int i = _juzStarts.length - 1; i >= 0; i--) {
      final (int s, int a) = _juzStarts[i];
      if (surah > s || (surah == s && ayah >= a)) return i + 1;
    }
    return 1;
  }

  static const List<(int, int)> _juzStarts = <(int, int)>[
    (1, 1),
    (2, 142),
    (2, 253),
    (3, 93),
    (4, 24),
    (4, 148),
    (5, 27),
    (6, 111),
    (7, 88),
    (8, 41),
    (9, 93),
    (11, 6),
    (12, 53),
    (15, 1),
    (17, 1),
    (18, 75),
    (21, 1),
    (23, 1),
    (25, 21),
    (27, 56),
    (29, 46),
    (33, 31),
    (36, 28),
    (39, 32),
    (41, 47),
    (46, 1),
    (51, 31),
    (58, 1),
    (67, 1),
    (78, 1),
  ];

  /// Paylaşılabilir metin üretir.
  static String shareText(
    Ayah ayah,
    String surahName, {
    bool withTurkish = true,
  }) {
    final StringBuffer buffer = StringBuffer()
      ..writeln(ayah.arabic)
      ..writeln();
    if (withTurkish) {
      buffer
        ..writeln(ayah.turkish)
        ..writeln();
    }
    buffer.write('— $surahName Suresi, ${ayah.number}. ayet (EzanAI)');
    return buffer.toString();
  }
}

/// Arama sonucu.
class AyahSearchResult {
  const AyahSearchResult({
    required this.ayah,
    required this.surah,
    this.matchedName = false,
  });

  final Ayah ayah;
  final Surah surah;
  final bool matchedName;
}
