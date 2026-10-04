import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors/app_exception.dart';
import '../../core/services/billing_service.dart';
import '../../core/utils/logger.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';

/// Premium abonelik ekranı — Google Play Billing üzerinden çalışır.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _busy = false;
  String? _message;

  static const List<({String title, String description})> _benefits =
      <({String title, String description})>[
        (
          title: 'Reklamsız deneyim',
          description: 'Tüm ekranlardaki reklam alanları kaldırılır.',
        ),
        (
          title: 'Sınırsız AI soru',
          description: 'Ücretsiz sürümdeki günlük 10 soru sınırı kalkar.',
        ),
        (
          title: 'Premium ilahi arşivi',
          description: 'Lisanslı yüksek kaliteli ilahi kayıtları açılır.',
        ),
        (
          title: 'Gelişmiş istatistik',
          description: 'Zikir, hatim ve okuma istatistiklerinin tamamı.',
        ),
        (
          title: 'Bulut yedekleme',
          description: 'Favoriler ve ilerleme cihazlar arasında eşitlenir.',
        ),
        (
          title: 'Gelişmiş kişiselleştirme',
          description: 'Ek tema ve vakit tabloları, öncelikli destek.',
        ),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    final runtime = ref.read(runtimeProvider);
    try {
      await runtime.billing.loadProducts();
      if (mounted) setState(() {});
    } catch (error) {
      AppLog.warning('Ürünler yüklenemedi: $error');
      if (mounted) {
        setState(
          () => _message = 'Mağaza ürünleri yüklenemedi. İnternet bağlantınızı kontrol edin.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PremiumStatus status = ref.watch(premiumProvider);
    final BillingService billing = ref.read(runtimeProvider).billing;
    final List<PremiumProduct> products = billing.products;
    final bool storeAvailable = billing.storeAvailable;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[AppColors.emerald700, AppColors.emerald900],
                ),
                borderRadius: AppRadius.allLg,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.gold400,
                        size: 26,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'EzanAI Premium',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    status == PremiumStatus.premium
                        ? 'Aboneliğiniz etkin. Reklamlar kapatıldı, tüm özellikler açık.'
                        : 'Topluluğumuza destek olun; reklamsız ve sınırsız bir deneyim yaşayın.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Durum: ${status.label}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Premium ile neler açılır?'),
          for (final ({String title, String description}) benefit in _benefits)
            ListTile(
              leading: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              title: Text(benefit.title),
              subtitle: Text(benefit.description),
            ),
          const SectionHeader(title: 'Abonelik seçenekleri'),
          if (!storeAvailable)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Google Play Hizmetleri bu cihazda kullanılamıyor. Play Store yüklü '
                've güncel olduğunda satın alma seçenekleri görünür.',
              ),
            ),
          if (storeAvailable && products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Ürünler yükleniyor… Play Console\'da ürünler yayınlandığında burada '
                'listelenir.',
              ),
            ),
          for (final PremiumProduct product in products)
            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text(
                  product.price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald500,
                  ),
                ),
                onTap: _busy || status == PremiumStatus.premium
                    ? null
                    : () => _purchase(product),
              ),
            ),
          if (products.isEmpty && storeAvailable)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Fiyatlar Play Store\'dan alınır ve ülkenize göre değişebilir.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _restore,
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('Satın alımları geri yükle'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _loadProducts(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Yenile'),
                  ),
                ),
              ],
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allMd,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(_message!, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          const SectionHeader(title: 'Bilgilendirme'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              '• Abonelik Google Play hesabınızdan otomatik yenilenir.\n'
              '• İptal etmek için Play Store > Abonelikler bölümünü kullanın.\n'
              '• Satın alma doğrulaması güvenli sunucumuzda yapılır; kart bilgileri '
              'uygulamaya hiçbir zaman girilmez.\n'
              '• Mevcut aboneliği olan kullanıcılar yeni cihazda "geri yükle" ile '
              'erişebilir.',
              style: TextStyle(height: 1.6, fontSize: 12),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final Uri uri = Uri.parse(
                  'https://play.google.com/store/account/subscriptions',
                );
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (error) {
                  AppLog.warning('Abonelik sayfası açılamadı: $error');
                }
              },
              child: const Text('Aboneliği Play Store\'da yönet'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchase(PremiumProduct product) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(premiumProvider.notifier).purchase(product.id);
      if (!mounted) return;
      setState(() {
        _message = 'Satın alma başlatıldı. Onay ekranını tamamlayın.';
      });
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _message = 'Satın alma tamamlanamadı. Lütfen tekrar deneyin.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final PremiumStatus restored = await ref
          .read(premiumProvider.notifier)
          .restore();
      if (!mounted) return;
      setState(() {
        _message = restored.isPremium
            ? 'Premium aboneliğiniz etkinleştirildi.'
            : 'Etkin bir satın alma bulunamadı.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Geri yükleme başarısız oldu: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
