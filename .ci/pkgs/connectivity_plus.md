# connectivity_plus (connectivity_plus-7.3.1)

## CHANGELOG (ilk 150 satır)
```
## 7.3.1

 - **FIX**(connectivity_plus): prevent Linux client leaks ([#3929](https://github.com/fluttercommunity/plus_plugins/issues/3929)). ([bab4cd3e](https://github.com/fluttercommunity/plus_plugins/commit/bab4cd3ea03c8a402121bf5c5af68fc2dbb16892))

## 7.3.0

 - **FEAT**(connectivity_plus): add hasConnectivity() utility extension ([#3842](https://github.com/fluttercommunity/plus_plugins/issues/3842)). ([4c623ae9](https://github.com/fluttercommunity/plus_plugins/commit/4c623ae91269d0aa2e795508c2d6f94659f51ef2))
 - **FIX**(connectivity_plus): guard eventSink after engine teardown (iOS) ([#3797](https://github.com/fluttercommunity/plus_plugins/issues/3797)). ([bf04cdf6](https://github.com/fluttercommunity/plus_plugins/commit/bf04cdf66598dc3fca274b8b1db2b92b0bf6b73e))
 - **FIX**(connectivity_plus): raise Apple platform minimums in SPM manifests to match FlutterFramework ([#3920](https://github.com/fluttercommunity/plus_plugins/issues/3920)). ([b3bb72e6](https://github.com/fluttercommunity/plus_plugins/commit/b3bb72e6f7fe5a41b8268ac855da7b55e274265b))
 - **FIX**(connectivity_plus): use Windows list manager events ([#3829](https://github.com/fluttercommunity/plus_plugins/issues/3829)). ([c876d41f](https://github.com/fluttercommunity/plus_plugins/commit/c876d41f259301d0ad6662afcf72e8aed4b74925))
 - **FIX**(connectivity_plus): improve network callback unregistration handling ([#3681](https://github.com/fluttercommunity/plus_plugins/issues/3681)). ([3e150ba7](https://github.com/fluttercommunity/plus_plugins/commit/3e150ba7d6c3219e022572b565000eedd4bedfd5))
 - **DOCS**(connectivity_plus): Update min iOS and MacOS in README ([#3926](https://github.com/fluttercommunity/plus_plugins/issues/3926)). ([a0207591](https://github.com/fluttercommunity/plus_plugins/commit/a0207591ad8d503a29c2e953f2c4ea7796b89f68))

## 7.2.0

 - **FEAT**(connectivity_plus): Updated Swift Package Manager setup for Flutter 3.44 ([#3893](https://github.com/fluttercommunity/plus_plugins/issues/3893)). ([9c064c2e](https://github.com/fluttercommunity/plus_plugins/commit/9c064c2eaa50c13f27a6e7d2b788f57580658353))

## 7.1.1

 - **DOCS**(connectivity_plus): Add missing info about Xcode 26.1.1 requirement, deduplicate headers ([#3792](https://github.com/fluttercommunity/plus_plugins/issues/3792)). ([ba6e6b94](https://github.com/fluttercommunity/plus_plugins/commit/ba6e6b94f673bb479a5891b8ca0fc5fd7b2345bc))

## 7.1.0

 - **FIX**(connectivity_plus): Register broadcast receiver with correct flag, bump minSDK to 21 ([#3781](https://github.com/fluttercommunity/plus_plugins/issues/3781)). ([93135ff2](https://github.com/fluttercommunity/plus_plugins/commit/93135ff28cd3a8241445d084927b8ca18d73fe58))
 - **FIX**(connectivity_plus): Use serial queue for NWPathMonitor to prevent race condition crash ([#3752](https://github.com/fluttercommunity/plus_plugins/issues/3752)). ([05a50f32](https://github.com/fluttercommunity/plus_plugins/commit/05a50f32ba0685a175c75396a05c9d18fb3ce9b4))
 - **FEAT**(connectivity_plus): add ConnectivityResult.satellite on Android and iOS ([#3771](https://github.com/fluttercommunity/plus_plugins/issues/3771)). ([2b58cffe](https://github.com/fluttercommunity/plus_plugins/commit/2b58cffedd8ebce127deba10d2e389c3c3bfcb4b))

## 7.0.0

> Note: This release has breaking changes.
>
> On Android plugin now requires the following:
> - Android Gradle Plugin >=8.12.1
> - Gradle wrapper >=8.13
> - Kotlin 2.2.0

 - **DOCS**(all): replace MacOS by macOS in package READMEs ([#3658](https://github.com/fluttercommunity/plus_plugins/issues/3658)). ([72b6234c](https://github.com/fluttercommunity/plus_plugins/commit/72b6234c25315c30d8efc9f15a9258b0bb7273a8))
 - **BREAKING** **FEAT**(connectivity_plus): Change Android compile SDK, update Android build config ([#3667](https://github.com/fluttercommunity/plus_plugins/issues/3667)). ([01b596a0](https://github.com/fluttercommunity/plus_plugins/commit/01b596a05204286903451a8d65a9186e4956f065))

## 6.1.5

 - **DOCS**(all): improve documentation across multiple README files ([#3630](https://github.com/fluttercommunity/plus_plugins/issues/3630)). ([643e12df](https://github.com/fluttercommunity/plus_plugins/commit/643e12dfe0389dc21b49bd31ec03e7f38844d339))

## 6.1.4

 - **REFACTOR**(connectivity_plus): removed unused code for web ([#3517](https://github.com/fluttercommunity/plus_plugins/issues/3517)). ([55ac8c5f](https://github.com/fluttercommunity/plus_plugins/commit/55ac8c5fa6f1192cf96e63de1506c82e95b00cda))

## 6.1.3

 - **FIX**(connectivity_plus): Resolve missing privacy manifest issue for iOS and MacOS ([#3458](https://github.com/fluttercommunity/plus_plugins/issues/3458)). ([dab92074](https://github.com/fluttercommunity/plus_plugins/commit/dab92074cbf7dece71a64854b4357eb5b62e2f4f))

## 6.1.2

 - **DOCS**(connectivity_plus): update package requirements ([#3409](https://github.com/fluttercommunity/plus_plugins/issues/3409)). ([cb8c5ead](https://github.com/fluttercommunity/plus_plugins/commit/cb8c5ead41bf8f1d5042a1109eac3e23305d3016))

## 6.1.1

 - **REFACTOR**(all): Use range of flutter_lints for broader compatibility ([#3371](https://github.com/fluttercommunity/plus_plugins/issues/3371)). ([8a303add](https://github.com/fluttercommunity/plus_plugins/commit/8a303add3dee1acb8bac5838246490ed8a0fe408))
 - **FIX**(connectivity_plus): macOS Privacy Manifest ([#3390](https://github.com/fluttercommunity/plus_plugins/issues/3390)). ([170703b5](https://github.com/fluttercommunity/plus_plugins/commit/170703b525c5390682fb558235ce699d29923b29))

## 6.1.0

 - **FEAT**(connectivity_plus): Add Swift Package Manager support ([#3173](https://github.com/fluttercommunity/plus_plugins/issues/3173)). ([036afeeb](https://github.com/fluttercommunity/plus_plugins/commit/036afeeb549f24813256f5049def6a6a3740a4f2))

## 6.0.5

 - **DOCS**(connectivity_plus): Update plugin requirements in README ([#3160](https://github.com/fluttercommunity/plus_plugins/issues/3160)). ([277f8b6b](https://github.com/fluttercommunity/plus_plugins/commit/277f8b6ba9ee6e7e5e3b1cce3e5eb8416830ba6b))

## 6.0.4

 - **CHORE**(connectivity_plus): Use `>=0.5.0 < 2.0.0` version range for package:web.
 - **REFACTOR**(all): Remove website files, configs, mentions ([#3018](https://github.com/fluttercommunity/plus_plugins/issues/3018)). ([ecc57146](https://github.com/fluttercommunity/plus_plugins/commit/ecc57146aa8c6b1c9c332169d3cc2205bc4a700f))
 - **FIX**(all): changed homepage url in pubspec.yaml ([#3099](https://github.com/fluttercommunity/plus_plugins/issues/3099)). ([66613656](https://github.com/fluttercommunity/plus_plugins/commit/66613656a85c176ba2ad337e4d4943d1f4171129))

## 6.0.3

 - **FIX**(connectivity_plus): Ensure Connectivity on Android is correctly reported when lost ([#2836](https://github.com/fluttercommunity/plus_plugins/issues/2836)). ([2aa6ad7a](https://github.com/fluttercommunity/plus_plugins/commit/2aa6ad7a1c05d35b894e6cef515bd9dfa49351dd))

## 6.0.2

 - **REFACTOR**(connectivity_plus): remove ReachabilityConnectivityProvider and ReachabilitySwift dependency ([#2813](https://github.com/fluttercommunity/plus_plugins/issues/2813)). ([f9ad927f](https://github.com/fluttercommunity/plus_plugins/commit/f9ad927f5c18f8ed8d4c22a24476430239c13492))
 - **REFACTOR**(connectivity_plus): Migrate Android example to use the new plugins declaration ([#2771](https://github.com/fluttercommunity/plus_plugins/issues/2771)). ([04200c23](https://github.com/fluttercommunity/plus_plugins/commit/04200c2311e8dd581980ed19f8ebd24d0afd1512))
 - **FIX**(connectivity_plus): WASM-compatible conditional imports ([#2825](https://github.com/fluttercommunity/plus_plugins/issues/2825)). ([6bee4a7e](https://github.com/fluttercommunity/plus_plugins/commit/6bee4a7e02d681ce94d8bd95c4399d844b0ceb27))
 - **FIX**(connectivity_plus): Improve iOS PathMonitorConnectivityProvider implementation and documentation ([#2763](https://github.com/fluttercommunity/plus_plugins/issues/2763)). ([c850d58e](https://github.com/fluttercommunity/plus_plugins/commit/c850d58ed9f422182c8f77583a43bcb13d5d979f))
 - **DOCS**(connectivity_plus): Document supported ConnectivityResult per platform ([#2780](https://github.com/fluttercommunity/plus_plugins/issues/2780)). ([1c4aec01](https://github.com/fluttercommunity/plus_plugins/commit/1c4aec019e74433a2b1174d75522b5abb0c9d9b4))
 - **DOCS**(connectivity_plus): Update README for more clarity ([#2770](https://github.com/fluttercommunity/plus_plugins/issues/2770)). ([8fb738e2](https://github.com/fluttercommunity/plus_plugins/commit/8fb738e2b8f5534db8f1c0fbbeae1a51cf03d099))
 - **DOCS**(connectivity_plus): Specify behavior when there is no connectivity ([#2753](https://github.com/fluttercommunity/plus_plugins/issues/2753)). ([8f132a23](https://github.com/fluttercommunity/plus_plugins/commit/8f132a23a0424299c5e9b946171164bc66710540))
 - **DOCS**(connectivity_plus): Improve documentation onConnectivityChanged method ([#2746](https://github.com/fluttercommunity/plus_plugins/issues/2746)). ([9ea21fbd](https://github.com/fluttercommunity/plus_plugins/commit/9ea21fbdbb9974077375f803f5bb3c57abcb6488))

## 6.0.1

> Note: This release has breaking changes.

> Plugin now requires the following:
> - Flutter >=3.19.0
> - Dart >=3.3.0
> - compileSDK 34 for Android part
> - Java 17 for Android part
> - Gradle 8.4 for Android part

In this release plugin migrated to package:web, meaning that it now supports WASM!

- **BREAKING** **FEAT**(connectivity_plus): support multiple connectivity types at the same time ([#2599](https://github.com/fluttercommunity/plus_plugins/issues/2599)). ([5b477468](https://github.com/fluttercommunity/plus_plugins/commit/5b4774683d6e186fbd69cf4208302221f52aa54d))
- **BREAKING** **FEAT**(connectivity_plus): Migrate to package:web ([#2621](https://github.com/fluttercommunity/plus_plugins/issues/2621)). ([fbc8e61c](https://github.com/fluttercommunity/plus_plugins/commit/fbc8e61c4f8996d6ba47622de191a83dc2fe1882))
- **BREAKING** **BUILD**(connectivity_plus): Target Java 17 on Android ([2413e45e](https://github.com/fluttercommunity/plus_plugins/commit/2413e45e88fa6a431c29f8e6240780e20c405453))
- **BREAKING** **BUILD**(connectivity_plus): Update to target and compile SDK 34 ([#2701](https://github.com/fluttercommunity/plus_plugins/pull/2701)). ([7ddd749](https://github.com/fluttercommunity/plus_plugins/commit/7ddd74989d2921af706f5e7a1aa32e41159ce13f))
- **BREAKING** **REFACTOR**(connectivity_plus): bump MACOSX_DEPLOYMENT_TARGET from 10.11 to 10.14 ([#2588](https://github.com/fluttercommunity/plus_plugins/issues/2588)). ([f6fe62d5](https://github.com/fluttercommunity/plus_plugins/commit/f6fe62d5f4d87c93e0f974e96bbd47ff453937d9))
- **FIX**(connectivity_plus): Emit event with types on Android when subscribing to onConnectivityChanged ([#2721](https://github.com/fluttercommunity/plus_plugins/issues/2721)). ([5a81e7ef](https://github.com/fluttercommunity/plus_plugins/commit/5a81e7ef75d75852935f7a095e5b426d534edff9))
- **FIX**(connectivity_plus): Fix connectivity state update on Android when network is lost ([#2673](https://github.com/fluttercommunity/plus_plugins/issues/2673)). ([21191682](https://github.com/fluttercommunity/plus_plugins/commit/2119168267e436e5900ea09cf68dd110e51b01e0))
- **FIX**(connectivity_plus): Return valid connection type when only one available ([#2668](https://github.com/fluttercommunity/plus_plugins/issues/2668)). ([81026a4c](https://github.com/fluttercommunity/plus_plugins/commit/81026a4c6c07cb610299a8f17db69c518475a675))
- **FIX**(connectivity_plus): Add iOS Privacy Info ([#2581](https://github.com/fluttercommunity/plus_plugins/issues/2581)). ([707fab70](https://github.com/fluttercommunity/plus_plugins/commit/707fab70eb1dd262226158be97586a67eec03dd0))
- **FIX**(connectivity_plus): Fix iOS example app name ([#2722](https://github.com/fluttercommunity/plus_plugins/issues/2722)). ([2441accd](https://github.com/fluttercommunity/plus_plugins/commit/2441accdffc3bc86f5e74db6c682d0dd4fbd6813))
- **DOCS**(connectivity_plus): Update documentation to address API changes ([#2719](https://github.com/fluttercommunity/plus_plugins/issues/2719)). ([59b9b341](https://github.com/fluttercommunity/plus_plugins/commit/59b9b3417cd0387d8a5f9e857eb350b4048dc68c))

## 6.0.0

> Note: DO NOT USE THIS RELEASE. It is invalid due to a publishing issue

## 5.0.2

 - **FIX**(connectivity_plus): Return correct connection state on Linux ([#2371](https://github.com/fluttercommunity/plus_plugins/issues/2371)). ([26576d83](https://github.com/fluttercommunity/plus_plugins/commit/26576d838be3b39121fd77ab33f49fc1fff1a97f))

## 5.0.1

 - **FIX**(connectivity_plus): Fix CHANGELOG to not mention Kotlin requirement ([#2246](https://github.com/fluttercommunity/plus_plugins/issues/2246)). ([e489d4aa](https://github.com/fluttercommunity/plus_plugins/commit/e489d4aa7a223b152b89b6c33ae994e8a73679bd))

## 5.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**(connectivity_plus): Bump min iOS to 12 to not crash after builds with Xcode 15 ([#2169](https://github.com/fluttercommunity/plus_plugins/issues/2169)). ([cf7d93fb](https://github.com/fluttercommunity/plus_plugins/commit/cf7d93fbfc76830acf2db755543cf4235a49df60))
 - **FIX**(connectivity_plus): Revert bump compileSDK to 34 ([#2229](https://github.com/fluttercommunity/plus_plugins/issues/2229)). ([01df65ce](https://github.com/fluttercommunity/plus_plugins/commit/01df65ce0268093de5dd381c84d251668dc95984))
 - **FEAT**(connectivity_plus): Remove deprecated VALID_ARCHS iOS property ([#2021](https://github.com/fluttercommunity/plus_plugins/issues/2021)). ([ee89d583](https://github.com/fluttercommunity/plus_plugins/commit/ee89d5836c7e598fce07d89e82a2d127ddfacbf8))


## 4.0.2

 - **FIX**(connectivity_plus): Downgrade js version to work with Flutter 3.3.10 ([#1989](https://github.com/fluttercommunity/plus_plugins/issues/1989)). ([42938c0c](https://github.com/fluttercommunity/plus_plugins/commit/42938c0c03132f7f50fa047c2970660d2720d320))
 - **FIX**(connectivity_plus): Regenerate iOS and MacOS example apps ([#1874](https://github.com/fluttercommunity/plus_plugins/issues/1874)). ([fc22e54e](https://github.com/fluttercommunity/plus_plugins/commit/fc22e54ec166d37d4326a9271677054fd34ccc3c))
 - **DOCS**(all): Fix example links on pub.dev ([#1863](https://github.com/fluttercommunity/plus_plugins/issues/1863)). ([d726035a](https://github.com/fluttercommunity/plus_plugins/commit/d726035ad7631d5a1397d0a2e5df23dc7e30a4f7))

## 4.0.1

 - **DOCS**(all): Update READMEs ([#1828](https://github.com/fluttercommunity/plus_plugins/issues/1828)). ([57d9c884](https://github.com/fluttercommunity/plus_plugins/commit/57d9c8845edfc81fdbabcef9eb1d1ca450e62e7d))

## 4.0.0

> Note: This release has breaking changes.

 - **CHORE**(connectivity_plus): Update Flutter dependencies, set Flutter >=3.3.0 and Dart to >=2.18.0 <4.0.0
```

## README (ilk 200 satır)
```
# connectivity_plus

[![pub package](https://img.shields.io/pub/v/connectivity_plus.svg)](https://pub.dev/packages/connectivity_plus)
[![pub points](https://img.shields.io/pub/points/connectivity_plus?color=2E8B57&label=pub%20points)](https://pub.dev/packages/connectivity_plus/score)
[![connectivity_plus](https://github.com/fluttercommunity/plus_plugins/actions/workflows/connectivity_plus.yaml/badge.svg)](https://github.com/fluttercommunity/plus_plugins/actions/workflows/connectivity_plus.yaml)

[<img src="../../../assets/flutter-favorite-badge.png" width="100" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

This plugin allows Flutter apps to discover network connectivity types that can be used.

> **Note**
>
> You should not rely on the current connectivity status to decide whether you can reliably make a network request. Always guard your app code against timeouts and errors that might come from the network layer.
> Connection type availability does not guarantee that there is an Internet access. For example, the plugin might return Wi-Fi connection type, but it might be a connection with no Internet access due to network requirements (like on hotel Wi-Fi networks where user often needs to go through a captive portal to authorize first).
>

## Platform Support

| Android | iOS | macOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Requirements

- Flutter >=3.19.0
- Dart >=3.3.0 <4.0.0
- iOS >=13.0
- macOS >=10.15
- Java 17
- Android Gradle Plugin >=8.12.1
- Gradle wrapper >=8.13
- Xcode >= 26.1.1

## Usage

Sample usage to check currently available connection types:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

// Determines whether any active network connection exists.
if (connectivityResult.hasConnectivity) {
  // Connectivity available (regardless of the underlying transport).
}

// This condition is for demo purposes only to explain every connection type.
// Use conditions which work for your requirements.
if (connectivityResult.contains(ConnectivityResult.mobile)) {
  // Mobile network available.
} else if (connectivityResult.contains(ConnectivityResult.wifi)) {
  // Wi-fi is available.
  // Note for Android:
  // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
} else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
  // Ethernet connection available.
} else if (connectivityResult.contains(ConnectivityResult.vpn)) {
  // Vpn connection active.
  // Note for iOS and macOS:
  // There is no separate network interface type for [vpn].
  // It returns [other] on any device (also simulator)
} else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
  // Bluetooth connection available.
} else if (connectivityResult.contains(ConnectivityResult.satellite)) {
  // Carrier-provided satellite network available
} else if (connectivityResult.contains(ConnectivityResult.other)) {
  // Connected to a network which is not in the above mentioned networks.
} else if (connectivityResult.contains(ConnectivityResult.none)) {
  // No available network types
}
```

You can also listen for active connectivity types changes by subscribing to the stream
exposed by the plugin.

This method should ensure emitting only distinct values.

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
    });
  }

  // Be sure to cancel subscription after you are done
  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}
```

## Supported ConnectivityResult values per platform

The following table shows which `ConnectivityResult` values can be returned on every of supported platforms.

|           | Android | iOS | Web | macOS | Windows | Linux |
|-----------|:-------:|:---:|:---:|:-----:|:-------:|:-----:|
| wifi      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| bluetooth | :white_check_mark: |                    |                    |                    |                    | :white_check_mark: |
| ethernet  | :white_check_mark: | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| mobile    | :white_check_mark: | :white_check_mark: |                    | :white_check_mark: |                    |                    |
| vpn       | :white_check_mark: |                    |                    |                    | :white_check_mark: | :white_check_mark: |
| satellite | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |
| other     | :white_check_mark: | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| none      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |

### Android

Connectivity changes are no longer communicated to Android apps in the background starting with Android O (8.0). You should always check for connectivity status when your app is resumed. The broadcast is only useful when your application is in the foreground.

### iOS & macOS

On iOS simulators, the connectivity types stream might not update when Wi-Fi status changes. This is a known issue.

Starting with iOS 12 and macOS 10.14, the implementation uses `NWPathMonitor` to obtain the enabled connectivity types. We noticed that this observer can give multiple or unreliable results. For example, reporting connectivity "none" followed by connectivity "wifi" right after reconnecting.

We recommend to use the `onConnectivityChanged` with this limitation in mind, as the method doesn't filter events, nor it ensures distinct values.

### Web

In order to retrieve information about the quality/speed of a browser's connection, the web implementation of the `connectivity` plugin uses the browser's [**NetworkInformation** Web API](https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation), which as of this writing (June 2020) is still "experimental", and not available in all browsers:

![Data on support for the netinfo feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/netinfo.png)

On desktop browsers, this API only returns a very broad set of connectivity statuses (One of `'slow-2g', '2g', '3g', or '4g'`), and may _not_ provide a Stream of changes. Firefox still hasn't enabled this feature by default.

**Fallback to `navigator.onLine`**

For those browsers where the NetworkInformation Web API is not available, the plugin falls back to the [**NavigatorOnLine** Web API](https://developer.mozilla.org/en-US/docs/Web/API/NavigatorOnLine), which is more broadly supported:

![Data on support for the online-status feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/online-status.png)

The NavigatorOnLine API is [provided by `dart:html`](https://api.dart.dev/stable/2.7.2/dart-html/Navigator/onLine.html), and only supports a boolean connectivity status (either online or offline), with no network speed information. In those cases the plugin will return either `wifi` (when the browser is online) or `none` (when it's not).

Other than the approximate "downlink" speed, where available, and due to security and privacy concerns, **no Web browser will provide** any specific information about the actual network your users' device is connected to, like **the SSID on a Wi-Fi, or the MAC address of their device.**

## Learn more

- [API Documentation](https://pub.dev/documentation/connectivity_plus/latest/connectivity_plus/connectivity_plus-library.html)
```
