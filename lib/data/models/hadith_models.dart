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

  factory Hadith.fromJson(Map<String, Object?> json) => Hadith(
        id: json['id'] as int,
        arabic: json['ar'] as String? ?? '',
        turkish: json['tr'] as String? ?? '',
        reference: json['ref'] as String? ?? '',
        primarySource: json['src'] as String? ?? '',
        topics: (json['topics'] as List<Object?>?)?.cast<String>() ?? const <String>['Genel'],
      );

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
    buffer.write('— Riyâzü\'s-sâlihîn, ${id}. hadis (EzanAI)');
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

  factory HadithCollection.fromJson(Map<String, Object?> json) => HadithCollection(
        name: json['collection'] as String? ?? '',
        author: json['author'] as String? ?? '',
        translator: json['translator'] as String? ?? '',
        count: json['count'] as int? ?? 0,
        topics: (json['topics'] as List<Object?>?)?.cast<String>() ?? const <String>[],
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
