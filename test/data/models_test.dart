import 'package:ezanai/core/utils/geo.dart';
import 'package:ezanai/data/hijri/hijri_calendar.dart';
import 'package:ezanai/data/models/app_settings.dart';
import 'package:ezanai/data/models/hijri_date.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:ezanai/data/models/prayer_times_day.dart';
import 'package:ezanai/data/prayer/prayer_calculator.dart';
import 'package:ezanai/design/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings', () {
    test('varsayılan ayarlar Diyanet yöntemini kullanır', () {
      const AppSettings settings = AppSettings();
      expect(settings.calculationMethodId, 'diyanet');
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.notifications.enabled, isTrue);
      expect(settings.notifications.prayerEnabled[Prayer.gunes], isFalse);
    });

    test('JSON gidiş-dönüşü değerleri korur', () {
      const AppSettings settings = AppSettings(
        calculationMethodId: 'mwl',
        asrHanafi: true,
        use24Hour: false,
        hijriOffsetDays: -1,
        quranFontSize: 30,
        manualOffsets: <String, int>{'imsak': 3, 'yatsi': -2},
        notifications: NotificationSettings(
          preReminderMinutes: 15,
          adhanSound: AdhanSound.tone2,
          fridayNotification: false,
        ),
      );
      final AppSettings restored = AppSettings.fromPrefs(settings.toPrefs());
      expect(restored.calculationMethodId, 'mwl');
      expect(restored.asrHanafi, isTrue);
      expect(restored.use24Hour, isFalse);
      expect(restored.hijriOffsetDays, -1);
      expect(restored.quranFontSize, 30);
      expect(restored.manualOffsets['imsak'], 3);
      expect(restored.manualOffsets['yatsi'], -2);
      expect(restored.notifications.preReminderMinutes, 15);
      expect(restored.notifications.adhanSound, AdhanSound.tone2);
      expect(restored.notifications.fridayNotification, isFalse);
    });

    test('bozuk yedek varsayılanlara döner', () {
      final AppSettings restored = AppSettings.importJson('bu json değil');
      expect(restored.calculationMethodId, 'diyanet');
    });

    test('Hanefî ikindi yalnızca desteklenen yöntemlerde uygulanır', () {
      const AppSettings settings = AppSettings(asrHanafi: true);
      final CalculationMethod diyanet = settings.resolvedMethod(
        CalculationMethod.diyanet,
      );
      expect(diyanet.asrFactor, 2.0);

      final CalculationMethod tehran = settings.resolvedMethod(
        CalculationMethod.fromId('tehran'),
      );
      expect(tehran.asrFactor, CalculationMethod.fromId('tehran').asrFactor);
    });

    test('manuel düzeltmeler her yöntemde aktarılır', () {
      const AppSettings settings = AppSettings(
        manualOffsets: <String, int>{'ogle': 4},
      );
      final CalculationMethod method = settings.resolvedMethod(
        CalculationMethod.fromId('egypt'),
      );
      expect(method.manualOffsets['ogle'], 4);
    });
  });

  group('CalculationMethod', () {
    test('bilinmeyen kimlik Diyanet\'e döner', () {
      expect(CalculationMethod.fromId('yok-boyle-bir-yontem').id, 'diyanet');
      expect(CalculationMethod.fromId(null).id, 'diyanet');
    });

    test('tüm yöntemler geçerli açılara sahip', () {
      for (final CalculationMethod method in CalculationMethod.all) {
        expect(method.fajrAngle, inInclusiveRange(12, 20));
        expect(method.ishaAngle, inInclusiveRange(12, 20));
        expect(method.asrFactor, inInclusiveRange(1, 2));
        expect(method.name, isNotEmpty);
      }
    });
  });

  group('GeoUtils', () {
    test('Kâbe yönü Türkiye için güneydoğuyu gösterir', () {
      final double bearing = GeoUtils.qiblaBearing(41.0082, 28.9784);
      expect(bearing, inInclusiveRange(150, 165));
      final double normalized = GeoUtils.normalizeDegrees(bearing);
      expect(normalized, inInclusiveRange(0, 360));
    });

    test('Kâbe koordinatında mesafe sıfıra yakındır', () {
      final double distance = GeoUtils.distanceToKaabaKm(21.4225, 39.8262);
      expect(distance, lessThan(1));
    });

    test('İstanbul-Kâbe mesafesi ~2400 km', () {
      final double distance = GeoUtils.distanceToKaabaKm(41.0082, 28.9784);
      expect(distance, inInclusiveRange(2300, 2500));
    });
  });

  group('HijriCalendar', () {
    late HijriCalendar calendar;

    setUpAll(() async {
      calendar = await HijriCalendar.load();
    });

    test('bugünü hicri tarihe çevirir', () {
      final HijriDate today = calendar.toHijri(DateTime(2026, 3, 20));
      expect(today.year, inInclusiveRange(1440, 1500));
      expect(today.month, inInclusiveRange(1, 12));
      expect(today.day, inInclusiveRange(1, 30));
      expect(today.monthName, isNotEmpty);
    });

    test('gün farkı hesabı ve geri dönüş tutarlı', () {
      final DateTime gregorian = DateTime(2026, 5, 27);
      final HijriDate hijri = calendar.toHijri(gregorian);
      final DateTime back = calendar.toGregorian(hijri);
      expect(back.year, gregorian.year);
      expect(back.month, gregorian.month);
      expect(back.day, gregorian.day);
    });

    test('ay uzunluğu 29 veya 30 gündür', () {
      final HijriDate hijri = calendar.toHijri(DateTime(2026, 1, 1));
      expect(calendar.monthLength(hijri), inInclusiveRange(29, 30));
    });

    test('Ramazan başlangıcı hicri 9. ayın 1. günüdür', () {
      final DateTime start = calendar.ramadanStart(1447);
      final HijriDate hijri = calendar.toHijri(start);
      expect(hijri.month, 9);
      expect(hijri.day, 1);
    });
  });

  group('PrayerTimesDay', () {
    PrayerTimesDay buildDay() {
      final DateTime date = DateTime(2026, 6, 21);
      return PrayerTimesDay(
        date: date,
        source: 'calculation',
        times: <Prayer, DateTime>{
          Prayer.imsak: DateTime(2026, 6, 21, 3, 20),
          Prayer.gunes: DateTime(2026, 6, 21, 5, 15),
          Prayer.ogle: DateTime(2026, 6, 21, 13, 5),
          Prayer.ikindi: DateTime(2026, 6, 21, 17, 0),
          Prayer.aksam: DateTime(2026, 6, 21, 20, 45),
          Prayer.yatsi: DateTime(2026, 6, 21, 22, 20),
        },
      );
    }

    test('sıralı veri sağlıklı kabul edilir', () {
      expect(buildDay().isSane, isTrue);
    });

    test('sonraki vakit ve içinde bulunulan vakit doğru bulunur', () {
      final PrayerTimesDay day = buildDay();
      final PrayerTime? next = day.nextPrayer(DateTime(2026, 6, 21, 13, 30));
      expect(next?.prayer, Prayer.ikindi);
      expect(day.currentPrayer(DateTime(2026, 6, 21, 13, 30)), Prayer.ogle);
      expect(day.currentPrayer(DateTime(2026, 6, 21, 23, 0)), Prayer.yatsi);
      expect(
        day.remainingTo(next!, DateTime(2026, 6, 21, 13, 30)),
        const Duration(hours: 3, minutes: 30),
      );
    });

    test('bozuk veri sağlıksız kabul edilir', () {
      final PrayerTimesDay broken = PrayerTimesDay(
        date: DateTime(2026, 6, 21),
        source: 'calculation',
        times: const <Prayer, DateTime>{},
      );
      expect(broken.isSane, isFalse);
    });

    test('JSON gidiş-dönüşü vakitleri korur', () {
      final PrayerTimesDay day = buildDay();
      final PrayerTimesDay restored = PrayerTimesDay.fromJson(day.toJson());
      expect(restored.times[Prayer.imsak], day.times[Prayer.imsak]);
      expect(restored.times[Prayer.yatsi], day.times[Prayer.yatsi]);
      expect(restored.source, day.source);
    });
  });
}
