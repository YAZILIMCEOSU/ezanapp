import 'package:ezanai/core/services/notification_service.dart';
import 'package:ezanai/data/models/app_settings.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bildirim planlamasının **saf mantık** testleri.
///
/// Gerçek zamanlama (`zonedSchedule`) platform kanalı gerektirdiği için burada
/// yalnızca karar mantığı doğrulanır: hangi vakit bildirilir, kimlikler
/// çakışır mı, sessiz saat uygulanır mı, bildirim yükü doğru ekrana gider mi.
/// Cihaz üzerindeki gerçek bildirim testi `docs/PHASES.md` §5'te listelenir.
void main() {
  group('bildirim kimlikleri', () {
    test('yedi gün × altı vakit için kimlikler benzersiz', () {
      final Set<int> ids = <int>{};
      for (int day = 0; day < 7; day++) {
        for (final Prayer prayer in Prayer.values) {
          expect(ids.add(NotificationIds.adhan(day, prayer)), isTrue);
          expect(ids.add(NotificationIds.pre(day, prayer)), isTrue);
        }
      }
      expect(ids.length, 7 * 6 * 2);
    });

    test('kimlikler ilgili aralıkta kalır', () {
      for (int day = 0; day < 7; day++) {
        for (final Prayer prayer in Prayer.values) {
          final int adhan = NotificationIds.adhan(day, prayer);
          final int pre = NotificationIds.pre(day, prayer);
          expect(adhan, greaterThanOrEqualTo(NotificationIds.baseAdhan));
          expect(adhan, lessThan(NotificationIds.preReminder));
          expect(pre, greaterThanOrEqualTo(NotificationIds.preReminder));
        }
      }
    });

    test('vakit kimlikleri tekil bildirim kimlikleriyle çakışmaz', () {
      const List<int> tekil = <int>[
        NotificationIds.friday,
        NotificationIds.ramadanSahur,
        NotificationIds.ramadanIftar,
        NotificationIds.dailyVerse,
        NotificationIds.dailyHadith,
        NotificationIds.zikirReminder,
        NotificationIds.hatimReminder,
        NotificationIds.test,
      ];
      expect(
        tekil.toSet().length,
        tekil.length,
        reason: 'Tekil kimlikler benzersiz',
      );
      for (final int id in tekil) {
        expect(id, greaterThanOrEqualTo(3001));
      }
      for (int day = 0; day < 7; day++) {
        for (final Prayer prayer in Prayer.values) {
          expect(tekil, isNot(contains(NotificationIds.adhan(day, prayer))));
          expect(tekil, isNot(contains(NotificationIds.pre(day, prayer))));
        }
      }
    });
  });

  group('bildirim yönlendirme yükü', () {
    test('her hedef kendi yüküyle ayrışır', () {
      for (final NotificationRoute route in NotificationRoute.values) {
        expect(NotificationRoute.fromPayload(route.value), route);
      }
    });

    test('ayrıntılı yükler ve tanımsız yükler güvenli', () {
      expect(
        NotificationRoute.fromPayload('adhan:aksam'),
        NotificationRoute.adhan,
      );
      expect(
        NotificationRoute.fromPayload('times:imsak'),
        NotificationRoute.times,
      );
      expect(NotificationRoute.fromPayload(null), NotificationRoute.home);
      expect(
        NotificationRoute.fromPayload('tanimsiz:yuk'),
        NotificationRoute.home,
      );
      expect(NotificationRoute.fromPayload(''), NotificationRoute.home);
    });
  });

  group('vakit bildirimi kararları', () {
    const NotificationSettings defaults = NotificationSettings();

    test('varsayılan olarak güneş vakti bildirilmez', () {
      expect(defaults.isEnabledFor(Prayer.imsak), isTrue);
      expect(defaults.isEnabledFor(Prayer.ogle), isTrue);
      expect(defaults.isEnabledFor(Prayer.ikindi), isTrue);
      expect(defaults.isEnabledFor(Prayer.aksam), isTrue);
      expect(defaults.isEnabledFor(Prayer.yatsi), isTrue);
      expect(defaults.isEnabledFor(Prayer.gunes), isFalse);
    });

    test('kullanıcı bir vakti kapatabilir', () {
      final NotificationSettings settings = defaults.copyWith(
        prayerEnabled: <Prayer, bool>{
          ...defaults.prayerEnabled,
          Prayer.aksam: false,
        },
      );
      expect(settings.isEnabledFor(Prayer.aksam), isFalse);
      expect(settings.isEnabledFor(Prayer.yatsi), isTrue);
    });

    test('bildirimler tümden kapatılınca hiçbir vakit bildirilmez', () {
      final NotificationSettings settings = defaults.copyWith(enabled: false);
      for (final Prayer prayer in Prayer.values) {
        expect(settings.isEnabledFor(prayer), isFalse);
      }
    });

    test('eksik ayar güvenli tarafta kalır (kapalı sayılır)', () {
      final NotificationSettings settings = defaults.copyWith(
        prayerEnabled: const <Prayer, bool>{Prayer.aksam: true},
      );
      expect(settings.isEnabledFor(Prayer.aksam), isTrue);
      expect(settings.isEnabledFor(Prayer.imsak), isFalse);
    });
  });

  group('sessiz saat ve uyku modu', () {
    const NotificationSettings defaults = NotificationSettings();

    test('varsayılan sessiz saat kapalı', () {
      expect(defaults.isInQuietHours(23 * 60 + 30), isFalse);
      expect(defaults.isInQuietHours(3 * 60), isFalse);
    });

    test('sessiz saat aralığı gece yarısını aşabilir', () {
      final NotificationSettings settings = defaults.copyWith(
        quietHoursEnabled: true,
      );
      expect(settings.isInQuietHours(23 * 60), isTrue);
      expect(settings.isInQuietHours(23 * 60 + 59), isTrue);
      expect(settings.isInQuietHours(5 * 60 + 59), isTrue);
      expect(settings.isInQuietHours(6 * 60), isFalse);
      expect(settings.isInQuietHours(22 * 60 + 59), isFalse);
      expect(settings.isInQuietHours(12 * 60), isFalse);
    });

    test('uyku modu 22:00–07:00 arasını kapsar', () {
      final NotificationSettings settings = defaults.copyWith(
        sleepModeEnabled: true,
      );
      expect(settings.isInQuietHours(22 * 60), isTrue);
      expect(settings.isInQuietHours(2 * 60), isTrue);
      expect(settings.isInQuietHours(6 * 60 + 59), isTrue);
      expect(settings.isInQuietHours(7 * 60), isFalse);
      expect(settings.isInQuietHours(21 * 60 + 59), isFalse);
    });

    test('öğle vakti sessiz saate girmez', () {
      final NotificationSettings settings = defaults.copyWith(
        quietHoursEnabled: true,
        sleepModeEnabled: true,
      );
      expect(settings.isInQuietHours(13 * 60), isFalse);
    });
  });

  group('ön hatırlatma ve gün sayısı', () {
    test('ön hatırlatma varsayılan olarak kapalı', () {
      expect(const NotificationSettings().preReminderMinutes, 0);
    });

    test('ön hatırlatma dakikası ayarlanabilir', () {
      final NotificationSettings settings = const NotificationSettings()
          .copyWith(preReminderMinutes: 15);
      expect(settings.preReminderMinutes, 15);
      expect(settings.adhanVolume, inInclusiveRange(0, 1));
    });

    test('zamanlanan gün sayısı makul aralıkta', () {
      expect(
        const NotificationSettings().daysToSchedule,
        inInclusiveRange(1, 30),
      );
    });
  });
}
