import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

import '../../core/utils/logger.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/zikir_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Tesbih ekranı: dokunarak zikir sayacı, hedef ve günlük özet.
class ZikirScreen extends ConsumerWidget {
  const ZikirScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Zikir>> zikirler = ref.watch(zikirListProvider);
    final ZikirCounterState counter = ref.watch(zikirCounterProvider);
    final AsyncValue<ZikirDailySummary> summary = ref.watch(
      zikirDailySummaryProvider,
    );
    final AppSettings settings = ref.watch(settingsProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tesbih'),
        actions: <Widget>[
          IconButton(
            tooltip: 'İstatistikler',
            onPressed: () => context.push(AppRoutes.zikirStats),
            icon: const Icon(Icons.insights_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Ayarlar',
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.tune_rounded, size: 20),
          ),
        ],
      ),
      body: zikirler.when(
        loading: () => const LoadingView(message: 'Zikirler yükleniyor…'),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(zikirListProvider),
        ),
        data: (List<Zikir> items) {
          Zikir selected = items.first;
          for (final Zikir zikir in items) {
            if (zikir.key == counter.zikirKey) selected = zikir;
          }
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final Zikir zikir = items[index];
                      return ChoiceChip(
                        label: Text(zikir.name),
                        selected: zikir.key == counter.zikirKey,
                        onSelected: (_) => ref
                            .read(zikirCounterProvider.notifier)
                            .selectZikir(zikir.key, zikir.defaultTarget),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) =>
                      SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _increment(ref, settings),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  selected.arabic,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontFamily: 'Amiri',
                                        color: AppColors.gold600,
                                        height: 1.8,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  selected.transliteration,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 250,
                                      height: 250,
                                      child: CircularProgressIndicator(
                                        value: counter.progress,
                                        strokeWidth: 12,
                                        backgroundColor: theme
                                            .colorScheme
                                            .outlineVariant
                                            .withValues(alpha: 0.3),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              counter.reached
                                                  ? AppColors.success
                                                  : AppColors.emerald500,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          '${counter.count}',
                                          style: theme.textTheme.displayMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -2,
                                              ),
                                        ),
                                        Text(
                                          'hedef ${counter.target}',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Saymak için ekrana dokunun',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (counter.completedSessions > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      'Bu oturumda ${counter.completedSessions} tur tamamlandı',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: AppColors.success),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: counter.count == 0
                            ? null
                            : () => ref
                                  .read(zikirCounterProvider.notifier)
                                  .reset(),
                        icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        label: const Text('Sıfırla'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _showTargetSheet(context, ref, counter),
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        label: const Text('Hedef'),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: summary.when(
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (Object error, StackTrace stackTrace) => Text(
                    'Günlük özet yüklenemedi: $error',
                    style: theme.textTheme.labelSmall,
                  ),
                  data: (ZikirDailySummary value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.today_rounded, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Bugün toplam ${value.totalCount} zikir',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${(value.progress * 100).round()}%',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: value.targetReached
                                  ? AppColors.success
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: value.progress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        value.targetReached
                            ? 'Günlük hedef tamam — Allah kabul etsin.'
                            : 'Günlük hedefe ${(value.target - value.totalCount).clamp(0, value.target)} zikir kaldı '
                                  '(hedef ${value.target}).',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (value.byZikir.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: <Widget>[
                            for (final MapEntry<String, int> entry
                                in value.byZikir.entries)
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text('${entry.key}: ${entry.value}'),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _increment(WidgetRef ref, AppSettings settings) async {
    if (settings.zikirVibrationEnabled) {
      try {
        final bool hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) await Vibration.vibrate(duration: 35);
      } catch (error) {
        AppLog.debug('Titreşim kullanılamadı: $error');
      }
    }
    if (settings.zikirSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (error) {
        AppLog.debug('Tık sesi çalınamadı: $error');
      }
    }
    await ref.read(zikirCounterProvider.notifier).increment();
    if (settings.zikirAutoAdvance) {
      ref.invalidate(zikirDailySummaryProvider);
    }
  }

  void _showTargetSheet(
    BuildContext context,
    WidgetRef ref,
    ZikirCounterState counter,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Hedef sayı',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final int option in <int>[33, 99, 100, 500, 1000])
              ListTile(
                leading: Icon(
                  counter.target == option
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: counter.target == option
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text('$option'),
                onTap: () {
                  ref.read(zikirCounterProvider.notifier).setTarget(option);
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setZikirPreferences(defaultTarget: option);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
