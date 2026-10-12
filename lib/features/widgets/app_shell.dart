import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/audio_service.dart';
import '../../core/config/app_features.dart';
import '../../core/l10n/app_strings.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import 'prayer_countdown_chip.dart';

/// Alt gezinme çubuğunda görünecek sekme tanımı.
typedef ShellTab = ({
  int branch,
  String label,
  IconData icon,
  IconData activeIcon,
});

/// Etkin özellik bayraklarına göre sekmeleri döner.
///
/// [branch] değeri `StatefulShellRoute` içindeki sekme sırasıdır ve sabittir;
/// kapatılan modülün sekmesi listeden çıkar, kalanların sırası korunur.
List<ShellTab> shellTabs(AppFeatures features, {String localeCode = 'tr'}) {
  final AppStrings s = AppStrings(localeCode);
  return <ShellTab>[
    (
      branch: 0,
      label: s.tabHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    (
      branch: 1,
      label: s.tabPrayers,
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule_rounded,
    ),
    if (features.quran)
      (
        branch: 2,
        label: s.tabQuran,
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
      ),
    if (features.ilahi)
      (
        branch: 3,
        label: s.tabIlahi,
        icon: Icons.library_music_outlined,
        activeIcon: Icons.library_music_rounded,
      ),
    (
      branch: 4,
      label: s.tabMore,
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
  ];
}

/// Sekmeli uygulama kabuğu: alt gezinme çubuğu ve sekmelerin korunması.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String localeCode = ref.watch(
      settingsProvider.select((s) => s.localeCode),
    );
    final List<ShellTab> tabs = shellTabs(
      ref.watch(appFeaturesProvider),
      localeCode: localeCode,
    );
    final int selected = tabs.indexWhere(
      (ShellTab tab) => tab.branch == navigationShell.currentIndex,
    );
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GlobalAudioMiniBar(currentBranch: navigationShell.currentIndex),
          DecoratedBox(
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
              onDestinationSelected: (int index) =>
                  _onSelect(tabs[index].branch),
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
        ],
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
        semanticLabel: 'Ezan Vaktim Pro logosu',
      ),
    );
  }
}

/// Tüm ana sekmelerde (Ana Sayfa, Vakitler, Kur'an, İlahi, Daha Fazla) görünür
/// global Kur'an ve ses kontrol çubuğu.
///
/// Kullanıcı Kur'an'da sesli bir sure açıp başka menüye geçtiğinde çalan sureyi
/// buradan görebilir, önceki/sonraki ayete geçebilir, duraklatabilir, kapatabilir
/// (`✕`) veya çubuğa dokunarak ilgili sure ve ayete geri dönebilir.
class GlobalAudioMiniBar extends ConsumerStatefulWidget {
  const GlobalAudioMiniBar({required this.currentBranch, super.key});

  final int currentBranch;

  @override
  ConsumerState<GlobalAudioMiniBar> createState() => _GlobalAudioMiniBarState();
}

class _GlobalAudioMiniBarState extends ConsumerState<GlobalAudioMiniBar> {
  StreamSubscription<PlaybackStatus>? _statusSub;
  StreamSubscription<int>? _queueSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AppAudioService audio = ref.read(runtimeProvider).audio;
      _statusSub = audio.statusStream.listen((_) {
        if (mounted) setState(() {});
      });
      _queueSub = audio.queueIndexStream.listen((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _queueSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    final bool isQuran = audio.hasActiveQuranSession;
    // İlahi sekmesinde (branch == 3) zaten kendi PlayerBar'ı olduğundan yalnızca
    // Kur'an tilaveti çalıyorsa göster; diğer tüm sekmelerde aktif ses varsa göster.
    if (!isQuran &&
        (widget.currentBranch == 3 || !audio.hasActiveAudioSession)) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final bool playing = audio.status == PlaybackStatus.playing;
    final bool loading = audio.status == PlaybackStatus.loading;
    final int surahNum = audio.activeSurahNumber ?? 1;
    final int ayahNum = audio.activeAyahNumber;
    final int totalAyahs = audio.activeTotalAyahs;

    final String title = isQuran
        ? '${audio.activeSurahName ?? '$surahNum. Sure'} • $ayahNum${totalAyahs > 0 ? '/$totalAyahs' : ''}. Ayet'
        : (audio.activeCustomTitle ?? 'Ses Oynatılıyor');
    final String subtitle = isQuran
        ? '${audio.activeReciterName ?? 'Kur\'an Tilaveti'} · Sureye dönmek için dokunun'
        : (audio.activeCustomSubtitle ?? 'Çalan sesi kontrol edin veya kapatın');

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 6,
      child: InkWell(
        onTap: isQuran
            ? () => context.push(AppRoutes.surah(surahNum, ayah: ayahNum))
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.emerald500.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isQuran
                      ? Icons.menu_book_rounded
                      : Icons.graphic_eq_rounded,
                  size: 19,
                  color: AppColors.emerald500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isQuran && totalAyahs > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Önceki Ayet',
                  onPressed: ayahNum > 1
                      ? () => audio.jumpToQueueIndex(ayahNum - 2)
                      : null,
                  icon: const Icon(Icons.skip_previous_rounded, size: 22),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: playing ? 'Duraklat' : 'Devam Et',
                onPressed: loading ? null : audio.togglePlayPause,
                icon: Icon(
                  loading
                      ? Icons.hourglass_top_rounded
                      : playing
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 28,
                  color: AppColors.emerald500,
                ),
              ),
              if (isQuran && totalAyahs > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Sonraki Ayet',
                  onPressed: ayahNum < totalAyahs
                      ? () => audio.jumpToQueueIndex(ayahNum)
                      : null,
                  icon: const Icon(Icons.skip_next_rounded, size: 22),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Sesi Kapat / Durdur',
                onPressed: () async {
                  await audio.stop();
                  if (mounted) setState(() {});
                },
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
