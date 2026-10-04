import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/logger.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/quran_models.dart';
import '../../data/repositories/quran_repository.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Sure okuma ekranı: Arapça metin, meal, tilavet ve favori işlemleri.
class SurahScreen extends ConsumerStatefulWidget {
  const SurahScreen({required this.surahNumber, this.initialAyah, super.key});

  final int surahNumber;
  final int? initialAyah;

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();

  int _lastSavedAyah = 0;
  int? _playingAyah;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_rememberPosition);
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_rememberPosition);
    super.dispose();
  }

  void _rememberPosition() {
    final Iterable<ItemPosition> visible = _positions.itemPositions.value.values
        .where((ItemPosition position) => position.itemLeadingEdge >= 0 && position.itemLeadingEdge < 0.4);
    if (visible.isEmpty) return;
    final int index = visible.first.index;
    final int ayahNumber = index + 1;
    if (ayahNumber == _lastSavedAyah) return;
    _lastSavedAyah = ayahNumber;
    ref.read(runtimeProvider).quran.saveProgress(widget.surahNumber, ayahNumber);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SurahContent> content = ref.watch(surahContentProvider(widget.surahNumber));
    final AppSettings settings = ref.watch(settingsProvider);
    final Set<int> bookmarks = ref.watch(quranBookmarkIdsProvider).value ?? const <int>{};
    final Reciter reciter = ref.watch(selectedReciterProvider);

    return Scaffold(
      appBar: AppBar(
        title: content.maybeWhen(
          data: (SurahContent value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(value.surah.nameTurkish, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                '${value.surah.meaning} · ${value.surah.verseCount} ayet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          orElse: () => const Text('Kur\'an'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Yazı boyutu',
            onPressed: () => _showFontSheet(context, ref, settings),
            icon: const Icon(Icons.format_size_rounded, size: 20),
          ),
          IconButton(
            tooltip: settings.quranShowTranslation ? 'Meali gizle' : 'Meali göster',
            onPressed: () => ref
                .read(settingsControllerProvider.notifier)
                .update(
                  settings.copyWith(quranShowTranslation: !settings.quranShowTranslation),
                  rescheduleNotifications: false,
                ),
            icon: Icon(
              settings.quranShowTranslation
                  ? Icons.translate_rounded
                  : Icons.translate_outlined,
              size: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: content.value?.ayahs.isEmpty ?? true
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _playSurah(content.value!, reciter),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_playingAyah == null ? 'Süreyi dinle' : 'Çalınıyor'),
            ),
      body: content.when(
        loading: () => const LoadingView(message: 'Sure yükleniyor…'),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(surahContentProvider(widget.surahNumber)),
        ),
        data: (SurahContent value) {
          if (value.ayahs.isEmpty) {
            return const EmptyView(
              icon: Icons.menu_book_outlined,
              title: 'Sure içeriği bulunamadı',
              message: 'Kur\'an verisi eksik görünüyor. Uygulamayı yeniden başlatmayı deneyin.',
            );
          }
          return ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positions,
            initialScrollIndex: _initialIndex(value),
            itemCount: value.ayahs.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _SurahHeader(
                  surah: value.surah,
                  showBasmala: widget.surahNumber != 1 && widget.surahNumber != 9,
                );
              }
              final Ayah ayah = value.ayahs[index - 1];
              final bool isBookmarked = bookmarks.contains(value.surah.number * 1000 + ayah.number);
              return _AyahCard(
                ayah: ayah,
                fontSize: settings.quranFontSize,
                showTranslation: settings.quranShowTranslation,
                isBookmarked: isBookmarked,
                isPlaying: _playingAyah == ayah.number,
                onBookmark: () async {
                  await ref.read(runtimeProvider).quran.toggleBookmark(ayah.surah, ayah.number);
                  ref.invalidate(quranBookmarkIdsProvider);
                  ref.invalidate(quranBookmarksProvider);
                },
                onShare: () => SharePlus.instance.share(
                  ShareParams(
                    text: QuranRepository.shareText(
                      ayah,
                      value.surah.nameTurkish,
                      withTurkish: settings.quranShowTranslation,
                    ),
                    subject: '${value.surah.nameTurkish} ${ayah.number}. ayet',
                  ),
                ),
                onCopy: () async {
                  await Clipboard.setData(ClipboardData(text: ayah.turkish));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal kopyalandı.')),
                    );
                  }
                },
                onPlay: () => _playAyah(ayah, reciter),
              );
            },
          );
        },
      ),
    );
  }

  int _initialIndex(SurahContent content) {
    final int? target = widget.initialAyah;
    if (target == null) return 0;
    final int index = content.ayahs.indexWhere((Ayah ayah) => ayah.number == target);
    return index <= 0 ? 0 : index + 1;
  }

  Future<void> _playAyah(Ayah ayah, Reciter reciter) async {
    final String url = Reciters.ayahUrl(reciter, ayah.surah, ayah.number);
    setState(() => _playingAyah = ayah.number);
    final bool ok = await ref.read(runtimeProvider).audio.playUrl(
          url,
          title: '${ayah.surah}. sure ${ayah.number}. ayet',
          artist: reciter.name,
          album: 'Kur\'an-ı Kerim',
          id: 'ayah-${ayah.surah}-${ayah.number}',
        );
    if (!ok && mounted) {
      setState(() => _playingAyah = null);
      final AppSettings settings = ref.read(settingsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settings.streamingOnlyOnWifi
                ? 'Yalnızca Wi-Fi üzerinden indirme açık. Ayarlardan değiştirebilirsiniz.'
                : 'Ayet sesi açılamadı. İnternet bağlantınızı kontrol edin.',
          ),
        ),
      );
    }
  }

  Future<void> _playSurah(SurahContent content, Reciter reciter) async {
    // Tüm sureyi, ayet ayet sıralı kaynak listesi olarak çalar.
    final List<String> urls = <String>[
      for (final Ayah ayah in content.ayahs)
        Reciters.ayahUrl(reciter, content.surah.number, ayah.number),
    ];
    if (urls.isEmpty) return;
    setState(() => _playingAyah = content.ayahs.first.number);
    final bool ok = await ref.read(runtimeProvider).audio.playUrl(
          urls.first,
          title: '${content.surah.nameTurkish} Suresi',
          artist: reciter.name,
          album: 'Kur\'an-ı Kerim',
          id: 'surah-${content.surah.number}',
        );
    if (!ok) {
      AppLog.warning('Sure sesi başlatılamadı');
      if (mounted) {
        setState(() => _playingAyah = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tilavet başlatılamadı. Bağlantınızı kontrol edin.')),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${content.surah.nameTurkish} dinleniyor. Ayet sırası için '
              'ayetlerin yanındaki oynat düğmesini kullanabilirsiniz.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showFontSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Yazı boyutu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),
                Slider(
                  value: settings.quranFontSize,
                  min: 18,
                  max: 44,
                  divisions: 13,
                  label: settings.quranFontSize.toStringAsFixed(0),
                  onChanged: (double value) {
                    setState(() {});
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setQuranFontSize(value);
                  },
                ),
                Text(
                  'بِسْمِ اللّٰهِ',
                  style: AppTheme.arabic(Theme.of(context).textTheme, size: settings.quranFontSize),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.quranShowTranslation,
                  title: const Text('Türkçe meali göster'),
                  onChanged: (bool value) => ref
                      .read(settingsControllerProvider.notifier)
                      .update(
                        settings.copyWith(quranShowTranslation: value),
                        rescheduleNotifications: false,
                      ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.quranAutoScroll,
                  title: const Text('Okurken otomatik kaydır'),
                  onChanged: (bool value) => ref
                      .read(settingsControllerProvider.notifier)
                      .update(
                        settings.copyWith(quranAutoScroll: value),
                        rescheduleNotifications: false,
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

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah, required this.showBasmala});

  final Surah surah;
  final bool showBasmala;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.emeraldGradient),
              borderRadius: AppRadius.allLg,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  surah.nameArabic,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Amiri',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${surah.nameTurkish} · ${surah.meaning}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${surah.verseCount} ayet · ${surah.revelation} dönemi',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          if (showBasmala) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحٖيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(theme.textTheme, size: 26, color: AppColors.gold600),
            ),
          ],
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.fontSize,
    required this.showTranslation,
    required this.isBookmarked,
    required this.isPlaying,
    required this.onBookmark,
    required this.onShare,
    required this.onCopy,
    required this.onPlay,
  });

  final Ayah ayah;
  final double fontSize;
  final bool showTranslation;
  final bool isBookmarked;
  final bool isPlaying;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.emerald600.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: AppRadius.allLg,
          border: Border.all(
            color: isPlaying
                ? AppColors.emerald500.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${ayah.surah}:${ayah.number}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: isPlaying ? 'Çalıyor' : 'Ayeti dinle',
                  onPressed: onPlay,
                  icon: Icon(
                    isPlaying ? Icons.graphic_eq_rounded : Icons.play_circle_outline_rounded,
                    size: 20,
                    color: isPlaying ? AppColors.emerald500 : null,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: isBookmarked ? 'Favoriden çıkar' : 'Favorilere ekle',
                  onPressed: onBookmark,
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 20,
                    color: isBookmarked ? AppColors.gold600 : null,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Paylaş',
                  onPressed: onShare,
                  icon: const Icon(Icons.ios_share_rounded, size: 19),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Meali kopyala',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_all_rounded, size: 19),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ayah.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(theme.textTheme, size: fontSize),
            ),
            if (showTranslation) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                ayah.turkish,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
