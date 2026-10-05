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
  final bool repeatOne;

  /// Çevrimdışı kaynak (indirilen dosya) çalınıyor mu?
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
      repeatOne: repeatOne ?? this.repeatOne,
      offlineMode: offlineMode ?? this.offlineMode,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// İlahi/Kur'an sesini yöneten denetleyici.
///
/// Arka planda çalma, kilit ekranı kontrolleri ve indirilen dosyalardan
/// çevrimdışı oynatma bu sınıf üzerinden yürür.
class PlayerController extends Notifier<PlayerUiState> {
  StreamSubscription<PlaybackStatus>? _statusSub;
  StreamSubscription<Duration>? _positionSub;
  Timer? _ticker;

  @override
  PlayerUiState build() {
    final AppAudioService audio = ref.watch(runtimeProvider).audio;

    _statusSub = audio.statusStream.listen((PlaybackStatus status) {
      if (!ref.mounted) return;
      state = state.copyWith(status: status);
      if (status == PlaybackStatus.completed) {
        _onCompleted();
      }
    });

    _positionSub = audio.positionStream.listen((Duration position) {
      if (!ref.mounted) return;
      state = state.copyWith(
        position: position,
        duration: audio.duration ?? state.duration,
      );
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) return;
      final AppAudioService service = ref.read(runtimeProvider).audio;
      final Duration? duration = service.duration;
      state = state.copyWith(
        position: service.position ?? state.position,
        duration: duration ?? state.duration,
      );
    });

    ref.onDispose(() {
      _statusSub?.cancel();
      _positionSub?.cancel();
      _ticker?.cancel();
    });

    return const PlayerUiState();
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
    state = state.copyWith(
      track: track,
      queue: effectiveQueue,
      index: index < 0 ? 0 : index,
      position: Duration.zero,
      duration: Duration(seconds: track.durationSeconds),
      status: PlaybackStatus.loading,
      clearError: true,
      offlineMode: track.isLocal || _isDownloaded(track),
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

    final bool started = source.startsWith('http')
        ? await audio.playUrl(
            source,
            title: track.title,
            artist: track.artist,
            album: track.album ?? 'EzanAI İlahi',
            artUri: track.artUri,
            id: track.id,
          )
        : await audio.playFile(source);

    if (!started) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: _offlineMessage(track),
      );
      return;
    }
    await audio.setVolume(state.volume);
    await audio.setLoop(state.repeatOne);
    state = state.copyWith(status: PlaybackStatus.playing);
  }

  Future<void> togglePlayPause() async {
    final AppAudioService audio = ref.read(runtimeProvider).audio;
    if (state.track == null) return;
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

  Future<void> seek(Duration position) =>
      ref.read(runtimeProvider).audio.seek(position);

  Future<void> seekToFraction(double fraction) {
    final Duration target = Duration(
      milliseconds: (state.duration.inMilliseconds * fraction.clamp(0, 1))
          .round(),
    );
    return seek(target);
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await ref.read(runtimeProvider).audio.setVolume(volume);
  }

  Future<void> toggleRepeat() async {
    final bool repeat = !state.repeatOne;
    state = state.copyWith(repeatOne: repeat);
    await ref.read(runtimeProvider).audio.setLoop(repeat);
  }

  Future<void> setSpeed(double speed) =>
      ref.read(runtimeProvider).audio.setSpeed(speed);

  /// Çalma listesini kuyruğa alıp ilk parçadan başlar.
  Future<void> playQueue(List<IlahiTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    await playTrack(tracks[startIndex], queue: tracks);
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
    if (state.repeatOne) {
      unawaited(ref.read(runtimeProvider).audio.play());
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
              minHeight: 2,
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
                          player.offlineMode
                              ? 'Çevrimdışı · ${player.track!.artist}'
                              : player.track!.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
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

/// Uzun süren akış hatalarını günlüğe yazar (denetleyici dışı yardımcı).
void logPlaybackError(Object error) => AppLog.warning('Oynatma hatası: $error');
