# audio_session (audio_session-0.2.4)

## CHANGELOG (ilk 150 satır)
```
## 0.2.4

* Support AGP 9.
* Migrate Android build files to .kts

## 0.2.3

* Fix AVAudioSession() method handler throwing when arguments is null (@snipd-mikel).
* Fix audioAttributes being ignored on Android (@LucasAlbergoni).
* Fix setCommunicationDevice by eliminating cache (@dballance).

## 0.2.2

* Run setCategory in a thread on iOS to avoid jank (@MinseokKang003).

## 0.2.1

* Fix NPE on Android in device encoding.

## 0.2.0

* Breaking change: AUDIO_SESSION_MICROPHONE=0 by default on iOS.
* Migrate to Kotlin.
* Bump min flutter version to 3.27.0, AGP to 8.5.2.

## 0.1.25

* Fix SwiftPM support on macOS.

## 0.1.24

* Add support for SwiftPM.
* Define AVAudioSessionCategory constants using raw strings.

## 0.1.23

* Replace androidx.media2 by androidx.media.
* Bump Android minSdk from 16 to 19.
* Fix Android lints.

## 0.1.22

* Add prefersNoInterruptionsFromSystemAlerts (@AlexBacich).
* Add inputGain features to AVAudioSession (@Volsavr).
* Export Android broadcast receivers for SDK >= 33 (@techieasif).
* Fix dispatchMediaKeyEvent error (@yellowfisherz).
* Handle iOS exception in setActive (@lsslu).

## 0.1.21

* Fix compile error with JDK 21 (@bartekpacia).

## 0.1.20

* Support rxdart 0.28.x.

## 0.1.19

* Run setActive in a thread on iOS to avoid jank (@jointhejourney).
* Update minimum iOS version to 12.0.

## 0.1.18

* Fix parameter type in AVAudioSessionCategoryOptions.contains (@kainosk).
* Fix parameter type in AVAudioSessionSetActiveOptions.contains (@kainosk).

## 0.1.17

* Fix compile error with Android SDK 34.

## 0.1.16

* Use lowercase topics.

## 0.1.15

* AGP 8 compatibility (@josephcrowell).
* Update AGP to 7.3.0.
* Apply flutter_lints.

## 0.1.14

* Update minimum flutter version to 3.0.

## 0.1.13

* Fix compile error with older rxdart 0.26.*.

## 0.1.12

* Add AndroidAudioManager.scoAudioEventStream (@rwrz)
* Add AndroidAudioManager.currentScoAudioState (@rwrz)

## 0.1.11

* Fix iOS bug where devicesChangedEventStream was not firing.

## 0.1.10

* Add communication device methods for Android 31 (@towynlin).

## 0.1.9

* Fix iOS error when decoding portType.

## 0.1.8

* Fix bug in AndroidAudioManager.getMicrophones().

## 0.1.7

* Fix bug detecting added devices on iOS/macOS (@derekcoder).
* Fix bug decoding Android enums.
* Migrate to Flutter 3, Android 31

## 0.1.6+1

* Hide iOS/macOS logs.

## 0.1.6

* Update Android Gradle dependencies.
* Fix Android compiler warnings.
* Fix setBluetoothScoOn bug.

## 0.1.5

* Add more missing API level checks on Android.

## 0.1.4

* Add missing API level checks on Android.

## 0.1.3

* Mostly complete AndroidAudioManager API.
* Mostly complete AVAudioSession API.
* Unified Android/iOS API for device discovery.
* Option to remove iOS microphone code at compile time.

## 0.1.2

* Support rxdart 0.27.0.

## 0.1.1

* Fix iOS interruption notifications bug.
* Fix deprecated warnings on Android (@lhartman1).

## 0.1.0
```

## README (ilk 200 satır)
```
# audio_session

This plugin informs the operating system of the nature of your audio app (e.g. game, media player, assistant, etc.) and how your app will handle and initiate audio interruptions (e.g. phone call interruptions). It also provides access to all of the capabilities of AVAudioSession on iOS and AudioManager on Android, providing for discoverability and configuration of audio hardware.

Audio apps often have unique requirements. For example, when a navigator app speaks driving instructions, a music player should duck its audio while a podcast player should pause its audio. Depending on which one of these three apps you are building, you will need to configure your app's audio settings and callbacks to appropriately handle these interactions.

This plugin can be used both by app developers, to initialise appropriate audio settings for their app, and by plugin authors, to provide easy access to low level features of iOS's AVAudioSession and Android's AudioManager in Dart.

## For app developers

### Configuring the audio session

Configure your app's audio session with reasonable defaults for playing music:

```dart
final session = await AudioSession.instance;
await session.configure(AudioSessionConfiguration.music());
```

Configure your app's audio session with reasonable defaults for playing podcasts/audiobooks:

```dart
final session = await AudioSession.instance;
await session.configure(AudioSessionConfiguration.speech());
```

Or use a custom configuration:

```dart
final session = await AudioSession.instance;
await session.configure(AudioSessionConfiguration(
  avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
  avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
  avAudioSessionMode: AVAudioSessionMode.spokenAudio,
  avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
  avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
  androidAudioAttributes: const AndroidAudioAttributes(
    contentType: AndroidAudioContentType.speech,
    flags: AndroidAudioFlags.none,
    usage: AndroidAudioUsage.voiceCommunication,
  ),
  androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
  androidWillPauseWhenDucked: true,
));
```

Note that iOS (and hence this plugin) provides a single audio session to your app which is shared by all of the different audio plugins you use. If your app uses multiple audio plugins, e.g. any combination of audio recording, text to speech, background audio, audio playing, or speech recognition, then it is possible that those plugins may internally overwrite each other's choice of these global system audio settings, including the ones you set via this plugin. Therefore, it is recommended that you apply your own preferred configuration using audio_session after all other audio plugins have loaded. You may consider asking the developer of each audio plugin you use to provide an option to not overwrite these global settings and allow them be managed externally.

### Activating the audio session

Each time you invoke an audio plugin to play audio, that plugin will activate your app's shared audio session to inform the operating system that your app is now actively playing audio. Depending on the configuration set above, this will also inform other audio apps to either stop playing audio, or possibly continue playing at a lower volume (i.e. ducking). You normally do not need to activate the audio session yourself, however if the audio plugin you use does not activate the audio session, you can activate it yourself:

```dart
// Activate the audio session before playing audio.
if (await session.setActive(true)) {
  // Now play audio.
} else {
  // The request was denied and the app should not play audio
}
```

### Reacting to audio interruptions

When another app (e.g. navigator, phone app, music player) activates its audio session, it similarly may ask your app to pause or duck its audio. Once again, the particular audio plugin you use may automatically pause or duck audio when requested. However, if it does not (or if you have switched off this behaviour), then you can respond to these events yourself by listening to `session.interruptionEventStream`. Similarly, if the audio plugin doesn't handle unplugged headphone events, you can respond to these yourself by listening to `session.becomingNoisyEventStream`.

Observe interruptions to the audio session:

```dart
session.interruptionEventStream.listen((event) {
  if (event.begin) {
    switch (event.type) {
      case AudioInterruptionType.duck:
        // Another app started playing audio and we should duck.
        break;
      case AudioInterruptionType.pause:
      case AudioInterruptionType.unknown:
        // Another app started playing audio and we should pause.
        break;
    }
  } else {
    switch (event.type) {
      case AudioInterruptionType.duck:
        // The interruption ended and we should unduck.
        break;
      case AudioInterruptionType.pause:
        // The interruption ended and we should resume.
      case AudioInterruptionType.unknown:
        // The interruption ended but we should not resume.
        break;
    }
  }
});
```

Observe unplugged headphones:

```dart
session.becomingNoisyEventStream.listen((_) {
  // The user unplugged the headphones, so we should pause or lower the volume.
});
```

Observe when devices are added or removed:

```dart
session.devicesChangedEventStream.listen((event) {
  print('Devices added:   ${event.devicesAdded}');
  print('Devices removed: ${event.devicesRemoved}');
});
```

## For plugin authors

This plugin provides easy access to the iOS AVAudioSession and Android AudioManager APIs from Dart, and provides a unified API to activate the audio session for both platforms:

```dart
// Activate the audio session before playing or recording audio.
if (await session.setActive(true)) {
  // Now play or record audio.
} else {
  // The request was denied and the app should not play audio
  // e.g. a phonecall is in progress.
}
```

On iOS this calls `AVAudioSession.setActive` and on Android this calls `AudioManager.requestAudioFocus`. In addition to calling the lower level APIs, it also registers callbacks and forwards events to Dart via the streams `AudioSession.interruptionEventStream` and `AudioSession.becomingNoisyEventStream`. This allows both plugins and apps to interface with a shared instance of the audio focus request and audio session without conflict.

If a plugin can handle audio interruptions (i.e. by listening to the `interruptionEventStream` and automatically pausing audio), it is preferable to provide an option to turn this feature on or off, since some apps may have specialised requirements. e.g.:

```dart
player = AudioPlayer(handleInterruptions: false);
```

Note that iOS and Android have fundamentally different ways to set the audio attributes and categories: for iOS it is app-wide, while for Android it is per player or audio track. As such, `audioSession.configure()` can and does set the app-wide configuration on iOS immediately, while on Android these app-wide settings are stored within audio_session and can be obtained by individual audio plugins via a Stream. The following code shows how a player plugin can listen for changes to the Android AudioAttributes and apply them:

```dart
audioSession.configurationStream
    .map((conf) => conf?.androidAudioAttributes)
    .distinct()
    .listen((attributes) {
  // apply the attributes to this Android audio track
  _channel.invokeMethod("setAudioAttributes", attributes.toJson());
});
```

All numeric values encoded in `AndroidAudioAttributes.toJson()` correspond exactly to the Android platform constants.

`configurationStream` will always emit the latest configuration as the first event upon subscribing, and so the above code will handle both the initial configuration choice and subsequent changes to it throughout the life of the app.

## iOS setup

If you wish to use any of the APIs that access the microphone (`getRecordPermission`, `requestRecordPermission`), add this key to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>... explain why the app uses the microphone here ...</string>
```

Next, pass a build option to this plugin to enable the microphone code in your build. This can be done with either CocoaPods or SwiftPM builds.

### CocoaPods

Edit your `ios/Podfile` as follows:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # ADD THE NEXT SECTION
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'AUDIO_SESSION_MICROPHONE=1'
      ]
    end
    
  end
end
```

### SwiftPM

Run `flutter clean` to force SwiftPM to pick up your new settings:

```
flutter clean
```

Export the environment variable `AUDIO_SESSION_MICROPHONE=1` before running your build command. E.g. Using the bash command line:

```
AUDIO_SESSION_MICROPHONE=1 flutter run
```

Note: `flutter clean` is needed whenever the value of `AUDIO_SESSION_MICROPHONE` changes, or whenever you switch between different projects that use audio_session with different `AUDIO_SESSION_MICROPHONE` values.
```
