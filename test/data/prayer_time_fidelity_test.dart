import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezanai/core/db/app_database.dart';
import 'package:ezanai/core/services/connectivity_service.dart';
import 'package:ezanai/data/models/city.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:ezanai/data/models/prayer_times_day.dart';
import 'package:ezanai/data/prayer/aladhan_api_source.dart';
import 'package:ezanai/data/prayer/local_calculation_source.dart';
import 'package:ezanai/data/prayer/prayer_calculator.dart';
import 'package:ezanai/data/prayer/prayer_times_cache.dart';
import 'package:ezanai/data/prayer/prayer_times_repository.dart';
import 'package:ezanai/data/prayer/prayer_times_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../support/test_runtime.dart';

/// **Vakit sadakati — "ezan 1 dakika erken çalıyor" hatasının regresyon testi.**
///
/// Kullanıcı bildirimi: "Yatsı ve diğer namaz vakitlerinde 1 dk erken ezan
/// vakti oluşuyor, Diyanet veritabanı güncelleme diyor."
///
/// Tespit edilen kök nedenler ve bu dosyadaki karşılıkları:
///
/// | # | Hata | Test |
/// |---|---|---|
/// | V1 | Yedek servis (AlAdhan) Diyanet temkinini uygulamıyordu → akşam 7, öğle 5, ikindi 4, yatsı 1 dk erken | `AlAdhan ... temkin` |
/// | V2 | Hanefî ikindi seçilince resmî Diyanet verisi bırakılıp AlAdhan'a düşülüyordu | `Hanefî ... resmî veri` |
/// | V3 | Manuel dakika düzeltmesi önbellekten okurken iki kez uygulanıyordu | `manuel düzeltme ... iki kez` |
/// | V4 | Günlük ekran ile haftalık tablo/bildirim farklı dakika üretebiliyordu | `gün ve aralık aynı` |
/// | V5 | Aralık önbelleği tazelik denetimi yapmıyordu → bildirim eski saate kuruluyordu | `bayat aralık önbelleği` |
/// | V6 | Yerel hesapta temkin yanlıydı (yatsı +1 dk, akşam +8 dk) | `temkin ... yansız` |
/// | V7 | Dünya şehirlerinde saat dilimi yok sayılıp +3 varsayılıyordu | `Kâbil ... +4,5` |
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  initTestDatabaseFactory();

  // Referans nokta: doğrulama örneklemindeki İstanbul kaydı (Bağcılar/İstanbul
  // aynı saat diliminde ve 1 dakikadan az farkla aynı vakitleri verir).
  const City bagcilar = City(
    id: '20585',
    name: 'Bağcılar',
    latitude: 41.01321,
    longitude: 28.94868,
    province: 'İstanbul',
  );

  const UserLocation bagcilarLocation = UserLocation(
    mode: LocationMode.manual,
    latitude: 41.01321,
    longitude: 28.94868,
    city: bagcilar,
  );

  const City kabul = City(
    id: '9972',
    name: 'Kâbil',
    latitude: 34.52813,
    longitude: 69.17233,
    country: 'Afganistan',
    isTurkish: false,
  );

  // Diyanet'in resmî yayımladığı gün (doğrulama örnekleminden).
  final DateTime day = DateTime(2022, 9, 23);
  late AppDatabase database;
  late PrayerTimesCache cache;
  String? databaseProblem;

  setUpAll(() async {
    databaseProblem = await probeDatabase();
  });

  /// Veritabanı yoksa testi atlar (atlama özet satırında görünür).
  void dbTest(String description, Future<void> Function() body) {
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

  // ---------------------------------------------------------------- V1 / V6
  group('V1+V6 — Diyanet ile dakika farkı', () {
    /// Resmî doğrulama örnekleri (11 il × 5 tarih, Diyanet).
    Future<List<Map<String, Object?>>> loadSamples() async {
      String raw;
      try {
        raw = await rootBundle.loadString(
          'assets/data/diyanet_validation_sample.json',
        );
      } catch (_) {
        // Paket varlıkları okunamazsa depodaki dosya kullanılır.
        raw = File('assets/data/diyanet_validation_sample.json')
            .readAsStringSync();
      }
      final Object? decoded = jsonDecode(raw);
      final Object? records = (decoded! as Map)['records'];
      return <Map<String, Object?>>[
        for (final Object? item in records! as List)
          (item! as Map).cast<String, Object?>(),
      ];
    }

    test(
      'yerel hesap Diyanet ile **yansız** (±0,5 dk ortalama) eşleşir',
      () async {
        final List<Map<String, Object?>> records = await loadSamples();
        expect(records, isNotEmpty);

        final Map<String, List<double>> errors = <String, List<double>>{
          for (final String key in <String>[
            'imsak',
            'gunes',
            'ogle',
            'ikindi',
            'aksam',
            'yatsi',
          ])
            key: <double>[],
        };

        for (final Map<String, Object?> record in records) {
          final DateTime date = DateTime.parse(record['date']! as String);
          final CalculatedTimes times = PrayerCalculator.calculate(
            date: date,
            latitude: (record['lat']! as num).toDouble(),
            longitude: (record['lon']! as num).toDouble(),
            method: CalculationMethod.diyanet,
            timeZoneOffsetHours: (record['tz'] as num?)?.toDouble() ?? 3.0,
          );
          final Map<String, double> computed = <String, double>{
            'imsak': times.imsak,
            'gunes': times.gunes,
            'ogle': times.ogle,
            'ikindi': times.ikindi,
            'aksam': times.aksam,
            'yatsi': times.yatsi,
          };
          for (final MapEntry<String, double> entry in computed.entries) {
            final List<String> parts = (record[entry.key]! as String).split(
              ':',
            );
            final double official =
                int.parse(parts[0]) + int.parse(parts[1]) / 60.0;
            errors[entry.key]!.add((entry.value - official) * 60);
          }
        }

        for (final MapEntry<String, List<double>> entry in errors.entries) {
          final List<double> values = entry.value;
          final double mean =
              values.reduce((double a, double b) => a + b) / values.length;
          final double worst = values
              .map((double v) => v.abs())
              .reduce((double a, double b) => a > b ? a : b);
          final int early2 = values.where((double v) => v < -2.0).length;

          expect(
            mean.abs(),
            lessThan(0.5),
            reason:
                '${entry.key}: ortalama sapma ${mean.toStringAsFixed(2)} dk — '
                'sistematik olarak erken/geç gösteriyor',
          );
          expect(
            worst,
            lessThan(3.0),
            reason:
                '${entry.key}: en kötü sapma ${worst.toStringAsFixed(2)} dk',
          );
          expect(
            early2 / values.length,
            lessThan(0.05),
            reason:
                '${entry.key}: $early2 örnekte 2 dakikadan fazla erken '
                '(toplam ${values.length})',
          );
        }
      },
    );

    test('temkin: akşam/yatsı düzeltmeleri Diyanet ile aynı (V6)', () {
      const Temkin temkin = Temkin.diyanet;
      expect(temkin.aksam, 7);
      expect(temkin.yatsi, 0);
      expect(temkin.gunes, -7);
      // Öğle ve ikindi Diyanet'in temkin uyguladığı yön: ileri.
      expect(temkin.ogle, greaterThanOrEqualTo(0));
      expect(temkin.ikindi, greaterThanOrEqualTo(0));
    });

    test('AlAdhan yanıtına yöntemin temkin düzeltmesi uygulanır (V1)', () async {
      // AlAdhan'ın Diyanet (13) için döndürdüğü **ham** değerler:
      // akşam 19:33 iken Diyanet 19:41 gösterir (temkin +8 → yeni tabloda +7).
      final http.Response response = http.Response(
        jsonEncode(<String, Object?>{
          'code': 200,
          'data': <String, Object?>{
            'timings': <String, String>{
              'Fajr': '05:12',
              'Sunrise': '06:41',
              'Dhuhr': '13:00',
              'Asr': '16:24',
              'Maghrib': '19:34',
              'Isha': '21:09',
            },
            'date': <String, Object?>{
              'hijri': <String, Object?>{
                'day': '15',
                'month': <String, Object?>{'en': 'Rabi al-Awwal'},
                'year': '1448',
              },
            },
          },
        }),
        200,
      );
      final AladhanApiSource source = AladhanApiSource(
        client: _StubHttpClient((http.BaseRequest request) => response),
      );
      final PrayerTimesDay result = await source.fetchDay(
        location: bagcilarLocation,
        date: day,
        method: CalculationMethod.diyanet,
      );

      DateTime at(int hour, int minute) =>
          DateTime(day.year, day.month, day.day, hour, minute);

      // Diyanet temkin: güneş −7, öğle +5, ikindi +4, akşam +7, yatsı 0.
      expect(result.timeOf(Prayer.gunes), at(6, 34));
      expect(result.timeOf(Prayer.ogle), at(13, 5));
      expect(result.timeOf(Prayer.ikindi), at(16, 28));
      expect(result.timeOf(Prayer.aksam), at(19, 41));
      expect(result.timeOf(Prayer.yatsi), at(21, 9));
    });

    test('temkinsiz yöntem (MWL) AlAdhan ham değerini korur', () async {
      final http.Response response = http.Response(
        jsonEncode(<String, Object?>{
          'data': <String, Object?>{
            'timings': <String, String>{
              'Fajr': '05:12',
              'Sunrise': '06:41',
              'Dhuhr': '13:00',
              'Asr': '16:24',
              'Maghrib': '19:34',
              'Isha': '21:09',
            },
          },
        }),
        200,
      );
      final AladhanApiSource source = AladhanApiSource(
        client: _StubHttpClient((http.BaseRequest request) => response),
      );
      final PrayerTimesDay result = await source.fetchDay(
        location: bagcilarLocation,
        date: day,
        method: CalculationMethod.mwl,
      );
      expect(
        result.timeOf(Prayer.aksam),
        DateTime(day.year, day.month, day.day, 19, 34),
      );
    });
  });

  // ---------------------------------------------------------------- V2 / V3
  group('V2+V3 — resmî veri ve kullanıcı düzeltmeleri', () {
    PrayerTimesRepository build({
      PrayerTimesSource? diyanet,
      PrayerTimesSource? aladhan,
    }) => PrayerTimesRepository(
      cache: cache,
      connectivity: _FixedConnectivity(true),
      diyanet: diyanet ?? _StubSource.failing('diyanet'),
      aladhan: aladhan ?? _StubSource.failing('aladhan'),
    );

    dbTest(
      'Hanefî ikindi seçilse de resmî Diyanet verisi kullanılır (V2)',
      () async {
        final _StubSource diyanet = _StubSource.success(
          'diyanet',
          _officialDay(day),
        );
        final _StubSource aladhan = _StubSource.success(
          'aladhan',
          _officialDay(day, source: 'aladhan'),
        );
        final PrayerTimesRepository repository = build(
          diyanet: diyanet,
          aladhan: aladhan,
        );

        final PrayerTimesDay evvel = await repository.getDay(
          location: bagcilarLocation,
          date: day,
          method: CalculationMethod.diyanet,
        );
        final PrayerTimesDay sani = await repository.getDay(
          location: bagcilarLocation,
          date: day,
          method: CalculationMethod.diyanet.copyWith(asrFactor: 2),
        );

        expect(sani.source, 'diyanet', reason: 'Yedek servise düşmemeli');
        expect(aladhan.dayCalls, 0, reason: 'AlAdhan hiç çağrılmamalı');

        // Diğer vakitler resmî değerle **birebir** aynı kalmalı.
        for (final Prayer prayer in <Prayer>[
          Prayer.imsak,
          Prayer.gunes,
          Prayer.ogle,
          Prayer.aksam,
          Prayer.yatsi,
        ]) {
          expect(
            sani.timeOf(prayer),
            evvel.timeOf(prayer),
            reason: '${prayer.label} değişmemeli',
          );
        }

        // Hanefî ikindi 40–90 dk daha geç olmalı.
        final int shiftMinutes = sani
            .timeOf(Prayer.ikindi)!
            .difference(evvel.timeOf(Prayer.ikindi)!)
            .inMinutes;
        final double expected = PrayerCalculator.asrShiftMinutes(
          date: day,
          latitude: bagcilarLocation.latitude,
          longitude: bagcilarLocation.longitude,
          method: CalculationMethod.diyanet,
        );
        expect(shiftMinutes, inInclusiveRange(40, 90));
        expect(shiftMinutes, closeTo(expected.round(), 1));
      },
    );

    dbTest(
      'önbellekten okunan resmî veriye de Hanefî kaydırma uygulanır (V8)',
      () async {
        // **Düzeltilen hata:** SQLite'tan okunan kayıt `source: 'cache'` olarak
        // işaretlendiği için "resmî veri" sayılmıyor, Hanefî ikindi kaydırması
        // atlanıyordu. Sonuç: ilk açılışta 16:26, uygulama yeniden açılınca
        // 15:46. Artık kaynak aslı korunuyor.
        final CalculationMethod hanefi = CalculationMethod.diyanet.copyWith(
          asrFactor: 2,
        );

        // 1) Çevrimiçi: resmî veri çekilir ve önbelleğe yazılır.
        final PrayerTimesRepository online = PrayerTimesRepository(
          cache: cache,
          connectivity: _FixedConnectivity(true),
          diyanet: _StubSource.success('diyanet', _officialDay(day)),
          aladhan: _StubSource.failing('aladhan'),
        );
        final PrayerTimesDay fresh = await online.getDay(
          location: bagcilarLocation,
          date: day,
          method: hanefi,
        );
        expect(fresh.source, 'diyanet');
        final int freshShift = fresh
            .timeOf(Prayer.ikindi)!
            .difference(_officialDay(day).timeOf(Prayer.ikindi)!)
            .inMinutes;
        expect(freshShift, inInclusiveRange(40, 90));

        // 2) Uygulama yeniden açıldı, internet yok: önbellekten okunur ve
        //    **aynı** dakikayı vermeli.
        final PrayerTimesRepository offline = PrayerTimesRepository(
          cache: cache,
          connectivity: _FixedConnectivity(false),
          diyanet: _StubSource.failing('diyanet'),
          aladhan: _StubSource.failing('aladhan'),
        );
        final PrayerTimesDay cached = await offline.getDay(
          location: bagcilarLocation,
          date: day,
          method: hanefi,
        );
        expect(cached.source, 'cache');
        expect(
          cached.timeOf(Prayer.ikindi),
          fresh.timeOf(Prayer.ikindi),
          reason: 'Önbellek Hanefî kaydırmayı korumalı',
        );
        expect(
          cached.timeOf(Prayer.aksam),
          _officialDay(day).timeOf(Prayer.aksam),
          reason: 'Diğer vakitler resmî kalmalı',
        );
      },
    );

    dbTest(
      'manuel düzeltme önbellekten okurken iki kez uygulanmaz (V3)',
      () async {
        final PrayerTimesRepository repository = build(
          diyanet: _StubSource.success('diyanet', _officialDay(day)),
        );
        final CalculationMethod shifted = CalculationMethod.diyanet.copyWith(
          manualOffsets: <String, int>{'yatsi': 3, 'imsak': -2},
        );

        final PrayerTimesDay first = await repository.getDay(
          location: bagcilarLocation,
          date: day,
          method: shifted,
        );
        expect(
          first.timeOf(Prayer.yatsi),
          _officialDay(day)
              .timeOf(Prayer.yatsi)!
              .add(const Duration(minutes: 3)),
        );

        // Aynı repository ikinci kez okur (bellek önbelleği) ve yeni bir
        // repository önbellekten (SQLite) okur: ikisi de +3 olmalı, +6 değil.
        final PrayerTimesDay second = await repository.getDay(
          location: bagcilarLocation,
          date: day,
          method: shifted,
        );
        expect(second.timeOf(Prayer.yatsi), first.timeOf(Prayer.yatsi));

        final PrayerTimesRepository fresh = build(
          diyanet: _StubSource.success('diyanet', _officialDay(day)),
        );
        final PrayerTimesDay fromCache = await fresh.getDay(
          location: bagcilarLocation,
          date: day,
          method: shifted,
        );
        expect(fromCache.source, 'cache');
        expect(
          fromCache.timeOf(Prayer.yatsi),
          first.timeOf(Prayer.yatsi),
          reason: 'Önbellekten okurken düzeltme yeniden eklenmemeli',
        );
      },
    );

    dbTest('düzeltmeli yöntem ayrı önbellek anahtarı kullanır (V3)', () async {
      final PrayerTimesRepository repository = build(
        diyanet: _StubSource.success('diyanet', _officialDay(day)),
      );
      await repository.getDay(
        location: bagcilarLocation,
        date: day,
        method: CalculationMethod.diyanet.copyWith(
          manualOffsets: <String, int>{'yatsi': 5},
        ),
      );

      // Varsayılan anahtar boş kalmalı: düzeltilmiş kayıt sızmamalı.
      expect(
        await cache.get('district:20585', day),
        isNull,
        reason: 'Düzeltilmiş veri varsayılan anahtara yazılmamalı',
      );

      // Hiçbir kaynak yokken yerel hesap resmî saatten ±2 dk içinde kalır.
      final PrayerTimesRepository clean = build(
        diyanet: _StubSource.failing('diyanet'),
      );
      final PrayerTimesDay day0 = await clean.getDay(
        location: bagcilarLocation,
        date: day,
        method: CalculationMethod.diyanet,
      );
      expect(day0.source, 'calculation');
      // +5 dk'lık düzeltme sızmamalı; cihaz hesabı resmî saate ±2 dk içinde.
      final int diff = day0
          .timeOf(Prayer.yatsi)!
          .difference(_officialDay(day).timeOf(Prayer.yatsi)!)
          .inMinutes
          .abs();
      expect(diff, lessThanOrEqualTo(2));
    });
  });

  // --------------------------------------------------------------------- V4
  group('V4 — bugünkü ekran ile haftalık tablo/bildirim aynı dakika', () {
    dbTest('gün ve aralık aynı vakitleri döndürür', () async {
      final _StubSource diyanet = _StubSource.success(
        'diyanet',
        _officialDay(day),
        range: <PrayerTimesDay>[
          _officialDay(day),
          _officialDay(day.add(const Duration(days: 1))),
        ],
      );
      final PrayerTimesRepository repository = PrayerTimesRepository(
        cache: cache,
        connectivity: _FixedConnectivity(true),
        diyanet: diyanet,
        aladhan: _StubSource.failing('aladhan'),
      );

      final PrayerTimesDay single = await repository.getDay(
        location: bagcilarLocation,
        date: day,
        method: CalculationMethod.diyanet,
      );
      final List<PrayerTimesDay> range = await repository.getRange(
        location: bagcilarLocation,
        startDate: day,
        endDate: day.add(const Duration(days: 1)),
        method: CalculationMethod.diyanet,
      );

      expect(range, isNotEmpty);
      for (final Prayer prayer in Prayer.values) {
        expect(
          range.first.timeOf(prayer),
          single.timeOf(prayer),
          reason: '${prayer.label}: tablo ile ana ekran aynı olmalı',
        );
      }
    });
  });

  // --------------------------------------------------------------------- V5
  group('V5 — bayat aralık önbelleği yenilenir', () {
    dbTest('7 saatlik önbellek yeniden çekilir', () async {
      final DateTime stale = DateTime.now().subtract(const Duration(hours: 7));
      await cache.saveMany('district:20585', <PrayerTimesDay>[
        _officialDay(day, cachedAt: stale),
      ]);

      final _StubSource diyanet = _StubSource.success(
        'diyanet',
        _officialDay(day),
        range: <PrayerTimesDay>[_officialDay(day)],
      );
      final PrayerTimesRepository repository = PrayerTimesRepository(
        cache: cache,
        connectivity: _FixedConnectivity(true),
        diyanet: diyanet,
        aladhan: _StubSource.failing('aladhan'),
      );

      final List<PrayerTimesDay> range = await repository.getRange(
        location: bagcilarLocation,
        startDate: day,
        endDate: day,
        method: CalculationMethod.diyanet,
      );
      expect(
        diyanet.rangeCalls,
        1,
        reason: 'Bayat aralık önbelleği kullanılmamalı',
      );
      expect(range, isNotEmpty);
    });
  });

  // --------------------------------------------------------------------- V7
  group('V7 — dünya şehri saat dilimi', () {
    test('Kâbil çevrimdışı hesapta +4,5 saat dilimini kullanır', () async {
      const LocalCalculationSource local = LocalCalculationSource();
      final PrayerTimesDay result = await local.fetchDay(
        location: const UserLocation(
          mode: LocationMode.manual,
          latitude: 34.52813,
          longitude: 69.17233,
          city: kabul,
        ),
        date: day,
        method: CalculationMethod.diyanet,
      );
      // Boylam 69,17° → 69,17 / 15 = 4,61 → 30 dakikaya yuvarlanınca +4,5.
      final CalculatedTimes reference = PrayerCalculator.calculate(
        date: day,
        latitude: 34.52813,
        longitude: 69.17233,
        method: CalculationMethod.diyanet,
        timeZoneOffsetHours: 4.5,
      );
      final int expectedMinutes = (reference.ogle * 60).round() % (24 * 60);
      final DateTime? ogle = result.timeOf(Prayer.ogle);
      expect(ogle, isNotNull);
      expect(
        ogle!.hour * 60 + ogle.minute,
        closeTo(expectedMinutes, 1),
        reason: 'Kâbil öğle vakti +4,5 dilimine göre hesaplanmalı',
      );
    });

    test('Türkiye ilçesi her zaman UTC+3 kullanır', () async {
      const LocalCalculationSource local = LocalCalculationSource();
      final PrayerTimesDay result = await local.fetchDay(
        location: bagcilarLocation,
        date: day,
        method: CalculationMethod.diyanet,
      );
      final CalculatedTimes reference = PrayerCalculator.calculate(
        date: day,
        latitude: bagcilarLocation.latitude,
        longitude: bagcilarLocation.longitude,
        method: CalculationMethod.diyanet,
      );
      final DateTime? ogle = result.timeOf(Prayer.ogle);
      expect(
        ogle!.hour * 60 + ogle.minute,
        closeTo((reference.ogle * 60).round() % (24 * 60), 1),
      );
    });
  });

  // ------------------------------------------------------------------ etiket
  group('Kaynak etiketi — "güncelleme" ifadesi netleşti', () {
    test('kaynak ve tazelik ayrı ayrı okunur', () {
      final PrayerTimesDay diyanet = _officialDay(
        day,
        cachedAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(diyanet.sourceLabel, 'Diyanet resmî verisi');
      expect(diyanet.freshnessLabel(), '3 saat önce alındı');
      expect(diyanet.displaySource, contains('Diyanet resmî verisi'));
      expect(diyanet.displaySource, contains('3 saat önce alındı'));
      expect(diyanet.displaySource, isNot(contains('güncelleme')));
    });

    test('cihaz hesabı ve yedek servis ayrı etiketlenir', () {
      expect(
        _officialDay(day, source: 'calculation').sourceLabel,
        contains('Cihazda hesaplandı'),
      );
      expect(
        _officialDay(day, source: 'aladhan').sourceLabel,
        contains('Yedek servis'),
      );
    });
  });
}

/// Diyanet'in resmî İstanbul vakitleri (23 Eylül 2022) — doğrulama
/// örnekleminden birebir alınmıştır.
PrayerTimesDay _officialDay(
  DateTime date, {
  String source = 'diyanet',
  DateTime? cachedAt,
}) {
  final DateTime base = DateTime(date.year, date.month, date.day);
  return PrayerTimesDay(
    date: base,
    times: <Prayer, DateTime>{
      Prayer.imsak: base.add(const Duration(hours: 5, minutes: 20)),
      Prayer.gunes: base.add(const Duration(hours: 6, minutes: 45)),
      Prayer.ogle: base.add(const Duration(hours: 13, minutes: 2)),
      Prayer.ikindi: base.add(const Duration(hours: 16, minutes: 26)),
      Prayer.aksam: base.add(const Duration(hours: 19, minutes: 8)),
      Prayer.yatsi: base.add(const Duration(hours: 20, minutes: 28)),
    },
    source: source,
    cachedAt: cachedAt ?? DateTime.now(),
  );
}

class _FixedConnectivity extends ConnectivityService {
  _FixedConnectivity(this.online) : super(Connectivity());

  final bool online;

  @override
  bool get isOnline => online;
}

class _StubSource implements PrayerTimesSource {
  _StubSource.success(
    this.id,
    this.day, {
    this.range = const <PrayerTimesDay>[],
  }) : failure = null;

  _StubSource.failing(this.id)
    : day = null,
      failure = 'test: kaynak kullanılamıyor',
      range = const <PrayerTimesDay>[];

  @override
  final String id;

  final PrayerTimesDay? day;
  final String? failure;
  final List<PrayerTimesDay> range;

  int dayCalls = 0;
  int rangeCalls = 0;

  @override
  String get label => id;

  @override
  String get description => 'test kaynağı';

  @override
  bool get requiresNetwork => true;

  @override
  Future<PrayerTimesDay> fetchDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
  }) async {
    dayCalls++;
    final String? message = failure;
    if (message != null) throw PrayerTimesSourceException(id, message);
    return day!;
  }

  @override
  Future<List<PrayerTimesDay>> fetchRange({
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
  }) async {
    rangeCalls++;
    final String? message = failure;
    if (message != null) throw PrayerTimesSourceException(id, message);
    return range;
  }
}

class _StubHttpClient extends http.BaseClient {
  _StubHttpClient(this.responder);

  final http.Response Function(http.BaseRequest request) responder;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final http.Response response = responder(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}
