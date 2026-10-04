import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/quran_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Kur'an ana ekranı: kaldığın yer, arama, favoriler ve sure listesi.
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Surah>> surahs = ref.watch(surahListProvider);
    final ReadingProgress? progress = ref.watch(quranProgressProvider).value;
    final int completedJuz = ref.watch(quranCompletedJuzProvider).value ?? 0;
    final Reciter reciter = ref.watch(selectedReciterProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Kur\'an-ı Kerim',
        subtitle: 'Meal ve tilavet · ${reciter.name}',
        actions: <Widget>[
          IconButton(
            tooltip: 'Ara',
            onPressed: () => context.push(AppRoutes.quranSearch),
            icon: const Icon(Icons.search_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Favoriler ve geçmiş',
            onPressed: () => context.push(AppRoutes.quranBookmarks),
            icon: const Icon(Icons.bookmark_border_rounded, size: 20),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          if (progress != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Material(
                  color: AppColors.emerald600.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allLg,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    leading: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.emerald500,
                    ),
                    title: const Text('Okumaya devam et'),
                    subtitle: Text(
                      '${progress.surah}. sure, ${progress.lastAyah}. ayet · '
                      '${progress.readAt.day}.${progress.readAt.month}.${progress.readAt.year}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(
                      AppRoutes.surah(progress.surah, ayah: progress.lastAyah),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.bookmark_added_outlined,
                      label: 'Okunan cüz',
                      value: '$completedJuz / 30',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.record_voice_over_outlined,
                      label: 'Okuyucu',
                      value: reciter.name.split(' ').first,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Sureler',
              action: TextButton(
                onPressed: () => _showReciterSheet(context, ref, reciter),
                child: const Text('Okuyucu'),
              ),
            ),
          ),
          surahs.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
                child: LoadingView(message: 'Sure listesi hazırlanıyor…'),
              ),
            ),
            error: (Object error, StackTrace stackTrace) => SliverToBoxAdapter(
              child: ErrorView(
                error: error,
                onRetry: () => ref.invalidate(surahListProvider),
              ),
            ),
            data: (List<Surah> items) => SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (BuildContext context, int index) {
                final Surah surah = items[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${surah.number}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(surah.nameTurkish),
                  subtitle: Text(
                    '${surah.meaning} · ${surah.verseCount} ayet · ${surah.revelation}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    surah.nameArabic,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Amiri',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => context.push(AppRoutes.surah(surah.number)),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(child: AdBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],
      ),
    );
  }

  void _showReciterSheet(BuildContext context, WidgetRef ref, Reciter current) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Text(
              'Tilavet okuyucusu',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Tilavetler açık lisanslı EveryAyah arşivinden akıtılır; indirilen '
              'sureler çevrimdışı dinlenebilir.',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final Reciter reciter in Reciters.all)
            ListTile(
              leading: Icon(
                reciter.id == current.id
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: reciter.id == current.id
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(reciter.name),
              subtitle: Text('${reciter.style} · ${reciter.arabicName}'),
              onTap: () async {
                await ref
                    .read(settingsControllerProvider.notifier)
                    .setQuranReciter(reciter.id);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: AppRadius.allMd,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
