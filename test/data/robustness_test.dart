import 'package:ezanai/core/db/app_database.dart';
import 'package:ezanai/data/models/app_settings.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:ezanai/data/models/prayer_times_day.dart';
import 'package:ezanai/data/prayer/prayer_times_cache.dart';
import 'package:ezanai/design/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../support/test_runtime.dart';

/// "Bozuk veri uygulamayı kilitlemesin" kuralının testleri.
///
/// Eski sürümden kalan bir ayar/yedek dosyası ya da yarım yazılmış bir
/// önbellek satırı; uygulamanın açılışını veya vakit ekranını **düşürmemeli**.
void main() {
  initTestDatabaseFactory();

  group('ayarlar bozuk veriye dayanıklı', () {
    test('yanlış türdeki alanlar varsayılana düşer', () {
      final AppSettings settings = AppSettings.fromPrefs(<String, Object?>{
        'themeMode': 42,
        'localeCode': false,
        'calculationMethodId': <String>['diyanet'],
        'asrHanafi': 'evet',
        'use24Hour': null,
        'manualOffsets': 'bozuk',
        'notifications': 'bozuk',
        'quranFontSize': 'büyük',
      });
      expect(settings.localeCode, 'tr');
      expect(settings.calculationMethodId, 'diyanet');
      expect(settings.asrHanafi, isFalse);
      expect(settings.use24Hour, isTrue);
      expect(settings.manualOffsets, isEmpty);
      expect(settings.quranFontSize, 28);
      expect(settings.notifications.enabled, isTrue);
    });

    test('bozuk bildirim ayarları açılışı düşürmez', () {
      final NotificationSettings notifications = NotificationSettings.fromJson(
        <String, Object?>{
          'enabled': 'hayır',
          'prayerEnabled': 'hepsi',
          'perPrayerSound': 5,
          'adhanSound': 3,
          'customAdhanPath': <int>[1],
          'adhanVolume': 'yüksek',
          'preReminderMinutes': '10',
        },
      );
      expect(notifications.enabled, isTrue);
      expect(notifications.prayerEnabled[Prayer.imsak], isTrue);
      expect(notifications.prayerEnabled[Prayer.gunes], isFalse);
      expect(notifications.adhanSound, AdhanSound.ezanMelodi);
      expect(notifications.customAdhanPath, isNull);
      expect(notifications.adhanVolume, 0.85);
      expect(notifications.preReminderMinutes, 0);
    });

    test('yarım kalmış JSON varsayılanlara döner', () {
      final AppSettings settings = AppSettings.importJson('{"themeMode":');
      expect(settings.localeCode, 'tr');
    });

    test('geçerli kısmi yedek okunur', () {
      final AppSettings? settings = AppSettings.tryImportJson(
        '{"themeMode":"dark","quranFontSize":32}',
      );
      expect(settings, isNotNull);
      expect(settings!.themeMode, AppThemeMode.dark);
      expect(settings.quranFontSize, 32);
      // Verilmeyen alanlar varsayılan kalır.
      expect(settings.localeCode, 'tr');
    });

    test('alakasız JSON yedek sayılmaz (ayarlar silinmez)', () {
      expect(AppSettings.tryImportJson('{"foo":1}'), isNull);
      expect(AppSettings.tryImportJson('[1,2,3]'), isNull);
      expect(AppSettings.tryImportJson('merhaba'), isNull);
    });
  });

  group('vakit önbelleği bozuk satıra dayanıklı', () {
    late AppDatabase database;
    late PrayerTimesCache cache;
    String? databaseProblem;

    setUpAll(() async {
      databaseProblem = await probeDatabase();
    });

    void cacheTest(String description, Future<void> Function() body) {
      test(description, () async {
        if (skipWithoutDatabase(databaseProblem)) return;
        await body();
      });
    }

    setUp(() async {
      if (databaseProblem != null) return;
      database = await AppDatabase.open(
        path: inMemoryDatabasePath,
        factory: testDatabaseFactory,
      );
      cache = PrayerTimesCache(database);
    });

    tearDown(() async {
      if (databaseProblem != null) return;
      await database.close();
    });

    cacheTest('geçerli satır okunur', () async {
      final DateTime date = DateTime(2026, 11, 10);
      await cache.save(
        'district:9541',
        PrayerTimesDay(
          date: date,
          times: <Prayer, DateTime>{
            Prayer.imsak: DateTime(2026, 11, 10, 6, 11),
            Prayer.gunes: DateTime(2026, 11, 10, 7, 38),
            Prayer.ogle: DateTime(2026, 11, 10, 12, 53),
            Prayer.ikindi: DateTime(2026, 11, 10, 15, 33),
            Prayer.aksam: DateTime(2026, 11, 10, 17, 58),
            Prayer.yatsi: DateTime(2026, 11, 10, 19, 20),
          },
          source: 'diyanet',
        ),
      );
      final List<PrayerTimesDay> days = await cache.getRange(
        'district:9541',
        date,
        date,
      );
      expect(days, hasLength(1));
      expect(days.first.times[Prayer.ikindi]!.hour, 15);
      expect(days.first.times[Prayer.ikindi]!.minute, 33);
    });

    cacheTest('bozuk satır atlanır, sağlam satır korunur', () async {
      final DateTime goodDate = DateTime(2026, 11, 10);
      await cache.save(
        'district:9541',
        PrayerTimesDay(
          date: goodDate,
          times: <Prayer, DateTime>{
            Prayer.imsak: DateTime(2026, 11, 10, 6, 11),
            Prayer.gunes: DateTime(2026, 11, 10, 7, 38),
            Prayer.ogle: DateTime(2026, 11, 10, 12, 53),
            Prayer.ikindi: DateTime(2026, 11, 10, 15, 33),
            Prayer.aksam: DateTime(2026, 11, 10, 17, 58),
            Prayer.yatsi: DateTime(2026, 11, 10, 19, 20),
          },
          source: 'diyanet',
        ),
      );
      // Aynı aralıkta, okunamayan saatli satır (eski/bozuk şema).
      await database.raw.insert('prayer_times_cache', <String, Object?>{
        'district_id': 'district:9541',
        'date': '2026-11-11',
        'imsak': 'xx:yy',
        'gunes': '07:39',
        'ogle': '12:54',
        'ikindi': '15:34',
        'aksam': '17:59',
        'yatsi': '19:21',
        'source': 'diyanet',
        'hijri': null,
        'fetched_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final List<PrayerTimesDay> days = await cache.getRange(
        'district:9541',
        DateTime(2026, 11, 10),
        DateTime(2026, 11, 12),
      );
      // Bozuk satır sessizce atlanır; uygulama çökmez.
      expect(days, hasLength(1));
      expect(days.single.date.day, 10);
    });

    cacheTest('tek satır okuması bozuk kayıtta null döner', () async {
      await database.raw.insert('prayer_times_cache', <String, Object?>{
        'district_id': 'district:9543',
        'date': '2026-11-12',
        'imsak': 'xx:yy',
        'gunes': '07:39',
        'ogle': '12:54',
        'ikindi': '15:34',
        'aksam': '17:59',
        'yatsi': '19:21',
        'source': 'diyanet',
        'hijri': null,
        'fetched_at': DateTime.now().millisecondsSinceEpoch,
      });
      final PrayerTimesDay? day = await cache.get(
        'district:9543',
        DateTime(2026, 11, 12),
      );
      expect(day, isNull);
    });
  });
}
