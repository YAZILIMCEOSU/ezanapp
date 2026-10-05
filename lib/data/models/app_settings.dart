import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../design/app_theme.dart';
import '../models/prayer.dart';
import '../prayer/prayer_calculator.dart';

/// Ezan bildirim sesi seçenekleri.
enum AdhanSound {
  silent('Sessiz', 'Bildirim sesi çalınmaz', null),
  systemDefault('Sistem varsayılanı', 'Telefonun bildirim sesi', 'system'),
  tone1('Bildirim tonu 1', 'Yumuşak çan dizesi (dahili)', 'ezan_ton_1'),
  tone2('Bildirim tonu 2', 'Derin çan (dahili)', 'ezan_ton_2'),
  tone3('Bildirim tonu 3', 'Kısa uyarı (dahili)', 'ezan_ton_3'),
  downloaded('İndirilen ezan', 'Ezan sesi kataloğundan seçilir', 'downloaded');

  const AdhanSound(this.label, this.description, this.resource);

  final String label;
  final String description;

  /// Android `res/raw` kaynak adı veya özel anahtar.
  final String? resource;

  bool get isSilent => this == AdhanSound.silent;

  static AdhanSound fromName(String? name) => AdhanSound.values.firstWhere(
    (AdhanSound s) => s.name == name,
    orElse: () => AdhanSound.tone1,
  );
}

/// Bildirim tercihleri.
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.prayerEnabled = const <Prayer, bool>{
      Prayer.imsak: true,
      Prayer.gunes: false,
      Prayer.ogle: true,
      Prayer.ikindi: true,
      Prayer.aksam: true,
      Prayer.yatsi: true,
    },
    this.preReminderMinutes = 0,
    this.adhanSound = AdhanSound.tone1,
    this.adhanVolume = 0.8,
    this.vibrationEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStartMinutes = 23 * 60,
    this.quietHoursEndMinutes = 6 * 60,
    this.sleepModeEnabled = false,
    this.fridayNotification = true,
    this.ramadanNotifications = true,
    this.sahurReminderMinutes = 45,
    this.iftarReminderMinutes = 15,
    this.dailyContentEnabled = false,
    this.dailyContentHour = 8,
    this.dailyContentMinute = 30,
    this.zikirReminderEnabled = false,
    this.zikirReminderHour = 20,
    this.zikirReminderMinute = 0,
    this.hatimReminderEnabled = false,
    this.hatimReminderHour = 21,
    this.hatimReminderMinute = 0,
    this.inAppAdhanEnabled = true,
    this.daysToSchedule = 7,
  });

  final bool enabled;
  final Map<Prayer, bool> prayerEnabled;

  /// Vakitten kaç dakika önce hatırlatma (0 = kapalı).
  final int preReminderMinutes;
  final AdhanSound adhanSound;
  final double adhanVolume;
  final bool vibrationEnabled;

  /// Sessiz mod: belirtilen aralıkta bildirim sesi çalınmaz (sessiz gösterim).
  final bool quietHoursEnabled;
  final int quietHoursStartMinutes;
  final int quietHoursEndMinutes;
  final bool sleepModeEnabled;

  final bool fridayNotification;
  final bool ramadanNotifications;
  final int sahurReminderMinutes;
  final int iftarReminderMinutes;

  final bool dailyContentEnabled;
  final int dailyContentHour;
  final int dailyContentMinute;

  final bool zikirReminderEnabled;
  final int zikirReminderHour;
  final int zikirReminderMinute;

  final bool hatimReminderEnabled;
  final int hatimReminderHour;
  final int hatimReminderMinute;

  /// Uygulama açıkken ezan sesini çal.
  final bool inAppAdhanEnabled;

  /// Kaç günlük bildirim zamanlanacak (pil/limit dengesi).
  final int daysToSchedule;

  bool isEnabledFor(Prayer prayer) =>
      enabled && (prayerEnabled[prayer] ?? false);

  /// Verilen dakika sessiz saat aralığında mı?
  bool isInQuietHours(int minutesOfDay) {
    if (!quietHoursEnabled && !sleepModeEnabled) return false;
    final int start = sleepModeEnabled ? 22 * 60 : quietHoursStartMinutes;
    final int end = sleepModeEnabled ? 7 * 60 : quietHoursEndMinutes;
    if (start == end) return false;
    if (start < end) return minutesOfDay >= start && minutesOfDay < end;
    return minutesOfDay >= start || minutesOfDay < end;
  }

  NotificationSettings copyWith({
    bool? enabled,
    Map<Prayer, bool>? prayerEnabled,
    int? preReminderMinutes,
    AdhanSound? adhanSound,
    double? adhanVolume,
    bool? vibrationEnabled,
    bool? quietHoursEnabled,
    int? quietHoursStartMinutes,
    int? quietHoursEndMinutes,
    bool? sleepModeEnabled,
    bool? fridayNotification,
    bool? ramadanNotifications,
    int? sahurReminderMinutes,
    int? iftarReminderMinutes,
    bool? dailyContentEnabled,
    int? dailyContentHour,
    int? dailyContentMinute,
    bool? zikirReminderEnabled,
    int? zikirReminderHour,
    int? zikirReminderMinute,
    bool? hatimReminderEnabled,
    int? hatimReminderHour,
    int? hatimReminderMinute,
    bool? inAppAdhanEnabled,
    int? daysToSchedule,
  }) => NotificationSettings(
    enabled: enabled ?? this.enabled,
    prayerEnabled: prayerEnabled ?? this.prayerEnabled,
    preReminderMinutes: preReminderMinutes ?? this.preReminderMinutes,
    adhanSound: adhanSound ?? this.adhanSound,
    adhanVolume: adhanVolume ?? this.adhanVolume,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietHoursStartMinutes:
        quietHoursStartMinutes ?? this.quietHoursStartMinutes,
    quietHoursEndMinutes: quietHoursEndMinutes ?? this.quietHoursEndMinutes,
    sleepModeEnabled: sleepModeEnabled ?? this.sleepModeEnabled,
    fridayNotification: fridayNotification ?? this.fridayNotification,
    ramadanNotifications: ramadanNotifications ?? this.ramadanNotifications,
    sahurReminderMinutes: sahurReminderMinutes ?? this.sahurReminderMinutes,
    iftarReminderMinutes: iftarReminderMinutes ?? this.iftarReminderMinutes,
    dailyContentEnabled: dailyContentEnabled ?? this.dailyContentEnabled,
    dailyContentHour: dailyContentHour ?? this.dailyContentHour,
    dailyContentMinute: dailyContentMinute ?? this.dailyContentMinute,
    zikirReminderEnabled: zikirReminderEnabled ?? this.zikirReminderEnabled,
    zikirReminderHour: zikirReminderHour ?? this.zikirReminderHour,
    zikirReminderMinute: zikirReminderMinute ?? this.zikirReminderMinute,
    hatimReminderEnabled: hatimReminderEnabled ?? this.hatimReminderEnabled,
    hatimReminderHour: hatimReminderHour ?? this.hatimReminderHour,
    hatimReminderMinute: hatimReminderMinute ?? this.hatimReminderMinute,
    inAppAdhanEnabled: inAppAdhanEnabled ?? this.inAppAdhanEnabled,
    daysToSchedule: daysToSchedule ?? this.daysToSchedule,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'enabled': enabled,
    'prayerEnabled': <String, bool>{
      for (final MapEntry<Prayer, bool> e in prayerEnabled.entries)
        e.key.key: e.value,
    },
    'preReminderMinutes': preReminderMinutes,
    'adhanSound': adhanSound.name,
    'adhanVolume': adhanVolume,
    'vibrationEnabled': vibrationEnabled,
    'quietHoursEnabled': quietHoursEnabled,
    'quietHoursStartMinutes': quietHoursStartMinutes,
    'quietHoursEndMinutes': quietHoursEndMinutes,
    'sleepModeEnabled': sleepModeEnabled,
    'fridayNotification': fridayNotification,
    'ramadanNotifications': ramadanNotifications,
    'sahurReminderMinutes': sahurReminderMinutes,
    'iftarReminderMinutes': iftarReminderMinutes,
    'dailyContentEnabled': dailyContentEnabled,
    'dailyContentHour': dailyContentHour,
    'dailyContentMinute': dailyContentMinute,
    'zikirReminderEnabled': zikirReminderEnabled,
    'zikirReminderHour': zikirReminderHour,
    'zikirReminderMinute': zikirReminderMinute,
    'hatimReminderEnabled': hatimReminderEnabled,
    'hatimReminderHour': hatimReminderHour,
    'hatimReminderMinute': hatimReminderMinute,
    'inAppAdhanEnabled': inAppAdhanEnabled,
    'daysToSchedule': daysToSchedule,
  };

  factory NotificationSettings.fromJson(Map<String, Object?>? json) {
    if (json == null) return const NotificationSettings();
    final Map<String, Object?> prayers =
        (json['prayerEnabled'] as Map?)?.cast<String, Object?>() ??
        <String, Object?>{};
    int intOr(String key, int fallback) =>
        (json[key] as num?)?.toInt() ?? fallback;
    bool boolOr(String key, bool fallback) => json[key] as bool? ?? fallback;
    return NotificationSettings(
      enabled: boolOr('enabled', true),
      prayerEnabled: <Prayer, bool>{
        for (final Prayer p in Prayer.values)
          p: prayers[p.key] as bool? ?? (p != Prayer.gunes),
      },
      preReminderMinutes: intOr('preReminderMinutes', 0),
      adhanSound: AdhanSound.fromName(json['adhanSound'] as String?),
      adhanVolume: (json['adhanVolume'] as num?)?.toDouble() ?? 0.8,
      vibrationEnabled: boolOr('vibrationEnabled', true),
      quietHoursEnabled: boolOr('quietHoursEnabled', false),
      quietHoursStartMinutes: intOr('quietHoursStartMinutes', 23 * 60),
      quietHoursEndMinutes: intOr('quietHoursEndMinutes', 6 * 60),
      sleepModeEnabled: boolOr('sleepModeEnabled', false),
      fridayNotification: boolOr('fridayNotification', true),
      ramadanNotifications: boolOr('ramadanNotifications', true),
      sahurReminderMinutes: intOr('sahurReminderMinutes', 45),
      iftarReminderMinutes: intOr('iftarReminderMinutes', 15),
      dailyContentEnabled: boolOr('dailyContentEnabled', false),
      dailyContentHour: intOr('dailyContentHour', 8),
      dailyContentMinute: intOr('dailyContentMinute', 30),
      zikirReminderEnabled: boolOr('zikirReminderEnabled', false),
      zikirReminderHour: intOr('zikirReminderHour', 20),
      zikirReminderMinute: intOr('zikirReminderMinute', 0),
      hatimReminderEnabled: boolOr('hatimReminderEnabled', false),
      hatimReminderHour: intOr('hatimReminderHour', 21),
      hatimReminderMinute: intOr('hatimReminderMinute', 0),
      inAppAdhanEnabled: boolOr('inAppAdhanEnabled', true),
      daysToSchedule: intOr('daysToSchedule', 7),
    );
  }
}

/// Uygulama ayarlarının tamamı.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.localeCode = 'tr',
    this.calculationMethodId = 'diyanet',
    this.asrHanafi = false,
    this.manualOffsets = const <String, int>{},
    this.use24Hour = true,
    this.hijriOffsetDays = 0,
    this.quranFontSize = 28,
    this.quranShowTranslation = true,
    this.quranShowTransliteration = false,
    this.quranReciterId = 'ar.alafasy',
    this.quranAutoScroll = true,
    this.keepScreenOnWhileReading = false,
    this.zikirVibrationEnabled = true,
    this.zikirSoundEnabled = true,
    this.zikirAutoAdvance = false,
    this.zikirDefaultTarget = 33,
    this.notifications = const NotificationSettings(),
    this.lastHatimTarget = 1,
    this.hatimAutoAdvance = true,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.streamingOnlyOnWifi = false,
    this.adhanPlaybackDucking = true,
  });

  final AppThemeMode themeMode;
  final String localeCode;

  /// Seçili hesaplama yöntemi kimliği (bkz. CalculationMethod.all).
  final String calculationMethodId;

  /// Hanefî ikindi (asr-ı sânî) tercihi — yöntem varsayılanını geçersiz kılar.
  final bool asrHanafi;

  /// Vakit bazlı manuel düzeltmeler (dakika).
  final Map<String, int> manualOffsets;

  final bool use24Hour;

  /// Hicri tarih kaydırması (-2..+2 gün).
  final int hijriOffsetDays;

  // Kur'an okuma tercihleri
  final double quranFontSize;
  final bool quranShowTranslation;
  final bool quranShowTransliteration;
  final String quranReciterId;
  final bool quranAutoScroll;
  final bool keepScreenOnWhileReading;

  // Tesbih tercihleri
  final bool zikirVibrationEnabled;
  final bool zikirSoundEnabled;
  final bool zikirAutoAdvance;
  final int zikirDefaultTarget;

  final NotificationSettings notifications;

  // Ramazan
  final int lastHatimTarget;
  final bool hatimAutoAdvance;

  // Gizlilik / veri
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool streamingOnlyOnWifi;
  final bool adhanPlaybackDucking;

  /// Tercihlerden okur.
  factory AppSettings.fromPrefs(Map<String, Object?> prefs) {
    int intOr(String key, int fallback) =>
        (prefs[key] as num?)?.toInt() ?? fallback;
    double doubleOr(String key, double fallback) =>
        (prefs[key] as num?)?.toDouble() ?? fallback;
    bool boolOr(String key, bool fallback) => prefs[key] as bool? ?? fallback;
    final Map<String, Object?>? offsets =
        prefs['manualOffsets'] as Map<String, Object?>?;
    final Map<String, Object?>? notif =
        prefs['notifications'] as Map<String, Object?>?;
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (AppThemeMode m) => m.name == prefs['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      localeCode: prefs['localeCode'] as String? ?? 'tr',
      calculationMethodId: prefs['calculationMethodId'] as String? ?? 'diyanet',
      asrHanafi: boolOr('asrHanafi', false),
      manualOffsets: offsets == null
          ? const <String, int>{}
          : <String, int>{
              for (final MapEntry<String, Object?> e in offsets.entries)
                e.key: (e.value as num).toInt(),
            },
      use24Hour: boolOr('use24Hour', true),
      hijriOffsetDays: intOr('hijriOffsetDays', 0),
      quranFontSize: doubleOr('quranFontSize', 28),
      quranShowTranslation: boolOr('quranShowTranslation', true),
      quranShowTransliteration: boolOr('quranShowTransliteration', false),
      quranReciterId: prefs['quranReciterId'] as String? ?? 'ar.alafasy',
      quranAutoScroll: boolOr('quranAutoScroll', true),
      keepScreenOnWhileReading: boolOr('keepScreenOnWhileReading', false),
      zikirVibrationEnabled: boolOr('zikirVibrationEnabled', true),
      zikirSoundEnabled: boolOr('zikirSoundEnabled', true),
      zikirAutoAdvance: boolOr('zikirAutoAdvance', false),
      zikirDefaultTarget: intOr('zikirDefaultTarget', 33),
      notifications: NotificationSettings.fromJson(notif),
      lastHatimTarget: intOr('lastHatimTarget', 1),
      hatimAutoAdvance: boolOr('hatimAutoAdvance', true),
      analyticsEnabled: boolOr('analyticsEnabled', true),
      crashReportingEnabled: boolOr('crashReportingEnabled', true),
      streamingOnlyOnWifi: boolOr('streamingOnlyOnWifi', false),
      adhanPlaybackDucking: boolOr('adhanPlaybackDucking', true),
    );
  }

  Map<String, Object?> toPrefs() => <String, Object?>{
    'themeMode': themeMode.name,
    'localeCode': localeCode,
    'calculationMethodId': calculationMethodId,
    'asrHanafi': asrHanafi,
    'manualOffsets': manualOffsets,
    'use24Hour': use24Hour,
    'hijriOffsetDays': hijriOffsetDays,
    'quranFontSize': quranFontSize,
    'quranShowTranslation': quranShowTranslation,
    'quranShowTransliteration': quranShowTransliteration,
    'quranReciterId': quranReciterId,
    'quranAutoScroll': quranAutoScroll,
    'keepScreenOnWhileReading': keepScreenOnWhileReading,
    'zikirVibrationEnabled': zikirVibrationEnabled,
    'zikirSoundEnabled': zikirSoundEnabled,
    'zikirAutoAdvance': zikirAutoAdvance,
    'zikirDefaultTarget': zikirDefaultTarget,
    'notifications': notifications.toJson(),
    'lastHatimTarget': lastHatimTarget,
    'hatimAutoAdvance': hatimAutoAdvance,
    'analyticsEnabled': analyticsEnabled,
    'crashReportingEnabled': crashReportingEnabled,
    'streamingOnlyOnWifi': streamingOnlyOnWifi,
    'adhanPlaybackDucking': adhanPlaybackDucking,
  };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? localeCode,
    String? calculationMethodId,
    bool? asrHanafi,
    Map<String, int>? manualOffsets,
    bool? use24Hour,
    int? hijriOffsetDays,
    double? quranFontSize,
    bool? quranShowTranslation,
    bool? quranShowTransliteration,
    String? quranReciterId,
    bool? quranAutoScroll,
    bool? keepScreenOnWhileReading,
    bool? zikirVibrationEnabled,
    bool? zikirSoundEnabled,
    bool? zikirAutoAdvance,
    int? zikirDefaultTarget,
    NotificationSettings? notifications,
    int? lastHatimTarget,
    bool? hatimAutoAdvance,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? streamingOnlyOnWifi,
    bool? adhanPlaybackDucking,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    localeCode: localeCode ?? this.localeCode,
    calculationMethodId: calculationMethodId ?? this.calculationMethodId,
    asrHanafi: asrHanafi ?? this.asrHanafi,
    manualOffsets: manualOffsets ?? this.manualOffsets,
    use24Hour: use24Hour ?? this.use24Hour,
    hijriOffsetDays: hijriOffsetDays ?? this.hijriOffsetDays,
    quranFontSize: quranFontSize ?? this.quranFontSize,
    quranShowTranslation: quranShowTranslation ?? this.quranShowTranslation,
    quranShowTransliteration:
        quranShowTransliteration ?? this.quranShowTransliteration,
    quranReciterId: quranReciterId ?? this.quranReciterId,
    quranAutoScroll: quranAutoScroll ?? this.quranAutoScroll,
    keepScreenOnWhileReading:
        keepScreenOnWhileReading ?? this.keepScreenOnWhileReading,
    zikirVibrationEnabled: zikirVibrationEnabled ?? this.zikirVibrationEnabled,
    zikirSoundEnabled: zikirSoundEnabled ?? this.zikirSoundEnabled,
    zikirAutoAdvance: zikirAutoAdvance ?? this.zikirAutoAdvance,
    zikirDefaultTarget: zikirDefaultTarget ?? this.zikirDefaultTarget,
    notifications: notifications ?? this.notifications,
    lastHatimTarget: lastHatimTarget ?? this.lastHatimTarget,
    hatimAutoAdvance: hatimAutoAdvance ?? this.hatimAutoAdvance,
    analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
    streamingOnlyOnWifi: streamingOnlyOnWifi ?? this.streamingOnlyOnWifi,
    adhanPlaybackDucking: adhanPlaybackDucking ?? this.adhanPlaybackDucking,
  );

  /// Ayar dışa/içe aktarma (bulut senkronizasyonu ve yedekleme için).
  String exportJson() => jsonEncode(toPrefs());

  static AppSettings importJson(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return const AppSettings();
      return AppSettings.fromPrefs(decoded.cast<String, Object?>());
    } catch (error) {
      // Bozuk/eksik yedek: kullanıcıya hata göstermek yerine varsayılanlar.
      AppLog.warning('Ayarlar içe aktarılamadı: $error');
      return const AppSettings();
    }
  }

  /// Seçili yönteme kullanıcı tercihlerini uygular:
  /// * Hanefî ikindi (asr-ı sânî) yalnızca ilgili yöntemlerde geçersiz kılınır.
  /// * Vakit bazlı manuel düzeltmeler hesap motoruna aktarılır.
  CalculationMethod resolvedMethod(CalculationMethod base) {
    if (!_asrOverridable.contains(base.id) && manualOffsets.isEmpty) {
      return base;
    }
    return base.copyWith(
      asrFactor: asrHanafi && _asrOverridable.contains(base.id)
          ? 2.0
          : base.asrFactor,
      manualOffsets: manualOffsets,
    );
  }

  static const Set<String> _asrOverridable = <String>{
    'diyanet',
    'mwl',
    'isna',
    'egypt',
    'umm_al_qura',
    'france',
    'russia',
  };
}
