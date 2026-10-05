import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/city.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../data/prayer/prayer_calculator.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/prayer_widgets.dart';
import '../widgets/state_views.dart';

/// Vakitler ekranı: günlük liste + haftalık/aylık tablo, konum ve yöntem.
class PrayersScreen extends ConsumerWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PrayerRangeView view = ref.watch(prayerRangeViewProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final CalculationMethod method = ref.watch(calculationMethodProvider);

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Namaz Vakitleri',
        subtitle: '${location.label} · ${method.name}',
        showCountdown: false,
        actions: <Widget>[
          IconButton(
            tooltip: 'Konum seç',
            onPressed: () => context.push(AppRoutes.cities),
            icon: const Icon(Icons.place_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Yenile',
            onPressed: () {
              if (view == PrayerRangeView.today) {
                ref.read(prayerTimesProvider.notifier).refresh();
              } else {
                ref.read(prayerRangeProvider.notifier).refresh();
              }
            },
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<PrayerRangeView>(
                segments: <ButtonSegment<PrayerRangeView>>[
                  for (final PrayerRangeView item in PrayerRangeView.values)
                    ButtonSegment<PrayerRangeView>(
                      value: item,
                      label: Text(item.label),
                      icon: Icon(item.icon, size: 16),
                    ),
                ],
                selected: <PrayerRangeView>{view},
                onSelectionChanged: (Set<PrayerRangeView> selection) => ref
                    .read(prayerRangeViewProvider.notifier)
                    .select(selection.first),
                showSelectedIcon: false,
              ),
            ),
          ),
          Expanded(
            child: switch (view) {
              PrayerRangeView.today => const _TodayView(),
              PrayerRangeView.week ||
              PrayerRangeView.month => const _RangeView(),
            },
          ),
          const _MethodFooter(),
          const SafeArea(top: false, child: AdBanner()),
        ],
      ),
    );
  }
}

/// Günlük vakit listesi + manuel düzeltmeler.
class _TodayView extends ConsumerWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TodayTimes> times = ref.watch(prayerTimesProvider);
    final DateTime now = ref.watch(clockProvider).value ?? DateTime.now();
    final AppSettings settings = ref.watch(settingsProvider);

    return times.when(
      loading: () => const LoadingView(message: 'Vakitler hazırlanıyor…'),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(prayerTimesProvider),
      ),
      data: (TodayTimes value) {
        final PrayerTimesDay day = value.day;
        final Prayer current = day.currentPrayer(now);
        final PrayerTime? next = day.nextPrayer(now);

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: <Widget>[
            if (value.warning != null) StatusBanner(message: value.warning!),
            NextPrayerCountdownCard(
              day: day,
              now: now,
              use24Hour: settings.use24Hour,
              locationLabel: value.locationLabel,
              sourceLabel: day.sourceLabel,
              onRefresh: () => ref.read(prayerTimesProvider.notifier).refresh(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vakit listesi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  // Dar ekranlarda (320 dp) etiket kırpılır; satır taşmaz.
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Uzun basıp düzeltme ekleyin',
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final Prayer prayer in Prayer.values)
              PrayerTile(
                prayer: prayer,
                time: day.timeOf(prayer),
                use24Hour: settings.use24Hour,
                isCurrent: current == prayer,
                isNext: next?.prayer == prayer,
                onTap: () => _showActions(context, ref, prayer, day),
                trailing: _OffsetBadge(
                  offset: settings.manualOffsets[prayer.key] ?? 0,
                ),
              ),
            PrayerSourceNote(
              day: day,
              use24Hour: settings.use24Hour,
              warning: value.warning,
            ),
          ],
        );
      },
    );
  }

  void _showActions(
    BuildContext context,
    WidgetRef ref,
    Prayer prayer,
    PrayerTimesDay day,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(prayer.icon, color: prayer.color),
              title: Text(
                '${prayer.label} — ${day.timeOf(prayer) == null ? '--:--' : AppTime.formatTime(day.timeOf(prayer)!)}',
              ),
              subtitle: Text(
                prayer.hasAdhan ? 'Ezan okunan vakit' : 'Ezan okunmaz',
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Bildirim ayarları'),
              subtitle: const Text('Bu vakit için bildirim ve ön hatırlatma'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(AppRoutes.notificationSettings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Manuel düzeltme (dakika)'),
              subtitle: const Text(
                'Bu vakit için -30…+30 dakika arası ayarlayın',
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showOffsetSheet(context, ref, prayer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOffsetSheet(BuildContext context, WidgetRef ref, Prayer prayer) {
    final AppSettings settings = ref.read(settingsProvider);
    int value = settings.manualOffsets[prayer.key] ?? 0;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '${prayer.label} düzeltmesi',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  value == 0
                      ? 'Düzeltme yok'
                      : '${value > 0 ? '+' : ''}$value dakika',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Slider(
                  value: value.toDouble(),
                  min: -30,
                  max: 30,
                  divisions: 60,
                  label: '$value dk',
                  onChanged: (double next) =>
                      setState(() => value = next.round()),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => value = 0),
                        child: const Text('Sıfırla'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .setManualOffset(prayer.key, value);
                          ref.invalidate(prayerTimesProvider);
                          ref.invalidate(prayerRangeProvider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OffsetBadge extends StatelessWidget {
  const _OffsetBadge({required this.offset});

  final int offset;

  @override
  Widget build(BuildContext context) {
    if (offset == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${offset > 0 ? '+' : ''}$offset dk',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.warning),
      ),
    );
  }
}

/// Haftalık/aylık tablo görünümü.
class _RangeView extends ConsumerWidget {
  const _RangeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PrayerTimesDay>> range = ref.watch(
      prayerRangeProvider,
    );
    final DateTime now = ref.watch(clockProvider).value ?? DateTime.now();
    final AppSettings settings = ref.watch(settingsProvider);
    final PrayerRangeView view = ref.watch(prayerRangeViewProvider);

    return range.when(
      loading: () => LoadingView(
        message: view == PrayerRangeView.week
            ? 'Haftalık tablo hazırlanıyor…'
            : 'Aylık tablo hazırlanıyor…',
      ),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(prayerRangeProvider),
      ),
      data: (List<PrayerTimesDay> days) {
        if (days.isEmpty) {
          return const EmptyView(
            icon: Icons.calendar_month_outlined,
            title: 'Tablo boş',
            message: 'Seçilen aralık için vakit verisi bulunamadı.',
          );
        }
        final String sourceLabel = days.first.sourceLabel;
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 62, child: Text('')),
                  for (final Prayer prayer in Prayer.values)
                    Expanded(
                      child: Text(
                        prayer.shortLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: days.length,
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant
                      .withValues(alpha: 0.4),
                ),
                itemBuilder: (BuildContext context, int index) =>
                    PrayerTableRow(
                      day: days[index],
                      now: now,
                      use24Hour: settings.use24Hour,
                      onTap: () => context.push(AppRoutes.ramadan),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '$sourceLabel · ${days.length} gün listeleniyor',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Alt bilgi: aktif yöntem + kaynak açıklaması.
class _MethodFooter extends ConsumerWidget {
  const _MethodFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CalculationMethod method = ref.watch(calculationMethodProvider);
    final AsyncValue<String> sourceInfo = ref.watch(activeSourceInfoProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.calculate_outlined, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  method.name,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  sourceInfo.value ?? method.description,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showMethodSheet(context, ref),
            child: const Text('Yöntem'),
          ),
        ],
      ),
    );
  }

  void _showMethodSheet(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.read(settingsProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        builder: (BuildContext context, ScrollController controller) =>
            ListView(
              controller: controller,
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Text(
                    'Hesaplama yöntemi',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SwitchListTile(
                  value: settings.asrHanafi,
                  onChanged: (bool value) async {
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .setAsrHanafi(value);
                    ref.invalidate(prayerTimesProvider);
                    ref.invalidate(prayerRangeProvider);
                  },
                  title: const Text('Hanefî ikindi (asr-ı sânî)'),
                  subtitle: const Text(
                    'İkindi vakti gölge uzunluğuna göre hesaplanır',
                  ),
                ),
                const Divider(height: 1),
                for (final CalculationMethod method in CalculationMethod.all)
                  ListTile(
                    leading: Icon(
                      settings.calculationMethodId == method.id
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: settings.calculationMethodId == method.id
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(method.name),
                    subtitle: Text(
                      method.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .setMethod(method.id);
                      ref.invalidate(prayerTimesProvider);
                      ref.invalidate(prayerRangeProvider);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
              ],
            ),
      ),
    );
  }
}

/// Aktif vakit verisi kaynağı bilgisi.
final FutureProvider<String> activeSourceInfoProvider = FutureProvider<String>((
  Ref ref,
) async {
  final UserLocation location = ref.watch(activeLocationProvider);
  return ref.watch(runtimeProvider).prayerTimes.describeActiveSource(location);
});
