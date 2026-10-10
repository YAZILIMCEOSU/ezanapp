import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:just_audio/just_audio.dart';

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

  AudioPlayer? _playerInstance;

  /// Oynatıcı yalnızca gerçekten gerektiğinde oluşturulur; böylece açılış
  /// hızlanır, ilk kareye kadar platform kanalı kullanılmaz ve ses
  /// kullanılmayan oturumlarda bellek boşa harcanmaz.
  AudioPlayer get _player => _playerInstance ??= AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<PlayerException>? _errorSub;

  final StreamController<PlaybackStatus> _statusController =
      StreamController<PlaybackStatus>.broadcast();
  Stream<PlaybackStatus> get statusStream => _statusController.stream;

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;

  final StreamController<int> _queueIndexController =
      StreamController<int>.broadcast();
  Stream<int> get queueIndexStream => _queueIndexController.stream;

  List<String> _queueUrls = const <String>[];
  int _queueIndex = 0;
  bool _advancingQueue = false;
  int get currentQueueIndex => _queueIndex;
  int get queueLength => _queueUrls.length;

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
      session.becomingNoisyEventStream.listen(
        (_) => unawaited(_player.pause()),
      );
    } catch (error) {
      AppLog.warning('Ses oturumu yapılandırılamadı: $error');
    }

    _stateSub = _player.playerStateStream.listen((PlayerState state) {
      if (state.processingState == ProcessingState.completed) {
        if (_queueUrls.isNotEmpty && _queueIndex + 1 < _queueUrls.length) {
          if (!_advancingQueue) {
            unawaited(_advanceQueue());
          }
          return;
        }
        _queueUrls = const <String>[];
        _status = PlaybackStatus.completed;
        if (!_statusController.isClosed) _statusController.add(_status);
        unawaited(_player.seek(Duration.zero));
        unawaited(_player.pause());
        return;
      }

      if (_advancingQueue &&
          (state.processingState == ProcessingState.idle ||
              state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering)) {
        // Sıradaki ayete geçerken sahte "idle" veya "paused" durumu yayma.
        return;
      }

      _status = switch (state.processingState) {
        ProcessingState.idle => PlaybackStatus.idle,
        ProcessingState.loading ||
        ProcessingState.buffering => PlaybackStatus.loading,
        ProcessingState.ready =>
          state.playing ? PlaybackStatus.playing : PlaybackStatus.paused,
        ProcessingState.completed => PlaybackStatus.completed,
      };
      if (!_statusController.isClosed) _statusController.add(_status);
    });
    _errorSub = _player.errorStream.listen((PlayerException error) {
      AppLog.warning('Oynatma hatası: ${error.message}');
      if (!_statusController.isClosed) {
        _statusController.add(PlaybackStatus.error);
      }
    });
    _player.positionStream.listen((Duration position) {
      _lastPosition = position;
      if (!_positionController.isClosed) _positionController.add(position);
    });
  }

  Future<void> _advanceQueue() async {
    if (_advancingQueue) return;
    _advancingQueue = true;
    try {
      while (_queueUrls.isNotEmpty && _queueIndex + 1 < _queueUrls.length) {
        _queueIndex += 1;
        if (!_queueIndexController.isClosed) {
          _queueIndexController.add(_queueIndex);
        }
        final String nextUrl = _queueUrls[_queueIndex];
        try {
          await _player.setAudioSource(AudioSource.uri(Uri.parse(nextUrl)));
          await _player.setLoopMode(LoopMode.off);
          unawaited(_player.play());
          _status = PlaybackStatus.playing;
          if (!_statusController.isClosed) _statusController.add(_status);
          return;
        } catch (error) {
          AppLog.warning('Sıradaki parça atlandı ($nextUrl): $error');
        }
      }
      _queueUrls = const <String>[];
      _status = PlaybackStatus.completed;
      if (!_statusController.isClosed) _statusController.add(_status);
    } finally {
      _advancingQueue = false;
    }
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
  Future<bool> playFile(
    String path, {
    double? volume,
    bool loop = false,
  }) async {
    await initialize(ducking: _duckingEnabled);
    _queueUrls = const <String>[];
    try {
      if (!File(path).existsSync()) {
        AppLog.warning('Ses dosyası bulunamadı: $path');
        return false;
      }
      await _player.setAudioSource(AudioSource.file(path));
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (volume != null) await _player.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      AppLog.error('Dosya çalınamadı', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Varlık (asset) dosyası çalar — dahili ezan ve ilahi sesleri.
  ///
  /// Tüm Android sürümlerinde sorunsuz çalışması için önce varlığı geçici
  /// yerel dosyaya çıkarıp ExoPlayer üzerinden yerel dosya olarak çalar.
  Future<bool> playAsset(
    String assetPath, {
    double volume = 1.0,
    bool loop = false,
  }) async {
    await initialize(ducking: _duckingEnabled);
    _queueUrls = const <String>[];
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final String safeName = 'ezan_${assetPath.replaceAll('/', '_')}';
      final File tempFile = File('${Directory.systemTemp.path}/$safeName');
      if (!tempFile.existsSync() || tempFile.lengthSync() != bytes.length) {
        await tempFile.writeAsBytes(bytes, flush: true);
      }
      await _player.setAudioSource(AudioSource.file(tempFile.path));
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _player.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (_) {
      try {
        await _player.setAudioSource(AudioSource.asset(assetPath));
        await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
        await _player.setVolume(volume.clamp(0.0, 1.0));
        unawaited(_player.play());
        _status = PlaybackStatus.playing;
        if (!_statusController.isClosed) _statusController.add(_status);
        return true;
      } catch (error, stackTrace) {
        AppLog.error(
          'Varlık çalınamadı: $assetPath',
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      }
    }
  }

  /// Ağ akışı (Kur'an/ilahi) çalar.
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
    await initialize(ducking: _duckingEnabled);
    _queueUrls = const <String>[];
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (volume != null) await _player.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      AppLog.error(
        'Akış çalınamadı: $url',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Birden çok URL'yi sırayla ve kesintisiz çalar (sure / ayet dizisi).
  ///
  /// 286 ayetlik Bakara Suresi gibi uzun surelerde bile ExoPlayer'a aynı anda
  /// yüzlerce HTTP bağlantısı yüklemek yerine aktif ayeti anında başlatır ve
  /// her ayet bittiğinde bir sonrakine otomatik geçer.
  Future<bool> playUrlList(
    List<String> urls, {
    int initialIndex = 0,
    double? volume,
  }) async {
    if (urls.isEmpty) return false;
    await initialize(ducking: _duckingEnabled);
    try {
      final int startIdx = initialIndex.clamp(0, urls.length - 1);
      _queueUrls = List<String>.unmodifiable(urls);
      _queueIndex = startIdx;
      if (!_queueIndexController.isClosed) {
        _queueIndexController.add(_queueIndex);
      }
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_queueUrls[_queueIndex])),
      );
      await _player.setLoopMode(LoopMode.off);
      if (volume != null) await _player.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      _queueUrls = const <String>[];
      AppLog.error(
        'URL listesi çalınamadı',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Birden çok parçayı sırayla çalar (sure dinleme / albüm).
  Future<bool> playPlaylist(
    List<AudioSource> sources, {
    int initialIndex = 0,
  }) async {
    await initialize(ducking: _duckingEnabled);
    _queueUrls = const <String>[];
    try {
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
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
    unawaited(_player.play());
  }

  Future<void> pause() => _player.pause();

  Future<void> togglePlayPause() =>
      _status == PlaybackStatus.playing ? _player.pause() : play();

  Future<void> stop() async {
    _queueUrls = const <String>[];
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
  Future<void> fadeIn({
    double to = 1.0,
    Duration duration = const Duration(seconds: 2),
  }) async {
    const int steps = 20;
    final Duration stepDelay = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );
    for (int i = 1; i <= steps; i++) {
      await _player.setVolume((to * i / steps).clamp(0.0, 1.0));
      await Future<void>.delayed(stepDelay);
    }
  }

  Future<void> fadeOut({Duration duration = const Duration(seconds: 2)}) async {
    const int steps = 20;
    final Duration stepDelay = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );
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
    await _queueIndexController.close();
    await _playerInstance?.dispose();
  }
}

/// Dahili ezan makamları, bildirim tonları ve dini ezgilerin varlık yolları.
abstract final class BundledSounds {
  static const String ezanMelodi = 'assets/audio/adhan/ezan_melodi.wav';
  static const String sabaMelodi = 'assets/audio/adhan/ezan_saba.wav';
  static const String segahMelodi = 'assets/audio/adhan/ezan_segah.wav';
  static const String tekbirMelodi = 'assets/audio/adhan/ezan_tekbir.wav';
  static const String tone1 = 'assets/audio/adhan/ezan_ton_1.wav';
  static const String tone2 = 'assets/audio/adhan/ezan_ton_2.wav';
  static const String tone3 = 'assets/audio/adhan/ezan_ton_3.wav';
  static const String ilahiUssak = 'assets/audio/adhan/ilahi_ussak.wav';
  static const String ilahiHuseyni = 'assets/audio/adhan/ilahi_huseyni.wav';

  static String? assetFor(AdhanSound sound) => switch (sound) {
    AdhanSound.ezanMelodi => ezanMelodi,
    AdhanSound.sabaMelodi => sabaMelodi,
    AdhanSound.segahMelodi => segahMelodi,
    AdhanSound.tekbirMelodi => tekbirMelodi,
    AdhanSound.tone1 => tone1,
    AdhanSound.tone2 => tone2,
    AdhanSound.tone3 => tone3,
    _ => null,
  };
}
