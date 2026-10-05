# CI raporu (2026-10-05 07:28 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | failure |
| test | failure |
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
Changed 205 dependencies!
8 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Upgrading analysis_options.yaml to exclude build and platform directories.
```

## fmt
```
== dart fix --apply ==
Computing fixes in ezanapp...
Applying fixes...

lib/core/services/push_service.dart
  prefer_initializing_formals - 1 fix

lib/core/utils/app_time.dart
  unused_import - 1 fix

lib/data/models/app_settings.dart
  directives_ordering - 1 fix

lib/features/ai/ai_screen.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/features/ilahi/player_controller.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/features/more/more_screen.dart
  curly_braces_in_flow_control_structures - 1 fix

lib/features/settings/about_screen.dart
  curly_braces_in_flow_control_structures - 1 fix

test/prayer_calculation_test.dart
  prefer_const_declarations - 1 fix
  unnecessary_brace_in_string_interps - 1 fix

9 fixes made in 8 files.
== dart format ==
Formatted lib/core/services/push_service.dart
Formatted lib/core/services/sync_service.dart
Formatted lib/core/utils/app_time.dart
Formatted lib/features/quran/surah_screen.dart
Formatted lib/features/settings/backup_screen.dart
Formatted test/core/text_normalizer_test.dart
Formatted test/data/models_test.dart
Formatted 93 files (7 changed) in 0.53 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check. Guard a 'State.context' use with a 'mounted' check on the State, and other BuildContext use with a 'mounted' check on the BuildContext • lib/features/settings/notification_settings_screen.dart:345:36 • use_build_context_synchronously
  error • A value of type 'dynamic' can't be assigned to a variable of type 'Object'. Try changing the type of the variable, or casting the right-hand type to 'Object' • test/prayer_calculation_test.dart:22:28 • invalid_assignment

2 issues found. (ran in 14.6s)
```

## test
```
  package:flutter/src/services/asset_bundle.dart 328:54  PlatformAssetBundle.load
  package:flutter/src/services/asset_bundle.dart 92:33   AssetBundle.loadString
  package:flutter/src/services/asset_bundle.dart 193:56  CachingAssetBundle.loadString.<fn>
  dart:_compact_hash                                     _LinkedHashMapMixin.putIfAbsent
  package:flutter/src/services/asset_bundle.dart 193:27  CachingAssetBundle.loadString
  package:ezanai/data/hijri/hijri_calendar.dart 33:37    HijriCalendar.load
  test/data/models_test.dart 116:38                      main.<fn>.<fn>
  
00:00 +9 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
00:00 +10 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
00:00 +11 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:00 +12 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
00:00 +13 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
00:00 +14 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
00:00 +15 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
00:00 +16 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer eşleştirme aksan ve ek farklarını tolere eder
00:00 +17 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Arapça harekeleri kaldırır
00:00 +18 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer yüzde biçimi
00:00 +19 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime geri sayım ve dijital sayaç biçimi
00:00 +20 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime 24 saat ve 12 saat biçimi
00:00 +21 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime gün karşılaştırması
00:00 +22 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:00 +22 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: doğrulama verisi yüklendi
00:00 +23 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±4 dakika içinde kalır
00:00 +23 -3: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±4 dakika içinde kalır [E]
  Expected: empty
    Actual: [
              'Adana 2022-01-15 imsak: hesap 06:20, Diyanet 06:20 (21240.1 dk)',
              'Adana 2022-01-15 gunes: hesap 07:36, Diyanet 07:44 (24787.7 dk)',
              'Adana 2022-01-15 ogle: hesap 12:53, Diyanet 12:53 (42479.5 dk)',
              'Adana 2022-01-15 ikindi: hesap 15:31, Diyanet 15:30 (53099.3 dk)',
              'Adana 2022-01-15 aksam: hesap 18:02, Diyanet 17:52 (60170.3 dk)',
              'Adana 2022-01-15 yatsi: hesap 19:13, Diyanet 19:11 (67258.1 dk)',
              'Adana 2022-03-21 imsak: hesap 05:14, Diyanet 05:15 (17700.7 dk)',
              'Adana 2022-03-21 gunes: hesap 06:26, Diyanet 06:34 (21247.8 dk)',
              'Adana 2022-03-21 ogle: hesap 12:51, Diyanet 12:51 (42479.7 dk)',
              'Adana 2022-03-21 ikindi: hesap 16:18, Diyanet 16:17 (56639.5 dk)',
              'Adana 2022-03-21 aksam: hesap 19:07, Diyanet 18:58 (63710.6 dk)',
              'Adana 2022-03-21 yatsi: hesap 20:14, Diyanet 20:12 (70797.9 dk)',
              'Adana 2022-06-21 imsak: hesap 03:27, Diyanet 03:27 (10619.6 dk)',
              'Adana 2022-06-21 gunes: hesap 05:05, Diyanet 05:12 (17707.0 dk)',
              'Adana 2022-06-21 ogle: hesap 12:46, Diyanet 12:45 (42479.1 dk)',
              'Adana 2022-06-21 ikindi: hesap 16:37, Diyanet 16:37 (56640.1 dk)',
              'Adana 2022-06-21 aksam: hesap 20:18, Diyanet 20:09 (70791.1 dk)',
              'Adana 2022-06-21 yatsi: hesap 21:48, Diyanet 21:46 (74338.3 dk)',
              'Adana 2022-09-23 imsak: hesap 05:01, Diyanet 05:00 (17699.0 dk)',
              'Adana 2022-09-23 gunes: hesap 06:13, Diyanet 06:20 (21247.2 dk)',
              'Adana 2022-09-23 ogle: hesap 12:37, Diyanet 12:36 (42479.5 dk)',
              'Adana 2022-09-23 ikindi: hesap 16:02, Diyanet 16:02 (56640.1 dk)',
              'Adana 2022-09-23 aksam: hesap 18:51, Diyanet 18:42 (63710.7 dk)',
              'Adana 2022-09-23 yatsi: hesap 19:58, Diyanet 19:57 (67259.1 dk)',
              ...
            ]
  Adana 2022-01-15 imsak: hesap 06:20, Diyanet 06:20 (21240.1 dk)
  Adana 2022-01-15 gunes: hesap 07:36, Diyanet 07:44 (24787.7 dk)
  Adana 2022-01-15 ogle: hesap 12:53, Diyanet 12:53 (42479.5 dk)
  Adana 2022-01-15 ikindi: hesap 15:31, Diyanet 15:30 (53099.3 dk)
  Adana 2022-01-15 aksam: hesap 18:02, Diyanet 17:52 (60170.3 dk)
  Adana 2022-01-15 yatsi: hesap 19:13, Diyanet 19:11 (67258.1 dk)
  Adana 2022-03-21 imsak: hesap 05:14, Diyanet 05:15 (17700.7 dk)
  Adana 2022-03-21 gunes: hesap 06:26, Diyanet 06:34 (21247.8 dk)
  Adana 2022-03-21 ogle: hesap 12:51, Diyanet 12:51 (42479.7 dk)
  Adana 2022-03-21 ikindi: hesap 16:18, Diyanet 16:17 (56639.5 dk)
  Adana 2022-03-21 aksam: hesap 19:07, Diyanet 18:58 (63710.6 dk)
  Adana 2022-03-21 yatsi: hesap 20:14, Diyanet 20:12 (70797.9 dk)
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/prayer_calculation_test.dart 94:5              main.<fn>
  
00:00 +23 -3: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada
00:00 +24 -3: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: Hanefî ikindi vakti Şâfiî'den sonra olur
00:00 +25 -3: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:00 +26 -3: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (tearDownAll)
00:00 +26 -3: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod tüm yöntemler geçerli açılara sahip
  /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (setUpAll)
  /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±4 dakika içinde kalır
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

Warning: Flutter support for your project's Kotlin version (2.2.20) will soon be dropped. Please upgrade your Kotlin version to a version of at least 2.3.20 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's KGP version is typically defined in the plugins block of the `settings.gradle` file (/home/runner/work/ezanapp/ezanapp/android/settings.gradle), by a plugin with the id of org.jetbrains.kotlin.android. 
If you don't see a plugins block, your project was likely created with an older template version, in which case it is most likely defined in the top-level build.gradle file (/home/runner/work/ezanapp/ezanapp/android/build.gradle) by the ext.kotlin_version property.

Note: /home/runner/.pub-cache/hosted/pub.dev/cloud_firestore-6.10.0/android/src/main/java/io/flutter/plugins/firebase/firestore/utils/PipelineStageHandlers.java uses unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: /home/runner/.pub-cache/hosted/pub.dev/geolocator_android-5.1.1+1/android/src/main/java/com/baseflow/geolocator/location/LocationMapper.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Checking the license for package CMake 3.22.1 in /usr/local/lib/android/sdk/licenses
License for package CMake 3.22.1 accepted.
Preparing "Install CMake 3.22.1 v.3.22.1".
"Install CMake 3.22.1 v.3.22.1" ready.
Installing CMake 3.22.1 in /usr/local/lib/android/sdk/cmake/3.22.1
"Install CMake 3.22.1 v.3.22.1" complete.
"Install CMake 3.22.1 v.3.22.1" finished.
/home/runner/work/ezanapp/ezanapp/android/app/src/debug/AndroidManifest.xml:4:9-44 Error:
	Attribute application@usesCleartextTraffic value=(true) from AndroidManifest.xml:4:9-44
	is also present at AndroidManifest.xml:39:9-45 value=(false).
	Suggestion: add 'tools:replace="android:usesCleartextTraffic"' to <application> element at AndroidManifest.xml:3:5-6:58 to override.

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:processDebugMainManifest'.
> Manifest merger failed : Attribute application@usesCleartextTraffic value=(true) from AndroidManifest.xml:4:9-44
  	is also present at AndroidManifest.xml:39:9-45 value=(false).
  	Suggestion: add 'tools:replace="android:usesCleartextTraffic"' to <application> element at AndroidManifest.xml:3:5-6:58 to override.

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 3m 27s
Running Gradle task 'assembleDebug'...                            207.9s
Gradle task assembleDebug failed with exit code 1
```
