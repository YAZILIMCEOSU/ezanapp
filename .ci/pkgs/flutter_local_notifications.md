# flutter_local_notifications (flutter_local_notifications-22.3.1)

## CHANGELOG (ilk 150 satır)
```
## [22.3.1]

* [macOS] fixed subtitle not showing up properly. Thanks to the PR from [Soi (Jiwon Lee)](https://github.com/JIWON1923)

## [22.3.0]

* [Android][iOS][macOS] added `openAppNotificationSettings()` method. This opens the system settings UI where the user can manage notification permissions for the app. When not possible, on iOS, it opens the application's settings on iOS and on macOS, it opens the system settings notification pane. Thanks to the PR from [hamadcc](https://github.com/hamadcc)

## [22.2.0]

* [Android][iOS][macOS] added support for callbacks to fire when a notification has been dismissed. This requires opting in by where the key requirements is to make use of the `dismissIsolate` property added to the `AndroidNotificationDetails` and `DarwinNotificationDetails` class. This indicates which isolate should be used to handle when a notification has been dismissed. Note on macOS, there is no support for background isolates so callback will always fire on the main isolate despite what is specified. Please see example app for more details on how to set up handling dismissals. Thanks to the PR from from [Vasily Laushkin](https://github.com/vlaushkin)
* [iOS] fixed issue [#2807](https://github.com/MaikuB/flutter_local_notifications/issues/2807) where the manifest for SPM incorrectly declared the minimum iOS version is 11 when it should have been 13. Thanks to the PR from [Bizzwell](https://github.com/Bizzwell)

## [22.1.0]

* [Android] added support for `showBigPictureWhenCollapsed` in `BigPictureStyleInformation`. Thanks to the PR from [hiimax (Codematic)](https://github.com/hiimax)
* [iOS][macOS] improved SPM compatibility
* Migrated example app to use SPM and removed Cocoapods integration
* Fixed API docs of `NotificationResponseType.selectedNotificationAction`. Thanks to the PR from [fush1m1](https://github.com/Fush1m1)

## [22.0.1]

* [Windows] Suppress warning around usage of experimental coroutines. This is to fix issue [#2777](https://github.com/MaikuB/flutter_local_notifications/issues/2777)

## [22.0.0]

* [Android] calling the `requestNotificationPolicyAccess()` method belonging to the `AndroidFlutterLocalNotificationsPlugin` class will now highlight associated application. Thanks to the PR from [Claudius Kienle](https://github.com/claudius-kienle)
* [Web] added web platform support. Thanks to the initial PR from [Levi Lesches](https://github.com/Levi-Lesches) and completion by [Gaurav](https://github.com/Gaurav-CareMonitor)
* [Windows] when calling `periodicallyShow()` the message when the `UnsupportedError` is thrown has been updated to say `Windows devices cannot periodically show notifications` instead. This has happened as a result of shifting the responsibility of reporting the `UnsupportedError` so it is done by `flutter_local_notifications_windows` instead of `flutter_local_notifications`
* [Windows] bumped `xml` dependency so that supported range is `>=6.5.0 <8.0.0`
* Fixed missing code formatting in the Notification Actions configuration section. Thanks to the PR from [Matias de Andrea](https://github.com/deandreamatias)

## [21.0.0]

* **Breaking change** bumped minimum Flutter SDK requirement to 3.38.1 and Dart SDK requirement to 3.10.0. Consequently the minimum OS requirements for each platform has been updated as well
  * [Android] minimum Android version is now 7.0 (API level 24)
  * [iOS] minimum iOS version is now 13
  * [macOS] minimum macOS version is now 10.15
* Bumped `timezone` dependency
* [Android] **Breaking change** bumped `compileSdk` to 36 and updated readme to mention this
* [Android] bumped Android Gradle Plugin (AGP) to 8.11.1 
* Migrated example app to `UIScene` lifecycle
* Updated readme to specify changes needed for applications that have migrated to `UIScene` lifecycle
* Updated iOS-specific setup around registering `UNUserNotificationCenterDelegate` to remove redundant `available` check and to be more specific that it should be done in the `application:didFinishLaunchingWithOptions:` method
* Bumped `flutter_timezone` dependency in example app

## [20.1.0]

* [iOS] added CarPlay notification support. Thanks to the PR from [derrik f](https://github.com/derrik-fleming)
* [iOS][macOS] the `ActiveNotification` class now returns values for `groupKey` property if applicable. This depends on if the `threadIdentifier` was specified when creating the notification itself. Thanks to the PR from [Kwon Tae Hyung](https://github.com/TaeBbong)
* [Windows] non-functional change: addressed the [`use_null_aware_elements`](https://dart.dev/tools/diagnostics/use_null_aware_elements) linter issue

## [20.0.0]

* **Breaking change** bumped minimum Flutter SDK requirement to 3.32.0 and Dart SDK requirement to 3.8.0
* **Breaking changes** the positional parameters in the following methods have now been converted to named parameters across all platforms. Thanks to the PR started by [Kwon Tae Hyung](https://github.com/TaeBbong)
  * `initialize()`
  * `show()`
  * `periodicallyShow()`
  * `periodicallyShowWithDuration()`
  * `cancel()`
  * `zonedSchedule()`
* [Android] **Breaking changes** the positional parameters in the following methods have now been converted to named parameters
  * `startForegroundService()`
  * `deleteNotificationChannelGroup()`
  * `deleteNotificationChannel()`
  * `getActiveNotificationMessagingStyle()`
* [Linux] **Breaking changes** the positional parameters in the `LinuxNotificationCustomHint()` method have now been converted to named parameters
* [Windows] * **Breaking changes** the positional parameters in the following methods have now been converted to named parameters
  * `showRawXml()`
  * `zonedScheduleRawXml()`
* [Windows] **Breaking changes** to align with the main the plugin, the following parameters have been renamed
  * the `details` parameter in the `show()` and `zonedSchedule()` methods has been renamed to `notificationDetails`
  * the `onNotificationReceived` in the `initialize()` method has been renamed to `onDidReceiveNotificationResponse`
* [Windows] **Breaking change** removed the `details` parameter from the `zonedScheduleRawXml()` method as it was not actually used. Thanks to the PR from [Levi Lesches](https://github.com/Levi-Lesches)
* [Android] updated Java compatibility version to 17
* [Android] fixed issue [#2745](https://github.com/MaikuB/flutter_local_notifications/issues/2745) to export the `AndroidIcon` abstract class 
* Updated readme with information for developers that plan to move to use the UIScene lifecycle
* Added `flutter_lints` to apply linter rules

## [19.5.0]

* [iOS][macOS] added `requestProvidesAppNotificationSettings` option to `DarwinInitializationSettings` class, and `isProvidesAppNotificationSettingsEnabled` to `NotificationsEnabledOptions` class. This allows applications to show a "Configure Notifications in <app name>" option when showing the context menu for an individual notification. This can be used for scenarios where an application can respond to the user selecting this option to show a custom page for controlling notification settings. Please note this whilst the API changes are applicable for iOS and macOS, the actual functionality only appears to be supported by Apple when it comes to iOS devices. See example app to see how this new functionality can be implemented. Thanks to the PR from [Luke Memet](https://github.com/lukemmtt)

## [19.4.2]

* [Windows] fixed issue where non-ASCII characters for the notification [application name](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsInitializationSettings/appName.html) weren't being displayed properly. Thanks to the PR from [yoyoIU](https://github.com/yoyo930021)

## [19.4.1]

* [Android] fixed issue [#2675](https://github.com/MaikuB/flutter_local_notifications/issues/2675) where addition of `invisible` flag to notification actions could cause scheduled notifications with actions created prior to 19.4.0 to fail to show
* Updated the Android release build configuration section to point to the latest [location](https://developer.android.com/topic/performance/app-optimization/customize-which-resources-to-keep) of the official Android docs on how to configure which resources (e.g. notification icons) are kept so they are not discarded by the Android compiler. It has also been reworded to make it clearer that this applies to all Android resources 

## [19.4.0]

* [Android] added ability to read `dataMimeType` and `dataUri` when calling `getActiveNotifications()` to read details of an active Android notification using the messaging style. Thanks to the PR from [Matt Bajorek](https://github.com/mattbajorek)
* [Android] added support for Android semantic actions. Thanks to the PR from [Jared Szechy](https://github.com/szechyjs)

## [19.3.1]

* [Windows] fixed issue [#2648](https://github.com/MaikuB/flutter_local_notifications/issues/2648) where non-ASCII characters in the notification payload were not being handled properly. Thanks to the PR from [yoyoIU](https://github.com/yoyo930021)
* [Windows] fixed issue [#2651](https://github.com/MaikuB/flutter_local_notifications/issues/2651) where unresolved symbols occurred with changes in introduced in newer Windows SDKs. Thanks to the PR from [Sebastien](https://github.com/Sebastien-VZN)

## [19.3.0]

* [Android][iOS][macOS] added `cancelAllPendingNotifications()` method for cancelling all pending notifications that have been scheduled. Thanks to the PR from [Kwon Tae Hyung](https://github.com/TaeBbong)

## [19.2.1]

* [macOS] removed redundant code that was only applicable on macOS versions lower than 10.14. This should be a non-functional change since 18.0.0 bumped the minimum Flutter SDK requirements that in turn required macOS 10.14 at a minimum. Thanks to the PR from [Blin Qipa](https://github.com/bqubique)
* [Android] bumped robolectric dependency. This fixes an issue where some users reported receiving instances of `java.lang.NoClassDefFoundError` around the plugin's Android unit tests. Thanks to the PR from [Turtlepaw](https://github.com/Turtlepaw)

## [19.2.0]

* [Android] added support to bypass have notifications bypass the device's Do Not Disturb (DnD) settings. Thanks the PR from [Michel v. Varendorff](https://github.com/mvarendorff2) that added the following changes
  * The `hasNotificationPolicyAccess()` method that checks if the application can modify the notification policy
  * The `requestNotificationPolicyAccess()` method that was added the `AndroidFlutterNotificationsPlugin` class. This can be used request access for the calling application modify the notification policy
  * Added `bypassDnd` the property of the `AndroidNotificationChannel` class and `channelBypassDnd` to the `AndroidNotificationDetails` class. These can used to indicate if notifications associated with the channel can bypass the DnD settings of the device
* Bumped `msix` dev dependency in example app. This to fix the [issue](https://github.com/YehudaKremer/msix/issues/303) where the `msix` package stopped being able to created MSIX installers

## [19.1.0]

* [iOS][macOS] added supported to specify the volume for critical alerts. Thanks to the PR from [bannzai](https://github.com/bannzai)
* Updated Gradle setup information in the readme to clarify that desugaring needs to be enabled even if scheduled notifications aren't used

## [19.0.0]

* [Android] **Breaking change** bumped `compileSdk` to 35 and updated readme to mention this
* [Android] bumped GSON dependency to 2.12. As a result of doing so, applications should no longer need ProGuard rules related to this plugin that were needed for release builds to function. The readme has been updated to remove the associated setup to reflect this. Thanks to the PR from [Koji Wakamiya](https://github.com/koji-1009)
* [Android] bumped Android Gradle Plugin to 8.6.0 to align with the [minimum version](https://developer.android.com/build/releases/gradle-plugin#api-level-support) to use `compileSdk` version 35 (Android 15)
* [Android] bumped desugaring library to 2.1.4 and set Java compatibility to 11 instead of 8. Readme has been updated to reflect these changes  where`sourceCompatibility` and `targetCompability` should be set to JavaVersion.VERSION_11 (i.e. Java 11), and `jvmTarget` is set to `11`
* [iOS] **Breaking change** removed `uiLocalNotificationDateInterpretation` parameter from `zonedSchedule()` method. This was done as it actually no relevant as of the 18.0.0 that dropped support for iOS versions older than 10, which in turn meant that the deprecated `UILocalNotification` APIs from Apple were no longer used. The corresponding `UILocalNotificationDateInterpretation` enum has already been removed as well
* [iOS][macOS] **Breaking changes** the `DarwinNotificationActionOption` and `DarwinNotificationCategoryOption` are now enhanced enums with values accessible through the `value` property that are exactly the same as their native representations. Previously a bitwise left shift operation was applied to the index value
* [iOS][macOS] **Breaking change** renamed `Converters` header and implementation to `FlutterLocalNotificationsConverters`. This would likely not affect any users of the plugin. Done to fix/mitigate issues [#2160](https://github.com/MaikuB/flutter_local_notifications/issues/2160) and [#2529](https://github.com/MaikuB/flutter_local_notifications/issues/2529) where the original name could clash
* [iOS][macOS] added Swift Package Manager support
* [Windows] Added support for Windows. Thanks to PR [Levi Lesches](https://github.com/Levi-Lesches) that continued the work done initially done by [Kenneth](https://github.com/kennethnym) and [lightrabbit](https://github.com/lightrabbit)
*  **Breaking change** bumped minimum Flutter SDK requirement to 3.22.0 and Dart SDK requirement to 3.4.0. The minimum supported Android version is now 5.0 (API level 21)
* Bumped `timezone` dependency so that minimum version is now 0.10.0
* Bumped multiple dependencies in example app
* Bumped minimum `plugin_platform_interface` version to 2.1.8
* Updated example app's `AndroidManifest.xml` to request internet permissions so that release builds can download remote content
* Migrated example app to use Plugin DSL. Thanks to the PR from [Martin Bertele](https://github.com/martin-bertele)
* Updated `compileSdk` and `targetSdkVersion` of example app to 35


## [18.0.1]

* Added upper bound constraints for [timezone](https://pub.dev/packages/timezone) dependency. This is to allow the plugin and apps pull version 0.10.x if constraints are satisified. Future releases may bump the minimum `timezone` dependency but this approach is being used at the moment as version 0.10.0 of the time `timezone` package introduces a dependency on `http` package. Directly bumping the `flutter_local_notifications` dependency on `timezone` could have introduced dependency conflicts

## [18.0.0]
```

## README (ilk 200 satır)
```
# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)
![Build Status](https://github.com/MaikuB/flutter_local_notifications/actions/workflows/validate.yml/badge.svg)

A cross platform plugin for displaying local notifications.

>[!IMPORTANT]
> Given how quickly the Flutter ecosystem evolves, the minimum Flutter SDK version will be bumped occasionally to make it easier to maintain the plugin. Note that the official plugins already follow a similar approach. If this affects your applications (e.g., you need to support an older OS version), you may need to consider maintaining your own fork.

## Table of contents

- **[📱 Supported platforms](#-supported-platforms)**
- **[✨ Features](#-features)**
- **[⚠ Caveats and limitations](#-caveats-and-limitations)**
   - [Compatibility with firebase_messaging](#compatibility-with-firebase_messaging)
   - [Scheduled Android notifications](#scheduled-android-notifications)
   - [iOS pending notifications limit](#ios-pending-notifications-limit)
   - [Scheduled notifications and daylight saving time](#scheduled-notifications-and-daylight-saving-time)
   - [Updating application badge](#updating-application-badge)
   - [Custom notification sounds](#custom-notification-sounds)
   - [macOS differences](#macos-differences)
   - [Linux limitations](#linux-limitations)
   - [Web limitations](#web-limitations)
   - [Notification payload](#notification-payload)
- **[📷 Screenshots](#-screenshots)**
- **[👏 Acknowledgements](#-acknowledgements)**
- **[🔧 Android Setup](#-android-setup)**
   - [Gradle setup](#gradle-setup)
   - [AndroidManifest.xml setup](#androidmanifestxml-setup)
   - [Requesting permissions on Android 13 or higher](#requesting-permissions-on-android-13-or-higher)
   - [Custom notification icons and sounds](#custom-notification-icons-and-sounds)
   - [Scheduled notifications](#scheduling-a-notification)
   - [Fullscreen intent notifications](#full-screen-intent-notifications)
   - [Release build configuration](#release-build-configuration)
     - [ProGuard rules](#proguard-rules)
- **[🔧 iOS setup](#-ios-setup)**
   - [General setup](#general-setup)
   - [Handling notifications whilst the app is in the foreground](#handling-notifications-whilst-the-app-is-in-the-foreground)
- **[🌐 Web Setup](#web-setup)**
- **[❓ Usage](#-usage)**
   - [Notification Actions](#notification-actions)
   - [Example app](#example-app)
   - [API reference](#api-reference)
- **[Initialisation](#initialisation)**
   - [[iOS (all supported versions) and macOS 10.14+] Requesting notification permissions](#ios-all-supported-versions-and-macos-1014-requesting-notification-permissions)
   - [Displaying a notification](#displaying-a-notification)
   - [Scheduling a notification](#scheduling-a-notification)
   - [Periodically show a notification with a specified interval](#periodically-show-a-notification-with-a-specified-interval)
   - [Retrieving pending notification requests](#retrieving-pending-notification-requests)
   - [[Selected OS versions] Retrieving active notifications](#android-only-retrieving-active-notifications)
   - [Grouping notifications](#grouping-notifications)
   - [Cancelling/deleting a notification](#cancellingdeleting-a-notification)
   - [Cancelling/deleting all notifications](#cancellingdeleting-all-notifications)
   - [Getting details on if the app was launched via a notification created by this plugin](#getting-details-on-if-the-app-was-launched-via-a-notification-created-by-this-plugin)
   - [[iOS only] Periodic notifications showing up after reinstallation](#ios-only-periodic-notifications-showing-up-after-reinstallation)
- **[📈 Testing](#-testing)**

## 📱 Supported platforms

* **Android+**. Uses the [NotificationCompat APIs](https://developer.android.com/reference/androidx/core/app/NotificationCompat) so it can be run older Android devices
* **iOS** Uses the [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework)
* **macOS** Uses the [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework)
* **Linux**. Uses the [Desktop Notifications Specification](https://specifications.freedesktop.org/notification-spec/)
* **Windows** Uses the [C++/WinRT](https://learn.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/) implementation of [Toast Notifications](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/toast-notifications-overview)
* **Web** Uses the [Notifications API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API)

Note: the plugin requires Flutter SDK 3.38.1 at a minimum. The list of support platforms for Flutter 3.38.1 itself can be found [here](https://github.com/flutter/website/blob/6150d58df2f39275ffd589ba32f25557a27e2384/src/content/reference/supported-platforms.md?plain=1#L82)

## ✨ Features

* Mockable (plugin and API methods aren't static)
* Display basic notifications
* Scheduling when notifications should appear
* Periodically show a notification (interval based)
* Schedule a notification to be shown daily at a specified time
* Schedule a notification to be shown weekly on a specified day and time
* Retrieve a list of pending notification requests that have been scheduled to be shown in the future
* Cancelling/removing notification by id or all of them
* Specify a custom notification sound
* Ability to handle when a user has tapped on a notification, when the app is in the foreground, background or is terminated
* Determine if an app was launched due to tapping on a notification
* [Android] Request permission to show notifications
* [Android] Configuring the importance level
* [Android] Configuring the priority
* [Android] Customising the vibration pattern for notifications
* [Android] Configure the default icon for all notifications
* [Android] Configure the icon for each notification (overrides the default when specified)
* [Android] Configure the large icon for each notification. The icon can be a drawable or a file on the device
* [Android] Formatting notification content via [HTML markup](https://developer.android.com/guide/topics/resources/string-resource.html#StylingWithHTML)
* [Android] Support for the following notification styles
    * Big picture
    * Big text
    * Inbox
    * Messaging
    * Media
        * While media playback control using a `MediaSession.Token` is not supported, with this style you let Android treat the `largeIcon` bitmap as album artwork
* [Android] Group notifications
* [Android] Show progress notifications
* [Android] Configure notification visibility on the lockscreen
* [Android] Ability to create and delete notification channels
* [Android] Retrieve the list of active notifications
* [Android] Full-screen intent notifications
* [Android] Start a foreground service
* [Android] Ability to check if notifications are enabled
* [Android] Open app notification settings
* [iOS (all supported versions) & macOS 10.14+] Request notification permissions and customise the permissions being requested around displaying notifications
* [iOS 10+] Request CarPlay notification permissions for notifications to appear in CarPlay interface
* [iOS 10 or newer and macOS 10.14 or newer] Display notifications with attachments
* [iOS 12.0+] Support for custom notification settings UI via "Configure Notifications in <application name>" button in notification context menu (API available on macOS 10.14+ but UI button does not appear in practice)
* [iOS and macOS 10.14 or newer] Ability to check if notifications are enabled with specific type check
* [iOS 15.4+] Attempt to open the app's notification settings page (falls back to app settings on older iOS versions)
* [macOS] Attempt to open the app's notification settings page (falls back to system settings notifications pane)
* [Linux] Ability to to use themed/Flutter Assets icons and sound
* [Linux] Ability to to set the category
* [Linux] Configuring the urgency
* [Linux] Configuring the timeout (depends on system implementation)
* [Linux] Ability to set custom notification location (depends on system implementation)
* [Linux] Ability to set custom hints
* [Linux] Ability to suppress sound
* [Linux] Resident and transient notifications
* [Windows] Can show raw XML (see the [Notifications Visualizer](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/notifications-visualizer))
* [Windows] A full Dart API for all the options supported by toast notifications
* [Windows] Can configure images, buttons, dropdowns, text input, and launch behavior
* [Windows] Can dynamically update notifications after they've been shown

## ⚠ Caveats and limitations

The cross-platform facing API exposed by the `FlutterLocalNotificationsPlugin` class doesn't expose platform-specific methods as its goal is to provide an abstraction for all platforms. As such, platform-specific configuration is passed in as data. There are platform-specific implementations of the plugin that can be obtained by calling the [`resolvePlatformSpecificImplementation`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/resolvePlatformSpecificImplementation.html). An example of using this is provided in the section on requesting permissions on iOS. In spite of this, there may still be gaps that don't cover your use case and don't make sense to add as they don't fit with the plugin's architecture or goals. Developers can fork or maintain their own code for showing notifications in these situations.

### Compatibility with firebase_messaging

Previously, there were issues that prevented this plugin working properly with the `firebase_messaging` plugin. This meant that callbacks from each plugin might not be invoked. This has been resolved since version 6.0.13 of the `firebase_messaging` plugin so please make sure you are using more recent versions of the  `firebase_messaging` plugin and follow the steps covered in `firebase_messaging`'s readme file located [here](https://pub.dev/packages/firebase_messaging)

### Scheduled Android notifications

Some Android OEMs have their own customised Android OS that can prevent applications from running in the background. Consequently, scheduled notifications may not work when the application is in the background on certain devices (e.g. by Xiaomi, Huawei). If you experience problems like this then this would be the reason why. As it's a restriction imposed by the OS, this is not something that can be resolved by the plugin. Some devices may have setting that lets users control which applications run in the background. The steps for these can vary but it is still up to the users of your application to do given it's a setting on the phone itself. The site https://dontkillmyapp.com provides details on how to do this for various devices.

It has been reported that Samsung's implementation of Android has imposed a maximum of 500 alarms that can be scheduled via the [Alarm Manager](https://developer.android.com/reference/android/app/AlarmManager) API and exceptions can occur when going over the limit.

### iOS pending notifications limit

There is a limit imposed by iOS where it will only keep the 64 notifications that were last set on any iOS versions newer than 9. On iOS versions 9 and older, the 64 notifications that fire soonest are kept. [See here for more details.](https://ileyf.cn.openradar.appspot.com/38065340)

### Scheduled notifications and daylight saving time

The notification APIs used on iOS versions older than 10 (aka the `UILocalNotification` APIs) have limited supported for time zones.

### Updating application badge

This plugin doesn't provide APIs for directly setting the badge count for your application. If you need this for your application, there are other plugins available, such as the [`flutter_app_badger`](https://pub.dev/packages/flutter_app_badger) plugin.

### Custom notification sounds

[iOS and macOS restrictions](https://developer.apple.com/documentation/usernotifications/unnotificationsound?language=objc) apply (e.g. supported file formats).

### macOS differences

Due to limitations currently within the macOS Flutter engine, `getNotificationAppLaunchDetails` will return null on macOS versions older than 10.14. These limitations will mean that conflicts may occur when using this plugin with other notification plugins (e.g. for push notifications).

The `schedule`, `showDailyAtTime` and `showWeeklyAtDayAndTime` methods that were implemented before macOS support was added and have been marked as deprecated aren't implemented on macOS.

### Linux limitations

Capabilities depend on the system notification server implementation, therefore, not all features listed in `LinuxNotificationDetails` may be supported. One of the ways to check some capabilities is to call the `LinuxFlutterLocalNotificationsPlugin.getCapabilities()` method.

Scheduled/pending notifications is currently not supported due to the lack of a scheduler API.

The `onDidReceiveNotificationResponse` callback runs on the main isolate of the running application and cannot be launched in the background if the application is not running. To respond to notification after the application is terminated, your application should be registered as DBus activatable (please see [DBusApplicationLaunching](https://wiki.gnome.org/HowDoI/DBusApplicationLaunching) for more information), and register action before activating the application. This is difficult to do in a plugin because plugins instantiate during application activation, so `getNotificationAppLaunchDetails` can't be implemented without changing the main user application.

### Windows limitations

- Windows does not support repeating notifications, so [`periodicallyShow`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShow.html) and [`periodicallyShowWithDuration`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShowWithDuration.html) will throw `UnsupportedError`s.
- Windows only allows apps with package identity to retrieve previously shown notifications. This means that on an app that was not packaged as an [MSIX](https://learn.microsoft.com/en-us/windows/msix/overview) installer, [`cancel`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancel.html) does nothing and [`getActiveNotifications`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getActiveNotifications.html) will return an empty list. To package your app as an MSIX, see [`package:msix`](https://pub.dev/packages/msix) and the `msix` section in [the example's `pubspec.yaml`](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/pubspec.yaml).

### Web limitations

- **You must request notification permissions before showing notifications -- but only in response to a user interaction.** If you try to request permissions automatically, like on loading a page, not only may your request be automatically denied, but the browser may deem your site as abusive and no longer show any more prompts to the user, and just block everything going forward.
- Notification actions are supported by Chrome and Edge, but not Firefox or Safari. They may catch up soon, but text input fields use a standards _proposal_, not an accepted standard, and so may only work on Chrome for a while.

- Browsers don't support scheduled or repeating notifications, and browsers on Android do not support custom vibration.

For more details on browser compatibility, limitations, and troubleshooting, see the [`flutter_local_notifications_web` README](https://pub.dev/packages/flutter_local_notifications_web).

### Notification payload

Due to some limitations on iOS with how it treats null values in dictionaries, a null notification payload is coalesced to an empty string behind the scenes on all platforms for consistency.

## 📷 Screenshots

| Platform | Screenshot                                                   |
| -------- | ------------------------------------------------------------ |
| Android  | <img height="480" src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/android_notification.png"> |
| iOS      | <img height="414" src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/ios_notification.png"> |
| macOS    | <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/macos_notification.png"> |
| Linux    | <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/gnome_linux_notification.png"> <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/kde_linux_notification.png"> |
| Windows  | <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/windows_notification.png"> |
| Web      | <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/web_notifications.png"> |


```
