# vibration (vibration-3.2.1)

## CHANGELOG (ilk 150 satır)
```
### 3.2.1

- Update minimum iOS target to 13.0 (#151 by @mfurkanyuceal)

### 3.2.0

> Note: This release has breaking changes.
>
> Plugin now requires the following:
>
> - Dart SDK >=3.11.0
> - Flutter >=3.41.0

- Adds missing `FlutterFramework` dependency to `Package.swift` for Swift
  Package Manager compatibility.

### 3.1.8

- Fix `repeat` parameter ignored on iOS. (#145 by @zeienko-vitalii)

### 3.1.7

- Fix Android deprecation warning for VIBRATOR_SERVICE. (#144 by
  @zeienko-vitalii)

### 3.1.7-dev.1

- Attempt to fix deprecation warning on Android.

### 3.1.6

- Fix crash on Android. (#140 by @armanagarwal)

### 3.1.5

- Adds Swift Package Manager compatibility.

### 3.1.4

> Note: This release has breaking changes.
>
> Plugin now requires the following:
>
> - Android Gradle Plugin >=8.12.1
> - Gradle wrapper >=8.13
> - Kotlin 2.2.0

- Bump package `vibration_platform_interface` to "0.1.1"

### 3.1.3

- Fix intensities on iOS.
- Lower miminum Compile SDK version for Android to 34

### 3.1.2

- Restore `hasAmplitudeControl` and `hasCustomVibrationsSupport` methods.

### 3.1.1

- Fix some cases where intensities were not being used correctly.

### 3.1.0

- Add common vibration patterns for Android and iOS.
- Add `sharpness` parameter for iOS.
- Suppress deprecation warnings for `vibrate` method on Android.

### 3.0.0

- The plugin has been recreated from scratch to align with the latest Flutter
  and Dart features.
- The iOS version no longer depends on intensities and amplitude, and it now
  supports custom durations and patterns.
- The example app is more intuitive and user-friendly.
- Calling the `hasVibrator` method is no longer necessary.
- Adjustments for null safety have been implemented.

## 2.1.0

- Fix vibration on iOS
- All methods are now properly null-safe

## 2.0.1

- Bump package `vibration_platform_interface` to "0.0.2"

## 2.0.0

- Remove references to Android embedding v1
- Update package:web to ">=0.5.1 <2.0.0" (#105 by
  [dkrutskikh](https://github.com/dkrutskikh))

## 1.9.0

- Added OpenHarmony support
- Migrate to common platform implement (vibration_platform_interface)

## 1.8.4

- Added Web support (#95 by [san-smith](https://github.com/san-smith))

## 1.8.2

- Raise minimum and target SDK versions for Android to upgrade Gradle to 7.5.

## 1.8.0

- Use `device_info_plus` for `hasAmplitudeControl` and `hasVibrator` methods.

## 1.7.7

- Adds a namespace attribute to the Android build.gradle, for compatibility with
  Android Gradle Plugin 8.0.

## 1.7.6

- Update package's dart SDK max version (under 3.0.0)

## 1.7.5

- Bump `vibration_web` to 1.6.4.

## 1.7.4

- Migrating to null safety.

## 1.7.3

- Use targetEnvironment check on iOS.

## 1.7.2

- Updated description to indicate web support.

## 1.7.1

- Fix building on iOS.

## 1.7.0

- Use Android Embedding v2.

## 1.6.1

- Added Web support (#43 by [roulljdh](https://github.com/roulljdh))

## 1.5.0

- Fibration now works in backgroud on Android (#40 by
```

## README (ilk 200 satır)
```
# Vibration

[![Build Status](https://travis-ci.org/benjamindean/flutter_vibration.svg?branch=master)](https://travis-ci.org/benjamindean/flutter_vibration)

A plugin for handling Vibration API on iOS, Android, and web. [API docs.](https://pub.dartlang.org/documentation/vibration/latest/vibration/Vibration-class.html)

## Getting Started

1. Add `vibration` to the dependencies section of `pubspec.yaml`.

   ```yml
   dependencies:
     vibration: ^3.1.3
   ```

2. Import package:

   ```dart
   import 'package:vibration/vibration.dart';
   ```

## Methods

### hasVibrator

Check if the target device has vibration capabilities. Not required when using other methods.

```dart
if (await Vibration.hasVibrator()) {
    Vibration.vibrate();
}
```

### hasAmplitudeControl

Check if the target device has the ability to control the vibration amplitude,
introduced in Android 8.0 Oreo - false for all earlier API levels.

```dart
if (await Vibration.hasAmplitudeControl()) {
    Vibration.vibrate(amplitude: 128);
}
```

### hasCustomVibrationsSupport

Check if the device is able to vibrate with a custom duration, pattern or intensity.
May return `true` even if the device has no vibrator (if you want to check whether the device has a vibrator,
see [`hasVibrator`](#hasVibrator)).

```dart
if (await Vibration.hasCustomVibrationsSupport()) {
    Vibration.vibrate(duration: 1000);
} else {
    Vibration.vibrate();
    await Future.delayed(Duration(milliseconds: 500));
    Vibration.vibrate();
}
```

### vibrate

#### Method Arguments

- `duration`: Duration of the vibration in milliseconds. Default is 500ms.
- `pattern`: List of integers representing the vibration pattern. Alternates between wait and vibrate durations.
- `repeat`: Index in the pattern at which to repeat, or -1 for no repeat. Default is -1.
- `intensities`: List of integers representing the vibration intensities for each segment in the pattern.
- `amplitude`: Amplitude of the vibration. Range is 1 to 255. Default is -1 (use platform default).
- `sharpness`: Sharpness of the vibration. iOS only. Range is 0.0 to 1.0. Default is 0.5.
- `preset`: Predefined vibration preset. Overrides other parameters if provided.

#### With specific duration (for example, 1 second):

```dart
Vibration.vibrate(duration: 1000);
```

Default duration is 500ms.

#### With specific duration and specific amplitude (if supported):

```dart
Vibration.vibrate(duration: 1000, amplitude: 128);
```

#### With pattern (wait 500ms, vibrate 1s, wait 500ms, vibrate 2s):

```dart
Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
```

#### With pattern (wait 500ms, vibrate 1s, wait 500ms, vibrate 2s) at varying intensities (1 - min, 255 - max):

```dart
Vibration.vibrate(pattern: [500, 1000, 500, 2000], intensities: [1, 255]);
```

#### With vibration presets:

You can use predefined vibration presets for common use cases.

```dart
Vibration.vibrate(preset: VibrationPreset.alarm);
```

Available presets:

- `VibrationPreset.alarm`
- `VibrationPreset.notification`
- `VibrationPreset.heartbeat`
- `VibrationPreset.singleShortBuzz`
- `VibrationPreset.doubleBuzz`
- `VibrationPreset.tripleBuzz`
- `VibrationPreset.longAlarmBuzz`
- `VibrationPreset.pulseWave`
- `VibrationPreset.progressiveBuzz`
- `VibrationPreset.rhythmicBuzz`
- `VibrationPreset.gentleReminder`
- `VibrationPreset.quickSuccessAlert`
- `VibrationPreset.zigZagAlert`
- `VibrationPreset.softPulse`
- `VibrationPreset.emergencyAlert`
- `VibrationPreset.heartbeatVibration`
- `VibrationPreset.countdownTimerAlert`
- `VibrationPreset.rapidTapFeedback`
- `VibrationPreset.dramaticNotification`
- `VibrationPreset.urgentBuzzWave`

### cancel

Stop ongoing vibration.

```dart
Vibration.cancel();
```

## Android

The `VIBRATE` permission is required in AndroidManifest.xml.

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

Supports vibration with duration and pattern. On Android 8 (Oreo) and above, uses the [VibrationEffect](https://developer.android.com/reference/android/os/VibrationEffect) class.
For the rest of the usage instructions, see [Vibrator](https://developer.android.com/reference/android/os/Vibrator) class documentation.

## iOS

Supports vibration with duration and pattern on CoreHaptics devices. On older devices, the pattern is emulated with 500ms long vibrations.
You can check whether the current device has CoreHaptics support using [`hasCustomVibrationsSupport`](#hasCustomVibrationsSupport).

## OpenHarmony

The OpenHarmony implementation of [`vibration`][1].

[`vibration`][1] 在 OpenHarmony 平台的实现。

Add the following permission settings to your project's module.json5 file.

在你的项目的 `module.json5` 文件中增加以下权限设置。

```json
    "requestPermissions": [
         {"name" :  "ohos.permission.VIBRATE"},
    ]
```

## Usage

```yaml
dependencies:
  vibration: any
  vibration_ohos: any
```

`vibrateEffect` and `vibrateAttribute` are only exist in `VibrationOhos`.

```dart
 (VibrationPlatform.instance as VibrationOhos).vibrate(
   vibrateEffect: const VibratePreset(count: 100),
   vibrateAttribute: const VibrateAttribute(
     usage: 'alarm',
   ),
 );
```

[1]: https://pub.dev/packages/vibration
```
