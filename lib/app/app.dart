import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/audio_service.dart';
import '../core/constants/app_constants.dart';
import '../core/services/notification_service.dart';
import '../core/services/push_service.dart';
import '../core/utils/logger.dart';
import '../data/models/app_settings.dart';
import '../data/models/prayer.dart';
import '../data/models/prayer_times_day.dart';
import '../design/app_theme.dart';
import '../router/app_router.dart';
import '../state/providers.dart';

/// Uygulama kökü: tema, yerelleştirme, bildirim yönlendirmeleri ve ezan sesi.
class EzanAiApp extends ConsumerStatefulWidget {
  const EzanAiApp({super.key});

  @override
  ConsumerState<EzanAiApp> createState() => _EzanAiAppState();
}

class _EzanAiAppState extends ConsumerState<EzanAiApp>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<NotificationRoute>? _routeSub;
  StreamSubscription<Prayer>? _adhanSub;
  StreamSubscription<PushMessage>? _pushSub;
  DateTime _lastDayCheck = DateTime.now();
  Duration _lastTimeZoneOffset = DateTime.now().timeZoneOffset;
  String? _lastTriggeredPrayerKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindNotifications());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final DateTime now = DateTime.now();
      final bool dayChanged =
          now.year != _lastDayCheck.year ||
          now.month != _lastDayCheck.month ||
          now.day != _lastDayCheck.day;
      final bool tzChanged = now.timeZoneOffset != _lastTimeZoneOffset;
      _lastDayCheck = now;
      _lastTimeZoneOffset = now.timeZoneOffset;

      ref.invalidate(clockProvider);
      if (dayChanged || tzChanged) {
        ref.read(runtimeProvider).prayerTimes.clearMemoryCache();
        ref.invalidate(prayerTimesProvider);
        ref.invalidate(prayerRangeProvider);
        ref.invalidate(hijriTodayProvider);
        unawaited(ref.read(notificationCoordinatorProvider).reschedule());
      }
    }
  }

  void _bindNotifications() {
    final runtime = ref.read(runtimeProvider);
    _routeSub = runtime.notifications.onRoute.listen((NotificationRoute route) {
      final String path = AppRoutes.fromNotification(route);
      AppLog.debug('Bildirimden yönlendirme: $path');
      appRouter.go(path);
    });

    _adhanSub = runtime.notifications.onAdhanNow.listen((Prayer prayer) {
      final AppSettings settings = ref.read(settingsProvider);
      if (!settings.notifications.inAppAdhanEnabled) return;
      _playAdhan(prayer, settings);
    });

    // Sunucu kaynaklı duyurular (ör. mübarek gün hatırlatması).
    _pushSub = runtime.push.onMessage.listen(_onPushMessage);

    // Uygulama kapalıyken bir bildirime dokunulduysa o ekrana gidilir.
    final String? pendingRoute = runtime.push.takePendingRoute();
    if (pendingRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) appRouter.go(pendingRoute);
      });
    }

    // İlk açılışta hoş geldin ekranı ve konum izni akışı.
    final bool onboardingDone = runtime.preferences.getBool(
      PrefKeys.onboardingDone,
    );
    if (!onboardingDone) {
      appRouter.go(AppRoutes.onboarding);
    }
  }

  /// Uygulama açıkken namaz vakti girdiği saniyede ezan/bildirim sesini tetikler.
  void _checkPrayerTimeEntered(DateTime now) {
    final TodayTimes? times = ref.read(prayerTimesProvider).value;
    if (times == null) return;
    final AppSettings settings = ref.read(settingsProvider);
    if (!settings.notifications.inAppAdhanEnabled) return;

    final PrayerScheduleSnapshot snapshot = times.snapshot(now);
    for (final Prayer prayer in Prayer.values) {
      final DateTime? when = snapshot.activeDay.timeOf(prayer);
      if (when == null) continue;
      final int diffSeconds = now.difference(when).inSeconds;
      if (diffSeconds >= 0 && diffSeconds < 45) {
        final String key =
            '${when.year}-${when.month}-${when.day}:${prayer.key}';
        if (_lastTriggeredPrayerKey == key) continue;
        _lastTriggeredPrayerKey = key;

        if (!settings.notifications.isEnabledFor(prayer)) continue;
        if (settings.notifications.isInQuietHours(now.hour * 60 + now.minute)) {
          continue;
        }
        ref.read(runtimeProvider).notifications.emitAdhanNow(prayer);
      }
    }
  }

  void _onPushMessage(PushMessage message) {
    if (!mounted) return;
    final String text = message.body.isEmpty
        ? message.title
        : '${message.title}\n${message.body}';
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 8),
        action: message.route == null
            ? null
            : SnackBarAction(
                label: 'Aç',
                onPressed: () => appRouter.go(message.route!),
              ),
      ),
    );
  }

  Future<void> _playAdhan(Prayer prayer, AppSettings settings) async {
    final runtime = ref.read(runtimeProvider);
    final NotificationSettings notif = settings.notifications;
    final AdhanSound sound = notif.soundFor(prayer);
    if (sound.isSilent) return;

    await runtime.audio.initialize(ducking: settings.adhanPlaybackDucking);
    final double targetVolume = notif.adhanVolume.clamp(0.1, 1.0);
    final double initialVolume = notif.adhanFadeIn
        ? (targetVolume * 0.25).clamp(0.05, 1.0)
        : targetVolume;

    bool started = false;
    if (sound == AdhanSound.downloaded &&
        notif.customAdhanPath != null &&
        notif.customAdhanPath!.isNotEmpty &&
        File(notif.customAdhanPath!).existsSync()) {
      started = await runtime.audio.playFile(
        notif.customAdhanPath!,
        volume: initialVolume,
      );
    } else {
      final String asset =
          BundledSounds.assetFor(sound) ?? BundledSounds.ezanMelodi;
      started = await runtime.audio.playAsset(asset, volume: initialVolume);
    }

    if (!started || !mounted) return;
    if (notif.adhanFadeIn) {
      unawaited(runtime.audio.fadeIn(to: targetVolume));
    }

    final ScaffoldMessengerState? messenger = _messengerKey.currentState;
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          '${prayer.label} vakti girdi • ${sound == AdhanSound.downloaded ? (notif.customAdhanTitle ?? sound.label) : sound.label}',
        ),
        duration: const Duration(seconds: 25),
        action: SnackBarAction(
          label: 'Sesi durdur',
          onPressed: () => runtime.audio.stop(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeSub?.cancel();
    _adhanSub?.cancel();
    _pushSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppThemeMode mode = ref.watch(themeModeProvider);
    final String localeCode = ref.watch(
      settingsProvider.select((AppSettings s) => s.localeCode),
    );
    ref.listen<AsyncValue<DateTime>>(clockProvider, (
      AsyncValue<DateTime>? previous,
      AsyncValue<DateTime> next,
    ) {
      final DateTime? now = next.value;
      if (now == null) return;
      final DateTime? prev = previous?.value;
      final bool jumpedBackward =
          prev != null && now.difference(prev).inSeconds < -30;
      final bool dayChanged =
          now.year != _lastDayCheck.year ||
          now.month != _lastDayCheck.month ||
          now.day != _lastDayCheck.day;
      final bool tzChanged = now.timeZoneOffset != _lastTimeZoneOffset;
      if (jumpedBackward || dayChanged || tzChanged) {
        _lastDayCheck = now;
        _lastTimeZoneOffset = now.timeZoneOffset;
        ref.read(runtimeProvider).prayerTimes.clearMemoryCache();
        ref.invalidate(prayerTimesProvider);
        ref.invalidate(prayerRangeProvider);
        ref.invalidate(hijriTodayProvider);
        unawaited(ref.read(notificationCoordinatorProvider).reschedule());
      }
      _checkPrayerTimeEntered(now);
    });

    final String effectiveLocale = switch (localeCode) {
      'en' || 'ar' => localeCode,
      _ => 'tr',
    };

    return MaterialApp.router(
      title: 'Ezan',
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: mode == AppThemeMode.amoled
          ? AppTheme.amoled()
          : AppTheme.dark(),
      themeMode: ThemeModeController.toMaterial(mode),
      locale: Locale(effectiveLocale),
      supportedLocales: const <Locale>[
        Locale('tr'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<Object?>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
