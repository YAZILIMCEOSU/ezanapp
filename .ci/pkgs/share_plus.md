# share_plus (share_plus-13.3.1)

## CHANGELOG (ilk 150 satır)
```
## 13.3.1

 - **FIX**(share_plus): Only configure popover presentation on iPad ([#3965](https://github.com/fluttercommunity/plus_plugins/issues/3965)). ([86ba69a5](https://github.com/fluttercommunity/plus_plugins/commit/86ba69a526a0d26173cb5df43ed446177cb08bd5))
 - **FIX**(share_plus): Remove deprecated UIApplication.keyWindow fallback on iOS ([#3970](https://github.com/fluttercommunity/plus_plugins/issues/3970)). ([26f4d487](https://github.com/fluttercommunity/plus_plugins/commit/26f4d487e5db45b9461f36ff9fc46662a8284654))
 - **FIX**(share_plus): Apply KGP unless built-in Kotlin is enabled ([#3951](https://github.com/fluttercommunity/plus_plugins/issues/3951)). ([cb9ccd5f](https://github.com/fluttercommunity/plus_plugins/commit/cb9ccd5f3c368f86311f126227ec985b3e86792c))

## 13.3.0

 - **FIX**(share_plus): Do not do I/O operations on the main thread on Android ([#3931](https://github.com/fluttercommunity/plus_plugins/issues/3931)). ([2c5b4935](https://github.com/fluttercommunity/plus_plugins/commit/2c5b4935c85fdbfeffea2bd68c9286c064ed8b7c))
 - **FEAT**(share_plus): Avoid exceptions on iPads with no sharePositionOrigin ([#3769](https://github.com/fluttercommunity/plus_plugins/issues/3769)). ([d3ba3f36](https://github.com/fluttercommunity/plus_plugins/commit/d3ba3f36a865d3ba7c8e5d1e48396ca3a13541b0))

## 13.2.1

 - **FIX**(share_plus): raise Apple platform minimums in SPM manifests to match FlutterFramework ([#3923](https://github.com/fluttercommunity/plus_plugins/issues/3923)). ([949e7717](https://github.com/fluttercommunity/plus_plugins/commit/949e7717ca32fc57dffc4638aeaf154d0fcea0cb))

## 13.2.0

 - **REFACTOR**(share_plus): Change Android Gradle from Groovy to Kotlin ([#3860](https://github.com/fluttercommunity/plus_plugins/issues/3860)). ([d9b6f299](https://github.com/fluttercommunity/plus_plugins/commit/d9b6f299dec2c61673a9e4650e9fd554d44422a5))
 - **FIX**(share_plus): resolve js interop lint and maintain minimum sdk ([#3846](https://github.com/fluttercommunity/plus_plugins/issues/3846)). ([09d75d8f](https://github.com/fluttercommunity/plus_plugins/commit/09d75d8f822831ffb07f81234365accc7e8593de))
 - **FEAT**(share_plus): Updated Swift Package Manager setup for Flutter 3.44 ([#3911](https://github.com/fluttercommunity/plus_plugins/issues/3911)). ([cf006091](https://github.com/fluttercommunity/plus_plugins/commit/cf00609169e791d41e21a59826dcfa574ce12fe6))
 - **FEAT**(share_plus): Add support of built-in Kotlin ([#3896](https://github.com/fluttercommunity/plus_plugins/issues/3896)). ([0c9b0ad0](https://github.com/fluttercommunity/plus_plugins/commit/0c9b0ad0e596adff407d61cefbbf1088b56783da))

## 13.1.0

 - **FEAT**(share_plus): Lower requirements to Dart 3.10 and Flutter 3.38.1 ([#3801](https://github.com/fluttercommunity/plus_plugins/issues/3801)). ([d965e00e](https://github.com/fluttercommunity/plus_plugins/commit/d965e00e5082d4e32e25cacad0b193a735d51c5f))

## 13.0.0

> Note: This release has breaking changes.
>
> Due to an update of win32 to 6.0.0, package requirements were also changed to match this update:
> - Minimum Flutter version is 3.41.6
> - Minimum Dart version is 3.11.0
> - Min iOS is 13.0
> - Min macOS is 10.15
>
> Since this release was already breaking, the rest of the dependencies were also updated to the latest possible versions.

 - **BREAKING** **FEAT**(share_plus): Bump win32 from 5.15.0 to 6.0.0 ([#3762](https://github.com/fluttercommunity/plus_plugins/issues/3762)). ([0e3eb918](https://github.com/fluttercommunity/plus_plugins/commit/0e3eb918e77fcc500b6124167a905f026ffc374a))

## 12.0.2

 - **FIX**(share_plus): Avoid crash on iOS during file and text sharing in add-to-app scenario ([#3738](https://github.com/fluttercommunity/plus_plugins/issues/3738)). ([ae6330bb](https://github.com/fluttercommunity/plus_plugins/commit/ae6330bbf579fe411b503be84fcfc202d2496625))

## 12.0.1

 - **FIX**(share_plus): Avoid crash on iOS 26 on iPhones with no sharePositionOrigin param([#3699](https://github.com/fluttercommunity/plus_plugins/issues/3699)). ([42b079bd](https://github.com/fluttercommunity/plus_plugins/commit/42b079bd5fa56c9983a5a4fcf351190884f5c540))

## 12.0.0

> Note: This release has breaking changes.
>
> On Android plugin now requires the following:
> - Android Gradle Plugin >=8.12.1
> - Gradle wrapper >=8.13
> - Kotlin 2.2.0

 - **FIX**(share_plus): unable to get the correct result on iOS ([#3660](https://github.com/fluttercommunity/plus_plugins/issues/3660)). ([3bd253b0](https://github.com/fluttercommunity/plus_plugins/commit/3bd253b04021a932fa79412a5da2318c22cfdbe2))
 - **DOCS**(all): replace MacOS by macOS in package READMEs ([#3658](https://github.com/fluttercommunity/plus_plugins/issues/3658)). ([72b6234c](https://github.com/fluttercommunity/plus_plugins/commit/72b6234c25315c30d8efc9f15a9258b0bb7273a8))
 - **BREAKING** **FEAT**(share_plus): Change Android compile SDK, update Android build config ([#3671](https://github.com/fluttercommunity/plus_plugins/issues/3671)). ([24363e27](https://github.com/fluttercommunity/plus_plugins/commit/24363e270d3c8219b9516fe57474a448f6c5fd48))

## 11.1.0

 - **FEAT**(share_plus): Added `excludedCupertinoActivities` share parameter ([#3376](https://github.com/fluttercommunity/plus_plugins/issues/3376)). ([f9fdadb4](https://github.com/fluttercommunity/plus_plugins/commit/f9fdadb41242ad2e36ddbf1ade82be6c5bb78ec4))
 - **DOCS**(all): improve documentation across multiple README files ([#3630](https://github.com/fluttercommunity/plus_plugins/issues/3630)). ([643e12df](https://github.com/fluttercommunity/plus_plugins/commit/643e12dfe0389dc21b49bd31ec03e7f38844d339))
 - **DOCS**(share-plus): Update README.md. ([2aa9f7e0](https://github.com/fluttercommunity/plus_plugins/commit/2aa9f7e0c7b471dc581d6fbd334633d16eb2da03))

## 11.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**(share_plus): SharePlus refactor ([#3404](https://github.com/fluttercommunity/plus_plugins/issues/3404)). ([0a19d460](https://github.com/fluttercommunity/plus_plugins/commit/0a19d46010b6ecf5c2f10771e33a39823f7c30b7))

This version introduces the new `SharePlus` class with the `share(params)` method.
It replaces the old `Share` class, which has been deprecated but can still be used.
Check the section "Migrating from `Share` to `SharePlus`" in the `README.md`.

## 10.1.4

 - **FIX**(share_plus): fallback for shareXFiles() to use download on web ([#3388](https://github.com/fluttercommunity/plus_plugins/issues/3388)). ([95a12ee3](https://github.com/fluttercommunity/plus_plugins/commit/95a12ee3982dd61de5d07005de62f81c2e99eb08))

## 10.1.3

 - **REFACTOR**(all): Use range of flutter_lints for broader compatibility ([#3371](https://github.com/fluttercommunity/plus_plugins/issues/3371)). ([8a303add](https://github.com/fluttercommunity/plus_plugins/commit/8a303add3dee1acb8bac5838246490ed8a0fe408))
 - **FIX**(share_plus): A function declaration without a prototype is deprecated in all versions of C ([#3375](https://github.com/fluttercommunity/plus_plugins/issues/3375)). ([40f9c421](https://github.com/fluttercommunity/plus_plugins/commit/40f9c42138bf1c80e6283f46e12109a0e66c0816))
 - **FIX**(share_plus): Set correct Flutter and Dart versions requirements ([#3363](https://github.com/fluttercommunity/plus_plugins/issues/3363)). ([65616668](https://github.com/fluttercommunity/plus_plugins/commit/6561666885f547725f6e88ebaae498832b53efed))

## 10.1.2

 - **FIX**(share_plus): Update privacy manifest path ([#3349](https://github.com/fluttercommunity/plus_plugins/issues/3349)). ([d884a991](https://github.com/fluttercommunity/plus_plugins/commit/d884a9917769e11daa66c1aaa3ebd0d015506e77))

## 10.1.1

 - **FIX**(share_plus): [#3322](https://github.com/fluttercommunity/plus_plugins/issues/3322) Downscale previews on iOS to avoid issues with huge images ([#3320](https://github.com/fluttercommunity/plus_plugins/issues/3320)). ([d8c95c2c](https://github.com/fluttercommunity/plus_plugins/commit/d8c95c2cffaf882cf0670cc5daf889eebd249a77))

## 10.1.0

 - **FEAT**(share_plus): Add Swift Package Manager support ([#3169](https://github.com/fluttercommunity/plus_plugins/issues/3169)). ([b3970225](https://github.com/fluttercommunity/plus_plugins/commit/b3970225b80183548ecc5516a5c1a1ad61016860))

## 10.0.3

 - **FIX**(share_plus): `mime` compatible with v2 (v1 still supported) ([#3309](https://github.com/fluttercommunity/plus_plugins/issues/3309)). ([401db75e](https://github.com/fluttercommunity/plus_plugins/commit/401db75efa24c40fd96a05e79d12801f92666efd))
 - **FIX**(all): Clean up macOS Privacy Manifests ([#3268](https://github.com/fluttercommunity/plus_plugins/issues/3268)). ([d7b98ebd](https://github.com/fluttercommunity/plus_plugins/commit/d7b98ebd7d39b0143931f5cc6e627187576223dc))
 - **FIX**(all): Add macOS Privacy Manifests ([#3251](https://github.com/fluttercommunity/plus_plugins/issues/3251)). ([bf5dad2a](https://github.com/fluttercommunity/plus_plugins/commit/bf5dad2ad249605055bcbd5f663e42569df12d64))

## 10.0.2

 - **FIX**(share_plus): [#2910](https://github.com/fluttercommunity/plus_plugins/issues/2910) Handle user dismissing dialog on shareUri() in web ([#3175](https://github.com/fluttercommunity/plus_plugins/issues/3175)). ([bba78118](https://github.com/fluttercommunity/plus_plugins/commit/bba781187b4af5682331ed90929c61c13137809a))

## 10.0.1

- **CHORE**(share_plus): Update to package:web to ^1.0.0 ([#3105](https://github.com/fluttercommunity/plus_plugins/pull/3105)). ([1f23910a](https://github.com/fluttercommunity/plus_plugins/commit/1f23910ab50fef2e499054f35cedfd14c578976a))

## 10.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**(share_plus): Introduce optional parameter `nameOverride` to `shareXFiles`. ([#3077](https://github.com/fluttercommunity/plus_plugins/issues/3077)). ([f483bce7](https://github.com/fluttercommunity/plus_plugins/commit/f483bce77f50fc03e8c6c969864dd978e46f32da))
 - **REFACTOR**(all): Remove website files, configs, mentions ([#3018](https://github.com/fluttercommunity/plus_plugins/issues/3018)). ([ecc57146](https://github.com/fluttercommunity/plus_plugins/commit/ecc57146aa8c6b1c9c332169d3cc2205bc4a700f))
 - **FIX**(all): changed homepage url in pubspec.yaml ([#3099](https://github.com/fluttercommunity/plus_plugins/issues/3099)). ([66613656](https://github.com/fluttercommunity/plus_plugins/commit/66613656a85c176ba2ad337e4d4943d1f4171129))
 - **DOCS**(share_plus): Update README.md ([#2903](https://github.com/fluttercommunity/plus_plugins/issues/2903)). ([2a547eb3](https://github.com/fluttercommunity/plus_plugins/commit/2a547eb3f0093160279fbc9de21dde3f3ff75c81))

## 9.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**(share_plus): Share API cleanup ([#2832](https://github.com/fluttercommunity/plus_plugins/issues/2832)). ([fd0511ca](https://github.com/fluttercommunity/plus_plugins/commit/fd0511ca4d55db1e075e72af5a0832b5cfe81244))

## 8.0.3

 - **REFACTOR**(share_plus): Migrate Android example to use the new plugins declaration ([#2742](https://github.com/fluttercommunity/plus_plugins/issues/2742)). ([a73af898](https://github.com/fluttercommunity/plus_plugins/commit/a73af898ee9b73dcc53307186ac4c79e795b1277))
 - **FIX**(share_plus): Recover ShareSuccessManager state after error ([#2817](https://github.com/fluttercommunity/plus_plugins/issues/2817)). ([2b12d8a8](https://github.com/fluttercommunity/plus_plugins/commit/2b12d8a8ada0d3f00abda0467946bb241361d016))
 - **DOCS**(share_plus): Add info regarding localization on Apple to README ([#2764](https://github.com/fluttercommunity/plus_plugins/issues/2764)). ([43f9a305](https://github.com/fluttercommunity/plus_plugins/commit/43f9a3051652448868c5031a45276f9ff870a025))
 - **DOCS**(share_plus): remove typo from the changelog ([#2747](https://github.com/fluttercommunity/plus_plugins/issues/2747)). ([961c8e2d](https://github.com/fluttercommunity/plus_plugins/commit/961c8e2dbf2210947cbed898c90e2776322a0942))

## 8.0.2

> Note: This release has breaking changes.

In this release plugin migrated to package:web, meaning that it now supports WASM!

> Plugin now requires the following:
> - Flutter >=3.19.0
> - Dart >=3.3.0
> - compileSDK 34 for Android part
> - Java 17 for Android part
> - Gradle 8.4 for Android part

- **BREAKING** **FEAT**(share_plus): Migrate to package:web ([#2709](https://github.com/fluttercommunity/plus_plugins/issues/2709)). ([641e7905](https://github.com/fluttercommunity/plus_plugins/commit/641e7905b4055827f1481f036415095dc43afe5f))
- **BREAKING** **BUILD**(share_plus): Target Java 17 on Android ([#2730](https://github.com/fluttercommunity/plus_plugins/issues/2730)). ([e6853a06](https://github.com/fluttercommunity/plus_plugins/commit/e6853a06fa110d69776a85684e302a7c900a6e07))
```

## README (ilk 200 satır)
```
# share_plus

[![share_plus](https://github.com/fluttercommunity/plus_plugins/actions/workflows/share_plus.yaml/badge.svg)](https://github.com/fluttercommunity/plus_plugins/actions/workflows/share_plus.yaml)
[![pub points](https://img.shields.io/pub/points/share_plus?color=2E8B57&label=pub%20points)](https://pub.dev/packages/share_plus/score)
[![pub package](https://img.shields.io/pub/v/share_plus.svg)](https://pub.dev/packages/share_plus)

[<img src="../../../assets/flutter-favorite-badge.png" width="100" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

A Flutter plugin to share content from your Flutter app via the platform's
share dialog.

Wraps the `ACTION_SEND` Intent on Android, `UIActivityViewController`
on iOS, or equivalent platform content sharing methods.

## Platform Support

| Shared content | Android | iOS | macOS | Web | Linux | Windows |
| :------------: | :-----: | :-: | :---: | :-: | :---: | :-----: |
| Text           |   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅   |
| URI            |   ✅    | ✅  |  ✅   | As text | As text | As text |
| Files          |   ✅    | ✅  |  ✅   | ✅  |  ❌   |   ✅   |

Also compatible with Windows and Linux by using "mailto" to share text via Email.

Sharing files is not supported on Linux.

## Requirements

- Flutter >=3.38.1
- Dart >=3.10.0 <4.0.0
- iOS >=13.0
- macOS >=10.15
- Java 17
- Kotlin 2.2.0
- Android Gradle Plugin >=8.12.1
- Gradle wrapper >=8.13

## Usage

To use this plugin, add `share_plus` as a [dependency in your pubspec.yaml file](https://plus.fluttercommunity.dev/docs/overview).

Import the library.

```dart
import 'package:share_plus/share_plus.dart';
```

### Share Text

Access the `SharePlus` instance via `SharePlus.instance`.
Then, invoke the `share()` method anywhere in your Dart code.

```dart
import 'package:share_plus/share_plus.dart';

SharePlus.instance.share(
  ShareParams(text: 'check out my website https://example.com')
);
```

The `share()` method requires the `ShareParams` object,
which contains the content to share.

These are some of the accepted parameters of the `ShareParams` class:

- `text`: text to share.
- `title`: content or share-sheet title (if supported).
- `subject`: email subject (if supported).

Check the class documentation for more details.

`share()` returns `status` object that allows to check the result of user action in the share sheet.

```dart
final result = await SharePlus.instance.share(params);

if (result.status == ShareResultStatus.success) {
    print('Thank you for sharing my website!');
}
```

### Share Files

To share one or multiple files, provide the `files` list in `ShareParams`.
Optionally, you can pass `title`, `text` and `sharePositionOrigin`.

```dart
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

final params = ShareParams(
  text: 'Great picture',
  files: [XFile('${directory.path}/image.jpg')],
);

final result = await SharePlus.instance.share(params);

if (result.status == ShareResultStatus.success) {
    print('Thank you for sharing the picture!');
}
```

```dart
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

final params = ShareParams(
  files: [
    XFile('${directory.path}/image1.jpg'),
    XFile('${directory.path}/image2.jpg'),
  ],
);

final result = await SharePlus.instance.share(params);

if (result.status == ShareResultStatus.dismissed) {
    print('Did you not like the pictures?');
}
```

On web, this uses the [Web Share API](https://web.dev/web-share/)
if it's available. Otherwise it falls back to downloading the shared files.
See [Can I Use - Web Share API](https://caniuse.com/web-share) to understand
which browsers are supported. This builds on the [`cross_file`](https://pub.dev/packages/cross_file)
package.

File downloading fallback mechanism for web can be disabled by setting:

```dart
import 'package:share_plus/share_plus.dart';

ShareParams(
  // rest of params
  downloadFallbackEnabled: false,
)
```

#### Share Data

You can also share files that you dynamically generate from its data using [`XFile.fromData`](https://pub.dev/documentation/share_plus/latest/share_plus/XFile/XFile.fromData.html).

To set the name of such files, use the `fileNameOverrides` parameter, otherwise the file name will be a random UUID string.

```dart
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:convert';

final params = ShareParams(
  files: [XFile.fromData(utf8.encode(text), mimeType: 'text/plain')],
  fileNameOverrides: ['myfile.txt']
);

SharePlus.instance.share(params);
```

> [!CAUTION]
> The `name` parameter in the `XFile.fromData` method is ignored in most platforms. Use `fileNameOverrides` instead.

### Share URI

iOS supports fetching metadata from a URI when shared using `UIActivityViewController`.
This special functionality is only properly supported on iOS.
On other platforms, the URI will be shared as plain text.

```dart
import 'package:share_plus/share_plus.dart';

final params = ShareParams(uri: uri);

SharePlus.instance.share(params);
```

### Share Results

All three methods return a `ShareResult` object which contains the following information:

- `status`: a `ShareResultStatus`
- `raw`: a `String` describing the share result, e.g. the opening app ID.

Note: `status` will be `ShareResultStatus.unavailable` if the platform does not support identifying the user action.

### Other Parameters

#### Title

Used as share sheet title where supported.

- Provided to Android's `Intent.createChooser` as the title, as well as, `EXTRA_TITLE` Intent extra.
- Provided to web Navigator Share API as title.

```dart
ShareParams(
  // rest of params
  title: 'Title',
)
```

#### Subject

```
