import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_service.dart';
import '../../data/models/app_settings.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';

/// Ezan/bildirim sesi seçimi ve ses seviyesi.
///
/// Uygulama içinde gömülü ezan kaydı bulunmaz: telifsiz tonlar dahilidir,
/// gerçek ezan kaydı yalnızca lisanslıysa kullanıcı tarafından eklenebilir.
class AdhanSoundScreen extends ConsumerWidget {
  const AdhanSoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);
    final NotificationSettings notifications = settings.notifications;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ezan sesi')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          const SectionHeader(title: 'Bildirim sesi'),
          for (final AdhanSound sound in AdhanSound.values)
            ListTile(
              leading: Icon(
                sound == notifications.adhanSound
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: sound == notifications.adhanSound
                    ? theme.colorScheme.primary
                    : null,
              ),
              title: Text(sound.label),
              subtitle: Text(sound.description),
              trailing: BundledSounds.assetFor(sound) == null
                  ? null
                  : IconButton(
                      tooltip: 'Dinle',
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      onPressed: () => _preview(ref, sound, notifications.adhanVolume),
                    ),
              onTap: () => ref
                  .read(settingsControllerProvider.notifier)
                  .updateNotifications(
                    notifications.copyWith(adhanSound: sound),
                  ),
            ),
          const SectionHeader(title: 'Ses seviyesi'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: <Widget>[
                const Icon(Icons.volume_down_rounded, size: 18),
                Expanded(
                  child: Slider(
                    value: notifications.adhanVolume.clamp(0.0, 1.0),
                    divisions: 10,
                    label: '${(notifications.adhanVolume * 100).round()}%',
                    onChanged: (double value) => ref
                        .read(settingsControllerProvider.notifier)
                        .updateNotifications(
                          notifications.copyWith(adhanVolume: value),
                        ),
                  ),
                ),
                const Icon(Icons.volume_up_rounded, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text('${(notifications.adhanVolume * 100).round()}%'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Ses seviyesi yalnızca uygulama açıkken okunan ezan için geçerlidir. '
              'Bildirim sesi Android bildirim kanalı ayarlarından değiştirilir.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Lisanslı ezan kayıtları'),
            subtitle: const Text(
              'Gerçek ezan kayıtları telif hakkı nedeniyle uygulamaya gömülmez. '
              'Lisanslı bir kayıt sağladığınızda katalog üzerinden seçilebilir.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.10),
                borderRadius: AppRadius.allMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Dahili tonlar',
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Uygulama ile gelen üç bildirim tonu, bazı cihazlarda bildirim sesi '
                    'kısıtlı olduğunda bile duyulabilmesi için yüksek öncelikli kanalda '
                    'çalınır.',
                    style: theme.textTheme.labelSmall?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _preview(WidgetRef ref, AdhanSound sound, double volume) async {
    final String? asset = BundledSounds.assetFor(sound);
    if (asset == null) return;
    await ref.read(runtimeProvider).audio.playAsset(asset, volume: volume);
  }
}
