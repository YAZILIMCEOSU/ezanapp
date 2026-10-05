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
///
/// Eşleştirme, anahtar kelimelerin yanı sıra başlık örtüşmesini de dikkate
/// alır ve terimleri **ayırt ediciliklerine göre** ağırlıklandırır: her kayıtta
/// geçen "namaz" gibi kelimeler zayıf, yalnız bir kayıtta geçen "vitir" gibi
/// kelimeler güçlü sinyal sayılır. Böylece "Vitir namazı kaç rekâttır?" sorusu
/// genel namaz kaydına değil, vitir kaydına yönlenir.
class LocalKnowledgeSource {
  LocalKnowledgeSource();

  /// Bu puanın altındaki eşleşmeler "bilgi tabanında yok" sayılır.
  static const double minimumScore = 2.2;

  /// Soruyu yerel bilgi tabanıyla eşleştirir.
  AiAnswer? answer(String question) {
    final String q = TextNormalizer.normalize(question);
    if (q.trim().isEmpty) return null;

    final List<String> tokens = TextNormalizer.tokens(q);
    final Set<String> tokenSet = tokens.toSet();
    final Set<String> stemSet = tokens.map(TextNormalizer.stem).toSet();

    KnowledgeEntry? best;
    double bestScore = 0;

    for (final KnowledgeEntry entry in KnowledgeBase.entries) {
      final double score = scoreEntry(entry, q, tokenSet, stemSet);
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best == null || bestScore < minimumScore) return null;

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
      relatedQuestions: best.related
          .map((String id) => KnowledgeBase.byId(id)?.title)
          .whereType<String>()
          .toList(growable: false),
      disclaimer:
          'Bu bilgi genel bilgilendirme amaçlıdır ve kesin dini hüküm niteliği taşımaz. '
          'Mezhep ve duruma göre farklılıklar olabilir; bağlayıcı görüş için müftülüğe danışın.',
      createdAt: DateTime.now(),
    );
  }

  /// Bir kaydın soruya uygunluk puanı.
  ///
  /// * Anahtar kelime katkısı: birebir geçme ve kelime örtüşmesi, terimin
  ///   ayırt ediciliğiyle (IDF) çarpılır.
  /// * Başlık katkısı: başlık kelimeleriyle kök örtüşmesi ayrıca puanlanır.
  ///
  /// Görünürlük test için açıktır; puanlama kuralları testlerde doğrulanır.
  static double scoreEntry(
    KnowledgeEntry entry,
    String question,
    Set<String> tokenSet,
    Set<String> stemSet,
  ) {
    final _TermWeights weights = _TermWeights.instance;
    double score = 0;

    for (final String keyword in entry.keywords) {
      final String normalized = TextNormalizer.normalize(keyword);
      if (normalized.isEmpty) continue;

      double base = 0;
      if (question.contains(normalized)) base += 3 + normalized.length / 12;

      final List<String> parts = TextNormalizer.tokens(normalized);
      if (parts.isEmpty) {
        score += base * weights.idf(normalized);
        continue;
      }

      int hits = 0;
      for (final String part in parts) {
        if (tokenSet.contains(part)) hits++;
      }
      if (hits == parts.length) {
        base += 2.0 * parts.length;
      } else if (hits > 0) {
        base += 0.6 * hits;
      }
      score += base * weights.phraseWeight(parts);
    }

    final Set<String> titleStems = <String>{};
    for (final String token in TextNormalizer.tokens(entry.title)) {
      titleStems.add(TextNormalizer.stem(token));
    }
    for (final String word in titleStems) {
      if (word.length > 3 && stemSet.contains(word)) {
        score += 0.9 * weights.idf(word);
      }
    }

    return score;
  }
}

/// Terimlerin ayırt ediciliğini ölçen ters belge frekansı (IDF) tablosu.
///
/// Bilgi tabanı küçük olduğundan tablo ilk kullanımda bir kez kurulur ve
/// önbellekte tutulur; her soruda yeniden hesaplanmaz.
class _TermWeights {
  _TermWeights._(this._documents, this._frequencies);

  static const double _minimumWeight = 0.35;
  static const double _maximumWeight = 1.2;

  static _TermWeights? _cached;

  static _TermWeights get instance => _cached ??= _build();

  final int _documents;
  final Map<String, int> _frequencies;

  static _TermWeights _build() {
    final Map<String, int> frequencies = <String, int>{};
    for (final KnowledgeEntry entry in KnowledgeBase.entries) {
      final Set<String> terms = <String>{};
      for (final String keyword in entry.keywords) {
        terms.add(TextNormalizer.normalize(keyword));
        for (final String part in TextNormalizer.tokens(keyword)) {
          terms.add(TextNormalizer.stem(part));
        }
      }
      for (final String part in TextNormalizer.tokens(entry.title)) {
        terms.add(TextNormalizer.stem(part));
      }
      for (final String term in terms) {
        frequencies[term] = (frequencies[term] ?? 0) + 1;
      }
    }
    return _TermWeights._(KnowledgeBase.entries.length, frequencies);
  }

  /// Yaygın terimler ~0,35; yalnız bir kayıtta geçen terimler ~1,0–1,2.
  double idf(String term) {
    final int frequency = _frequencies[term] ?? 1;
    final double raw =
        log((_documents + 1) / (frequency + 1)) / log((_documents + 1) / 2);
    return raw.clamp(_minimumWeight, _maximumWeight).toDouble();
  }

  /// Bir ifadenin ağırlığı: en ayırt edici kelimesinin ağırlığı.
  double phraseWeight(List<String> parts) {
    double best = 0;
    for (final String part in parts) {
      final double weight = idf(TextNormalizer.stem(part));
      if (weight > best) best = weight;
    }
    return best;
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
          relatedQuestions: _suggestionsFor(trimmed),
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

  /// Öneri soruları: soru yerel bir kayda uyuyorsa o kaydın ilişkili
  /// başlıkları, aksi hâlde bilgi tabanından (soruya göre deterministik)
  /// örnek başlıklar döner.
  List<String> _suggestionsFor(String question) {
    final AiAnswer? local = _local.answer(question);
    if (local != null && local.relatedQuestions.isNotEmpty) {
      return local.relatedQuestions;
    }

    const List<KnowledgeEntry> pool = KnowledgeBase.entries;
    final Random random = Random(
      question.length * 31 +
          question.codeUnits.fold<int>(0, (int a, int b) => a + b),
    );
    return <String>[
      for (int i = 0; i < 3 && pool.isNotEmpty; i++)
        pool[random.nextInt(pool.length)].title,
    ];
  }

  /// Hiçbir kaynağa eşleşmeyen sorular için dürüst yanıt + öneri listesi.
  AiAnswer _fallback(String question) {
    final List<String> suggestions = _suggestionsFor(question);

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
