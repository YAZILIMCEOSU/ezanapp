import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Bulut yedekleme (Premium): favoriler, ilerleme ve kayıtlar.
///
/// Sunucu yapılandırılmadıysa ekran bunu açıkça bildirir ve yalnızca yerel
/// yedekleme seçeneği sunar — hiçbir işlem sessizce başarısız olmaz.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final bool premium = ref.watch(isPremiumProvider);
    final bool configured = AppConfig.hasSupabase;
    final ThemeData theme = Theme.of(context);
    final DateTime? lastBackup = ref.read(runtimeProvider).sync.lastBackupAt;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulut yedekleme')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: premium
                    ? AppColors.emerald600.withValues(alpha: 0.10)
                    : AppColors.warning.withValues(alpha: 0.10),
                borderRadius: AppRadius.allLg,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    premium ? Icons.cloud_done_outlined : Icons.lock_outline_rounded,
                    color: premium ? AppColors.emerald500 : AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      premium
                          ? 'Premium etkin: yedekleme açık.'
                          : 'Bulut yedekleme Premium aboneliğine dahildir. Yerel '
                                'yedeklemeyi her zaman kullanabilirsiniz.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!configured)
            const StatusBanner(
              icon: Icons.cloud_off_outlined,
              message: 'Sunucu yapılandırılmadığı için bulut yedekleme kullanılamıyor. '
                  'Ayarlar yedekleme özelliğiyle verilerinizi dosya olarak saklayabilirsiniz.',
            ),
          const SectionHeader(title: 'Yedekleme'),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Şimdi yedekle'),
            subtitle: Text(
              lastBackup == null
                  ? 'Son yedekleme: hiç yapılmadı'
                  : 'Son yedekleme: ${AppTime.formatDateShort(lastBackup)} '
                        '${AppTime.formatTime(lastBackup)}',
            ),
            trailing: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _busy || !configured
                ? null
                : () => _upload(requirePremium: !premium),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Yedekten geri yükle'),
            subtitle: const Text(
              'Sunucudaki yedeği indirir ve cihazdaki verileri değiştirir',
            ),
            onTap: _busy || !configured ? null : () => _restore(requirePremium: !premium),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Oturumu kapat'),
            subtitle: const Text('Bu cihazdaki anonim oturum sonlandırılır'),
            onTap: _busy || !configured
                ? null
                : () async {
                    await ref.read(runtimeProvider).sync.signOut();
                    if (mounted) {
                      setState(() => _status = 'Oturum kapatıldı.');
                    }
                  },
          ),
          const SectionHeader(title: 'Neler yedeklenir?'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              '• Kur\'an favorileri ve okuma ilerlemesi\n'
              '• Hadis favorileri\n'
              '• Zikir kayıtları ve özel zikirler\n'
              '• İlahi favorileri, son dinlenenler ve çalma listeleri\n'
              '• Hatim ve kaza orucu takibi\n'
              '• Ramazan günlük kayıtları\n'
              '• AI sohbet geçmişi\n\n'
              'Ayarlar, indirilen ses dosyaları ve konum bilgisi yedeklenmez '
              '(ayarlar için ayrı "Ayarları yedekle" özelliği vardır).',
              style: TextStyle(height: 1.6, fontSize: 12.5),
            ),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: AppRadius.allMd,
                ),
                child: Text(_status!, style: theme.textTheme.bodySmall),
              ),
            ),
          const SectionHeader(title: 'Gizlilik'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Yedekler anonim bir kimlikle ve yalnızca sizin erişebileceğiniz şekilde '
              '(satır düzeyi güvenlik ile) saklanır. Yedekleme isteğe bağlıdır; '
              'kullanmadığınızda verileriniz yalnızca cihazınızda kalır.',
              style: TextStyle(height: 1.6, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _upload({required bool requirePremium}) async {
    if (requirePremium) {
      setState(() => _status = 'Bulut yedekleme Premium aboneliğine dahildir. '
          'Premium ile sınırsız yedekleme yapabilirsiniz.');
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final bool ok = await ref.read(runtimeProvider).sync.uploadBackup();
      final String? error = ref.read(runtimeProvider).sync.lastError;
      setState(() {
        _status = ok
            ? 'Yedekleme tamamlandı.'
            : (error ?? 'Yedekleme tamamlanamadı. Bağlantınızı kontrol edin.');
      });
    } catch (error) {
      AppLog.warning('Yedekleme hatası: $error');
      setState(() => _status = 'Yedekleme sırasında bir sorun oluştu.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore({required bool requirePremium}) async {
    if (requirePremium) {
      setState(() => _status = 'Geri yükleme Premium aboneliğine dahildir.');
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Yedekten geri yükle'),
        content: const Text(
          'Bu cihazdaki favoriler, ilerleme ve kayıtlar sunucudaki yedekle '
          'değiştirilecek. Devam etmek istiyor musunuz?',
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
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final Map<String, Object?>? payload =
          await ref.read(runtimeProvider).sync.downloadBackup();
      if (payload == null) {
        setState(() {
          _status = ref.read(runtimeProvider).sync.lastError ??
              'Sunucuda yedek bulunamadı.';
        });
        return;
      }
      final int restored = await ref.read(runtimeProvider).sync.restoreBackup(payload);
      ref.invalidate(quranBookmarksProvider);
      ref.invalidate(hadithFavoritesProvider);
      ref.invalidate(zikirDailySummaryProvider);
      ref.invalidate(ilahiFavoriteIdsProvider);
      if (!mounted) return;
      setState(() => _status = '$restored kayıt geri yüklendi.');
    } catch (error) {
      AppLog.warning('Geri yükleme hatası: $error');
      if (mounted) setState(() => _status = 'Geri yükleme tamamlanamadı.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
