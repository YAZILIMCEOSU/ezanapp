import 'package:flutter/foundation.dart';

/// Hadis modeli.
///
/// Her hadiste kaynak künyesi (`ref`) ve birincil kaynak (`src`) açıkça
/// saklanır; arayüzde her zaman gösterilir.
@immutable
class Hadith {
  const Hadith({
    required this.id,
    required this.arabic,
    required this.turkish,
    required this.reference,
    required this.primarySource,
    required this.topics,
  });

  final int id;
  final String arabic;
  final String turkish;

  /// Künye: "Buhârî, Îmân 41; Müslim, Îmân 155" gibi.
  final String reference;

  /// Birincil kaynak adı (Buhârî, Müslim…).
  final String primarySource;

  final List<String> topics;

  factory Hadith.fromJson(Map<String, Object?> json) {
    final String rawSrc = (json['src'] as String? ?? '').trim();
    return Hadith(
      id: json['id'] as int,
      arabic: json['ar'] as String? ?? '',
      turkish: json['tr'] as String? ?? '',
      reference: json['ref'] as String? ?? '',
      primarySource: rawSrc.isEmpty ? 'Riyâzü\'s-sâlihîn' : rawSrc,
      topics:
          (json['topics'] as List<Object?>?)?.cast<String>() ??
          const <String>['Genel'],
    );
  }

  /// Konu/bölüm başlığını seçili arayüz dilinde temiz olarak döner.
  static String localizedTopic(String topic, String localeCode) {
    if (localeCode == 'en') {
      return switch (topic) {
        'Tümü' => 'All',
        'Ahiret ve Hesap' => 'Hereafter & Accountability',
        'Ahlak ve Edep' => 'Character & Etiquette',
        'Aile ve Akrabalık' => 'Family & Kinship',
        'Fazilet ve İbadet' => 'Virtues & Worship',
        'Genel' => 'General',
        'Helal Kazanç ve Ticaret' => 'Halal Livelihood & Trade',
        'Komşuluk ve Muamelat' => 'Neighborliness & Social Conduct',
        'Namaz' => 'Prayer (Salah)',
        'Oruç ve Ramazan' => 'Fasting & Ramadan',
        'Temizlik ve Sağlık' => 'Purification & Health',
        'Zikir ve Dua' => 'Dhikr & Supplication',
        'İhlas ve Kalp' => 'Sincerity & Heart',
        'İlim ve Öğrenme' => 'Knowledge & Learning',
        _ => topic,
      };
    }
    if (localeCode == 'ar') {
      return switch (topic) {
        'Tümü' => 'الكل',
        'Ahiret ve Hesap' => 'الآخرة والحساب',
        'Ahlak ve Edep' => 'الأخلاق والآداب',
        'Aile ve Akrabalık' => 'الأسرة وصلة الرحم',
        'Fazilet ve İbadet' => 'الفضائل والعبادات',
        'Genel' => 'عام',
        'Helal Kazanç ve Ticaret' => 'الكسب الحلال والتجارة',
        'Komşuluk ve Muamelat' => 'الجوار والمعاملات',
        'Namaz' => 'الصلاة',
        'Oruç ve Ramazan' => 'الصوم ورمضان',
        'Temizlik ve Sağlık' => 'الطهارة والصحة',
        'Zikir ve Dua' => 'الذكر والدعاء',
        'İhlas ve Kalp' => 'الإخلاص وأعمال القلوب',
        'İlim ve Öğrenme' => 'العلم والتعلم',
        _ => topic,
      };
    }
    return topic;
  }

  /// Meali kısaltılmış özet (ana ekran kartları için).
  String get shortTurkish {
    final String flat = turkish.replaceAll('\n\n', ' ').replaceAll('\n', ' ');
    return flat.length <= 220 ? flat : '${flat.substring(0, 218)}…';
  }

  /// Paylaşım metni.
  String shareText() {
    final StringBuffer buffer = StringBuffer();
    if (arabic.isNotEmpty) {
      buffer
        ..writeln(arabic)
        ..writeln();
    }
    buffer
      ..writeln(turkish)
      ..writeln();
    if (reference.isNotEmpty) {
      buffer
        ..writeln('Kaynak: $reference')
        ..writeln();
    }
    buffer.write('— Riyâzü\'s-sâlihîn, $id. hadis (EzanAI)');
    return buffer.toString();
  }
}

/// Hadis koleksiyonu meta bilgisi.
@immutable
class HadithCollection {
  const HadithCollection({
    required this.name,
    required this.author,
    required this.translator,
    required this.count,
    required this.topics,
    required this.note,
  });

  final String name;
  final String author;
  final String translator;
  final int count;
  final List<String> topics;
  final String note;

  factory HadithCollection.fromJson(Map<String, Object?> json) =>
      HadithCollection(
        name: json['collection'] as String? ?? '',
        author: json['author'] as String? ?? '',
        translator: json['translator'] as String? ?? '',
        count: json['count'] as int? ?? 0,
        topics:
            (json['topics'] as List<Object?>?)?.cast<String>() ??
            const <String>[],
        note: json['note'] as String? ?? '',
      );
}

/// Günün hadisi seçimi.
@immutable
class DailyHadith {
  const DailyHadith({required this.hadith, required this.pickedAt});

  final Hadith hadith;
  final DateTime pickedAt;
}
