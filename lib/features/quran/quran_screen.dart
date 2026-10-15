import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/quran_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../ilahi/player_controller.dart';
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
    final QuranTranslation translation = QuranTranslations.byId(
      ref.watch(settingsProvider.select((s) => s.quranTranslationId)),
    );
    final ThemeData theme = Theme.of(context);

    final int resumeSurah = progress?.surah ?? 1;
    final int resumeAyah = progress?.lastAyah ?? 1;

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Kur\'an-ı Kerim',
        subtitle: '${translation.shortLabel} · ${reciter.name}',
        actions: <Widget>[
          IconButton(
            tooltip: 'Meal dili ve çevrimdışı indirme',
            onPressed: () => _showTranslationSheet(context, ref, translation),
            icon: const Icon(Icons.translate_rounded, size: 20),
          ),
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
      bottomNavigationBar: const PlayerBar(),
      body: CustomScrollView(
        slivers: <Widget>[
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
                    vertical: AppSpacing.xs,
                  ),
                  leading: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.emerald500,
                  ),
                  title: const Text('Okumaya devam et'),
                  subtitle: Text(
                    progress == null
                        ? '$resumeSurah. sure, $resumeAyah. ayet · ${translation.shortLabel}'
                        : '$resumeSurah. sure, $resumeAyah. ayet · '
                              '${progress.readAt.day}.${progress.readAt.month}.${progress.readAt.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () =>
                        _showTranslationSheet(context, ref, translation),
                    icon: const Icon(Icons.translate_rounded, size: 16),
                    label: Text(
                      translation.languageCode.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  onTap: () => context.push(
                    AppRoutes.surah(resumeSurah, ayah: resumeAyah),
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
                    child: InkWell(
                      borderRadius: AppRadius.allMd,
                      onTap: () => _showJuzSheet(context),
                      child: _MiniStat(
                        icon: Icons.bookmark_added_outlined,
                        label: 'Okunan cüz (Sec)',
                        value: '$completedJuz / 30',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InkWell(
                      borderRadius: AppRadius.allMd,
                      onTap: () => _showReciterSheet(context, ref, reciter),
                      child: _MiniStat(
                        icon: Icons.record_voice_over_outlined,
                        label: 'Okuyucu',
                        value: reciter.name.split(' ').first,
                      ),
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
                onPressed: () => _showJuzSheet(context),
                child: const Text('Cüzler (30)'),
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

  void _showTranslationSheet(
    BuildContext context,
    WidgetRef ref,
    QuranTranslation current,
  ) {
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
              AppSpacing.xs,
            ),
            child: Text(
              'Meal dili ve çevrimdışı paketler',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Kur\'an mealini kendi dilinizde okuyabilir veya çevrimdışı kullanım için indirebilirsiniz.',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final QuranTranslation item in QuranTranslations.all)
            ListTile(
              leading: Icon(
                item.id == current.id
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: item.id == current.id
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(item.name),
              subtitle: Text(
                '${item.languageName} · ${item.bundledOffline ? 'Çevrimdışı hazır' : 'İndirilebilir meal'}',
              ),
              trailing: Icon(
                item.bundledOffline
                    ? Icons.offline_pin_rounded
                    : Icons.cloud_download_outlined,
                color: item.bundledOffline ? AppColors.emerald500 : null,
                size: 20,
              ),
              onTap: () async {
                await ref
                    .read(settingsControllerProvider.notifier)
                    .setQuranTranslation(item.id);
                ref.invalidate(surahContentProvider);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item.name} etkinleştirildi (${item.shortLabel}).',
                      ),
                    ),
                  );
                }
                await ref
                    .read(runtimeProvider)
                    .quran
                    .downloadTranslation(item.id);
                ref.invalidate(surahContentProvider);
              },
            ),
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

  static const List<({int juz, int surah, int ayah, String label})> _juzStarts =
      <({int juz, int surah, int ayah, String label})>[
        (juz: 1, surah: 1, ayah: 1, label: 'Fâtiha 1. Ayet'),
        (juz: 2, surah: 2, ayah: 142, label: 'Bakara 142. Ayet'),
        (juz: 3, surah: 2, ayah: 253, label: 'Bakara 253. Ayet'),
        (juz: 4, surah: 3, ayah: 93, label: 'Âl-i İmrân 93. Ayet'),
        (juz: 5, surah: 4, ayah: 24, label: 'Nisâ 24. Ayet'),
        (juz: 6, surah: 4, ayah: 148, label: 'Nisâ 148. Ayet'),
        (juz: 7, surah: 5, ayah: 82, label: 'Mâide 82. Ayet'),
        (juz: 8, surah: 6, ayah: 111, label: 'En\'âm 111. Ayet'),
        (juz: 9, surah: 7, ayah: 88, label: 'A\'râf 88. Ayet'),
        (juz: 10, surah: 8, ayah: 41, label: 'Enfâl 41. Ayet'),
        (juz: 11, surah: 9, ayah: 93, label: 'Tevbe 93. Ayet'),
        (juz: 12, surah: 11, ayah: 6, label: 'Hûd 6. Ayet'),
        (juz: 13, surah: 12, ayah: 53, label: 'Yûsuf 53. Ayet'),
        (juz: 14, surah: 15, ayah: 1, label: 'Hicr 1. Ayet'),
        (juz: 15, surah: 17, ayah: 1, label: 'İsrâ 1. Ayet'),
        (juz: 16, surah: 18, ayah: 75, label: 'Kehf 75. Ayet'),
        (juz: 17, surah: 21, ayah: 1, label: 'Enbiyâ 1. Ayet'),
        (juz: 18, surah: 23, ayah: 1, label: 'Mü\'minûn 1. Ayet'),
        (juz: 19, surah: 25, ayah: 21, label: 'Furkan 21. Ayet'),
        (juz: 20, surah: 27, ayah: 56, label: 'Neml 56. Ayet'),
        (juz: 21, surah: 29, ayah: 46, label: 'Ankebût 46. Ayet'),
        (juz: 22, surah: 33, ayah: 31, label: 'Ahzâb 31. Ayet'),
        (juz: 23, surah: 36, ayah: 28, label: 'Yâsîn 28. Ayet'),
        (juz: 24, surah: 39, ayah: 32, label: 'Zümer 32. Ayet'),
        (juz: 25, surah: 41, ayah: 47, label: 'Fussilet 47. Ayet'),
        (juz: 26, surah: 46, ayah: 1, label: 'Ahkâf 1. Ayet'),
        (juz: 27, surah: 51, ayah: 31, label: 'Zâriyât 31. Ayet'),
        (juz: 28, surah: 58, ayah: 1, label: 'Mücâdele 1. Ayet'),
        (juz: 29, surah: 67, ayah: 1, label: 'Mülk 1. Ayet'),
        (juz: 30, surah: 78, ayah: 1, label: 'Nebe 1. Ayet (Amme Cüzü)'),
      ];

  void _showJuzSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        builder: (BuildContext context, ScrollController controller) =>
            ListView.builder(
              controller: controller,
              itemCount: _juzStarts.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: Text(
                      'Cüz Seçimi (1–30. Cüz — e-Diyanet Fihristi)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }
                final item = _juzStarts[index - 1];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.emerald500.withValues(
                      alpha: 0.14,
                    ),
                    foregroundColor: AppColors.emerald500,
                    child: Text(
                      '${item.juz}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: Text(
                    '${item.juz}. Cüz',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('Başlangıç: ${item.label}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    thisContextPush(context, item.surah, item.ayah);
                  },
                );
              },
            ),
      ),
    );
  }

  void thisContextPush(BuildContext context, int surah, int ayah) {
    context.push(AppRoutes.surah(surah, ayah: ayah));
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
