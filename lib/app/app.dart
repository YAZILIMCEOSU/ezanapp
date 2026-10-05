import 'dart:async';

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
import '../design/app_theme.dart';
import '../router/app_router.dart';
import '../state/providers.dart';

/// Uygulama kökü: tema, yerelleştirme, bildirim yönlendirmeleri ve ezan sesi.
class EzanAiApp extends ConsumerStatefulWidget {
  const EzanAiApp({super.key});

  @override
  ConsumerState<EzanAiApp> createState() => _EzanAiAppState();
}

class _EzanAiAppState extends ConsumerState<EzanAiApp> {
  StreamSubscription<NotificationRoute>? _routeSub;
  StreamSubscription<Prayer>? _adhanSub;
  StreamSubscription<PushMessage>? _pushSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindNotifications());
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

  void _onPushMessage(PushMessage message) {
    if (!mounted) return;
    final String text = message.body.isEmpty
        ? message.title
        : '${message.title}\n${message.body}';
    ScaffoldMessenger.of(context).showSnackBar(
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
    final String? asset = BundledSounds.assetFor(
      settings.notifications.adhanSound,
    );
    if (asset == null) return;

    final bool started = await runtime.audio.playAsset(
      asset,
      volume: settings.notifications.adhanVolume,
    );
    if (!started || !mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${prayer.label} vakti girdi'),
        duration: const Duration(seconds: 12),
        action: SnackBarAction(
          label: 'Sesi durdur',
          onPressed: () => runtime.audio.pause(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _routeSub?.cancel();
    _adhanSub?.cancel();
    _pushSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppThemeMode mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'EzanAI',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: mode == AppThemeMode.amoled
          ? AppTheme.amoled()
          : AppTheme.dark(),
      themeMode: ThemeModeController.toMaterial(mode),
      locale: const Locale('tr'),
      supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<Object?>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
