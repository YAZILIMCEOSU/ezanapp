import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_features.dart';
import '../../design/app_colors.dart';
import '../../state/providers.dart';
import 'prayer_countdown_chip.dart';

/// Alt gezinme çubuğunda görünecek sekme tanımı.
typedef ShellTab = ({int branch, String label, IconData icon, IconData activeIcon});

/// Etkin özellik bayraklarına göre sekmeleri döner.
///
/// [branch] değeri `StatefulShellRoute` içindeki sekme sırasıdır ve sabittir;
/// kapatılan modülün sekmesi listeden çıkar, kalanların sırası korunur.
List<ShellTab> shellTabs(AppFeatures features) => <ShellTab>[
  (
    branch: 0,
    label: 'Ana Sayfa',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  (
    branch: 1,
    label: 'Vakitler',
    icon: Icons.schedule_outlined,
    activeIcon: Icons.schedule_rounded,
  ),
  if (features.quran)
    (
      branch: 2,
      label: 'Kur\'an',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
    ),
  if (features.ilahi)
    (
      branch: 3,
      label: 'İlahi',
      icon: Icons.library_music_outlined,
      activeIcon: Icons.library_music_rounded,
    ),
  (
    branch: 4,
    label: 'Daha Fazla',
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
  ),
];

/// Sekmeli uygulama kabuğu: alt gezinme çubuğu ve sekmelerin korunması.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ShellTab> tabs = shellTabs(ref.watch(appFeaturesProvider));
    final int selected = tabs.indexWhere(
      (ShellTab tab) => tab.branch == navigationShell.currentIndex,
    );
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
        child: NavigationBar(
          // Kapatılan modül açık kalmışsa (ör. eski bir bağlantı) çubuk ilk
          // sekmeyi işaretler; yönlendirme kullanıcıyı zaten ana sayfaya alır.
          selectedIndex: selected < 0 ? 0 : selected,
          onDestinationSelected: (int index) => _onSelect(tabs[index].branch),
          destinations: <Widget>[
            for (final ShellTab tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Sekme başlığı ve sağ tarafta canlı geri sayım gösteren standart üst çubuk.
class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHeader({
    required this.title,
    this.subtitle,
    this.actions,
    this.showCountdown = false,
    this.leading,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showCountdown;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppBar(
      leading: leading,
      titleSpacing: leading == null ? 20 : 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: <Widget>[
        if (showCountdown) const PrayerCountdownChip(),
        ...?actions,
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Bölüm başlığı + isteğe bağlı eylem.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 12),
    super.key,
  });

  final String title;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Marka işareti (uygulama logosu) — üst çubuklarda kullanılır.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 28, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 12,
      height: size + 12,
      decoration: BoxDecoration(
        color: AppColors.emerald900,
        borderRadius: BorderRadius.circular((size + 12) * 0.32),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/logo_mark_small.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'EzanAI logosu',
      ),
    );
  }
}
