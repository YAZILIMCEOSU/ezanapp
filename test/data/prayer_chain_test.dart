import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezanai/core/db/app_database.dart';
import 'package:ezanai/core/services/connectivity_service.dart';
import 'package:ezanai/data/models/city.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:ezanai/data/models/prayer_times_day.dart';
import 'package:ezanai/data/prayer/aladhan_api_source.dart';
import 'package:ezanai/data/prayer/diyanet_api_source.dart';
import 'package:ezanai/data/prayer/local_calculation_source.dart';
import 'package:ezanai/data/prayer/prayer_calculator.dart';
import 'package:ezanai/data/prayer/prayer_times_cache.dart';
import 'package:ezanai/data/prayer/prayer_times_repository.dart';
import 'package:ezanai/data/prayer/prayer_times_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Vakit kaynak zincirinin (önbellek → Diyanet → AlAdhan → yerel hesap)
/// bütün dallarını sınar.
///
/// Faz kapısı: "API çökerse uygulama kullanılamaz hâle gelmesin" kuralının
/// kanıtı. Gerçek repository + gerçek kaynaklar; ağ yerine sahte HTTP
/// istemcisi, veritabanı yerine bellek içi SQLite kullanılır.
void main() {
  initTestDatabaseFactory();

  late AppDatabase database;
  late PrayerTimesCache cache;
  String? databaseProblem;

  const City istanbul = City(
    id: '1741',
    name: 'İstanbul',
    latitude: 41.0082,
    longitude: 28.9784,
    province: 'İstanbul',
  );

  const UserLocation cityLocation = UserLocation(
    mode: LocationMode.manual,
    latitude: 41.0082,
    longitude: 28.9784,
    city: istanbul,
  );

  const UserLocation gpsLocation = UserLocation(
    mode: LocationMode.gps,
    latitude: 41.0082,
    longitude: 28.9784,
  );

  final DateTime today = DateTime(2026, 10, 5);

  setUpAll(() async {
    databaseProblem = await probeDatabase();
  });

  /// Veritabanı yoksa testi atlar (atlama özet satırında görünür).
  void chainTest(String description, Future<void> Function() body) {
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

  PrayerTimesRepository buildRepository({
    required bool online,
    PrayerTimesSource? diyanet,
    PrayerTimesSource? aladhan,
  }) => PrayerTimesRepository(
    cache: cache,
    connectivity: _FixedConnectivity(online),
    diyanet: diyanet ?? _StubSource.failing('diyanet'),
    aladhan: aladhan ?? _StubSource.failing('aladhan'),
  );

  group('zincir sırası', () {
    chainTest('Diyanet resmî verisi ilk sırada kullanılır ve önbelleğe yazılır', () async {
      final _StubSource diyanet = _StubSource.success(
        'diyanet',
        saneDay(today),
      );
      final _StubSource aladhan = _StubSource.success('aladhan', saneDay(today));
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
        aladhan: aladhan,
      );

      final PrayerTimesDay day = await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'diyanet');
      expect(day.isSane, isTrue);
      expect(diyanet.dayCalls, 1);
      expect(aladhan.dayCalls, 0, reason: 'Diyanet başarılıysa AlAdhan denenmez');
      expect(repository.lastWarning, isNull);

      final PrayerTimesDay? cached = await cache.get('district:1741', today);
      expect(cached, isNotNull, reason: 'Resmî veri önbelleğe yazılmalı');
      expect(cached!.timeOf(Prayer.imsak), day.timeOf(Prayer.imsak));
    });

    chainTest('Diyanet başarısızsa AlAdhan devreye girer', () async {
      final _StubSource diyanet = _StubSource.failing('diyanet');
      final _StubSource aladhan = _StubSource.success(
        'aladhan',
        saneDay(today, source: 'aladhan'),
      );
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
        aladhan: aladhan,
      );

      final PrayerTimesDay day = await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'aladhan');
      expect(diyanet.dayCalls, 1);
      expect(aladhan.dayCalls, 1);
    });

    chainTest('her iki servis de çökerse yerel hesap devreye girer', () async {
      final PrayerTimesRepository repository = buildRepository(online: true);

      final PrayerTimesDay day = await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'calculation');
      expect(day.isSane, isTrue, reason: 'Yerel hesap tutarlı vakit üretmeli');
      expect(day.timeOf(Prayer.imsak), isNotNull);
      expect(
        repository.lastWarning,
        contains('cihazda hesaplandı'),
        reason: 'Kullanıcıya bilgilendirme yapılmalı',
      );
    });

    chainTest('tutarsız (bozuk) servis verisi reddedilir ve zincir devam eder', () async {
      final _StubSource diyanet = _StubSource.success(
        'diyanet',
        unsortedDay(today),
      );
      final _StubSource aladhan = _StubSource.success(
        'aladhan',
        saneDay(today, source: 'aladhan'),
      );
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
        aladhan: aladhan,
      );

      final PrayerTimesDay day = await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'aladhan', reason: 'Bozuk veri kabul edilmemeli');
      expect(day.isSane, isTrue);
      expect(await cache.get('district:1741', today), isNotNull);
    });
  });

  group('önbellek ve çevrimdışı davranış', () {
    chainTest('çevrimdışıyken son başarılı veri önbellekten okunur', () async {
      // 1) Çevrimiçi: resmî veri çekilir ve kaydedilir.
      final PrayerTimesRepository online = buildRepository(
        online: true,
        diyanet: _StubSource.success('diyanet', saneDay(today)),
      );
      await online.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      // 2) Çevrimdışı + her kaynak hata veriyor: önbellek kurtarmalı.
      final _StubSource diyanet = _StubSource.failing('diyanet');
      final _StubSource aladhan = _StubSource.failing('aladhan');
      final PrayerTimesRepository offline = buildRepository(
        online: false,
        diyanet: diyanet,
        aladhan: aladhan,
      );

      final PrayerTimesDay day = await offline.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'cache');
      expect(day.isSane, isTrue);
      expect(diyanet.dayCalls, 0, reason: 'Çevrimdışıyken ağa çıkılmaz');
      expect(aladhan.dayCalls, 0);
      expect(offline.lastWarning, contains('Çevrimdışı'));
    });

    chainTest('süresi geçmiş (6 saatten eski) önbellek kullanılmaz', () async {
      await cache.save(
        'district:1741',
        saneDay(
          today,
          source: 'diyanet',
          cachedAt: DateTime.now().subtract(const Duration(hours: 7)),
        ),
      );

      final PrayerTimesRepository offline = buildRepository(online: false);
      final PrayerTimesDay day = await offline.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'calculation');
      expect(day.isSane, isTrue);
    });

    chainTest('çevrimdışı ve önbellek boşsa yerel hesap sonuç üretir', () async {
      final PrayerTimesRepository repository = buildRepository(online: false);

      final PrayerTimesDay day = await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'calculation');
      expect(day.isSane, isTrue);
      // Vakitler kullanılabilir olmalı: sonraki vakit her zaman bulunur.
      expect(day.nextPrayer(day.timeOf(Prayer.imsak)!), isNotNull);
    });

    chainTest('ilçe seçilmemişse (GPS) resmî servis çağrılmaz, hesap kullanılır', () async {
      final _StubSource diyanet = _StubSource.failing('diyanet');
      final _StubSource aladhan = _StubSource.failing('aladhan');
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
        aladhan: aladhan,
      );

      final PrayerTimesDay day = await repository.getDay(
        location: gpsLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'calculation');
      expect(diyanet.dayCalls, 0);
      expect(aladhan.dayCalls, 0);
    });

    chainTest('bellek önbelleği aynı gün için tekrar sorguda ağa çıkmaz', () async {
      final _StubSource diyanet = _StubSource.success('diyanet', saneDay(today));
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
      );

      await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );
      final PrayerTimesDay second = await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(diyanet.dayCalls, 1);
      expect(second.source, 'diyanet');
    });

    chainTest('zorla yenileme önbelleği atlar', () async {
      await cache.save('district:1741', saneDay(today, source: 'diyanet'));

      final _StubSource diyanet = _StubSource.success('diyanet', saneDay(today));
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
      );

      await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
        forceRefresh: true,
      );

      expect(diyanet.dayCalls, 1);
    });
  });

  group('aralık (haftalık/aylık tablo)', () {
    chainTest('önbellek aralığı kapsıyorsa ağa çıkılmaz', () async {
      final List<PrayerTimesDay> week = <PrayerTimesDay>[
        for (int i = 0; i < 8; i++)
          saneDay(
            today.add(Duration(days: i)),
            source: 'diyanet',
          ),
      ];
      await cache.saveMany('district:1741', week);

      final _StubSource diyanet = _StubSource.success('diyanet', saneDay(today));
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: diyanet,
      );

      final List<PrayerTimesDay> days = await repository.getRange(
        location: cityLocation,
        startDate: today,
        endDate: today.add(const Duration(days: 7)),
        method: CalculationMethod.diyanet,
      );

      expect(days.length, 8);
      expect(diyanet.rangeCalls, 0);
      expect(days.first.source, 'cache');
    });

    chainTest('önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur', () async {
      final PrayerTimesRepository repository = buildRepository(online: false);

      final List<PrayerTimesDay> days = await repository.getRange(
        location: cityLocation,
        startDate: today,
        endDate: today.add(const Duration(days: 6)),
        method: CalculationMethod.diyanet,
      );

      expect(days.length, 7);
      expect(
        days.every((PrayerTimesDay d) => d.isSane),
        isTrue,
        reason: 'Yerel hesap her günü tutarlı üretmeli',
      );
      expect(
        days.map((PrayerTimesDay d) => d.date.day),
        <int>[5, 6, 7, 8, 9, 10, 11],
      );
    });
  });

  group('Diyanet HTTP katmanı (sahte istemci)', () {
    chainTest('resmî yanıt çözümlenir (zarf + hicri tarih)', () async {
      final _StubHttpClient client = _StubHttpClient(
        (http.BaseRequest request) =>
            http.Response.bytes(utf8.encode(_diyanetPayload(today)), 200),
      );
      final DiyanetApiSource source = DiyanetApiSource(client: client);

      final PrayerTimesDay day = await source.fetchDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'diyanet');
      expect(day.isSane, isTrue);
      expect(day.hijriDate, '15 Rebîülevvel 1448');
      expect(day.timeOf(Prayer.aksam)!.hour, 19);
      expect(client.requested.single.path, contains('/prayer-times/1741/'));
    });

    chainTest('5xx yanıtı geçici hata olarak bildirilir', () async {
      final DiyanetApiSource source = DiyanetApiSource(
        client: _StubHttpClient(
          (http.BaseRequest request) => http.Response('servis yok', 503),
        ),
      );

      await expectLater(
        source.fetchDay(
          location: cityLocation,
          date: today,
          method: CalculationMethod.diyanet,
        ),
        throwsA(
          isA<PrayerTimesSourceException>()
              .having((PrayerTimesSourceException e) => e.sourceId, 'kaynak', 'diyanet')
              .having(
                (PrayerTimesSourceException e) => e.isTransient,
                'geçici',
                isTrue,
              ),
        ),
      );
    });

    chainTest('bozuk JSON çökme yerine kaynak hatası üretir', () async {
      final DiyanetApiSource source = DiyanetApiSource(
        client: _StubHttpClient(
          (http.BaseRequest request) => http.Response('<html>hata</html>', 200),
        ),
      );

      await expectLater(
        source.fetchDay(
          location: cityLocation,
          date: today,
          method: CalculationMethod.diyanet,
        ),
        throwsA(isA<PrayerTimesSourceException>()),
      );
    });

    chainTest('ilçe kimliği yoksa servis çağrılmadan hata verir', () async {
      final _StubHttpClient client = _StubHttpClient(
        (http.BaseRequest request) => http.Response('{}', 200),
      );
      final DiyanetApiSource source = DiyanetApiSource(client: client);

      await expectLater(
        source.fetchDay(
          location: gpsLocation,
          date: today,
          method: CalculationMethod.diyanet,
        ),
        throwsA(isA<PrayerTimesSourceException>()),
      );
      expect(client.calls, 0);
    });

    chainTest('AlAdhan yanıtı çözümlenir ve hicri etiket üretilir', () async {
      final AladhanApiSource source = AladhanApiSource(
        client: _StubHttpClient(
          (http.BaseRequest request) =>
              http.Response.bytes(utf8.encode(_aladhanPayload()), 200),
        ),
      );

      final PrayerTimesDay day = await source.fetchDay(
        location: gpsLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'aladhan');
      expect(day.isSane, isTrue);
      expect(day.hijriDate, contains('Rebîülevvel'));
    });

    chainTest('AlAdhan boş vakit verisinde hata üretir', () async {
      final AladhanApiSource source = AladhanApiSource(
        client: _StubHttpClient(
          (http.BaseRequest request) => http.Response(
            jsonEncode(<String, Object?>{
              'code': 200,
              'data': <String, Object?>{'timings': <String, Object?>{}},
            }),
            200,
          ),
        ),
      );

      await expectLater(
        source.fetchDay(
          location: gpsLocation,
          date: today,
          method: CalculationMethod.diyanet,
        ),
        throwsA(isA<PrayerTimesSourceException>()),
      );
    });
  });

  group('kaynak bilgisi (kullanıcı mesajları)', () {
    chainTest('resmî veri varken son güncelleme bilgisi gösterilir', () async {
      final PrayerTimesRepository repository = buildRepository(
        online: true,
        diyanet: _StubSource.success('diyanet', saneDay(today)),
      );
      await repository.getDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(
        await repository.describeActiveSource(cityLocation),
        contains('Son güncelleme'),
      );
    });

    chainTest('konum seçilmemişse hesap bilgisi gösterilir', () async {
      final PrayerTimesRepository repository = buildRepository(online: false);
      expect(
        await repository.describeActiveSource(gpsLocation),
        contains('GPS'),
      );
    });
  });

  group('yerel hesap kalibrasyonu', () {
    chainTest('Diyanet yöntemiyle İstanbul için tutarlı vakitler üretir', () async {
      const LocalCalculationSource local = LocalCalculationSource();
      final PrayerTimesDay day = await local.fetchDay(
        location: cityLocation,
        date: today,
        method: CalculationMethod.diyanet,
      );

      expect(day.source, 'calculation');
      expect(day.isSane, isTrue);
      final DateTime imsak = day.timeOf(Prayer.imsak)!;
      final DateTime yatsi = day.timeOf(Prayer.yatsi)!;
      expect(imsak.hour, inInclusiveRange(4, 7));
      expect(yatsi.hour, inInclusiveRange(19, 23));
      expect(
        yatsi.difference(imsak).inHours,
        greaterThan(12),
        reason: 'İmsak ile yatsı arası gerçekçi olmalı',
      );
    });
  });
}

/// Sabit ağ durumu (platform kanalına dokunmadan).
class _FixedConnectivity extends ConnectivityService {
  _FixedConnectivity(this.online) : super(Connectivity());

  final bool online;

  @override
  bool get isOnline => online;
}

/// Ağ yerine kullanılan sahte vakit kaynağı.
class _StubSource implements PrayerTimesSource {
  _StubSource.success(this.id, this.day)
    : failure = null,
      range = const <PrayerTimesDay>[];

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
  bool get requiresNetwork => id != 'calculation';

  @override
  Future<PrayerTimesDay> fetchDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
  }) async {
    dayCalls++;
    final String? message = failure;
    if (message != null) {
      throw PrayerTimesSourceException(id, message);
    }
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
    if (message != null) {
      throw PrayerTimesSourceException(id, message);
    }
    return range;
  }
}

/// `http.BaseClient` yerine geçen sahte istemci (gerçek ağ yok).
class _StubHttpClient extends http.BaseClient {
  _StubHttpClient(this.responder);

  final http.Response Function(http.BaseRequest request) responder;
  final List<Uri> requested = <Uri>[];
  int calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls++;
    requested.add(request.url);
    final http.Response response = responder(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

/// Sıralı (geçerli) bir gün üretir.
PrayerTimesDay saneDay(
  DateTime date, {
  String source = 'diyanet',
  DateTime? cachedAt,
}) {
  final DateTime base = DateTime(date.year, date.month, date.day);
  return PrayerTimesDay(
    date: base,
    times: <Prayer, DateTime>{
      Prayer.imsak: base.add(const Duration(hours: 5, minutes: 12)),
      Prayer.gunes: base.add(const Duration(hours: 6, minutes: 34)),
      Prayer.ogle: base.add(const Duration(hours: 13, minutes: 5)),
      Prayer.ikindi: base.add(const Duration(hours: 16, minutes: 28)),
      Prayer.aksam: base.add(const Duration(hours: 19, minutes: 41)),
      Prayer.yatsi: base.add(const Duration(hours: 21, minutes: 9)),
    },
    source: source,
    hijriDate: '15 Rebîülevvel 1448',
    cachedAt: cachedAt ?? DateTime.now(),
  );
}

/// Vakitleri sırasız (bozuk) gün — servis hatasını taklit eder.
PrayerTimesDay unsortedDay(DateTime date) {
  final PrayerTimesDay valid = saneDay(date);
  return valid.copyWith(
    times: <Prayer, DateTime>{
      Prayer.imsak: valid.times[Prayer.imsak]!,
      Prayer.gunes: valid.times[Prayer.gunes]!,
      Prayer.ogle: valid.times[Prayer.gunes]!,
      Prayer.ikindi: valid.times[Prayer.ikindi]!,
      Prayer.aksam: valid.times[Prayer.aksam]!,
      Prayer.yatsi: valid.times[Prayer.yatsi]!,
    },
  );
}

String _diyanetPayload(DateTime date) => jsonEncode(<String, Object?>{
  'success': true,
  'code': 200,
  'data': <Object?>[
    <String, Object?>{
      'date': _iso(date),
      'times': <String, String>{
        'imsak': '05:12',
        'gunes': '06:34',
        'ogle': '13:05',
        'ikindi': '16:28',
        'aksam': '19:41',
        'yatsi': '21:09',
      },
      'hijri_date': <String, Object?>{
        'day': 15,
        'month_name': 'Rebîülevvel',
        'year': 1448,
        'full_date': '15 Rebîülevvel 1448',
      },
    },
  ],
});

String _aladhanPayload() => jsonEncode(<String, Object?>{
  'code': 200,
  'status': 'OK',
  'data': <String, Object?>{
    'timings': <String, String>{
      'Fajr': '05:12',
      'Sunrise': '06:34',
      'Dhuhr': '13:05',
      'Asr': '16:28',
      'Maghrib': '19:41',
      'Isha': '21:09',
    },
    'date': <String, Object?>{
      'gregorian': <String, Object?>{'date': '05-10-2026'},
      'hijri': <String, Object?>{
        'day': '15',
        'year': '1448',
        'month': <String, Object?>{'en': 'Rabi al-awwal', 'tr': 'Rebîülevvel'},
      },
    },
  },
});

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';