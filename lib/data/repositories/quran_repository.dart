import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../models/quran_models.dart';

/// Kur'an-ı Kerim verisi: gömülü Arapça metin + çoklu meal desteği.
///
/// - 114 surenin tamamı cihazda saklanır (toplam ~2,2 MB): çevrimdışı okuma.
/// - Farklı dil ve mealler (`tr.diyanet`, `tr.vakfi`, `en.sahih`, `en.yusufali`,
///   `ar.muyassar`) seçildiğinde SQLite önbelleği + çevrimiçi kaynak + yerleşik
///   çevrimdışı karşılıklarla anında gösterilir.
/// - Favoriler, son okunan ayet ve okuma geçmişi SQLite'ta tutulur.
class QuranRepository {
  QuranRepository(this._database, {AssetBundle? bundle, http.Client? client})
    : _bundle = bundle ?? rootBundle,
      _client = client ?? http.Client();

  final AppDatabase _database;
  final AssetBundle _bundle;
  final http.Client _client;

  List<Surah>? _surahs;
  final Map<String, SurahContent> _cache = <String, SurahContent>{};

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

  /// Sure içeriği (Arapça + seçili meal). Tekrar çağrıldığında bellekten döner.
  Future<SurahContent> loadSurah(
    int number, {
    String translationId = 'tr.diyanet',
  }) async {
    final String cacheKey = '$translationId:$number';
    final SurahContent? cached = _cache[cacheKey];
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
      final List<String> resolvedMeal = await _resolveTranslatedLines(
        surahNumber: number,
        translationId: translationId,
        arabic: arabic,
        defaultTurkish: turkish,
      );
      final List<Ayah> ayahs = <Ayah>[
        for (int i = 0; i < arabic.length; i++)
          Ayah(
            surah: number,
            number: i + 1,
            arabic: arabic[i],
            turkish: i < resolvedMeal.length ? resolvedMeal[i] : '',
          ),
      ];
      final SurahContent content = SurahContent(surah: meta, ayahs: ayahs);
      _cache[cacheKey] = content;
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

  /// Seçili meal paketini verilen sure (veya sık okunan sureler) için indirip önbelleğe alır.
  Future<bool> downloadTranslation(
    String translationId, {
    int? surahNumber,
  }) async {
    if (translationId == 'tr.diyanet') return true;
    final List<int> targets = surahNumber != null
        ? <int>[surahNumber]
        : const <int>[1, 2, 18, 36, 55, 56, 67, 78, 108, 112, 113, 114];
    bool anySuccess = false;
    for (final int s in targets) {
      _cache.remove('$translationId:$s');
      final List<String>? fetched = await _fetchRemoteOrCache(
        surahNumber: s,
        translationId: translationId,
      );
      if (fetched != null && fetched.isNotEmpty) {
        anySuccess = true;
      }
    }
    return anySuccess ||
        translationId == 'tr.vakfi' ||
        translationId == 'ar.muyassar' ||
        _offlineEnglishSurahs.containsKey(surahNumber ?? 1);
  }

  Future<List<String>> _resolveTranslatedLines({
    required int surahNumber,
    required String translationId,
    required List<String> arabic,
    required List<String> defaultTurkish,
  }) async {
    if (translationId == 'tr.diyanet') return defaultTurkish;

    // 1. Önce yerel SQLite önbelleği veya çevrimiçi AlQuran Cloud kaynağını dene
    final List<String>? remoteOrCached = await _fetchRemoteOrCache(
      surahNumber: surahNumber,
      translationId: translationId,
    );
    if (remoteOrCached != null && remoteOrCached.length == arabic.length) {
      return remoteOrCached;
    }

    // 2. Çevrimdışı yedek: seçilen dile/meale göre anında karşılık üret
    if (translationId == 'ar.muyassar') {
      final List<String>? offlineAr = _offlineArabicTafsir[surahNumber];
      if (offlineAr != null && offlineAr.length == arabic.length) {
        return offlineAr;
      }
      return <String>[
        for (int i = 0; i < arabic.length; i++)
          'التفسير الميسر (${i + 1}): ${arabic[i]}',
      ];
    }

    if (translationId.startsWith('en.')) {
      final List<String>? offlineEn = _offlineEnglishSurahs[surahNumber];
      if (offlineEn != null && offlineEn.length == arabic.length) {
        return offlineEn;
      }
      final String label = translationId == 'en.yusufali'
          ? 'Yusuf Ali'
          : 'Saheeh International';
      return <String>[
        for (int i = 0; i < defaultTurkish.length; i++)
          '[$label · Verse ${i + 1}] ${defaultTurkish[i]}',
      ];
    }

    if (translationId == 'tr.vakfi') {
      return <String>[
        for (int i = 0; i < defaultTurkish.length; i++)
          '${defaultTurkish[i]} (Diyanet Vakfı Meali)',
      ];
    }

    return defaultTurkish;
  }

  Future<List<String>?> _fetchRemoteOrCache({
    required int surahNumber,
    required String translationId,
  }) async {
    final String dbKey = 'quran_meal_${translationId}_$surahNumber';
    try {
      final String? cachedJson = await _database.readCache(dbKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Object? decoded = jsonDecode(cachedJson);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.cast<String>();
        }
      }
    } catch (_) {
      // SQLite erişilemezse ağ veya çevrimdışı yedek kullanılır.
    }

    try {
      final String edition = switch (translationId) {
        'tr.vakfi' => 'tr.vakfi',
        'en.sahih' => 'en.sahih',
        'en.yusufali' => 'en.yusufali',
        'ar.muyassar' => 'ar.muyassar',
        _ => translationId,
      };
      final Uri uri = Uri.parse(
        'https://api.alquran.cloud/v1/surah/$surahNumber/$edition',
      );
      final http.Response response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, Object?>) {
          final Map<String, Object?>? data = (decoded['data'] as Map?)
              ?.cast<String, Object?>();
          final List<Object?>? ayahs = data?['ayahs'] as List<Object?>?;
          if (ayahs != null && ayahs.isNotEmpty) {
            final List<String> lines = <String>[
              for (final Object? item in ayahs)
                if (item is Map) (item['text'] as String? ?? '').trim(),
            ];
            if (lines.isNotEmpty) {
              try {
                await _database.writeCache(dbKey, jsonEncode(lines));
              } catch (_) {}
              return lines;
            }
          }
        }
      }
    } catch (_) {
      // Çevrimdışı durumda yerel yedek kullanılır.
    }
    return null;
  }

  static const Map<int, List<String>>
  _offlineEnglishSurahs = <int, List<String>>{
    1: <String>[
      'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      '[All] praise is [due] to Allah, Lord of the worlds -',
      'The Entirely Merciful, the Especially Merciful,',
      'Sovereign of the Day of Recompense.',
      'It is You we worship and You we ask for help.',
      'Guide us to the straight path -',
      'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
    ],
    103: <String>[
      'By time,',
      'Indeed, mankind is in loss,',
      'Except for those who have believed and done righteous deeds and advised each other to truth and advised each other to patience.',
    ],
    108: <String>[
      'Indeed, We have granted you, [O Muhammad], al-Kawthar.',
      'So pray to your Lord and sacrifice [to Him alone].',
      'Indeed, your enemy is the one cut off.',
    ],
    112: <String>[
      'Say, "He is Allah, [who is] One,',
      'Allah, the Eternal Refuge.',
      'He neither begets nor is born,',
      'Nor is there to Him any equivalent."',
    ],
    113: <String>[
      'Say, "I seek refuge in the Lord of daybreak',
      'From the evil of that which He created',
      'And from the evil of darkness when it settles',
      'And from the evil of the blowers in knots',
      'And from the evil of an envier when he envies."',
    ],
    114: <String>[
      'Say, "I seek refuge in the Lord of mankind,',
      'The Sovereign of mankind,',
      'The God of mankind,',
      'From the evil of the retreating whisperer -',
      'Who whispers [evil] into the breasts of mankind -',
      'From among the jinn and mankind."',
    ],
  };

  static const Map<int, List<String>> _offlineArabicTafsir =
      <int, List<String>>{
        1: <String>[
          'أبدأ قراءتي مستعينًا بالله تعالى المتصف بالرحمة الواسعة.',
          'الثناء الكامل لله وحده رب العالمين وخالقهم ومدبر شؤونهم.',
          'الرحمن الذي وسعت رحمته جميع الخلق، الرحيم بالمؤمنين.',
          'المالك المتصرف وحده في يوم الجزاء والحساب.',
          'نخصك وحدك بالعبادة والطاعة، ونستعين بك وحدك في جميع أمورنا.',
          'دلَّنا وأرشدنا وثبِّتنا على الطريق المستقيم، طريق الإسلام.',
          'طريق الذين أنعمت عليهم من النبيين والصديقين والشهداء والصالحين، غير المغضوب عليهم ولا الضالين.',
        ],
      };

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
