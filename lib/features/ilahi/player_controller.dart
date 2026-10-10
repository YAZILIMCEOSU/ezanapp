import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/audio_service.dart';
import '../../core/utils/logger.dart';
import '../../data/models/ilahi_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';

/// Oynatıcı durumu (arayüz için).
class PlayerUiState {
  const PlayerUiState({
    this.track,
    this.queue = const <IlahiTrack>[],
    this.index = 0,
    this.status = PlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
    this.volume = 1,
    this.speed = 1.0,
    this.repeatOne = false,
    this.offlineMode = false,
  });

  final IlahiTrack? track;
  final List<IlahiTrack> queue;
  final int index;
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;
  final String? error;
  final double volume;
  final double speed;
  final bool repeatOne;

  /// Çevrimdışı kaynak (dahili ses veya indirilen dosya) çalınıyor mu?
  final bool offlineMode;

  bool get playing => status == PlaybackStatus.playing;
  bool get buffering => status == PlaybackStatus.loading;
  bool get hasNext => index + 1 < queue.length;
  bool get hasPrevious => index > 0;
  String? get currentTrackId => track?.id;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds)
        .clamp(0, 1)
        .toDouble();
  }

  PlayerUiState copyWith({
    IlahiTrack? track,
    List<IlahiTrack>? queue,
    int? index,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    bool? repeatOne,
    bool? offlineMode,
    String? error,
    bool clearError = false,
    bool clearTrack = false,
  }) {
    return PlayerUiState(
      track: clearTrack ? null : (track ?? this.track),
      queue: queue ?? this.queue,
      index: index ?? this.index,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      repeatOne: repeatOne ?? this.repeatOne,
      offlineMode: offlineMode ?? this.offlineMode,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// İlahi/Kur'an/Ezan sesini yöneten denetleyici.
///
/// Arka planda çalma, kilit ekranı kontrolleri ve indirilen/dahili dosyalardan
/// çevrimdışı oynatma bu sınıf üzerinden yürür.
class PlayerController extends Notifier<PlayerUiState> {
  StreamSubscription<PlaybackStatus>? _statusSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<int>? _queueIdxSub;
  Timer? _ticker;

  @override
  PlayerUiState build() {
    final AppAudioService audio = ref.watch(runtimeProvider).audio;

    _statusSub = audio.statusStream.listen((PlaybackStatus status) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: status,
        clearError: status == PlaybackStatus.playing,
      );
      if (status == PlaybackStatus.completed) {
        _onCompleted();
      }
    });

    _positionSub = audio.positionStream.listen((Duration position) {
      if (!ref.mounted) return;
      _syncPositionAndDuration(audio, position);
    });

    _durationSub = audio.durationStream.listen((Duration d) {
      if (!ref.mounted) return;
      if (audio.queueLength <= 1 && d > Duration.zero) {
        state = state.copyWith(duration: d);
      }
    });

    _queueIdxSub = audio.queueIndexStream.listen((int idx) {
      if (!ref.mounted) return;
      _syncPositionAndDuration(audio, audio.position ?? Duration.zero);
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) return;
      final AppAudioService service = ref.read(runtimeProvider).audio;
      if (state.track == null) return;
      _syncPositionAndDuration(service, service.position ?? state.position);
    });

    ref.onDispose(() {
      _statusSub?.cancel();
      _positionSub?.cancel();
      _durationSub?.cancel();
      _queueIdxSub?.cancel();
      _ticker?.cancel();
    });

    return const PlayerUiState();
  }

  void _syncPositionAndDuration(AppAudioService audio, Duration rawPosition) {
    final IlahiTrack? currentTrack = state.track;
    if (currentTrack == null) return;

    if (audio.queueLength > 1) {
      // Çok parçalı sure kuyruğu: toplam süreyi koru, kuyruk ilerlemesini hesapla.
      final Duration totalDuration = state.duration.inSeconds > 0
          ? state.duration
          : Duration(
              seconds: currentTrack.durationSeconds > 0
                  ? currentTrack.durationSeconds
                  : audio.queueLength * 8,
            );
      final Duration? itemDur = audio.duration;
      final double itemFrac = (itemDur != null && itemDur.inMilliseconds > 0)
          ? (rawPosition.inMilliseconds / itemDur.inMilliseconds).clamp(
              0.0,
              1.0,
            )
          : 0.0;
      final double overallFrac =
          ((audio.currentQueueIndex + itemFrac) / audio.queueLength).clamp(
            0.0,
            1.0,
          );
      final Duration effectivePos = Duration(
        milliseconds: (totalDuration.inMilliseconds * overallFrac).round(),
      );
      state = state.copyWith(position: effectivePos, duration: totalDuration);
      return;
    }

    final Duration? actualDuration = audio.duration;
    final Duration resolvedDuration =
        (actualDuration != null && actualDuration > Duration.zero)
        ? actualDuration
        : state.duration;
    final Duration clampedPos =
        resolvedDuration > Duration.zero && rawPosition > resolvedDuration
        ? resolvedDuration
        : rawPosition;
    state = state.copyWith(position: clampedPos, duration: resolvedDuration);
  }

  /// Tek bir parçayı (isteğe bağlı kuyrukla) çalar.
  Future<void> playTrack(
    IlahiTrack track, {
    List<IlahiTrack> queue = const <IlahiTrack>[],
  }) async {
    final List<IlahiTrack> effectiveQueue = queue.isEmpty
        ? <IlahiTrack>[track]
        : queue;
    final int index = effectiveQueue.indexWhere(
      (IlahiTrack item) => item.id == track.id,
    );
    final bool isOffline =
        track.isLocal ||
        _isDownloaded(track) ||
        track.audioUrl.startsWith('asset:');
    state = state.copyWith(
      track: track,
      queue: effectiveQueue,
      index: index < 0 ? 0 : index,
      position: Duration.zero,
      duration: Duration(seconds: track.durationSeconds),
      status: PlaybackStatus.loading,
      clearError: true,
      offlineMode: isOffline,
    );

    final String? source = _sourceFor(track);
    if (source == null) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: 'Bu içerik için oynatılabilir ses bağlantısı bulunamadı.',
      );
      return;
    }

    final AppAudioService audio = ref.read(runtimeProvider).audio;
    await audio.initialize(
      ducking: ref.read(settingsProvider).adhanPlaybackDucking,
    );

    final bool started;
    if (source.startsWith('asset:')) {
      started = await audio.playAsset(
        source.substring(6),
        volume: state.volume,
        loop: state.repeatOne,
      );
    } else if (source.startsWith('everyayah:') || source.contains('|')) {
      final List<String> urls = track.resolvedAudioUrls;
      started = await audio.playUrlList(urls, volume: state.volume);
    } else if (source.startsWith('http')) {
      started = await audio.playUrl(
        source,
        title: track.title,
        artist: track.artist,
        album: track.album ?? 'Ezan İlahi',
        artUri: track.artUri,
        id: track.id,
        volume: state.volume,
        loop: state.repeatOne,
      );
    } else {
      started = await audio.playFile(
        source,
        volume: state.volume,
        loop: state.repeatOne,
      );
    }

    if (!started) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: _offlineMessage(track),
      );
      return;
    }
    await audio.setVolume(state.volume);
    if (state.speed != 1.0) {
      await audio.setSpeed(state.speed);
    }
    if (!source.startsWith('everyayah:') && !source.contains('|')) {
      await audio.setLoop(state.repeatOne);
    }
    final Duration? loadedDuration = audio.duration;
    state = state.copyWith(
      status: PlaybackStatus.playing,
      duration:
          (audio.queueLength <= 1 &&
              loadedDuration != null &&
              loadedDuration > Duration.zero)
          ? loadedDuration
          : state.duration,
      clearError: true,
    );
  }

  Future<void> togglePlayPause() async {
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    if (state.track == null) return;
    if (state.status == PlaybackStatus.error) {
      await playTrack(state.track!, queue: state.queue);
      return;
    }
    await audio.togglePlayPause();
  }

  Future<void> pause() => ref.read(runtimeProvider).audio.pause();

  Future<void> resume() => ref.read(runtimeProvider).audio.play();

  Future<void> stop() async {
    await ref.read(runtimeProvider).audio.stop();
    state = const PlayerUiState();
  }

  Future<void> next() async {
    if (!state.hasNext) return;
    await _playIndex(state.index + 1);
  }

  Future<void> previous() async {
    if (state.position.inSeconds > 5) {
      await seek(Duration.zero);
      return;
    }
    if (!state.hasPrevious) {
      await seek(Duration.zero);
      return;
    }
    await _playIndex(state.index - 1);
  }

  Future<void> _playIndex(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    final IlahiTrack track = state.queue[index];
    await playTrack(track, queue: state.queue);
    await ref.read(runtimeProvider).ilahi.markPlayed(track.id);
  }

  Future<void> seek(Duration position) async {
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    if (audio.queueLength > 1 && state.duration.inMilliseconds > 0) {
      final double frac =
          (position.inMilliseconds / state.duration.inMilliseconds).clamp(
            0.0,
            1.0,
          );
      final int targetIdx = (frac * audio.queueLength).floor().clamp(
        0,
        audio.queueLength - 1,
      );
      state = state.copyWith(position: position);
      await audio.jumpToQueueIndex(targetIdx);
      return;
    }
    final Duration clamped = state.duration > Duration.zero
        ? Duration(
            milliseconds: position.inMilliseconds.clamp(
              0,
              state.duration.inMilliseconds,
            ),
          )
        : position;
    state = state.copyWith(position: clamped);
    await audio.seek(clamped);
  }

  Future<void> seekRelative(Duration offset) async {
    final Duration target = state.position + offset;
    if (target < Duration.zero) {
      await seek(Duration.zero);
    } else if (state.duration > Duration.zero && target > state.duration) {
      await seek(state.duration);
    } else {
      await seek(target);
    }
  }

  Future<void> seekToFraction(double fraction) {
    final Duration target = Duration(
      milliseconds: (state.duration.inMilliseconds * fraction.clamp(0, 1))
          .round(),
    );
    return seek(target);
  }

  Future<void> setVolume(double volume) async {
    final double clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    await ref.read(runtimeProvider).audio.setVolume(clamped);
  }

  Future<void> toggleRepeat() async {
    final bool repeat = !state.repeatOne;
    state = state.copyWith(repeatOne: repeat);
    await ref.read(runtimeProvider).audio.setLoop(repeat);
  }

  Future<void> setSpeed(double speed) async {
    final double clamped = speed.clamp(0.5, 2.0);
    state = state.copyWith(speed: clamped);
    await ref.read(runtimeProvider).audio.setSpeed(clamped);
  }

  Future<void> cycleSpeed() async {
    const List<double> speeds = <double>[0.75, 1.0, 1.25, 1.5];
    final int idx = speeds.indexOf(state.speed);
    final double nextSpeed = speeds[(idx + 1) % speeds.length];
    await setSpeed(nextSpeed);
  }

  /// Çalma listesini kuyruğa alıp ilk parçadan başlar.
  Future<void> playQueue(List<IlahiTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    final int safeIndex = startIndex.clamp(0, tracks.length - 1);
    await playTrack(tracks[safeIndex], queue: tracks);
  }

  /// Kuyruğa parça ekler.
  void enqueue(List<IlahiTrack> tracks) {
    if (tracks.isEmpty) return;
    final List<IlahiTrack> merged = <IlahiTrack>[
      ...state.queue,
      ...tracks.where(
        (IlahiTrack track) =>
            !state.queue.any((IlahiTrack item) => item.id == track.id),
      ),
    ];
    state = state.copyWith(queue: merged);
  }

  void clearError() => state = state.copyWith(clearError: true);

  void _onCompleted() {
    if (state.repeatOne && state.track != null) {
      unawaited(playTrack(state.track!, queue: state.queue));
      return;
    }
    if (state.hasNext) {
      unawaited(_playIndex(state.index + 1));
    }
  }

  String? _sourceFor(IlahiTrack track) {
    if (track.localPath != null && track.localPath!.isNotEmpty) {
      return track.localPath;
    }
    if (track.audioUrl.isEmpty) return null;
    return track.audioUrl;
  }

  bool _isDownloaded(IlahiTrack track) =>
      track.localPath != null && track.localPath!.isNotEmpty;

  String _offlineMessage(IlahiTrack track) {
    if (ref.read(settingsProvider).streamingOnlyOnWifi &&
        !_isDownloaded(track)) {
      return 'Yalnızca Wi-Fi üzerinden akış açık. İçeriği indirip çevrimdışı '
          'dinleyebilir veya ayarları değiştirebilirsiniz.';
    }
    return 'Ses çalınamadı. İnternet bağlantınızı kontrol edin veya içeriği indirip '
        'çevrimdışı dinleyin.';
  }
}

final NotifierProvider<PlayerController, PlayerUiState>
playerControllerProvider = NotifierProvider<PlayerController, PlayerUiState>(
  PlayerController.new,
);

/// Alt oynatma çubuğu — uygulamanın ilahi ve Kur'an ekranlarında görünür.
class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerUiState player = ref.watch(playerControllerProvider);
    if (player.track == null) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(AppRoutes.player),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LinearProgressIndicator(
              value: player.progress,
              minHeight: 3,
              backgroundColor: theme.colorScheme.outlineVariant.withValues(
                alpha: 0.4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .togglePlayPause(),
                    icon: Icon(
                      player.playing
                          ? Icons.pause_rounded
                          : player.buffering
                          ? Icons.hourglass_top_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.emerald500,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          player.track!.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${AppTimeLabel.short(player.position)} / ${AppTimeLabel.short(player.duration)} · ${player.offlineMode ? "Çevrimdışı · ${player.track!.artist}" : player.track!.artist}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: '10 sn geri',
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .seekRelative(const Duration(seconds: -10)),
                    icon: const Icon(Icons.replay_10_rounded, size: 20),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Sonraki',
                    onPressed: player.hasNext
                        ? () =>
                              ref.read(playerControllerProvider.notifier).next()
                        : null,
                    icon: const Icon(Icons.skip_next_rounded, size: 20),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Kapat',
                    onPressed: () =>
                        ref.read(playerControllerProvider.notifier).stop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
            if (player.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        player.error!,
                        style: theme.textTheme.labelSmall,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

abstract final class AppTimeLabel {
  static String short(Duration d) {
    final int totalSeconds = d.inSeconds < 0 ? 0 : d.inSeconds;
    final String mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final String secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}

/// Uzun süren akış hatalarını günlüğe yazar (denetleyici dışı yardımcı).
void logPlaybackError(Object error) => AppLog.warning('Oynatma hatası: $error');
