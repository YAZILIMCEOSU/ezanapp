import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/audio/audio_service.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/prayer.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';

/// Ezan/bildirim sesi seçimi, vakit bazlı ses özelleştirmesi ve cihazdan ses yükleme.
class AdhanSoundScreen extends ConsumerStatefulWidget {
  const AdhanSoundScreen({super.key});

  @override
  ConsumerState<AdhanSoundScreen> createState() => _AdhanSoundScreenState();
}

class _AdhanSoundScreenState extends ConsumerState<AdhanSoundScreen> {
  AdhanSound? _previewingSound;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = ref.watch(settingsProvider);
    final NotificationSettings notifications = settings.notifications;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ezan ve Bildirim Sesi'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sesi durdur',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () {
              ref.read(runtimeProvider).audio.stop();
              setState(() => _previewingSound = null);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: FilledButton.icon(
              onPressed: () {
                final AdhanSound target =
                    _canPreview(notifications.adhanSound, notifications)
                    ? notifications.adhanSound
                    : AdhanSound.ezanMelodi;
                _preview(target, notifications, forcePlay: true);
              },
              icon: const Icon(Icons.volume_up_rounded, size: 20),
              label: const Text('Vakit Girmiş Gibi Şimdi Test Et'),
            ),
          ),
          const SectionHeader(title: 'Ezan makamı ve bildirim sesi'),
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
              title: Text(
                sound == AdhanSound.downloaded &&
                        notifications.customAdhanTitle != null &&
                        notifications.customAdhanTitle!.isNotEmpty
                    ? '${sound.label} (${notifications.customAdhanTitle})'
                    : sound.label,
              ),
              subtitle: Text(sound.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (sound == AdhanSound.downloaded)
                    IconButton(
                      tooltip: 'Telefondan ses dosyası seç',
                      icon: const Icon(Icons.folder_open_rounded),
                      onPressed: () => _pickCustomAdhanFile(context),
                    ),
                  if (_canPreview(sound, notifications))
                    IconButton(
                      tooltip: _previewingSound == sound ? 'Durdur' : 'Dinle',
                      icon: Icon(
                        _previewingSound == sound
                            ? Icons.stop_circle_rounded
                            : Icons.play_circle_outline_rounded,
                        color: _previewingSound == sound
                            ? AppColors.emerald500
                            : null,
                      ),
                      onPressed: () => _preview(sound, notifications),
                    ),
                ],
              ),
              onTap: () async {
                if (sound == AdhanSound.downloaded &&
                    (notifications.customAdhanPath == null ||
                        notifications.customAdhanPath!.isEmpty)) {
                  await _pickCustomAdhanFile(context);
                  return;
                }
                await ref
                    .read(settingsControllerProvider.notifier)
                    .updateNotifications(
                      notifications.copyWith(adhanSound: sound),
                    );
                if (_canPreview(sound, notifications)) {
                  await _preview(sound, notifications, forcePlay: true);
                } else {
                  await ref.read(runtimeProvider).audio.stop();
                  if (mounted) setState(() => _previewingSound = null);
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: OutlinedButton.icon(
              onPressed: () => _pickCustomAdhanFile(context),
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: Text(
                notifications.customAdhanTitle == null
                    ? 'Telefondan Ezan / Bildirim Sesi Yükle (MP3, WAV, M4A)'
                    : 'Özel Sesi Değiştir: ${notifications.customAdhanTitle}',
              ),
            ),
          ),
          const SectionHeader(title: 'Otomatik okuma ve ses ayarları'),
          SwitchListTile(
            title: const Text('Vakit girdiğinde otomatik ezan oku'),
            subtitle: const Text(
              'Uygulama açıkken namaz vakti girdiği saniyede seçili ezan/makam sesini otomatik başlatır',
            ),
            value: notifications.inAppAdhanEnabled,
            onChanged: (bool value) => ref
                .read(settingsControllerProvider.notifier)
                .updateNotifications(
                  notifications.copyWith(inAppAdhanEnabled: value),
                ),
          ),
          SwitchListTile(
            title: const Text('Yumuşak başlangıç (Fade-in)'),
            subtitle: const Text(
              'Ezan sesi kısık başlayıp 2 saniye içinde kademeli olarak yükselir',
            ),
            value: notifications.adhanFadeIn,
            onChanged: (bool value) => ref
                .read(settingsControllerProvider.notifier)
                .updateNotifications(
                  notifications.copyWith(adhanFadeIn: value),
                ),
          ),
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
          const SectionHeader(title: 'Her vakit için ayrı ses seçimi'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'İsterseniz sabah/imsak için Saba makamı, iş saatlerindeki vakitler için '
              'kısa ton veya sessiz, akşam ve yatsı için uzun Hicaz ezan makamı seçebilirsiniz.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final Prayer prayer in Prayer.values)
            ListTile(
              leading: const Icon(Icons.schedule_rounded, size: 20),
              title: Text(prayer.label),
              subtitle: Text(
                notifications.perPrayerSound.containsKey(prayer)
                    ? 'Özel: ${notifications.perPrayerSound[prayer]!.label}'
                    : 'Varsayılan (${notifications.adhanSound.label})',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                  _pickPrayerSoundSheet(context, prayer, notifications),
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
                    'Telifsiz makamlar ve özel ses desteği',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Uygulama içindeki Hicaz, Saba, Segâh ve Tekbir ezgileri telifsiz olarak '
                    'üretilmiştir; yüksek öncelikli bildirim kanalında ekran kilitliyken de '
                    'duyulur. Kendi lisanslı müezzin/ezan MP3 dosyanızı da yukarıdan seçip '
                    'kullanabilirsiniz.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canPreview(AdhanSound sound, NotificationSettings notifications) {
    if (BundledSounds.assetFor(sound) != null) return true;
    if (sound == AdhanSound.downloaded &&
        notifications.customAdhanPath != null &&
        notifications.customAdhanPath!.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> _preview(
    AdhanSound sound,
    NotificationSettings notifications, {
    bool forcePlay = false,
  }) async {
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    if (!forcePlay && _previewingSound == sound) {
      await audio.stop();
      if (mounted) setState(() => _previewingSound = null);
      return;
    }
    setState(() => _previewingSound = sound);
    bool ok = false;
    if (sound == AdhanSound.downloaded &&
        notifications.customAdhanPath != null &&
        notifications.customAdhanPath!.isNotEmpty) {
      ok = await audio.playFile(
        notifications.customAdhanPath!,
        volume: notifications.adhanVolume,
      );
    } else {
      final String? asset = BundledSounds.assetFor(sound);
      if (asset != null) {
        ok = await audio.playAsset(asset, volume: notifications.adhanVolume);
      }
    }
    if (!mounted) return;
    if (!ok) {
      setState(() => _previewingSound = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ses oynatılamadı.')),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Dinleniyor: ${sound.label}'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Durdur',
            onPressed: () {
              audio.stop();
              if (mounted) setState(() => _previewingSound = null);
            },
          ),
        ),
      );
  }

  Future<void> _pickCustomAdhanFile(BuildContext context) async {
    const XTypeGroup audioGroup = XTypeGroup(
      label: 'Ses dosyaları',
      extensions: <String>['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[audioGroup],
    );
    if (file == null) return;

    try {
      final Directory support = await getApplicationSupportDirectory();
      final Directory adhanDir = Directory(
        p.join(support.path, 'adhan_custom'),
      );
      if (!adhanDir.existsSync()) {
        await adhanDir.create(recursive: true);
      }
      final String fileName = p.basename(file.path);
      final String targetPath = p.join(adhanDir.path, fileName);
      await File(file.path).copy(targetPath);

      final String title = p.basenameWithoutExtension(fileName);
      final NotificationSettings current = ref
          .read(settingsProvider)
          .notifications;
      await ref
          .read(settingsControllerProvider.notifier)
          .updateNotifications(
            current.copyWith(
              adhanSound: AdhanSound.downloaded,
              customAdhanPath: targetPath,
              customAdhanTitle: title,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Özel ezan sesi yüklendi: $title')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ses dosyası yüklenemedi: $error')),
        );
      }
    }
  }

  Future<void> _pickPrayerSoundSheet(
    BuildContext context,
    Prayer prayer,
    NotificationSettings notifications,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          builder: (BuildContext _, ScrollController controller) => ListView(
            controller: controller,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  '${prayer.label} vakti sesi',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                leading: Icon(
                  !notifications.perPrayerSound.containsKey(prayer)
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: !notifications.perPrayerSound.containsKey(prayer)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: const Text('Varsayılan sesi kullan'),
                subtitle: Text(notifications.adhanSound.label),
                onTap: () {
                  final Map<Prayer, AdhanSound> updated =
                      Map<Prayer, AdhanSound>.from(notifications.perPrayerSound)
                        ..remove(prayer);
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotifications(
                        notifications.copyWith(perPrayerSound: updated),
                      );
                  Navigator.of(sheetContext).pop();
                },
              ),
              const Divider(height: 1),
              for (final AdhanSound option in AdhanSound.values)
                ListTile(
                  leading: Icon(
                    notifications.perPrayerSound[prayer] == option
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: notifications.perPrayerSound[prayer] == option
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(option.label),
                  subtitle: Text(option.description),
                  onTap: () {
                    final Map<Prayer, AdhanSound> updated =
                        Map<Prayer, AdhanSound>.from(
                          notifications.perPrayerSound,
                        )..[prayer] = option;
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateNotifications(
                          notifications.copyWith(perPrayerSound: updated),
                        );
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
