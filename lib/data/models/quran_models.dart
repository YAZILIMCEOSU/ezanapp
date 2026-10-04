import 'package:flutter/foundation.dart';

/// Sure bilgisi (uygulama içi gömülü meta veri).
@immutable
class Surah {
  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameTurkish,
    required this.meaning,
    required this.transliteration,
    required this.verseCount,
    required this.revelation,
    required this.juzStart,
  });

  final int number;
  final String nameArabic;
  final String nameTurkish;
  final String meaning;
  final String transliteration;
  final int verseCount;

  /// "Mekke" / "Medine"
  final String revelation;

  /// Bu surenin başladığı cüz (yoksa null).
  final int? juzStart;

  bool get isMeccan => revelation == 'Mekke';

  String get label => '$number. $nameTurkish';

  String get subtitle => '$meaning • $verseCount ayet • $revelation';

  factory Surah.fromJson(Map<String, Object?> json) => Surah(
        number: json['n'] as int,
        nameArabic: json['nameAr'] as String,
        nameTurkish: json['nameTr'] as String,
        meaning: json['meaningTr'] as String? ?? '',
        transliteration: json['translit'] as String? ?? '',
        verseCount: json['verses'] as int,
        revelation: json['revelation'] as String? ?? 'Mekke',
        juzStart: json['juzStart'] as int?,
      );
}

/// Tek bir ayet (Arapça + Türkçe meal + isteğe bağlı okunuş).
@immutable
class Ayah {
  const Ayah({
    required this.surah,
    required this.number,
    required this.arabic,
    required this.turkish,
  });

  final int surah;
  final int number;
  final String arabic;
  final String turkish;

  String get reference => '$surah:$number';

  /// Surenin başında besmele olup olmadığını anlamak için kullanılır.
  static const String bismillahArabic =
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  @override
  bool operator ==(Object other) =>
      other is Ayah && other.surah == surah && other.number == number;

  @override
  int get hashCode => Object.hash(surah, number);
}

/// Bir surenin tamamı.
@immutable
class SurahContent {
  const SurahContent({required this.surah, required this.ayahs});

  final Surah surah;
  final List<Ayah> ayahs;

  bool get isEmpty => ayahs.isEmpty;
}

/// Kur'an okuma yer imi.
@immutable
class QuranBookmark {
  const QuranBookmark({
    required this.surah,
    required this.number,
    required this.createdAt,
    this.note,
  });

  final int surah;
  final int number;
  final DateTime createdAt;
  final String? note;

  String get reference => '$surah:$number';

  factory QuranBookmark.fromRow(Map<String, Object?> row) => QuranBookmark(
        surah: row['surah']! as int,
        number: row['ayah']! as int,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
        note: row['note'] as String?,
      );
}

/// Sure bazında okuma ilerlemesi.
@immutable
class ReadingProgress {
  const ReadingProgress({
    required this.surah,
    required this.lastAyah,
    required this.readAt,
  });

  final int surah;
  final int lastAyah;
  final DateTime readAt;

  factory ReadingProgress.fromRow(Map<String, Object?> row) => ReadingProgress(
        surah: row['surah']! as int,
        lastAyah: row['last_ayah']! as int,
        readAt: DateTime.fromMillisecondsSinceEpoch(row['read_at']! as int),
      );
}

/// Kur'an tilavet okuyucusu (reciter).
@immutable
class Reciter {
  const Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.style,
    required this.bitrateFolder,
  });

  final String id;
  final String name;
  final String arabicName;

  /// "Murattal" / "Mücevved"
  final String style;

  /// Ses sunucusundaki klasör adı (ör. "128" veya "192").
  final String bitrateFolder;

  bool get isHighQuality => bitrateFolder != '64';
}

/// Uygulamada sunulan okuyucular (açık lisanslı, yaygın kullanılan tilavetler).
abstract final class Reciters {
  static const String baseUrl = 'https://everyayah.com/data';

  static const List<Reciter> all = <Reciter>[
    Reciter(
        id: 'ar.alafasy',
        name: 'Mishary Rashid Alafasy',
        arabicName: 'مشاري العفاسي',
        style: 'Murattal',
        bitrateFolder: 'Alafasy_128kbps'),
    Reciter(
        id: 'ar.abdulbasitmurattal',
        name: 'Abdul Basit (Murattal)',
        arabicName: 'عبد الباسط',
        style: 'Murattal',
        bitrateFolder: 'Abdul_Basit_Murattal_192kbps'),
    Reciter(
        id: 'ar.husary',
        name: 'Mahmoud Khalil Al-Husary',
        arabicName: 'محمود الحصري',
        style: 'Murattal',
        bitrateFolder: 'Husary_128kbps'),
    Reciter(
        id: 'ar.minshawi',
        name: 'Mohamed Siddiq El-Minshawi',
        arabicName: 'محمد المنشاوي',
        style: 'Murattal',
        bitrateFolder: 'Minshawy_Murattal_128kbps'),
    Reciter(
        id: 'ar.mahermuaiqly',
        name: 'Maher Al Muaiqly',
        arabicName: 'ماهر المعيقلي',
        style: 'Murattal',
        bitrateFolder: 'Maher_AlMuaiqly_64kbps'),
    Reciter(
        id: 'ar.shaatree',
        name: 'Abu Bakr Ash-Shaatree',
        arabicName: 'أبو بكر الشاطري',
        style: 'Murattal',
        bitrateFolder: 'Abu_Bakr_Ash-Shaatree_128kbps'),
    Reciter(
        id: 'ar.hudhaify',
        name: 'Ali Al-Hudhaify',
        arabicName: 'علي الحذيفي',
        style: 'Murattal',
        bitrateFolder: 'Hudhaify_128kbps'),
    Reciter(
        id: 'ar.shaikhsudays',
        name: 'Abdurrahman As-Sudais',
        arabicName: 'عبد الرحمن السديس',
        style: 'Murattal',
        bitrateFolder: 'Abdurrahmaan_As-Sudais_192kbps'),
  ];

  static Reciter byId(String? id) =>
      all.firstWhere((Reciter r) => r.id == id, orElse: () => all.first);

  /// Tek ayet ses dosyası adresi (EveryAyah — herkese açık tilavet arşivi).
  static String ayahUrl(Reciter reciter, int surah, int ayah) {
    final String s = surah.toString().padLeft(3, '0');
    final String a = ayah.toString().padLeft(3, '0');
    return '$baseUrl/${reciter.bitrateFolder}/$s$a.mp3';
  }
}
