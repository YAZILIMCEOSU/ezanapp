# firebase_messaging (firebase_messaging-16.7.0)

## CHANGELOG (ilk 150 satır)
```
## 16.7.0

 - **FIX**(messaging,ios): register for APNs after Dart Firebase.initializeApp() ([#18650](https://github.com/firebase/flutterfire/issues/18650)). ([2ea8381a](https://github.com/firebase/flutterfire/commit/2ea8381a1ada9fa6946c87fc0d203f94f04c6212))
 - **FIX**(messaging,android): skip onMessageOpenedApp for terminated notification taps ([#18663](https://github.com/firebase/flutterfire/issues/18663)). ([a57837ef](https://github.com/firebase/flutterfire/commit/a57837ef40f73f0187b45125ecc0d81811b71bd9))
 - **FIX**(messaging,ios): register for APNs when UIScene plugins miss launch callbacks ([#18620](https://github.com/firebase/flutterfire/issues/18620)). ([2fd8aa88](https://github.com/firebase/flutterfire/commit/2fd8aa886fcd7faf281ca5a7645ddaebabc3cb7a))
 - **FEAT**(core): bump Firebase iOS SDK to 12.19.0 ([#18683](https://github.com/firebase/flutterfire/issues/18683)). ([35e39637](https://github.com/firebase/flutterfire/commit/35e39637f4cbef0d70043047f80d6f6e80daf8fe))

## 16.6.0

 - **FIX**(ci): bump Kotlin Gradle plugin to 2.3.0 ([#18600](https://github.com/firebase/flutterfire/issues/18600)). ([4c3865e2](https://github.com/firebase/flutterfire/commit/4c3865e2e56bf59904a9f48a6e70f0f963df2cda))
 - **FIX**(ci): align Android toolchain and analyzer with Flutter 3.47 ([#18566](https://github.com/firebase/flutterfire/issues/18566)). ([87ace849](https://github.com/firebase/flutterfire/commit/87ace8496fec75c461f3b29a9b8a85d46e286957))
 - **FIX**(messaging,android): fixing an issue with analytics being triggered twice ([#18544](https://github.com/firebase/flutterfire/issues/18544)). ([ef1cac4c](https://github.com/firebase/flutterfire/commit/ef1cac4c0c5154921f70400d46a5d0eeade2dab0))
 - **FIX**(messaging,macos): unwrap UNNotificationResponse launch payload ([#18527](https://github.com/firebase/flutterfire/issues/18527)). ([584acc9f](https://github.com/firebase/flutterfire/commit/584acc9fb2d805733c33060b875b674b9d434a7e))
 - **FIX**(messaging,android): fix an issue that could cause duplicate call stack ([#18122](https://github.com/firebase/flutterfire/issues/18122)). ([1522bd8f](https://github.com/firebase/flutterfire/commit/1522bd8f7771da70508fa26422fc9447e3ffa8ad))
 - **FEAT**: bump Firebase iOS SDK to 12.18.0 ([#18596](https://github.com/firebase/flutterfire/issues/18596)). ([07febc37](https://github.com/firebase/flutterfire/commit/07febc37617ab8b4f6f06e7208baa6a15ce2ef70))
 - **FEAT**(messaging,ios): migrate example iOS runner from ObjC to Swift ([#18578](https://github.com/firebase/flutterfire/issues/18578)). ([69d16e44](https://github.com/firebase/flutterfire/commit/69d16e44cb7f70d8eaaed3e4fe9d2a186194e3d4))
 - **FEAT**(messaging,android): improve how messaging is determining permission on Android ([#18101](https://github.com/firebase/flutterfire/issues/18101)). ([1c89b686](https://github.com/firebase/flutterfire/commit/1c89b686209c79ef800e61885bcbfbd555b589ee))

## 16.5.0

 - **FIX**(app_check): sync SPM pins to 12.17.0 and fix Windows Activate override after [#18505](https://github.com/firebase/flutterfire/issues/18505) ([#18515](https://github.com/firebase/flutterfire/issues/18515)). ([ce1f6e05](https://github.com/firebase/flutterfire/commit/ce1f6e05e2d2645c414f8e731d3d082436caa012))
 - **FIX**(messaging,android): fix an issue that could cause ANRs when receiving multiple notifications at the same time ([#18359](https://github.com/firebase/flutterfire/issues/18359)). ([a45f8d92](https://github.com/firebase/flutterfire/commit/a45f8d925c7404f81aae8a08dc2088149f3f2e7a))
 - **FIX**(messaging,ios): fix an issue where FirebaseMessaging could init even if FirebaseMessagingAutoInitEnabled was disabled ([#18452](https://github.com/firebase/flutterfire/issues/18452)). ([6f22596b](https://github.com/firebase/flutterfire/commit/6f22596baced28bf135f7cd40fdb5c008df2f328))
 - **FIX**(messaging,macos): fix an issue where getInitialMessage could hang forever in macOS ([#18457](https://github.com/firebase/flutterfire/issues/18457)). ([87d88d20](https://github.com/firebase/flutterfire/commit/87d88d200df9a5e0536d458a1bb02ace8933e682))
 - **FEAT**(messaging,ios): support early notification delegate setup for UIScene apps ([#18501](https://github.com/firebase/flutterfire/issues/18501)). ([b69bbc0d](https://github.com/firebase/flutterfire/commit/b69bbc0d950aef8edaf843edb8cda12613103440))

## 16.4.3

 - Update a dependency to the latest release.

## 16.4.2

 - Update a dependency to the latest release.

## 16.4.1

 - **FIX**: resolve FlutterSceneLifeCycleDelegate conformance guard ([#18385](https://github.com/firebase/flutterfire/issues/18385)). ([48d67196](https://github.com/firebase/flutterfire/commit/48d67196a10affe09724529df5f67cf40b62bccf))

## 16.4.0

 - **FIX**(messaging,ios): fix a race condition that could happen when getting initial message ([#18352](https://github.com/firebase/flutterfire/issues/18352)). ([77396b81](https://github.com/firebase/flutterfire/commit/77396b81ae56943a38c23b429249b0b9cbd4bc21))
 - **FEAT**(messaging,ios): add support for actionIdentifier on iOS devices ([#18357](https://github.com/firebase/flutterfire/issues/18357)). ([d60af4d9](https://github.com/firebase/flutterfire/commit/d60af4d9e1345c113490e875c85bd9ac62dad935))

## 16.3.0

 - **FEAT**(messaging,web): add support for custom service worker script path in `getToken` method ([#18290](https://github.com/firebase/flutterfire/issues/18290)). ([b37722db](https://github.com/firebase/flutterfire/commit/b37722db13548aca57b3a24ba0f27b5de021be02))

## 16.2.2

 - Update a dependency to the latest release.

## 16.2.1

 - **REFACTOR**: move all packages to workspace ([#18182](https://github.com/firebase/flutterfire/issues/18182)). ([6cdfcb10](https://github.com/firebase/flutterfire/commit/6cdfcb103da7be46ccb190d7e107d8c537aa1ff8))
 - **FIX**(messaging,android): fix call race that could happen when using requestPermission ([#18256](https://github.com/firebase/flutterfire/issues/18256)). ([57d4c3d0](https://github.com/firebase/flutterfire/commit/57d4c3d050c6a9252390de6cac91a0ca1d5461e3))

## 16.2.0

 - **FEAT**: use local firebase_core instead of remote SPM dependency ([#18141](https://github.com/firebase/flutterfire/issues/18141)). ([995caf40](https://github.com/firebase/flutterfire/commit/995caf400df80c0fde7151c651ccc6c0f756e381))

## 16.1.3

 - **FIX**(messaging,ios): fix an issue where the scene initializer could be called twice in latest Flutter versions ([#18051](https://github.com/firebase/flutterfire/issues/18051)). ([5b602105](https://github.com/firebase/flutterfire/commit/5b602105faf9f64ac977a4266de5ee10785330bd))
 - **DOCS**(messaging): update documentation for setForegroundNotificationPresentationOptions to clarify persistence of options ([#18107](https://github.com/firebase/flutterfire/issues/18107)). ([02777d70](https://github.com/firebase/flutterfire/commit/02777d70bb587895cb789dd1b520a2feaaaf32b1))

## 16.1.2

 - Update a dependency to the latest release.

## 16.1.1

 - **FIX**(messaging,iOS): scope iOS 18 duplicate notification workaround to iOS 18.0 only ([#17932](https://github.com/firebase/flutterfire/issues/17932)). ([c78f56ea](https://github.com/firebase/flutterfire/commit/c78f56ea0fd0d5ba0b565a11cbf9acce73f93401))

## 16.1.0

 - **FIX**(messaging,iOS): refactor notification handling in scene delegate methods ([#17905](https://github.com/firebase/flutterfire/issues/17905)). ([6fd8929b](https://github.com/firebase/flutterfire/commit/6fd8929b667df23eed21df288c9f8d8f213ea8ad))
 - **FEAT**(firebase_messaging,iOS): add scene delegate support for `firebase_messaging` ([#17888](https://github.com/firebase/flutterfire/issues/17888)). ([a8633970](https://github.com/firebase/flutterfire/commit/a8633970c841a43699c54a9c6ce4e9669b74e268))

## 16.0.4

 - Update a dependency to the latest release.

## 16.0.3

 - **FIX**(firebase_messaging): fix null apple notification when sound is of type String ([#17770](https://github.com/firebase/flutterfire/issues/17770)). ([7fe893c0](https://github.com/firebase/flutterfire/commit/7fe893c0075f0abb019c0890bebd1fd3ba37a5d3))

## 16.0.2

 - Update a dependency to the latest release.

## 16.0.1

 - Update a dependency to the latest release.

## 16.0.0

> Note: This release has breaking changes.

 - **FEAT**(messaging): remove deprecated functions ([#17563](https://github.com/firebase/flutterfire/issues/17563)). ([1b716261](https://github.com/firebase/flutterfire/commit/1b7162619311e24b7f13a3e3b8c603fb1e05477b))
 - **BREAKING** **FEAT**: bump iOS SDK to version 12.0.0 ([#17549](https://github.com/firebase/flutterfire/issues/17549)). ([b2619e68](https://github.com/firebase/flutterfire/commit/b2619e685fec897513483df1d7be347b64f95606))
 - **BREAKING** **FEAT**: bump Android SDK to version 34.0.0 ([#17554](https://github.com/firebase/flutterfire/issues/17554)). ([a5bdc051](https://github.com/firebase/flutterfire/commit/a5bdc051d40ee44e39cf0b8d2a7801bc6f618b67))

## 15.2.10

 - Update a dependency to the latest release.

## 15.2.9

 - Update a dependency to the latest release.

## 15.2.8

 - Update a dependency to the latest release.

## 15.2.7

 - Update a dependency to the latest release.

## 15.2.6

 - Update a dependency to the latest release.

## 15.2.5

 - Update a dependency to the latest release.

## 15.2.4

 - Update a dependency to the latest release.

## 15.2.3

 - Update a dependency to the latest release.

## 15.2.2

 - Update a dependency to the latest release.

## 15.2.1

 - **FIX**(messaging,android): remove a deprecation message ([#16995](https://github.com/firebase/flutterfire/issues/16995)). ([b4e46db6](https://github.com/firebase/flutterfire/commit/b4e46db6fcc9080673108599a24bb4c1fe79f0f3))

## 15.2.0

 - **FEAT**(messaging,apple): allow system to display button for in-app notification settings ([#13484](https://github.com/firebase/flutterfire/issues/13484)). ([b36f924e](https://github.com/firebase/flutterfire/commit/b36f924e018f4d88ea5eaf17a779b2c3cf03583d))
 - **FEAT**(messaging): Swift Package Manager support ([#13205](https://github.com/firebase/flutterfire/issues/13205)) ([#16786](https://github.com/firebase/flutterfire/issues/16786)). ([165d2ab6](https://github.com/firebase/flutterfire/commit/165d2ab6f9a25d4209ada837b13add584fdd225d))

## 15.1.6

 - Update a dependency to the latest release.
```

## README (ilk 200 satır)
```
[<img src="https://raw.githubusercontent.com/firebase/flutterfire/main/.github/images/flutter_favorite.png" width="200" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

# Firebase Messaging Plugin for Flutter

A Flutter plugin to use the [Firebase Cloud Messaging API](https://firebase.google.com/docs/cloud-messaging).

To learn more about Firebase Cloud Messaging, please visit the [Firebase website](https://firebase.google.com/products/cloud-messaging)

[![pub package](https://img.shields.io/pub/v/firebase_messaging.svg)](https://pub.dev/packages/firebase_messaging)

## Getting Started

To get started with Firebase Cloud Messaging for Flutter, please [see the documentation](https://firebase.google.com/docs/cloud-messaging).

## Usage

To use this plugin, please visit the [Cloud Messaging Usage documentation](https://firebase.google.com/docs/cloud-messaging)

### iOS apps using UIScene

Apps that adopt the UIScene lifecycle register Flutter plugins after
`application:didFinishLaunchingWithOptions:`. Apple requires
`UNUserNotificationCenter.delegate` to be configured before that method returns, so configure
Firebase Messaging explicitly from your app delegate:

```swift
override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
  FLTFirebaseMessagingPlugin.configureNotificationCenterDelegate()
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

```objectivec
#import <firebase_messaging/FLTFirebaseMessagingPlugin.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FLTFirebaseMessagingPlugin configureNotificationCenterDelegate];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
```
