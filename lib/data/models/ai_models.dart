import 'package:flutter/foundation.dart';

/// Cevabın üretildiği kaynak türü.
enum AiSourceKind {
  quran('Kur\'an'),
  hadith('Hadis'),
  fiqh('Fıkıh'),
  other('Kaynak');

  const AiSourceKind(this.label);

  final String label;

  static AiSourceKind fromJson(Object? raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'quran':
      case 'kur\'an':
      case 'kuran':
        return AiSourceKind.quran;
      case 'hadith':
      case 'hadis':
        return AiSourceKind.hadith;
      case 'fiqh':
      case 'fikih':
      case 'fetva':
        return AiSourceKind.fiqh;
      default:
        return AiSourceKind.other;
    }
  }

  String get iconAsset => switch (this) {
    AiSourceKind.quran => 'quran',
    AiSourceKind.hadith => 'hadith',
    AiSourceKind.fiqh => 'fiqh',
    AiSourceKind.other => 'other',
  };
}

/// Cevapta gösterilen tekil kaynak.
@immutable
class AiSource {
  const AiSource({
    required this.kind,
    required this.label,
    this.detail,
    this.url,
  });

  final AiSourceKind kind;

  /// Görünen künye, ör. "Buhârî, Savm 26".
  final String label;
  final String? detail;
  final String? url;

  Map<String, Object?> toJson() => <String, Object?>{
    'kind': kind.name,
    'label': label,
    if (detail != null) 'detail': detail,
    if (url != null) 'url': url,
  };

  factory AiSource.fromJson(Map<String, Object?> json) => AiSource(
    kind: AiSourceKind.fromJson(json['kind']),
    label: json['label']?.toString() ?? '',
    detail: json['detail']?.toString(),
    url: json['url']?.toString(),
  );
}

/// Cevabın üretim biçimi.
enum AiAnswerMode {
  /// Yerel bilgi tabanından (çevrimdışı).
  offline,

  /// Backend üzerinden AI servisinden.
  remote;

  String get label => switch (this) {
    AiAnswerMode.offline => 'Çevrimdışı bilgi tabanı',
    AiAnswerMode.remote => 'AI destekli yanıt',
  };
}

/// Sohbetteki tekil mesaj.
@immutable
class AiMessage {
  const AiMessage({
    required this.id,
    required this.text,
    required this.fromUser,
    required this.createdAt,
    this.sources = const <AiSource>[],
    this.madhabNotes = const <String>[],
    this.mode,
    this.disclaimer,
    this.relatedQuestions = const <String>[],
    this.failed = false,
  });

  final String id;
  final String text;
  final bool fromUser;
  final DateTime createdAt;
  final List<AiSource> sources;
  final List<String> madhabNotes;
  final AiAnswerMode? mode;
  final String? disclaimer;
  final List<String> relatedQuestions;
  final bool failed;

  Map<String, Object?> toJson() => <String, Object?>{
    'role': fromUser ? 'user' : 'assistant',
    'text': text,
    if (sources.isNotEmpty)
      'sources': sources.map((AiSource s) => s.toJson()).toList(),
  };
}

/// Asistanın ürettiği cevap.
@immutable
class AiAnswer {
  const AiAnswer({
    required this.text,
    required this.sources,
    required this.mode,
    required this.disclaimer,
    required this.createdAt,
    this.madhabNotes = const <String>[],
    this.relatedQuestions = const <String>[],
    this.topic,
  });

  final String text;
  final List<AiSource> sources;
  final AiAnswerMode mode;
  final String disclaimer;
  final DateTime createdAt;
  final List<String> madhabNotes;
  final List<String> relatedQuestions;
  final String? topic;

  bool get hasSources => sources.isNotEmpty;

  /// Panoya/paylaşıma uygun metin; kaynak künyeleri her zaman eklenir.
  String shareText() {
    final StringBuffer buffer = StringBuffer(text);
    if (madhabNotes.isNotEmpty) {
      buffer.write('\n\nMezhep farklılıkları:');
      for (final String note in madhabNotes) {
        buffer.write('\n• $note');
      }
    }
    buffer.write('\n\nKaynaklar:');
    for (final AiSource source in sources) {
      buffer.write('\n• ${source.label}');
    }
    if (disclaimer.isNotEmpty) {
      buffer.write('\n\n$disclaimer');
    }
    return buffer.toString().trim();
  }
}

/// Sohbet oturumu (geçmiş listesi için).
@immutable
class AiConversation {
  const AiConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<AiMessage> messages;
  final DateTime updatedAt;

  AiConversation copyWith({
    String? title,
    List<AiMessage>? messages,
    DateTime? updatedAt,
  }) => AiConversation(
    id: id,
    title: title ?? this.title,
    messages: messages ?? this.messages,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
