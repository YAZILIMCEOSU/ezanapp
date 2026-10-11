import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/audio/audio_service.dart';
import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/quran_models.dart';
import '../../data/repositories/quran_repository.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Sure okuma ekranı: Arapça metin, meal, yatay MediaPlayer ve yaşlı dostu ok takipli okuma.
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

  StreamSubscription<int>? _queueSub;
  StreamSubscription<PlaybackStatus>? _statusSub;
  StreamSubscription<Duration>? _positionSub;
  int _lastSavedAyah = 0;
  int? _playingAyah;
  int _trackedAyah = 1;
  int _manualWordIndex = 0;
  bool _arrowTrackingEnabled = true;
  PlaybackStatus _playbackStatus = PlaybackStatus.idle;
  Duration _ayahPosition = Duration.zero;
  Duration _ayahDuration = Duration.zero;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _trackedAyah = (widget.initialAyah != null && widget.initialAyah! > 0)
        ? widget.initialAyah!
        : 1;
    _positions.itemPositions.addListener(_rememberPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AppAudioService audio = ref.read(runtimeProvider).audio;
      _playbackSpeed = audio.speed;
      _queueSub = audio.queueIndexStream.listen((int idx) {
        if (!mounted || _playingAyah == null) return;
        final int nextAyah = idx + 1;
        setState(() {
          _playingAyah = nextAyah;
          _trackedAyah = nextAyah;
          _manualWordIndex = 0;
          _ayahPosition = Duration.zero;
          _ayahDuration = audio.duration ?? Duration.zero;
        });
        if (ref.read(settingsProvider).quranAutoScroll ||
            _arrowTrackingEnabled) {
          _scrollToAyah(nextAyah);
        }
      });
      _statusSub = audio.statusStream.listen((PlaybackStatus status) {
        if (!mounted) return;
        setState(() {
          _playbackStatus = status;
          if (status == PlaybackStatus.completed ||
              status == PlaybackStatus.idle ||
              status == PlaybackStatus.error) {
            _playingAyah = null;
            _ayahPosition = Duration.zero;
          }
        });
      });
      _positionSub = audio.positionStream.listen((Duration pos) {
        if (!mounted || _playingAyah == null) return;
        setState(() {
          _ayahPosition = pos;
          _ayahDuration = audio.duration ?? _ayahDuration;
        });
      });
    });
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    _statusSub?.cancel();
    _positionSub?.cancel();
    _positions.itemPositions.removeListener(_rememberPosition);
    super.dispose();
  }

  void _scrollToAyah(int ayahNumber) {
    if (!_scrollController.isAttached) return;
    try {
      _scrollController.scrollTo(
        index: ayahNumber,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        alignment: 0.14,
      );
    } catch (_) {}
  }

  void _rememberPosition() {
    final Iterable<ItemPosition> visible = _positions.itemPositions.value.where(
      (ItemPosition position) =>
          position.itemLeadingEdge >= 0 && position.itemLeadingEdge < 0.4,
    );
    if (visible.isEmpty) return;
    final int index = visible.first.index;
    final int ayahNumber = index <= 0 ? 1 : index;
    if (ayahNumber == _lastSavedAyah) return;
    _lastSavedAyah = ayahNumber;
    ref
        .read(runtimeProvider)
        .quran
        .saveProgress(widget.surahNumber, ayahNumber);
  }

  double get _currentAyahProgress {
    if (_ayahDuration.inMilliseconds <= 0) return 0.0;
    return (_ayahPosition.inMilliseconds / _ayahDuration.inMilliseconds)
        .clamp(0.0, 0.999)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SurahContent> content = ref.watch(
      surahContentProvider(widget.surahNumber),
    );
    final AppSettings settings = ref.watch(settingsProvider);
    final Set<int> bookmarks =
        ref.watch(quranBookmarkIdsProvider).value ?? const <int>{};
    final Reciter reciter = ref.watch(selectedReciterProvider);
    final QuranTranslation translation = QuranTranslations.byId(
      settings.quranTranslationId,
    );

    return Scaffold(
      appBar: AppBar(
        title: content.maybeWhen(
          data: (SurahContent value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value.surah.nameTurkish,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '${value.surah.meaning} · ${value.surah.verseCount} ayet · ${translation.shortLabel}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          orElse: () => const Text('Kur\'an'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: _arrowTrackingEnabled
                ? 'Ok takibi açık (yaşlı dostu)'
                : 'Ok takibini aç',
            onPressed: () {
              setState(() => _arrowTrackingEnabled = !_arrowTrackingEnabled);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      _arrowTrackingEnabled
                          ? 'Ok takipli yaşlı dostu okuma modu açıldı.'
                          : 'Ok takibi kapatıldı.',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
            icon: Icon(
              Icons.double_arrow_rounded,
              size: 20,
              color: _arrowTrackingEnabled ? AppColors.emerald500 : null,
            ),
          ),
          IconButton(
            tooltip: 'Meal dili ve indirme (${translation.shortLabel})',
            onPressed: () => _showTranslationSheet(context, ref, translation),
            icon: const Icon(Icons.language_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Yazı boyutu ve yaşlı modu',
            onPressed: () => _showFontSheet(context, ref, settings),
            icon: const Icon(Icons.format_size_rounded, size: 20),
          ),
          IconButton(
            tooltip: settings.quranShowTranslation
                ? 'Meali gizle'
                : 'Meali göster',
            onPressed: () => ref
                .read(settingsControllerProvider.notifier)
                .update(
                  settings.copyWith(
                    quranShowTranslation: !settings.quranShowTranslation,
                  ),
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
      bottomNavigationBar: content.maybeWhen(
        data: (SurahContent value) => value.ayahs.isEmpty
            ? null
            : _QuranHorizontalPlayerBar(
                surah: value.surah,
                reciter: reciter,
                activeAyah: _playingAyah ?? _trackedAyah,
                totalAyahs: value.ayahs.length,
                isPlaying:
                    _playingAyah != null &&
                    _playbackStatus == PlaybackStatus.playing,
                isPaused:
                    _playingAyah != null &&
                    _playbackStatus == PlaybackStatus.paused,
                isLoading:
                    _playingAyah != null &&
                    _playbackStatus == PlaybackStatus.loading,
                ayahPosition: _ayahPosition,
                ayahDuration: _ayahDuration,
                speed: _playbackSpeed,
                arrowTrackingEnabled: _arrowTrackingEnabled,
                elderlyLargeFont: settings.quranFontSize >= 32,
                onTogglePlayPause: () =>
                    _togglePlayPauseSurah(value, reciter),
                onStop: _stopAudio,
                onPreviousAyah: () => _stepAyah(value, reciter, -1),
                onNextAyah: () => _stepAyah(value, reciter, 1),
                onSeekToAyah: (int targetAyah) =>
                    _jumpToAyah(value, reciter, targetAyah),
                onCycleSpeed: _cycleSpeed,
                onPickReciter: () => _showReciterSheet(context, ref),
                onToggleArrowTracking: () => setState(
                  () => _arrowTrackingEnabled = !_arrowTrackingEnabled,
                ),
                onToggleElderlyFont: () {
                  final double nextSize = settings.quranFontSize >= 32
                      ? 26
                      : 34;
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setQuranFontSize(nextSize);
                  setState(() => _arrowTrackingEnabled = true);
                },
              ),
        orElse: () => null,
      ),
      body: content.when(
        loading: () => const LoadingView(message: 'Sure yükleniyor…'),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () =>
              ref.invalidate(surahContentProvider(widget.surahNumber)),
        ),
        data: (SurahContent value) {
          if (value.ayahs.isEmpty) {
            return const EmptyView(
              icon: Icons.menu_book_outlined,
              title: 'Sure içeriği bulunamadı',
              message:
                  'Kur\'an verisi eksik görünüyor. Uygulamayı yeniden başlatmayı deneyin.',
            );
          }
          return ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positions,
            initialScrollIndex: _initialIndex(value),
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            itemCount: value.ayahs.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _SurahHeader(
                  surah: value.surah,
                  showBasmala:
                      widget.surahNumber != 1 && widget.surahNumber != 9,
                );
              }
              final Ayah ayah = value.ayahs[index - 1];
              final bool isBookmarked = bookmarks.contains(
                value.surah.number * 1000 + ayah.number,
              );
              final bool isPlayingThis = _playingAyah == ayah.number;
              final bool isTrackedThis =
                  _arrowTrackingEnabled &&
                  (_playingAyah ?? _trackedAyah) == ayah.number;
              return _AyahCard(
                ayah: ayah,
                fontSize: settings.quranFontSize,
                showTranslation: settings.quranShowTranslation,
                isBookmarked: isBookmarked,
                isPlaying: isPlayingThis,
                isArrowTracked: isTrackedThis,
                audioWordProgress: isPlayingThis ? _currentAyahProgress : null,
                manualWordIndex: isTrackedThis ? _manualWordIndex : 0,
                onTapCard: () {
                  setState(() {
                    _trackedAyah = ayah.number;
                    _manualWordIndex = 0;
                  });
                },
                onStepWord: (int delta, int wordCount) {
                  setState(() {
                    final int nextWord = _manualWordIndex + delta;
                    if (nextWord >= wordCount) {
                      if (ayah.number < value.ayahs.length) {
                        _trackedAyah = ayah.number + 1;
                        _manualWordIndex = 0;
                        _scrollToAyah(_trackedAyah);
                      }
                    } else if (nextWord < 0) {
                      if (ayah.number > 1) {
                        _trackedAyah = ayah.number - 1;
                        _manualWordIndex = 0;
                        _scrollToAyah(_trackedAyah);
                      }
                    } else {
                      _manualWordIndex = nextWord;
                    }
                  });
                },
                onBookmark: () async {
                  await ref
                      .read(runtimeProvider)
                      .quran
                      .toggleBookmark(ayah.surah, ayah.number);
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
                onPlay: () => _playAyah(value, ayah, reciter),
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
    final int index = content.ayahs.indexWhere(
      (Ayah ayah) => ayah.number == target,
    );
    return index <= 0 ? 0 : index + 1;
  }

  Future<void> _togglePlayPauseSurah(
    SurahContent content,
    Reciter reciter,
  ) async {
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    if (_playingAyah != null) {
      if (_playbackStatus == PlaybackStatus.playing) {
        await audio.pause();
        return;
      }
      if (_playbackStatus == PlaybackStatus.paused) {
        await audio.play();
        return;
      }
    }
    final int startAyah = _trackedAyah.clamp(1, content.ayahs.length);
    await _playFromAyahNumber(content, reciter, startAyah);
  }

  Future<void> _stopAudio() async {
    await ref.read(runtimeProvider).audio.stop();
    if (!mounted) return;
    setState(() {
      _playingAyah = null;
      _playbackStatus = PlaybackStatus.idle;
      _ayahPosition = Duration.zero;
    });
  }

  Future<void> _stepAyah(
    SurahContent content,
    Reciter reciter,
    int delta,
  ) async {
    final int current = _playingAyah ?? _trackedAyah;
    final int target = (current + delta).clamp(1, content.ayahs.length);
    await _jumpToAyah(content, reciter, target);
  }

  Future<void> _jumpToAyah(
    SurahContent content,
    Reciter reciter,
    int targetAyah,
  ) async {
    final int clamped = targetAyah.clamp(1, content.ayahs.length);
    setState(() {
      _trackedAyah = clamped;
      _manualWordIndex = 0;
    });
    _scrollToAyah(clamped);
    if (_playingAyah != null) {
      final AppAudioService audio = ref.read(runtimeProvider).audio;
      if (audio.queueLength == content.ayahs.length) {
        setState(() => _playingAyah = clamped);
        await audio.jumpToQueueIndex(clamped - 1);
      } else {
        await _playFromAyahNumber(content, reciter, clamped);
      }
    }
  }

  Future<void> _cycleSpeed() async {
    const List<double> speeds = <double>[0.75, 1.0, 1.25, 1.5];
    final int idx = speeds.indexOf(_playbackSpeed);
    final double next = speeds[(idx + 1) % speeds.length];
    setState(() => _playbackSpeed = next);
    await ref.read(runtimeProvider).audio.setSpeed(next);
  }

  Future<void> _playFromAyahNumber(
    SurahContent content,
    Reciter reciter,
    int ayahNumber,
  ) async {
    final List<String> urls = <String>[
      for (final Ayah a in content.ayahs)
        Reciters.ayahUrl(reciter, content.surah.number, a.number),
    ];
    if (urls.isEmpty) return;
    final int startIndex = (ayahNumber - 1).clamp(0, urls.length - 1);
    setState(() {
      _playingAyah = ayahNumber;
      _trackedAyah = ayahNumber;
      _manualWordIndex = 0;
      _playbackStatus = PlaybackStatus.loading;
    });
    _scrollToAyah(ayahNumber);
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    final bool ok = await audio.playUrlList(urls, initialIndex: startIndex);
    if (_playbackSpeed != 1.0) {
      await audio.setSpeed(_playbackSpeed);
    }
    if (!ok && mounted) {
      setState(() {
        _playingAyah = null;
        _playbackStatus = PlaybackStatus.error;
      });
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

  Future<void> _playAyah(
    SurahContent content,
    Ayah ayah,
    Reciter reciter,
  ) async {
    if (_playingAyah == ayah.number) {
      if (_playbackStatus == PlaybackStatus.playing) {
        await ref.read(runtimeProvider).audio.pause();
      } else {
        await ref.read(runtimeProvider).audio.play();
      }
      return;
    }
    await _playFromAyahNumber(content, reciter, ayah.number);
  }

  void _showReciterSheet(BuildContext context, WidgetRef ref) {
    final Reciter current = ref.read(selectedReciterProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                'Kur\'an Okuyucusu (Kari) Seçimi',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final Reciter item in Reciters.all)
              ListTile(
                leading: Icon(
                  item.id == current.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: item.id == current.id ? AppColors.emerald500 : null,
                ),
                title: Text(item.name),
                subtitle: Text(item.style),
                onTap: () {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setQuranReciter(item.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showFontSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Yazı boyutu ve Ok Takipli Yaşlı Modu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Slider(
                  value: settings.quranFontSize,
                  min: 18,
                  max: 44,
                  divisions: 13,
                  label: settings.quranFontSize.toStringAsFixed(0),
                  onChanged: (double value) {
                    setModalState(() {});
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setQuranFontSize(value);
                  },
                ),
                Text(
                  'بِسْمِ اللّٰهِ',
                  style: AppTheme.arabic(
                    Theme.of(context).textTheme,
                    size: settings.quranFontSize,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _arrowTrackingEnabled,
                  title: const Text('Yaşlılar için ok takipli kelime/satır vurgusu'),
                  subtitle: const Text(
                    'Okunan ayeti ve kelimeyi hareketli ok işaretiyle gösterir',
                  ),
                  onChanged: (bool value) {
                    setModalState(() => _arrowTrackingEnabled = value);
                    setState(() => _arrowTrackingEnabled = value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.quranShowTranslation,
                  title: const Text('Meali göster'),
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
              'Meal dili ve çevrimdışı indirme',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Kur\'an mealini kendi dilinizde seçin veya çevrimdışı okumak için indirin.',
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
                ref.invalidate(surahContentProvider(widget.surahNumber));
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
                    .downloadTranslation(
                      item.id,
                      surahNumber: widget.surahNumber,
                    );
                ref.invalidate(surahContentProvider(widget.surahNumber));
              },
            ),
        ],
      ),
    );
  }
}

/// Sure ekranının altında sabit duran yatay Kur'an MediaPlayer ve Ok Takip çubuğu.
class _QuranHorizontalPlayerBar extends StatelessWidget {
  const _QuranHorizontalPlayerBar({
    required this.surah,
    required this.reciter,
    required this.activeAyah,
    required this.totalAyahs,
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    required this.ayahPosition,
    required this.ayahDuration,
    required this.speed,
    required this.arrowTrackingEnabled,
    required this.elderlyLargeFont,
    required this.onTogglePlayPause,
    required this.onStop,
    required this.onPreviousAyah,
    required this.onNextAyah,
    required this.onSeekToAyah,
    required this.onCycleSpeed,
    required this.onPickReciter,
    required this.onToggleArrowTracking,
    required this.onToggleElderlyFont,
  });

  final Surah surah;
  final Reciter reciter;
  final int activeAyah;
  final int totalAyahs;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final Duration ayahPosition;
  final Duration ayahDuration;
  final double speed;
  final bool arrowTrackingEnabled;
  final bool elderlyLargeFont;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onStop;
  final VoidCallback onPreviousAyah;
  final VoidCallback onNextAyah;
  final ValueChanged<int> onSeekToAyah;
  final VoidCallback onCycleSpeed;
  final VoidCallback onPickReciter;
  final VoidCallback onToggleArrowTracking;
  final VoidCallback onToggleElderlyFont;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int safeAyah = activeAyah.clamp(1, totalAyahs > 0 ? totalAyahs : 1);

    return Material(
      elevation: 10,
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Üst satır: Ok Takibi bilgisi + Yaşlı Dostu hızlı butonlar
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.double_arrow_rounded,
                    size: 18,
                    color: AppColors.emerald500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${surah.nameTurkish} • $safeAyah / $totalAyahs. Ayet · ${reciter.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onToggleArrowTracking,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: arrowTrackingEnabled
                            ? AppColors.emerald500.withValues(alpha: 0.16)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: arrowTrackingEnabled
                              ? AppColors.emerald500
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        arrowTrackingEnabled ? '➤ Ok Takibi Açık' : 'Ok Takibi',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: arrowTrackingEnabled
                              ? AppColors.emerald500
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onToggleElderlyFont,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: elderlyLargeFont
                            ? AppColors.gold500.withValues(alpha: 0.20)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: elderlyLargeFont
                              ? AppColors.gold600
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        'Yaşlı Modu (A+)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: elderlyLargeFont ? AppColors.gold600 : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Orta satır: Yatay ayet ilerleme Slider'ı
              if (totalAyahs > 1)
                Row(
                  children: <Widget>[
                    Text(
                      '$safeAyah. ayet',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: safeAyah.toDouble(),
                          min: 1,
                          max: totalAyahs.toDouble(),
                          divisions: totalAyahs - 1,
                          label: '$safeAyah. Ayet',
                          onChanged: (double v) => onSeekToAyah(v.round()),
                        ),
                      ),
                    ),
                    Text(
                      (isPlaying || isPaused) && ayahDuration.inMilliseconds > 0
                          ? '${AppTime.formatClock(ayahPosition)}/${AppTime.formatClock(ayahDuration)}'
                          : '$totalAyahs ayet',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              // Alt satır: Yatay MediaPlayer oynatma ve ayet geçiş düğmeleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Kari (Okuyucu) Seç',
                    onPressed: onPickReciter,
                    icon: const Icon(Icons.record_voice_over_rounded, size: 20),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Önceki Ayet',
                    onPressed: safeAyah > 1 ? onPreviousAyah : null,
                    icon: const Icon(Icons.skip_previous_rounded, size: 26),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 6,
                      ),
                    ),
                    onPressed: onTogglePlayPause,
                    icon: Icon(
                      isLoading
                          ? Icons.hourglass_top_rounded
                          : isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 22,
                    ),
                    label: Text(
                      isPlaying
                          ? 'Duraklat'
                          : isPaused
                          ? 'Devam Et'
                          : 'Dinle ($safeAyah. Ayet)',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Sonraki Ayet',
                    onPressed: safeAyah < totalAyahs ? onNextAyah : null,
                    icon: const Icon(Icons.skip_next_rounded, size: 26),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(42, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    onPressed: onCycleSpeed,
                    child: Text(
                      '${speed}x',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald500,
                      ),
                    ),
                  ),
                  if (isPlaying || isPaused || isLoading)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Durdur',
                      onPressed: onStop,
                      icon: const Icon(Icons.stop_circle_outlined, size: 20),
                    ),
                ],
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.emeraldGradient),
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
              style: AppTheme.arabic(
                theme.textTheme,
                size: 26,
                color: AppColors.gold600,
              ),
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
    required this.isArrowTracked,
    required this.audioWordProgress,
    required this.manualWordIndex,
    required this.onTapCard,
    required this.onStepWord,
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
  final bool isArrowTracked;
  final double? audioWordProgress;
  final int manualWordIndex;
  final VoidCallback onTapCard;
  final void Function(int delta, int wordCount) onStepWord;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> arabicWords = ayah.arabic
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
    final int wordCount = arabicWords.isEmpty ? 1 : arabicWords.length;
    final int activeWordIdx = audioWordProgress != null
        ? (audioWordProgress! * wordCount).floor().clamp(0, wordCount - 1)
        : manualWordIndex.clamp(0, wordCount - 1);
    final double effectiveProgress = audioWordProgress ??
        (wordCount <= 1 ? 1.0 : (activeWordIdx + 1) / wordCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: InkWell(
        borderRadius: AppRadius.allLg,
        onTap: onTapCard,
        child: Container(
          decoration: BoxDecoration(
            color: isPlaying
                ? AppColors.emerald600.withValues(alpha: 0.12)
                : isArrowTracked
                ? AppColors.gold500.withValues(alpha: 0.10)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
            borderRadius: AppRadius.allLg,
            border: Border.all(
              width: (isPlaying || isArrowTracked) ? 2.0 : 1.0,
              color: isPlaying
                  ? AppColors.emerald500
                  : isArrowTracked
                  ? AppColors.gold600
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isPlaying || isArrowTracked)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? AppColors.emerald500.withValues(alpha: 0.16)
                        : AppColors.gold500.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.double_arrow_rounded,
                        size: 20,
                        color: isPlaying
                            ? AppColors.emerald500
                            : AppColors.gold600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isPlaying
                              ? '➤ ŞU AN OKUNAN SATIR (${ayah.number}. Ayet • ${activeWordIdx + 1}/$wordCount. kelime)'
                              : '➤ OK TAKİP SATIRI (${ayah.number}. Ayet • ${activeWordIdx + 1}/$wordCount. kelime)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isPlaying
                                ? AppColors.emerald500
                                : AppColors.gold600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                    tooltip: isPlaying ? 'Duraklat' : 'Ayeti dinle',
                    onPressed: onPlay,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 22,
                      color: isPlaying ? AppColors.emerald500 : null,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: isBookmarked
                        ? 'Favoriden çıkar'
                        : 'Favorilere ekle',
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
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
              // Ok Takipli Arapça Metin: aktif kelime ok işareti (⬅) ve vurgulu arka planla gösterilir
              if ((isPlaying || isArrowTracked) && arabicWords.length > 1)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: RichText(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: AppTheme.arabic(theme.textTheme, size: fontSize),
                      children: <InlineSpan>[
                        for (int i = 0; i < arabicWords.length; i++)
                          TextSpan(
                            text: i == activeWordIdx
                                ? '⬅${arabicWords[i]} '
                                : '${arabicWords[i]} ',
                            style: i == activeWordIdx
                                ? AppTheme.arabic(
                                    theme.textTheme,
                                    size: fontSize + 2,
                                    color: AppColors.emerald500,
                                  ).copyWith(
                                    fontWeight: FontWeight.w800,
                                    backgroundColor: AppColors.gold500
                                        .withValues(alpha: 0.28),
                                  )
                                : i < activeWordIdx
                                ? AppTheme.arabic(
                                    theme.textTheme,
                                    size: fontSize,
                                  ).copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.72),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  ayah.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabic(theme.textTheme, size: fontSize),
                ),
              // Arapça okuma yönüne (sağdan sola ◀──) uygun hareketli ok takip çubuğu
              if (isPlaying || isArrowTracked) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: effectiveProgress.clamp(0.05, 1.0),
                      minHeight: 5,
                      color: AppColors.emerald500,
                      backgroundColor: AppColors.gold500.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                if (!isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => onStepWord(-1, wordCount),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 14,
                          ),
                          label: const Text('Önceki Kelime'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => onStepWord(1, wordCount),
                          icon: const Icon(
                            Icons.double_arrow_rounded,
                            size: 16,
                          ),
                          label: const Text('Kelime İlerle ⬅'),
                        ),
                      ],
                    ),
                  ),
              ],
              if (showTranslation) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (isPlaying || isArrowTracked)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, right: 6),
                        child: Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 18,
                          color: AppColors.emerald500,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        ayah.turkish,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: fontSize > 30 ? 19 : null,
                          fontWeight: (isPlaying || isArrowTracked)
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
