import 'dart:convert';

import 'package:ezanai/core/config/app_config.dart';
import 'package:ezanai/data/ai/ai_service.dart';
import 'package:ezanai/data/models/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Uzak AI sözleşmesi ve zarif bozulma (graceful degradation) testleri.
///
/// Bu dosyadaki uzak yol testleri backend adresi tanımlı olduğunda çalışır:
///
/// ```bash
/// flutter test test/data/ai_remote_test.dart \
///   --dart-define=EZANAI_API_BASE=https://backend.test
/// ```
///
/// CI bu komutu ayrı bir adımda çalıştırır; normal `flutter test` koşusunda
/// uzak testler "atlandı" olarak işaretlenir.
void main() {
  final bool configured = AppConfig.hasBackend;

  AiService serviceWith(MockClient client) =>
      AiService(client: client, local: LocalKnowledgeSource());

  group('backend yapılandırılmadığında', () {
    test('soru yerel bilgi tabanından kaynaklı yanıtlanır', () async {
      final AiService service = AiService(
        client: MockClient((http.Request request) async {
          fail('Backend kapalıyken ağ isteği yapılmamalı: ${request.url}');
        }),
      );
      final AiAnswer answer = await service.ask('Abdest nasıl alınır?');
      expect(answer.hasSources, isTrue);
      expect(answer.mode, AiAnswerMode.offline);
      expect(answer.text, isNotEmpty);
    });

    test('bilinmeyen soruda dürüst "bilmiyorum" cevabı döner', () async {
      final AiService service = AiService(
        client: MockClient((http.Request request) async {
          fail('Backend kapalıyken ağ isteği yapılmamalı: ${request.url}');
        }),
      );
      final AiAnswer answer = await service.ask('zzz qqq xxx');
      expect(answer.text, contains('eşleştiremedim'));
      expect(answer.sources, isNotEmpty, reason: 'İlke künyesi gösterilir');
      expect(answer.relatedQuestions, isNotEmpty);
    });
  }, skip: configured ? 'Bu koşuda backend adresi tanımlı' : false);

  // Not: uzak yola giden sorular, yerel bilgi tabanında karşılığı olmayan
  // sorulardır; yerel eşleşme varsa AiService zaten çevrimdışı yanıt verir.
  group('backend yapılandırıldığında', () {
    test('kaynaklı uzak yanıt kabul edilir', () async {
      final AiService service = serviceWith(
        MockClient((http.Request request) async {
          expect(request.url.path, endsWith('/ai/ask'));
          expect(request.headers['Content-Type'], contains('application/json'));
          final Map<String, Object?> body =
              jsonDecode(request.body) as Map<String, Object?>;
          expect(body['language'], 'tr');
          expect(body['question'], isNotEmpty);
          return http.Response(
            jsonEncode(<String, Object?>{
              'answer': 'Bu konunun ayrıntısı kaynaklarda yer alır.',
              'sources': <Object>[
                'Kur\'an-ı Kerim, Târık 86/1-17',
                <String, Object?>{
                  'label': 'Buhârî, Tefsîr 1',
                  'kind': 'hadith',
                },
              ],
              'madhab_notes': <String>[
                'Görüş ayrılığı olan noktalar mezhebe göre belirtilir.',
              ],
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      // Yerel bilgi tabanında karşılığı olmayan bir soru seçilir; aksi hâlde
      // AiService haklı olarak çevrimdışı yanıt döndürür ve uzak yol denenmez.
      final AiAnswer answer = await service.ask(
        'Tarık suresinin fazileti nedir?',
      );
      expect(answer.mode, AiAnswerMode.remote);
      expect(answer.text, contains('kaynaklarda'));
      expect(answer.sources.length, 2);
      expect(
        answer.sources.first.kind,
        AiSourceKind.quran,
        reason: 'Düz metin künyede de tür çıkarılmalı',
      );
      expect(answer.sources[1].kind, AiSourceKind.hadith);
      expect(answer.sources[1].label, contains('Buhârî'));
      expect(answer.madhabNotes, isNotEmpty);
      expect(answer.disclaimer, contains('kesin'));
    });

    test('kaynaksız uzak yanıt reddedilir, yerel tabana düşülür', () async {
      final AiService service = serviceWith(
        MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, Object?>{'answer': 'Kaynaksız iddia.'}),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      final AiAnswer answer = await service.ask('Abdest nasıl alınır?');
      expect(
        answer.mode,
        AiAnswerMode.offline,
        reason: 'Kaynaksız cevap kullanıcıya gösterilmemeli',
      );
      expect(answer.hasSources, isTrue);
    });

    test('sunucu hatasında (500) uygulama çökmez', () async {
      final AiService service = serviceWith(
        MockClient(
          (http.Request request) async => http.Response('Sunucu hatası', 500),
        ),
      );

      final AiAnswer answer = await service.ask('Cuma namazı farz mı?');
      expect(answer.mode, AiAnswerMode.offline);
      expect(answer.hasSources, isTrue);
    });

    test('bozuk JSON yanıtında uygulama çökmez', () async {
      final AiService service = serviceWith(
        MockClient(
          (http.Request request) async => http.Response('{ bu json degil', 200),
        ),
      );

      final AiAnswer answer = await service.ask('Cuma namazı farz mı?');
      expect(answer.mode, AiAnswerMode.offline);
    });

    test(
      'bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap',
      () async {
        final AiService service = serviceWith(
          MockClient(
            (http.Request request) async => http.Response(
              jsonEncode(<String, Object?>{'answer': 'Emin değilim.'}),
              200,
              headers: <String, String>{'content-type': 'application/json'},
            ),
          ),
        );

        final AiAnswer answer = await service.ask('zzz qqq xxx');
        expect(answer.mode, AiAnswerMode.offline);
        expect(answer.text, contains('eşleştiremedim'));
      },
    );

    test('uzak yanıtlara da öneri soruları eklenir', () async {
      final AiService service = serviceWith(
        MockClient(
          (http.Request request) async => http.Response(
            jsonEncode(<String, Object?>{
              'text': 'Kaynaklı cevap.',
              'sources': <String>['Kur\'an-ı Kerim, Bakara 2/186'],
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          ),
        ),
      );

      final AiAnswer answer = await service.ask(
        'Şeytan taşlama kaç taşla yapılır?',
      );
      expect(answer.mode, AiAnswerMode.remote);
      expect(answer.relatedQuestions, isNotEmpty);
      expect(
        answer.relatedQuestions.every((String q) => !q.contains('_')),
        isTrue,
        reason: 'Öneriler kayıt kimliği değil başlık olmalı',
      );
    });
  }, skip: configured ? false : 'EZANAI_API_BASE tanımlı değil');
}
