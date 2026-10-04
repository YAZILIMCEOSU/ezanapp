/// Uygulama geneli sabitler.
abstract final class AppConstants {
  static const String appName = 'EzanAI';
  static const String tagline = 'Akıllı İslam Asistanı';
  static const String supportEmail = 'destek@ezanai.app';
  static const String privacyUrl = 'https://ezanai.app/gizlilik';
  static const String termsUrl = 'https://ezanai.app/kullanim-kosullari';
  static const String websiteUrl = 'https://ezanai.app';

  /// Mekke — Kâbe koordinatları.
  static const double kaabaLat = 21.4224779;
  static const double kaabaLng = 39.8251832;

  /// Gece yarısından sonraki vakitler bir sonraki güne aittir.
  static const int citySearchLimit = 40;

  /// Vakit hesaplama varsayılanı.
  static const double defaultLatitude = 41.0082;
  static const double defaultLongitude = 28.9784;
  static const String defaultCity = 'İstanbul';

  /// Önbellek süreleri.
  static const Duration prayerTimesTtl = Duration(hours: 6);
  static const Duration remoteCatalogTtl = Duration(days: 3);
  static const Duration dailyContentTtl = Duration(hours: 12);

  /// AI asistan sınırları.
  static const int freeAiDailyMessages = 8;
  static const int premiumAiDailyMessages = 500;
  static const int aiHistoryLimit = 60;
}

/// Desteklenen diller ve mealler (genişletilebilir).
abstract final class QuranTranslation {
  static const String turkish = 'tr';
  static const Map<String, String> labels = <String, String>{turkish: 'Türkçe'};
}

/// Bildirim kanal kimlikleri.
abstract final class NotificationChannels {
  static const String prayer = 'ezanai_prayer_times';
  static const String adhan = 'ezanai_adhan';
  static const String ramadan = 'ezanai_ramadan';
  static const String daily = 'ezanai_daily_content';
  static const String zikir = 'ezanai_zikir';
  static const String system = 'ezanai_system';
}

/// Tercihlerde kullanılan anahtarlar (shared_preferences).
abstract final class PrefKeys {
  static const String onboardingDone = 'onboarding_done';
  static const String themeMode = 'theme_mode';
  static const String locationMode = 'location_mode';
  static const String selectedCityId = 'selected_city_id';
  static const String selectedCityName = 'selected_city_name';
  static const String selectedCityLat = 'selected_city_lat';
  static const String selectedCityLon = 'selected_city_lon';
  static const String selectedCityTimezone = 'selected_city_tz';
  static const String calculationMethod = 'calculation_method';
  static const String asrMethod = 'asr_method';
  static const String manualOffset = 'manual_offset';
  static const String use24Hour = 'use_24_hour';
  static const String hijriOffset = 'hijri_offset';
  static const String turkishLocale = 'turkish_locale';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String perPrayerNotifications = 'per_prayer_notifications';
  static const String preReminderMinutes = 'pre_reminder_minutes';
  static const String adhanSound = 'adhan_sound';
  static const String adhanVolume = 'adhan_volume';
  static const String quietHoursEnabled = 'quiet_hours_enabled';
  static const String quietHoursStart = 'quiet_hours_start';
  static const String quietHoursEnd = 'quiet_hours_end';
  static const String fridayNotification = 'friday_notification';
  static const String ramadanNotifications = 'ramadan_notifications';
  static const String dailyContentNotification = 'daily_content_notification';
  static const String dailyContentTime = 'daily_content_time';
  static const String zikirReminder = 'zikir_reminder';
  static const String hatimReminder = 'hatim_reminder';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String quranFontSize = 'quran_font_size';
  static const String quranShowTranslation = 'quran_show_translation';
  static const String quranShowTransliteration = 'quran_show_transliteration';
  static const String lastReadSurah = 'last_read_surah';
  static const String lastReadAyah = 'last_read_ayah';
  static const String sleepMode = 'sleep_mode';
  static const String lastSuccessfulTimesJson = 'last_times_json';
  static const String lastTimesFetchedAt = 'last_times_fetched_at';
  static const String hatimTarget = 'hatim_target';
  static const String kazaFasts = 'kaza_fasts';
  static const String premiumCache = 'premium_cache';
  static const String aiDailyUsage = 'ai_daily_usage';
  static const String akikaReminder = 'akika_reminder';
}
