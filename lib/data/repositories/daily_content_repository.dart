import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../core/constants/app_constants.dart';
import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../models/hadith_models.dart';
import '../models/quran_models.dart';
import 'hadith_repository.dart';
import 'quran_repository.dart';
import 'zikir_repository.dart';

/// Günün ayeti, hadisi ve duası.
///
/// Seçimler cihaz üzerinde deterministik olarak yapılır (aynı gün her açılışta
/// aynı içerik gelir) ve gün sonuna kadar önbelleğe alınır; böylece internet
/// olmadan da ana ekran içerikleri eksiksiz görünür.
class DailyContentRepository {
  DailyContentRepository(
    this._database,
    this._quran,
    this._hadith,
    this._zikir,
  );

  final AppDatabase _database;
  final QuranRepository _quran;
  final HadithRepository _hadith;
  final ZikirRepository _zikir;

  /// Günün içeriği (ayet + hadis + dua).
  Future<DailyContent> load(DateTime date) async {
    final DateTime day = DateTime(date.year, date.month, date.day);
    final DailyContent? cached = await _fromCache(day);
    if (cached != null && !_isStale(cached)) return cached;

    final DailyContent fresh = DailyContent(
      date: day,
      verse: await dailyVerse(day),
      hadith: await _hadith.dailyHadith(day),
      dua: await _zikir.dailyDua(day),
      fetchedAt: DateTime.now(),
      source: 'local',
    );
    await _save(fresh);
    return fresh;
  }

  /// Günün ayeti — Kur'an'ın tamamından dengeli bir seçim.
  Future<DailyAyah?> dailyVerse(DateTime date) async {
    final List<Surah> surahs = await _quran.surahs();
    if (surahs.isEmpty) return null;
    final int dayIndex =
        date.difference(DateTime(date.year)).inDays + date.year * 97;
    // Uzun surelerden ve kısa surelerden dengeli seçim yapılır.
    final List<Surah> pool =
        surahs.where((Surah s) => s.verseCount >= 3).toList();
    final Surah surah = pool[dayIndex % pool.length];
    final SurahContent content = await _quran.loadSurah(surah.number);
    if (content.ayahs.isEmpty) return null;
    final int ayahIndex = (dayIndex * 7) % content.ayahs.length;
    return DailyAyah(ayah: content.ayahs[ayahIndex], surah: surah);
  }

  /// Rastgele ayet (keşfet).
  Future<DailyAyah?> randomVerse({int? surahNumber}) async {
    final List<Surah> surahs = await _quran.surahs();
    if (surahs.isEmpty) return null;
    final Surah surah = surahNumber == null
        ? surahs[DateTime.now().microsecond % surahs.length]
        : surahs.firstWhere((Surah s) => s.number == surahNumber,
            orElse: () => surahs.first);
    final SurahContent content = await _quran.loadSurah(surah.number);
    if (content.ayahs.isEmpty) return null;
    return DailyAyah(
      ayah: content.ayahs[DateTime.now().millisecond % content.ayahs.length],
      surah: surah,
    );
  }

  // ------------------------------------------------------------- Önbellek

  Future<DailyContent?> _fromCache(DateTime day) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'daily_content_cache',
      where: 'date = ?',
      whereArgs: <Object?>[_dateKey(day)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final Map<String, Object?> row = rows.first;
    try {
      final Map<String, Object?>? verseJson = _decode(row['verse'] as String?);
      final Map<String, Object?>? hadithJson =
          _decode(row['hadith'] as String?);
      final Map<String, Object?>? duaJson = _decode(row['dua'] as String?);
      return DailyContent(
        date: day,
        verse: verseJson == null ? null : DailyAyah.fromCache(verseJson),
        hadith: hadithJson == null ? null : _hadithFromCache(hadithJson),
        dua: duaJson,
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(
            (row['fetched_at'] as num?)?.toInt() ?? 0),
        source: 'cache',
      );
    } catch (error) {
      AppLog.warning('Günün içeriği önbelleği okunamadı', error: error);
      return null;
    }
  }

  Future<void> _save(DailyContent content) async {
    await _database.raw.insert(
      'daily_content_cache',
      <String, Object?>{
        'date': _dateKey(content.date),
        'verse':
            content.verse == null ? null : jsonEncode(content.verse!.toCache()),
        'hadith': content.hadith == null
            ? null
            : jsonEncode(_hadithToCache(content.hadith!)),
        'dua': content.dua == null ? null : jsonEncode(content.dua),
        'fetched_at': content.fetchedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _hadithToCache(Hadith hadith) => <String, Object?>{
        'id': hadith.id,
        'ar': hadith.arabic,
        'tr': hadith.turkish,
        'ref': hadith.reference,
        'src': hadith.primarySource,
        'topics': hadith.topics,
      };

  Hadith _hadithFromCache(Map<String, Object?> json) => Hadith(
        id: (json['id'] as num).toInt(),
        arabic: json['ar'] as String? ?? '',
        turkish: json['tr'] as String? ?? '',
        reference: json['ref'] as String? ?? '',
        primarySource: json['src'] as String? ?? '',
        topics: (json['topics'] as List<Object?>?)?.cast<String>() ??
            const <String>['Genel'],
      );

  Map<String, Object?>? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final Object? decoded = jsonDecode(raw);
    if (decoded is Map) return decoded.cast<String, Object?>();
    return null;
  }

  bool _isStale(DailyContent content) =>
      DateTime.now().difference(content.fetchedAt) >
      AppConstants.dailyContentTtl;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Günün ayeti ve sure bilgisi.
class DailyAyah {
  const DailyAyah({required this.ayah, required this.surah});

  final Ayah ayah;
  final Surah surah;

  Map<String, Object?> toCache() => <String, Object?>{
        's': surah.number,
        'n': ayah.number,
        'ar': ayah.arabic,
        'tr': ayah.turkish,
        'surahName': surah.nameTurkish,
        'meaning': surah.meaning,
        'revelation': surah.revelation,
        'verseCount': surah.verseCount,
        'translit': surah.transliteration,
        'nameAr': surah.nameArabic,
      };

  factory DailyAyah.fromCache(Map<String, Object?> json) => DailyAyah(
        surah: Surah(
          number: (json['s'] as num).toInt(),
          nameArabic: json['nameAr'] as String? ?? '',
          nameTurkish: json['surahName'] as String? ?? '',
          meaning: json['meaning'] as String? ?? '',
          transliteration: json['translit'] as String? ?? '',
          verseCount: (json['verseCount'] as num?)?.toInt() ?? 0,
          revelation: json['revelation'] as String? ?? 'Mekke',
          juzStart: null,
        ),
        ayah: Ayah(
          surah: (json['s'] as num).toInt(),
          number: (json['n'] as num).toInt(),
          arabic: json['ar'] as String? ?? '',
          turkish: json['tr'] as String? ?? '',
        ),
      );

  String shareText() {
    final StringBuffer buffer = StringBuffer()
      ..writeln(ayah.arabic)
      ..writeln()
      ..writeln(ayah.turkish)
      ..writeln()
      ..write('— ${surah.nameTurkish} Suresi, ${ayah.number}. ayet (EzanAI)');
    return buffer.toString();
  }
}

/// Günün tüm içeriği.
class DailyContent {
  const DailyContent({
    required this.date,
    required this.verse,
    required this.hadith,
    required this.dua,
    required this.fetchedAt,
    required this.source,
  });

  final DateTime date;
  final DailyAyah? verse;
  final Hadith? hadith;
  final Map<String, Object?>? dua;
  final DateTime fetchedAt;
  final String source;
}
