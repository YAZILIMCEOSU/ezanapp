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
      for (final Duration offset in <Duration>[
        const Duration(hours: 5, minutes: 30),
        const Duration(hours: 3, minutes: 30),
        const Duration(hours: -3, minutes: 30),
      ]) {
        final String resolved = NotificationService.resolveLocationName(
          null,
          offset,
        );
        expect(
          tz.getLocation(resolved).currentTimeZone.offset,
          offset,
          reason: '$offset için ${resolved.isEmpty ? '(boş)' : resolved}',
        );
      }
    });
  });
}
