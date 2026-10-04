# geolocator (geolocator-14.1.1)

## CHANGELOG (ilk 150 satır)
```
## 14.1.1

- Fixes the Android build of the example app by pinning the Kotlin Gradle plugin to 2.4.0 and the Android Gradle Plugin to 9.1.0, matching `geolocator_android`'s example.

## 14.1.0

- Updates `geolocator_platform_interface` to `^4.4.0`.
- Updates `geolocator_android` to `^5.1.0`.

## 14.0.4

- Fixes the Android build of the example app by updating the Android Gradle Plugin to 9.0.1 and Gradle to 9.1.0.

## 14.0.3

- Updates the following dependencies:
  - `geolocator_platform_interface` to 4.2.8
  - `geolocator_android` to 5.0.3
  - `geolocator_apple` to 2.3.14
  - `geolocator_linux` to 0.2.6
  - `geolocator_web` to 4.1.4
  - `flutter_lints` to 6.0.0

## 14.0.2

- Adds section about `UIBackgroundModes` to the README.
- Adds Linux as a supported platform to pubspec.

## 14.0.1

- Adds section about `FOREGROUND_SERVICE_LOCATION` to the README.
- Fixes PlatformException in example app for Android 14 (SDK level 34) and newer by updating manifest permissions.

## 14.0.0

- **BREAKING CHANGE:** for Flutter `3.27.0` and below. Make sure you'll upgrade Flutter to `3.29.0` or above before using this version.
- Bump `flutter_lints` to version of afp to 5.0.0
- Updated `geolocator_android` dependency to version `^5.0.0`

## 13.0.4

- Bump `flutter_lints` to version 5.0.0. Later added: of afp example project.

## 13.0.3

- Updates dart sdk to `sdk: ^3.5.0`
- Updates example project and fixes analyzer issues

## 13.0.2

- Updates dependency on geolocator_apple to version 2.3.8.
- Migrates Android configuration of example app away from imperative gradle API.

## 13.0.1

- Resolves problems when compiling non-web platforms because of illegal reference to `dart:js_interop`.

## 13.0.0

- **BREAKING CHANGE:** Deprecates getCurrentPosition desiredAccuracy, forceAndroidLocationManager, and timeLimit parameters in favor of supplying a LocationSettings class.
- Exposes `WebSettings` from geolocator.
- Updates dependency on geolocator_web to version 4.1.0
- Updates dependency on geolocator_android to version 4.3.0
- Updates dependency on geolocator_apple to version 2.3.7
- Updates dependency on geolocator_windows to version 0.2.3
- Updates dependency on geolocator_platform_interface to version 4.2.3

## 12.0.0

- **BREAKING CHANGE:** Updates dependency on geolocator_web to version [4.0.0](https://pub.dev/packages/geolocator_web/changelog).

## 11.1.0

- Expose `AndroidPosition` from geolocator.

## 11.0.0

- **BREAKING CHANGE:** Updates dependency on geolocator_web to version [3.0.0](https://pub.dev/packages/geolocator_web/changelog).

## 10.1.1

- Adds a description to the README on how to add the `BYPASS_PERMISSION_LOCATION_ALWAYS` preprocessor to bypass the need for adding the `NSLocationAlwaysUsageDescription` to the `Info.plist`.

## 10.1.0

- Includes `altitudeAccuracy` and `headingAccuracy` in `Position`.

## 10.0.1

- Updates documentation for `getCurrentPosition()`, to clarify the behavior of location accuracy on Android devices.
- Updates README regarding the plugin interpretation of `LocationAccuracy`.

## 10.0.0

- **BREAKING CHANGE:** Updates dependency on geolocator_windows to version 0.2.0. This will synchronize default values for `Position.altitude`, `Position.heading` and `Position.speed` with the other platforms.

## 9.0.2

- Updated dependency on geolocator_android to version 4.1.3
- Export `AndroidResource` class at `geolocator/lib/geolocator.dart.at`.

## 9.0.1

- Migrates to Dart SDK 2.15.0 and Flutter 2.8.0.

## 9.0.0

> **IMPORTANT:** when updating to version 9.0.0 make sure to also set the `compileSdkVersion` in the `android/app/build.gradle` file to `33`.

- Updates dependency on geolocator_android to version 4.0.0;
- Makes sure the Android example app compiles against Android SDK 33.

## 8.2.1

- Fixes repository URL of the package.

## 8.2.0

- Adds support to make a foreground service on Android and continue processing location updates when the application is moved into the background.
- Ensures that the `getCurrentPosition` takes the supplied accuracy into account.
- Improves the speed of acquiring the current position on iOS.
- Added additional option to `AppleSettings` class to allow the user to configure the background location indicator of `CLocationManager`.

## 8.1.1

- Updated README.md to clarify the use of the geolocator_web package.

## 8.1.0

- Endorses the geolocator_windows package.

## 8.0.5

- Fix code coverage issues by adding iOS specific test for getCurrentPosition

## 8.0.4

- Export `ActivityType` at `geolocator.dart`

## 8.0.3

- Upgraded the geolocator_platform_interface, geolocator_web, geolocator_apple and geolocator_android packages to the latest versions.

## 8.0.2

- Updated README.md to clarify the use of platform specific packages.

## 8.0.1

- Fix "forceAndroidLocationManager" for getLastKnownPosition
```

## README (ilk 200 satır)
```
# Flutter Geolocator Plugin  

[![pub package](https://img.shields.io/pub/v/geolocator.svg)](https://pub.dartlang.org/packages/geolocator) ![Build status](https://github.com/Baseflow/flutter-geolocator/workflows/geolocator/badge.svg?branch=master) [![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart) [![codecov](https://codecov.io/gh/Baseflow/flutter-geolocator/branch/master/graph/badge.svg)](https://codecov.io/gh/Baseflow/flutter-geolocator)

A Flutter geolocation plugin which provides easy access to platform specific location services ([FusedLocationProviderClient](https://developers.google.com/android/reference/com/google/android/gms/location/FusedLocationProviderClient) or if not available the [LocationManager](https://developer.android.com/reference/android/location/LocationManager) on Android and [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager) on iOS).

## Features

* Get the last known location;
* Get the current location of the device;
* Get continuous location updates;
* Check if location services are enabled on the device;
* Calculate the distance (in meters) between two geocoordinates;
* Calculate the bearing between two geocoordinates;

> **IMPORTANT:**
> 
> Version 7.0.0 of the geolocator plugin contains several breaking changes, for a complete overview please have a look at the [Breaking changes in 7.0.0](https://github.com/Baseflow/flutter-geolocator/wiki/Breaking-changes-in-7.0.0) wiki page.
> 
> Starting from version 6.0.0 the geocoding features (`placemarkFromAddress` and `placemarkFromCoordinates`) are no longer part of the geolocator plugin. We have moved these features to their own plugin: [geocoding](https://pub.dev/packages/geocoding). This new plugin is an improved version of the old methods.

## Usage

To add the geolocator to your Flutter application read the [install](https://pub.dev/packages/geolocator/install) instructions. Below are some Android and iOS specifics that are required for the geolocator to work correctly.
  
<details>
<summary>Android</summary>
  
**Upgrade pre 1.12 Android projects**
  
Since version 5.0.0 this plugin is implemented using the Flutter 1.12 Android plugin APIs. Unfortunately this means App developers also need to migrate their Apps to support the new Android infrastructure. You can do so by following the [Upgrading pre 1.12 Android projects](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects) migration guide. Failing to do so might result in unexpected behaviour.

**AndroidX** 

The geolocator plugin requires the AndroidX version of the Android Support Libraries. This means you need to make sure your Android project supports AndroidX. Detailed instructions can be found [here](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility). 

The TL;DR version is:

1. Add the following to your "gradle.properties" file:

```
android.useAndroidX=true
android.enableJetifier=true
```
2. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file to 35:

```
android {
  compileSdkVersion 35

  ...
}
```
3. Make sure you replace all the `android.` dependencies to their AndroidX counterparts (a full list can be found here: [Migrating to AndroidX](https://developer.android.com/jetpack/androidx/migrate)).

**Permissions**

On Android you'll need to add the `ACCESS_COARSE_LOCATION` permission to your Android Manifest, and the `ACCESS_FINE_LOCATION` permission if your app needs precise location. To do so open the AndroidManifest.xml file (located under android/app/src/main) and add the following line(s) as direct children of the `<manifest>` tag:

``` xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Include only if your app benefits from precise location access. -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Since Android 12 (API level 31) users can grant only approximate location even when your app requests `ACCESS_FINE_LOCATION`, so request both permissions together in a single runtime request rather than `ACCESS_FINE_LOCATION` on its own.

Starting from Android 10 you need to add the `ACCESS_BACKGROUND_LOCATION` permission (next to the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission) if you want to continue receiving updates even when your App is running in the background:

``` xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

Starting from Android 14 (SDK 34) the [`FOREGROUND_SERVICE_LOCATION`](https://developer.android.com/reference/android/Manifest.permission#FOREGROUND_SERVICE_LOCATION) permission is required to run a foreground service of type location, which this plugin uses to keep delivering updates while your app is in the foreground. The plugin's own manifest already declares it, so it is merged into your app automatically — no action needed on your part.

> **NOTE:** Specifying the `ACCESS_COARSE_LOCATION` permission results in location updates with an accuracy approximately equivalent to a city block. It might take a long time (minutes) before you will get your first locations fix as `ACCESS_COARSE_LOCATION` will only use the network services to calculate the position of the device. More information can be found [here](https://developer.android.com/training/location/retrieve-current#permissions). 


</details>

<details>
<summary>iOS</summary>

On iOS you'll need to add the following entry to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningful in the context of your App):

``` xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

If you don't need to receive updates when your app is in the background, then add a compiler flag as follows: in XCode, click on Pods, choose the Target 'geolocator_apple', choose Build Settings, in the search box look for 'Preprocessor Macros' then add the `BYPASS_PERMISSION_LOCATION_ALWAYS=1` flag.
Setting this flag prevents your app from requiring the `NSLocationAlwaysAndWhenInUseUsageDescription` entry in Info.plist, and avoids questions from Apple when submitting your app. 

You can also have the flag set automatically by adding the following to the `ios/Podfile` of your application:
```agsl
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "geolocator_apple"
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'BYPASS_PERMISSION_LOCATION_ALWAYS=1']
      end
    end
  end
end
```

If you do want to receive updates when your App is in the background (or if you don't bypass the permission request as described above) then you'll need to:
* Add the Background Modes capability to your XCode project (Project > Signing and Capabilities > "+ Capability" button) and select Location Updates. Be careful with this, you will need to explain in detail to Apple why your App needs this when submitting your App to the AppStore. If Apple isn't satisfied with the explanation your App will be rejected.
* Add an `NSLocationAlwaysAndWhenInUseUsageDescription` entry to your Info.plist (use `NSLocationAlwaysUsageDescription` if you're targeting iOS <11.0) 

When using the `requestTemporaryFullAccuracy({purposeKey: "YourPurposeKey"})` method, a dictionary should be added to the Info.plist file.
```xml
<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>YourPurposeKey</key>
  <string>The example App requires temporary access to the device&apos;s precise location.</string>
</dict>
```
The second key (in this example called `YourPurposeKey`) should match the purposeKey that is passed in the `requestTemporaryFullAccuracy()` method. It is possible to define multiple keys for different features in your app. More information can be found in Apple's [documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationtemporaryusagedescriptiondictionary).

> NOTE: the first time requesting temporary full accuracy access it might take several seconds for the pop-up to show. This is due to the fact that iOS is determining the exact user location which may take several seconds. Unfortunately this is out of our hands.
</details>

On iOS 16 and above you need to specify `UIBackgroundModes` `location` to receive location updates in the background.

``` xml
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>
```

<details>
<summary>macOS</summary>

On macOS you'll need to add the following entries to your Info.plist file (located under macOS/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningfull in the context of your App):

``` xml
<key>NSLocationUsageDescription</key>
<string>This app needs access to location.</string>
```

You will also have to add the following entry to the DebugProfile.entitlements and Release.entitlements files. This will declare that your App wants to make use of the device's location services and adds it to the list in the "System Preferences" -> "Security & Privace" -> "Privacy" settings.
```xml
<key>com.apple.security.personal-information.location</key>
<true/>
```

When using the `requestTemporaryFullAccuracy({purposeKey: "YourPurposeKey"})` method, a dictionary should be added to the Info.plist file.
```xml
<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>YourPurposeKey</key>
  <string>The example App requires temporary access to the device&apos;s precise location.</string>
</dict>
```
The second key (in this example called `YourPurposeKey`) should match the purposeKey that is passed in the `requestTemporaryFullAccuracy()` method. It is possible to define multiple keys for different features in your app. More information can be found in Apple's [documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationtemporaryusagedescriptiondictionary).

> NOTE: the first time requesting temporary full accuracy access it might take several seconds for the pop-up to show. This is due to the fact that macOS is determining the exact user location which may take several seconds. Unfortunately this is out of our hands.
</details>

<details>
<summary>Web</summary>

To use the Geolocator plugin on the web you need to be using Flutter 1.20 or higher. Flutter will automatically add the endorsed [geolocator_web]() package to your application when you add the `geolocator: ^6.2.0` dependency to your `pubspec.yaml`.

The following methods of the geolocator API are not supported on the web and will result in a `UnsupportedError`:

- `getLastKnownPosition({ bool forceAndroidLocationManager = true })`
- `openAppSettings()`
- `openLocationSettings()`
- `getServiceStatusStream()`

**NOTE**

Geolocator Web is available only in [secure_contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts) (HTTPS). More info about the Geolocator API can be found [here](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API).

</details>

<details>
<summary>Windows</summary>

To use the Geolocator plugin on Windows you need to be using Flutter 2.10 or higher. Flutter will automatically add the endorsed [geolocator_windows]() package to your application when you add the `geolocator: ^8.1.0` dependency to your `pubspec.yaml`.

</details>

### Example

The code below shows an example on how to acquire the current position of the device, including checking if the location services are enabled and checking / requesting permission to access the position of the device:

```dart
import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
```
