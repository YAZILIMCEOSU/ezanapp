# google_mobile_ads (google_mobile_ads-9.1.0)

## CHANGELOG (ilk 150 satır)
```
## 9.1.0
* Adding Ad Preloading APIs. [PR 1445](https://github.com/googleads/googleads-mobile-flutter/pull/1445)
* Support `AdManagerBannerAd` recycling by exposing `isMounted`. [PR 1443](https://github.com/googleads/googleads-mobile-flutter/pull/1443)
* Added `setConsentSyncId()` on `ConsentRequestParameters`. [PR 1452](https://github.com/googleads/googleads-mobile-flutter/pull/1452)
* Introduces `ageRestrictedTreatment` property to `RequestConfiguration`. [PR 1455](https://github.com/googleads/googleads-mobile-flutter/pull/1455)
* Null-safe return values across the plugin. [PR 1461](https://github.com/googleads/googleads-mobile-flutter/pull/1461)
* Updates GMA Android SDK dependencies:
  * [Google Mobile Ads](https://developers.google.com/admob/android/quick-start) SDK version `25.4.0`.
  * [Google Mobile Ads Next-Gen](https://developers.google.com/admob/android/next-gen/rel-notes) SDK version `1.3.1`.
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to `13.7.0`.
* Uses latest UMP SDK:
  * [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 4.0.0.
  * [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 3.1.0.

## 9.0.0
* Resolves pending start/stop method channel futures in AppStateNotifier Android. [PR 1438](https://github.com/googleads/googleads-mobile-flutter/pull/1438)
* Updates GMA Android SDK dependencies:
  * [Google Mobile Ads](https://developers.google.com/admob/android/quick-start) SDK version `25.3.0`.
  * [Google Mobile Ads Next-Gen](https://developers.google.com/admob/android/next-gen/rel-notes) SDK version `1.1.0`.
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to `13.3.0`.
* Uses latest UMP SDK:
  * [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 4.0.0.
  * [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 3.1.0.

## 8.0.0
* Updates minimum Flutter SDK to 3.38.1
* Updates Dart SDK low bound to 3.10.0.
* Adds Swift Package Manager Support for the plugin. [PR 1395](https://github.com/googleads/googleads-mobile-flutter/pull/1395)
* Adds `isCollapsible` API. [FR 1294](https://github.com/googleads/googleads-mobile-flutter/issues/1294)
* Renamed method name to avoid possible name collision. [FR 1394](https://github.com/googleads/googleads-mobile-flutter/issues/1394)
* Migrated to use UISceneDelegate protocol. [Issue 1391](https://github.com/googleads/googleads-mobile-flutter/issues/1391)
* New to Anchored adaptive banner ads:
  * The following APIs have been deprecated for their replacement:
    * The `getCurrentOrientationAnchoredAdaptiveBannerAdSize` function is deprecated. Instead, use the `getLargeAnchoredAdaptiveBannerAdSize` function.
    * The `getAnchoredAdaptiveBannerAdSize` function is deprecated. Instead, use the `getLargeAnchoredAdaptiveBannerAdSizeWithOrientation` function.
* Updates GMA [Android](https://developers.google.com/admob/android/rel-notes) dependency to 25.1.0
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to 13.2.0
* Uses latest UMP SDK:
  * [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 4.0.0.
  * [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 3.1.0.

## 7.0.0
* Added character limits expected for Native Ad Templates. Issues [1243](https://github.com/googleads/googleads-mobile-flutter/issues/1243) and [1332](https://github.com/googleads/googleads-mobile-flutter/issues/1332)
* Fixed padding for Native Ads small template. [Issue 1357](https://github.com/googleads/googleads-mobile-flutter/issues/1357)
* Updated to use Gradle plugin 9.2.1 [Issue 1361](https://github.com/googleads/googleads-mobile-flutter/issues/1361)
* Updates dependencies. [Issue 1366](https://github.com/googleads/googleads-mobile-flutter/issues/1366)
* Updates GMA [Android](https://developers.google.com/admob/android/rel-notes) dependency to 24.9.0
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to 12.14.0
* Uses latest UMP SDK:
  * [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 4.0.0.
  * [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 3.1.0.

## 6.0.0
* Updates minimum Flutter SDK to 3.27.0
* Updates Dart SDK low bound to 3.6.0.
* Fixes AdMessageCodec deprecated API issue: https://github.com/googleads/googleads-mobile-flutter/issues/1242
* Adds a new API (`isMounted`) to support recycling ad banners
* Updates GMA [Android](https://developers.google.com/admob/android/rel-notes) dependency to 24.1.0
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to 12.2.0
* Uses latest UMP SDK:
  * [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 3.2.0.
  * [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 3.0.0.

## 5.3.1
* Fixes dart SDK low bound building issues: https://github.com/googleads/googleads-mobile-flutter/issues/1234

## 5.3.0
* Updated WebView Flutter Android dependency 
* Adds support for the new Debug Geography enums for the UMP SDK: 
  * [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 3.1.0.
  * [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 2.7.0.
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to 11.13.0
* Updates GMA [Android](https://developers.google.com/admob/android/rel-notes) dependency to 23.6.0

## 5.2.0
* Removed use of rootViewController for iOS GMA SDK which solved issues like 
  https://github.com/googleads/googleads-mobile-flutter/issues/1146 and https://github.com/googleads/googleads-mobile-flutter/issues/700.
* Android GMA SDK is now initialized on a background thread.
* Updates GMA [iOS](https://developers.google.com/admob/ios/rel-notes) dependency to 11.10.0
* Updates GMA [Android](https://developers.google.com/admob/android/rel-notes) dependency to 23.4.0

## 5.1.0
* Adds support for APIs from the [Android](https://developers.google.com/admob/android/privacy/release-notes) UMP SDK version 2.2.0.
* Adds support for APIs from the [iOS](https://developers.google.com/admob/ios/privacy/download#release_notes) UMP SDK version 2.4.0.

## 5.0.0
* Adds `MediationExtras` class to include parameters when using mediation through the implementation of `FlutterMediationExtras` in Android and `FlutterMediationExtras` in iOS.
* Deprecates `MediationNetworkExtrasProvider` and `FLTMediationNetworkExtrasProvider`.
* Removed the `orientation` parameter for the AppOpen Ad format.
* Bumps minimum Android SDK version to 21.
* Updates GMA iOS dependency to 11.2.0
* Updates GMA Android dependency to 23.0.0

## 4.0.0
* The minimum supported Flutter version is now 3.7.0.
* Removes `visibility_detector` as a dependency, and the workaround added in
  https://github.com/googleads/googleads-mobile-flutter/pull/610.
* Adds null checks for Ad Ids for Android in
  https://github.com/googleads/googleads-mobile-flutter/pull/967
* Updated Android dependencies in https://github.com/googleads/googleads-mobile-flutter/pull/843
* Updates GMA iOS dependency to 10.11.0
* Updates GMA Android dependency to 22.5.0

## 3.1.0
* Updates GMA iOS dependency to 10.9.0
* Adds explicit UMP SDK 2.1.0 dependency for Android.
* Fixes https://github.com/googleads/googleads-mobile-flutter/issues/735

## 3.0.0
* Adds support for `MobileAds.registerWebView()`. This API supports in-app ad monetization for
  `WebView`s. You can read more in the [android](https://developers.google.com/admob/android/webview)
  or [iOS](https://developers.google.com/admob/ios/webview) documentation.
  This plugin now depends on [webview_flutter](https://pub.dev/packages/webview_flutter), 
  [webview_flutter_wkwebview](https://pub.dev/packages/webview_flutter_wkwebview), and 
  [webview_flutter_android](https://pub.dev/packages/webview_flutter_android)
* Updates Android GMA dependency to 22.0.0 and iOS dependency to 10.4.0
* Fixes https://github.com/googleads/googleads-mobile-flutter/issues/700
* Updates minimum supported Xcode version to 14.1.

## 2.4.0
* Adds support for native templates, which are predefined layouts for native ads.
  * `NativeAd` has a new optional parameter, `nativeTemplateStyle` of type `NativeTemplateStyle`.
    If provided, the plugin will inflate and style a platform native ad view for you, instead of
    requiring you to write and register a NativeAdFactory (android) or FLTNativeAdFactory (iOS).
* Adds a new flag, AdWidget.optOutOfVisibilityDetectorWorkaround. Setting this to true
  lets you opt out of the fix added for https://github.com/googleads/googleads-mobile-flutter/issues/580,
  which was resolved in Flutter 3.7.0.

## 2.3.0
* Updates GMA iOS dependency to 9.13
* Updates GMA Android dependency to 21.3.0
* Updates request agent string based on metadata in AndroidManifest.xml or Info.plist

## 2.2.0
* Updates GMA iOS dependency to 9.11.0. This fixes dependency issues in apps that
  also depend on the latest version of Firebase: https://github.com/googleads/googleads-mobile-flutter/issues/673
* Adds the field `responseExtras` to `ResponseInfo`. See `ResponseInfo` docs:
  * https://developers.google.com/admob/flutter/response-info
  * https://developers.google.com/ad-manager/mobile-ads-sdk/flutter/response-info
* Fixes a crash introduced in 2.1.0, [issue #675](https://github.com/googleads/googleads-mobile-flutter/issues/675)

## 2.1.0
* Updates GMA dependencies to 21.2.0 (Android) and 9.10.0 (iOS):
* Adds `loadedAdapterResponseInfo` to `ResponseInfo` and the following fields to
  `AdapterResponseInfo`:
  * adSourceID
  * adSourceInstanceId
  * adSourceInstanceName
  * adSourceName
* Fixes [close button issue on iOS](https://github.com/googleads/googleads-mobile-flutter/issues/191)
```

## README (ilk 200 satır)
```
# Google Mobile Ads for Flutter

[![google_mobile_ads](https://github.com/googleads/googleads-mobile-flutter/actions/workflows/google_mobile_ads.yaml/badge.svg)](https://github.com/googleads/googleads-mobile-flutter/actions/workflows/google_mobile_ads.yaml)

This repository contains the source code for the Google Mobile Ads Flutter
plugin, which enables publishers to monetize [Flutter](https://flutter.dev/)
apps using the Google Mobile Ads SDK. 

## Documentation

For instructions on how to use the plugin, please refer to the developer guides
for [AdMob](https://developers.google.com/admob/flutter/quick-start) and
[Ad Manager](https://developers.google.com/ad-manager/mobile-ads-sdk/flutter/quick-start).

## Downloads

See [pub.dev](https://pub.dev/packages/google_mobile_ads/versions) for the
latest releases of the plugin.

## Suggesting improvements

To file bugs, make feature requests, or to suggest other improvements, please
use [github's issue tracker](https://github.com/googleads/googleads-mobile-flutter/issues).


## Other resources

* [AdMob help center](https://support.google.com/admob/?hl=en#topic=7383088)
* [Ad Manager help center](https://support.google.com/admanager/?hl=en#topic=7505988)

## License

[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0)```
