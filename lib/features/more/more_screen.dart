import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/config/app_features.dart';
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
          if (mounted) {
            setState(() => _version = '${info.version}+${info.buildNumber}');
          }
        })
        .catchError((Object _) => null);
  }

  @override
  Widget build(BuildContext context) {
    final AppFeatures features = ref.watch(appFeaturesProvider);
    final bool premium = ref.watch(isPremiumProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Daha Fazla',
        subtitle: _version.isEmpty ? 'Ezan' : 'Sürüm $_version',
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          if (features.premium) _PremiumCard(premium: premium),
          // Ezan Vakti Pro & e-Diyanet tarzı 3 sütunlu beyaz/turkuvaz Menü ızgarası
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 78,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              children: <Widget>[
                if (features.quran)
                  const _MenuGridCard(
                    icon: Icons.menu_book_rounded,
                    badgeIcon: Icons.auto_stories_rounded,
                    label: 'Kur\'an',
                    route: AppRoutes.quran,
                  ),
                if (features.hadith)
                  const _MenuGridCard(
                    icon: Icons.local_library_rounded,
                    badgeIcon: Icons.format_quote_rounded,
                    label: 'Kütüphane',
                    route: AppRoutes.hadith,
                  ),
                if (features.ilahi)
                  const _MenuGridCard(
                    icon: Icons.graphic_eq_rounded,
                    badgeIcon: Icons.play_circle_fill_rounded,
                    label: 'Aşr-ı Şerifler',
                    route: AppRoutes.ilahi,
                  ),
                const _MenuGridCard(
                  icon: Icons.calendar_month_rounded,
                  badgeIcon: Icons.brightness_3_rounded,
                  label: 'Dini Günler',
                  route: AppRoutes.calendar,
                ),
                if (features.dua)
                  const _MenuGridCard(
                    icon: Icons.mark_email_unread_rounded,
                    badgeIcon: Icons.favorite_rounded,
                    label: 'Tebrikler',
                    route: AppRoutes.dualar,
                  ),
                const _MenuGridCard(
                  icon: Icons.home_rounded,
                  badgeIcon: Icons.access_time_filled_rounded,
                  label: 'Ana Sayfa',
                  route: AppRoutes.home,
                ),
                const _MenuGridCard(
                  icon: Icons.schedule_rounded,
                  badgeIcon: Icons.notifications_active_rounded,
                  label: 'Vaktinde Kıl',
                  route: AppRoutes.prayers,
                ),
                const _MenuGridCard(
                  icon: Icons.ads_click_rounded,
                  badgeIcon: Icons.fingerprint_rounded,
                  label: 'Zikirmatik',
                  route: AppRoutes.zikir,
                ),
                const _MenuGridCard(
                  icon: Icons.mosque_rounded,
                  badgeIcon: Icons.location_on_rounded,
                  label: 'Yakın Camiler',
                  route: AppRoutes.mosques,
                ),
                const _MenuGridCard(
                  icon: Icons.explore_rounded,
                  badgeIcon: Icons.navigation_rounded,
                  label: 'Kıble Pusulası',
                  route: AppRoutes.qibla,
                ),
                if (features.ai)
                  const _MenuGridCard(
                    icon: Icons.auto_awesome_rounded,
                    badgeIcon: Icons.verified_rounded,
                    label: 'İslami Asistan',
                    route: AppRoutes.ai,
                  ),
                const _MenuGridCard(
                  icon: Icons.fact_check_rounded,
                  badgeIcon: Icons.edit_calendar_rounded,
                  label: 'Kazalar',
                  route: AppRoutes.kazaTracker,
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'İbadet'),
          const _Tile(
            icon: Icons.explore_outlined,
            title: 'Kıble',
            subtitle: 'Pusula ile Kâbe yönü ve mesafe',
            route: AppRoutes.qibla,
          ),
          const _Tile(
            icon: Icons.mosque_outlined,
            title: 'Yakındaki Camiler',
            subtitle: 'En yakın camiler, mesafe, yön ve haritada yol tarifi',
            route: AppRoutes.mosques,
          ),
          const _Tile(
            icon: Icons.fingerprint_rounded,
            title: 'Tesbih ve Zikir',
            subtitle: 'Sayaç, günlük hedef, istatistik',
            route: AppRoutes.zikir,
          ),
          const _Tile(
            icon: Icons.stars_outlined,
            title: 'Esmaül Hüsna (99 İsim)',
            subtitle: 'Allah\'ın 99 güzel ismi, anlamları ve zikir adetleri',
            route: AppRoutes.esmaulHusna,
          ),
          const _Tile(
            icon: Icons.fact_check_outlined,
            title: 'Kaza Takibi ve Cuma Hutbeleri',
            subtitle: 'Kaza namazı/orucu borç sayacı ve Cuma mesajları',
            route: AppRoutes.kazaTracker,
          ),
          if (features.dua)
            const _Tile(
              icon: Icons.volunteer_activism_outlined,
              title: 'Dualar',
              subtitle: 'Sabah, akşam, namaz ve günlük dualar; kaynak künyeli',
              route: AppRoutes.dualar,
            ),
          if (features.hadith)
            const _Tile(
              icon: Icons.format_quote_outlined,
              title: 'Hadis',
              subtitle: '1900 sahih hadis, konu ve arama',
              route: AppRoutes.hadith,
            ),
          if (features.ramadan)
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
          if (features.quran || features.ilahi)
            const SectionHeader(title: 'İçerik'),
          if (features.quran)
            const _Tile(
              icon: Icons.menu_book_outlined,
              title: 'Kur\'an-ı Kerim',
              subtitle: 'Arapça, Türkçe meal, tilavet, favoriler',
              route: AppRoutes.quran,
            ),
          if (features.ilahi)
            const _Tile(
              icon: Icons.library_music_outlined,
              title: 'İlahi ve Dini Sesler',
              subtitle: 'Kategori, çalma listesi, çevrimdışı indirme',
              route: AppRoutes.ilahi,
            ),
          SectionHeader(title: features.ai ? 'Asistan ve Ayarlar' : 'Ayarlar'),
          if (features.ai)
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
                Expanded(
                  child: Text(
                    premium ? 'Premium etkin' : 'Ezan Premium',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
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

/// Ezan Vakti Pro & e-Diyanet tarzı beyaz yuvarlatılmış kare kart + turkuvaz/mercan çift renkli ikon.
class _MenuGridCard extends StatelessWidget {
  const _MenuGridCard({
    required this.icon,
    required this.badgeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData badgeIcon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? theme.colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _tabRoutes.contains(route)
            ? context.go(route)
            : context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outlineVariant
                  : const Color(0xFFE1ECF2),
            ),
            boxShadow: isDark
                ? const <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF00838F).withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0097A7).withValues(alpha: 0.16)
                      : const Color(0xFFEAF4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(icon, size: 22, color: const Color(0xFF0097A7)),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surface
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          badgeIcon,
                          size: 10,
                          color: const Color(0xFFFF7043),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : const Color(0xFF1E353D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
