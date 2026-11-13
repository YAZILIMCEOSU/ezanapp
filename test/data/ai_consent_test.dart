import 'package:ezanai/data/ai/ai_service.dart';
import 'package:ezanai/data/models/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// KVKK: dinî inanç özel nitelikli veridir. Uzak AI, açık rıza olmadan
/// hiçbir soruyu sunucuya göndermemelidir.
void main() {
  group('Uzak AI rıza kapısı', () {
    test('allowRemote verilmezse yanıt çevrimdışı kalır', () async {
      final AiService service = AiService();
      final AiAnswer answer = await service.ask('Namaz kaç rekattır?');

      expect(answer.mode, AiAnswerMode.offline);
    });

    test('allowRemote=false iken ağa çıkılmaz', () async {
      final AiService service = AiService();
      final AiAnswer answer = await service.ask(
        'Tarık suresinin fazileti nedir?',
        allowRemote: false,
      );

      expect(answer.mode, AiAnswerMode.offline);
    });

    test('boş/çok kısa soru uzak yola hiç çıkmaz', () async {
      final AiService service = AiService();
      for (final String question in <String>['', ' ', 'a']) {
        final AiAnswer answer = await service.ask(question, allowRemote: true);
        expect(answer.mode, AiAnswerMode.offline, reason: 'soru: "$question"');
      }
    });
  });
}
