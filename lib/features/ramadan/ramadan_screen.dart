import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../../data/models/hijri_date.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../data/models/ramadan_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../data/models/dua_models.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Ramazan ekranı: sahur/iftar geri sayımı, imsakiye, hatim, kaza ve günlük dua.
class RamadanScreen extends ConsumerStatefulWidget {
  const RamadanScreen({super.key});

  @override
  ConsumerState<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends ConsumerState<RamadanScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<
      ({
        PrayerTimesDay today,
        PrayerTimesDay tomorrow,
        DateTime imsak,
        DateTime iftar,
      })
    >
    today = ref.watch(ramadanTodayProvider);
    final HijriDate hijri = ref.watch(hijriTodayProvider);
    final int dayNumber = ref.watch(runtimeProvider).ramadan.ramadanDayNumber();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramazan'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Bildirim ayarları',
            onPressed: () => context.push(AppRoutes.notificationSettings),
            icon: const Icon(Icons.notifications_active_outlined, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.emeraldGradient),
                borderRadius: AppRadius.allLg,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    hijri.isRamadan
                        ? 'Ramazan ${hijri.day}. gün'
                        : hijri.longFormatted,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    hijri.isRamadan
                        ? '$dayNumber. gün · ${hijri.longFormatted}'
                        : 'Ramazan ayına ${_daysToRamadan(hijri)} gün kaldı',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  today.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    error: (Object error, StackTrace stackTrace) => Text(
                      'Vakitler alınamadı: $error',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    data:
                        (
                          ({
                            PrayerTimesDay today,
                            PrayerTimesDay tomorrow,
                            DateTime imsak,
                            DateTime iftar,
                          })
                          value,
                        ) {
                          final bool beforeIftar = _now.isBefore(value.iftar);
                          final Duration remaining = beforeIftar
                              ? value.iftar.difference(_now)
                              : value.imsak.isAfter(_now)
                              ? value.imsak.difference(_now)
                              : value.tomorrow
                                        .timeOf(Prayer.imsak)
                                        ?.difference(_now) ??
                                    Duration.zero;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                beforeIftar ? 'İftara kalan' : 'Sahura kalan',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppTime.formatClock(remaining),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: <Widget>[
                                  _TimeChip(
                                    label: 'İmsak',
                                    time: AppTime.formatTime(
                                      value.imsak,
                                      use24Hour: ref
                                          .watch(settingsProvider)
                                          .use24Hour,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _TimeChip(
                                    label: 'İftar',
                                    time: AppTime.formatTime(
                                      value.iftar,
                                      use24Hour: ref
                                          .watch(settingsProvider)
                                          .use24Hour,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
          if (hijri.isRamadan) _TodayLogCard(date: _now),
          const SectionHeader(title: 'Hatim takibi'),
          const _HatimSection(),
          const SectionHeader(title: 'Kaza orucu takibi'),
          const _KazaSection(),
          const SectionHeader(title: 'İmsakiye'),
          const _ImsakiyeSection(),
          const SectionHeader(title: 'Günün duası'),
          const _DailyDuaCard(),
          const SizedBox(height: AppSpacing.md),
          const AdBanner(),
        ],
      ),
    );
  }

  int _daysToRamadan(HijriDate hijri) {
    // Ramazan 9. ay; hicri yıl uzunluğu 354 gün olduğu için yaklaşık fark:
    final int monthsAhead = (9 - hijri.month + 12) % 12;
    return monthsAhead == 0 ? 0 : monthsAhead * 30 - hijri.day + 1;
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $time',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TodayLogCard extends ConsumerWidget {
  const _TodayLogCard({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RamadanDayLog?> log = ref.watch(todayLogProvider);
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: log.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (Object error, StackTrace stackTrace) => Text(
              'Bugünün kaydı okunamadı: $error',
              style: theme.textTheme.labelSmall,
            ),
            data: (RamadanDayLog? value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bugünün ibadet kaydı',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: value?.fasted ?? false,
                  title: const Text('Oruç tuttum'),
                  onChanged: (bool v) => _save(ref, value, fasted: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: value?.tarawih ?? false,
                  title: const Text('Teravih kıldım'),
                  onChanged: (bool v) => _save(ref, value, tarawih: v),
                ),
                Row(
                  children: <Widget>[
                    Text('Okunan sayfa: ${value?.quranPages ?? 0}'),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Bir sayfa azalt',
                      onPressed: () => _save(
                        ref,
                        value,
                        pages: ((value?.quranPages ?? 0) - 1).clamp(0, 999),
                      ),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    IconButton(
                      tooltip: 'Bir sayfa ekle',
                      onPressed: () => _save(
                        ref,
                        value,
                        pages: (value?.quranPages ?? 0) + 1,
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded),
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

  Future<void> _save(
    WidgetRef ref,
    RamadanDayLog? current, {
    bool? fasted,
    bool? tarawih,
    int? pages,
  }) async {
    final RamadanDayLog updated = RamadanDayLog(
      date: DateTime(date.year, date.month, date.day),
      fasted: fasted ?? current?.fasted ?? false,
      tarawih: tarawih ?? current?.tarawih ?? false,
      quranPages: pages ?? current?.quranPages ?? 0,
      note: current?.note,
    );
    try {
      await ref.read(runtimeProvider).ramadan.saveDayLog(updated);
      ref.invalidate(todayLogProvider);
      ref.invalidate(ramadanLogsProvider);
      ref.invalidate(ramadanSummaryProvider);
    } catch (error) {
      AppLog.warning('Ramazan kaydı yazılamadı: $error');
    }
  }
}

class _HatimSection extends ConsumerWidget {
  const _HatimSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<JuzProgress>> progress = ref.watch(
      hatimProgressProvider,
    );
    return progress.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: LoadingView(message: 'Hatim durumu yükleniyor…'),
      ),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(hatimProgressProvider),
      ),
      data: (List<JuzProgress> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              '${items.where((JuzProgress j) => j.status == JuzStatus.done).length} / 30 cüz tamam',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Semantics(
              label: 'Hatim cüzleri: dokunarak işaretleyin',
              child: GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final JuzProgress juz in items)
                    InkWell(
                      borderRadius: AppRadius.allMd,
                      onTap: () async {
                        await ref
                            .read(runtimeProvider)
                            .ramadan
                            .updateJuz(
                              juz.juz,
                              juz.status == JuzStatus.done
                                  ? JuzStatus.pending
                                  : JuzStatus.done,
                            );
                        ref.invalidate(hatimProgressProvider);
                        ref.invalidate(ramadanSummaryProvider);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: juz.status == JuzStatus.done
                              ? AppColors.emerald500.withValues(alpha: 0.18)
                              : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                          borderRadius: AppRadius.allMd,
                          border: Border.all(
                            color: juz.status == JuzStatus.done
                                ? AppColors.emerald500
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          '${juz.juz}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: juz.status == JuzStatus.done
                                    ? AppColors.emerald500
                                    : null,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KazaSection extends ConsumerWidget {
  const _KazaSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<KazaFast>> kaza = ref.watch(kazaFastsProvider);
    return kaza.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: LoadingView(message: 'Kaza kayıtları yükleniyor…'),
      ),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(kazaFastsProvider),
      ),
      data: (List<KazaFast> items) => Column(
        children: <Widget>[
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Kaza orucu kaydınız yok. Borcunuz varsa aşağıdaki düğmeyle ekleyebilirsiniz.',
              ),
            ),
          for (final KazaFast fast in items)
            CheckboxListTile(
              value: fast.completed,
              title: Text(
                fast.completed ? 'Kaza orucu kılındı' : 'Kaza orucu bekliyor',
              ),
              subtitle: Text(
                <String>[
                  if (fast.dueDate != null) 'Hedef tarih: ${fast.dueDate}',
                  if (fast.note != null && fast.note!.isNotEmpty) fast.note!,
                ].join(' · '),
              ),
              secondary: IconButton(
                tooltip: 'Kaydı sil',
                onPressed: () async {
                  await ref
                      .read(runtimeProvider)
                      .ramadan
                      .deleteKazaFast(fast.id);
                  ref.invalidate(kazaFastsProvider);
                  ref.invalidate(ramadanSummaryProvider);
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
              ),
              onChanged: (bool? value) async {
                await ref
                    .read(runtimeProvider)
                    .ramadan
                    .completeKazaFast(fast.id, completed: value ?? false);
                ref.invalidate(kazaFastsProvider);
                ref.invalidate(ramadanSummaryProvider);
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(runtimeProvider).ramadan.addKazaFast();
                    ref.invalidate(kazaFastsProvider);
                    ref.invalidate(ramadanSummaryProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kaza orucu eklendi.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Kaza orucu ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImsakiyeSection extends ConsumerWidget {
  const _ImsakiyeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PrayerTimesDay>> imsakiye = ref.watch(
      imsakiyeProvider,
    );
    final bool use24 = ref.watch(settingsProvider).use24Hour;
    return imsakiye.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: LoadingView(message: 'İmsakiye hazırlanıyor…'),
      ),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(imsakiyeProvider),
      ),
      data: (List<PrayerTimesDay> days) => Column(
        children: <Widget>[
          for (final PrayerTimesDay day in days.take(30))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 74,
                    child: Text(
                      AppTime.formatDateShort(day.date),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'İmsak ${AppTime.formatTime(day.timeOf(Prayer.imsak) ?? day.date, use24Hour: use24)}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'İftar ${AppTime.formatTime(day.timeOf(Prayer.aksam) ?? day.date, use24Hour: use24)}',
                      style: Theme.of(context).textTheme.labelMedium,
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

class _DailyDuaCard extends ConsumerWidget {
  const _DailyDuaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Dua?> dua = ref.watch(dailyDuaProvider);
    final ThemeData theme = Theme.of(context);
    return dua.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: LoadingView(message: 'Dua yükleniyor…'),
      ),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(dailyDuaProvider),
      ),
      data: (Dua? value) {
        if (value == null) {
          return const EmptyView(
            icon: Icons.volunteer_activism_outlined,
            title: 'Dua bulunamadı',
            message:
                'Dua içeriği okunamadı. Uygulamayı yeniden başlatmayı deneyin.',
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.gold500.withValues(alpha: 0.10),
              borderRadius: AppRadius.allLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (value.hasArabic) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    value.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Amiri',
                      height: 1.9,
                    ),
                  ),
                ],
                if (value.transliteration.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    value.transliteration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (value.meaning.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(value.meaning, style: theme.textTheme.bodyMedium),
                ],
                if (value.reference.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      value.reference,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
