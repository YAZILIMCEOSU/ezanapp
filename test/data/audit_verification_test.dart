import 'package:ezanai/app/app_runtime.dart';
import 'package:ezanai/core/audio/audio_service.dart';
import 'package:ezanai/core/constants/app_constants.dart';
import 'package:ezanai/core/l10n/app_strings.dart';
import 'package:ezanai/core/services/compass_service.dart';
import 'package:ezanai/core/utils/geo.dart';
import 'package:ezanai/core/utils/logger.dart';
import 'package:ezanai/data/ai/ai_service.dart';
import 'package:ezanai/data/models/ai_models.dart';
import 'package:ezanai/data/models/app_settings.dart';
import 'package:ezanai/data/models/city.dart';
import 'package:ezanai/data/models/hadith_models.dart';
import 'package:ezanai/data/models/ilahi_models.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:ezanai/data/models/prayer_times_day.dart';
import 'package:ezanai/data/models/quran_models.dart';
import 'package:ezanai/data/models/zikir_models.dart';
import 'package:ezanai/data/prayer/prayer_calculator.dart';
import 'package:ezanai/data/repositories/ai_repository.dart';
import 'package:ezanai/features/more/esmaul_husna_screen.dart';
import 'package:ezanai/state/content_providers.dart';
import 'package:ezanai/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_runtime.dart';

void main() {
  initTestDatabaseFactory();

  String? databaseProblem;

  setUpAll(() async {
    databaseProblem = await probeDatabase();
  });

  group('AI kota, kaynak doğrulama ve fetva güvenliği', () {
    test('günlük kota dolsa bile İslam\'ın ve imanın şartları gibi onaylı cevaplar engellenmez', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime();
      addTearDown(runtime.dispose);

      // Günlük ücretsiz kotayı tamamen doldur:
      for (int i = 0; i < kFreeDailyAiLimit; i++) {
        await runtime.ai.incrementUsage();
      }
      expect(await runtime.ai.canAsk(premium: false), isFalse);

      // 1) Kota doluyken "İslam'ın şartları nelerdir?" sorusu engellenmemeli:
      final AiAnswer islamAnswer = await runtime.ai.askWithQuota(
        'İslam\'ın şartları nelerdir?',
        premium: false,
      );
      expect(islamAnswer.failureKind, AiFailureKind.none);
      expect(islamAnswer.isVerifiedLocal, isTrue);
      expect(islamAnswer.hasSources, isTrue);
      expect(islamAnswer.text, contains('Kelime-i şehâdet'));

      // 2) Kota doluyken "İmanın şartları nelerdir?" sorusu engellenmemeli:
      final AiAnswer imanAnswer = await runtime.ai.askWithQuota(
        'İmanın şartları nelerdir?',
        premium: false,
      );
      expect(imanAnswer.failureKind, AiFailureKind.none);
      expect(imanAnswer.isVerifiedLocal, isTrue);
      expect(imanAnswer.hasSources, isTrue);
      expect(imanAnswer.text, contains('Allah\'a iman'));

      // 3) Yerel bilgi tabanında olmayan kapsamlı soru ise kota uyarısı döndürmeli:
      final AiAnswer blocked = await runtime.ai.askWithQuota(
        'Endülüs döneminde vakıf muhasebesi nasıl tutulurdu?',
        premium: false,
      );
      expect(blocked.failureKind, AiFailureKind.quotaExceeded);
      expect(blocked.text, contains('ücretsiz yapay zekâ soru hakkınız doldu'));
    });

    test('fetva soruları tespit edilir ve uydurma kaynaklar elenir', () {
      expect(AiService.isFatwaQuestion('Kripto para caiz midir?'), isTrue);
      expect(
        AiService.isFatwaQuestion('Diş fırçalamak orucu bozar mı?'),
        isTrue,
      );
      expect(
        AiService.isFatwaQuestion('İslam\'ın şartları nelerdir?'),
        isFalse,
      );

      final List<AiSource> filtered = AiService.validateRemoteSources(
        <AiSource>[
          const AiSource(kind: AiSourceKind.other, label: 'unknown'),
          const AiSource(kind: AiSourceKind.other, label: 'uydurma kaynak'),
          const AiSource(kind: AiSourceKind.other, label: 'ab'),
          const AiSource(
            kind: AiSourceKind.hadith,
            label: 'Buhârî, Îmân 1',
            detail: 'Hadis kaynağı',
          ),
        ],
      );
      expect(filtered.length, 1);
      expect(filtered.first.label, 'Buhârî, Îmân 1');
    });
  });

  group('Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot)', () {
    final DateTime dayDate = DateTime(2026, 10, 10);
    final DateTime tomorrowDate = DateTime(2026, 10, 11);

    final PrayerTimesDay today = PrayerTimesDay(
      date: dayDate,
      source: 'diyanet',
      times: <Prayer, DateTime>{
        Prayer.imsak: DateTime(2026, 10, 10, 5, 34),
        Prayer.gunes: DateTime(2026, 10, 10, 6, 59),
        Prayer.ogle: DateTime(2026, 10, 10, 12, 58),
        Prayer.ikindi: DateTime(2026, 10, 10, 16, 11),
        Prayer.aksam: DateTime(2026, 10, 10, 18, 48),
        Prayer.yatsi: DateTime(2026, 10, 10, 20, 7),
      },
    );

    final PrayerTimesDay tomorrow = PrayerTimesDay(
      date: tomorrowDate,
      source: 'diyanet',
      times: <Prayer, DateTime>{
        Prayer.imsak: DateTime(2026, 10, 11, 5, 35),
        Prayer.gunes: DateTime(2026, 10, 11, 7, 0),
        Prayer.ogle: DateTime(2026, 10, 11, 12, 58),
        Prayer.ikindi: DateTime(2026, 10, 11, 16, 10),
        Prayer.aksam: DateTime(2026, 10, 11, 18, 46),
        Prayer.yatsi: DateTime(2026, 10, 11, 20, 6),
      },
    );

    test('gün içinde aktif vakit, sıradaki vakit ve geri sayım tutarlıdır', () {
      final DateTime now = DateTime(2026, 10, 10, 14, 0);
      final PrayerScheduleSnapshot snap = PrayerScheduleSnapshot.resolve(
        day: today,
        tomorrow: tomorrow,
        now: now,
      );
      expect(snap.activeDay, same(today));
      expect(snap.currentPrayer, Prayer.ogle);
      expect(snap.nextPrayer?.prayer, Prayer.ikindi);
      expect(snap.remaining, const Duration(hours: 2, minutes: 11));
      expect(snap.isAfterIsha, isFalse);
      expect(snap.rolledOverToTomorrow, isFalse);
      expect(snap.progress, greaterThan(0.3));
      expect(snap.progress, lessThan(0.4));
    });

    test('yatsı sonrasında sıradaki vakit yarının imsakıdır', () {
      final DateTime now = DateTime(2026, 10, 10, 21, 35);
      final PrayerScheduleSnapshot snap = PrayerScheduleSnapshot.resolve(
        day: today,
        tomorrow: tomorrow,
        now: now,
      );
      expect(snap.currentPrayer, Prayer.yatsi);
      expect(snap.nextPrayer?.prayer, Prayer.imsak);
      expect(snap.nextPrayer?.time, DateTime(2026, 10, 11, 5, 35));
      expect(snap.remaining, const Duration(hours: 8));
      expect(snap.isAfterIsha, isTrue);
    });

    test(
      'gece yarısı geçildiğinde aktif gün otomatik olarak yarına devreder',
      () {
        final DateTime now = DateTime(2026, 10, 11, 0, 35);
        final PrayerScheduleSnapshot snap = PrayerScheduleSnapshot.resolve(
          day: today,
          tomorrow: tomorrow,
          now: now,
        );
        expect(snap.rolledOverToTomorrow, isTrue);
        expect(snap.activeDay, same(tomorrow));
        expect(snap.currentPrayer, Prayer.yatsi);
        expect(snap.nextPrayer?.prayer, Prayer.imsak);
        expect(snap.remaining, const Duration(hours: 5));
      },
    );

    test(
      'hesaplama yöntemi ve Hanefî ikindi değişimi vakitleri yeniler',
      () async {
        if (skipWithoutDatabase(databaseProblem)) return;
        final AppRuntime runtime = await createTestRuntime();
        addTearDown(runtime.dispose);

        const UserLocation loc = UserLocation(
          mode: LocationMode.gps,
          latitude: 41.0082,
          longitude: 28.9784,
        );

        final PrayerTimesDay standardDay = await runtime.prayerTimes.getDay(
          location: loc,
          date: dayDate,
          method: CalculationMethod.diyanet,
        );
        final PrayerTimesDay hanafiDay = await runtime.prayerTimes.getDay(
          location: loc,
          date: dayDate,
          method: CalculationMethod.diyanet.copyWith(asrFactor: 2),
        );
        expect(
          hanafiDay
              .timeOf(Prayer.ikindi)!
              .isAfter(standardDay.timeOf(Prayer.ikindi)!),
          isTrue,
          reason: 'Asr-ı sânî (Hanefî) ikindi vakti asr-ı evvelden daha geç olmalıdır',
        );
      },
    );
  });

  group('Dijital tesbih tutarlılığı ve kalıcılığı', () {
    test('oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime();
      addTearDown(runtime.dispose);

      final ProviderContainer container = ProviderContainer(
        overrides: [runtimeProvider.overrideWithValue(runtime)],
      );
      addTearDown(container.dispose);

      final ZikirCounterController controller = container.read(
        zikirCounterProvider.notifier,
      );

      // 1) 15 kez hızlı artış (çift sayım veya kayıp olmamalı):
      for (int i = 0; i < 15; i++) {
        await controller.increment();
      }
      expect(container.read(zikirCounterProvider).count, 15);

      // 2) Hedef değiştirildiğinde mevcut oturum sayacı sıfırlanmamalı:
      controller.setTarget(99);
      expect(container.read(zikirCounterProvider).target, 99);
      expect(
        container.read(zikirCounterProvider).count,
        15,
        reason: 'Hedef değişimi oturum sayacını sıfırlamamalı',
      );

      // 3) Başka zikre geçip geri dönüldüğünde önceki zikir sayacı korunmalı:
      controller.selectZikir('elhamdulillah', 33);
      await controller.increment();
      await controller.increment();
      expect(container.read(zikirCounterProvider).count, 2);

      controller.selectZikir('subhanallah', 33);
      expect(container.read(zikirCounterProvider).count, 15);
      expect(container.read(zikirCounterProvider).target, 99);

      // 4) Uygulama yeniden açıldığında (yeni ProviderContainer) oturum korunmalı:
      final ProviderContainer reopened = ProviderContainer(
        overrides: [runtimeProvider.overrideWithValue(runtime)],
      );
      addTearDown(reopened.dispose);
      final ZikirCounterState restored = reopened.read(zikirCounterProvider);
      expect(restored.zikirKey, 'subhanallah');
      expect(restored.count, 15);
      expect(restored.target, 99);

      // 5) Oturum sayacı sıfırlandığında günlük toplam (15 + 2 = 17) silinmemeli:
      await controller.reset();
      expect(container.read(zikirCounterProvider).count, 0);

      final ZikirDailySummary summary = await runtime.zikir.todaySummary(
        target: 100,
      );
      expect(summary.totalCount, 17);
      expect(summary.byZikir['subhanallah'], 15);
      expect(summary.byZikir['elhamdulillah'], 2);
      expect(summary.progress, closeTo(0.17, 0.001));
    });
  });

  group('Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon', () {
    test('geçersiz sensör verisi reddedilir', () {
      expect(
        CompassService.isValidSensorPayload(<Object?, Object?>{
          'heading': double.nan,
          'accuracy': 5.0,
        }),
        isFalse,
      );
      expect(
        CompassService.isValidSensorPayload(<Object?, Object?>{
          'heading': 120.0,
          'accuracy': -1.0,
        }),
        isFalse,
      );
      expect(
        CompassService.isValidSensorPayload(<Object?, Object?>{
          'heading': 145.0,
          'accuracy': 4.0,
          'tilt': 5.0,
          'roll': 2.0,
        }),
        isTrue,
      );
    });

    test('manyetik kuzey sapması gerçek kuzeye doğru eklenir', () {
      final double decl = GeoUtils.magneticDeclination(41.0082, 28.9784);
      expect(decl, greaterThan(4.5));
      expect(decl, lessThan(8.0));

      final double qibla = GeoUtils.qiblaBearing(41.0082, 28.9784);
      // Cihazın manyetik kuzeye göre açısı (qibla - decl) olduğunda gerçek kuzeye
      // göre tam kıbleye (sapma 0°) bakıyor olmalıdır:
      final CompassReading reading = CompassReading(
        heading: qibla - decl,
        magneticHeading: qibla - decl,
        accuracy: 3.0,
      ).withQibla(qibla, declination: decl);

      expect(reading.heading, closeTo(qibla, 0.01));
      expect(reading.differenceToQibla, closeTo(0.0, 0.01));
      expect(reading.isAligned, isTrue);
    });

    test('manyetik parazit ve telefon eğimi ayrı uyarılarla bildirilir', () {
      const CompassReading interference = CompassReading(
        heading: 150,
        accuracy: 5,
        fieldStrengthMicroTesla: 92.0,
      );
      expect(interference.hasMagneticInterference, isTrue);
      expect(interference.needsCalibration, isTrue);
      expect(interference.calibrationMessage, contains('Manyetik parazit'));

      const CompassReading tilted = CompassReading(
        heading: 150,
        accuracy: 5,
        tilt: 52.0,
      );
      expect(tilted.isTilted, isTrue);
      expect(tilted.needsCalibration, isTrue);
      expect(tilted.calibrationMessage, contains('eğik'));
    });
  });

  group('Gizlilik ve log temizliği', () {
    test('AppLog.sanitize koordinat, e-posta ve anahtarları maskeler', () {
      const String raw =
          'Kullanıcı ali.veli@ornek.com konum 41.0082, 28.9784 '
          'url ?latitude=41.00821&longitude=28.97842 Bearer secretToken12345';
      final String sanitized = AppLog.sanitize(raw);
      expect(sanitized, isNot(contains('ali.veli@ornek.com')));
      expect(sanitized, isNot(contains('41.0082')));
      expect(sanitized, isNot(contains('28.9784')));
      expect(sanitized, isNot(contains('secretToken12345')));
      expect(sanitized, contains('[e-posta-gizlendi]'));
      expect(sanitized, contains('[konum-gizlendi]'));
      expect(sanitized, contains('[anahtar-gizlendi]'));
    });
  });

  group('Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu', () {
    test('varsayılan ezan sesi Hicaz makamıdır ve vakit bazlı ses özelleştirmesi korunur', () {
      const NotificationSettings defaults = NotificationSettings();
      expect(defaults.adhanSound, AdhanSound.ezanMelodi);
      expect(BundledSounds.assetFor(AdhanSound.ezanMelodi), isNotNull);
      expect(BundledSounds.assetFor(AdhanSound.sabaMelodi), isNotNull);
      expect(BundledSounds.assetFor(AdhanSound.segahMelodi), isNotNull);
      expect(BundledSounds.assetFor(AdhanSound.tekbirMelodi), isNotNull);

      final NotificationSettings customized = defaults.copyWith(
        perPrayerSound: <Prayer, AdhanSound>{
          Prayer.imsak: AdhanSound.sabaMelodi,
          Prayer.ogle: AdhanSound.tone3,
          Prayer.yatsi: AdhanSound.ezanMelodi,
        },
        customAdhanPath: '/tmp/ozel_ezan.mp3',
        customAdhanTitle: 'Özel Ezan',
      );
      expect(customized.soundFor(Prayer.imsak), AdhanSound.sabaMelodi);
      expect(customized.soundFor(Prayer.ogle), AdhanSound.tone3);
      expect(customized.soundFor(Prayer.aksam), AdhanSound.ezanMelodi);

      final NotificationSettings restored = NotificationSettings.fromJson(
        customized.toJson(),
      );
      expect(restored.soundFor(Prayer.imsak), AdhanSound.sabaMelodi);
      expect(restored.soundFor(Prayer.ogle), AdhanSound.tone3);
      expect(restored.customAdhanPath, '/tmp/ozel_ezan.mp3');
      expect(restored.customAdhanTitle, 'Özel Ezan');
    });

    test('ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime();
      addTearDown(runtime.dispose);

      final List<IlahiTrack> tracks = await runtime.ilahi.catalog();
      expect(tracks.length, greaterThanOrEqualTo(10));
      expect(tracks.any((IlahiTrack t) => t.id == 'makam_hicaz_ezan'), isTrue);
      expect(tracks.any((IlahiTrack t) => t.id == 'ilahi_ussak_yunus'), isTrue);
      expect(
        tracks.any((IlahiTrack t) => t.id == 'tilavet_ayetel_kursi'),
        isTrue,
      );
      for (final IlahiTrack track in tracks) {
        expect(track.hasLicenseInfo, isTrue);
        expect(track.audioUrl, isNotEmpty);
      }
    });

    test('bildirim seslerinde çan ifadesi yer almaz; telifsiz ilahi ve ezan makamları kullanılır', () {
      for (final AdhanSound sound in AdhanSound.values) {
        expect(sound.label.toLowerCase(), isNot(contains('çan')));
        expect(sound.description.toLowerCase(), isNot(contains('çan')));
      }
      expect(AdhanSound.tone1.label, contains('İlahi'));
      expect(AdhanSound.tone2.label, contains('İlahi'));
      expect(AdhanSound.tone3.label, contains('İlahi'));
    });

    test('uygulama adı Ezan, dil desteği TR/EN/AR, meal seçimi, saat geri alma ve Esmaül Hüsna doğrulanır', () {
      expect(AppConstants.appName, 'Ezan');
      expect(AppStrings.supportedLanguages.length, 3);
      expect(const AppStrings('en').tabPrayers, 'Prayer Times');
      expect(const AppStrings('ar').tabPrayers, 'أوقات الصلاة');
      expect(Hadith.localizedTopic('Namaz', 'en'), 'Prayer (Salah)');
      expect(Hadith.localizedTopic('Namaz', 'ar'), 'الصلاة');
      expect(QuranTranslations.all.length, greaterThanOrEqualTo(5));
      expect(EsmaulHusnaScreen.names.length, 99);

      // Saat geri alındığında (ör. batıya seyahat) sıradaki vakit doğru hesaplanır
      final PrayerTimesDay loadedOnNextDay = PrayerTimesDay(
        date: DateTime(2026, 10, 11),
        source: 'diyanet',
        times: <Prayer, DateTime>{
          Prayer.imsak: DateTime(2026, 10, 11, 5, 35),
          Prayer.gunes: DateTime(2026, 10, 11, 7, 0),
          Prayer.ogle: DateTime(2026, 10, 11, 12, 57),
          Prayer.ikindi: DateTime(2026, 10, 11, 16, 5),
          Prayer.aksam: DateTime(2026, 10, 11, 18, 40),
          Prayer.yatsi: DateTime(2026, 10, 11, 19, 59),
        },
      );
      final PrayerScheduleSnapshot rolledBack = PrayerScheduleSnapshot.resolve(
        day: loadedOnNextDay,
        now: DateTime(2026, 10, 10, 15, 30),
      );
      expect(rolledBack.currentPrayer, Prayer.ogle);
      expect(rolledBack.nextPrayer?.prayer, Prayer.ikindi);
      expect(rolledBack.remaining, const Duration(minutes: 35));
    });
  });
}
