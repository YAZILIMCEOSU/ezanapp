import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_runtime.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/services/billing_service.dart';
import '../core/services/compass_service.dart';
import '../core/services/location_service.dart';
import '../core/utils/geo.dart';
import '../core/utils/logger.dart';
import '../data/models/app_settings.dart';
import '../data/models/city.dart';
import '../data/models/hijri_date.dart';
import '../data/models/prayer.dart';
import '../data/models/prayer_times_day.dart';
import '../data/prayer/prayer_calculator.dart';
import '../design/app_theme.dart';

/// `main()` içinde `ProviderScope(overrides: ...)` ile gerçek çalışma zamanı
/// verilir; böylece tüm ekranlar servislere **senkron** erişir ve açılış hızlı
/// kalır.
final Provider<AppRuntime> runtimeProvider = Provider<AppRuntime>(
  (Ref ref) =>
      throw StateError('AppRuntime sağlanmadı (main.dart override etmeli).'),
);

/// Bağlantı durumu — çevrimdışı bilgilendirmeleri için.
final StreamProvider<bool> connectivityProvider = StreamProvider<bool>(
  (Ref ref) => ref.watch(runtimeProvider).connectivity.onStatusChange,
);

final Provider<bool> isOnlineProvider = Provider<bool>(
  (Ref ref) =>
      ref.watch(connectivityProvider).value ??
      ref.read(runtimeProvider).connectivity.isOnline,
);

// ---------------------------------------------------------------- Ayarlar

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(runtimeProvider).initialSettings;

  Future<void> update(
    AppSettings next, {
    bool rescheduleNotifications = true,
  }) async {
    final AppSettings previous = state;
    state = next;
    try {
      await ref
          .read(runtimeProvider)
          .preferences
          .setJson(PrefKeys.appSettings, next.toPrefs());
    } catch (error) {
      AppLog.warning('Ayarlar kaydedilemedi: $error');
    }
    // Bildirim nesnesi `copyWith` içinde korunur; kimlik karşılaştırması
    // gereksiz zamanlamayı önler.
    if (!identical(previous.notifications, next.notifications) &&
        rescheduleNotifications) {
      unawaited(
        ref.read(notificationCoordinatorProvider).reschedule(settings: next),
      );
    }
    if (previous.themeMode != next.themeMode) {
      ref.read(themeModeProvider.notifier).syncFromSettings(next.themeMode);
    }
  }

  /// Yedekten geri yükleme.
  Future<void> restoreFromJson(String raw) =>
      update(AppSettings.importJson(raw));

  Future<void> setThemeMode(AppThemeMode mode) =>
      update(state.copyWith(themeMode: mode));

  Future<void> setMethod(String methodId) =>
      update(state.copyWith(calculationMethodId: methodId));

  Future<void> setAsrHanafi(bool value) =>
      update(state.copyWith(asrHanafi: value));

  Future<void> setUse24Hour(bool value) =>
      update(state.copyWith(use24Hour: value), rescheduleNotifications: false);

  Future<void> setHijriOffset(int days) => update(
    state.copyWith(hijriOffsetDays: days.clamp(-3, 3)),
    rescheduleNotifications: false,
  );

  Future<void> setManualOffset(String prayerKey, int minutes) {
    final Map<String, int> offsets = Map<String, int>.from(state.manualOffsets);
    if (minutes == 0) {
      offsets.remove(prayerKey);
    } else {
      offsets[prayerKey] = minutes.clamp(-30, 30);
    }
    return update(state.copyWith(manualOffsets: offsets));
  }

  Future<void> updateNotifications(NotificationSettings notifications) =>
      update(state.copyWith(notifications: notifications));

  Future<void> setQuranFontSize(double size) => update(
    state.copyWith(quranFontSize: size.clamp(18, 44)),
    rescheduleNotifications: false,
  );

  Future<void> setQuranReciter(String reciterId) => update(
    state.copyWith(quranReciterId: reciterId),
    rescheduleNotifications: false,
  );

  Future<void> setZikirPreferences({
    bool? vibration,
    bool? sound,
    bool? autoAdvance,
    int? defaultTarget,
  }) => update(
    state.copyWith(
      zikirVibrationEnabled: vibration,
      zikirSoundEnabled: sound,
      zikirAutoAdvance: autoAdvance,
      zikirDefaultTarget: defaultTarget,
    ),
    rescheduleNotifications: false,
  );

  Future<void> setAnalytics(bool enabled) => update(
    state.copyWith(analyticsEnabled: enabled),
    rescheduleNotifications: false,
  );

  Future<void> setCrashReporting(bool enabled) => update(
    state.copyWith(crashReportingEnabled: enabled),
    rescheduleNotifications: false,
  );

  Future<void> setStreamingOnlyOnWifi(bool value) => update(
    state.copyWith(streamingOnlyOnWifi: value),
    rescheduleNotifications: false,
  );

  Future<void> setAdhanDucking(bool value) => update(
    state.copyWith(adhanPlaybackDucking: value),
    rescheduleNotifications: false,
  );
}

final NotifierProvider<SettingsController, AppSettings>
settingsControllerProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

final Provider<AppSettings> settingsProvider = Provider<AppSettings>(
  (Ref ref) => ref.watch(settingsControllerProvider),
);

/// Ayarların uygulandığı nihai hesap yöntemi.
final Provider<CalculationMethod> calculationMethodProvider =
    Provider<CalculationMethod>((Ref ref) {
      final AppSettings settings = ref.watch(settingsProvider);
      return settings.resolvedMethod(
        CalculationMethod.fromId(settings.calculationMethodId),
      );
    });

// -------------------------------------------------------------------- Tema

class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => ref.read(settingsControllerProvider).themeMode;

  void syncFromSettings(AppThemeMode mode) => state = mode;

  static ThemeMode toMaterial(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.amoled => ThemeMode.dark,
  };
}

final NotifierProvider<ThemeModeController, AppThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(
      ThemeModeController.new,
    );

// ---------------------------------------------------------------- Konum

/// Konum durumu: aktif konum + işlem bilgisi (arayüz için).
@immutable
class LocationState {
  const LocationState({required this.location, this.busy = false, this.error});

  final UserLocation location;
  final bool busy;
  final String? error;

  LocationState copyWith({UserLocation? location, bool? busy, String? error}) =>
      LocationState(
        location: location ?? this.location,
        busy: busy ?? this.busy,
        error: error,
      );
}

class LocationController extends Notifier<LocationState> {
  static const String _locationKey = 'active_location';

  @override
  LocationState build() {
    final AppRuntime runtime = ref.read(runtimeProvider);
    final Map<String, Object?>? stored = runtime.preferences.getJson(
      _locationKey,
    );
    if (stored != null) {
      try {
        return LocationState(location: UserLocation.fromJson(stored));
      } catch (error) {
        AppLog.warning('Kayıtlı konum okunamadı: $error');
      }
    }
    return const LocationState(
      location: UserLocation(
        mode: LocationMode.gps,
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
      ),
    );
  }

  /// GPS ile konumu tazeler. Başarısız olursa [LocationState.error] doludur.
  Future<bool> refreshFromGps({bool requestPermission = true}) async {
    state = state.copyWith(busy: true);
    try {
      final AppRuntime runtime = ref.read(runtimeProvider);
      LocationStatus status = await runtime.location.checkStatus();
      if (status != LocationStatus.granted && requestPermission) {
        status = await runtime.location.requestPermission();
      }
      if (status != LocationStatus.granted) {
        state = state.copyWith(
          busy: false,
          error: switch (status) {
            LocationStatus.deniedForever => 'Konum izni kalıcı olarak reddedilmiş. Ayarlardan izin verebilirsiniz.',
            LocationStatus.serviceDisabled =>
              'Konum servisi kapalı. Açtıktan sonra tekrar deneyin.',
            _ => 'Konum izni verilmedi. Dilerseniz şehir seçebilirsiniz.',
          },
        );
        return false;
      }

      final LocationFix fix = await runtime.location.getCurrentPosition();
      City? matched;
      try {
        matched = await runtime.cities.nearest(fix.latitude, fix.longitude);
      } catch (error) {
        AppLog.warning('Yakın şehir bulunamadı: $error');
      }

      await _persist(
        UserLocation(
          mode: LocationMode.gps,
          latitude: fix.latitude,
          longitude: fix.longitude,
          city: matched,
          updatedAt: DateTime.now(),
          gpsAccuracyMeters: fix.accuracyMeters,
        ),
      );
      state = state.copyWith(busy: false, error: null);
      return true;
    } on AppException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
      return false;
    } catch (error) {
      AppLog.warning('GPS hatası: $error');
      state = state.copyWith(
        busy: false,
        error: 'Konum alınamadı. Lütfen tekrar deneyin.',
      );
      return false;
    }
  }

  Future<void> selectCity(
    City city, {
    LocationMode mode = LocationMode.manual,
  }) => _persist(
    UserLocation(
      mode: mode,
      latitude: city.latitude,
      longitude: city.longitude,
      city: city,
      updatedAt: DateTime.now(),
    ),
  );

  /// Şehir verisi bulunamadığında koordinatla devam eder (yurt dışı vb.).
  Future<void> useCoordinates(double latitude, double longitude) => _persist(
    UserLocation(
      mode: LocationMode.gps,
      latitude: latitude,
      longitude: longitude,
      updatedAt: DateTime.now(),
    ),
  );

  void clearError() => state = state.copyWith(error: null);

  Future<void> _persist(UserLocation location) async {
    state = state.copyWith(location: location, busy: false, error: null);
    try {
      await ref
          .read(runtimeProvider)
          .preferences
          .setJson(_locationKey, location.toJson());
    } catch (error) {
      AppLog.warning('Konum kaydedilemedi: $error');
    }
    ref.invalidate(prayerTimesProvider);
    ref.invalidate(prayerRangeProvider);
    unawaited(ref.read(notificationCoordinatorProvider).reschedule());
  }
}

final NotifierProvider<LocationController, LocationState>
locationControllerProvider =
    NotifierProvider<LocationController, LocationState>(LocationController.new);

final Provider<UserLocation> activeLocationProvider = Provider<UserLocation>(
  (Ref ref) => ref.watch(locationControllerProvider).location,
);

/// GPS koordinatına en yakın şehir adı (arayüzde "İstanbul yakını" gibi).
final FutureProvider<String> locationLabelProvider = FutureProvider<String>((
  Ref ref,
) async {
  final UserLocation location = ref.watch(activeLocationProvider);
  if (location.city != null) return location.city!.displayName;
  final AppRuntime runtime = ref.watch(runtimeProvider);
  return runtime.cities.describePoint(location.latitude, location.longitude);
});

// ------------------------------------------------------------- Vakitler

class TodayTimes {
  const TodayTimes({
    required this.day,
    required this.tomorrow,
    required this.warning,
    required this.locationLabel,
  });

  final PrayerTimesDay day;
  final PrayerTimesDay tomorrow;
  final String? warning;
  final String locationLabel;

  /// O anki vakit + sonraki vakit + kalan süre.
  ({Prayer current, PrayerTime? next, Duration? remaining}) countdown(
    DateTime now,
  ) {
    final Prayer current = day.currentPrayer(now);
    final PrayerTime? next = day.nextPrayer(now);
    return (
      current: current,
      next: next,
      remaining: next?.time.difference(now),
    );
  }
}

/// Bugünün vakitleri; konum/yöntem değişiminde otomatik yeniden yüklenir.
class PrayerTimesNotifier extends AsyncNotifier<TodayTimes> {
  @override
  Future<TodayTimes> build() async {
    final AppRuntime runtime = ref.watch(runtimeProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final CalculationMethod method = ref.watch(calculationMethodProvider);

    final DateTime now = DateTime.now();
    final PrayerTimesDay day = await runtime.prayerTimes.getDay(
      location: location,
      date: now,
      method: method,
    );
    final PrayerTimesDay tomorrow = await runtime.prayerTimes.getDay(
      location: location,
      date: now.add(const Duration(days: 1)),
      method: method,
    );

    final String label = await runtime.cities.describePoint(
      location.latitude,
      location.longitude,
    );
    return TodayTimes(
      day: day,
      tomorrow: tomorrow,
      warning: runtime.prayerTimes.lastWarning,
      locationLabel: location.city?.displayName ?? label,
    );
  }

  Future<void> refresh() async {
    final AppRuntime runtime = ref.read(runtimeProvider);
    runtime.prayerTimes.clearMemoryCache();
    state = const AsyncLoading<TodayTimes>();
    state = await AsyncValue.guard<TodayTimes>(() async {
      final UserLocation location = ref.read(activeLocationProvider);
      final CalculationMethod method = ref.read(calculationMethodProvider);
      final DateTime now = DateTime.now();
      final PrayerTimesDay day = await runtime.prayerTimes.getDay(
        location: location,
        date: now,
        method: method,
        forceRefresh: true,
      );
      final PrayerTimesDay tomorrow = await runtime.prayerTimes.getDay(
        location: location,
        date: now.add(const Duration(days: 1)),
        method: method,
        forceRefresh: true,
      );
      return TodayTimes(
        day: day,
        tomorrow: tomorrow,
        warning: runtime.prayerTimes.lastWarning,
        locationLabel:
            location.city?.displayName ??
            await runtime.cities.describePoint(
              location.latitude,
              location.longitude,
            ),
      );
    });
    unawaited(ref.read(notificationCoordinatorProvider).reschedule());
  }
}

final AsyncNotifierProvider<PrayerTimesNotifier, TodayTimes>
prayerTimesProvider = AsyncNotifierProvider<PrayerTimesNotifier, TodayTimes>(
  PrayerTimesNotifier.new,
);

enum PrayerRangeView {
  today('Bugün', Icons.today_rounded),
  week('Hafta', Icons.date_range_rounded),
  month('Ay', Icons.calendar_month_rounded);

  const PrayerRangeView(this.label, this.icon);

  final String label;
  final IconData icon;
}

class PrayerRangeViewController extends Notifier<PrayerRangeView> {
  @override
  PrayerRangeView build() => PrayerRangeView.today;

  void select(PrayerRangeView view) => state = view;
}

final NotifierProvider<PrayerRangeViewController, PrayerRangeView>
prayerRangeViewProvider =
    NotifierProvider<PrayerRangeViewController, PrayerRangeView>(
      PrayerRangeViewController.new,
    );

/// Haftalık/aylık tablo verisi (Bugün görünümünde boş döner).
class PrayerRangeNotifier extends AsyncNotifier<List<PrayerTimesDay>> {
  @override
  Future<List<PrayerTimesDay>> build() async {
    final PrayerRangeView view = ref.watch(prayerRangeViewProvider);
    if (view == PrayerRangeView.today) return const <PrayerTimesDay>[];

    final AppRuntime runtime = ref.watch(runtimeProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final CalculationMethod method = ref.watch(calculationMethodProvider);
    final DateTime start = DateTime.now();
    final DateTime end = view == PrayerRangeView.week
        ? start.add(const Duration(days: 6))
        : DateTime(start.year, start.month + 1, 0);

    return runtime.prayerTimes.getRange(
      location: location,
      startDate: start,
      endDate: end,
      method: method,
    );
  }

  Future<void> refresh() async {
    ref.read(runtimeProvider).prayerTimes.clearMemoryCache();
    ref.invalidateSelf();
    await future;
  }
}

final AsyncNotifierProvider<PrayerRangeNotifier, List<PrayerTimesDay>>
prayerRangeProvider =
    AsyncNotifierProvider<PrayerRangeNotifier, List<PrayerTimesDay>>(
      PrayerRangeNotifier.new,
    );

/// Saniyelik saat — geri sayımlar için. Ekrandan çıkıldığında durur.
final StreamProvider<DateTime> clockProvider =
    StreamProvider.autoDispose<DateTime>(
      (Ref ref) => Stream<DateTime>.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
    );

/// Hicri tarih (ayarlardaki kaydırma uygulanır).
final Provider<HijriDate> hijriTodayProvider = Provider<HijriDate>((Ref ref) {
  final AppRuntime runtime = ref.watch(runtimeProvider);
  final AppSettings settings = ref.watch(settingsProvider);
  return runtime.hijri.toHijri(
    DateTime.now(),
    dayOffset: settings.hijriOffsetDays,
  );
});

// ---------------------------------------------------- Bildirim koordinatörü

/// Konum/ayar değiştiğinde bildirimleri yeniden zamanlar.
class NotificationCoordinator {
  NotificationCoordinator(this._runtime, this._ref);

  final AppRuntime _runtime;
  final Ref _ref;

  Future<int> reschedule({AppSettings? settings, int days = 8}) async {
    final AppSettings current =
        settings ?? _ref.read(settingsControllerProvider);
    final UserLocation location = _ref.read(activeLocationProvider);
    final CalculationMethod method = current.resolvedMethod(
      CalculationMethod.fromId(current.calculationMethodId),
    );

    if (!current.notifications.enabled) {
      await _runtime.notifications.cancelPrayerNotifications();
      return 0;
    }

    try {
      final DateTime start = DateTime.now();
      final List<PrayerTimesDay> range = await _runtime.prayerTimes.getRange(
        location: location,
        startDate: start,
        endDate: start.add(Duration(days: days - 1)),
        method: method,
      );

      final int scheduled = await _runtime.notifications.scheduleForDays(
        days: range,
        settings: current.notifications,
        locationLabel: location.city?.displayName ?? 'Konumunuz',
        hijriOffsetDays: current.hijriOffsetDays,
      );

      if (range.length >= 2 && _runtime.ramadan.isRamadan) {
        await _runtime.notifications.scheduleRamadan(
          today: range.first,
          tomorrow: range[1],
          settings: current.notifications,
          locationLabel: location.city?.displayName ?? 'Konumunuz',
        );
      }

      final NotificationSettings ns = current.notifications;
      await _runtime.notifications.scheduleDailyReminder(
        id: 3004,
        title: 'Günün ayeti hazır',
        body: 'Bugünün ayetini ve hadisini okumak için dokunun.',
        hour: ns.dailyContentHour,
        minute: ns.dailyContentMinute,
        channelId: NotificationChannels.daily,
        settings: ns,
        enabled: ns.dailyContentEnabled,
        payload: 'home:daily',
      );
      await _runtime.notifications.scheduleDailyReminder(
        id: 3006,
        title: 'Günlük zikrinizi tamamlayın',
        body: 'Hedefinize bir adım daha yaklaşın.',
        hour: ns.zikirReminderHour,
        minute: ns.zikirReminderMinute,
        channelId: NotificationChannels.zikir,
        settings: ns,
        enabled: ns.zikirReminderEnabled,
        payload: 'zikir:today',
      );
      await _runtime.notifications.scheduleDailyReminder(
        id: 3007,
        title: 'Hatim hatırlatması',
        body: 'Bugünkü cüzünüzü okumayı unutmayın.',
        hour: ns.hatimReminderHour,
        minute: ns.hatimReminderMinute,
        channelId: NotificationChannels.zikir,
        settings: ns,
        enabled: ns.hatimReminderEnabled,
        payload: 'ramadan:hatim',
      );
      return scheduled;
    } catch (error) {
      AppLog.warning('Bildirimler zamanlanamadı: $error');
      return 0;
    }
  }
}

final Provider<NotificationCoordinator> notificationCoordinatorProvider =
    Provider<NotificationCoordinator>(
      (Ref ref) => NotificationCoordinator(ref.watch(runtimeProvider), ref),
    );

// ------------------------------------------------------------ Premium

class PremiumController extends Notifier<PremiumStatus> {
  StreamSubscription<PremiumStatus>? _subscription;

  @override
  PremiumStatus build() {
    final AppRuntime runtime = ref.read(runtimeProvider);
    final bool cached = runtime.preferences.getBool(PrefKeys.premiumCache);
    unawaited(_attach(runtime));
    ref.onDispose(() => _subscription?.cancel());
    return cached ? PremiumStatus.premium : PremiumStatus.unknown;
  }

  bool get isPremium => state.isPremium;

  Future<void> _attach(AppRuntime runtime) async {
    _subscription ??= runtime.billing.statusStream.listen((
      PremiumStatus status,
    ) {
      state = status;
      runtime.ads.setPremium(status.isPremium);
      unawaited(
        runtime.preferences.setBool(PrefKeys.premiumCache, status.isPremium),
      );
    });
    if (runtime.billing.status != PremiumStatus.unknown) {
      state = runtime.billing.status;
      runtime.ads.setPremium(runtime.billing.status.isPremium);
    }
  }

  Future<void> purchase(String productId) async {
    final AppRuntime runtime = ref.read(runtimeProvider);
    final bool started = await runtime.billing.purchase(productId);
    if (!started) {
      throw AppException(
        runtime.billing.lastError ?? 'Satın alma başlatılamadı.',
      );
    }
  }

  Future<PremiumStatus> restore() async {
    final AppRuntime runtime = ref.read(runtimeProvider);
    final PremiumStatus status = await runtime.billing.refresh();
    state = status;
    runtime.ads.setPremium(status.isPremium);
    await runtime.preferences.setBool(PrefKeys.premiumCache, status.isPremium);
    return status;
  }
}

final NotifierProvider<PremiumController, PremiumStatus> premiumProvider =
    NotifierProvider<PremiumController, PremiumStatus>(PremiumController.new);

final Provider<bool> isPremiumProvider = Provider<bool>(
  (Ref ref) => ref.watch(premiumProvider).isPremium,
);

// ------------------------------------------------------------- Kıble

final Provider<CompassService> compassServiceProvider =
    Provider<CompassService>((Ref ref) {
      final CompassService service = CompassService();
      ref.onDispose(service.dispose);
      return service;
    });

/// Kâbe yönü (kuzeyden saat yönünde derece).
final Provider<double> qiblaDirectionProvider = Provider<double>((Ref ref) {
  final UserLocation location = ref.watch(activeLocationProvider);
  return GeoUtils.qiblaBearing(location.latitude, location.longitude);
});

/// Kâbe'ye kuş uçuşu mesafe (km).
final Provider<double> qiblaDistanceProvider = Provider<double>((Ref ref) {
  final UserLocation location = ref.watch(activeLocationProvider);
  return GeoUtils.distanceToKaabaKm(location.latitude, location.longitude);
});
