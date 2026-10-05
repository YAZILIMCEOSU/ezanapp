import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: <Widget>[
                      const BrandMark(size: 26),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppTime.greetingFor(
                                now,
                                afterMaghrib: times.maybeWhen(
                                  data: (TodayTimes value) =>
                                      value.day.currentPrayer(now) ==
                                          Prayer.aksam ||
                                      value.day.currentPrayer(now) ==
                                          Prayer.yatsi,
                                  orElse: () => false,
                                ),
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            Text(
                              '${hijri.longFormatted} · ${AppTime.formatDateLong(now)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Ayarlar',
                        onPressed: () => context.push(AppRoutes.settings),
                        icon: const Icon(Icons.settings_outlined, size: 20),
                      ),
                    ],
                  ),
                ),
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
                      NextPrayerCountdownCard(
                        day: value.day,
                        now: now,
                        use24Hour: settings.use24Hour,
                        locationLabel: value.locationLabel,
                        sourceLabel: value.day.sourceLabel,
                        onRefresh: () =>
                            ref.read(prayerTimesProvider.notifier).refresh(),
                      ),
                      _TodayTimesCard(
                        times_: value,
                        now: now,
                        use24Hour: settings.use24Hour,
                      ),
                      if (isRamadan) const _RamadanCard(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _QuickActions()),
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
  });

  final TodayTimes times_;
  final DateTime now;
  final bool use24Hour;

  @override
  Widget build(BuildContext context) {
    final PrayerTimesDay day = times_.day;
    final Prayer current = day.currentPrayer(now);
    final PrayerTime? next = day.nextPrayer(now);

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
            isNext: next?.prayer == prayer,
            onTap: () => context.go(AppRoutes.prayers),
            trailing: Icon(
              Icons.notifications_active_outlined,
              size: 17,
              color: Theme.of(context).colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.6),
            ),
          ),
        PrayerSourceNote(
          day: day,
          use24Hour: use24Hour,
          warning: times_.warning,
        ),
      ],
    );
  }
}

/// Hızlı erişim kutucukları.
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isRamadan = ref.watch(runtimeProvider).ramadan.isRamadan;
    final List<({IconData icon, String label, String route, Color color})>
    actions = <({IconData icon, String label, String route, Color color})>[
      (
        icon: Icons.explore_outlined,
        label: 'Kıble',
        route: AppRoutes.qibla,
        color: AppColors.emerald500,
      ),
      (
        icon: Icons.auto_awesome_outlined,
        label: 'AI Asistan',
        route: AppRoutes.ai,
        color: AppColors.gold500,
      ),
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
      (
        icon: Icons.format_quote_outlined,
        label: 'Hadis',
        route: AppRoutes.hadith,
        color: AppColors.aksam,
      ),
      (
        icon: isRamadan
            ? Icons.nightlight_outlined
            : Icons.star_outline_rounded,
        label: isRamadan ? 'Ramazan' : 'Ramazan Modu',
        route: AppRoutes.ramadan,
        color: AppColors.imsak,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.15,
        children: <Widget>[
          for (final ({Color color, IconData icon, String label, String route})
              action
              in actions)
            _QuickActionTile(
              icon: action.icon,
              label: action.label,
              color: action.color,
              onTap: () => context.push(action.route),
            ),
        ],
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: AppRadius.allMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              // Etiket esnektir: küçük ekranlarda iki satıra sığmazsa kırpılır,
              // kutu taşmaz (Spacer ile birlikte taşma veriyordu).
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
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

/// Günün ayeti kartı.
class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
