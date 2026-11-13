import 'package:ezanai/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('saat dilimi çözümü', () {
    test('cihazın IANA bölgesi kaydırmayla uyuyorsa aynen kullanılır', () {
      final tz.Location berlin = tz.getLocation('Europe/Berlin');
      final String resolved = NotificationService.resolveLocationName(
        'Europe/Berlin',
        berlin.currentTimeZone.offset,
      );
      expect(resolved, 'Europe/Berlin');
    });

    test('bilinmeyen bölge adı çökertmez, kaydırmaya düşer', () {
      final String resolved = NotificationService.resolveLocationName(
        'Mars/Olympus',
        const Duration(hours: 3),
      );
      expect(resolved, 'Europe/Istanbul');
      expect(
        tz.getLocation(resolved).currentTimeZone.offset,
        const Duration(hours: 3),
      );
    });

    test('kaydırmayla uyuşmayan IANA adı reddedilir', () {
      final String resolved = NotificationService.resolveLocationName(
        'Europe/Berlin',
        const Duration(hours: 3),
      );
      expect(resolved, 'Europe/Istanbul');
    });

    test('yarım saatlik dilimler 30 dakika kaymaz', () {
      // Cihazın gerçek kaydırması her zaman tz veritabanındaki bir bölgenin
      // **o anki** kaydırmasıdır. Bu yüzden test, sabit uydurma kaydırma
      // yerine gerçek yarım saatlik bölgelerin bugünkü kaydırmasını kullanır.
      for (final String zone in <String>[
        'Asia/Kolkata',
        'Asia/Tehran',
        'America/St_Johns',
      ]) {
        final Duration offset = tz.getLocation(zone).currentTimeZone.offset;
        expect(offset.inMinutes % 60, isNot(0), reason: '$zone tam saat değil');
        final String resolved = NotificationService.resolveLocationName(
          null,
          offset,
        );
        expect(
          tz.getLocation(resolved).currentTimeZone.offset,
          offset,
          reason: '$zone ($offset) -> $resolved',
        );
      }
    });

    test('veritabanında karşılığı olmayan kaydırma çökertmez', () {
      // Örnek: hiçbir bölgenin o an -2:30 olmadığı bir tarihte (kışın
      // Newfoundland -3:30'dur) son çare tam saatlik dilime düşer.
      final String resolved = NotificationService.resolveLocationName(
        null,
        const Duration(hours: -2, minutes: -30),
      );
      expect(resolved, isNotEmpty);
      expect(tz.getLocation(resolved).currentTimeZone.offset.inMinutes % 60, 0);
    });
  });
}
