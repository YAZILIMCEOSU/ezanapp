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
        final PrayerScheduleSnapshot snap = value.snapshot(now);
        final PrayerTimesDay day = snap.activeDay;
        final Prayer current = snap.currentPrayer;
        final PrayerTime? next = snap.nextPrayer;

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: <Widget>[
            if (value.warning != null) StatusBanner(message: value.warning!),
            NextPrayerCountdownCard(
              day: value.day,
              tomorrow: value.tomorrow,
              snapshot: snap,
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
                isNext: !snap.isAfterIsha && next?.prayer == prayer,
                onTap: () => _showActions(context, ref, prayer, day),
                trailing: _OffsetBadge(
                  offset: settings.manualOffsets[prayer.key] ?? 0,
                ),
              ),
            _NafileAndSpecialPrayersSection(
              day: day,
              settings: settings,
              use24Hour: settings.use24Hour,
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

class _NafilePrayerSpec {
  const _NafilePrayerSpec({
    required this.title,
    required this.rekatBadge,
    required this.timeLabel,
    required this.summary,
    required this.guide,
    required this.icon,
    required this.enabled,
    required this.onToggle,
  });

  final String title;
  final String rekatBadge;
  final String timeLabel;
  final String summary;
  final String guide;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onToggle;
}

/// Nafile ve vakitli özel namazlar (İşrak, Kuşluk/Duha, Evvâbîn, Teheccüd,
/// Tahiyyetü'l-Mescid, Abdest Şükür, Cuma, Bayram ve Teravih) için otomatik
/// vakit hesaplama, rehber ve tek tıkla alarm kurma bölümü.
class _NafileAndSpecialPrayersSection extends ConsumerWidget {
  const _NafileAndSpecialPrayersSection({
    required this.day,
    required this.settings,
    required this.use24Hour,
  });

  final PrayerTimesDay day;
  final AppSettings settings;
  final bool use24Hour;

  String _fmt(DateTime? dt) =>
      dt == null ? '--:--' : AppTime.formatTime(dt, use24Hour: use24Hour);

  Future<void> _updateNotif(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings next,
    String label,
    bool enabled,
  ) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .updateNotifications(next);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? '$label alarmı kuruldu (${next.adhanSound.label}).'
                : '$label alarmı kapatıldı.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final NotificationSettings ns = settings.notifications;

    final DateTime? imsak = day.timeOf(Prayer.imsak);
    final DateTime? gunes = day.timeOf(Prayer.gunes);
    final DateTime? ogle = day.timeOf(Prayer.ogle);
    final DateTime? aksam = day.timeOf(Prayer.aksam);
    final DateTime? yatsi = day.timeOf(Prayer.yatsi);

    final DateTime? israkTime = gunes?.add(const Duration(minutes: 47));
    final DateTime? duhaBest = gunes?.add(const Duration(minutes: 120));
    final DateTime? duhaEnd = ogle?.subtract(const Duration(minutes: 45));
    final DateTime? evvabinTime = aksam?.add(const Duration(minutes: 25));
    final DateTime? teheccudTime = imsak?.subtract(const Duration(minutes: 75));
    final DateTime? teravihTime = yatsi?.add(const Duration(minutes: 25));
    final DateTime? cumaPrep = ogle?.subtract(const Duration(minutes: 45));
    final DateTime? eidTime = gunes?.add(const Duration(minutes: 48));

    final List<_NafilePrayerSpec> items = <_NafilePrayerSpec>[
      _NafilePrayerSpec(
        title: 'İşrak Namazı',
        rekatBadge: '2 Rekât',
        timeLabel: 'Alarm: ${_fmt(israkTime)} (Güneş + 47 dk)',
        summary: 'Sabah namazını kıldıktan sonra zikirle meşgul olup güneş doğduktan ve kerahet vakti çıktıktan (~45-50 dk sonra) hemen kılınan 2 rekât namazdır (Kuşluk başlangıcıdır).',
        guide:
            '• Vakti: Güneş doğup kerahet vakti çıktıktan (yaklaşık 45-50 dk sonra, bugün ${_fmt(israkTime)}) başlar.\n'
            '• Rekâtı: 2 rekâttır.\n'
            '• Niyeti: "Niyet ettim Allah rızası için İşrak namazını kılmaya."\n'
            '• Fazileti: Tirmizî\'de (Cum\'a, 59) geçen hadis-i şerifte sabah namazını cemaatle kılıp güneş doğuncaya kadar Allah\'ı zikrederek ardından 2 rekât İşrak namazı kılan kimseye tam bir hac ve umre sevabı verileceği müjdelenmiştir.',
        icon: Icons.wb_sunny_outlined,
        enabled: ns.israkAlarm,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(israkAlarm: v),
          'İşrak Namazı',
          v,
        ),
      ),
      _NafilePrayerSpec(
        title: 'Kuşluk (Duha) Namazı',
        rekatBadge: '2, 4, 8 veya 12 Rekât',
        timeLabel:
            'Vakit: ${_fmt(israkTime)} – ${_fmt(duhaEnd)} • Alarm: ${_fmt(duhaBest)}',
        summary: 'Güneşin doğup kerahet vaktinin çıkmasından öğle kerahet vaktine kadar kılınan, vücudun 360 ekleminin şükrü yerine geçen müstehap namazdır.',
        guide:
            '• Vakti: Güneş doğduktan ~45-50 dk sonra (${_fmt(israkTime)}) başlar, öğle vaktine ~45 dk kalaya (${_fmt(duhaEnd)}) kadar devam eder. En faziletli vakti gündüzün dörtte biri geçtiği (${_fmt(duhaBest)}) saattir.\n'
            '• Rekâtı: En az 2, genellikle 4 veya 8, en çok 12 rekât olarak ikişer veya dörder rekâtta bir selam verilerek kılınır.\n'
            '• Niyeti: "Niyet ettim Allah rızası için Kuşluk (Duha) namazını kılmaya."\n'
            '• Kaynak: Müslim, Müsâfirîn, 84; Buhârî, Teheccüd, 31.',
        icon: Icons.light_mode_rounded,
        enabled: ns.duhaAlarm,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(duhaAlarm: v),
          'Kuşluk (Duha) Namazı',
          v,
        ),
      ),
      _NafilePrayerSpec(
        title: 'Evvâbîn Namazı',
        rekatBadge: '2, 4 veya 6 Rekât',
        timeLabel:
            'Vakit: ${_fmt(aksam)} – ${_fmt(yatsi)} • Alarm: ${_fmt(evvabinTime)}',
        summary: 'Akşam namazını kıldıktan hemen sonra, yatsı vakti girmeden önce Allah\'a yönelen kulların (evvâbîn) kıldığı 2, 4 veya 6 rekâtlık nafile namazdır.',
        guide:
            '• Vakti: Akşam namazının farzı ve sünneti kılındıktan hemen sonra (bugün ${_fmt(evvabinTime)}) yatsı vakti (${_fmt(yatsi)}) girmeden önce kılınır.\n'
            '• Rekâtı: 2, 4 veya 6 rekât olarak eda edilir (ikişer rekâtta bir selam verilmesi müstehaptır).\n'
            '• Niyeti: "Niyet ettim Allah rızası için Evvâbîn namazını kılmaya."\n'
            '• Kaynak: Tirmizî, Mevâkît, 203; İbn Mâce, İkâmet, 185.',
        icon: Icons.nights_stay_outlined,
        enabled: ns.evvabinAlarm,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(evvabinAlarm: v),
          'Evvâbîn Namazı',
          v,
        ),
      ),
      _NafilePrayerSpec(
        title: 'Teheccüd (Gece) Namazı',
        rekatBadge: '2 – 8 Rekât',
        timeLabel:
            'Seher Alarmı: ${_fmt(teheccudTime)} (İmsak: ${_fmt(imsak)})',
        summary: 'Yatsı namazından sonra biraz uyuyup gece yarısı ile imsak vakti arasında uyanılarak kılınan, farz namazlardan sonra en faziletli namazdır.',
        guide:
            '• Vakti: Yatsı namazından sonra biraz uyuyup gece yarısı ile imsak (${_fmt(imsak)}) arasında uyanılarak kılınır. En faziletli vakti gecenin son üçte biri olan seher vaktidir (Alarm saati: ${_fmt(teheccudTime)}).\n'
            '• Rekâtı: 2 ile 8 rekât arasında (ikişer rekâtta bir selam verilerek) kılınır.\n'
            '• Niyeti: "Niyet ettim Allah rızası için Teheccüd namazını kılmaya."\n'
            '• Kaynak: İsrâ Suresi, 17/79; Müslim, Sıyam, 202.',
        icon: Icons.bedtime_rounded,
        enabled: ns.teheccudAlarm,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(teheccudAlarm: v),
          'Teheccüd (Gece) Namazı',
          v,
        ),
      ),
      _NafilePrayerSpec(
        title: 'Tahiyyetü\'l-Mescid & Abdest Şükür Namazı',
        rekatBadge: '2 Rekât + 2 Rekât',
        timeLabel: 'Camiye girince & Abdest sonrası (Kerahet vakti dışında)',
        summary: 'Tahiyyetü\'l-Mescid: Camiye/mescide girildiğinde oturmadan önce kılınan 2 rekât selamlama namazıdır. Abdest Şükür: Abdest aldıktan hemen sonra azalar kurumadan kılınan 2 rekât namazdır.',
        guide:
            '• Tahiyyetü\'l-Mescid (2 Rekât): Bir camiye veya mescide girildiğinde, oturmadan önce mescidin Rabbine saygı amacıyla kılınan 2 rekâtlık sünnet namazdır (Buhârî, Salât, 60).\n'
            '• Abdest Şükür Namazı (2 Rekât): Abdest veya gusül aldıktan hemen sonra, azalar henüz kurumadan kılınan 2 rekâtlık namazdır; Hz. Bilâl-i Habeşî\'nin cennette ayak seslerinin duyulmasına vesile olan ameldir (Buhârî, Teheccüd, 17; Müslim, Fedâilü\'s-Sahâbe, 108).',
        icon: Icons.mosque_outlined,
        enabled: ns.abdestSukurReminder,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(abdestSukurReminder: v),
          'Abdest Şükür & Tahiyyetü\'l-Mescid',
          v,
        ),
      ),
      _NafilePrayerSpec(
        title: 'Cuma Namazı & Bayram Namazları',
        rekatBadge: 'Cemaatle Vakitli',
        timeLabel:
            'Cuma Hazırlık: ${_fmt(cumaPrep)} (Öğle: ${_fmt(ogle)}) • Bayram: ${_fmt(eidTime)}',
        summary: 'Cuma namazı her Cuma öğle vaktinde cemaatle kılınır (4 ilk sünnet + 2 farz + 4 son sünnet). Ramazan ve Kurban Bayramı namazları güneşten ~48 dk sonra cemaatle 2 rekât vâcip olarak kılınır.',
        guide:
            '• Cuma Namazı: Cuma günü öğle vaktinde (${_fmt(ogle)}) cemaatle kılınır; alarm öğleden 45 dk önce (${_fmt(cumaPrep)}) ve Cuma sabahı 09:30\'da hatırlatır.\n'
            '• Bayram Namazları (2 Rekât Vâcip): Ramazan ve Kurban Bayramının 1. günü güneş doğup kerahet vakti çıktıktan (~48 dk sonra, yaklaşık ${_fmt(eidTime)}) cemaatle 6 zâid tekbir alınarak kılınır.',
        icon: Icons.groups_rounded,
        enabled: ns.fridayNotification,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(fridayNotification: v, eidAlarm: v),
          'Cuma ve Bayram Namazı',
          v,
        ),
      ),
      _NafilePrayerSpec(
        title: 'Teravih Namazı',
        rekatBadge: '20 Rekât Sünnet-i Müekkede',
        timeLabel:
            'Alarm: ${_fmt(teravihTime)} (Yatsı: ${_fmt(yatsi)} sonrası)',
        summary: 'Ramazan ayı boyunca Yatsı namazının farzı ve son sünnetinden sonra, Vitir namazından önce cemaatle veya ferdi olarak 20 rekât kılınan sünnet-i müekkede namazdır.',
        guide:
            '• Vakti: Yatsı namazından (${_fmt(yatsi)}) sonra Vitir namazından önce kılınır (Alarm: ${_fmt(teravihTime)}).\n'
            '• Rekâtı: 20 rekâttır; ikişer veya dörder rekâtta bir selam verilerek eda edilir.\n'
            '• Kaynak: Buhârî, Salâtü\'t-Terâvîh, 1; Müslim, Müsâfirîn, 173.',
        icon: Icons.auto_awesome_rounded,
        enabled: ns.teravihAlarm,
        onToggle: (bool v) => _updateNotif(
          context,
          ref,
          ns.copyWith(teravihAlarm: v),
          'Teravih Namazı',
          v,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.alarm_add_rounded,
                size: 20,
                color: AppColors.emerald500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Nafile & Vakitli Özel Namaz Alarmları',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => context.push(AppRoutes.adhanSounds),
                icon: const Icon(Icons.music_note_rounded, size: 16),
                label: const Text('Ses Seç'),
              ),
            ],
          ),
          Text(
            'Kuşluk (Duha), Teheccüd, Evvâbîn, İşrak, Tahiyyetü\'l-Mescid, Abdest Şükür, Cuma, Bayram ve Teravih namazları için otomatik vakit hesabı ve sesli alarm.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final _NafilePrayerSpec spec in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: AppRadius.allMd,
                  onTap: () => _showGuideSheet(context, spec),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: spec.enabled
                                    ? AppColors.emerald500.withValues(
                                        alpha: 0.16,
                                      )
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                spec.icon,
                                size: 20,
                                color: spec.enabled
                                    ? AppColors.emerald500
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        spec.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold500.withValues(
                                            alpha: 0.18,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          spec.rekatBadge,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.gold600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    spec.timeLabel,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.emerald500,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: spec.enabled,
                              onChanged: spec.onToggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          spec.summary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showGuideSheet(BuildContext context, _NafilePrayerSpec spec) {
    final ThemeData theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(spec.icon, color: AppColors.emerald500),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${spec.title} (${spec.rekatBadge})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                spec.timeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.emerald500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                spec.guide,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
