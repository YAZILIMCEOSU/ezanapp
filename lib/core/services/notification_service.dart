import 'dart:async';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/app_settings.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Bildirim yönlendirme hedefi (bildirime dokunulduğunda).
enum NotificationRoute {
  home('home'),
  times('times'),
  quran('quran'),
  ramadan('ramadan'),
  zikir('zikir'),
  hadith('hadith'),
  dua('dua'),
  adhan('adhan');

  const NotificationRoute(this.value);

  final String value;

  static NotificationRoute fromPayload(String? payload) {
    if (payload == null) return NotificationRoute.home;
    for (final NotificationRoute route in NotificationRoute.values) {
      if (payload.startsWith(route.value)) return route;
    }
    return NotificationRoute.home;
  }
}

/// Bildirim kimliği üretici — aynı bildirimin üzerine yazılmasını engeller.
abstract final class NotificationIds {
  static const int baseAdhan = 1000;
  static const int preReminder = 2000;
  static const int friday = 3001;
  static const int ramadanSahur = 3002;
  static const int ramadanIftar = 3003;
  static const int dailyVerse = 3004;
  static const int dailyHadith = 3005;
  static const int zikirReminder = 3006;
  static const int hatimReminder = 3007;
  static const int test = 3008;
  static const int abdestSukur = 3009;
  static const int baseNafile = 4000;

  static int adhan(int dayIndex, Prayer prayer) =>
      baseAdhan + dayIndex * 10 + prayer.index;

  static int pre(int dayIndex, Prayer prayer) =>
      preReminder + dayIndex * 10 + prayer.index;

  static int nafile(int dayIndex, int slot) =>
      baseNafile + dayIndex * 10 + slot;

  /// İptal edilen gün sayısı.
  ///
  /// Planlama ufku 15 gündür (`NotificationCoordinator.scheduleHorizonDays`);
  /// kullanıcı ayarı düşürdüğünde eski günlerin alarmları kalmasın diye
  /// iptal aralığı ufkun üzerinde tutulur.
  static const int maxCancelDays = 20;
}

/// Android'in hangi zamanlama modunu kabul ettiği.
enum NotificationScheduleMode {
  alarmClock('alarmClock'),
  exact('exact'),
  inexact('inexact'),
  skipped('skipped'),
  failed('failed');

  const NotificationScheduleMode(this.value);

  final String value;

  bool get delivered => this == alarmClock || this == exact || this == inexact;
}

/// Bir zamanlama turunun sonucu.
class NotificationScheduleReport {
  const NotificationScheduleReport({
    this.scheduled = 0,
    this.failed = 0,
    this.inexact = 0,
    this.error,
  });

  final int scheduled;
  final int failed;
  final int inexact;
  final String? error;

  bool get ok => failed == 0;
}

/// Test bildiriminin kurulum sonucu.
class NotificationTestResult {
  const NotificationTestResult({
    required this.scheduled,
    required this.mode,
    this.pending = 0,
    this.error,
  });

  final bool scheduled;
  final NotificationScheduleMode mode;
  final int pending;
  final String? error;
}

/// Bildirim görünürlüğünü etkileyen tüm sistem durumları.
///
/// "Bildirim çubukta hiç çıkmıyor" şikâyetinde sorun tek bir yerde değil,
/// zincirin herhangi bir halkasında olabilir: uygulama başlatılamamış,
/// bildirim izni verilmemiş veya kanal kullanıcı tarafından kapatılmış.
/// Bu sınıf üçünü birlikte raporlar.
class NotificationHealth {
  const NotificationHealth({
    this.supported = true,
    this.ready = true,
    this.appNotificationsEnabled = true,
    this.channelImportance = -1,
    this.exactAlarmsAvailable = true,
    this.pendingCount = 0,
    this.error,
  });

  /// Android dışı ortam (test/masaüstü): uyarı gösterilmez.
  static const NotificationHealth notApplicable = NotificationHealth(
    supported: false,
  );

  final bool supported;
  final bool ready;
  final bool appNotificationsEnabled;

  /// 0 = kanal kullanıcı tarafından kapatılmış, -1 = bilinmiyor.
  final int channelImportance;
  final bool exactAlarmsAvailable;
  final int pendingCount;
  final String? error;

  bool get channelBlocked => channelImportance == 0;

  /// Sistem bildirimi hiç görünmeyecek mi?
  bool get blocked =>
      supported && (!ready || !appNotificationsEnabled || channelBlocked);
}

/// Ezan, vakit, Ramazan ve içerik bildirimlerini yönetir.
///
/// Tüm zamanlamalar `timezone` paketiyle yerel saat dilimine göre yapılır;
/// cihaz yeniden başlatıldığında Android tarafındaki boot receiver
/// zamanlamaları geri yükler.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _timeZoneReady = false;
  bool _initializationFailed = false;
  String? _lastError;

  /// Bildirimlerde kullanılan küçük simge.
  ///
  /// Android küçük simgesi **drawable** olmalıdır. `@mipmap/ic_launcher`
  /// (eski değer) bazı cihaz/derlemelerde `invalid_icon` hatası veriyor ve
  /// bu hata bütün bildirim sistemini sessizce durduruyordu.
  static const String notificationIcon = 'ic_stat_ezan';
  static const String _fallbackIcon = '@mipmap/ic_launcher';

  /// Bildirim servisi hazır mı? (Simge/kanal hatası tanılamada görünür.)
  bool get ready => _initialized && !_initializationFailed;

  /// Son başlatma/zamanlama hatası (kullanıcıya ham hata gösterilmez).
  String? get lastError => _lastError;

  /// Kullanıcı bildirime dokunduğunda çağrılır.
  final StreamController<NotificationRoute> _routeController =
      StreamController<NotificationRoute>.broadcast();
  Stream<NotificationRoute> get onRoute => _routeController.stream;

  /// Şu anda gösterilen ezan bildirimi (uygulama içi ezan sesi için).
  final StreamController<Prayer> _adhanController =
      StreamController<Prayer>.broadcast();
  Stream<Prayer> get onAdhanNow => _adhanController.stream;

  /// Başlatma sürüyorsa ikinci bir tur başlatılmaz.
  ///
  /// Açılışta `_warmUp` ile ana ekranın ilk karesi neredeyse aynı anda
  /// `initialize()` çağırıyor; iki paralel başlatma kanal oluşturma ve simge
  /// denemelerini birbirine karıştırabiliyordu.
  Future<void>? _initializing;

  /// Başarısız başlatma denemelerinin sayısı.
  ///
  /// **Düzeltme:** Önceden başlatma bir kez başarısız olduğunda
  /// `_initialized = true` kalıyor ve oturum boyunca bir daha **hiç
  /// denenmiyordu**; geçici bir eklenti hatası (açılışta motor henüz hazır
  /// değilken) bütün bildirimleri kalıcı olarak susturuyordu. Artık en fazla
  /// üç kez yeniden denenir; kullanıcı "Test bildirimi"ne bastığında da
  /// başlatma yeniden çalışır.
  static const int _maxInitializeAttempts = 3;
  int _initializeAttempts = 0;

  Future<void> initialize() {
    if (_initialized && !_initializationFailed) return Future<void>.value();
    if (_initializationFailed &&
        _initializeAttempts >= _maxInitializeAttempts) {
      return Future<void>.value();
    }
    return _initializing ??= _initializeOnce().whenComplete(() {
      _initializing = null;
    });
  }

  Future<void> _initializeOnce() async {
    _initializeAttempts++;
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _prepareTimeZone();

    // Küçük simge bulunamazsa (R8 kaynak budaması, üretici ROM'u) yedek
    // simgeyle tekrar denenir. İki deneme de başarısız olursa hata
    // **yutulmaz**: `NotificationHealth.ready == false` olarak raporlanır ve
    // ana ekranda görünür.
    _initializationFailed = false;
    _lastError = null;
    for (final String icon in <String>[notificationIcon, _fallbackIcon]) {
      try {
        await _plugin.initialize(
          settings: InitializationSettings(
            android: AndroidInitializationSettings(icon),
            iOS: ios,
          ),
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            final String? payload = response.payload;
            _routeController.add(NotificationRoute.fromPayload(payload));
          },
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
        );
        _lastError = null;
        break;
      } catch (error) {
        _lastError = '$error';
        AppLog.warning('Bildirim başlatılamadı (simge: $icon)', error: error);
      }
    }
    _initializationFailed = _lastError != null;

    if (Platform.isAndroid) {
      try {
        await _createAndroidChannels();
      } catch (error) {
        AppLog.warning('Bildirim kanalları oluşturulamadı', error: error);
      }
      await refreshExactAlarmStatus();
    }
    _initialized = true;
    AppLog.debug(
      'Bildirim servisi hazır (tz: ${tz.local.name}, '
      'kesin alarm: $_exactAlarmsAvailable, simge: '
      '${_initializationFailed ? 'HATA' : notificationIcon})',
    );
  }

  Duration? _resolvedOffset;

  /// Cihazın yerel saat dilimini çözer.
  ///
  /// **Düzeltme:** Önceden yalnızca açılışta bir kez çözülüyordu. Yaz saati
  /// uygulamasına geçen bölgelerde veya uçakla başka saat dilimine
  /// gidildiğinde `tz.local` eski kaydırmada kalıyor ve kurulan alarmlar
  /// **bir saat** kayıyordu. Artık kaydırma değiştiğinde yeniden çözülür ve
  /// her zamanlama turundan önce çağrılır.
  Future<void> refreshTimeZone() async {
    final Duration offset = DateTime.now().timeZoneOffset;
    if (_timeZoneReady && _resolvedOffset == offset) return;
    _ensureTimeZoneData();
    final String resolved = resolveLocationName(
      await _deviceTimeZoneName(),
      offset,
    );
    try {
      tz.setLocalLocation(tz.getLocation(resolved));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    _resolvedOffset = offset;
    _timeZoneReady = true;
  }

  /// Cihazın IANA saat dilimi adını (ör. `Europe/Istanbul`) okur.
  ///
  /// Android tarafı `java.util.TimeZone.getDefault().id` döndürür. Bu ad,
  /// yalnızca kaydırmadan türetilen tahmini bölgeden **daha güvenlidir**:
  /// Berlin'de kışın +1 olan kaydırma, kaydırma listesinde Londra ile de
  /// eşleşebilir ve yaz saati geçişinden sonra günlük/haftalık hatırlatmalar
  /// bir saat kayabilirdi.
  Future<String?> _deviceTimeZoneName() async {
    if (!Platform.isAndroid) return null;
    try {
      final String? name = await _platform.invokeMethod<String>('timeZone');
      final String? trimmed = name?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

  static bool _timeZoneDataReady = false;

  static void _ensureTimeZoneData() {
    if (_timeZoneDataReady) return;
    tzdata.initializeTimeZones();
    _timeZoneDataReady = true;
  }

  Future<void> _prepareTimeZone() => refreshTimeZone();

  /// Cihaz kaydırmasına karşılık gelen bölge adını çözer.
  ///
  /// Sıra: cihazın IANA adı → yaygın bölge listesi → **tam kaydırma eşleşen
  /// herhangi bir bölge** → `Etc/GMT±N`.
  ///
  /// Son adımda tam eşleşme aranması yarım saatlik dilimlerde (±5:30, +3:30,
  /// −3:30 …) eski `~/ 60` kısaltmasının oluşturduğu 30 dakikalık kaymayı
  /// önler; `Etc/GMT` yalnızca tam saatleri desteklediği için son çare kalır.
  @visibleForTesting
  static String resolveLocationName(String? deviceZone, Duration offset) {
    _ensureTimeZoneData();
    final String? candidate = deviceZone?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      try {
        if (tz.getLocation(candidate).currentTimeZone.offset == offset) {
          return candidate;
        }
      } catch (_) {
        // Bilinmeyen bölge adı: kaydırma tabanlı çözüme düş.
      }
    }
    for (final String name in _preferredZones) {
      try {
        if (tz.getLocation(name).currentTimeZone.offset == offset) return name;
      } catch (_) {
        continue;
      }
    }
    String? etcFallback;
    for (final tz.Location location in tz.timeZoneDatabase.locations.values) {
      if (location.currentTimeZone.offset != offset) continue;
      final String name = location.name;
      if (name == 'UTC' || name.startsWith('Etc/')) {
        etcFallback ??= name;
        continue;
      }
      return name;
    }
    if (etcFallback != null) return etcFallback;
    final int hours = offset.inMinutes ~/ 60;
    if (hours == 0) return 'UTC';
    // Etc bölgelerinde işaret terstir: UTC+3 → Etc/GMT-3
    return 'Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}';
  }

  static const List<String> _preferredZones = <String>[
    'Europe/Istanbul',
    'Europe/London',
    'Europe/Berlin',
    'Europe/Paris',
    'Europe/Moscow',
    'Asia/Riyadh',
    'Asia/Dubai',
    'Asia/Karachi',
    'Asia/Kolkata',
    'Asia/Jakarta',
    'Asia/Kuala_Lumpur',
    'Africa/Cairo',
    'Africa/Casablanca',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Australia/Sydney',
    'UTC',
  ];

  static String adhanChannelId(AdhanSound sound) {
    if (sound.isSilent) return NotificationChannels.prayer;
    if (sound == AdhanSound.systemDefault) {
      return '${NotificationChannels.adhan}_v5_system_default';
    }
    return '${NotificationChannels.adhan}_v4_${sound.name}';
  }

  static AndroidNotificationSound? _rawSoundFor(AdhanSound sound) {
    if (sound.isSilent || sound == AdhanSound.systemDefault) return null;
    if (sound == AdhanSound.downloaded) {
      return const RawResourceAndroidNotificationSound('ezan_melodi');
    }
    final String? res = sound.resource;
    if (res == null || res == 'system') return null;
    return RawResourceAndroidNotificationSound(res);
  }

  Future<void> _createAndroidChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    // Eski kanalları temizle; paralel çalışarak açılış süresini geciktirmez.
    final List<Future<void>> cleanups = <Future<void>>[];
    for (final AdhanSound sound in AdhanSound.values) {
      cleanups.add(
        android
            .deleteNotificationChannel(
              channelId: '${NotificationChannels.adhan}_${sound.name}',
            )
            .catchError((_) {}),
      );
      cleanups.add(
        android
            .deleteNotificationChannel(
              channelId: '${NotificationChannels.adhan}_v2_${sound.name}',
            )
            .catchError((_) {}),
      );
      cleanups.add(
        android
            .deleteNotificationChannel(
              channelId: '${NotificationChannels.adhan}_v3_${sound.name}',
            )
            .catchError((_) {}),
      );
    }
    cleanups.add(
      android
          .deleteNotificationChannel(
            channelId:
                '${NotificationChannels.adhan}_v4_${AdhanSound.systemDefault.name}',
          )
          .catchError((_) {}),
    );
    await Future.wait(cleanups);

    Future<void> channel(
      String id,
      String name,
      String description, {
      bool silent = false,
      bool useNotificationStream = false,
      AndroidNotificationSound? customSound,
    }) async {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          id,
          name,
          description: description,
          importance: silent ? Importance.low : Importance.max,
          playSound: !silent,
          sound: silent ? null : customSound,
          enableVibration: !silent,
          audioAttributesUsage: (silent || useNotificationStream)
              ? AudioAttributesUsage.notification
              : AudioAttributesUsage.alarm,
        ),
      );
    }

    final List<Future<void>> creations = <Future<void>>[
      channel(
        NotificationChannels.adhan,
        'Ezan ve vakit bildirimleri',
        'Namaz vakti girdiğinde ve ezan öncesi hatırlatmalarda gösterilir.',
        customSound: const RawResourceAndroidNotificationSound('ezan_melodi'),
      ),
      for (final AdhanSound sound in AdhanSound.values)
        if (!sound.isSilent)
          channel(
            adhanChannelId(sound),
            sound == AdhanSound.systemDefault
                ? 'Vakit bildirimi (Telefonun bildirim sesi)'
                : 'Ezan bildirimi (${sound.label})',
            sound.description,
            useNotificationStream: sound == AdhanSound.systemDefault,
            customSound: _rawSoundFor(sound),
          ),
      channel(
        NotificationChannels.prayer,
        'Namaz vakti hatırlatmaları',
        'Vakit girdiğinde sessiz bilgilendirme.',
        silent: true,
      ),
      channel(
        NotificationChannels.ramadan,
        'Ramazan bildirimleri',
        'Sahur ve iftar hatırlatmaları.',
        useNotificationStream: true,
      ),
      channel(
        NotificationChannels.daily,
        'Günün ayeti ve hadisi',
        'Her gün seçtiğiniz saatte günün içeriği.',
        silent: true,
      ),
      channel(
        NotificationChannels.zikir,
        'Zikir ve hatim hatırlatmaları',
        'Günlük zikir ve hatim hedefleri için nazik hatırlatmalar.',
        silent: true,
      ),
      channel(
        NotificationChannels.system,
        'Uygulama bildirimleri',
        'Güncellemeler ve önemli duyurular.',
        silent: true,
      ),
      channel(
        NotificationChannels.test,
        'Bildirim testi',
        'Bildirimlerin gerçekten ulaştığını doğrulayan deneme bildirimi.',
        useNotificationStream: true,
      ),
    ];
    await Future.wait(creations);
  }

  /// Bildirim izinlerini ister (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    await initialize();
    bool granted = true;
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      try {
        granted = await android?.requestNotificationsPermission() ?? true;
      } catch (error) {
        _lastError = '$error';
        granted = false;
      }
      try {
        await android?.requestExactAlarmsPermission();
      } catch (error) {
        AppLog.warning('Kesin alarm izni istenemedi: $error');
      }
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }
    return granted;
  }

  /// Bildirim izni verilmiş mi?
  Future<bool> hasPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      try {
        final AndroidFlutterLocalNotificationsPlugin? android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.areNotificationsEnabled() ?? true;
      } catch (error) {
        _lastError = '$error';
        return false;
      }
    }
    return true;
  }

  /// Android'de kesin alarm izni var mı? (Son okunan durum.)
  ///
  /// `false` ise vakit bildirimleri sistem tarafından **birkaç dakika
  /// kaydırılabilir**; ana ekranda uyarı gösterilir.
  bool _exactAlarmsAvailable = true;
  bool get exactAlarmsAvailable => _exactAlarmsAvailable;

  /// İzin durumunu yeniden okur (açılış, ekran açılışı ve izin dönüşü).
  ///
  /// **Dikkat:** `canScheduleExactAlarms()` kendisi `initialize()` çağırır;
  /// buradan o çağrılırsa `initialize → refresh → initialize` döngüsü oluşur.
  /// Bu yüzden platform kontrolü doğrudan yapılır, hazırlık çağrılmaz.
  Future<bool> refreshExactAlarmStatus() async {
    if (!Platform.isAndroid) {
      _exactAlarmsAvailable = true;
      return true;
    }
    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      _exactAlarmsAvailable =
          await android?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      _exactAlarmsAvailable = true;
    }
    return _exactAlarmsAvailable;
  }

  /// Android 14+ **kesin alarm** izni verilmiş mi?
  ///
  /// Android 14'ten itibaren `SCHEDULE_EXACT_ALARM` yeni kurulumlarda varsayılan
  /// olarak **kapalıdır**. İzin yoksa ezan dakikası tam tutturulamaz: sistem
  /// alarmı birkaç dakika kaydırabilir. Bu yüzden durumu ekranda gösterip
  /// kullanıcıyı tek dokunuşla izin ekranına yönlendiriyoruz.
  Future<bool> canScheduleExactAlarms() async {
    await initialize();
    if (!Platform.isAndroid) return true;
    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Kesin alarm izni ekranını açar (Android 14+ "Alarmlar ve hatırlatıcılar").
  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    } catch (error) {
      AppLog.warning('Kesin alarm izni açılamadı: $error');
    }
  }

  /// Android'in uygulama/kanal bildirim ayarlarını açan yerel köprü.
  ///
  /// `requestNotificationsPermission()` yalnızca **ilk** istekte pencere
  /// gösterir; kullanıcı bir kez reddettiyse hiçbir şey olmaz ve kullanıcı
  /// "bildirim gelmiyor" der. Bu köprü doğrudan sistem ayarını açar.
  static const MethodChannel _platform = MethodChannel('ezanai/notifications');

  /// Uygulamanın bildirim ayarlarını (veya belirli bir kanalın ayarını) açar.
  Future<bool> openNotificationSettings({String? channelId}) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? opened = await _platform.invokeMethod<bool>(
        channelId == null ? 'openSettings' : 'openChannelSettings',
        channelId == null ? null : <String, Object?>{'channelId': channelId},
      );
      if (opened == true) return true;
    } catch (error) {
      AppLog.warning('Bildirim ayarları açılamadı: $error');
    }
    // Yerel köprü yoksa son çare: izin penceresini tekrar dene.
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {}
    return false;
  }

  /// Kanalın sistemdeki önemi: 0 = kullanıcı kanalı kapatmış, -1 = bilinmiyor.
  Future<int> channelImportance(String channelId) async {
    if (!Platform.isAndroid) return -1;
    try {
      final Map<Object?, Object?>? state = await _platform
          .invokeMethod<Map<Object?, Object?>>(
            'channelState',
            <String, Object?>{'channelId': channelId},
          );
      final Object? importance = state?['importance'];
      if (importance is num) return importance.toInt();
    } catch (_) {}
    return -1;
  }

  /// Bildirim zincirinin tamamının sağlığını okur.
  ///
  /// Uygulama başlatma, bildirim izni ve kanal durumu ayrı ayrı kontrol
  /// edilir; böylece "hiç bildirim gelmiyor" sorunu tek dokunuşla
  /// düzeltilebilecek şekilde ekranda gösterilir.
  Future<NotificationHealth> checkHealth({String? channelId}) async {
    if (!Platform.isAndroid) return NotificationHealth.notApplicable;
    await initialize();
    final int pending = await pendingCount();
    final bool exact = await refreshExactAlarmStatus();
    final int importance = await channelImportance(
      channelId ?? adhanChannelId(AdhanSound.ezanMelodi),
    );
    bool enabled = false;
    try {
      enabled = await hasPermission();
    } catch (error) {
      _lastError ??= '$error';
    }
    return NotificationHealth(
      ready: !_initializationFailed,
      appNotificationsEnabled: enabled,
      channelImportance: importance,
      exactAlarmsAvailable: exact,
      pendingCount: pending,
      error: _lastError,
    );
  }

  Future<void> openSystemSettings() async {
    await openNotificationSettings();
  }

  /// Belirtilen günler için vakit bildirimlerini zamanlar.
  ///
  /// Mevcut zamanlamalar temizlenir ve yeniden kurulur; böylece konum/yöntem
  /// değiştiğinde eski bildirimler kalmaz.
  Future<int> scheduleForDays({
    required List<PrayerTimesDay> days,
    required NotificationSettings settings,
    required String locationLabel,
    int hijriOffsetDays = 0,
  }) async {
    await initialize();
    await refreshTimeZone();
    await cancelPrayerNotifications();
    if (days.isNotEmpty) {
      final DateTime first = days.first.date;
      _scheduleAnchorDate = DateTime(first.year, first.month, first.day);
    }
    _failedThisRun = 0;
    _inexactThisRun = 0;
    _lastScheduleError = null;
    _lastReport = const NotificationScheduleReport();
    if (!settings.enabled) return 0;

    int scheduled = 0;
    final DateTime now = DateTime.now();

    for (
      int dayIndex = 0;
      dayIndex < days.length && dayIndex < settings.daysToSchedule;
      dayIndex++
    ) {
      final PrayerTimesDay day = days[dayIndex];
      for (final Prayer prayer in Prayer.values) {
        if (!settings.isEnabledFor(prayer)) continue;
        final DateTime? when = day.timeOf(prayer);
        if (when == null) continue;
        final int minutesOfDay = when.hour * 60 + when.minute;
        final bool quiet = settings.isInQuietHours(minutesOfDay);

        // Ana vakit bildirimi
        if (when.isAfter(now)) {
          final AdhanSound prayerSound = quiet
              ? AdhanSound.silent
              : settings.soundFor(prayer);
          await _schedule(
            id: NotificationIds.adhan(dayIndex, prayer),
            title: _titleFor(prayer, quiet),
            body: _bodyFor(prayer, locationLabel, day),
            when: when,
            channelId: adhanChannelId(prayerSound),
            settings: settings,
            quiet: quiet || prayerSound.isSilent,
            soundOverride: prayerSound,
            payload: '${NotificationRoute.adhan.value}:${prayer.key}',
            hijriOffsetDays: hijriOffsetDays,
          );
          scheduled++;
        }

        // Öncesi hatırlatma
        if (settings.preReminderMinutes > 0 && prayer.isPrayerTime) {
          final DateTime remindAt = when.subtract(
            Duration(minutes: settings.preReminderMinutes),
          );
          if (remindAt.isAfter(now)) {
            await _schedule(
              id: NotificationIds.pre(dayIndex, prayer),
              title:
                  '${prayer.label} vaktine ${settings.preReminderMinutes} dakika',
              body: '$locationLabel için ${prayer.label} vakti yaklaşıyor.',
              when: remindAt,
              channelId: NotificationChannels.prayer,
              settings: settings,
              quiet: settings.isInQuietHours(
                remindAt.hour * 60 + remindAt.minute,
              ),
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }

      // --- Nafile ve Özel Vakitli Namaz Alarmları ---
      final AdhanSound nafileSound = settings.adhanSound;
      final String nafileChannel = adhanChannelId(nafileSound);

      // 0) İşrak Namazı Alarmı (Güneş doğduktan +47 dk sonra, kerahet çıkışı, 2 rekât)
      if (settings.israkAlarm) {
        final DateTime? gunes = day.timeOf(Prayer.gunes);
        if (gunes != null) {
          final DateTime israkTime = gunes.add(const Duration(minutes: 47));
          if (israkTime.isAfter(now)) {
            final bool quiet = settings.isInQuietHours(
              israkTime.hour * 60 + israkTime.minute,
            );
            await _schedule(
              id: NotificationIds.nafile(dayIndex, 0),
              title: 'İşrak Namazı Vakti (${_format(israkTime)})',
              body:
                  '$locationLabel • Güneş doğup kerahet vakti çıktı. 2 rekât İşrak namazı vakti girdi.',
              when: israkTime,
              channelId: nafileChannel,
              settings: settings,
              quiet: quiet || nafileSound.isSilent,
              soundOverride: nafileSound,
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }

      // 1) Kuşluk (Duha) Namazı Alarmı (Güneşten +120 dk sonra faziletli vakit, 2-8-12 rekât)
      if (settings.duhaAlarm) {
        final DateTime? gunes = day.timeOf(Prayer.gunes);
        if (gunes != null) {
          final DateTime duhaTime = gunes.add(const Duration(minutes: 120));
          if (duhaTime.isAfter(now)) {
            final bool quiet = settings.isInQuietHours(
              duhaTime.hour * 60 + duhaTime.minute,
            );
            await _schedule(
              id: NotificationIds.nafile(dayIndex, 1),
              title: 'Kuşluk (Duha) Namazı Vakti (${_format(duhaTime)})',
              body:
                  '$locationLabel • Kuşluk (Duha) namazının en faziletli vakti (2, 4, 8 veya 12 rekât).',
              when: duhaTime,
              channelId: nafileChannel,
              settings: settings,
              quiet: quiet || nafileSound.isSilent,
              soundOverride: nafileSound,
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }

      // 2) Evvâbîn Namazı Alarmı (Akşam namazından +25 dk sonra, yatsı girmeden, 2/4/6 rekât)
      if (settings.evvabinAlarm) {
        final DateTime? aksam = day.timeOf(Prayer.aksam);
        if (aksam != null) {
          final DateTime evvabinTime = aksam.add(const Duration(minutes: 25));
          if (evvabinTime.isAfter(now)) {
            final bool quiet = settings.isInQuietHours(
              evvabinTime.hour * 60 + evvabinTime.minute,
            );
            await _schedule(
              id: NotificationIds.nafile(dayIndex, 2),
              title: 'Evvâbîn Namazı Vakti (${_format(evvabinTime)})',
              body:
                  '$locationLabel • Akşam namazı sonrası 2, 4 veya 6 rekât Evvâbîn namazı hatırlatması.',
              when: evvabinTime,
              channelId: nafileChannel,
              settings: settings,
              quiet: quiet || nafileSound.isSilent,
              soundOverride: nafileSound,
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }

      // 3) Teheccüd (Gece) Namazı Alarmı (İmsak'tan 75 dk önce seher vakti, 2-8 rekât)
      if (settings.teheccudAlarm) {
        final DateTime? imsak = day.timeOf(Prayer.imsak);
        if (imsak != null) {
          final DateTime teheccudTime = imsak.subtract(
            const Duration(minutes: 75),
          );
          if (teheccudTime.isAfter(now)) {
            await _schedule(
              id: NotificationIds.nafile(dayIndex, 3),
              title: 'Teheccüd (Gece) Namazı Vakti (${_format(teheccudTime)})',
              body:
                  '$locationLabel • Seher vakti (İmsak: ${_format(imsak)}). 2 ile 8 rekât arası Teheccüd namazı vakti.',
              when: teheccudTime,
              channelId: nafileChannel,
              settings: settings,
              quiet: nafileSound.isSilent,
              soundOverride: nafileSound,
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }

      // 4) Teravih Namazı Alarmı (Yatsıdan +25 dk sonra, 20 rekât)
      if (settings.teravihAlarm) {
        final DateTime? yatsi = day.timeOf(Prayer.yatsi);
        if (yatsi != null) {
          final DateTime teravihTime = yatsi.add(const Duration(minutes: 25));
          if (teravihTime.isAfter(now)) {
            await _schedule(
              id: NotificationIds.nafile(dayIndex, 4),
              title: 'Teravih Namazı Hatırlatması (${_format(teravihTime)})',
              body:
                  '$locationLabel • Yatsı namazı sonrası 20 rekât Teravih ve Vitir namazı vakti.',
              when: teravihTime,
              channelId: nafileChannel,
              settings: settings,
              quiet: nafileSound.isSilent,
              soundOverride: nafileSound,
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }

      // 5) Cuma Namazı Vakit Öncesi Hazırlık Alarmı (Cuma günü Öğle'den 45 dk önce)
      if (settings.fridayNotification && day.date.weekday == DateTime.friday) {
        final DateTime? ogle = day.timeOf(Prayer.ogle);
        if (ogle != null) {
          final DateTime cumaPrep = ogle.subtract(const Duration(minutes: 45));
          if (cumaPrep.isAfter(now)) {
            await _schedule(
              id: NotificationIds.nafile(dayIndex, 5),
              title: 'Cuma Namazına 45 Dakika Kaldı (${_format(ogle)})',
              body:
                  '$locationLabel • Cuma hutbesi, gusül, Kehf Suresi ve Tahiyyetü\'l-Mescid için camiye hazırlık vakti.',
              when: cumaPrep,
              channelId: nafileChannel,
              settings: settings,
              quiet: nafileSound.isSilent,
              soundOverride: nafileSound,
              payload: NotificationRoute.times.value,
              hijriOffsetDays: hijriOffsetDays,
            );
            scheduled++;
          }
        }
      }
    }

    if (settings.abdestSukurReminder) {
      await scheduleDailyReminder(
        id: NotificationIds.abdestSukur,
        title: 'Abdest Şükür & Tahiyyetü\'l-Mescid Hatırlatması',
        body: 'Abdest sonrası 2 rekât Abdest Şükür namazını ve camiye girdiğinizde 2 rekât Tahiyyetü\'l-Mescid kılmayı unutmayın.',
        hour: 11,
        minute: 30,
        channelId: NotificationChannels.prayer,
        settings: settings,
        enabled: true,
        payload: NotificationRoute.times.value,
      );
      scheduled++;
    }

    if (settings.fridayNotification) {
      await scheduleWeekly(
        id: NotificationIds.friday,
        title: 'Cuma günü mübarek olsun',
        body: 'Cuma namazı ve hutbe için hazırlığınızı yapmayı unutmayın.',
        weekday: DateTime.friday,
        hour: 9,
        minute: 30,
        channelId: NotificationChannels.prayer,
        settings: settings,
        payload: NotificationRoute.times.value,
      );
      scheduled++;
    }

    final int success = scheduled > _failedThisRun
        ? scheduled - _failedThisRun
        : 0;
    _lastReport = NotificationScheduleReport(
      scheduled: success,
      failed: _failedThisRun,
      inexact: _inexactThisRun,
      error: _lastScheduleError,
    );
    AppLog.debug(
      '$success bildirim zamanlandı (${days.length} gün, '
      '$_inexactThisRun yaklaşık, $_failedThisRun başarısız)',
    );
    return success;
  }

  /// Ramazan sahur ve iftar hatırlatmaları.
  Future<void> scheduleRamadan({
    required PrayerTimesDay today,
    required PrayerTimesDay tomorrow,
    required NotificationSettings settings,
    required String locationLabel,
  }) async {
    await initialize();
    await _plugin.cancel(id: NotificationIds.ramadanSahur);
    await _plugin.cancel(id: NotificationIds.ramadanIftar);
    if (!settings.enabled || !settings.ramadanNotifications) return;

    final DateTime now = DateTime.now();
    final DateTime? imsak =
        tomorrow.timeOf(Prayer.imsak) ?? today.timeOf(Prayer.imsak);
    final DateTime? aksam = today.timeOf(Prayer.aksam);

    if (imsak != null) {
      final DateTime remind = imsak.subtract(
        Duration(minutes: settings.sahurReminderMinutes),
      );
      if (remind.isAfter(now)) {
        await _schedule(
          id: NotificationIds.ramadanSahur,
          title: 'Sahur vakti yaklaşıyor',
          body:
              '$locationLabel: imsak ${_format(imsak)} — sahur için ${settings.sahurReminderMinutes} dakika kaldı.',
          when: remind,
          channelId: NotificationChannels.ramadan,
          settings: settings,
          quiet: false,
          payload: NotificationRoute.ramadan.value,
        );
      }
    }
    if (aksam != null) {
      final DateTime remind = aksam.subtract(
        Duration(minutes: settings.iftarReminderMinutes),
      );
      if (remind.isAfter(now)) {
        await _schedule(
          id: NotificationIds.ramadanIftar,
          title: 'İftara ${settings.iftarReminderMinutes} dakika',
          body:
              '$locationLabel: iftar ${_format(aksam)}. Allah orucunuzu kabul etsin.',
          when: remind,
          channelId: NotificationChannels.ramadan,
          settings: settings,
          quiet: false,
          payload: NotificationRoute.ramadan.value,
        );
      }
    }
  }

  /// Her gün tekrarlayan bildirim (günün ayeti/hadisi, zikir, hatim).
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required String channelId,
    required NotificationSettings settings,
    String? payload,
  }) async {
    await initialize();
    await _plugin.cancel(id: id);
    final tz.TZDateTime when = _nextInstanceOf(weekday, hour, minute);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _details(channelId, settings, silent: true),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    } catch (error) {
      _lastScheduleError = '$error';
      _lastError = '$error';
      AppLog.warning('Haftalık bildirim kurulamadı (id: $id)', error: error);
    }
  }

  /// Günlük içerik/zikir/hatim hatırlatması.
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required NotificationSettings settings,
    required bool enabled,
    String? payload,
  }) async {
    await initialize();
    await _plugin.cancel(id: id);
    if (!enabled || !settings.enabled) return;
    final tz.TZDateTime when = _nextInstanceOf(null, hour, minute);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _details(channelId, settings, silent: true),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (error) {
      _lastScheduleError = '$error';
      _lastError = '$error';
      AppLog.warning('Günlük bildirim kurulamadı (id: $id)', error: error);
    }
  }

  /// Gün içinde bir kez gösterilecek özel bildirim (ör. Kadir gecesi, bayram).
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String channelId = NotificationChannels.daily,
    String? payload,
    NotificationSettings settings = const NotificationSettings(),
  }) async {
    await initialize();
    if (when.isBefore(DateTime.now())) return;
    await _schedule(
      id: id,
      title: title,
      body: body,
      when: when,
      channelId: channelId,
      settings: settings,
      quiet: true,
      payload: payload,
    );
  }

  /// Uygulama açıkken anında bildirim gösterir.
  ///
  /// Başarısız olursa `false` döner; çağıran ekran "gönderildi" demez.
  Future<bool> showNow({
    required String title,
    required String body,
    String channelId = NotificationChannels.system,
    String? payload,
    int id = NotificationIds.test,
    bool silent = true,
    AdhanSound? soundOverride,
  }) async {
    await initialize();
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details(
          channelId,
          const NotificationSettings(),
          silent: silent,
          soundOverride: soundOverride,
        ),
        payload: payload,
      );
      return true;
    } catch (error) {
      _lastError = '$error';
      AppLog.warning('Bildirim gösterilemedi: $error');
      return false;
    }
  }

  /// Telefonun varsayılan bildirim sesiyle (ezan okumadan) anında bildirim gösterir.
  Future<void> showSystemDefaultNow({
    required String title,
    required String body,
    String? payload,
    int id = NotificationIds.test,
  }) async {
    await initialize();
    final String channelId = adhanChannelId(AdhanSound.systemDefault);
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details(
          channelId,
          const NotificationSettings(adhanSound: AdhanSound.systemDefault),
          silent: false,
          soundOverride: AdhanSound.systemDefault,
        ),
        payload: payload,
      );
    } catch (error) {
      _lastError = '$error';
      AppLog.warning('Sistem sesli bildirim gösterilemedi', error: error);
    }
  }

  /// Deneme bildirimini [delaySeconds] saniye sonrası için **zamanlar**.
  ///
  /// Anında `show()` yalnızca kanalın açık olduğunu gösterir; asıl arıza
  /// çoğu zaman zamanlanmış bildirimin kurulamamasıdır. Bu yüzden test,
  /// ezanla aynı `zonedSchedule` yolunu kullanır ve sonucu geri döndürür.
  Future<NotificationTestResult> sendTestNotification({
    NotificationSettings settings = const NotificationSettings(),
    int delaySeconds = 8,
  }) async {
    await initialize();
    await refreshTimeZone();
    final NotificationScheduleMode mode = await _schedule(
      id: NotificationIds.test,
      title: 'Ezan Vaktim Pro bildirim testi',
      body: 'Bu bildirimi görüyorsanız vakit bildirimleri çalışıyor.',
      when: DateTime.now().add(Duration(seconds: delaySeconds)),
      channelId: NotificationChannels.test,
      settings: settings,
      quiet: false,
      soundOverride: AdhanSound.systemDefault,
      payload: NotificationRoute.home.value,
    );
    final int pending = await pendingCount();
    return NotificationTestResult(
      scheduled: mode.delivered,
      mode: mode,
      pending: pending,
      error: mode == NotificationScheduleMode.failed
          ? _lastScheduleError
          : null,
    );
  }

  Future<void> cancelPrayerNotifications() async {
    await initialize();
    for (int day = 0; day < NotificationIds.maxCancelDays; day++) {
      for (final Prayer prayer in Prayer.values) {
        await _plugin.cancel(id: NotificationIds.adhan(day, prayer));
        await _plugin.cancel(id: NotificationIds.pre(day, prayer));
      }
      for (int slot = 0; slot < 7; slot++) {
        await _plugin.cancel(id: NotificationIds.nafile(day, slot));
      }
    }
    await _plugin.cancel(id: NotificationIds.abdestSukur);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  /// Zamanlanmış bildirim sayısı (ayarlar ekranında gösterilir).
  Future<int> pendingCount() async {
    try {
      final List<PendingNotificationRequest> pending = await _plugin
          .pendingNotificationRequests();
      return pending.length;
    } catch (_) {
      return 0;
    }
  }

  /// Kesin alarm izni yoksa yalnızca bir kez loglanır (ekranı kirletmemek için).
  bool _exactAlarmWarningLogged = false;

  /// Son zamanlama turunun sayaçları ve raporu.
  int _failedThisRun = 0;
  int _inexactThisRun = 0;
  String? _lastScheduleError;
  NotificationScheduleReport _lastReport = const NotificationScheduleReport();

  NotificationScheduleReport get lastReport => _lastReport;

  /// Zamanlanan listenin ilk günü (bildirim kimliğindeki gün indeksi için).
  DateTime? _scheduleAnchorDate;

  /// Uygulama ezanı kendisi çalarken aynı vakit için kurulmuş **sistem
  /// bildirimini** iptal eder.
  ///
  /// Aksi hâlde ezan iki kez (bildirim sesi + uygulama içi ses) üst üste
  /// çalıyordu. İptal, bildirim sesi başladıktan hemen sonra yapılır; Android
  /// bildirimi kaldırınca ses de kesilir.
  Future<void> suppressSystemAdhan(Prayer prayer, DateTime when) async {
    final DateTime? anchor = _scheduleAnchorDate;
    if (anchor == null) return;
    final int dayIndex = DateTime(
      when.year,
      when.month,
      when.day,
    ).difference(anchor).inDays;
    if (dayIndex < 0 || dayIndex >= NotificationIds.maxCancelDays) return;
    try {
      await initialize();
      await _plugin.cancel(id: NotificationIds.adhan(dayIndex, prayer));
    } catch (error) {
      AppLog.debug('Sistem ezan bildirimi iptal edilemedi: $error');
    }
  }

  /// Uygulama içi ezanın çalma penceresi.
  ///
  /// **Düzeltilen hata ("1 dk gecikmeli ezan"):** Telefon uykuya geçtiğinde
  /// saniyelik saat durur. Uygulama açıldığında ilk tik vaktin 40 saniye
  /// sonrasına düşebiliyor ve ezan neredeyse bir dakika **gecikmeli**
  /// başlıyordu. Artık ezan yalnızca vakit girdiği **ilk 5 saniye** içinde ve
  /// uygulama gerçekten ön planda çalışırken tetiklenir; geç kalındıysa
  /// sistem bildirimi zaten ezanı çalmıştır, ikinci kez okunmaz.
  static bool isAdhanWindow(int diffSeconds, {required bool foreground}) =>
      foreground && diffSeconds >= 0 && diffSeconds <= 5;

  /// Duvar saatini cihazın saat dilimine **kaydırmadan** çevirir.
  ///
  /// Tek zamanlama noktası: ezan 15:33 için kurulduysa alarm 15:33:00'da
  /// çalmalıdır. Bu yardımcı, ileride eklenecek bir "+1 dakika" hatasının
  /// fark edilmesi için test edilir (`notification_plan_test.dart`).
  @visibleForTesting
  static tz.TZDateTime scheduledInstant(DateTime when) =>
      tz.TZDateTime.from(when, tz.local);

  /// Tek bir bildirimi kurar ve hangi modun tuttuğunu döndürür.
  ///
  /// **Asla dışarıya hata fırlatmaz.** Önceden tek bir bildirimin hatası
  /// (ör. geçersiz simge) bütün zamanlama turunu durduruyor ve kullanıcı
  /// hiçbir bildirim almıyordu; artık hata sayılır, tur devam eder ve
  /// sonuç `NotificationScheduleReport` içinde raporlanır.
  Future<NotificationScheduleMode> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required String channelId,
    required NotificationSettings settings,
    required bool quiet,
    AdhanSound? soundOverride,
    String? payload,
    int hijriOffsetDays = 0,
  }) async {
    final tz.TZDateTime scheduled = scheduledInstant(when);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      return NotificationScheduleMode.skipped;
    }
    final NotificationDetails details = _details(
      channelId,
      settings,
      silent: quiet,
      soundOverride: soundOverride,
    );

    Future<void> scheduleWith(AndroidScheduleMode mode) =>
        _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: mode,
          payload: payload,
        );

    try {
      // Android 12-15+ cihazlarda uygulama tamamen kapalıyken ve derin uyku
      // (Doze) modundayken dahi zamanında çalması için önce alarmClock denenir.
      await scheduleWith(AndroidScheduleMode.alarmClock);
      return NotificationScheduleMode.alarmClock;
    } catch (firstError) {
      if (firstError is PlatformException &&
          _isExactAlarmPermissionError(firstError)) {
        _markExactAlarmMissing(firstError);
      }
      try {
        await scheduleWith(AndroidScheduleMode.exactAllowWhileIdle);
        return NotificationScheduleMode.exact;
      } catch (exactError) {
        if (exactError is PlatformException &&
            _isExactAlarmPermissionError(exactError)) {
          _markExactAlarmMissing(exactError);
        }
        try {
          await scheduleWith(AndroidScheduleMode.inexactAllowWhileIdle);
          _inexactThisRun++;
          return NotificationScheduleMode.inexact;
        } catch (error) {
          _failedThisRun++;
          _lastScheduleError = '$error';
          _lastError = '$error';
          AppLog.warning(
            'Bildirim zamanlanamadı (id: $id, ${_format(when)})',
            error: error,
          );
          return NotificationScheduleMode.failed;
        }
      }
    }
  }

  /// Hatanın "kesin alarm izni yok" türünden olup olmadığı.
  static bool _isExactAlarmPermissionError(PlatformException error) {
    final String text = '${error.code} ${error.message}'.toLowerCase();
    return text.contains('exact') || text.contains('permission');
  }

  void _markExactAlarmMissing(PlatformException error) {
    _exactAlarmsAvailable = false;
    if (_exactAlarmWarningLogged) return;
    _exactAlarmWarningLogged = true;
    AppLog.warning(
      'Kesin alarm izni yok; ezan dakikası birkaç dakika kayabilir. '
      'Ayarlar > Bildirimler > "Kesin alarm izni" bölümünden açın '
      '(${error.code})',
    );
  }

  NotificationDetails _details(
    String channelId,
    NotificationSettings settings, {
    required bool silent,
    AdhanSound? soundOverride,
  }) {
    final AdhanSound sound = silent
        ? AdhanSound.silent
        : (soundOverride ?? settings.adhanSound);
    final bool isSystemTone = sound == AdhanSound.systemDefault;
    final AndroidNotificationSound? androidSound = _rawSoundFor(sound);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelTitle(channelId),
        channelDescription: _channelDescription(channelId),
        importance: silent ? Importance.defaultImportance : Importance.max,
        priority: silent ? Priority.defaultPriority : Priority.max,
        playSound: !sound.isSilent,
        sound: isSystemTone ? null : androidSound,
        audioAttributesUsage: (silent || isSystemTone)
            ? AudioAttributesUsage.notification
            : AudioAttributesUsage.alarm,
        fullScreenIntent: !silent && !isSystemTone,
        enableVibration: settings.vibrationEnabled && !silent,
        category: isSystemTone
            ? AndroidNotificationCategory.reminder
            : AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        color: const Color(0xFF0E4A3F),
        ticker: 'Ezan Vaktim Pro',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: !sound.isSilent,
        sound: sound.isSilent ? null : 'default',
      ),
    );
  }

  String _channelTitle(String channelId) {
    if (channelId.startsWith(NotificationChannels.adhan)) {
      return 'Ezan ve vakit bildirimleri';
    }
    return switch (channelId) {
      NotificationChannels.prayer => 'Namaz vakti hatırlatmaları',
      NotificationChannels.ramadan => 'Ramazan bildirimleri',
      NotificationChannels.daily => 'Günün içeriği',
      NotificationChannels.zikir => 'Zikir ve hatim hatırlatmaları',
      _ => 'Uygulama bildirimleri',
    };
  }

  String _channelDescription(String channelId) {
    if (channelId.startsWith(NotificationChannels.adhan)) {
      return 'Namaz ve nafile vakti girdiğinde tam ezan veya ilahi ile gösterilir.';
    }
    return switch (channelId) {
      NotificationChannels.prayer => 'Vakit girdiğinde sessiz bilgilendirme.',
      NotificationChannels.ramadan => 'Sahur ve iftar hatırlatmaları.',
      NotificationChannels.daily => 'Günün ayeti ve hadisi.',
      NotificationChannels.zikir => 'Zikir ve hatim hedefleri.',
      _ => 'Genel bilgilendirmeler.',
    };
  }

  String _titleFor(Prayer prayer, bool quiet) => switch (prayer) {
    Prayer.imsak => 'İmsak vakti girdi',
    Prayer.gunes => 'Güneş doğdu',
    Prayer.ogle => 'Öğle vakti girdi',
    Prayer.ikindi => 'İkindi vakti girdi',
    Prayer.aksam => 'Akşam vakti girdi — iftar vakti',
    Prayer.yatsi => 'Yatsı vakti girdi',
  };

  String _bodyFor(Prayer prayer, String locationLabel, PrayerTimesDay day) {
    final DateTime? time = day.timeOf(prayer);
    final String hijri = day.hijriDate == null ? '' : ' • ${day.hijriDate}';
    if (prayer == Prayer.gunes) {
      return '$locationLabel • Güneş ${_format(time)}$hijri';
    }
    return '$locationLabel • ${prayer.label} ${_format(time)}$hijri';
  }

  String _format(DateTime? time) => time == null
      ? '--:--'
      : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  tz.TZDateTime _nextInstanceOf(int? weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    DateTime cursor = DateTime(now.year, now.month, now.day);
    if (weekday != null) {
      while (cursor.weekday != weekday) {
        cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
      }
    }
    // **Düzeltme:** `add(Duration(days: 1))` yaz saati geçişlerinde 23/25
    // saatlik gün üretir ve saat bir saat kayar. Tarih her seferinde yeniden
    // kurulur; `TZDateTime` duvar saatini doğru çözer.
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      cursor.year,
      cursor.month,
      cursor.day,
      hour,
      minute,
    );
    while (!scheduled.isAfter(now)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
      scheduled = tz.TZDateTime(
        tz.local,
        cursor.year,
        cursor.month,
        cursor.day,
        hour,
        minute,
      );
    }
    return scheduled;
  }

  Future<void> dispose() async {
    await _routeController.close();
    await _adhanController.close();
  }

  /// Ezan vakti geldiğinde uygulama içi akışı tetikler.
  void emitAdhanNow(Prayer prayer) {
    if (!_adhanController.isClosed) _adhanController.add(prayer);
  }
}

/// Uygulama kapalıyken bildirime dokunulduğunda çalışan giriş noktası.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  AppLog.debug('Arka plan bildirim dokunuşu: ${response.payload}');
}
