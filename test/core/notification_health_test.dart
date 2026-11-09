import 'package:ezanai/core/constants/app_constants.dart';
import 'package:ezanai/core/services/notification_service.dart';
import 'package:ezanai/data/models/app_settings.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bildirim zincirinin "hiç görünmüyor" durumlarını doğru raporladığını
/// ve planlama/iptal kimliklerinin çakışmadığını doğrular.
void main() {
  group('bildirim sağlığı', () {
    test('kanal kapatılmışsa engellenmiş sayılır', () {
      const NotificationHealth health = NotificationHealth(
        channelImportance: 0,
      );
      expect(health.channelBlocked, isTrue);
      expect(health.blocked, isTrue);
    });

    test('kanal açık ve izin varsa engel yok', () {
      const NotificationHealth health = NotificationHealth(
        channelImportance: 4,
      );
      expect(health.channelBlocked, isFalse);
      expect(health.blocked, isFalse);
    });

    test('bildirim izni yoksa engellenmiş sayılır', () {
      const NotificationHealth health = NotificationHealth(
        appNotificationsEnabled: false,
        channelImportance: 4,
      );
      expect(health.blocked, isTrue);
    });

    test('servis başlatılamadıysa engellenmiş sayılır', () {
      const NotificationHealth health = NotificationHealth(ready: false);
      expect(health.blocked, isTrue);
    });

    test('Android dışı ortamda uyarı gösterilmez', () {
      expect(NotificationHealth.notApplicable.supported, isFalse);
      expect(NotificationHealth.notApplicable.blocked, isFalse);
    });
  });

  group('zamanlama raporu', () {
    test('hata yoksa başarılı', () {
      const NotificationScheduleReport report = NotificationScheduleReport(
        scheduled: 42,
      );
      expect(report.ok, isTrue);
    });

    test('tek hata bile raporu başarısız yapar', () {
      const NotificationScheduleReport report = NotificationScheduleReport(
        scheduled: 41,
        failed: 1,
        error: 'invalid_icon',
      );
      expect(report.ok, isFalse);
      expect(report.error, 'invalid_icon');
    });
  });

  group('kanal kimlikleri', () {
    test('sessiz ses namaz kanalını kullanır', () {
      expect(
        NotificationService.adhanChannelId(AdhanSound.silent),
        NotificationChannels.prayer,
      );
    });

    test('sistem sesi ayrı (v5) kanal kullanır', () {
      expect(
        NotificationService.adhanChannelId(AdhanSound.systemDefault),
        '${NotificationChannels.adhan}_v5_system_default',
      );
    });

    test('her ezan sesi için kanal kimliği benzersiz', () {
      final Set<String> ids = <String>{
        for (final AdhanSound sound in AdhanSound.values)
          NotificationService.adhanChannelId(sound),
      };
      // Sessiz ses namaz kanalına düşer; kalan her ses kendi kanalını açar.
      expect(ids.length, AdhanSound.values.length);
    });
  });

  group('iptal ufku planlama ufkunu kapsar', () {
    test('15 günlük planın tüm kimlikleri iptal aralığında', () {
      const int plannedDays = 15;
      expect(NotificationIds.maxCancelDays, greaterThanOrEqualTo(plannedDays));

      final Set<int> ids = <int>{};
      for (int day = 0; day < NotificationIds.maxCancelDays; day++) {
        for (final Prayer prayer in Prayer.values) {
          expect(ids.add(NotificationIds.adhan(day, prayer)), isTrue);
          expect(ids.add(NotificationIds.pre(day, prayer)), isTrue);
        }
        for (int slot = 0; slot < 7; slot++) {
          expect(ids.add(NotificationIds.nafile(day, slot)), isTrue);
        }
      }
    });
  });
}
