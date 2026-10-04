# firebase_remote_config (firebase_remote_config-6.7.0)

## CHANGELOG (ilk 150 satır)
```
## 6.7.0

 - **FIX**(remote_config,ios): emit onConfigUpdated events on the platform thread ([#18673](https://github.com/firebase/flutterfire/issues/18673)). ([17c70494](https://github.com/firebase/flutterfire/commit/17c70494c73c6c8cddb758fbfffc8468ad8fdbc6))
 - **FEAT**(core): bump Firebase iOS SDK to 12.19.0 ([#18683](https://github.com/firebase/flutterfire/issues/18683)). ([35e39637](https://github.com/firebase/flutterfire/commit/35e39637f4cbef0d70043047f80d6f6e80daf8fe))

## 6.6.0

 - **REFACTOR**(core,apple): migrate iOS/macOS plugin implementation to Swift ([#18569](https://github.com/firebase/flutterfire/issues/18569)). ([3b9a655b](https://github.com/firebase/flutterfire/commit/3b9a655b8ac8ac5f6efa23ea63e210b597f2ec02))
 - **FIX**(ci): bump Kotlin Gradle plugin to 2.3.0 ([#18600](https://github.com/firebase/flutterfire/issues/18600)). ([4c3865e2](https://github.com/firebase/flutterfire/commit/4c3865e2e56bf59904a9f48a6e70f0f963df2cda))
 - **FIX**(remote_config): classify fetch failures instead of reporting them all as `internal` ([#18585](https://github.com/firebase/flutterfire/issues/18585)). ([128912e8](https://github.com/firebase/flutterfire/commit/128912e884c815b498ff943cd7b38838104d89f0))
 - **FIX**(ci): align Android toolchain and analyzer with Flutter 3.47 ([#18566](https://github.com/firebase/flutterfire/issues/18566)). ([87ace849](https://github.com/firebase/flutterfire/commit/87ace8496fec75c461f3b29a9b8a85d46e286957))
 - **FIX**(android): remove plugin-local AGP and Kotlin Gradle Plugin pins from buildscript blocks ([#18139](https://github.com/firebase/flutterfire/issues/18139)). ([4f6960c4](https://github.com/firebase/flutterfire/commit/4f6960c437da6945e2db2505f4e0a92fef5b76da))
 - **FEAT**: bump Firebase iOS SDK to 12.18.0 ([#18596](https://github.com/firebase/flutterfire/issues/18596)). ([07febc37](https://github.com/firebase/flutterfire/commit/07febc37617ab8b4f6f06e7208baa6a15ce2ef70))

## 6.5.6

 - **FIX**(app_check): sync SPM pins to 12.17.0 and fix Windows Activate override after [#18505](https://github.com/firebase/flutterfire/issues/18505) ([#18515](https://github.com/firebase/flutterfire/issues/18515)). ([ce1f6e05](https://github.com/firebase/flutterfire/commit/ce1f6e05e2d2645c414f8e731d3d082436caa012))
 - **FIX**(remote_config,windows): move CMake dependency from Core to Remote Config ([#18498](https://github.com/firebase/flutterfire/issues/18498)). ([d6ef43f6](https://github.com/firebase/flutterfire/commit/d6ef43f616d03a57b76469b77f4cfd3d8325075a))
 - **FIX**(remote_config): restores the Apple error mapping and accepts both throttling status spellings ([#18458](https://github.com/firebase/flutterfire/issues/18458)). ([523d985a](https://github.com/firebase/flutterfire/commit/523d985a8219fd20a7071915ee539c19692975fa))

## 6.5.5

 - Update a dependency to the latest release.

## 6.5.4

 - Update a dependency to the latest release.

## 6.5.3

 - Update a dependency to the latest release.

## 6.5.2

 - Update a dependency to the latest release.

## 6.5.1

 - Update a dependency to the latest release.

## 6.5.0

 - **REFACTOR**: move all packages to workspace ([#18182](https://github.com/firebase/flutterfire/issues/18182)). ([6cdfcb10](https://github.com/firebase/flutterfire/commit/6cdfcb103da7be46ccb190d7e107d8c537aa1ff8))
 - **FEAT**: upgrade pigeon to version 26.3.4 ([#18205](https://github.com/firebase/flutterfire/issues/18205)). ([cb6b4aef](https://github.com/firebase/flutterfire/commit/cb6b4aeffc568755ea3eebe32b998f00237bf5ad))

## 6.4.0

 - **FEAT**: use local firebase_core instead of remote SPM dependency ([#18141](https://github.com/firebase/flutterfire/issues/18141)). ([995caf40](https://github.com/firebase/flutterfire/commit/995caf400df80c0fde7151c651ccc6c0f756e381))

## 6.3.0

 - **FIX**(remote-config,ios): fix hot reload issue ([#18062](https://github.com/firebase/flutterfire/issues/18062)). ([5db57711](https://github.com/firebase/flutterfire/commit/5db577116139d469bcdf38dd58f69c1e5f61c87e))
 - **FIX**(android): remove kotlin-android since AGP 9 supports it ([#18059](https://github.com/firebase/flutterfire/issues/18059)). ([1e39ad1f](https://github.com/firebase/flutterfire/commit/1e39ad1f146ce23742731ceeb30ff36c440b816f))
 - **FEAT**(ios): migrate iOS to UIScene lifecycle ([#18054](https://github.com/firebase/flutterfire/issues/18054)). ([3ffa4110](https://github.com/firebase/flutterfire/commit/3ffa411098132fd5182a84be4e7a226106bc7451))

## 6.2.0

 - **FIX**(remote_config): correct `lastFetchTime` calculation ([#18004](https://github.com/firebase/flutterfire/issues/18004)). ([92f03e08](https://github.com/firebase/flutterfire/commit/92f03e08e9b5362c180da16d60d869568daf2c55))
 - **FEAT**(remote-config,windows): add support for windows ([#18006](https://github.com/firebase/flutterfire/issues/18006)). ([a6ec167f](https://github.com/firebase/flutterfire/commit/a6ec167f4ece9c9b455a916366781f482cc380b3))

## 6.1.4

 - Update a dependency to the latest release.

## 6.1.3

 - Update a dependency to the latest release.

## 6.1.2

 - Update a dependency to the latest release.

## 6.1.1

 - Update a dependency to the latest release.

## 6.1.0

 - **FEAT**(remote_config,web): add web support for `onConfigUpdated` ([#17750](https://github.com/firebase/flutterfire/issues/17750)). ([799b12e4](https://github.com/firebase/flutterfire/commit/799b12e4b31a2c7c8f251dd4adbbf65227bfc1b6))

## 6.0.2

 - Update a dependency to the latest release.

## 6.0.1

 - Update a dependency to the latest release.

## 6.0.0

> Note: This release has breaking changes.

 - **FIX**(remote_config,android): make `onCancel` accept nullable arguments to avoid crash on hot restart ([#17569](https://github.com/firebase/flutterfire/issues/17569)). ([2b782558](https://github.com/firebase/flutterfire/commit/2b782558666337fd65780231fe07a277986cedce))
 - **BREAKING** **FEAT**: bump iOS SDK to version 12.0.0 ([#17549](https://github.com/firebase/flutterfire/issues/17549)). ([b2619e68](https://github.com/firebase/flutterfire/commit/b2619e685fec897513483df1d7be347b64f95606))
 - **BREAKING** **FEAT**: bump Android SDK to version 34.0.0 ([#17554](https://github.com/firebase/flutterfire/issues/17554)). ([a5bdc051](https://github.com/firebase/flutterfire/commit/a5bdc051d40ee44e39cf0b8d2a7801bc6f618b67))

## 5.5.0

 - **FEAT**(remote_config): add support for Pigeon. Update iOS to Swift and Android to Swift ([#17489](https://github.com/firebase/flutterfire/issues/17489)). ([08ecc502](https://github.com/firebase/flutterfire/commit/08ecc5029616058c86d0093b9aae3ee8cea811a4))

## 5.4.7

 - Update a dependency to the latest release.

## 5.4.6

 - Update a dependency to the latest release.

## 5.4.5

 - Update a dependency to the latest release.

## 5.4.4

 - Update a dependency to the latest release.

## 5.4.3

 - Update a dependency to the latest release.

## 5.4.2

 - Update a dependency to the latest release.

## 5.4.1

 - Update a dependency to the latest release.

## 5.4.0

 - **FEAT**(remote-config): custom signals support ([#17053](https://github.com/firebase/flutterfire/issues/17053)). ([7cf248a8](https://github.com/firebase/flutterfire/commit/7cf248a8808e3d8f7fed29f18ddaf1fadf329ca3))

## 5.3.1

 - Update a dependency to the latest release.

## 5.3.0

 - Update a dependency to the latest release.

## 5.2.0

 - **FEAT**(remote_config): Swift Package Manager support ([#16772](https://github.com/firebase/flutterfire/issues/16772)). ([164421ec](https://github.com/firebase/flutterfire/commit/164421ec8d3d67ca0349bce60d2b7731ad704639))

## 5.1.5

 - Update a dependency to the latest release.

## 5.1.4

```

## README (ilk 200 satır)
```
# Firebase Remote Config Plugin for Flutter

A Flutter plugin to use the [Firebase Remote Config API](https://firebase.google.com/docs/remote-config).

To learn more about Firebase Remote Config, please visit the [Firebase website](https://firebase.google.com/products/remote-config)

[![pub package](https://img.shields.io/pub/v/firebase_remote_config.svg)](https://pub.dev/packages/firebase_remote_config)

## Getting Started

To get started with Firebase Remote Config for Flutter, please
see the [Flutter specific documentation](https://firebase.google.com/docs/remote-config/get-started?platform=flutter) available at
[https://firebase.google.com/](https://firebase.google.com/).

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
```
