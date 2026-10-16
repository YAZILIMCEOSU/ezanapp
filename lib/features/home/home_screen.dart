import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_features.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/dua_models.dart';
import '../../data/models/hadith_models.dart';
import '../../data/models/hijri_date.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../data/models/zikir_models.dart';
import '../../data/repositories/daily_content_repository.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/prayer_widgets.dart';
import '../widgets/state_views.dart';

/// Ana ekran: vakit özeti, geri sayım, günün içerikleri ve hızlı erişim.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TodayTimes> times = ref.watch(prayerTimesProvider);
    final DateTime now = ref.watch(clockProvider).value ?? DateTime.now();
    final AppSettings settings = ref.watch(settingsProvider);
    final HijriDate hijri = ref.watch(hijriTodayProvider);
    final bool isRamadan = ref.watch(runtimeProvider).ramadan.isRamadan;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(prayerTimesProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _EDiyanetTopHeader(now: now, hijri: hijri),
              ),
              SliverToBoxAdapter(
                child: times.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
                    child: LoadingView(message: 'Vakitler hazırlanıyor…'),
                  ),
                  error: (Object error, StackTrace stackTrace) => ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(prayerTimesProvider),
                  ),
                  data: (TodayTimes value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (value.warning != null)
                        StatusBanner(
                          message: value.warning!,
                          action: TextButton(
                            onPressed: () => ref
                                .read(prayerTimesProvider.notifier)
                                .refresh(),
                            child: const Text('Yenile'),
                          ),
                        ),
                      _EDiyanetSplitPrayerCard(
                        day: value.day,
                        tomorrow: value.tomorrow,
                        snapshot: value.snapshot(now),
                        now: now,
                        use24Hour: settings.use24Hour,
                        locationLabel: value.locationLabel,
                        onRefresh: () =>
                            ref.read(prayerTimesProvider.notifier).refresh(),
                      ),
                      _EDiyanetHutbeBanner(now: now),
                      const SizedBox(height: AppSpacing.sm),
                      const _QuickActions(),
                      _TodayTimesCard(
                        times_: value,
                        now: now,
                        use24Hour: settings.use24Hour,
                        notifications: settings.notifications,
                      ),
                      if (isRamadan) const _RamadanCard(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _DailyVerseCard()),
              const SliverToBoxAdapter(child: _DailyHadithCard()),
              const SliverToBoxAdapter(child: _DailyDuaCard()),
              const SliverToBoxAdapter(child: _ZikirSummaryCard()),
              if (isRamadan) const SliverToBoxAdapter(child: _KadirNightHint()),
              const SliverToBoxAdapter(child: AdBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bugünün altı vakti.
class _TodayTimesCard extends StatelessWidget {
  const _TodayTimesCard({
    required this.times_,
    required this.now,
    required this.use24Hour,
    required this.notifications,
  });

  final TodayTimes times_;
  final DateTime now;
  final bool use24Hour;
  final NotificationSettings notifications;

  @override
  Widget build(BuildContext context) {
    final PrayerScheduleSnapshot snap = times_.snapshot(now);
    final PrayerTimesDay day = snap.activeDay;
    final Prayer current = snap.currentPrayer;
    final PrayerTime? next = snap.nextPrayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: 'Bugünün vakitleri',
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          action: TextButton.icon(
            onPressed: () => context.go(AppRoutes.prayers),
            icon: const Icon(Icons.table_chart_outlined, size: 16),
            label: const Text('Tablo'),
          ),
        ),
        for (final Prayer prayer in Prayer.values)
          PrayerTile(
            prayer: prayer,
            time: day.timeOf(prayer),
            use24Hour: use24Hour,
            isCurrent: current == prayer,
            isNext: !snap.isAfterIsha && next?.prayer == prayer,
            onTap: () => context.push(AppRoutes.adhanSounds),
            trailing: Icon(
              notifications.enabled &&
                      notifications.isEnabledFor(prayer) &&
                      !notifications.soundFor(prayer).isSilent
                  ? Icons.volume_up_rounded
                  : Icons.notifications_off_outlined,
              size: 18,
              color:
                  notifications.enabled &&
                      notifications.isEnabledFor(prayer) &&
                      !notifications.soundFor(prayer).isSilent
                  ? AppColors.emerald500
                  : Theme.of(context).colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
            ),
          ),
        PrayerSourceNote(
          day: day,
          use24Hour: use24Hour,
          warning: times_.warning,
        ),
        DiyanetKerahatAndNafileBar(day: day, now: now, use24Hour: use24Hour),
      ],
    );
  }
}

/// Hızlı erişim kutucukları.
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeatures features = ref.watch(appFeaturesProvider);
    final bool isRamadan = ref.watch(runtimeProvider).ramadan.isRamadan;
    final List<({IconData icon, String label, String route, Color color})>
    allActions = <({IconData icon, String label, String route, Color color})>[
      (
        icon: Icons.explore_outlined,
        label: 'Kıble',
        route: AppRoutes.qibla,
        color: AppColors.emerald500,
      ),
      if (features.ai)
        (
          icon: Icons.auto_awesome_outlined,
          label: 'AI Asistan',
          route: AppRoutes.ai,
          color: AppColors.gold500,
        ),
      if (features.quran)
        (
          icon: Icons.menu_book_outlined,
          label: 'Kur\'an',
          route: AppRoutes.quran,
          color: AppColors.info,
        ),
      (
        icon: Icons.fingerprint_rounded,
        label: 'Tesbih',
        route: AppRoutes.zikir,
        color: AppColors.emerald600,
      ),
      if (features.hadith)
        (
          icon: Icons.format_quote_outlined,
          label: 'Hadis',
          route: AppRoutes.hadith,
          color: AppColors.aksam,
        ),
      if (features.ramadan)
        (
          icon: isRamadan
              ? Icons.nightlight_outlined
              : Icons.star_outline_rounded,
          label: isRamadan ? 'Ramazan' : 'Ramazan Modu',
          route: AppRoutes.ramadan,
          color: AppColors.imsak,
        ),
      if (features.hadith) ...<
        ({IconData icon, String label, String route, Color color})
      >[
        (
          icon: Icons.mosque_outlined,
          label: 'Camiler',
          route: AppRoutes.mosques,
          color: AppColors.emerald500,
        ),
        (
          icon: Icons.stars_outlined,
          label: 'Esmaül Hüsna',
          route: AppRoutes.esmaulHusna,
          color: AppColors.gold500,
        ),
        (
          icon: Icons.fact_check_outlined,
          label: 'Kaza & Hutbe',
          route: AppRoutes.kazaTracker,
          color: AppColors.info,
        ),
      ],
    ];

    // Kapatılan modüllerin girişleri hiç gösterilmez (ölü buton olmaz).
    final List<({IconData icon, String label, String route, Color color})>
    actions = allActions
        .where(
          (({IconData icon, String label, String route, Color color}) action) =>
              features.allows(action.route),
        )
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 86,
        ),
        itemBuilder: (BuildContext context, int index) {
          final ({Color color, IconData icon, String label, String route})
          action = actions[index];
          return _QuickActionTile(
            icon: action.icon,
            label: action.label,
            color: action.color,
            onTap: () => context.push(action.route),
          );
        },
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? <Color>[
                        color.withValues(alpha: 0.35),
                        const Color(0xFF0A2229),
                      ]
                    : <Color>[
                        color.withValues(alpha: 0.88),
                        const Color(0xFF005B6A),
                      ],
              ),
              border: Border.all(
                color: isDark ? theme.colorScheme.outlineVariant : Colors.white,
                width: 2.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                letterSpacing: -0.2,
                color: isDark
                    ? theme.colorScheme.onSurface
                    : const Color(0xFF1E2D38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// e-Diyanet tarzı üst başlık + Radyo oynatıcı + Miladi | Hicri tarih şeridi.
class _EDiyanetTopHeader extends ConsumerWidget {
  const _EDiyanetTopHeader({required this.now, required this.hijri});

  final DateTime now;
  final HijriDate hijri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final AppFeatures features = ref.watch(appFeaturesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Üst marka çubuğu: Logo + Ezan Vaktim Pro + sağ aksiyon ikonları
          Row(
            children: <Widget>[
              const BrandMark(size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppConstants.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF1F2D3A),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hakkında',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: const EdgeInsets.all(4),
                onPressed: () => context.push(AppRoutes.about),
                icon: const Icon(Icons.info_outline_rounded, size: 21),
              ),
              IconButton(
                tooltip: 'Bildirim Ayarları',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: const EdgeInsets.all(4),
                onPressed: () => context.push(AppRoutes.notificationSettings),
                icon: const Icon(Icons.notifications_none_rounded, size: 21),
              ),
              IconButton(
                tooltip: 'Kıble Pusulası',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: const EdgeInsets.all(4),
                onPressed: () => context.push(AppRoutes.qibla),
                icon: const Icon(Icons.explore_outlined, size: 21),
              ),
              IconButton(
                tooltip: 'Ayarlar',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: const EdgeInsets.all(4),
                onPressed: () => context.push(AppRoutes.settings),
                icon: const Icon(Icons.settings_outlined, size: 21),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 2. e-Diyanet Radyo / Tilavet Kartı
          Material(
            color: isDark ? const Color(0xFF15262E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push(
                features.ilahi ? AppRoutes.ilahi : AppRoutes.adhanSounds,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? theme.colorScheme.outlineVariant
                        : const Color(0xFFE3EBF0),
                  ),
                  boxShadow: isDark
                      ? const <BoxShadow>[]
                      : <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFF142838), Color(0xFF2C5364)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Color(0xFFFFD54F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppConstants.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Kur\'an & İlahi Radyo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E2D38),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF1F3842)
                            : const Color(0xFFF3F7FA),
                        border: Border.all(
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFD5E1E8),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 24,
                        color: isDark ? Colors.white : const Color(0xFF263846),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 3. Miladi | Hicri Tarih Şeridi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8EC),
                ),
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8EC),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    AppTime.formatDateLong(now),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF253542),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 1.2,
                    height: 13,
                    color: isDark ? Colors.white30 : const Color(0xFF90A4AE),
                  ),
                ),
                Flexible(
                  child: Text(
                    hijri.longFormatted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF253542),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// e-Diyanet tarzı İkili Ana Vakit Izgarası (Sol) & Cami Silüetli Geri Sayım Kartı (Sağ).
class _EDiyanetSplitPrayerCard extends StatelessWidget {
  const _EDiyanetSplitPrayerCard({
    required this.day,
    required this.now,
    required this.use24Hour,
    required this.locationLabel,
    this.tomorrow,
    this.snapshot,
    this.onRefresh,
  });

  final PrayerTimesDay day;
  final PrayerTimesDay? tomorrow;
  final PrayerScheduleSnapshot? snapshot;
  final DateTime now;
  final bool use24Hour;
  final String locationLabel;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final PrayerScheduleSnapshot snap =
        snapshot ??
        PrayerScheduleSnapshot.resolve(day: day, tomorrow: tomorrow, now: now);
    final PrayerTimesDay activeDay = snap.activeDay;
    final Prayer current = snap.currentPrayer;
    final PrayerTime? next = snap.nextPrayer;
    final Duration remaining = snap.remaining;

    final List<String> locParts = locationLabel
        .split(RegExp(r'[,/·-]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    final String cityMain =
        (locParts.isNotEmpty ? locParts.first : locationLabel).toUpperCase();
    final String districtSub = locParts.length > 1
        ? locParts.sublist(1).join(' / ')
        : locationLabel;

    const List<List<Prayer>> rows = <List<Prayer>>[
      <Prayer>[Prayer.imsak, Prayer.ogle, Prayer.aksam],
      <Prayer>[Prayer.gunes, Prayer.ikindi, Prayer.yatsi],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // SOL SÜTUN: Şehir Başlığı + İlçe Seçici + 3x2 Vakit Izgarası
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cityMain,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF263846),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () => context.push(AppRoutes.cities),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF15262E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFDCE5EC),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.my_location_rounded,
                            size: 13,
                            color: Color(0xFF0097A7),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              districtSub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF34495E),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: Color(0xFF0097A7),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final List<Prayer> row in rows) ...<Widget>[
                    Row(
                      children: <Widget>[
                        for (final Prayer p in row)
                          Expanded(
                            child: _EDiyanetPrayerTicket(
                              prayer: p,
                              timeText: activeDay.timeOf(p) == null
                                  ? '--:--'
                                  : AppTime.formatTime(
                                      activeDay.timeOf(p)!,
                                      use24Hour: use24Hour,
                                    ),
                              isActive: current == p,
                              isDark: isDark,
                            ),
                          ),
                      ],
                    ),
                    if (row != rows.last) const SizedBox(height: 5),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // SAĞ SÜTUN: Cami Silüetli Gökyüzü ve Geri Sayım Kartı
            Expanded(
              flex: 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 172,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      const CustomPaint(painter: _EDiyanetMosqueSkyPainter()),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 44),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  next != null
                                      ? '${next.prayer.label} Vaktine Kalan'
                                      : 'Vakit Geri Sayımı',
                                  style: const TextStyle(
                                    color: Color(0xFF1F2D3A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  next == null
                                      ? '--:--'
                                      : AppTime.formatClock(remaining),
                                  style: const TextStyle(
                                    color: Color(0xFF1B2836),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    fontFeatures: <FontFeature>[
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EDiyanetPrayerTicket extends StatelessWidget {
  const _EDiyanetPrayerTicket({
    required this.prayer,
    required this.timeText,
    required this.isActive,
    required this.isDark,
  });

  final Prayer prayer;
  final String timeText;
  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color bg = isActive
        ? const Color(0xFFECA013)
        : (isDark ? const Color(0xFF15262E) : Colors.white);
    final Color fg = isActive
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF263846));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? const Color(0xFFD68C06)
              : (isDark ? Colors.white12 : const Color(0xFFE3ECF2)),
        ),
        boxShadow: isDark
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              prayer.label,
              style: TextStyle(
                color: fg.withValues(alpha: isActive ? 0.96 : 0.78),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeText,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EDiyanetMosqueSkyPainter extends CustomPainter {
  const _EDiyanetMosqueSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF5FA8D3),
          Color(0xFF8ECAE6),
          Color(0xFFD8EEFA),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Yumuşak bulut halkaları
    final Paint cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.25),
      26,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.18),
      32,
      cloudPaint,
    );

    // Alt kısımda cami kubbe ve minare silüeti
    final Paint mosquePaint = Paint()
      ..color = const Color(0xFF284B63).withValues(alpha: 0.85);
    final double baseY = size.height;
    // Taban
    canvas.drawRect(Rect.fromLTWH(0, baseY - 18, size.width, 18), mosquePaint);
    // Ana kubbe
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, baseY - 16),
        width: size.width * 0.52,
        height: 44,
      ),
      3.14159,
      3.14159,
      true,
      mosquePaint,
    );
    // Yan kubbeler
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.22, baseY - 14),
        width: size.width * 0.24,
        height: 24,
      ),
      3.14159,
      3.14159,
      true,
      mosquePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, baseY - 14),
        width: size.width * 0.24,
        height: 24,
      ),
      3.14159,
      3.14159,
      true,
      mosquePaint,
    );
    // İki minare
    final double m1X = size.width * 0.12;
    final double m2X = size.width * 0.88;
    canvas.drawRect(Rect.fromLTWH(m1X - 3, baseY - 58, 6, 44), mosquePaint);
    canvas.drawRect(Rect.fromLTWH(m2X - 3, baseY - 58, 6, 44), mosquePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// e-Diyanet tarzı Hayırlı Cumalar / Günün Hutbesi manşet kartı.
class _EDiyanetHutbeBanner extends StatelessWidget {
  const _EDiyanetHutbeBanner({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final bool isFriday = now.weekday == DateTime.friday;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.kazaTracker),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color(0xFF8B6B4A),
                  Color(0xFF5D7A68),
                  Color(0xFF2B5876),
                ],
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isFriday ? 'Hayırlı Cumalar' : 'Günün Hikmeti & Hutbe',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFriday
                            ? 'Cumanız mübarek olsun.'
                            : 'Haftalık hutbe ve ibadet rehberi.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Cuma Hutbesi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Günün ayeti kartı.
class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appFeaturesProvider).quran) {
      return const SizedBox.shrink();
    }
    final AsyncValue<DailyContent> content = ref.watch(dailyContentProvider);
    final DailyAyah? verse = content.value?.verse;
    if (verse == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: AppRadius.allLg,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant
                .withValues(alpha: 0.6),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.auto_stories_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Günün ayeti',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Paylaş',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text: verse.shareText(),
                      subject: 'Günün ayeti',
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              verse.ayah.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(Theme.of(context).textTheme, size: 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              verse.ayah.turkish,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${verse.surah.nameTurkish} Suresi, ${verse.ayah.number}. ayet',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    AppRoutes.surah(
                      verse.surah.number,
                      ayah: verse.ayah.number,
                    ),
                  ),
                  child: const Text('Sureyi oku'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Günün hadisi kartı — kaynak künyesi her zaman görünür.
class _DailyHadithCard extends ConsumerWidget {
  const _DailyHadithCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appFeaturesProvider).hadith) {
      return const SizedBox.shrink();
    }
    final AsyncValue<DailyContent> content = ref.watch(dailyContentProvider);
    final DailyContent? daily = content.value;
    final Hadith? hadith = daily?.hadith;
    if (hadith == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: AppRadius.allLg,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant
                .withValues(alpha: 0.6),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.format_quote_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Günün hadisi',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Paylaş',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text: hadith.shareText(),
                      subject: 'Günün hadisi',
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hadith.turkish,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                hadith.reference,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    context.push(AppRoutes.hadithDetail(hadith.id)),
                child: const Text('Hadisi aç'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Günün duası kartı — kaynak künyesi ve "Dualar" bağlantısı ile.
class _DailyDuaCard extends ConsumerWidget {
  const _DailyDuaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appFeaturesProvider).dua) {
      return const SizedBox.shrink();
    }
    final AsyncValue<Dua?> content = ref.watch(dailyDuaProvider);
    final Dua? dua = content.value;
    if (dua == null) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: AppRadius.allLg,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.volunteer_activism_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Günün duası',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Paylaş',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(text: dua.shareText(), subject: 'Günün duası'),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              dua.name,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (dua.transliteration.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                dua.transliteration,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
            if (dua.meaning.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                dua.meaning,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Icon(
                  Icons.verified_outlined,
                  size: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    dua.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.dualar),
                  child: const Text('Tüm dualar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Günlük zikir özeti.
class _ZikirSummaryCard extends ConsumerWidget {
  const _ZikirSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ZikirDailySummary> summary = ref.watch(
      zikirDailySummaryProvider,
    );
    final ZikirDailySummary? value = summary.value;
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppColors.emerald600.withValues(alpha: 0.16),
              AppColors.emerald900.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: AppRadius.allLg,
          border: Border.all(
            color: AppColors.emerald500.withValues(alpha: 0.28),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.fingerprint_rounded,
                  size: 18,
                  color: AppColors.emerald500,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Günlük zikir',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '${value.totalCount} / ${value.target}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value.progress,
                minHeight: 6,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    value.sessions == 0
                        ? 'Bugün henüz zikir yapmadınız. Küçük bir başlangıç yeterli.'
                        : '${value.sessions} oturumda ${value.totalCount} zikir tamamlandı.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => context.push(AppRoutes.zikir),
                  child: const Text('Tesbih aç'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ramazan modunda sahur/iftar geri sayımı.
class _RamadanCard extends ConsumerWidget {
  const _RamadanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<
      ({
        PrayerTimesDay today,
        PrayerTimesDay tomorrow,
        DateTime imsak,
        DateTime iftar,
      })
    >
    data = ref.watch(ramadanTodayProvider);
    final DateTime now = ref.watch(clockProvider).value ?? DateTime.now();

    return data.maybeWhen(
      data: (value) {
        final bool afterIftar = now.isAfter(value.iftar);
        final DateTime target = afterIftar ? _nextDayImsak(value) : value.iftar;
        final String label = afterIftar ? 'Sahura kalan' : 'İftara kalan';
        final Duration remaining = target.difference(now);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: Material(
            color: AppColors.aksam.withValues(alpha: 0.14),
            borderRadius: AppRadius.allLg,
            child: InkWell(
              borderRadius: AppRadius.allLg,
              onTap: () => context.push(AppRoutes.ramadan),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.aksam.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.nightlight_round,
                        color: AppColors.aksam,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${AppTime.formatClock(remaining)} · ${AppTime.formatTime(target, use24Hour: true)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  DateTime _nextDayImsak(
    ({
      PrayerTimesDay today,
      PrayerTimesDay tomorrow,
      DateTime imsak,
      DateTime iftar,
    })
    value,
  ) {
    final DateTime? tomorrowImsak = value.tomorrow.timeOf(Prayer.imsak);
    if (tomorrowImsak != null) return tomorrowImsak;
    return value.imsak.add(const Duration(days: 1));
  }
}

/// Kadir gecesi yaklaşıyorsa hatırlatma.
class _KadirNightHint extends ConsumerWidget {
  const _KadirNightHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int ramadanDay = ref
        .watch(runtimeProvider)
        .ramadan
        .ramadanDayNumber();
    if (ramadanDay < 25) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: StatusBanner(
        icon: Icons.auto_awesome_rounded,
        message:
            'Kadir gecesi Ramazanın son on gününde aranır. Bu geceleri dua ve '
            'Kur\'an ile değerlendirmek tavsiye edilir.',
      ),
    );
  }
}

/// Uygulama sürümü ve destege erişim (hakkında ekranına yönlendirir).
class SupportRow extends StatelessWidget {
  const SupportRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.help_outline_rounded),
      title: const Text('Destek ve geri bildirim'),
      subtitle: const Text(AppConstants.supportEmail),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(AppRoutes.about),
    );
  }
}
