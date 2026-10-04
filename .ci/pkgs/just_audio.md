# just_audio (just_audio-0.10.6)

## CHANGELOG (ilk 150 satır)
```
## 0.10.6

* Support AGP 9.
* Migrate Android build files to .kts

## 0.10.5

* Disable Android audio offload by default to prevent playback issues.
* Add androidAudioOffloadPreferences.
* Deprecate androidOffloadSchedulingEnabled.

## 0.10.4

* Fix bug on simultaneous loads.
* Fix dispose crash on iOS.
* Fix initial seek values on subsequent loads (@Abestanis).

## 0.10.3

* Fix pending timers bug in unit tests.
* Fix NPE in Android position broadcast.

## 0.10.2

* Add Player.playerEvent.
* Fix playing/playbackEvent emission order.
* Fix rxdart errors on lower bound rxdart 0.26.0.
* Fix MissingPluginException in dispose on iOS.

## 0.10.1

* Fix unhandled PlayerInterruptedException.
* Fix duplicate load in active state.
* Synchronize playlist API calls.
* Improve position accuracy over Bluetooth on Android.

## 0.10.0

* New playlist API.
* Deprecate ConcatenatingAudioSource - use playlist API instead.
* Deprecate LoopingAudioSource - Use List.filled(N, source) instead.
* Replace playbackEventStream.onError by errorStream.
* Add errorCode/errorMessage to PlaybackEvent.
* Add maxSkipsOnError constructor parameter.
* Fix conversion between milliBel and deciBel (@Chaphasilor).
* Bump min flutter version to 3.27.0, AGP to 8.5.2.

## 0.9.46

* Fix SwiftPM support on macOS.

## 0.9.45

* Add setWebSinkId for web (@dganzella).

## 0.9.44

* Add support for SwiftPM.

## 0.9.43

* Fix NPE in load on iOS/macOS.
* Migrate to media3 ExoPlayer 1.4.1 on Android (@hansvdwd and @ryanheise).

## 0.9.42

* Fix dealloc crash on iOS/macOS (@cristian1980).
* Fix Dart memory leak on dispose (@MinSeungHyun).
* Bump gradle to 8.5.0.

## 0.9.41

* Fix stop() to cause play() to return on iOS.

## 0.9.40

* Fix JDK 21 compile error.

## 0.9.39

* Apply preferPreciseDurationAndTiming to files (@canxin121).
* Add tag parameter to setUrl/setFilePath/setAsset (@mathisfouques).
* Add tag parameter to setClip (@goviral-ma).
* Support rxdart 0.28.x.

## 0.9.38

* Migrate to package:web.
* Add AudioPlayer.setWebCrossOrigin for CORS on web (@danielwinkler).

## 0.9.37

* Support useLazyPreparation on iOS/macOS.
* Add index in sequence to errors for Android/iOS/macOS.
* Fix seek to index UI update on iOS/macOS.

## 0.9.36

* Add setAllowsExternalPlayback on iOS/macOS.
* Support index-based seeking on Android/iOS/macOS.
* Add option to send headers/userAgent without proxy.
* Fix bug where user supplied headers are overwritten by defaults (@ctedgar).

## 0.9.35

* Fix nullable completer argument type (@srawlins).
* Support uuid 4.0.0 (@Pante).

## 0.9.34

* Support AGP 8 (@josephcrowell).
* Update AGP to 7.3.0.

## 0.9.33

* Update minimum flutter version to 3.0.

## 0.9.32

* Fix ignored tag parameter in AudioSource.asset().
* Fix ignored tag parameter in AudioSource.file().
* Fix nested URIs in HLS from EXT-X-MEDIA when using headers.

## 0.9.31

* Add a package parameter to AudioPlayer.setAsset() (@ewertonls).
* Add AudioSource.asset(), AudioSource.file().
* Fix tests for dart-sdk 2.5 (@ewertonls).

## 0.9.30

* Upgrade ExoPlayer to 2.18.1.
* Fix bug using headers with LockCachingAudioSource.
* Add LockCachingAudioSource.resolve().

## 0.9.29

* Fix bug in ConcatenatingAudioSource.clear().
* Fix bug where proxy drains origin faster than it feeds client.
* Fix bug where User Agent was not set on redirects (@mikel-snipd)
* Fix bug where StreamAudioSource requests are not closed when proxy is disposed (@mikel-snipd)

## 0.9.28

* Recursively apply headers to HLS fragments.
* Add positionDiscontinuityStream.

## 0.9.27

* Support offload scheduling on Android.
```

## README (ilk 200 satır)
```
# just_audio

just_audio is a feature-rich audio player for Android, iOS, macOS, web, Linux and Windows.

[Platform Support](#platform-support) — [API Documentation](https://pub.dev/documentation/just_audio/latest/just_audio/just_audio-library.html) — [Tutorials](#tutorials) — [Background Audio](https://pub.dev/packages/just_audio_background) — [Community Support](https://stackoverflow.com/questions/tagged/just-audio)

![Screenshot with arrows pointing to features](https://user-images.githubusercontent.com/19899190/125459608-e89cd6d4-9f09-426c-abcc-ed7513d9acfc.png)

### Quick synopsis

```dart
import 'package:just_audio/just_audio.dart';

final player = AudioPlayer();                   // Create a player
final duration = await player.setUrl(           // Load a URL
    'https://foo.com/bar.mp3');                 // Schemes: (https: | file: | asset: )
player.play();                                  // Play without waiting for completion
await player.play();                            // Play while waiting for completion
await player.pause();                           // Pause but remain ready to play
await player.seek(Duration(seconds: 10));       // Jump to the 10 second position
await player.setSpeed(2.0);                     // Twice as fast
await player.setVolume(0.5);                    // Half as loud
await player.stop();                            // Stop and free resources
```

### Migrating to 0.10.x

* iOS: As of audio_session 0.2.x, you may remove the compile flag `AUDIO_SESSION_MICROPHONE=0` as this is now the default.
* Instead of `player.setAudioSource(ConcatenatingAudioSource(children: sources))` use `player.setAudioSources(sources)`.
* Instead of `LoopingAudioSource(child: source, count: N)` use `...List.filled(N, source)`.
* Instead of listening to `player.playbackEventStream.onError`, listen to `player.errorStream`.
* If you would like to emulate the previous skip-on-error setting, use constructor parameter `maxSkipsOnError: 6`.

### Working with multiple players

```dart
// Set up two players with different audio files
final player1 = AudioPlayer(); await player1.setUrl(...);
final player2 = AudioPlayer(); await player2.setUrl(...);

// Play both at the same time
player1.play();
player2.play();

// Play one after the other
await player1.play();
await player2.play();

// Loop player1 until player2 finishes
await player1.setLoopMode(LoopMode.one);
player1.play();          // Don't wait
await player2.play();    // Wait for player2 to finish
await player1.pause();   // Finish player1

// Free platform decoders and buffers for each player.
await player1.stop();
await player2.stop();
```

### Working with clips

```dart
// Play clip 2-4 seconds followed by clip 10-12 seconds
await player.setClip(start: Duration(seconds: 2), end: Duration(seconds: 4));
await player.play(); await player.pause();
await player.setClip(start: Duration(seconds: 10), end: Duration(seconds: 12));
await player.play(); await player.pause();

await player.setClip(); // Clear clip region
```

### Working with gapless playlists

```dart
// Define the playlist
final playlist = <AudioSource>[
  AudioSource.uri(Uri.parse('https://example.com/track1.mp3')),
  AudioSource.uri(Uri.parse('https://example.com/track2.mp3')),
  AudioSource.uri(Uri.parse('https://example.com/track3.mp3')),
];
// Load the playlist
await player.setAudioSources(playlist, initialIndex: 0, initialPosition: Duration.zero,
  useLazyPreparation: true,                    // Load each item just in time
  shuffleOrder: DefaultShuffleOrder(),         // Customise the shuffle algorithm
);
await player.seekToNext();                     // Skip to the next item
await player.seekToPrevious();                 // Skip to the previous item
await player.seek(Duration.zero, index: 2);    // Skip to the start of track3.mp3
await player.setLoopMode(LoopMode.all);        // Set playlist to loop (off|all|one)
await player.setShuffleModeEnabled(true);      // Shuffle playlist order (true|false)

// Update the playlist
await player.addAudioSource(newChild1);
await player.insertAudioSource(3, newChild2);
await player.removeAudioSourceAt(3);
await player.moveAudioSource(2, 1);
```

### Working with headers

```dart
// Setting the HTTP user agent
final player = AudioPlayer(
  userAgent: 'myradioapp/1.0 (Linux;Android 11) https://myradioapp.com',
  useProxyForRequestHeaders: true, // default
);

// Setting request headers
final duration = await player.setUrl('https://foo.com/bar.mp3',
    headers: {'header1': 'value1', 'header2': 'value2'});
```

Note: By default, headers are implemented via a local HTTP proxy which on Android, iOS and macOS requires non-HTTPS support to be enabled. See [Platform Specific Configuration](#platform-specific-configuration).

Alternatively, settings `useProxyForRequestHeaders: false` will use the platform's native headers implementation without a proxy. Although note that iOS doesn't offer an official native API for setting headers, and so this will use the undocumented `AVURLAssetHTTPHeaderFieldsKey` API (or in the case of the user-agent header on iOS 16 and above, the official `AVURLAssetHTTPUserAgentKey` API).

### Working with caches

```dart
// Clear the asset cache directory
await AudioPlayer.clearAssetCache();

// Download and cache audio while playing it (experimental)
final audioSource = LockCachingAudioSource('https://foo.com/bar.mp3');
await player.setAudioSource(audioSource);
// Delete the cached file
await audioSource.clearCache();
```

Note: `LockCachingAudioSource` is implemented via a local HTTP proxy which on Android, iOS and macOS requires non-HTTPS support to be enabled. See [Platform Specific Configuration](#platform-specific-configuration).

### Working with stream audio sources

```dart
// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);
  
  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

await player.setAudioSource(MyCustomSource());
player.play();
```

Note: `StreamAudioSource` is implemented via a local HTTP proxy which on Android, iOS and macOS requires non-HTTPS support to be enabled. See [Platform Specific Configuration](#platform-specific-configuration).


### Working with errors

```dart
// Catching errors at load time
try {
  await player.setUrl("https://s3.amazonaws.com/404-file.mp3");
} on PlayerException catch (e) {
  // iOS/macOS: maps to NSError.code
  // Android: maps to ExoPlayerException.type
  // Web: maps to MediaError.code
  // Linux/Windows: maps to PlayerErrorCode.index
  print("Error code: ${e.code}");
  // iOS/macOS: maps to NSError.localizedDescription
  // Android: maps to ExoPlaybackException.getMessage()
  // Web/Linux: a generic message
  // Windows: MediaPlayerError.message
  print("Error message: ${e.message}");
} on PlayerInterruptedException catch (e) {
  // This call was interrupted since another audio source was loaded or the
  // player was stopped or disposed before this audio source could complete
  // loading.
  print("Connection aborted: ${e.message}");
} catch (e) {
  // Fallback for all other errors
  print('An error occured: $e');
}

// Listening to errors during playback (e.g. lost network connection)
player.errorStream.listen((PlayerException e) {
  print('Error code: ${e.code}');
  print('Error message: ${e.message}');
  print('AudioSource index: ${e.index}');
});
```

### Working with state streams

See [The state model](#the-state-model) for details.

```dart
```
