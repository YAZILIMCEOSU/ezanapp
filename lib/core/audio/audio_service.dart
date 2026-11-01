import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart'
    show ByteData, MethodChannel, Uint8List, rootBundle;
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
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  final StreamController<PlaybackStatus> _statusController =
      StreamController<PlaybackStatus>.broadcast();
  Stream<PlaybackStatus> get statusStream => _statusController.stream;

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  Stream<Duration> get durationStream => _durationController.stream;

  final StreamController<int> _queueIndexController =
      StreamController<int>.broadcast();
  Stream<int> get queueIndexStream => _queueIndexController.stream;

  List<String> _queueUrls = const <String>[];
  int _queueIndex = 0;
  bool _advancingQueue = false;
  bool _switchingSource = false;
  int _operationId = 0;
  int get currentQueueIndex => _queueIndex;
  int get queueLength => _queueUrls.length;

  // Global Kur'an / Ses oturumu bilgisi (farklı menülere geçilse bile korunur).
  int? _activeSurahNumber;
  String? _activeSurahName;
  String? _activeReciterName;
  int _activeTotalAyahs = 0;
  String? _activeCustomTitle;
  String? _activeCustomSubtitle;

  int? get activeSurahNumber => _activeSurahNumber;
  String? get activeSurahName => _activeSurahName;
  String? get activeReciterName => _activeReciterName;
  int get activeTotalAyahs => _activeTotalAyahs;
  int get activeAyahNumber => _queueIndex + 1;
  String? get activeCustomTitle => _activeCustomTitle;
  String? get activeCustomSubtitle => _activeCustomSubtitle;
  bool get hasActiveQuranSession =>
      _activeSurahNumber != null &&
      (_status == PlaybackStatus.playing ||
          _status == PlaybackStatus.paused ||
          _status == PlaybackStatus.loading);
  bool get hasActiveAudioSession =>
      _status == PlaybackStatus.playing ||
      _status == PlaybackStatus.paused ||
      _status == PlaybackStatus.loading;

  void setQuranSession({
    required int surahNumber,
    required String surahName,
    required String reciterName,
    required int totalAyahs,
  }) {
    _activeSurahNumber = surahNumber;
    _activeSurahName = surahName;
    _activeReciterName = reciterName;
    _activeTotalAyahs = totalAyahs;
    _activeCustomTitle = null;
    _activeCustomSubtitle = null;
    if (!_statusController.isClosed) _statusController.add(_status);
  }

  void _clearQuranSession() {
    _activeSurahNumber = null;
    _activeSurahName = null;
    _activeReciterName = null;
    _activeTotalAyahs = 0;
  }

  PlaybackStatus _status = PlaybackStatus.idle;
  PlaybackStatus get status => _status;

  static const MethodChannel _hardwareChannel = MethodChannel(
    'ezanai/sensors/methods',
  );

  bool _initialized = false;
  bool _duckingEnabled = true;
  bool _pausedByInterruption = false;
  double _lastVolume = 1.0;

  Duration _lastPosition = Duration.zero;
  Duration? _lastDuration;
  Duration? get position => _lastPosition;
  Duration? get duration => _playerInstance?.duration ?? _lastDuration;

  double _speed = 1.0;
  double get speed => _speed;

  void _setHardwareWakeLock(bool enabled) {
    try {
      unawaited(
        _hardwareChannel.invokeMethod<bool>(
          'setAudioWakeLock',
          <String, Object?>{'enabled': enabled},
        ),
      );
    } catch (_) {}
  }

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
          if (event.type == AudioInterruptionType.duck) {
            // Bildirim geldiğinde ezan/Kur'an/ilahi durdurulmaz; yalnızca
            // bildirim süresince ses hafif kısılır.
            unawaited(_player.setVolume((_lastVolume * 0.45).clamp(0.1, 1.0)));
            return;
          }
          AppLog.debug('Ses kesintisi başladı (${event.type.name})');
          if (_status == PlaybackStatus.playing) {
            _pausedByInterruption = true;
            unawaited(_player.pause());
          }
        } else {
          if (event.type == AudioInterruptionType.duck) {
            unawaited(_player.setVolume(_lastVolume.clamp(0.0, 1.0)));
            return;
          }
          AppLog.debug('Ses kesintisi bitti');
          if (_pausedByInterruption) {
            _pausedByInterruption = false;
            unawaited(_player.play());
          }
        }
      });
      session.becomingNoisyEventStream.listen(
        (_) => unawaited(_player.pause()),
      );
    } catch (error) {
      AppLog.warning('Ses oturumu yapılandırılamadı: $error');
    }

    _stateSub = _player.playerStateStream.listen((PlayerState state) {
      if (_switchingSource) {
        return;
      }

      if (state.processingState == ProcessingState.completed) {
        if (_queueUrls.isNotEmpty && _queueIndex + 1 < _queueUrls.length) {
          if (!_advancingQueue) {
            unawaited(_advanceQueue());
          }
          return;
        }
        _queueUrls = const <String>[];
        _clearQuranSession();
        _activeCustomTitle = null;
        _activeCustomSubtitle = null;
        _status = PlaybackStatus.completed;
        _setHardwareWakeLock(false);
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
      _setHardwareWakeLock(
        _status == PlaybackStatus.playing || _status == PlaybackStatus.loading,
      );
      if (!_statusController.isClosed) _statusController.add(_status);
    });

    _errorSub = _player.errorStream.listen((PlayerException error) {
      if (_switchingSource || _advancingQueue) {
        return;
      }
      final String msg = (error.message ?? '').toLowerCase();
      if (msg.contains('interrupted') || msg.contains('abort')) {
        return;
      }
      AppLog.warning('Oynatma hatası: ${error.message}');
      _status = PlaybackStatus.error;
      if (!_statusController.isClosed) {
        _statusController.add(PlaybackStatus.error);
      }
    });

    _positionSub = _player
        .createPositionStream(
          minPeriod: const Duration(milliseconds: 45),
          maxPeriod: const Duration(milliseconds: 90),
        )
        .listen((Duration position) {
          _lastPosition = position;
          if (!_positionController.isClosed) _positionController.add(position);
        });

    _durationSub = _player.durationStream.listen((Duration? d) {
      if (d != null && d > Duration.zero) {
        _lastDuration = d;
        if (!_durationController.isClosed) _durationController.add(d);
      }
    });
  }

  Future<void> _advanceQueue() async {
    if (_advancingQueue) return;
    _advancingQueue = true;
    try {
      while (_queueUrls.isNotEmpty && _queueIndex + 1 < _queueUrls.length) {
        _queueIndex += 1;
        _lastPosition = Duration.zero;
        _lastDuration = null;
        if (!_queueIndexController.isClosed) {
          _queueIndexController.add(_queueIndex);
        }
        final String nextUrl = _queueUrls[_queueIndex];
        try {
          final Duration? d = await _player.setAudioSource(
            AudioSource.uri(Uri.parse(nextUrl)),
          );
          if (d != null && d > Duration.zero) {
            _lastDuration = d;
            if (!_durationController.isClosed) _durationController.add(d);
          }
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

  /// Çok parçalı kuyrukta belirli bir indekse (ayete/bölüme) atlar.
  Future<bool> jumpToQueueIndex(int targetIndex) async {
    if (_queueUrls.isEmpty) return false;
    final int clamped = targetIndex.clamp(0, _queueUrls.length - 1);
    final int op = ++_operationId;
    _advancingQueue = true;
    try {
      _queueIndex = clamped;
      _lastPosition = Duration.zero;
      _lastDuration = null;
      if (!_queueIndexController.isClosed) {
        _queueIndexController.add(_queueIndex);
      }
      final Duration? d = await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_queueUrls[_queueIndex])),
      );
      if (op != _operationId) return false;
      if (d != null && d > Duration.zero) {
        _lastDuration = d;
        if (!_durationController.isClosed) _durationController.add(d);
      }
      await _player.setLoopMode(LoopMode.off);
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error) {
      AppLog.warning('Kuyruk indeksine atlanamadı ($clamped): $error');
      return false;
    } finally {
      _advancingQueue = false;
    }
  }

  Future<void> _applyDucking() async {
    try {
      final AudioSession session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          // Ezan, Kur'an ve ilahi 3+ dakika sürdüğünden her zaman kalıcı
          // "gain" odağı alınır; aksi halde Android "gainTransientMayDuck"
          // odağını 30-40 saniye sonra otomatik iptal edebilir.
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
      await session.setActive(true);
    } catch (error) {
      AppLog.warning('Ses odağı ayarlanamadı', error: error);
    }
  }

  /// Yerel dosya (indirilen içerik) çalar.
  Future<bool> playFile(
    String path, {
    double? volume,
    bool loop = false,
    String? title,
    String? subtitle,
  }) async {
    await initialize(ducking: _duckingEnabled);
    final int op = ++_operationId;
    _switchingSource = true;
    _pausedByInterruption = false;
    _queueUrls = const <String>[];
    _clearQuranSession();
    _activeCustomTitle = title;
    _activeCustomSubtitle = subtitle;
    _lastPosition = Duration.zero;
    _lastDuration = null;
    try {
      if (!File(path).existsSync()) {
        AppLog.warning('Ses dosyası bulunamadı: $path');
        return false;
      }
      _setHardwareWakeLock(true);
      try {
        await _player.stop();
      } catch (_) {}
      if (op != _operationId) return false;
      await _player.setAudioSource(AudioSource.file(path));
      if (op != _operationId) return false;
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (volume != null) {
        _lastVolume = volume.clamp(0.0, 1.0);
        await _player.setVolume(_lastVolume);
      }
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      _setHardwareWakeLock(false);
      AppLog.error('Dosya çalınamadı', error: error, stackTrace: stackTrace);
      return false;
    } finally {
      if (op == _operationId) {
        _switchingSource = false;
      }
    }
  }

  static String _normalizeAssetPath(String assetPath) {
    if (assetPath.endsWith('.wav') &&
        assetPath.startsWith('assets/audio/adhan/')) {
      return '${assetPath.substring(0, assetPath.length - 4)}.mp3';
    }
    return assetPath;
  }

  /// Varlık (asset) dosyası çalar — dahili gerçek ezan ve ilahi sesleri.
  ///
  /// Tüm Android sürümlerinde sorunsuz çalışması için önce varlığı geçici
  /// yerel dosyaya çıkarıp ExoPlayer üzerinden yerel dosya olarak çalar.
  Future<bool> playAsset(
    String assetPath, {
    double volume = 1.0,
    bool loop = false,
    String? title,
    String? subtitle,
  }) async {
    await initialize(ducking: _duckingEnabled);
    final int op = ++_operationId;
    _switchingSource = true;
    _pausedByInterruption = false;
    _queueUrls = const <String>[];
    _clearQuranSession();
    _activeCustomTitle = title;
    _activeCustomSubtitle = subtitle;
    _lastPosition = Duration.zero;
    _lastDuration = null;
    _lastVolume = volume.clamp(0.0, 1.0);
    final String resolvedAsset = _normalizeAssetPath(assetPath);
    try {
      _setHardwareWakeLock(true);
      try {
        await _player.stop();
      } catch (_) {}
      if (op != _operationId) return false;
      final ByteData data = await rootBundle.load(resolvedAsset);
      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final String safeName = 'ezan_v4_${resolvedAsset.replaceAll('/', '_')}';
      final File tempFile = File('${Directory.systemTemp.path}/$safeName');
      if (!tempFile.existsSync() || tempFile.lengthSync() != bytes.length) {
        await tempFile.writeAsBytes(bytes, flush: true);
      }
      if (op != _operationId) return false;
      await _player.setAudioSource(AudioSource.file(tempFile.path));
      if (op != _operationId) return false;
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _player.setVolume(_lastVolume);
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (_) {
      try {
        if (op != _operationId) return false;
        await _player.setAudioSource(AudioSource.asset(resolvedAsset));
        if (op != _operationId) return false;
        await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
        await _player.setVolume(_lastVolume);
        unawaited(_player.play());
        _status = PlaybackStatus.playing;
        if (!_statusController.isClosed) _statusController.add(_status);
        return true;
      } catch (error, stackTrace) {
        _setHardwareWakeLock(false);
        AppLog.error(
          'Varlık çalınamadı: $resolvedAsset',
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      }
    } finally {
      if (op == _operationId) {
        _switchingSource = false;
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
    final int op = ++_operationId;
    _switchingSource = true;
    _pausedByInterruption = false;
    _queueUrls = const <String>[];
    _clearQuranSession();
    _activeCustomTitle = title;
    _activeCustomSubtitle = artist ?? album;
    _lastPosition = Duration.zero;
    _lastDuration = null;
    try {
      _setHardwareWakeLock(true);
      try {
        await _player.stop();
      } catch (_) {}
      if (op != _operationId) return false;
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      if (op != _operationId) return false;
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (volume != null) {
        _lastVolume = volume.clamp(0.0, 1.0);
        await _player.setVolume(_lastVolume);
      }
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      _setHardwareWakeLock(false);
      AppLog.error(
        'Akış çalınamadı: $url',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      if (op == _operationId) {
        _switchingSource = false;
      }
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
    final int op = ++_operationId;
    _switchingSource = true;
    _pausedByInterruption = false;
    _lastPosition = Duration.zero;
    _lastDuration = null;
    try {
      _setHardwareWakeLock(true);
      try {
        await _player.stop();
      } catch (_) {}
      if (op != _operationId) return false;
      final int startIdx = initialIndex.clamp(0, urls.length - 1);
      _queueUrls = List<String>.unmodifiable(urls);
      _queueIndex = startIdx;
      if (!_queueIndexController.isClosed) {
        _queueIndexController.add(_queueIndex);
      }
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_queueUrls[_queueIndex])),
      );
      if (op != _operationId) return false;
      await _player.setLoopMode(LoopMode.off);
      if (volume != null) {
        _lastVolume = volume.clamp(0.0, 1.0);
        await _player.setVolume(_lastVolume);
      }
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      _setHardwareWakeLock(false);
      _queueUrls = const <String>[];
      AppLog.error(
        'URL listesi çalınamadı',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      if (op == _operationId) {
        _switchingSource = false;
      }
    }
  }

  /// Birden çok parçayı sırayla çalar (sure dinleme / albüm).
  Future<bool> playPlaylist(
    List<AudioSource> sources, {
    int initialIndex = 0,
  }) async {
    await initialize(ducking: _duckingEnabled);
    final int op = ++_operationId;
    _switchingSource = true;
    _pausedByInterruption = false;
    _queueUrls = const <String>[];
    try {
      _setHardwareWakeLock(true);
      try {
        await _player.stop();
      } catch (_) {}
      if (op != _operationId) return false;
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      if (op != _operationId) return false;
      unawaited(_player.play());
      _status = PlaybackStatus.playing;
      if (!_statusController.isClosed) _statusController.add(_status);
      return true;
    } catch (error, stackTrace) {
      _setHardwareWakeLock(false);
      AppLog.error('Liste çalınamadı', error: error, stackTrace: stackTrace);
      return false;
    } finally {
      if (op == _operationId) {
        _switchingSource = false;
      }
    }
  }

  Future<void> play() async {
    if (_status == PlaybackStatus.completed) {
      await _player.seek(Duration.zero);
    }
    _pausedByInterruption = false;
    _setHardwareWakeLock(true);
    unawaited(_player.play());
    _status = PlaybackStatus.playing;
    if (!_statusController.isClosed) _statusController.add(_status);
  }

  Future<void> pause() async {
    _pausedByInterruption = false;
    _setHardwareWakeLock(false);
    await _player.pause();
    _status = PlaybackStatus.paused;
    if (!_statusController.isClosed) _statusController.add(_status);
  }

  Future<void> togglePlayPause() =>
      _status == PlaybackStatus.playing ? pause() : play();

  Future<void> stop() async {
    ++_operationId;
    _switchingSource = false;
    _advancingQueue = false;
    _pausedByInterruption = false;
    _queueUrls = const <String>[];
    _clearQuranSession();
    _activeCustomTitle = null;
    _activeCustomSubtitle = null;
    _lastPosition = Duration.zero;
    if (_playerInstance != null) {
      _setHardwareWakeLock(false);
      await _playerInstance!.stop();
    }
    _status = PlaybackStatus.idle;
    if (!_statusController.isClosed) _statusController.add(_status);
  }

  Future<void> seek(Duration position) async {
    _lastPosition = position;
    if (!_positionController.isClosed) _positionController.add(position);
    await _player.seek(position);
  }

  Future<void> seekToIndex(int index) =>
      _player.seek(Duration.zero, index: index);

  Future<void> setVolume(double volume) async {
    _lastVolume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_lastVolume);
  }

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
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _statusController.close();
    await _positionController.close();
    await _durationController.close();
    await _queueIndexController.close();
    await _playerInstance?.dispose();
  }
}

/// Dahili gerçek müezzin ezan makamları, bildirim sesleri ve vokal ilahilerin varlık yolları.
abstract final class BundledSounds {
  static const String ezanMelodi = 'assets/audio/adhan/ezan_melodi.mp3';
  static const String sabaMelodi = 'assets/audio/adhan/ezan_saba.mp3';
  static const String segahMelodi = 'assets/audio/adhan/ezan_segah.mp3';
  static const String tekbirMelodi = 'assets/audio/adhan/ezan_tekbir.mp3';
  static const String tone1 = 'assets/audio/adhan/ezan_ton_1.mp3';
  static const String tone2 = 'assets/audio/adhan/ezan_ton_2.mp3';
  static const String tone3 = 'assets/audio/adhan/ezan_ton_3.mp3';
  static const String ilahiUssak = 'assets/audio/adhan/ilahi_ussak.mp3';
  static const String ilahiHuseyni = 'assets/audio/adhan/ilahi_huseyni.mp3';
  static const String ilahiHayir = 'assets/audio/adhan/ilahi_hayir.mp3';
  static const String ilahiHidayet = 'assets/audio/adhan/ilahi_hidayet.mp3';

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
