import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezanai/app/app_runtime.dart';
import 'package:ezanai/core/audio/audio_service.dart';
import 'package:ezanai/core/db/app_database.dart';
import 'package:ezanai/core/services/ads_service.dart';
import 'package:ezanai/core/services/billing_service.dart';
import 'package:ezanai/core/services/connectivity_service.dart';
import 'package:ezanai/core/services/location_service.dart';
import 'package:ezanai/core/services/notification_service.dart';
import 'package:ezanai/core/services/preferences_service.dart';
import 'package:ezanai/core/services/push_service.dart';
import 'package:ezanai/core/services/sync_service.dart';
import 'package:ezanai/data/hijri/hijri_calendar.dart';
import 'package:ezanai/data/models/app_settings.dart';
import 'package:ezanai/data/models/prayer.dart';
import 'package:ezanai/data/models/prayer_times_day.dart';
import 'package:ezanai/data/prayer/prayer_times_cache.dart';
import 'package:ezanai/data/prayer/prayer_times_repository.dart';
import 'package:ezanai/data/repositories/ai_repository.dart';
import 'package:ezanai/data/repositories/city_repository.dart';
import 'package:ezanai/data/repositories/daily_content_repository.dart';
import 'package:ezanai/data/repositories/hadith_repository.dart';
import 'package:ezanai/data/repositories/ilahi_repository.dart';
import 'package:ezanai/data/repositories/quran_repository.dart';
import 'package:ezanai/data/repositories/ramadan_repository.dart';
import 'package:ezanai/data/repositories/zikir_repository.dart';
import 'package:ezanai/state/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Arayüz testleri için gerçek çalışma zamanı: gerçek repository'ler, bellek
/// içi SQLite ve dosyadan okunan varlıklar.
///
/// Böylece ekranlar taklit edilmeden, üretimdeki veri yollarının aynısıyla
/// çizilir; taşma, boş durum ve hata durumları gerçekçi biçimde yakalanır.
class TestAssets extends AssetBundle {
  TestAssets();

  /// Varlık anahtarı doğrudan dosya yolu olarak okunur
  /// (ör. `assets/data/adhkar/adhkar.json`); testler paket kökünden çalışır.
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('Test varlığı bulunamadı: $key');
    }
    final Uint8List bytes = file.readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }
}

/// Testlerde platform kanalları bulunmadığı için beklenen gürültü.
bool isPlatformNoise(Object error) =>
    error is MissingPluginException ||
    error is PlatformException ||
    error is UnimplementedError;

/// sqflite FFI'yi hazırlar (bellek içi veritabanı için).
void initTestDatabaseFactory() {
  sqfliteFfiInit();
}

/// Testlerde kullanılan veritabanı fabrikası.
///
/// İzole süreç (isolate) kullanmayan sürüm seçilir; widget testlerinde
/// sahte saatle çalışırken sorgular mikrogörevlerle tamamlanır ve testin
/// sonunda bekleyen ileti kalmaz.
DatabaseFactory get testDatabaseFactory => databaseFactoryFfiNoIsolate;

/// Veritabanı kurulamadıysa testi atlar ve görünür biçimde işaretler.
///
/// Bazı CI ortamlarında SQLite sistem kütüphanesi bulunmayabilir; bu durumda
/// veri katmanı testleri atlanır ve özet satırında `~` sayısı olarak görünür.
bool skipWithoutDatabase(String? reason) {
  if (reason == null) return false;
  markTestSkipped('Test veritabanı kullanılamıyor: $reason');
  return true;
}

/// Veritabanının gerçekten açılabildiğini doğrular; sorun varsa nedenini
/// döner (testler atlanırken kullanıcıya anlaşılır bilgi vermek için).
Future<String?> probeDatabase() async {
  try {
    final AppDatabase database = await AppDatabase.open(
      path: inMemoryDatabasePath,
      factory: testDatabaseFactory,
    );
    await database.close();
    return null;
  } catch (error) {
    return error.toString();
  }
}

/// Testlerde güvenli varsayılan ayarlar: bildirimler kapalı, böylece
/// platform kanallarına dokunulmaz.
AppSettings testSettings() => const AppSettings().copyWith(
  notifications: const NotificationSettings(enabled: false),
);

/// Gerçek repository'lerle bir [AppRuntime] kurar.
Future<AppRuntime> createTestRuntime({
  Map<String, Object> preferences = const <String, Object>{},
  String? databasePath,
}) async {
  final AppDatabase database = await AppDatabase.open(
    path: databasePath ?? inMemoryDatabasePath,
    factory: testDatabaseFactory,
  );

  SharedPreferences.setMockInitialValues(preferences);
  final PreferencesService prefs = await PreferencesService.create();

  final TestAssets assets = TestAssets();
  final ConnectivityService connectivity = ConnectivityService(Connectivity());
  final PrayerTimesRepository prayerTimes = PrayerTimesRepository(
    cache: PrayerTimesCache(database),
    connectivity: connectivity,
  );
  final HijriCalendar hijri = await HijriCalendar.load(bundle: assets);
  final QuranRepository quran = QuranRepository(database, bundle: assets);
  final HadithRepository hadith = HadithRepository(database, bundle: assets);
  final ZikirRepository zikir = ZikirRepository(database, bundle: assets);

  return AppRuntime(
    database: database,
    preferences: prefs,
    connectivity: connectivity,
    location: const LocationService(),
    notifications: NotificationService(),
    audio: AppAudioService(),
    ads: AdsService(),
    billing: BillingService(),
    hijri: hijri,
    prayerTimes: prayerTimes,
    cities: CityRepository(),
    quran: quran,
    hadith: hadith,
    zikir: zikir,
    ilahi: IlahiRepository(database),
    ramadan: RamadanRepository(database, prayerTimes, hijri),
    dailyContent: DailyContentRepository(database, quran, hadith, zikir),
    ai: AiRepository(database),
    push: PushService(),
    sync: SyncService(database, prefs),
    initialSettings: testSettings(),
  );
}

/// Sabit vakit verisi üreten notifier (ağ erişimi olmadan vakit ekranları).
class FixedPrayerTimesNotifier extends PrayerTimesNotifier {
  FixedPrayerTimesNotifier(this.fixed);

  final TodayTimes fixed;

  @override
  Future<TodayTimes> build() async => fixed;

  @override
  Future<void> refresh() async {}
}

/// Belirli bir gün için sabit vakitler üretir.
TodayTimes fixedTimes(
  DateTime date, {
  String label = 'İstanbul',
  String? warning,
}) => TodayTimes(
  day: dayFor(date),
  tomorrow: dayFor(date.add(const Duration(days: 1))),
  warning: warning,
  locationLabel: label,
);

/// Sıralı (geçerli) bir gün üretir.
PrayerTimesDay dayFor(DateTime date, {String source = 'test'}) {
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
  );
}

/// Hatayı, ilgili widget zinciri ve kaynak satırıyla birlikte okunur metne
/// çevirir (taşma hatalarında hangi widget'ın sorunlu olduğunu gösterir).
String describeError(FlutterErrorDetails details) {
  final StringBuffer buffer = StringBuffer(details.exceptionAsString());
  final Iterable<DiagnosticsNode> Function()? collector =
      details.informationCollector;
  if (collector != null) {
    try {
      for (final DiagnosticsNode node in collector()) {
        buffer.write('\n${node.toStringDeep()}');
      }
    } catch (error) {
      buffer.write('\n(ek bilgi alınamadı: $error)');
    }
  }
  return buffer.toString();
}

/// Ekranı çizer, hataları toplar, doğrular ve ekranı kapatır.
///
/// [verify] geri çağrısı ağaç ayaktayken çalışır; içerik doğrulamaları
/// (`find.text(...)` gibi) burada yapılmalıdır. Çizim hataları ve taşmalar
/// otomatik olarak denetlenir; atlama durumunda test `skipWithoutDatabase`
/// ile işaretlenir.
Future<List<FlutterErrorDetails>> renderScreen(
  WidgetTester tester,
  Widget screen, {
  required AppRuntime runtime,
  Size size = TestScreens.phone,
  TodayTimes? times,
  Duration settle = const Duration(milliseconds: 400),
  bool strict = true,
  void Function()? verify,
}) async {
  final List<FlutterErrorDetails> reported = <FlutterErrorDetails>[];
  final FlutterExceptionHandler? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    reported.add(details);
  };
  addTearDown(() => FlutterError.onError = previous);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final Widget content = MaterialApp(home: screen);
  // `times` verilirse vakit sağlayıcısı sabitlenir: ağa çıkılmaz ve geri
  // sayım deterministik olur.
  final Widget app = times == null
      ? ProviderScope(
          overrides: [runtimeProvider.overrideWithValue(runtime)],
          child: content,
        )
      : ProviderScope(
          overrides: [
            runtimeProvider.overrideWithValue(runtime),
            prayerTimesProvider.overrideWith(
              () => FixedPrayerTimesNotifier(times),
            ),
          ],
          child: content,
        );

  await tester.pumpWidget(app);
  await tester.pump(settle);

  Object? verificationError;
  StackTrace? verificationStack;
  if (verify != null) {
    try {
      verify();
    } catch (error, stack) {
      verificationError = error;
      verificationStack = stack;
    }
  }

  // Ekranı kapat: saniyelik saat gibi abonelikler ve zamanlayıcılar serbest
  // kalsın (testin sonunda "bekleyen zamanlayıcı" hatası oluşmasın).
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));

  FlutterError.onError = previous;

  if (strict) {
    final List<FlutterErrorDetails> overflows = reported
        .where((FlutterErrorDetails d) => hasOverflowError(d.exception))
        .toList();
    expect(
      overflows,
      isEmpty,
      reason:
          'Taşma hatası:\n${overflows.map(describeError).join('\n---\n')}',
    );
    final List<FlutterErrorDetails> problems = reported
        .where(
          (FlutterErrorDetails d) =>
              !hasOverflowError(d.exception) && !isPlatformNoise(d.exception),
        )
        .toList();
    expect(
      problems,
      isEmpty,
      reason:
          'Beklenmeyen çizim hatası:\n${problems.map(describeError).join('\n---\n')}',
    );
  }

  if (verificationError != null && verificationStack != null) {
    Error.throwWithStackTrace(verificationError, verificationStack);
  }
  return reported;
}

/// Taşma (overflow) hatası mı? RenderFlex taşmaları testte hata olarak
/// raporlanır; bu yardımcı ayırt etmek için kullanılır.
bool hasOverflowError(Object? error) {
  final String text = error.toString();
  return text.contains('overflowed') || text.contains('A RenderFlex');
}

/// Yaygın ekran boyutları.
class TestScreens {
  static const Size smallPhone = Size(320, 568);
  static const Size phone = Size(411, 914);
  static const Size tablet = Size(1024, 1366);

  static const Map<String, Size> named = <String, Size>{
    'küçük telefon 320×568': smallPhone,
    'telefon 411×914': phone,
    'tablet 1024×1366': tablet,
  };

  static const List<Size> all = <Size>[smallPhone, phone, tablet];
}
