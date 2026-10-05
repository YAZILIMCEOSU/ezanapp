# CI raporu (2026-10-05 09:01 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | failure |
| test | failure |
| test (uzak AI sözleşmesi) | failure |
| build (debug apk) | failure |
| build (release appbundle) | failure |

## pubget
```
Resolving dependencies...
Downloading packages...
+ _flutterfire_internals 1.3.77
+ app_links 7.2.1
+ app_links_linux 1.0.3
+ app_links_platform_interface 2.0.4
+ app_links_web 1.0.4
+ args 2.7.0
+ async 2.13.1
+ audio_service 0.18.19
+ audio_service_platform_interface 0.1.3
+ audio_service_web 0.1.4
+ audio_session 0.2.4
+ boolean_selector 2.1.2
+ characters 1.4.1
+ clock 1.1.3
+ cloud_firestore 6.10.0
+ cloud_firestore_platform_interface 8.0.7
+ cloud_firestore_web 5.7.3
+ code_assets 2.1.0
+ collection 1.19.1
+ connectivity_plus 7.3.1 (7.3.2 available)
+ connectivity_plus_platform_interface 2.1.0
+ convert 3.1.2
+ cross_file 0.3.5+5 (0.4.0 available)
+ crypto 3.0.7
+ cupertino_ui 1.1.1
+ dart_jsonwebtoken 3.4.1
+ dbus 0.7.15 (0.8.0 available)
+ device_info_plus 13.3.0
+ device_info_plus_platform_interface 8.1.0
+ equatable 2.1.0 (3.0.0 available)
+ fake_async 1.3.3
+ ffi 2.2.0
+ ffi_leak_tracker 0.1.2
+ file 7.0.1
+ file_selector 1.1.0
+ file_selector_android 0.5.2+11
+ file_selector_ios 0.5.3+6
+ file_selector_linux 0.9.4+1
+ file_selector_macos 0.9.5+1
+ file_selector_platform_interface 2.7.0
+ file_selector_web 0.9.5
+ file_selector_windows 0.9.3+6
+ firebase_analytics 12.6.0
+ firebase_analytics_platform_interface 6.0.7
+ firebase_analytics_web 0.6.1+13
+ firebase_auth 6.7.0
+ firebase_auth_platform_interface 9.1.0
+ firebase_auth_web 6.3.0
+ firebase_core 4.15.0
+ firebase_core_platform_interface 8.1.1
+ firebase_core_web 3.12.0
+ firebase_crashlytics 5.4.0
+ firebase_crashlytics_platform_interface 3.9.0
+ firebase_messaging 16.7.0
+ firebase_messaging_platform_interface 4.10.0
+ firebase_messaging_web 4.2.5
+ firebase_remote_config 6.7.0
+ firebase_remote_config_platform_interface 3.0.7
+ firebase_remote_config_web 1.10.14
+ fixnum 1.1.1
+ fl_chart 1.2.0
+ flutter 0.0.0 from sdk flutter
+ flutter_cache_manager 3.4.5
+ flutter_lints 6.0.0
+ flutter_local_notifications 22.3.1
+ flutter_local_notifications_linux 8.0.1
+ flutter_local_notifications_platform_interface 12.2.0
+ flutter_local_notifications_web 1.0.0
+ flutter_local_notifications_windows 3.1.1
+ flutter_localizations 0.0.0 from sdk flutter
+ flutter_riverpod 3.4.3
+ flutter_secure_storage 11.2.0
+ flutter_secure_storage_darwin 0.4.3
+ flutter_secure_storage_linux 3.0.3
+ flutter_secure_storage_platform_interface 2.1.1
+ flutter_secure_storage_web 2.1.1
+ flutter_secure_storage_windows 4.2.2
+ flutter_test 0.0.0 from sdk flutter
+ flutter_web_plugins 0.0.0 from sdk flutter
+ functions_client 2.7.1
+ geoclue 0.1.1
+ geolocator 14.1.1
+ geolocator_android 5.1.1+1
+ geolocator_apple 2.3.14
+ geolocator_linux 0.2.6
+ geolocator_platform_interface 4.4.0
+ geolocator_web 4.1.4
+ geolocator_windows 0.2.5
+ glob 2.2.0
+ go_router 18.0.2
+ google_mobile_ads 9.1.0
+ gotrue 2.27.2
+ gsettings 0.2.8 (0.2.9 available)
+ gtk 2.2.0
+ hooks 2.2.0
+ http 1.6.0
+ http_parser 4.1.2
+ in_app_purchase 3.3.1
+ in_app_purchase_android 0.5.3
+ in_app_purchase_platform_interface 1.4.1
+ in_app_purchase_storekit 0.4.13
+ intl 0.20.3
+ jni 1.1.0
+ jni_flutter 1.0.3
+ jni_util 1.0.0
+ js 0.7.2
+ json_annotation 4.12.0
+ just_audio 0.10.6
+ just_audio_background 0.0.1-beta.17
+ just_audio_platform_interface 4.6.0
+ just_audio_web 0.4.16
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 6.1.0
+ listen 1.0.1
+ logging 1.3.0
+ matcher 0.12.20
+ material_color_utilities 0.13.0 (0.13.1 available)
+ material_ui 1.5.0
+ meta 1.19.0
+ mime 2.1.0
+ native_toolchain_c 0.19.5
+ nm 0.5.0 (0.6.0 available)
+ objective_c 9.6.2
+ package_config 3.0.0
+ package_info_plus 10.2.2
+ package_info_plus_platform_interface 4.1.0
+ passkeys_platform_interface 2.10.0
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
Nothing to fix!
== dart format ==
Formatted lib/data/ai/ai_service.dart
Formatted 95 files (1 changed) in 0.95 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

  error • The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'. Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation' • lib/data/ai/ai_service.dart:61:18 • undefined_method

1 issue found. (ran in 21.1s)
```

## test
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart
lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
 - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
      } else if (_isHadithCitation(citation)) {
                 ^^^^^^^^^^^^^^^^^
00:00 +0 -1: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
   - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
  Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
        } else if (_isHadithCitation(citation)) {
                   ^^^^^^^^^^^^^^^^^
  .
  Error: The Dart compiler exited unexpectedly.
  package:flutter_tools/src/base/common.dart 34:3  throwToolExit
  package:flutter_tools/src/compile.dart 1024:11   DefaultResidentCompiler._compile.<fn>
  dart:async/zone_root.dart 48:47                  _rootRunUnary
  dart:async/zone.dart 816:35                      _CustomZone.runUnary
  dart:async/future_impl.dart 948:45               Future._propagateToListeners.handleValueCallback
  dart:async/future_impl.dart 977:13               Future._propagateToListeners
  dart:async/future_impl.dart 862:9                Future._propagateToListeners
  dart:async/future_impl.dart 720:5                Future._completeWithValue
  dart:async/future_impl.dart 804:7                Future._asyncCompleteWithValue.<fn>
  dart:async/zone_root.dart 35:13                  _rootRun
  dart:async/zone.dart 810:35                      _CustomZone.run
  dart:async/zone.dart 702:7                       _CustomZone.runGuarded
  dart:async/zone.dart 743:23                      _CustomZone.bindCallbackGuarded.<fn>
  dart:async/schedule_microtask.dart 40:35         _microtaskLoop
  dart:async/schedule_microtask.dart 49:5          _startMicrotaskLoop
  dart:isolate-patch/isolate_patch.dart 127:13     _runPendingImmediateCallback
  dart:isolate-patch/isolate_patch.dart 193:5      _RawReceivePort._handleMessage
  
lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
 - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
      } else if (_isHadithCitation(citation)) {
                 ^^^^^^^^^^^^^^^^^
00:00 +0 -2: loading /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
   - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
  Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
        } else if (_isHadithCitation(citation)) {
                   ^^^^^^^^^^^^^^^^^
  .
00:00 +0 -2: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart [E]
  Error: The Dart compiler exited unexpectedly.
  package:flutter_tools/src/base/common.dart 34:3  throwToolExit
  package:flutter_tools/src/compile.dart 1024:11   DefaultResidentCompiler._compile.<fn>
  dart:async/zone_root.dart 48:47                  _rootRunUnary
  dart:async/zone.dart 816:35                      _CustomZone.runUnary
  dart:async/future_impl.dart 948:45               Future._propagateToListeners.handleValueCallback
  dart:async/future_impl.dart 977:13               Future._propagateToListeners
  dart:async/future_impl.dart 862:9                Future._propagateToListeners
  dart:async/future_impl.dart 720:5                Future._completeWithValue
  dart:async/future_impl.dart 804:7                Future._asyncCompleteWithValue.<fn>
  dart:async/zone_root.dart 35:13                  _rootRun
  dart:async/zone.dart 810:35                      _CustomZone.run
  dart:async/zone.dart 702:7                       _CustomZone.runGuarded
  dart:async/zone.dart 743:23                      _CustomZone.bindCallbackGuarded.<fn>
  dart:async/schedule_microtask.dart 40:35         _microtaskLoop
  dart:async/schedule_microtask.dart 49:5          _startMicrotaskLoop
  dart:isolate-patch/isolate_patch.dart 127:13     _runPendingImmediateCallback
  dart:isolate-patch/isolate_patch.dart 193:5      _RawReceivePort._handleMessage
  
00:00 +0 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings varsayılan ayarlar Diyanet yöntemini kullanır
00:00 +1 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings JSON gidiş-dönüşü değerleri korur
00:00 +2 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings bozuk yedek varsayılanlara döner
00:00 +3 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings Hanefî ikindi yalnızca desteklenen yöntemlerde uygulanır
00:00 +4 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings manuel düzeltmeler her yöntemde aktarılır
00:00 +5 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod bilinmeyen kimlik Diyanet'e döner
00:00 +6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod tüm yöntemler geçerli açılara sahip
00:00 +7 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe yönü Türkiye için güneydoğuyu gösterir
00:00 +8 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe koordinatında mesafe sıfıra yakındır
00:00 +9 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils İstanbul-Kâbe mesafesi ~2400 km
00:00 +10 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (setUpAll)
00:00 +10 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar bugünü hicri tarihe çevirir
00:00 +11 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar gün farkı hesabı ve geri dönüş tutarlı
00:00 +12 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar ay uzunluğu 29 veya 30 gündür
00:00 +13 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar Ramazan başlangıcı hicri 9. ayın 1. günüdür
00:00 +14 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (tearDownAll)
00:00 +14 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sıralı veri sağlıklı kabul edilir
00:00 +15 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:00 +16 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay bozuk veri sağlıksız kabul edilir
00:00 +17 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
00:01 +18 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
00:01 +19 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
00:01 +20 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer ekleri kaba biçimde kırpar
00:01 +21 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer eşleştirme aksan ve ek farklarını tolere eder
00:01 +22 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Arapça harekeleri kaldırır
00:01 +23 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer yüzde biçimi
00:01 +24 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime geri sayım ve dijital sayaç biçimi
00:01 +25 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime 24 saat ve 12 saat biçimi
00:01 +26 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime gün karşılaştırması
00:01 +27 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:01 +27 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: doğrulama verisi yüklendi
00:01 +28 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±3 dakika içinde kalır
00:01 +29 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada
00:01 +30 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: Hanefî ikindi vakti Şâfiî'den sonra olur
00:01 +31 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:01 +32 -2: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (tearDownAll)
00:01 +32 -2: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart
```

## ai
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart
lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
 - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
      } else if (_isHadithCitation(citation)) {
                 ^^^^^^^^^^^^^^^^^
00:00 +0 -1: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
   - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
  Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
        } else if (_isHadithCitation(citation)) {
                   ^^^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart
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
lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
 - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
      } else if (_isHadithCitation(citation)) {
                 ^^^^^^^^^^^^^^^^^
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Target kernel_snapshot_program failed: Exception

Checking the license for package CMake 3.22.1 in /usr/local/lib/android/sdk/licenses
License for package CMake 3.22.1 accepted.
Preparing "Install CMake 3.22.1 v.3.22.1".
"Install CMake 3.22.1 v.3.22.1" ready.
Installing CMake 3.22.1 in /usr/local/lib/android/sdk/cmake/3.22.1
"Install CMake 3.22.1 v.3.22.1" complete.
"Install CMake 3.22.1 v.3.22.1" finished.

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.6-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 4m 16s
Running Gradle task 'assembleDebug'...                            257.9s
Gradle task assembleDebug failed with exit code 1
```

## release
```
Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 30 days
	for: CN=EzanAI CI, OU=QA, O=Yazilimceosu, L=Istanbul, C=TR
[Storing /home/runner/work/_temp/ci-release.jks]
Running Gradle task 'bundleRelease'...                          
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
lib/data/ai/ai_service.dart:61:18: Error: The method '_isHadithCitation' isn't defined for the type 'LocalKnowledgeSource'.
 - 'LocalKnowledgeSource' is from 'package:ezanai/data/ai/ai_service.dart' ('lib/data/ai/ai_service.dart').
Try correcting the name to the name of an existing method, or defining a method named '_isHadithCitation'.
      } else if (_isHadithCitation(citation)) {
                 ^^^^^^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.6-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 17s
Running Gradle task 'bundleRelease'...                             77.8s
Gradle task bundleRelease failed with exit code 1
```
