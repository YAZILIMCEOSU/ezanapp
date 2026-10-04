import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/app_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/prayer/prayer_calculator.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';

/// Genel ayarlar: tema, konum, hesap yöntemi, Kur'an tercihleri, veri yönetimi.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);
    final SettingsController controller = ref.read(
      settingsControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final CalculationMethod method = settings.resolvedMethod(
      CalculationMethod.fromId(settings.calculationMethodId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          const SectionHeader(title: 'Görünüm'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            subtitle: Text(
              '${settings.themeMode.label} · AMOLED koyu modda siyah arka plan kullanılır',
            ),
            onTap: () => _showThemeSheet(context, ref, settings.themeMode),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.schedule_outlined),
            title: const Text('24 saat biçimi'),
            subtitle: Text(
              AppTime.formatTime(DateTime.now(), use24Hour: settings.use24Hour),
            ),
            value: settings.use24Hour,
            onChanged: controller.setUse24Hour,
          ),
          const SectionHeader(title: 'Konum ve vakitler'),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('Konum'),
            subtitle: Text(ref.watch(activeLocationProvider).label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.cities),
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text('Hesaplama yöntemi'),
            subtitle: Text(method.name),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showMethodSheet(context, ref, settings),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wb_twilight_rounded),
            title: const Text('Hanefî ikindi vakti'),
            subtitle: const Text(
              'İkindi, Şâfiî\'ye göre bir gölge boyu daha geç girer',
            ),
            value: settings.asrHanafi,
            onChanged: controller.setAsrHanafi,
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Hicri gün kaydırması'),
            subtitle: Text(
              settings.hijriOffsetDays == 0
                  ? 'Diyanet takvimiyle aynı'
                  : '${settings.hijriOffsetDays > 0 ? '+' : ''}${settings.hijriOffsetDays} gün',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  tooltip: 'Bir gün geri',
                  onPressed: () =>
                      controller.setHijriOffset(settings.hijriOffsetDays - 1),
                  icon: const Icon(Icons.remove_rounded, size: 18),
                ),
                IconButton(
                  tooltip: 'Bir gün ileri',
                  onPressed: () =>
                      controller.setHijriOffset(settings.hijriOffsetDays + 1),
                  icon: const Icon(Icons.add_rounded, size: 18),
                ),
              ],
            ),
            onTap: () => context.push(AppRoutes.calendar),
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Vakit bazlı düzeltme'),
            subtitle: const Text(
              'Diyanet vakitlerine ±30 dakika ekleyip çıkarın',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go(AppRoutes.prayers),
          ),
          const SectionHeader(title: 'Bildirimler'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Bildirim ayarları'),
            subtitle: const Text(
              'Vakit, Cuma, Ramazan, günlük içerik ve zikir hatırlatmaları',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.notificationSettings),
          ),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('Ezan sesi'),
            subtitle: Text(settings.notifications.adhanSound.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.adhanSounds),
          ),
          const SectionHeader(title: 'Kur\'an ve zikir'),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('Kur\'an yazı boyutu'),
            subtitle: Text('${settings.quranFontSize.round()} punto'),
          ),
          Slider(
            value: settings.quranFontSize,
            min: 18,
            max: 44,
            divisions: 13,
            label: settings.quranFontSize.round().toString(),
            onChanged: controller.setQuranFontSize,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.translate_rounded),
            title: const Text('Türkçe meal göster'),
            value: settings.quranShowTranslation,
            onChanged: (bool value) => controller.update(
              settings.copyWith(quranShowTranslation: value),
              rescheduleNotifications: false,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_rounded),
            title: const Text('Zikirde titreşim'),
            value: settings.zikirVibrationEnabled,
            onChanged: (bool value) =>
                controller.setZikirPreferences(vibration: value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Zikirde tık sesi'),
            value: settings.zikirSoundEnabled,
            onChanged: (bool value) =>
                controller.setZikirPreferences(sound: value),
          ),
          const SectionHeader(title: 'Veri ve gizlilik'),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: const Text('Kullanım istatistikleri'),
            subtitle: const Text(
              'Anonim kullanım verisi; kişisel veri toplanmaz',
            ),
            value: settings.analyticsEnabled,
            onChanged: controller.setAnalytics,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: const Text('Çökme raporları'),
            subtitle: const Text('Hataları düzeltmemize yardımcı olur'),
            value: settings.crashReportingEnabled,
            onChanged: controller.setCrashReporting,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wifi_rounded),
            title: const Text('Yalnızca Wi-Fi\'de akış'),
            subtitle: const Text('Mobil veriyle ses indirmeyi engeller'),
            value: settings.streamingOnlyOnWifi,
            onChanged: controller.setStreamingOnlyOnWifi,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_mute_outlined),
            title: const Text('Ezan okunurken sesi kıs'),
            value: settings.adhanPlaybackDucking,
            onChanged: controller.setAdhanDucking,
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Bulut yedekleme'),
            subtitle: Text(
              AppConfig.hasSupabase
                  ? 'Premium ile favoriler ve ilerleme cihazlar arasında eşitlenir'
                  : 'Sunucu yapılandırılmadı (yerel yedekleme kullanılabilir)',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.backup),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Ayarları yedekle'),
            subtitle: const Text('Ayarlarınızı paylaşın veya kaydedin'),
            onTap: () => _exportSettings(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Yedekten geri yükle'),
            subtitle: const Text(
              'Daha önce paylaştığınız JSON metnini yapıştırın',
            ),
            onTap: () => _importSettings(context, ref),
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            title: const Text('Verilerimi sil'),
            subtitle: const Text(
              'Favoriler, geçmiş, indirilenler ve sohbetler silinir',
            ),
            onTap: () => _confirmClear(context, ref),
          ),
          const SectionHeader(title: 'Uygulama'),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Premium'),
            subtitle: const Text('Reklamsız deneyim ve sınırsız AI'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.premium),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Hakkında'),
            subtitle: Text(
              AppConfig.hasBackend
                  ? 'Sunucu bağlı'
                  : 'Çevrimdışı bilgi tabanı etkin',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.about),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'EzanAI verilerinizi cihazınızda tutar. Konum yalnızca vakit hesabı için '
              'kullanılır, sunucuya gönderilmez.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final AppThemeMode mode in AppThemeMode.values)
            ListTile(
              leading: Icon(
                mode == current
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
              title: Text(mode.label),
              subtitle: mode == AppThemeMode.amoled
                  ? const Text('OLED ekranlarda daha az güç tüketir')
                  : null,
              onTap: () {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(mode);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }

  void _showMethodSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.7,
        child: ListView(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Hesaplama yöntemi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Türkiye için Diyanet yöntemi önerilir. Yurt dışındaysanız bulunduğunuz '
                'bölgenin resmî yöntemini seçin.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final CalculationMethod item in CalculationMethod.all)
              ListTile(
                leading: Icon(
                  item.id == settings.calculationMethodId
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: item.id == settings.calculationMethodId
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(item.name),
                subtitle: Text(item.description),
                onTap: () {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setMethod(item.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportSettings(BuildContext context, WidgetRef ref) async {
    final AppSettings settings = ref.read(settingsProvider);
    final String json = const JsonEncoder.withIndent('  ')
        .convert(settings.toPrefs());
    await SharePlus.instance.share(
      ShareParams(text: json, subject: 'EzanAI ayar yedeği'),
    );
  }

  Future<void> _importSettings(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Yedekten geri yükle'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Daha önce paylaştığınız JSON metnini yapıştırın',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Geri yükle'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .restoreFromJson(controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ayarlar geri yüklendi.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedek okunamadı, metni kontrol edin.')),
        );
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Verilerimi sil'),
        content: const Text(
          'Favoriler, okuma geçmişi, zikir kayıtları, AI sohbetleri ve indirilen '
          'sesler silinecek. Bu işlem geri alınamaz.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(runtimeProvider).clearUserData();
    ref.invalidate(hadithCollectionProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm kullanıcı verileri silindi.')),
      );
    }
  }
}
