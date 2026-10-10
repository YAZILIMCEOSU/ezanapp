import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/prayer.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Bildirim ayarları: vakit bildirimleri, hatırlatmalar ve özel günler.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool? _systemPermission;
  int _pending = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final runtime = ref.read(runtimeProvider);
    try {
      final bool granted = await runtime.notifications.hasPermission();
      final int pending = await runtime.notifications.pendingCount();
      if (!mounted) return;
      setState(() {
        _systemPermission = granted;
        _pending = pending;
      });
    } catch (error) {
      AppLog.warning('Bildirim durumu okunamadı: $error');
      if (mounted) setState(() => _systemPermission = false);
    }
  }

  Future<void> _update(
    NotificationSettings Function(NotificationSettings) change,
  ) async {
    setState(() => _busy = true);
    final SettingsController controller = ref.read(
      settingsControllerProvider.notifier,
    );
    final NotificationSettings current = ref
        .read(settingsProvider)
        .notifications;
    await controller.updateNotifications(change(current));
    await _refreshStatus();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final NotificationSettings settings = ref
        .watch(settingsProvider)
        .notifications;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: <Widget>[
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          if (_systemPermission == false)
            StatusBanner(
              icon: Icons.notifications_off_outlined,
              message:
                  'Bildirim izni verilmemiş. Vakit bildirimlerinin çalışması için '
                  'sistem ayarlarından izin vermeniz gerekir.',
              action: TextButton(
                onPressed: () async {
                  await ref
                      .read(runtimeProvider)
                      .notifications
                      .requestPermission();
                  await ref.read(notificationCoordinatorProvider).reschedule();
                  await _refreshStatus();
                },
                child: const Text('Ayarları aç'),
              ),
            ),
          if (_systemPermission == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                0,
              ),
              child: Text(
                'Zamanlanmış bildirim: $_pending',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Bildirimleri etkinleştir'),
            subtitle: const Text(
              'Kapatırsanız hiçbir vakit bildirimi gösterilmez',
            ),
            value: settings.enabled,
            onChanged: (bool value) =>
                _update((NotificationSettings s) => s.copyWith(enabled: value)),
          ),
          const SectionHeader(title: 'Vakit bildirimleri'),
          for (final Prayer prayer in Prayer.values)
            SwitchListTile(
              secondary: Icon(prayer.icon),
              title: Text(prayer.label),
              subtitle: Text(
                prayer == Prayer.gunes
                    ? 'Güneş doğuşu için bildirim · ${settings.soundFor(prayer).label}'
                    : '${prayer.notificationTitle} · ${settings.soundFor(prayer).label}',
              ),
              value: settings.prayerEnabled[prayer] ?? false,
              onChanged: settings.enabled
                  ? (bool value) => _update(
                      (NotificationSettings s) => s.copyWith(
                        prayerEnabled: <Prayer, bool>{
                          ...s.prayerEnabled,
                          prayer: value,
                        },
                      ),
                    )
                  : null,
            ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_rounded),
            title: const Text('Titreşim'),
            value: settings.vibrationEnabled,
            onChanged: (bool value) => _update(
              (NotificationSettings s) => s.copyWith(vibrationEnabled: value),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Uygulama açıkken ezan sesi çal'),
            subtitle: const Text('Kapalıysa yalnızca bildirim gösterilir'),
            value: settings.inAppAdhanEnabled,
            onChanged: (bool value) => _update(
              (NotificationSettings s) => s.copyWith(inAppAdhanEnabled: value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('Ezan sesi'),
            subtitle: Text(settings.adhanSound.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.adhanSounds),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Önceden hatırlatma'),
            subtitle: Text(
              settings.preReminderMinutes == 0
                  ? 'Kapalı'
                  : '${settings.preReminderMinutes} dakika önce',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showMinutesSheet(
              context,
              title: 'Önceden hatırlatma',
              values: const <int>[0, 5, 10, 15, 20, 30, 45, 60],
              current: settings.preReminderMinutes,
              labelFor: (int value) =>
                  value == 0 ? 'Kapalı' : '$value dakika önce',
              onPick: (int value) => _update(
                (NotificationSettings s) =>
                    s.copyWith(preReminderMinutes: value),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.bedtime_outlined),
            title: const Text('Sessiz saatler'),
            subtitle: Text(
              settings.quietHoursEnabled
                  ? '${AppTime.formatTimeOfDay(settings.quietHoursStartMinutes ~/ 60, settings.quietHoursStartMinutes % 60)} – '
                        '${AppTime.formatTimeOfDay(settings.quietHoursEndMinutes ~/ 60, settings.quietHoursEndMinutes % 60)}'
                  : 'Belirli saatlerde bildirim sesi çıkarılmaz',
            ),
            value: settings.quietHoursEnabled,
            onChanged: (bool value) => _update(
              (NotificationSettings s) => s.copyWith(quietHoursEnabled: value),
            ),
          ),
          const SectionHeader(title: 'Özel günler'),
          SwitchListTile(
            secondary: const Icon(Icons.event_outlined),
            title: const Text('Cuma günü bildirimi'),
            subtitle: const Text('Perşembe akşamı ve Cuma sabahı hatırlatma'),
            value: settings.fridayNotification,
            onChanged: (bool value) => _update(
              (NotificationSettings s) => s.copyWith(fridayNotification: value),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.nightlight_outlined),
            title: const Text('Ramazan bildirimleri'),
            subtitle: Text(
              settings.ramadanNotifications
                  ? 'Sahur ${settings.sahurReminderMinutes} dk önce · iftar ${settings.iftarReminderMinutes} dk önce'
                  : 'Sahur ve iftar hatırlatmaları kapalı',
            ),
            value: settings.ramadanNotifications,
            onChanged: (bool value) => _update(
              (NotificationSettings s) =>
                  s.copyWith(ramadanNotifications: value),
            ),
          ),
          if (settings.ramadanNotifications) ...<Widget>[
            ListTile(
              leading: const Icon(Icons.fastfood_outlined),
              title: const Text('Sahur hatırlatması'),
              subtitle: Text('${settings.sahurReminderMinutes} dakika önce'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showMinutesSheet(
                context,
                title: 'Sahur hatırlatması',
                values: const <int>[15, 30, 45, 60, 90],
                current: settings.sahurReminderMinutes,
                labelFor: (int value) => '$value dakika önce',
                onPick: (int value) => _update(
                  (NotificationSettings s) =>
                      s.copyWith(sahurReminderMinutes: value),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wb_twilight_rounded),
              title: const Text('İftar hatırlatması'),
              subtitle: Text('${settings.iftarReminderMinutes} dakika önce'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showMinutesSheet(
                context,
                title: 'İftar hatırlatması',
                values: const <int>[5, 10, 15, 20, 30],
                current: settings.iftarReminderMinutes,
                labelFor: (int value) => '$value dakika önce',
                onPick: (int value) => _update(
                  (NotificationSettings s) =>
                      s.copyWith(iftarReminderMinutes: value),
                ),
              ),
            ),
          ],
          const SectionHeader(title: 'Günlük hatırlatmalar'),
          SwitchListTile(
            secondary: const Icon(Icons.menu_book_outlined),
            title: const Text('Günün ayeti ve hadisi'),
            subtitle: Text(
              'Her gün ${AppTime.formatTimeOfDay(settings.dailyContentHour, settings.dailyContentMinute)}',
            ),
            value: settings.dailyContentEnabled,
            onChanged: (bool value) => _update(
              (NotificationSettings s) =>
                  s.copyWith(dailyContentEnabled: value),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded),
            title: const Text('Zikir hatırlatması'),
            subtitle: Text(
              'Her gün ${AppTime.formatTimeOfDay(settings.zikirReminderHour, settings.zikirReminderMinute)}',
            ),
            value: settings.zikirReminderEnabled,
            onChanged: (bool value) => _update(
              (NotificationSettings s) =>
                  s.copyWith(zikirReminderEnabled: value),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_stories_outlined),
            title: const Text('Hatim hatırlatması'),
            subtitle: Text(
              'Her gün ${AppTime.formatTimeOfDay(settings.hatimReminderHour, settings.hatimReminderMinute)}',
            ),
            value: settings.hatimReminderEnabled,
            onChanged: (bool value) => _update(
              (NotificationSettings s) =>
                  s.copyWith(hatimReminderEnabled: value),
            ),
          ),
          const SectionHeader(title: 'Bakım'),
          ListTile(
            leading: const Icon(Icons.notifications_active_rounded),
            title: const Text('Test bildirimi gönder'),
            subtitle: const Text('Bildirimlerin çalıştığını doğrulayın'),
            onTap: () async {
              await ref
                  .read(runtimeProvider)
                  .notifications
                  .showNow(
                    title: 'EzanAI test bildirimi',
                    body: 'Bildirimler çalışıyor. Vakitlerde görüşmek üzere!',
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test bildirimi gönderildi.')),
                );
              }
              await _refreshStatus();
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Bildirimleri yeniden zamanla'),
            subtitle: Text(
              'Önümüzdeki ${settings.daysToSchedule} gün için yeniden planlanır',
            ),
            onTap: () async {
              final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                context,
              );
              setState(() => _busy = true);
              final int count = await ref
                  .read(notificationCoordinatorProvider)
                  .reschedule(days: settings.daysToSchedule + 1);
              await _refreshStatus();
              if (!mounted) return;
              setState(() => _busy = false);
              messenger.showSnackBar(
                SnackBar(content: Text('$count bildirim zamanlandı.')),
              );
            },
          ),
          if (_pending == 0 && settings.enabled)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Zamanlanmış bildirim görünmüyor. Android pil optimizasyonu zamanlanmış '
                'bildirimleri kısıtlayabilir; sistem ayarlarından EzanAI için '
                '"Kısıtlanmamış" seçeneğini işaretleyin.',
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Sessiz modda yalnızca titreşim kullanılır. Ezan sesi için kanal ayarlarından '
              'ses seviyesini yükseltebilirsiniz.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(runtimeProvider).notifications.cancelAll();
                await _refreshStatus();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tüm bildirimler iptal edildi.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_off_rounded, size: 18),
              label: const Text('Tüm bildirimleri iptal et'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMinutesSheet(
    BuildContext context, {
    required String title,
    required List<int> values,
    required int current,
    required String Function(int) labelFor,
    required Future<void> Function(int) onPick,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final int value in values)
              ListTile(
                leading: Icon(
                  value == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: value == current
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(labelFor(value)),
                onTap: () async {
                  await onPick(value);
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
