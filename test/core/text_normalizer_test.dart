import 'package:ezanai/core/utils/app_time.dart';
import 'package:ezanai/core/utils/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNormalizer', () {
    test('Türkçe karakterleri sadeleştirir', () {
      expect(TextNormalizer.normalize('Şükür'), 'sukur');
      expect(TextNormalizer.normalize('İmsak Çağı'), 'imsak cagi');
      expect(TextNormalizer.normalize('Öğle'), 'ogle');
    });

    test('kelimelere ayırır ve kısa kelimeleri atar', () {
      expect(TextNormalizer.tokens('Namaz kılmak ve zekât vermek'), <String>[
        'namaz',
        'kilmak',
        've',
        'zekat',
        'vermek',
      ]);
    });

    test('ekleri kaba biçimde kırpar', () {
      expect(
        TextNormalizer.stem(TextNormalizer.normalize('namazların')),
        'namaz',
      );
      expect(TextNormalizer.stem(TextNormalizer.normalize('kısa')), 'kisa');
    });

    test('eşleştirme aksan ve ek farklarını tolere eder', () {
      expect(TextNormalizer.matches('Namaz kılmak', 'namaz'), isTrue);
      expect(TextNormalizer.matches('Şükretmek gerekir', 'sukur'), isFalse);
      expect(TextNormalizer.matches('Şükür etmek gerekir', 'sukur'), isTrue);
      expect(TextNormalizer.matches('Oruç tutmak', 'zekat'), isFalse);
    });

    test('Arapça harekeleri kaldırır', () {
      expect(
        TextNormalizer.stripArabicDiacritics('بِسْمِ اللّٰهِ'),
        isNot(contains('ِ')),
      );
    });

    test('yüzde biçimi', () {
      expect(TextNormalizer.percent(0.75), '%75');
      expect(TextNormalizer.percent(2), '%100');
      expect(TextNormalizer.percent(double.nan), '%0');
    });
  });

  group('AppTime', () {
    test('geri sayım ve dijital sayaç biçimi', () {
      expect(
        AppTime.formatClock(const Duration(hours: 1, minutes: 5, seconds: 9)),
        '01:05:09',
      );
      expect(
        AppTime.formatCountdown(const Duration(hours: 1, minutes: 5)),
        '1s 05dk',
      );
      expect(AppTime.formatCountdown(const Duration(minutes: 3)), '3dk 00sn');
      expect(AppTime.formatCountdown(const Duration(seconds: 12)), '12sn');
    });

    test('24 saat ve 12 saat biçimi', () {
      final DateTime time = DateTime(2026, 1, 1, 17, 5);
      expect(AppTime.formatTime(time), '17:05');
      expect(AppTime.formatTime(time, use24Hour: false), contains('05'));
    });

    test('gün karşılaştırması', () {
      expect(
        AppTime.isSameDay(DateTime(2026, 5, 1, 23), DateTime(2026, 5, 1, 1)),
        isTrue,
      );
      expect(
        AppTime.isSameDay(DateTime(2026, 5, 1), DateTime(2026, 5, 2)),
        isFalse,
      );
    });
  });
}
