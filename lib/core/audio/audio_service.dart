import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../data/models/app_settings.dart';
import '../utils/logger.dart';

/// Çalma durumu (arayüz için sadeleştirilmiş).
enum PlaybackStatus { idle, loading, playing, paused, completed, error }

/// Uygulamadaki tüm ses oynatma işlerini yöneten servis.
///
/// - Kur'an tilaveti, ilahi ve ezan sesleri aynı motoru kullanır.
/// - Arka planda çalma ve kilit ekranı kontrolleri
///   `just_audio_background` ile sağlanır (main.dart içinde başlatılır).
/// - Ses oturumu (audio_session) ile ezan okunurken diğer sesler kısılır
///   (ducking) ve telefon görüşmelerinde otomatik duraklar.
class AppAudioService {
  AppAudioService();

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<PlayerException>? _errorSub;

  final StreamController<PlaybackStatus> _statusController =
      StreamController<PlaybackStatus>.broadcast();
  Stream<PlaybackStatus> get statusStream => _statusController.stream;

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;

  PlaybackStatus _status = PlaybackStatus.idle;
  PlaybackStatus get status => _status;

  bool _initialized = false;
  bool _duckingEnabled = true;

  Duration _lastPosition = Duration.zero;
  Duration? get position => _lastPosition;
  Duration? get duration => _player.duration;

  double _speed = 1.0;
  double get speed => _speed;

  /// Ses oturumunu yapılandırır; bir kez çağrılır.
  Future<void> initialize({bool ducking = true}) async {
    if (_initialized) {
      _duckingEnabled = ducking;
      await _applyDucking();
      return;
    }
    _initialized = true;
    _duckingEnabled = ducking;
    try {
      final AudioSession session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _applyDucking();
      session.interruptionEventStream.listen((AudioInterruptionEvent event) {
        if (event.begin) {
          AppLog.debug('Ses kesintisi başladı (${event.type.name})');
          unawaited(_player.pause());
        } else {
          AppLog.debug('Ses kesintisi bitti');
        }
      });
      session.becomingNoisyEventStream
          .listen((_) => unawaited(_player.pause()));
    } catch (error) {
      AppLog.warning('Ses oturumu yapılandırılamadı: $error');
    }

    _stateSub = _player.playerStateStream.listen((PlayerState state) {
      _status = switch (state.processingState) {
        ProcessingState.idle => PlaybackStatus.idle,
        ProcessingState.loading ||
        ProcessingState.buffering =>
          PlaybackStatus.loading,
        ProcessingState.ready =>
          state.playing ? PlaybackStatus.playing : PlaybackStatus.paused,
        ProcessingState.completed => PlaybackStatus.completed,
      };
      if (!_statusController.isClosed) _statusController.add(_status);
      if (state.processingState == ProcessingState.completed) {
        unawaited(_player.seek(Duration.zero));
        unawaited(_player.pause());
      }
    });
    _errorSub = _player.errorStream.listen((PlayerException error) {
      AppLog.warning('Oynatma hatası: ${error.message}');
      if (!_statusController.isClosed)
        _statusController.add(PlaybackStatus.error);
    });
    _player.positionStream.listen((Duration position) {
      _lastPosition = position;
      if (!_positionController.isClosed) _positionController.add(position);
    });
  }

  Future<void> _applyDucking() async {
    try {
      final AudioSession session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: _duckingEnabled
              ? AndroidAudioFocusGainType.gainTransientMayDuck
              : AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
    } catch (error) {
      AppLog.warning('Ses odağı ayarlanamadı', error: error);
    }
  }

  /// Yerel dosya (indirilen içerik) çalar.
  Future<bool> playFile(String path,
      {double? volume, bool loop = false}) async {
    try {
      if (!File(path).existsSync()) {
        AppLog.warning('Ses dosyası bulunamadı: $path');
        return false;
      }
      await _player.setAudioSource(AudioSource.file(path));
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (volume != null) await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.play();
      return true;
    } catch (error, stackTrace) {
      AppLog.error('Dosya çalınamadı', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Varlık (asset) dosyası çalar — dahili ezan tonları.
  Future<bool> playAsset(String assetPath,
      {double volume = 1.0, bool loop = false}) async {
    try {
      await _player.setAudioSource(AudioSource.asset(assetPath));
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.play();
      return true;
    } catch (error, stackTrace) {
      AppLog.error('Varlık çalınamadı: $assetPath',
          error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Ağ akışı (Kur'an/ilahi) çalar.
  ///
  /// [title], [artist] ve [album] bilgileri kilit ekranı bildirimi için
  /// just_audio_background tarafından kullanılır.
  Future<bool> playUrl(
    String url, {
    String? title,
    String? artist,
    String? album,
    String? artUri,
    String? id,
    double? volume,
    bool loop = false,
  }) async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: id ?? url,
            title: title ?? 'EzanAI',
            artist: artist,
            album: album,
            artUri: artUri == null ? null : Uri.tryParse(artUri),
          ),
        ),
      );
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (volume != null) await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.play();
      return true;
    } catch (error, stackTrace) {
      AppLog.error('Akış çalınamadı: $url',
          error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Birden çok parçayı sırayla çalar (sure dinleme / albüm).
  Future<bool> playPlaylist(
    List<AudioSource> sources, {
    int initialIndex = 0,
  }) async {
    try {
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      await _player.play();
      return true;
    } catch (error, stackTrace) {
      AppLog.error('Liste çalınamadı', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> play() async {
    if (_status == PlaybackStatus.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> togglePlayPause() =>
      _status == PlaybackStatus.playing ? _player.pause() : play();

  Future<void> stop() async {
    await _player.stop();
    _status = PlaybackStatus.idle;
    if (!_statusController.isClosed) _statusController.add(_status);
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToIndex(int index) =>
      _player.seek(Duration.zero, index: index);

  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0.0, 1.0));

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    await _player.setSpeed(_speed);
  }

  Future<void> setLoop(bool loop) =>
      _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);

  int? get currentIndex => _player.currentIndex;

  /// Aynı anda ses seviyesini yumuşakça değiştirir (ezan başlangıcı için).
  Future<void> fadeIn(
      {double to = 1.0, Duration duration = const Duration(seconds: 2)}) async {
    const int steps = 20;
    final Duration stepDelay =
        Duration(milliseconds: duration.inMilliseconds ~/ steps);
    for (int i = 1; i <= steps; i++) {
      await _player.setVolume((to * i / steps).clamp(0.0, 1.0));
      await Future<void>.delayed(stepDelay);
    }
  }

  Future<void> fadeOut({Duration duration = const Duration(seconds: 2)}) async {
    const int steps = 20;
    final Duration stepDelay =
        Duration(milliseconds: duration.inMilliseconds ~/ steps);
    for (int i = steps; i >= 0; i--) {
      await _player.setVolume((i / steps).clamp(0.0, 1.0));
      await Future<void>.delayed(stepDelay);
    }
    await pause();
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _errorSub?.cancel();
    await _statusController.close();
    await _positionController.close();
    await _player.dispose();
  }
}

/// Dahili bildirim tonlarının varlık yolları.
abstract final class BundledSounds {
  static const String tone1 = 'assets/audio/adhan/ezan_ton_1.wav';
  static const String tone2 = 'assets/audio/adhan/ezan_ton_2.wav';
  static const String tone3 = 'assets/audio/adhan/ezan_ton_3.wav';

  static String? assetFor(AdhanSound sound) => switch (sound) {
        AdhanSound.tone1 => tone1,
        AdhanSound.tone2 => tone2,
        AdhanSound.tone3 => tone3,
        _ => null,
      };
}
