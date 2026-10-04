import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/text_normalizer.dart';
import '../models/ai_models.dart';
import 'knowledge_base.dart';

/// Yerel niyet eşleştirme tabanlı bilgi kaynağı.
///
/// İnternet olmasa bile çalışır ve **her zaman kaynak gösterir**.
class LocalKnowledgeSource {
  LocalKnowledgeSource();

  /// Soruyu yerel bilgi tabanıyla eşleştirir.
  AiAnswer? answer(String question) {
    final String q = TextNormalizer.normalize(question);
    if (q.trim().isEmpty) return null;

    final List<String> tokens = TextNormalizer.tokens(q);

    KnowledgeEntry? best;
    double bestScore = 0;

    for (final KnowledgeEntry entry in KnowledgeBase.entries) {
      double score = 0;
      for (final String keyword in entry.keywords) {
        final String k = TextNormalizer.normalize(keyword);
        if (k.isEmpty) continue;
        if (q.contains(k)) {
          score += 3 + k.length / 12;
        }
        final List<String> kTokens = TextNormalizer.tokens(k);
        if (kTokens.isEmpty) continue;
        int hit = 0;
        for (final String kt in kTokens) {
          if (tokens.contains(kt)) hit++;
        }
        if (hit == kTokens.length) {
          score += 2.0 * kTokens.length;
        } else if (hit > 0) {
          score += 0.6 * hit;
        }
      }
      final String title = TextNormalizer.normalize(entry.title);
      for (final String token in TextNormalizer.tokens(title)) {
        if (token.length > 3 && tokens.contains(token)) score += 0.4;
      }
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best == null || bestScore < 2.2) return null;

    final List<AiSource> sources = <AiSource>[];

    for (final String citation in best.citations) {
      if (citation.startsWith('Kur')) {
        sources.add(
          AiSource(
            kind: AiSourceKind.quran,
            label: citation,
            detail: 'Kur\'an-ı Kerim',
          ),
        );
      } else if (citation.contains('Buhârî') ||
          citation.contains('Müslim') ||
          citation.contains('Tirmizî') ||
          citation.contains('İbn Mâce') ||
          citation.contains('Dârimî') ||
          citation.contains('Taberânî')) {
        sources.add(
          AiSource(
            kind: AiSourceKind.hadith,
            label: citation,
            detail: 'Hadis kaynağı',
          ),
        );
      } else {
        sources.add(
          AiSource(
            kind: AiSourceKind.fiqh,
            label: citation,
            detail: 'Fıkıh kaynağı',
          ),
        );
      }
    }

    final StringBuffer buffer = StringBuffer(best.answer);
    if (best.details.isNotEmpty) {
      buffer.write('\n');
      for (final String detail in best.details) {
        buffer.write('\n• $detail');
      }
    }

    return AiAnswer(
      text: buffer.toString().trim(),
      sources: sources,
      madhabNotes: best.madhabNotes,
      mode: AiAnswerMode.offline,
      topic: best.title,
      relatedQuestions: best.related.isEmpty ? const <String>[] : best.related,
      disclaimer:
          'Bu bilgi genel bilgilendirme amaçlıdır ve kesin dini hüküm niteliği taşımaz. '
          'Mezhep ve duruma göre farklılıklar olabilir; bağlayıcı görüş için müftülüğe danışın.',
      createdAt: DateTime.now(),
    );
  }
}

/// Uzak AI yanıtı.
class RemoteAiResult {
  const RemoteAiResult({
    required this.text,
    required this.sources,
    this.madhabNotes = const <String>[],
  });

  final String text;
  final List<AiSource> sources;
  final List<String> madhabNotes;
}

/// AI asistanın veri katmanı.
///
/// * Backend yapılandırılmışsa (`AppConfig.hasBackend`) uzak uç noktaya gider;
///   anahtar **asla** istemcide tutulmaz.
/// * Uzak çağrı başarısız olursa yerel bilgi tabanına düşer.
/// * Her cevap kaynaklıdır ve kesin hüküm vermez.
class AiService {
  AiService({http.Client? client, LocalKnowledgeSource? local})
    : _client = client ?? http.Client(),
      _local = local ?? LocalKnowledgeSource();

  final http.Client _client;
  final LocalKnowledgeSource _local;

  static const Duration _timeout = Duration(seconds: 25);

  /// Soruyu yanıtlar. [history] önceki mesajlardır (en yeniden geriye).
  Future<AiAnswer> ask(
    String question, {
    List<AiMessage> history = const <AiMessage>[],
  }) async {
    final String trimmed = question.trim();
    if (trimmed.isEmpty) {
      return AiAnswer(
        text: 'Lütfen bir soru yazın.',
        sources: const <AiSource>[],
        mode: AiAnswerMode.offline,
        disclaimer: '',
        createdAt: DateTime.now(),
      );
    }

    final AiAnswer? localAnswer = _local.answer(trimmed);
    if (localAnswer != null) return localAnswer;

    if (AppConfig.hasBackend) {
      try {
        final RemoteAiResult remote = await _askRemote(trimmed, history);
        return AiAnswer(
          text: remote.text,
          sources: remote.sources,
          madhabNotes: remote.madhabNotes,
          mode: AiAnswerMode.remote,
          disclaimer:
              'Bu cevap yapay zekâ yardımıyla derlenmiştir; kesin dini hüküm değildir. '
              'Kaynaklara bakmanız ve tereddüt hâlinde müftülüğe danışmanız önerilir.',
          createdAt: DateTime.now(),
        );
      } catch (error, stack) {
        AppLog.warning('AI uzak çağrısı başarısız: $error');
        AppLog.debug('$stack');
      }
    }

    return _fallback(trimmed);
  }

  Future<RemoteAiResult> _askRemote(
    String question,
    List<AiMessage> history,
  ) async {
    final Uri? uri = AppConfig.endpoint('/ai/ask');
    if (uri == null) throw StateError('AI servisi yapılandırılmadı.');
    final Map<String, Object?> body = <String, Object?>{
      'question': question,
      'language': 'tr',
      'madhab': 'hanefi',
      'history': history
          .take(6)
          .toList()
          .reversed
          .map((AiMessage m) => m.toJson())
          .toList(growable: false),
    };

    final http.Response response = await _client
        .post(
          uri,
          headers: const <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw StateError('AI servisi ${response.statusCode} döndü.');
    }

    final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('AI yanıtı beklenen biçimde değil.');
    }

    final String text = switch (decoded['answer'] ?? decoded['text']) {
      final String value when value.trim().isNotEmpty => value.trim(),
      _ => throw const FormatException('AI yanıtı boş.'),
    };

    final List<AiSource> sources = _parseSources(decoded['sources']);
    final List<String> madhabNotes = _parseStringList(
      decoded['madhab_notes'] ?? decoded['madhabNotes'],
    );

    if (sources.isEmpty) {
      // Kaynak yoksa cevabı kaynaklı saymayız; yerel bilgi tabanına düşeriz.
      throw const FormatException('AI yanıtı kaynaksız döndü.');
    }

    return RemoteAiResult(
      text: text,
      sources: sources,
      madhabNotes: madhabNotes,
    );
  }

  List<AiSource> _parseSources(Object? raw) {
    if (raw is! List) return const <AiSource>[];
    final List<AiSource> sources = <AiSource>[];
    for (final Object? item in raw) {
      if (item is String) {
        sources.add(AiSource(kind: AiSourceKind.other, label: item));
      } else if (item is Map) {
        final Object? label =
            item['label'] ?? item['ref'] ?? item['citation'] ?? item['title'];
        if (label is! String || label.trim().isEmpty) continue;
        final Object? kind = item['type'] ?? item['kind'];
        sources.add(
          AiSource(
            kind: AiSourceKind.fromJson(kind),
            label: label.trim(),
            detail: item['detail'] is String ? item['detail'] as String : null,
            url: item['url'] is String ? item['url'] as String : null,
          ),
        );
      }
    }
    return sources;
  }

  List<String> _parseStringList(Object? raw) {
    if (raw is! List) return const <String>[];
    return raw
        .whereType<String>()
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  /// Hiçbir kaynağa eşleşmeyen sorular için dürüst yanıt + öneri listesi.
  AiAnswer _fallback(String question) {
    const List<KnowledgeEntry> pool = KnowledgeBase.entries;
    final Random random = Random(
      question.length * 31 +
          question.codeUnits.fold<int>(0, (int a, int b) => a + b),
    );
    final List<String> suggestions = <String>[
      for (int i = 0; i < 3 && pool.isNotEmpty; i++)
        pool[random.nextInt(pool.length)].title,
    ];

    return AiAnswer(
      text:
          'Bu sorunun cevabını güvenilir kaynaklarla eşleştiremedim. '
          'Kesin hüküm vermemek adına tahmin yürütmüyorum.\n\n'
          'Şunları deneyebilirsiniz:\n'
          '• Soruyu daha kısa ve net sorun (ör. "vitir kaç rekât?")\n'
          '• Aşağıdaki konu başlıklarından birini seçin\n'
          '• Ayrıntılı fetva için müftülüğe veya ehil bir hocaya danışın',
      sources: const <AiSource>[
        AiSource(
          kind: AiSourceKind.fiqh,
          label: 'Genel ilke: bilmediğini söylemek ilmin gereğidir',
          detail:
              'Kaynakla doğrulanamayan konularda hüküm vermekten kaçınılır.',
        ),
      ],
      mode: AiAnswerMode.offline,
      relatedQuestions: suggestions,
      disclaimer:
          'Bu cevap bir dini hüküm değildir; kişisel durumunuza göre bağlayıcı görüş için '
          'bir müftülüğe danışmanız önerilir.',
      createdAt: DateTime.now(),
    );
  }

  void dispose() => _client.close();
}
