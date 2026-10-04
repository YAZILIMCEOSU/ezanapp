import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/audio_service.dart';
import '../core/constants/app_constants.dart';
import '../core/services/notification_service.dart';
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
      if (!settings.notifications.inAppAdhan) return;
      _playAdhan(prayer, settings);
    });

    // İlk açılışta hoş geldin ekranı ve konum izni akışı.
    final bool onboardingDone = runtime.preferences.getBool(
      PrefKeys.onboardingDone,
    );
    if (!onboardingDone) {
      appRouter.go(AppRoutes.onboarding);
    }
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
