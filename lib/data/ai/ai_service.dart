import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/text_normalizer.dart';
import '../models/ai_models.dart';
import 'knowledge_base.dart';

/// RAG (Retrieval-Augmented Generation) için geri getirilen doğrulanmış belge.
class RetrievedPassage {
  const RetrievedPassage({required this.entry, required this.score});

  final KnowledgeEntry entry;
  final double score;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': entry.id,
    'title': entry.title,
    'category': entry.category,
    'answer': entry.answer,
    'details': entry.details,
    'citations': entry.citations,
    'madhab_notes': entry.madhabNotes,
    'score': double.parse(score.toStringAsFixed(2)),
  };
}

/// Yerel niyet eşleştirme ve doğrulanmış belge geri getirme (RAG) kaynağı.
///
/// İnternet olmasa bile çalışır ve **her zaman kaynak gösterir**.
///
/// Eşleştirme, anahtar kelimelerin yanı sıra başlık örtüşmesini ve yazım
/// hatalarını (1 harf düşmesi/yer değiştirmesi) dikkate alır; terimleri
/// **ayırt ediciliklerine göre** ağırlıklandırır.
class LocalKnowledgeSource {
  LocalKnowledgeSource();

  /// Bu puanın altındaki eşleşmeler "bilgi tabanında yok" sayılır.
  static const double minimumScore = 2.2;

  /// Soruya en uygun doğrulanmış belgeleri puan sırasıyla döndürür (RAG).
  List<RetrievedPassage> retrievePassages(
    String question, {
    int limit = 3,
    double minScore = 1.25,
  }) {
    final String q = TextNormalizer.normalize(question);
    if (q.trim().isEmpty) return const <RetrievedPassage>[];

    final List<String> tokens = TextNormalizer.tokens(q);
    final Set<String> tokenSet = tokens.toSet();
    final Set<String> stemSet = tokens.map(TextNormalizer.stem).toSet();

    final List<RetrievedPassage> scored = <RetrievedPassage>[];
    for (final KnowledgeEntry entry in KnowledgeBase.entries) {
      final double score = scoreEntry(entry, q, tokenSet, stemSet);
      if (score >= minScore) {
        scored.add(RetrievedPassage(entry: entry, score: score));
      }
    }
    scored.sort(
      (RetrievedPassage a, RetrievedPassage b) => b.score.compareTo(a.score),
    );
    if (scored.length <= limit) return scored;
    return scored.sublist(0, limit);
  }

  /// Soruyu yerel bilgi tabanıyla eşleştirir; birden fazla doğrulanmış konu
  /// birlikte sorulmuşsa RAG birleştirmesi yapar.
  AiAnswer? answer(String question) {
    final List<RetrievedPassage> passages = retrievePassages(
      question,
      limit: 3,
      minScore: minimumScore,
    );
    if (passages.isEmpty) return null;

    final KnowledgeEntry best = passages.first.entry;
    final double bestScore = passages.first.score;

    // Kullanıcı aynı soruda iki ayrı doğrulanmış konuyu birlikte sormuşsa
    // (ör. "İslam'ın ve imanın şartları nelerdir?" veya "Zekât ve fitre farkı")
    // ikinci belge de yüksek puan aldıysa RAG sentezi uygula.
    final bool hasCompositeSecond =
        passages.length >= 2 &&
        passages[1].score >= minimumScore * 1.35 &&
        passages[1].score >= bestScore * 0.58 &&
        _isCompositeQuestion(question);

    final List<KnowledgeEntry> selectedEntries = hasCompositeSecond
        ? <KnowledgeEntry>[best, passages[1].entry]
        : <KnowledgeEntry>[best];

    final List<AiSource> sources = <AiSource>[];
    final Set<String> seenCitations = <String>{};
    final List<String> madhabNotes = <String>[];
    final Set<String> seenNotes = <String>{};

    for (final KnowledgeEntry entry in selectedEntries) {
      for (final String citation in entry.citations) {
        if (!seenCitations.add(citation)) continue;
        sources.add(_sourceFromCitation(citation, entry));
      }
      for (final String note in entry.madhabNotes) {
        if (seenNotes.add(note)) madhabNotes.add(note);
      }
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < selectedEntries.length; i++) {
      final KnowledgeEntry entry = selectedEntries[i];
      if (i > 0) {
        buffer.write('\n\n— ${entry.title} —\n');
      }
      buffer.write(entry.answer);
      if (entry.details.isNotEmpty) {
        buffer.write('\n');
        for (final String detail in entry.details) {
          buffer.write('\n• $detail');
        }
      }
    }

    final bool fatwa = AiService.isFatwaQuestion(question);

    return AiAnswer(
      text: buffer.toString().trim(),
      sources: sources,
      madhabNotes: madhabNotes,
      mode: AiAnswerMode.offline,
      topic: best.title,
      isVerifiedLocal: true,
      relatedQuestions: best.related
          .map((String id) => KnowledgeBase.byId(id)?.title)
          .whereType<String>()
          .toList(growable: false),
      disclaimer: fatwa
          ? 'Bu yanıt doğrulanmış ilmihal ve hadis kaynaklarından derlenmiştir; '
                'ancak kişisel durumunuza özel bir fetva veya kesin dini hüküm '
                'niteliği taşımaz. Mezhep farklılıkları ve özel şartlar için '
                'Diyanet İşleri Başkanlığı Din İşleri Yüksek Kurulu\'na veya '
                'müftülüğe danışınız.'
          : 'Bu bilgi genel bilgilendirme amaçlıdır ve kesin dini hüküm niteliği taşımaz. '
                'Mezhep ve duruma göre farklılıklar olabilir; bağlayıcı görüş için müftülüğe danışın.',
      createdAt: DateTime.now(),
    );
  }

  static bool _isCompositeQuestion(String question) {
    final String q = TextNormalizer.normalize(question);
    return q.contains(' ve ') ||
        q.contains(' ile ') ||
        q.contains(' fark') ||
        q.contains(' hem ');
  }

  static AiSource _sourceFromCitation(String citation, KnowledgeEntry entry) {
    final String section = '${entry.category} · ${entry.title}';
    if (citation.startsWith('Kur')) {
      return AiSource(
        kind: AiSourceKind.quran,
        label: citation,
        detail: 'Kur\'an-ı Kerim · $section',
      );
    }
    if (_isHadithCitation(citation)) {
      return AiSource(
        kind: AiSourceKind.hadith,
        label: citation,
        detail: 'Hadis kaynağı · $section',
      );
    }
    return AiSource(
      kind: AiSourceKind.fiqh,
      label: citation,
      detail: 'Fıkıh / İlmihal kaynağı · $section',
    );
  }

  static const Set<String> _stopStems = <String>{
    'nasil',
    'nedir',
    'neler',
    'nelerdir',
    'zaman',
    'kac',
    'hangi',
    'icin',
    'olur',
    'yapil',
    'yapilir',
    'edil',
    'edilir',
    'alin',
    'alinir',
    'kilin',
    'kilinir',
    'okun',
    'okunur',
    'veril',
    'verilir',
    'tutul',
    'tutulur',
    'gerek',
    'gerekir',
    'caiz',
  };

  /// Bir kaydın soruya uygunluk puanı.
  ///
  /// * Anahtar kelime katkısı: birebir geçme, kelime/kök örtüşmesi ve 1 harf
  ///   yazım hatası toleransı, terimin ayırt ediciliğiyle (IDF) çarpılır.
  /// * Başlık katkısı: başlık kelimeleriyle kök/fuzzy örtüşmesi ayrıca puanlanır.
  static double scoreEntry(
    KnowledgeEntry entry,
    String question,
    Set<String> tokenSet,
    Set<String> stemSet,
  ) {
    final _TermWeights weights = _TermWeights.instance;
    double score = 0;
    bool hasTopicHit = false;

    for (final String keyword in entry.keywords) {
      final String normalized = TextNormalizer.normalize(keyword);
      if (normalized.isEmpty) continue;

      double base = 0;
      if (question.contains(normalized)) {
        base += 3 + normalized.length / 12;
        hasTopicHit = true;
      }

      final List<String> parts = TextNormalizer.tokens(normalized);
      if (parts.isEmpty) {
        score += base * weights.idf(normalized);
        continue;
      }

      int exactHits = 0;
      int fuzzyHits = 0;
      for (final String part in parts) {
        final String partStem = TextNormalizer.stem(part);
        final bool isStop =
            _stopStems.contains(part) || _stopStems.contains(partStem);
        if (tokenSet.contains(part) || stemSet.contains(partStem)) {
          exactHits++;
          if (!isStop) hasTopicHit = true;
        } else if (!isStop &&
            _matchesFuzzy(part, partStem, tokenSet, stemSet)) {
          fuzzyHits++;
          hasTopicHit = true;
        }
      }
      final int totalHits = exactHits + fuzzyHits;
      if (totalHits == parts.length) {
        final double multiplier = fuzzyHits == 0 ? 2.0 : 1.55;
        base += multiplier * parts.length;
      } else if (totalHits > 0) {
        base += 0.55 * exactHits + 0.35 * fuzzyHits;
      }
      score += base * weights.phraseWeight(parts);
    }

    final Set<String> titleStems = <String>{};
    for (final String token in TextNormalizer.tokens(entry.title)) {
      titleStems.add(TextNormalizer.stem(token));
    }
    for (final String word in titleStems) {
      if (word.length > 3 && !_stopStems.contains(word)) {
        if (stemSet.contains(word)) {
          score += 0.9 * weights.idf(word);
          hasTopicHit = true;
        } else if (stemSet.any(
          (String s) => TextNormalizer.isFuzzyTokenMatch(word, s),
        )) {
          score += 0.65 * weights.idf(word);
          hasTopicHit = true;
        }
      }
    }

    if (!hasTopicHit) return 0;
    return score;
  }

  static bool _matchesFuzzy(
    String part,
    String partStem,
    Set<String> tokenSet,
    Set<String> stemSet,
  ) {
    if (part.length < 4) return false;
    for (final String token in tokenSet) {
      if (TextNormalizer.isFuzzyTokenMatch(part, token)) return true;
    }
    for (final String stem in stemSet) {
      if (TextNormalizer.isFuzzyTokenMatch(partStem, stem)) return true;
    }
    return false;
  }
}

/// Terimlerin ayırt ediciliğini ölçen ters belge frekansı (IDF) tablosu.
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

/// Uzak AI isteğinde oluşan hatanın türü.
class _RemoteAiException implements Exception {
  const _RemoteAiException(this.kind, this.message);

  final AiFailureKind kind;
  final String message;

  @override
  String toString() => 'RemoteAiException($kind): $message';
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
/// * Önceden onaylanmış yerel bilgi tabanı (`LocalKnowledgeSource`) eşleşirse
///   doğrudan kaynaklı yanıt döner.
/// * Backend yapılandırılmışsa (`AppConfig.hasBackend`), doğrulanmış RAG
///   bağlamıyla birlikte uzak uç noktaya gider; API anahtarı **asla**
///   istemcide tutulmaz.
/// * Kaynak bulunamaması, ağ hatası, kota aşımı ve sunucu hatası ayrı ele alınır.
/// * Dinî hüküm / fetva sorularında kaynaklar doğrulanır, uydurma kaynaklar
///   reddedilir ve belirsizlik gizlenmez.
class AiService {
  AiService({http.Client? client, LocalKnowledgeSource? local})
    : _client = client ?? http.Client(),
      _local = local ?? LocalKnowledgeSource();

  final http.Client _client;
  final LocalKnowledgeSource _local;

  static const Duration _timeout = Duration(seconds: 25);

  /// Yalnızca önceden onaylanmış yerel bilgi tabanını sorgular.
  /// (Kota dolsa bile temel dini soruları yanıtlamak için kullanılır.)
  AiAnswer? answerVerifiedLocal(String question) {
    final String trimmed = question.trim();
    if (trimmed.isEmpty) return null;
    return _local.answer(trimmed);
  }

  /// Soruya ilişkin doğrulanmış RAG pasajlarını getirir.
  List<RetrievedPassage> retrieveRagContext(String question, {int limit = 3}) =>
      _local.retrievePassages(question, limit: limit);

  /// Sorunun dinî hüküm / fetva niteliği taşıyıp taşımadığını belirler.
  static bool isFatwaQuestion(String question) {
    final String q = TextNormalizer.normalize(question);
    const List<String> markers = <String>[
      'caiz mi',
      'caiz midir',
      'haram mi',
      'haram midir',
      'helal mi',
      'helal midir',
      'gunah mi',
      'gunah midir',
      'bozar mi',
      'bozulur mu',
      'fetva',
      'hukmu nedir',
      'hukmu ne',
      'mekruh mu',
      'vacip mi',
      'farz mi',
      'gecerli mi',
      'kabul olur mu',
    ];
    for (final String marker in markers) {
      if (q.contains(marker)) return true;
    }
    return false;
  }

  /// Uzak modelin döndürdüğü kaynakların uydurma/boş olmadığını doğrular.
  static List<AiSource> validateRemoteSources(List<AiSource> sources) {
    final List<AiSource> valid = <AiSource>[];
    for (final AiSource source in sources) {
      final String label = source.label.trim();
      if (label.length < 4) continue;
      final String normalized = TextNormalizer.normalize(label);
      if (normalized == 'unknown' ||
          normalized == 'none' ||
          normalized == 'kaynak yok' ||
          normalized == 'belirsiz' ||
          normalized.contains('uydurma')) {
        continue;
      }
      valid.add(source);
    }
    return valid;
  }

  /// Kota dolduğunda döndürülen açık bilgilendirme yanıtı.
  static AiAnswer quotaExceededAnswer({String? question}) {
    return AiAnswer(
      text:
          'Bugünkü ücretsiz yapay zekâ soru hakkınız doldu.\n\n'
          '• İslam\'ın şartları, imanın şartları, namaz, abdest, oruç, zekât ve '
          'kıble gibi **temel onaylı dini sorular** kota dolsa bile sınırsız '
          'olarak yanıtlanmaya devam eder.\n'
          '• Kapsamlı yapay zekâ soruları için Premium\'a geçebilir veya yarın '
          'tekrar deneyebilirsiniz.',
      sources: const <AiSource>[
        AiSource(
          kind: AiSourceKind.other,
          label: 'Günlük kullanım kotası',
          detail:
              'Temel onaylı bilgi tabanı sorularında kota sınırı uygulanmaz.',
        ),
      ],
      mode: AiAnswerMode.offline,
      failureKind: AiFailureKind.quotaExceeded,
      disclaimer: 'Temel ilmihal sorularınızı sormaya devam edebilirsiniz.',
      createdAt: DateTime.now(),
    );
  }

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

    // 1. Önceden onaylanmış yerel bilgi tabanı (tam eşleşme).
    final AiAnswer? localAnswer = _local.answer(trimmed);
    if (localAnswer != null) return localAnswer;

    // 2. RAG için doğrulanmış yakın belgeleri hazırla.
    final List<RetrievedPassage> ragPassages = _local.retrievePassages(
      trimmed,
      limit: 3,
      minScore: 1.15,
    );

    // 3. Backend yapılandırılmışsa RAG bağlamıyla uzak servise sor.
    if (AppConfig.hasBackend) {
      try {
        final RemoteAiResult remote = await _askRemote(
          trimmed,
          history,
          ragPassages: ragPassages,
        );
        final bool fatwa = isFatwaQuestion(trimmed);
        return AiAnswer(
          text: remote.text,
          sources: remote.sources,
          madhabNotes: remote.madhabNotes,
          mode: AiAnswerMode.remote,
          relatedQuestions: _suggestionsFor(trimmed),
          disclaimer: fatwa
              ? 'Bu cevap doğrulanmış kaynaklar eşliğinde derlenmiştir; kesin '
                    'dini hüküm veya kişisel fetva yerine geçmez. Özel durumlar '
                    've mezhep hükümleri için müftülüğe danışınız.'
              : 'Bu cevap yapay zekâ yardımıyla derlenmiştir; kesin dini hüküm değildir. '
                    'Kaynaklara bakmanız ve tereddüt hâlinde müftülüğe danışmanız önerilir.',
          createdAt: DateTime.now(),
        );
      } on _RemoteAiException catch (error) {
        AppLog.warning(
          'AI uzak çağrısı (${error.kind.name}): ${error.message}',
        );
        if (error.kind == AiFailureKind.quotaExceeded) {
          return quotaExceededAnswer(question: trimmed);
        }
        return _fallback(
          trimmed,
          failureKind: error.kind,
          ragPassages: ragPassages,
        );
      } catch (error, stack) {
        AppLog.warning('AI uzak çağrısı başarısız: $error');
        AppLog.debug('$stack');
        return _fallback(
          trimmed,
          failureKind: AiFailureKind.apiError,
          ragPassages: ragPassages,
        );
      }
    }

    return _fallback(
      trimmed,
      failureKind: AiFailureKind.noVerifiedSource,
      ragPassages: ragPassages,
    );
  }

  Future<RemoteAiResult> _askRemote(
    String question,
    List<AiMessage> history, {
    List<RetrievedPassage> ragPassages = const <RetrievedPassage>[],
  }) async {
    final Uri? uri = AppConfig.endpoint('/ai/ask');
    if (uri == null) {
      throw const _RemoteAiException(
        AiFailureKind.apiError,
        'AI servisi yapılandırılmadı.',
      );
    }
    final Map<String, Object?> body = <String, Object?>{
      'question': question,
      'language': 'tr',
      'madhab': 'hanefi',
      'require_verified_sources': true,
      'is_fatwa_query': isFatwaQuestion(question),
      if (ragPassages.isNotEmpty)
        'retrieved_context': ragPassages
            .map((RetrievedPassage p) => p.toJson())
            .toList(growable: false),
      'history': history
          .take(6)
          .toList()
          .reversed
          .map((AiMessage m) => m.toJson())
          .toList(growable: false),
    };

    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const _RemoteAiException(
        AiFailureKind.networkError,
        'AI servisi zaman aşımına uğradı.',
      );
    } on SocketException {
      throw const _RemoteAiException(
        AiFailureKind.networkError,
        'Ağ bağlantısı kurulamadı.',
      );
    } on http.ClientException catch (error) {
      throw _RemoteAiException(
        AiFailureKind.networkError,
        'İstemci ağ hatası: $error',
      );
    }

    if (response.statusCode == 429) {
      throw const _RemoteAiException(
        AiFailureKind.quotaExceeded,
        'Günlük AI soru kotası doldu.',
      );
    }

    if (response.statusCode != 200) {
      throw _RemoteAiException(
        AiFailureKind.apiError,
        'AI servisi ${response.statusCode} döndü.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const _RemoteAiException(
        AiFailureKind.apiError,
        'AI yanıtı geçerli JSON değil.',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw const _RemoteAiException(
        AiFailureKind.apiError,
        'AI yanıtı beklenen biçimde değil.',
      );
    }

    final String text = switch (decoded['answer'] ?? decoded['text']) {
      final String value when value.trim().isNotEmpty => value.trim(),
      _ => throw const _RemoteAiException(
        AiFailureKind.apiError,
        'AI yanıtı boş.',
      ),
    };

    final List<AiSource> sources = validateRemoteSources(
      _parseSources(decoded['sources']),
    );
    final List<String> madhabNotes = _parseStringList(
      decoded['madhab_notes'] ?? decoded['madhabNotes'],
    );

    if (sources.isEmpty) {
      // Kaynak yoksa veya uydurma/geçersizse cevabı kabul etmeyiz.
      throw const _RemoteAiException(
        AiFailureKind.noVerifiedSource,
        'AI yanıtı doğrulanabilir kaynak içermiyor.',
      );
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
        final String label = item.trim();
        if (label.isEmpty) continue;
        sources.add(
          AiSource(
            kind: _kindFromLabel(label),
            label: label,
            detail: _defaultDetailForKind(_kindFromLabel(label)),
          ),
        );
      } else if (item is Map) {
        final Object? label =
            item['label'] ?? item['ref'] ?? item['citation'] ?? item['title'];
        if (label is! String || label.trim().isEmpty) continue;
        final Object? kind = item['type'] ?? item['kind'];
        final AiSourceKind resolvedKind = kind == null
            ? _kindFromLabel(label.trim())
            : AiSourceKind.fromJson(kind);
        final String? section =
            (item['detail'] ?? item['section'] ?? item['chapter']) as String?;
        sources.add(
          AiSource(
            kind: resolvedKind,
            label: label.trim(),
            detail: section ?? _defaultDetailForKind(resolvedKind),
            url: item['url'] is String ? item['url'] as String : null,
          ),
        );
      }
    }
    return sources;
  }

  static String _defaultDetailForKind(AiSourceKind kind) => switch (kind) {
    AiSourceKind.quran => 'Kur\'an-ı Kerim',
    AiSourceKind.hadith => 'Hadis kaynağı',
    AiSourceKind.fiqh => 'Fıkıh / İlmihal kaynağı',
    AiSourceKind.other => 'Doğrulanmış kaynak',
  };

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

  /// Doğrulanmış kaynak bulunamadığında veya uzak hata oluştuğunda dürüst yanıt.
  AiAnswer _fallback(
    String question, {
    AiFailureKind failureKind = AiFailureKind.noVerifiedSource,
    List<RetrievedPassage> ragPassages = const <RetrievedPassage>[],
  }) {
    final List<String> suggestions = ragPassages.isNotEmpty
        ? ragPassages
              .map((RetrievedPassage p) => p.entry.title)
              .toList(growable: false)
        : _suggestionsFor(question);

    final String prefix = switch (failureKind) {
      AiFailureKind.networkError =>
        'İnternet bağlantısı veya sunucu erişimi sağlanamadı; bu sorunun '
            'tam karşılığı çevrimdışı onaylı bilgi tabanında da bulunamadı. ',
      AiFailureKind.apiError =>
        'Yapay zekâ servisine şu anda ulaşılamadı ve bu soru için çevrimdışı '
            'bilgi tabanında doğrudan eşleşme bulunamadı. ',
      AiFailureKind.quotaExceeded => 'Günlük ücretsiz soru kotanız doldu. ',
      AiFailureKind.noVerifiedSource || AiFailureKind.none =>
        'Bu sorunun cevabını güvenilir kaynaklarla eşleştiremedim. ',
    };

    return AiAnswer(
      text:
          '${prefix}Kesin hüküm vermemek ve kaynak uydurmamak adına tahmin yürütmüyorum.\n\n'
          'Şunları deneyebilirsiniz:\n'
          '• Soruyu daha kısa ve net sorun (ör. "İslam\'ın şartları nelerdir?", "vitir kaç rekât?")\n'
          '• Aşağıdaki doğrulanmış konu başlıklarından birini seçin\n'
          '• Kişisel durumunuza özel fetva için müftülüğe veya Din İşleri Yüksek Kurulu\'na danışın',
      sources: const <AiSource>[
        AiSource(
          kind: AiSourceKind.fiqh,
          label: 'Genel ilke: bilmediğini söylemek ilmin gereğidir',
          detail:
              'Kaynakla doğrulanamayan konularda hüküm vermekten kaçınılır.',
        ),
      ],
      mode: AiAnswerMode.offline,
      failureKind: failureKind == AiFailureKind.none
          ? AiFailureKind.noVerifiedSource
          : failureKind,
      relatedQuestions: suggestions,
      disclaimer:
          'Bu cevap bir dini hüküm değildir; kişisel durumunuza göre bağlayıcı görüş için '
          'bir müftülüğe danışmanız önerilir.',
      createdAt: DateTime.now(),
    );
  }

  void dispose() => _client.close();
}

/// Tanınan hadis kaynakları (künye metninden kaynak türü çıkarımı için).
const List<String> _hadithCollections = <String>[
  'Buhârî',
  'Müslim',
  'Tirmizî',
  'İbn Mâce',
  'Dârimî',
  'Taberânî',
  'Nesâî',
  'Ebû Dâvûd',
  'Ahmed b. Hanbel',
];

/// Hadis kaynağı künyesi mi? (Buhârî, Müslim, sünenler, müsnedler…)
bool _isHadithCitation(String citation) {
  for (final String collection in _hadithCollections) {
    if (citation.contains(collection)) return true;
  }
  return false;
}

/// Künye metninden kaynak türü çıkarımı.
AiSourceKind _kindFromLabel(String label) {
  if (label.startsWith('Kur')) return AiSourceKind.quran;
  if (_isHadithCitation(label)) return AiSourceKind.hadith;
  if (label.contains('Diyanet') || label.contains('İlmihal')) {
    return AiSourceKind.fiqh;
  }
  return AiSourceKind.other;
}
