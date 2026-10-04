import 'package:flutter/foundation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/audio/audio_service.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../core/db/app_database.dart';
import '../core/services/ads_service.dart';
import '../core/services/billing_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/preferences_service.dart';
import '../core/utils/logger.dart';
import '../data/hijri/hijri_calendar.dart';
import '../data/models/app_settings.dart';
import '../data/prayer/prayer_times_cache.dart';
import '../data/prayer/prayer_times_repository.dart';
import '../data/repositories/ai_repository.dart';
import '../data/repositories/city_repository.dart';
import '../data/repositories/daily_content_repository.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/ilahi_repository.dart';
import '../data/repositories/quran_repository.dart';
import '../data/repositories/ramadan_repository.dart';
import '../data/repositories/zikir_repository.dart';

/// Uygulamanın nesne grafiği.
///
/// `main()` içinde **bir kez** kurulur ve `ProviderScope` üzerinden tüm
/// arayüze senkron olarak sunulur. Böylece ekranlar `await` beklemeden
/// veriye erişir, açılış hızlı kalır ve her servis tek örnek olur.
class AppRuntime {
  AppRuntime({
    required this.database,
    required this.preferences,
    required this.connectivity,
    required this.location,
    required this.notifications,
    required this.audio,
    required this.ads,
    required this.billing,
    required this.hijri,
    required this.prayerTimes,
    required this.cities,
    required this.quran,
    required this.hadith,
    required this.zikir,
    required this.ilahi,
    required this.ramadan,
    required this.dailyContent,
    required this.ai,
    required this.initialSettings,
  });

  final AppDatabase database;
  final PreferencesService preferences;
  final ConnectivityService connectivity;
  final LocationService location;
  final NotificationService notifications;
  final AppAudioService audio;
  final AdsService ads;
  final BillingService billing;
  final HijriCalendar hijri;
  final PrayerTimesRepository prayerTimes;
  final CityRepository cities;
  final QuranRepository quran;
  final HadithRepository hadith;
  final ZikirRepository zikir;
  final IlahiRepository ilahi;
  final RamadanRepository ramadan;
  final DailyContentRepository dailyContent;
  final AiRepository ai;
  final AppSettings initialSettings;

  bool _disposed = false;

  /// Tüm servisleri hazırlar. Kritik olmayan adımlar (bildirim, reklam,
  /// faturalandırma) başarısız olsa bile uygulama açılır — kullanıcı boş
  /// ekranla kalmaz.
  static Future<AppRuntime> create({bool initializePlatformServices = true}) async {
    final AppDatabase database = await AppDatabase.open();
    final PreferencesService preferences = await PreferencesService.create();
    final AppSettings settings = AppSettings.fromPrefs(
      preferences.getJson(PrefKeys.appSettings) ?? const <String, Object?>{},
    );

    final HijriCalendar hijri = await HijriCalendar.load();
    final ConnectivityService connectivity = ConnectivityService(Connectivity());
    final NotificationService notifications = NotificationService();
    final AppAudioService audio = AppAudioService();
    final AdsService ads = AdsService();
    final BillingService billing = BillingService();

    final PrayerTimesRepository prayerTimes = PrayerTimesRepository(
      cache: PrayerTimesCache(database),
      connectivity: connectivity,
    );

    final QuranRepository quran = QuranRepository(database);
    final HadithRepository hadith = HadithRepository(database);
    final ZikirRepository zikir = ZikirRepository(database);
    final IlahiRepository ilahi = IlahiRepository(
      database,
      catalogUrl: AppConfig.hasIlahiCatalog ? AppConfig.ilahiCatalogUrl : null,
    );

    final AppRuntime runtime = AppRuntime(
      database: database,
      preferences: preferences,
      connectivity: connectivity,
      location: const LocationService(),
      notifications: notifications,
      audio: audio,
      ads: ads,
      billing: billing,
      hijri: hijri,
      prayerTimes: prayerTimes,
      cities: CityRepository(),
      quran: quran,
      hadith: hadith,
      zikir: zikir,
      ilahi: ilahi,
      ramadan: RamadanRepository(database, prayerTimes, hijri),
      dailyContent: DailyContentRepository(database, quran, hadith, zikir),
      ai: AiRepository(database),
      initialSettings: settings,
    );

    if (initializePlatformServices) {
      await runtime._warmUp();
    }
    AppLog.info('EzanAI hazır (${settings.calculationMethodId} yöntemi).');
    return runtime;
  }

  Future<void> _warmUp() async {
    await _safely('bağlantı izleme', () => connectivity.start((bool online) {
          AppLog.debug(online ? 'Ağ bağlantısı kuruldu.' : 'Ağ bağlantısı kesildi.');
        }));
    await _safely('bildirimler', () => notifications.initialize());
    await _safely('ses motoru', () => audio.initialize(ducking: initialSettings.adhanPlaybackDucking));
    await _safely('faturalandırma', () => billing.initialize());
    ads.setPremium(false);
  }

  Future<void> _safely(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      AppLog.warning('$label başlatılamadı: $error');
      AppLog.debug('$stack');
    }
  }

  /// Kullanıcı "verilerimi sil" dediğinde yerel veritabanı temizlenir.
  Future<void> clearUserData() async {
    await database.clearUserData();
    prayerTimes.clearMemoryCache();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _safely('ses motoru', audio.dispose);
    await _safely('faturalandırma', billing.dispose);
    ads.dispose();
    ai.dispose();
    await _safely('veritabanı', database.close);
  }

  // --------------------------------------------------------- Yardımcılar

  /// Durum bilgisi (ayarlar > hakkında ekranı için).
  Map<String, String> diagnostics() => <String, String>{
        'Vakit verisi': AppConfig.hasBackend ? 'Backend yapılandırıldı' : 'Resmî servis + yerel hesap',
        'AI asistan': AppConfig.hasBackend ? 'Sunucu bağlı' : 'Çevrimdışı bilgi tabanı',
        'Bulut senkron': AppConfig.hasSupabase ? 'Etkin' : 'Kapalı',
        'İlahi kataloğu': AppConfig.hasIlahiCatalog ? 'Bağlı' : 'Yalnızca cihazdaki sesler',
        'Reklamlar': AppConfig.adsConfigured ? 'Etkin' : 'Kapalı (kimlik tanımlı değil)',
      };

  @visibleForTesting
  bool get isDisposed => _disposed;
}
