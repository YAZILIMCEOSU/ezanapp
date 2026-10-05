# CI raporu (2026-10-04 13:29 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | failure |
| test | success |
| build | failure |

## pubget
```
+ path 1.9.1
+ path_provider 2.1.6
+ path_provider_android 2.3.1
+ path_provider_foundation 2.6.0
+ path_provider_linux 2.2.2
+ path_provider_platform_interface 2.1.3
+ path_provider_windows 2.3.0
+ petitparser 7.1.0
+ platform 3.2.0
+ plugin_platform_interface 2.1.8
+ pointycastle 4.0.0
+ postgrest 2.9.1
+ process 5.0.6
+ pub_semver 2.2.1
+ realtime_client 2.13.0
+ record_use 1.1.1
+ riverpod 3.4.3
+ rxdart 0.28.0
+ scrollable_positioned_list 0.3.8
+ share_plus 13.3.1
+ share_plus_platform_interface 7.2.0
+ shared_preferences 2.5.5
+ shared_preferences_android 2.4.28
+ shared_preferences_foundation 2.5.7
+ shared_preferences_linux 2.4.1
+ shared_preferences_platform_interface 2.4.2
+ shared_preferences_web 2.4.3
+ shared_preferences_windows 2.4.1
+ sky_engine 0.0.0 from sdk flutter
+ source_span 1.10.2
+ sqflite 2.4.4
+ sqflite_android 2.4.4
+ sqflite_common 2.5.13
+ sqflite_common_ffi 2.4.3
+ sqflite_darwin 2.4.4
+ sqflite_platform_interface 2.4.2
+ sqlite3 3.7.0
+ stack_trace 1.12.2
+ state_notifier 1.0.0
+ storage_client 2.8.1
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ supabase 2.16.2
+ supabase_common 0.1.2
+ supabase_flutter 2.18.0
+ synchronized 3.4.2
+ term_glyph 1.2.2
+ test_api 0.7.12 (0.7.14 available)
+ timezone 0.11.1
+ typed_data 1.4.0
+ url_launcher 6.3.3
+ url_launcher_android 6.3.33
+ url_launcher_ios 6.4.2
+ url_launcher_linux 3.2.3
+ url_launcher_macos 3.2.6
+ url_launcher_platform_interface 2.3.2
+ url_launcher_web 2.4.3
+ url_launcher_windows 3.1.6
+ uuid 4.6.0
+ vector_math 2.4.3
+ vibration 3.2.1
+ vibration_platform_interface 0.1.2
+ vm_service 15.3.0
+ web 1.1.1
+ web_socket 1.0.1
+ web_socket_channel 3.0.3
+ webview_flutter 4.14.1
+ webview_flutter_android 4.14.1
+ webview_flutter_platform_interface 2.15.1
+ webview_flutter_wkwebview 3.27.0
+ win32 6.4.0
+ win32_registry 3.0.3
+ xdg_directories 1.1.0
+ xml 7.1.0
+ yaml 3.1.4
+ yet_another_json_isolate 2.1.1
Changed 197 dependencies!
8 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Upgrading analysis_options.yaml to exclude build and platform directories.
```

## fmt
```
== dart fix --apply ==
  prefer_initializing_formals - 1 fix

lib/data/models/app_settings.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/data/prayer/aladhan_api_source.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/data/prayer/diyanet_api_source.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/data/prayer/prayer_times_repository.dart
  prefer_initializing_formals - 2 fixes

lib/data/repositories/ilahi_repository.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/features/home/home_screen.dart
  prefer_const_constructors - 3 fixes
  unnecessary_const - 1 fix

lib/features/widgets/ad_banner.dart
  directives_ordering - 1 fix

lib/features/widgets/app_shell.dart
  use_null_aware_elements - 1 fix

lib/features/widgets/prayer_countdown_chip.dart
  unused_import - 1 fix

lib/features/widgets/prayer_widgets.dart
  unused_import - 1 fix

lib/features/widgets/state_views.dart
  use_null_aware_elements - 1 fix

lib/router/app_router.dart
  directives_ordering - 1 fix

22 fixes made in 18 files.
== dart format ==
Formatted lib/data/repositories/daily_content_repository.dart
Formatted lib/data/repositories/hadith_repository.dart
Formatted lib/data/repositories/ilahi_repository.dart
Formatted lib/data/repositories/quran_repository.dart
Formatted lib/data/repositories/ramadan_repository.dart
Formatted lib/data/repositories/zikir_repository.dart
Formatted lib/design/app_colors.dart
Formatted lib/design/app_spacing.dart
Formatted lib/design/app_theme.dart
Formatted lib/features/home/home_screen.dart
Formatted lib/features/prayers/prayers_screen.dart
Formatted lib/features/widgets/ad_banner.dart
Formatted lib/features/widgets/app_shell.dart
Formatted lib/features/widgets/prayer_countdown_chip.dart
Formatted lib/features/widgets/prayer_widgets.dart
Formatted lib/features/widgets/state_views.dart
Formatted lib/router/app_router.dart
Formatted lib/state/content_providers.dart
Formatted lib/state/providers.dart
Formatted 61 files (55 changed) in 0.39 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/features/prayers/prayers_screen.dart:275:29 • curly_braces_in_flow_control_structures
   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/features/prayers/prayers_screen.dart:539:25 • curly_braces_in_flow_control_structures
  error • Target of URI doesn't exist: '../features/ai/ai_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:5:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/hadith/hadith_detail_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:6:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/hadith/hadith_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:7:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/ilahi/ilahi_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:9:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/ilahi/player_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:10:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/ilahi/playlist_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:11:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/more/more_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:12:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/more/onboarding_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:13:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/more/premium_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:14:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/qibla/qibla_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:16:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/quran/quran_bookmarks_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:17:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/quran/quran_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:18:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/quran/quran_search_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:19:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/quran/surah_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:20:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/ramadan/ramadan_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:21:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/settings/about_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:22:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/settings/city_picker_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:23:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/settings/notification_settings_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:24:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/settings/settings_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:25:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/widgets/not_found_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:26:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/zikir/zikir_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:27:8 • uri_does_not_exist
  error • Target of URI doesn't exist: '../features/zikir/zikir_stats_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/router/app_router.dart:28:8 • uri_does_not_exist
  error • The function 'AppShell' isn't defined. Try importing the library that defines 'AppShell', correcting the name to the name of an existing function, or defining a function named 'AppShell' • lib/router/app_router.dart:93:12 • undefined_function
  error • The name 'QuranScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:121:25 • creation_with_non_type
  error • The name 'IlahiScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:131:25 • creation_with_non_type
  error • The name 'MoreScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:141:25 • creation_with_non_type
  error • The name 'OnboardingScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:150:17 • creation_with_non_type
  error • The name 'QiblaScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:155:17 • creation_with_non_type
  error • The name 'ZikirScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:160:17 • creation_with_non_type
  error • The name 'ZikirStatsScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:165:21 • creation_with_non_type
  error • The name 'HadithScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:172:17 • creation_with_non_type
  error • The function 'HadithDetailScreen' isn't defined. Try importing the library that defines 'HadithDetailScreen', correcting the name to the name of an existing function, or defining a function named 'HadithDetailScreen' • lib/router/app_router.dart:177:15 • undefined_function
  error • The name 'RamadanScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:186:17 • creation_with_non_type
  error • The name 'AiScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:190:69 • creation_with_non_type
  error • The name 'PremiumScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:195:17 • creation_with_non_type
  error • The name 'CityPickerScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:200:17 • creation_with_non_type
  error • The name 'SettingsScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:205:17 • creation_with_non_type
  error • The name 'NotificationSettingsScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:210:21 • creation_with_non_type
  error • The name 'AboutScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:215:21 • creation_with_non_type
  error • The name 'QuranSearchScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:222:17 • creation_with_non_type
  error • The name 'QuranBookmarksScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:227:17 • creation_with_non_type
  error • The function 'SurahScreen' isn't defined. Try importing the library that defines 'SurahScreen', correcting the name to the name of an existing function, or defining a function named 'SurahScreen' • lib/router/app_router.dart:231:63 • undefined_function
  error • The name 'PlayerScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:239:17 • creation_with_non_type
  error • The name 'PlaylistScreen' isn't a class. Try correcting the name to match an existing class • lib/router/app_router.dart:244:17 • creation_with_non_type
  error • The function 'PlaylistScreen' isn't defined. Try importing the library that defines 'PlaylistScreen', correcting the name to the name of an existing function, or defining a function named 'PlaylistScreen' • lib/router/app_router.dart:248:63 • undefined_function
  error • The function 'NotFoundScreen' isn't defined. Try importing the library that defines 'NotFoundScreen', correcting the name to the name of an existing function, or defining a function named 'NotFoundScreen' • lib/router/app_router.dart:254:7 • undefined_function
  error • Undefined class 'FutureProviderFamily'. Try changing the name to the name of an existing class, or creating a class with the name 'FutureProviderFamily' • lib/state/content_providers.dart:58:7 • undefined_class
   info • Type could be non-nullable. Try changing the type to be non-nullable • lib/state/content_providers.dart:58:55 • unnecessary_nullable_for_final_variable_declarations
   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/state/content_providers.dart:65:9 • curly_braces_in_flow_control_structures
  error • Undefined class 'FutureProviderFamily'. Try changing the name to the name of an existing class, or creating a class with the name 'FutureProviderFamily' • lib/state/content_providers.dart:105:7 • undefined_class
   info • Type could be non-nullable. Try changing the type to be non-nullable • lib/state/content_providers.dart:105:47 • unnecessary_nullable_for_final_variable_declarations
  error • Undefined class 'FutureProviderFamily'. Try changing the name to the name of an existing class, or creating a class with the name 'FutureProviderFamily' • lib/state/content_providers.dart:130:7 • undefined_class
   info • Type could be non-nullable. Try changing the type to be non-nullable • lib/state/content_providers.dart:130:60 • unnecessary_nullable_for_final_variable_declarations
   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/state/content_providers.dart:136:9 • curly_braces_in_flow_control_structures
  error • Undefined class 'FutureProviderFamily'. Try changing the name to the name of an existing class, or creating a class with the name 'FutureProviderFamily' • lib/state/content_providers.dart:219:7 • undefined_class
   info • Type could be non-nullable. Try changing the type to be non-nullable • lib/state/content_providers.dart:219:51 • unnecessary_nullable_for_final_variable_declarations

58 issues found. (ran in 16.0s)
```

## test
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/placeholder_test.dart
00:00 +0: placeholder
00:00 +1: All tests passed!
```

## build
```
Upgrading build.gradle.kts
Upgrading gradle.properties
Upgrading gradle.properties
Running Gradle task 'assembleDebug'...                          
Warning: Flutter support for your project's Gradle version (8.14.3) will soon be dropped. Please upgrade your Gradle version to a version of at least 9.1.0 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's gradle version is typically defined in the gradle wrapper file. By default, this can be found at /home/runner/work/ezanapp/ezanapp/android/gradle/wrapper/gradle-wrapper.properties. 
For more information, see https://docs.gradle.org/current/userguide/gradle_wrapper.html.

Warning: Flutter support for your project's Android Gradle Plugin version (Android Gradle Plugin version 8.12.1) will soon be dropped. Please upgrade your Android Gradle Plugin version to a version of at least Android Gradle Plugin version 9.0.1 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's AGP version is typically defined in the plugins block of the `settings.gradle` file (/home/runner/work/ezanapp/ezanapp/android/settings.gradle), by a plugin with the id of com.android.application. 
If you don't see a plugins block, your project was likely created with an older template version. In this case it is most likely defined in the top-level build.gradle file (/home/runner/work/ezanapp/ezanapp/android/build.gradle) by the following line in the dependencies block of the buildscript: "classpath 'com.android.tools.build:gradle:<version>'".


FAILURE: Build failed with an exception.

* Where:
Build file '/home/runner/work/ezanapp/ezanapp/android/app/build.gradle.kts' line: 3

* What went wrong:
An exception occurred applying plugin request [id: 'dev.flutter.flutter-gradle-plugin']
> Failed to apply plugin 'dev.flutter.flutter-gradle-plugin'.
   > Error: Your project's Kotlin version (2.2.0) is lower than Flutter's minimum supported version of 2.2.20. Please upgrade your Kotlin version. 
     Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

     Potential fix: Your project's KGP version is typically defined in the plugins block of the `settings.gradle` file (/home/runner/work/ezanapp/ezanapp/android/settings.gradle), by a plugin with the id of org.jetbrains.kotlin.android. 
     If you don't see a plugins block, your project was likely created with an older template version, in which case it is most likely defined in the top-level build.gradle file (/home/runner/work/ezanapp/ezanapp/android/build.gradle) by the ext.kotlin_version property.


* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 19s
Running Gradle task 'assembleDebug'...                             80.6s

┌─ Flutter Fix ────────────────────────────────────────────────────────────────────────┐
│ [!] Starting AGP 9+, only the new DSL interface will be read.                        │
│ This results in a build failure when applying the Flutter Gradle plugin at           │
│ /home/runner/work/ezanapp/ezanapp/android/app/build.gradle.kts.                      │
│                                                                                      │
│ To resolve this update flutter or opt out of `android.newDsl`.                       │
│ For instructions on how to opt out, see:                                             │
│ https://developer.android.com/build/releases/agp-9-0-0-release-notes                 │
│                                                                                      │
│ If you are not upgrading to AGP 9+, run `flutter analyze --suggestions` to check for │
│ incompatible dependencies.                                                           │
└──────────────────────────────────────────────────────────────────────────────────────┘
Gradle task assembleDebug failed with exit code 1
```
