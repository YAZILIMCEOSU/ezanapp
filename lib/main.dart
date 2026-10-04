import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app.dart';
import 'app/app_runtime.dart';
import 'core/utils/logger.dart';
import 'design/app_colors.dart';
import 'design/app_spacing.dart';
import 'design/app_theme.dart';
import 'state/providers.dart';

/// Arka planda ses oynatma kanalı (ilahi/Kur'an).
const String _audioChannelId = 'com.yazilimceosu.ezanai.audio';
const String _audioChannelName = 'Ses oynatma';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLog.error('Yakalanmamış arayüz hatası', error: details.exception, stackTrace: details.stack);
    FlutterError.presentError(details);
  };

  // Arka plan ses bildirimi: başarısız olsa bile uygulama açılmaya devam eder.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: _audioChannelId,
      androidNotificationChannelName: _audioChannelName,
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

/// Uygulama açılışında ciddi bir sorun olursa gösterilen güvenli ekran.
///
/// Kullanıcıya teknik ayrıntı yerine ne yapabileceği anlatılır.
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
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'EzanAI başlatılamadı',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Uygulamayı kapatıp yeniden açmayı deneyin. Sorun sürerse '
                  'depolama alanınızı kontrol edin veya bize ulaşın.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
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
