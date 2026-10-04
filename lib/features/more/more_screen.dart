import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/config/app_config.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';

/// "Daha Fazla" sekmesi: tüm modüller ve ayarlar.
class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((PackageInfo info) {
          if (mounted)
            setState(() => _version = '${info.version}+${info.buildNumber}');
        })
        .catchError((Object _) => null);
  }

  @override
  Widget build(BuildContext context) {
    final bool premium = ref.watch(isPremiumProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Daha Fazla',
        subtitle: _version.isEmpty ? 'EzanAI' : 'Sürüm $_version',
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          _PremiumCard(premium: premium),
          const SectionHeader(title: 'İbadet'),
          const _Tile(
            icon: Icons.explore_outlined,
            title: 'Kıble',
            subtitle: 'Pusula ile Kâbe yönü ve mesafe',
            route: AppRoutes.qibla,
          ),
          const _Tile(
            icon: Icons.fingerprint_rounded,
            title: 'Tesbih ve Zikir',
            subtitle: 'Sayaç, günlük hedef, istatistik',
            route: AppRoutes.zikir,
          ),
          const _Tile(
            icon: Icons.format_quote_outlined,
            title: 'Hadis',
            subtitle: '1900 sahih hadis, konu ve arama',
            route: AppRoutes.hadith,
          ),
          const _Tile(
            icon: Icons.nightlight_outlined,
            title: 'Ramazan',
            subtitle: 'Sahur/iftar, imsakiye, hatim, kaza takibi',
            route: AppRoutes.ramadan,
          ),
          _Tile(
            icon: Icons.calendar_month_outlined,
            title: 'Hicri Takvim ve Önemli Günler',
            subtitle: 'Kandiller, bayramlar, mübarek geceler',
            route: AppRoutes.calendar,
            trailing: Text(
              ref.watch(hijriTodayProvider).formatted,
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SectionHeader(title: 'İçerik'),
          const _Tile(
            icon: Icons.menu_book_outlined,
            title: 'Kur\'an-ı Kerim',
            subtitle: 'Arapça, Türkçe meal, tilavet, favoriler',
            route: AppRoutes.quran,
          ),
          const _Tile(
            icon: Icons.library_music_outlined,
            title: 'İlahi ve Dini Sesler',
            subtitle: 'Kategori, çalma listesi, çevrimdışı indirme',
            route: AppRoutes.ilahi,
          ),
          const SectionHeader(title: 'Asistan ve Ayarlar'),
          const _Tile(
            icon: Icons.auto_awesome_outlined,
            title: 'AI İslam Asistanı',
            subtitle: 'Kaynaklı, mezhep farklarını belirten yanıtlar',
            route: AppRoutes.ai,
          ),
          const _Tile(
            icon: Icons.settings_outlined,
            title: 'Ayarlar',
            subtitle: 'Tema, konum, yöntem, bildirimler',
            route: AppRoutes.settings,
          ),
          const _Tile(
            icon: Icons.notifications_active_outlined,
            title: 'Bildirim Ayarları',
            subtitle: 'Vakitler, Cuma, Ramazan, günlük içerik',
            route: AppRoutes.notificationSettings,
          ),
          _Tile(
            icon: Icons.place_outlined,
            title: 'Konum',
            subtitle: ref.watch(activeLocationProvider).label,
            route: AppRoutes.cities,
          ),
          const SectionHeader(title: 'Uygulama'),
          const _Tile(
            icon: Icons.info_outline_rounded,
            title: 'Hakkında ve Gizlilik',
            subtitle: 'Kaynaklar, lisanslar, veri politikası',
            route: AppRoutes.about,
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Veri kullanımı'),
            subtitle: Text(
              AppConfig.hasSupabase
                  ? 'Bulut senkronizasyon etkin (isteğe bağlı)'
                  : 'Tüm verileriniz cihazınızda kalır',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AdBanner(),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.premium});

  final bool premium;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
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
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  premium ? 'Premium etkin' : 'EzanAI Premium',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              premium
                  ? 'Reklamsız deneyim ve sınırsız AI asistan aktif. Desteğiniz için teşekkürler.'
                  : 'Reklamsız kullanım, sınırsız AI soru hakkı, gelişmiş istatistikler '
                        've bulut yedekleme.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonal(
              onPressed: () => context.push(AppRoutes.premium),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold400,
                foregroundColor: AppColors.emerald900,
              ),
              child: Text(premium ? 'Aboneliği yönet' : 'Premium\'a geç'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sekme kökleri (shell içinde) — bunlara `go` ile gidilir, diğerlerine `push`.
const Set<String> _tabRoutes = <String>{
  AppRoutes.home,
  AppRoutes.prayers,
  AppRoutes.quran,
  AppRoutes.ilahi,
  AppRoutes.more,
};

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: () =>
          _tabRoutes.contains(route) ? context.go(route) : context.push(route),
    );
  }
}
