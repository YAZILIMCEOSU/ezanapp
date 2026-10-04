import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app.dart';
import 'app/app_runtime.dart';
import 'core/utils/logger.dart';
import 'design/app_spacing.dart';
import 'design/app_theme.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLog.error(
      'Yakalanmamış arayüz hatası',
      error: details.exception,
      stackTrace: details.stack,
    );
    // Hata ayıklamada ayrıntılı kayıt; üretimde uygulama çalışmaya devam eder.
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      FlutterError.presentError(details);
    }
  };

  // Cihaz yönleri: dikey + yatay (tablet uyumu), ters çevirme kapalı.
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Arka planda ses (Kur'an/ilahi) için kilit ekranı bildirimi.
  // Başarısız olursa uygulama yine açılır, yalnızca arka plan çalma devre dışı kalır.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.yazilimceosu.ezanai.audio',
      androidNotificationChannelName: 'Ses oynatma',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (error) {
    AppLog.warning('Arka plan ses servisi başlatılamadı: $error');
  }

  try {
    final AppRuntime runtime = await AppRuntime.create();
    runApp(
      ProviderScope(
        overrides: <Override>[runtimeProvider.overrideWithValue(runtime)],
        child: const EzanAiApp(),
      ),
    );
  } catch (error, stackTrace) {
    AppLog.error('Uygulama başlatılamadı', error: error, stackTrace: stackTrace);
    runApp(_StartupFailureApp(message: '$error'));
  }
}

/// Açılış sırasında giderilemeyen bir sorun olursa gösterilen güvenli ekran.
///
/// Kullanıcıya teknik ayrıntı yerine ne yapabileceği anlatılır; buradan
/// uygulama yeniden başlatılamaz ama veri kaybı olmaz.
class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = AppTheme.light();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'EzanAI başlatılamadı',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Uygulamayı kapatıp yeniden açmayı deneyin. Sorun sürerse depolama '
                  'alanınızı kontrol edin veya destek ekibimize ulaşın.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: AppSpacing.lg),
                SelectableText(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
