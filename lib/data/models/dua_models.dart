import 'package:flutter/foundation.dart';

import '../../core/utils/text_normalizer.dart';

/// Dua modeli.
///
/// Her duada **kaynak künyesi** (`reference`) ve kategori zorunludur; arayüzde
/// künye her zaman gösterilir (hadis ve AI içeriğiyle aynı ilke).
@immutable
class Dua {
  const Dua({
    required this.key,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.reference,
    required this.category,
    this.time,
  });

  /// Kararlı kimlik (favoriler ve günlük seçim bunu kullanır).
  final String key;
  final String name;

  /// Arapça metin (boş olabilir; o zaman yalnızca okunuş/meal gösterilir).
  final String arabic;

  /// Latin harfli okunuş.
  final String transliteration;

  /// Türkçe anlamı.
  final String meaning;

  /// Kaynak künyesi (ör. "Buhârî, Deavât 7").
  final String reference;

  /// Kategori kimliği (`duaCategories` ile eşleşir).
  final String category;

  /// Okunması önerilen zaman (ör. "Sabah ve akşam").
  final String? time;

  factory Dua.fromJson(Map<String, Object?> json) => Dua(
    key: (json['key'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    arabic: (json['arabic'] ?? '').toString(),
    transliteration: (json['transliteration'] ?? '').toString(),
    meaning: (json['meaning'] ?? '').toString(),
    reference: (json['reference'] ?? '').toString(),
    category: (json['category'] ?? otherCategory).toString(),
    time: json['time']?.toString(),
  );

  /// Kategorisi eksik kayıtlar için güvenli varsayılan.
  static const String otherCategory = 'diger';

  /// Aramada kullanılacak düz metin (okunuş + anlam + ad).
  String get searchText => '$name $transliteration $meaning $reference';

  /// Paylaşım metni — künye her zaman eklenir.
  String shareText() {
    final StringBuffer buffer = StringBuffer()
      ..writeln(name)
      ..writeln();
    if (arabic.isNotEmpty) {
      buffer
        ..writeln(arabic)
        ..writeln();
    }
    if (transliteration.isNotEmpty) {
      buffer
        ..writeln(transliteration)
        ..writeln();
    }
    if (meaning.isNotEmpty) {
      buffer
        ..writeln(meaning)
        ..writeln();
    }
    buffer
      ..writeln('Kaynak: $reference')
      ..writeln()
      ..write('(EzanAI ile paylaşıldı)');
    return buffer.toString().trim();
  }

  /// Arama eşleşmesi (diakritik duyarsız, ek toleranslı).
  bool matches(String query) => TextNormalizer.matches(searchText, query);

  bool get hasArabic => arabic.trim().isNotEmpty;
}

/// Dua kategorisi (arayüz sekmeleri).
@immutable
class DuaCategory {
  const DuaCategory({
    required this.key,
    required this.label,
    this.description = '',
  });

  final String key;
  final String label;
  final String description;

  factory DuaCategory.fromJson(Map<String, Object?> json) => DuaCategory(
    key: (json['key'] ?? '').toString(),
    label: (json['label'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
  );
}

/// Kategorilenmiş dua listesi (arayüzün tek girdi modeli).
@immutable
class DuaCatalog {
  const DuaCatalog({required this.categories, required this.dualar});

  final List<DuaCategory> categories;
  final List<Dua> dualar;

  bool get isEmpty => dualar.isEmpty;

  /// Kategorideki dualar.
  List<Dua> byCategory(String categoryKey) =>
      dualar.where((Dua dua) => dua.category == categoryKey).toList();

  /// Metin araması (boş sorgu tüm listeyi döner).
  List<Dua> search(String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return dualar;
    return dualar.where((Dua dua) => dua.matches(trimmed)).toList();
  }

  /// Bir duayı kimliğinden bulur.
  Dua? byKey(String key) {
    for (final Dua dua in dualar) {
      if (dua.key == key) return dua;
    }
    return null;
  }
}
