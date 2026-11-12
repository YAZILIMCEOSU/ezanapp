import 'package:ezanai/data/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gizlilik beyanı ile kodun aynı şeyi söylemesini güvence altına alır.
void main() {
  group('Gizlilik varsayılanları', () {
    test('analitik ve çökme raporları varsayılan olarak kapalı', () {
      const AppSettings settings = AppSettings();
      expect(settings.analyticsEnabled, isFalse);
      expect(settings.crashReportingEnabled, isFalse);
    });

    test('eski ayar yedeğinde alan yoksa kapalı kabul edilir', () {
      final AppSettings settings = AppSettings.fromPrefs(
        const <String, Object?>{'themeMode': 'system'},
      );
      expect(settings.analyticsEnabled, isFalse);
      expect(settings.crashReportingEnabled, isFalse);
    });

    test('JSON gidiş-dönüşünde kapalı tercih korunur', () {
      const AppSettings settings = AppSettings();
      final AppSettings restored = AppSettings.importJson(
        settings.exportJson(),
      );
      expect(restored.analyticsEnabled, isFalse);
      expect(restored.crashReportingEnabled, isFalse);
    });
  });

  group('Ses etiketleri', () {
    test('hiçbir ses etiketi doğrulanmamış sanatçı/müezzin adı içermez', () {
      const List<String> forbidden = <String>[
        'abdülbâsıt',
        'abdulbasit',
        'muhammed rıfat',
        'minşâvî',
        'minshawi',
        'harem-i şerîf',
        'kâbe imamı',
        'gerçek müezzin',
      ];
      for (final AdhanSound sound in AdhanSound.values) {
        final String text = '${sound.label} ${sound.description}'.toLowerCase();
        for (final String word in forbidden) {
          expect(
            text.contains(word),
            isFalse,
            reason: '${sound.name} etiketi "$word" içeriyor',
          );
        }
      }
    });

    test('tam ezan sesleri vokal sentez olarak etiketlenir', () {
      for (final AdhanSound sound in <AdhanSound>[
        AdhanSound.ezanMelodi,
        AdhanSound.segahMelodi,
        AdhanSound.tekbirMelodi,
      ]) {
        expect(sound.label.toLowerCase(), contains('vokal sentez'));
      }
    });
  });
}
