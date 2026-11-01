import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/logger.dart';
import 'preferences_service.dart';

/// Kullanıcının yapay zekâ yanıtı için yaptığı bildirim.
class AiReport {
  const AiReport({
    required this.id,
    required this.reason,
    required this.excerpt,
    required this.createdAt,
    this.question,
    this.forwarded = false,
  });

  final String id;
  final String reason;
  final String excerpt;
  final DateTime createdAt;
  final String? question;

  /// Sunucuya iletildi mi? (Sunucu yoksa yalnızca cihazda saklanır.)
  final bool forwarded;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'reason': reason,
    'excerpt': excerpt,
    'createdAt': createdAt.toIso8601String(),
    'question': question,
    'forwarded': forwarded,
  };

  static AiReport? fromJson(Map<String, Object?> json) {
    try {
      return AiReport(
        id: json['id'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        excerpt: json['excerpt'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        question: json['question'] as String?,
        forwarded: json['forwarded'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}

/// **Yapay zekâ yanıtlarını bildirme servisi.**
///
/// Google Play'in *AI-Generated Content* politikası, üretken yapay zekâ sunan
/// uygulamalarda kullanıcının **uygunsuz/hatalı içeriği bildirebilmesini**
/// şart koşar. Bu servis:
///
/// 1. Bildirimi **cihazda** saklar (en fazla [maxStored] kayıt) — internet
///    gerekmez, gizlilik dostudur.
/// 2. Backend yapılandırılmışsa (`EZANAI_API_BASE`) bildirimi sunucuya iletir;
///    iletimek başarısız olsa bile kayıt cihazda kalır.
/// 3. Bildirim metnine **kişisel veri eklemez** (konum, kimlik yok).
class AiReportService {
  AiReportService(this._prefs, {http.Client? client})
    : _client = client ?? http.Client();

  final PreferencesService _prefs;
  final http.Client _client;

  static const String prefsKey = 'ai_reports_v1';
  static const int maxStored = 100;

  /// Kayıtlı bildirimler (en yeni önce).
  List<AiReport> recent() {
    return _prefs
        .getJsonList(prefsKey)
        .map(AiReport.fromJson)
        .whereType<AiReport>()
        .toList(growable: false);
  }

  /// Yeni bir bildirim oluşturur.
  Future<AiReport> report({
    required String reason,
    required String answer,
    String? question,
  }) async {
    final String excerpt = answer.length > 280
        ? '${answer.substring(0, 280)}…'
        : answer;
    final AiReport entry = AiReport(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      reason: reason,
      excerpt: excerpt,
      createdAt: DateTime.now(),
      question: question,
    );
    final AiReport stored = await _forwardOrKeep(entry);

    final List<AiReport> all = <AiReport>[stored, ...recent()];
    final List<AiReport> trimmed = all.length > maxStored
        ? all.sublist(0, maxStored)
        : all;
    await _prefs.setJsonList(prefsKey, <Map<String, Object?>>[
      for (final AiReport item in trimmed) item.toJson(),
    ]);
    AppLog.info('AI yanıtı bildirildi (${entry.reason}).');
    return stored;
  }

  Future<AiReport> _forwardOrKeep(AiReport entry) async {
    final Uri? uri = AppConfig.endpoint('ai/report');
    if (uri == null) return entry;
    try {
      final http.Response response = await _client
          .post(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, Object?>{
              'reason': entry.reason,
              'excerpt': entry.excerpt,
              'question': entry.question,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AiReport(
          id: entry.id,
          reason: entry.reason,
          excerpt: entry.excerpt,
          createdAt: entry.createdAt,
          question: entry.question,
          forwarded: true,
        );
      }
      AppLog.warning('AI bildirimi iletilemedi: HTTP ${response.statusCode}');
    } catch (error) {
      AppLog.warning('AI bildirimi iletilemedi: $error');
    }
    return entry;
  }

  /// Bildirim nedenleri (arayüzde gösterilir).
  static const List<String> reasons = <String>[
    'Yanlış veya yanıltıcı dinî bilgi',
    'Kaynak gösterilmemiş / uydurma kaynak',
    'Mezhep farkı belirtilmemiş',
    'Saygısız veya uygunsuz ifade',
    'Diğer',
  ];
}
