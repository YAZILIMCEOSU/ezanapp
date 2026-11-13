import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../app/app_runtime.dart';
import '../core/config/app_features.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/services/ai_report_service.dart';
import '../core/services/billing_service.dart';
import '../core/services/compass_service.dart';
import '../core/services/home_widget_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/tts_service.dart';
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

/// Android'de **kesin alarm** izni verili mi?
///
/// İzin yoksa sistem ezan alarmını dakikalarca geciktirebilir; bu yüzden ana
/// ekranda tek dokunuşluk bir uyarı gösterilir. Android dışında (ve testlerde)
/// her zaman `true` döner.
final FutureProvider<bool> exactAlarmAvailabilityProvider =
    FutureProvider<bool>((Ref ref) async {
      final AppRuntime runtime = ref.watch(runtimeProvider);
      try {
        return await runtime.notifications.canScheduleExactAlarms();
      } catch (_) {
        // Platform kanalı yoksa (test/masaüstü) uyarı gösterilmez.
        return true;
      }
    });

/// Bildirimlerin gerçekten görünüp görünmeyeceği.
///
/// Tek bir bayrak yeterli değil: uygulama başlatma, bildirim izni ve kanal
/// durumu ayrı ayrı kontrol edilir. "Bildirim çubukta hiç çıkmıyor"
/// durumunun hangi halkada koptuğu ana ekranda görünür.
final FutureProvider<NotificationHealth> notificationHealthProvider =
    FutureProvider<NotificationHealth>((Ref ref) async {
      final AppRuntime runtime = ref.watch(runtimeProvider);
      final AdhanSound sound = ref.watch(
        settingsProvider.select((AppSettings s) => s.notifications.adhanSound),
      );
      try {
        return await runtime.notifications.checkHealth(
          channelId: NotificationService.adhanChannelId(sound),
        );
      } catch (_) {
        // Test/masaüstü ortamı: uyarı gösterilmez.
        return NotificationHealth.notApplicable;
      }
    });

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
    final bool methodChanged =
        previous.calculationMethodId != next.calculationMethodId ||
        previous.asrHanafi != next.asrHanafi ||
        !_sameOffsets(previous.manualOffsets, next.manualOffsets);
    if (methodChanged) {
      ref.read(runtimeProvider).prayerTimes.clearMemoryCache();
      ref.invalidate(prayerTimesProvider);
      ref.invalidate(prayerRangeProvider);
    }
    // Bildirim nesnesi `copyWith` içinde korunur; kimlik karşılaştırması
    // gereksiz zamanlamayı önler.
    if ((!identical(previous.notifications, next.notifications) ||
            methodChanged) &&
        rescheduleNotifications) {
      unawaited(
        ref.read(notificationCoordinatorProvider).reschedule(settings: next),
      );
    }
    if (previous.themeMode != next.themeMode) {
      ref.read(themeModeProvider.notifier).syncFromSettings(next.themeMode);
    }
  }

  static bool _sameOffsets(Map<String, int> a, Map<String, int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final MapEntry<String, int> entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  /// Yedekten geri yükleme.
  /// Yedeği uygular. Metin geçersizse **false** döner ve ayarlar değişmez.
  Future<bool> restoreFromJson(String raw) async {
    final AppSettings? parsed = AppSettings.tryImportJson(raw);
    if (parsed == null) return false;
    await update(parsed);
    return true;
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      update(state.copyWith(themeMode: mode));

  Future<void> setLocaleCode(String localeCode) => update(
    state.copyWith(localeCode: localeCode),
    rescheduleNotifications: false,
  );

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

  /// Tüm manuel dakika düzeltmelerini temizler.
  ///
  /// "Vakit 1 dakika geç/erken görünüyor" şikâyetlerinin en sık sebebi unutulmuş
  /// bir manuel düzeltmedir (ör. ikindi +1). Tek dokunuşla resmî saatlere
  /// dönülebilmesi için bu yöntem eklendi.
  Future<void> clearManualOffsets() =>
      update(state.copyWith(manualOffsets: const <String, int>{}));

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

  Future<void> setQuranTranslation(String translationId) => update(
    state.copyWith(quranTranslationId: translationId),
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

  /// KVKK açık rıza kayıtları.
  ///
  /// Rıza, cihazda ISO-8601 zaman damgasıyla saklanır; geri çekildiğinde
  /// kayıt silinir. Sunucuya rıza kaydı gönderilmez.
  String? get aiConsentAt =>
      ref.read(runtimeProvider).preferences.getString(PrefKeys.aiConsentAt);

  String? get backupConsentAt =>
      ref.read(runtimeProvider).preferences.getString(PrefKeys.backupConsentAt);

  Future<void> grantAiConsent() => ref
      .read(runtimeProvider)
      .preferences
      .setString(PrefKeys.aiConsentAt, DateTime.now().toIso8601String());

  Future<void> withdrawAiConsent() =>
      ref.read(runtimeProvider).preferences.remove(PrefKeys.aiConsentAt);

  Future<void> grantBackupConsent() => ref
      .read(runtimeProvider)
      .preferences
      .setString(PrefKeys.backupConsentAt, DateTime.now().toIso8601String());

  Future<void> withdrawBackupConsent() =>
      ref.read(runtimeProvider).preferences.remove(PrefKeys.backupConsentAt);

  /// Kişiselleştirilmiş reklam rızası. **Varsayılan kapalıdır**; rıza yoksa
  /// AdMob'a `npa=1` (kişiselleştirilmemiş reklam) sinyali gönderilir.
  String? get personalizedAdsConsentAt => ref
      .read(runtimeProvider)
      .preferences
      .getString(PrefKeys.personalizedAdsConsentAt);

  Future<void> grantPersonalizedAdsConsent() => ref
      .read(runtimeProvider)
      .preferences
      .setString(
        PrefKeys.personalizedAdsConsentAt,
        DateTime.now().toIso8601String(),
      );

  Future<void> withdrawPersonalizedAdsConsent() => ref
      .read(runtimeProvider)
      .preferences
      .remove(PrefKeys.personalizedAdsConsentAt);

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
    AppThemeMode.system => ThemeMode.light,
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
  StreamSubscription<LocationFix>? _positionSub;
  bool _refreshing = false;
  bool _refining = false;

  @override
  LocationState build() {
    ref.onDispose(() {
      _positionSub?.cancel();
      _positionSub = null;
    });
    final AppRuntime runtime = ref.read(runtimeProvider);
    final Map<String, Object?>? stored = runtime.preferences.getJson(
      _locationKey,
    );
    LocationState initial = const LocationState(
      location: UserLocation(
        mode: LocationMode.gps,
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
      ),
    );
    if (stored != null) {
      try {
        initial = LocationState(location: UserLocation.fromJson(stored));
      } catch (error) {
        AppLog.warning('Kayıtlı konum okunamadı: $error');
      }
    }
    if (initial.location.mode == LocationMode.gps) {
      unawaited(Future<void>.microtask(_ensureAutoWatch));
    }
    return initial;
  }

  Future<void> _ensureAutoWatch() async {
    await _positionSub?.cancel();
    _positionSub = null;
    if (state.location.mode != LocationMode.gps) return;
    final AppRuntime runtime = ref.read(runtimeProvider);
    // Kayıtlı GPS koordinatı varsa 960 ilçelik güncel veritabanından tam ilçeyi doğrula
    // (ör. eski sürümde Bağcılar koordinatı Küçükçekmece'ye eşleşmişse anında Bağcılar'a düzelt).
    if (state.location.city != null) {
      try {
        final City? rematched = await runtime.cities.nearest(
          state.location.latitude,
          state.location.longitude,
        );
        if (state.location.mode == LocationMode.gps &&
            rematched != null &&
            rematched.id != state.location.city?.id) {
          await _persist(
            UserLocation(
              mode: LocationMode.gps,
              latitude: state.location.latitude,
              longitude: state.location.longitude,
              city: rematched,
              updatedAt: state.location.updatedAt ?? DateTime.now(),
              gpsAccuracyMeters: state.location.gpsAccuracyMeters,
            ),
            restartWatch: false,
          );
        }
      } catch (_) {}
    }

    try {
      _positionSub = runtime.location
          .watchPosition(distanceFilterMeters: 150)
          .listen((LocationFix fix) async {
            if (state.location.mode != LocationMode.gps) return;
            final double movedKm = LocationService.distanceKm(
              state.location.latitude,
              state.location.longitude,
              fix.latitude,
              fix.longitude,
            );
            City? matched;
            try {
              matched = await runtime.cities.nearest(
                fix.latitude,
                fix.longitude,
              );
            } catch (_) {}
            if (movedKm < 0.15 && matched?.id == state.location.city?.id) {
              return;
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
              restartWatch: false,
            );
          }, onError: (_) {});
    } catch (_) {}
  }

  /// GPS ile konumu tazeler. Başarısız olursa [LocationState.error] doludur.
  ///
  /// **Hız:** Kullanıcı hiçbir zaman GPS kilidi beklemez.
  /// 1. İşletim sisteminin son bilinen konumu varsa **anında** uygulanır.
  /// 2. Canlı konum [(LocationService.getCurrentPosition)] toplam ~9 sn
  ///    bütçeyle alınır ve geldiğinde güncellenir.
  /// 3. Hassas konum gerekiyorsa [refineInBackground] çağrılır; ilçe
  ///    değişirse vakitler kendiliğinden yenilenir.
  Future<bool> refreshFromGps({bool requestPermission = true}) async {
    if (_refreshing) return state.location.city != null;
    _refreshing = true;
    // İlk açılışta kaydedilmiş bir ilçe varsa "yükleniyor" göstergesi
    // gösterme; ekran anında kullanılabilir kalsın.
    final bool hadCity = state.location.city != null;
    if (!hadCity) state = state.copyWith(busy: true);
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

      // 1) Son bilinen konum: beklemeden uygula (Bağcılar gibi ilçe anında
      //    görünür). Kayıtlı ilçe yoksa veya mevcut konum kaba ise uygulanır.
      final LocationFix? fastFix = await runtime.location
          .getLastKnownFastPosition();
      final bool fastBetter =
          fastFix != null &&
          (state.location.city == null ||
              (state.location.gpsAccuracyMeters ?? 1e9) >
                  (fastFix.accuracyMeters ?? 1e9) + 250);
      if (fastBetter) {
        final City? fastCity = await runtime.cities.nearest(
          fastFix.latitude,
          fastFix.longitude,
        );
        await _persist(
          UserLocation(
            mode: LocationMode.gps,
            latitude: fastFix.latitude,
            longitude: fastFix.longitude,
            city: fastCity,
            updatedAt: fastFix.timestamp ?? DateTime.now(),
            gpsAccuracyMeters: fastFix.accuracyMeters,
          ),
          restartWatch: false,
        );
        state = state.copyWith(busy: false);
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

      // 2) Kaba konumla (Wi-Fi/baz istasyonu) bulunduysa ilçe yanlış olabilir;
      //    arka planda hassas konum isteyip ilçe değişirse düzelt.
      if (!fix.isDistrictAccurate) {
        unawaited(_refineDistrict());
      }
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
    } finally {
      _refreshing = false;
    }
  }

  /// Arka planda hassas konum alır ve ilçe değiştiyse vakitleri yeniler.
  Future<void> _refineDistrict() async {
    if (_refining) return;
    _refining = true;
    try {
      final AppRuntime runtime = ref.read(runtimeProvider);
      final LocationFix? precise = await runtime.location.refineInBackground();
      if (precise == null) return;
      final City? matched = await runtime.cities.nearest(
        precise.latitude,
        precise.longitude,
      );
      final bool moved =
          matched?.id != state.location.city?.id ||
          (state.location.latitude - precise.latitude).abs() > 0.002 ||
          (state.location.longitude - precise.longitude).abs() > 0.002;
      if (!moved) return;
      if (state.location.mode != LocationMode.gps) return;
      AppLog.debug('Hassas konum ilçeyi güncelledi: ${matched?.displayName}');
      await _persist(
        UserLocation(
          mode: LocationMode.gps,
          latitude: precise.latitude,
          longitude: precise.longitude,
          city: matched,
          updatedAt: DateTime.now(),
          gpsAccuracyMeters: precise.accuracyMeters,
        ),
        restartWatch: false,
      );
    } catch (error) {
      AppLog.warning('Hassas konum alınamadı: $error');
    } finally {
      _refining = false;
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

  Future<void> _persist(
    UserLocation location, {
    bool restartWatch = true,
  }) async {
    state = state.copyWith(location: location, busy: false, error: null);
    if (location.mode == LocationMode.gps) {
      if (restartWatch) {
        unawaited(_ensureAutoWatch());
      }
    } else {
      await _positionSub?.cancel();
      _positionSub = null;
    }
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
    this.needsCitySelection = false,
    this.sourceDetail,
  });

  final PrayerTimesDay day;
  final PrayerTimesDay tomorrow;
  final String? warning;
  final String locationLabel;

  /// Bugünün vakitlerinin hangi yoldan alındığı (tanılama ekranı için).
  ///
  /// `PrayerTimesRepository.lastSourceDetail` tek alan; yarının verisi
  /// çekilirken üzerine yazılıyordu. Tanılama ekranı bu yüzden yarının
  /// kaynağını gösterebiliyordu. Bugünün değeri burada sabitlenir.
  final String? sourceDetail;

  /// Uyarı şeridindeki eylem "Yenile" yerine "Şehir seç" olmalı mı?
  /// (Konum hiçbir ilçeyle eşleşmediyse yenilemek sorunu çözmez.)
  final bool needsCitySelection;

  /// Aktif vakit, sıradaki vakit, geri sayım ve gün devri için tek model.
  PrayerScheduleSnapshot snapshot(DateTime now) =>
      PrayerScheduleSnapshot.resolve(day: day, tomorrow: tomorrow, now: now);

  /// O anki vakit + sonraki vakit + kalan süre.
  ({Prayer current, PrayerTime? next, Duration? remaining}) countdown(
    DateTime now,
  ) {
    final PrayerScheduleSnapshot snap = snapshot(now);
    return (
      current: snap.currentPrayer,
      next: snap.nextPrayer,
      remaining: snap.nextPrayer == null ? null : snap.remaining,
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
    // `lastWarning` repository üzerinde tek alan; yarının verisi çekilirken
    // sıfırlanıyordu. Bu yüzden bugünün uyarısı hemen saklanır.
    final String? todayWarning = runtime.prayerTimes.lastWarning;
    final String? todayDetail = runtime.prayerTimes.lastSourceDetail;
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
      // **Yalnızca bugünün uyarısı.** Önceden yarının verisi çekilirken
      // `lastWarning` sıfırlanıp yarının uyarısı gösterilebiliyordu: bugünün
      // vakitleri resmî veriden gelmiş olsa bile ekranda "resmî vakit
      // servisine ulaşılamadı" yazıyordu.
      warning: todayWarning,
      locationLabel: location.city?.displayName ?? label,
      needsCitySelection: location.city == null,
      sourceDetail: todayDetail,
    );
  }

  Future<void> refresh() async {
    final AppRuntime runtime = ref.read(runtimeProvider);
    // "Yenile" kullanıcının servis denemesi: kaynak düzeyindeki 6 saatlik
    // önbellek de atlanır, aksi hâlde tekrar deneme ağa hiç çıkmazdı.
    runtime.prayerTimes.clearMemoryCache(includingSource: true);
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
      final String? todayWarning = runtime.prayerTimes.lastWarning;
      final String? todayDetail = runtime.prayerTimes.lastSourceDetail;
      final PrayerTimesDay tomorrow = await runtime.prayerTimes.getDay(
        location: location,
        date: now.add(const Duration(days: 1)),
        method: method,
        forceRefresh: true,
      );
      return TodayTimes(
        day: day,
        tomorrow: tomorrow,
        warning: todayWarning,
        sourceDetail: todayDetail,
        locationLabel:
            location.city?.displayName ??
            await runtime.cities.describePoint(
              location.latitude,
              location.longitude,
            ),
        needsCitySelection: location.city == null,
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
    ref
        .read(runtimeProvider)
        .prayerTimes
        .clearMemoryCache(includingSource: true);
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
///
/// Arka planda GPS/konum yenilenirken eski şehrin ağ isteği geç tamamlanırsa
/// yeni şehrin alarmlarını ezmemesi için [_rescheduleGeneration] ve aktif konum
/// doğrulaması kullanılır.
class NotificationCoordinator {
  NotificationCoordinator(this._runtime, this._ref);

  final AppRuntime _runtime;
  final Ref _ref;
  int _rescheduleGeneration = 0;

  static bool _sameLocation(UserLocation a, UserLocation b) {
    if (a.city?.id != b.city?.id) return false;
    return (a.latitude - b.latitude).abs() < 1e-4 &&
        (a.longitude - b.longitude).abs() < 1e-4;
  }

  /// Ezan bildirimlerinin kaç gün ileriye kurulacağı.
  ///
  /// Uygulama 14 gün boyunca açılmasa bile vakit bildirimleri çalışmaya devam
  /// eder (önceden 8 gündü; tatile giden kullanıcıda bildirimler sessizce
  /// duruyordu).
  static const int scheduleHorizonDays = 15;

  /// Aynı anda iki `reschedule()` çalışırsa biri diğerinin iptal ettiği
  /// bildirimleri silebilir (cancel/schedule yarışı). Tüm turlar sıraya alınır.
  Future<void> _queue = Future<void>.value();
  NotificationScheduleReport? _lastReport;
  String? _lastError;

  NotificationScheduleReport? get lastReport => _lastReport;
  String? get lastError => _lastError;

  Future<int> reschedule({
    AppSettings? settings,
    int days = scheduleHorizonDays,
  }) {
    final Completer<int> completer = Completer<int>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await _reschedule(settings: settings, days: days));
      } catch (error) {
        // `unawaited` çağıranlar hata yutmasın: tur 0 ile tamamlanır.
        AppLog.warning('Bildirim yeniden zamanlanamadı: $error');
        if (!completer.isCompleted) completer.complete(0);
      }
    });
    return completer.future;
  }

  Future<int> _reschedule({
    AppSettings? settings,
    int days = scheduleHorizonDays,
  }) async {
    final int generation = ++_rescheduleGeneration;
    final AppSettings current =
        settings ?? _ref.read(settingsControllerProvider);
    final UserLocation location = _ref.read(activeLocationProvider);
    final CalculationMethod method = current.resolvedMethod(
      CalculationMethod.fromId(current.calculationMethodId),
    );

    if (!current.notifications.enabled) {
      await _runtime.notifications.cancelPrayerNotifications();
      _ref.invalidate(notificationHealthProvider);
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

      // Arka planda konum yenilendiyse veya daha yeni bir zamanlama başladıysa
      // eski şehre ait bu sonucu iptal et.
      final UserLocation latestLocation = _ref.read(activeLocationProvider);
      if (generation != _rescheduleGeneration ||
          !_sameLocation(location, latestLocation)) {
        return 0;
      }

      final String resolvedLabel =
          location.city?.displayName ??
          await _runtime.cities.describePoint(
            location.latitude,
            location.longitude,
          );

      if (generation != _rescheduleGeneration ||
          !_sameLocation(location, _ref.read(activeLocationProvider))) {
        return 0;
      }

      final int scheduled = await _runtime.notifications.scheduleForDays(
        days: range,
        settings: current.notifications,
        locationLabel: resolvedLabel,
        hijriOffsetDays: current.hijriOffsetDays,
      );

      // Hangi modun tuttuğu ve kaç bildirimin kurulamadığı tanılama için
      // saklanır; ayarlar ekranı ve test bunu gösterir.
      final NotificationScheduleReport report =
          _runtime.notifications.lastReport;
      _lastReport = report;
      if (!report.ok) {
        AppLog.warning(
          'Bazı vakit bildirimleri kurulamadı: ${report.failed} hata',
          error: report.error,
        );
      }

      if (range.length >= 2 && _runtime.ramadan.isRamadan) {
        await _runtime.notifications.scheduleRamadan(
          today: range.first,
          tomorrow: range[1],
          settings: current.notifications,
          locationLabel: resolvedLabel,
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
      _lastError = '$error';
      AppLog.warning('Bildirimler zamanlanamadı: $error');
      return 0;
    } finally {
      _ref.invalidate(notificationHealthProvider);
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

/// Sesli okuma (hutbe, dua) — cihazın kendi Türkçe konuşma motoru.
final Provider<TtsService> ttsServiceProvider = Provider<TtsService>(
  (Ref ref) => const TtsService(),
);

/// Android ana ekran widget'ı köprüsü (vakit + geri sayım).
final Provider<HomeWidgetService> homeWidgetServiceProvider =
    Provider<HomeWidgetService>((Ref ref) => const HomeWidgetService());

/// Yapay zekâ yanıtı bildirim servisi (Play "AI-Generated Content" politikası).
final Provider<AiReportService> aiReportServiceProvider =
    Provider<AiReportService>(
      (Ref ref) => AiReportService(ref.watch(runtimeProvider).preferences),
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

// ------------------------------------------------------------- Özellik bayrakları

/// Etkin özellik bayrakları (derleme zamanı; testler geçersiz kılabilir).
///
/// Kapatılan modüllerin sekmeleri, kartları ve menü girişleri gizlenir
/// (bkz. `AppFeatures` ve `docs/KURULUM.md` §7).
final Provider<AppFeatures> appFeaturesProvider = Provider<AppFeatures>(
  (Ref ref) => AppFeatures.active,
);

/// Kâbe'ye kuş uçuşu mesafe (km).
final Provider<double> qiblaDistanceProvider = Provider<double>((Ref ref) {
  final UserLocation location = ref.watch(activeLocationProvider);
  return GeoUtils.distanceToKaabaKm(location.latitude, location.longitude);
});
