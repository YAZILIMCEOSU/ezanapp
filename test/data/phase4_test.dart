import 'package:ezanai/core/services/ai_report_service.dart';
import 'package:ezanai/core/services/home_widget_service.dart';
import 'package:ezanai/core/services/preferences_service.dart';
import 'package:ezanai/core/services/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Faz 4 doğrulama testleri.**
///
/// 1. Ana ekran widget'ı veri sözleşmesi (tarih/saat biçimi, şehir yedeği).
/// 2. Hutbe/dua sesli okuma metin hazırlığı (Arapça ayıklama, parçalama).
/// 3. Yapay zekâ yanıtı bildirim akışı (Play AI-Generated Content politikası).
void main() {
  group('1) Ana ekran widget verisi', () {
    test('vakit saati 24 saat biçiminde ve hedef zamanı doğru taşınır', () {
      final HomeWidgetPayload payload = HomeWidgetService.payloadFor(
        city: 'Bağcılar, İstanbul',
        prayerLabel: 'İkindi',
        prayerTime: DateTime(2026, 10, 27, 16, 41),
        hijri: '16 Cemaziyelevvel 1448',
      );
      expect(payload.time, '16:41');
      expect(payload.prayer, 'İkindi');
      expect(payload.city, 'Bağcılar, İstanbul');
      expect(payload.hijri, '16 Cemaziyelevvel 1448');
      expect(payload.target, DateTime(2026, 10, 27, 16, 41));
      expect(payload.headline, 'İkindi · 16:41');

      final Map<String, Object?> map = payload.toMap();
      expect(map['time'], '16:41');
      expect(map['targetMillis'], DateTime(2026, 10, 27, 16, 41).millisecondsSinceEpoch);
      expect(map.keys.toSet(), <String>{
        'city',
        'prayer',
        'time',
        'targetMillis',
        'hijri',
      });
    });

    test('şehir bilgisi boşsa anlaşılır yedek metin kullanılır', () {
      final HomeWidgetPayload payload = HomeWidgetService.payloadFor(
        city: '   ',
        prayerLabel: 'Akşam',
        prayerTime: DateTime(2026, 10, 27, 18, 48),
        hijri: '',
      );
      expect(payload.city, 'Konum seçilmedi');
      expect(payload.time, '18:48');
    });
  });

  group('2) Sesli okuma metni', () {
    test('Arapça hat ayıklanır, Türkçe metin korunur', () {
      const String mixed = 'Muhterem Müslümanlar!  بِسْمِ اللّٰهِ  Sabır ve şükür.';
      final String clean = TtsText.sanitize(mixed);
      expect(clean, contains('Muhterem Müslümanlar!'));
      expect(clean, contains('Sabır ve şükür.'));
      expect(clean, isNot(contains('بِسْمِ')));
      expect(clean, isNot(contains('  ')));
    });

    test('Arapça ayıklama kapatılabilir', () {
      expect(TtsText.sanitize('اللّٰه', stripArabic: false), 'اللّٰه');
    });

    test('kısa metin tek parça olarak döner', () {
      final List<String> chunks = TtsText.chunk('Kısa bir dua metni.');
      expect(chunks, <String>['Kısa bir dua metni.']);
    });

    test('boş metin sesli okunmaz', () {
      expect(TtsText.chunk('   '), isEmpty);
      expect(TtsText.chunk(''), isEmpty);
    });

    test('uzun hutbe 4000 karakter sınırını aşmayan parçalara bölünür', () {
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < 400; i++) {
        buffer.write('Bu cümle hutbe metninin bir parçasıdır ve test amaçlıdır. ');
      }
      final String text = buffer.toString().trim();
      expect(text.length, greaterThan(3000));

      final List<String> chunks = TtsText.chunk(text);
      expect(chunks.length, greaterThan(1));
      for (final String chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(TtsText.maxChunkChars));
        expect(chunk.trim(), isNotEmpty);
      }
      // Hiçbir kelime kaybolmamalı: parçalar birleşince aynı kelime sayısı.
      final int originalWords = text.split(' ').length;
      final int chunkWords = chunks
          .map((String c) => c.split(' ').length)
          .fold(0, (int a, int b) => a + b);
      expect(chunkWords, originalWords);
    });

    test('tek cümle sınırı aşarsa kelime sınırından zorunlu bölünür', () {
      final String single = List<String>.filled(900, 'kelime').join(' ');
      final List<String> chunks = TtsText.chunk(single, maxChars: 100);
      expect(chunks.length, greaterThan(1));
      for (final String chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(100));
      }
    });
  });

  group('3) Yapay zekâ yanıtı bildirimi', () {
    test('bildirim kaydedilir ve en yeni önce döner', () async {
      final PreferencesService prefs = PreferencesService(null);
      final AiReportService service = AiReportService(prefs);

      await service.report(
        reason: AiReportService.reasons.first,
        answer: 'Örnek yanıt metni.',
        question: 'Örnek soru?',
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await service.report(
        reason: AiReportService.reasons.last,
        answer: 'İkinci yanıt.',
      );

      final List<AiReport> reports = service.recent();
      expect(reports.length, 2);
      expect(reports.first.reason, AiReportService.reasons.last);
      expect(reports.last.question, 'Örnek soru?');
      expect(reports.last.forwarded, isFalse);
    });

    test('uzun yanıt 280 karakterlik özetle saklanır', () async {
      final PreferencesService prefs = PreferencesService(null);
      final AiReportService service = AiReportService(prefs);
      await service.report(
        reason: 'Diğer',
        answer: 'a' * 900,
      );
      final List<AiReport> reports = service.recent();
      expect(reports.single.excerpt.length, 281);
      expect(reports.single.excerpt.endsWith('…'), isTrue);
    });

    test('bildirim nedenleri kullanıcıya anlaşılır ve sıralı', () {
      expect(AiReportService.reasons, hasLength(5));
      expect(AiReportService.reasons.first, contains('dinî'));
      expect(AiReportService.reasons, contains('Diğer'));
    });

    test('JSON gidiş-dönüşü kaybolmadan çalışır', () {
      final AiReport report = AiReport(
        id: '42',
        reason: 'Diğer',
        excerpt: 'kısa',
        createdAt: DateTime(2026, 10, 27, 9, 30),
        question: 'soru',
        forwarded: true,
      );
      final AiReport? parsed = AiReport.fromJson(report.toJson());
      expect(parsed, isNotNull);
      expect(parsed!.id, '42');
      expect(parsed.createdAt, DateTime(2026, 10, 27, 9, 30));
      expect(parsed.forwarded, isTrue);
      expect(parsed.question, 'soru');
    });
  });
}
