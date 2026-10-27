# CI raporu (2026-10-27 07:17 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | failure |
| test | failure |
| test (uzak AI sözleşmesi) | success |
| build (debug apk) | failure |
| build (release appbundle) | failure |
| dene-apk indirmeye açıldı | skipped |

## pubget
```
Resolving dependencies...
Downloading packages...
+ _flutterfire_internals 1.3.77 (1.3.79 available)
+ app_links 7.2.2
+ app_links_linux 1.0.4
+ app_links_platform_interface 2.0.4
+ app_links_web 1.0.5
+ args 2.7.0
+ async 2.13.1
+ audio_service 0.18.19
+ audio_service_platform_interface 0.1.3
+ audio_service_web 0.1.4
+ audio_session 0.2.4
+ boolean_selector 2.1.2
+ characters 1.4.1
+ clock 1.1.3
+ code_assets 2.1.0
+ collection 1.19.1
+ connectivity_plus 7.3.1 (7.3.2 available)
+ connectivity_plus_platform_interface 2.1.0
+ convert 3.1.2
+ cross_file 0.3.5+5 (0.4.0 available)
+ crypto 3.0.8
+ cupertino_ui 1.1.4
+ dart_jsonwebtoken 3.4.1
+ dbus 0.7.15 (0.8.0 available)
+ device_info_plus 13.3.0
+ device_info_plus_platform_interface 8.1.0
+ equatable 3.0.0
+ fake_async 1.3.3
+ ffi 2.2.0
+ ffi_leak_tracker 0.1.2
+ file 7.0.1
+ file_selector 1.1.0
+ file_selector_android 0.5.2+11
+ file_selector_ios 0.5.3+7
+ file_selector_linux 0.9.4+1
+ file_selector_macos 0.9.5+2
+ file_selector_platform_interface 2.7.0
+ file_selector_web 0.9.5
+ file_selector_windows 0.9.3+6
+ firebase_core 4.15.2 (5.1.0 available)
+ firebase_core_platform_interface 8.1.1
+ firebase_core_web 3.12.0 (4.1.0 available)
+ firebase_messaging 16.7.1 (17.0.1 available)
+ firebase_messaging_platform_interface 4.10.0 (4.11.1 available)
+ firebase_messaging_web 4.2.5 (4.3.1 available)
+ fixnum 1.1.1
+ fl_chart 1.3.0
+ flutter 0.0.0 from sdk flutter
+ flutter_cache_manager 3.4.5
+ flutter_lints 6.0.0
+ flutter_local_notifications 22.3.3
+ flutter_local_notifications_linux 8.0.2
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
+ geolocator 14.1.2
+ geolocator_android 5.2.1
+ geolocator_apple 2.4.3
+ geolocator_linux 0.2.6
+ geolocator_platform_interface 4.4.1
+ geolocator_web 4.1.4
+ geolocator_windows 0.2.5
+ glob 2.2.0
+ go_router 18.1.1
+ google_mobile_ads 9.2.0
+ gotrue 2.27.3
+ gsettings 0.2.8 (0.2.9 available)
+ hooks 2.2.0
+ http 1.6.0
+ http_parser 4.1.2
+ in_app_purchase 3.3.1
+ in_app_purchase_android 0.5.5
+ in_app_purchase_platform_interface 1.4.1
+ in_app_purchase_storekit 0.4.15
+ intl 0.20.3
+ jni 1.1.0
+ jni_flutter 1.0.4+1
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
+ material_ui 1.8.0
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
+ realtime_client 2.13.2
+ record_use 1.1.1
+ riverpod 3.4.3
+ rxdart 0.28.0
+ scrollable_positioned_list 0.3.8
+ share_plus 13.3.1
+ share_plus_platform_interface 7.2.0
+ shared_preferences 2.5.6
+ shared_preferences_android 2.5.4
+ shared_preferences_foundation 2.6.1
+ shared_preferences_linux 2.4.1
+ shared_preferences_platform_interface 2.4.2
+ shared_preferences_web 2.4.3
+ shared_preferences_windows 2.4.1
+ sky_engine 0.0.0 from sdk flutter
+ source_span 1.10.2
+ sqflite 2.4.5
+ sqflite_android 2.4.5
+ sqflite_common 2.5.14
+ sqflite_common_ffi 2.4.5
+ sqflite_darwin 2.4.4+1
+ sqflite_platform_interface 2.4.3
+ sqlite3 3.8.0
+ stack_trace 1.12.2
+ state_notifier 1.0.0
+ storage_client 2.8.1
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ supabase 2.16.5
+ supabase_common 0.1.2
+ supabase_flutter 2.18.3
+ synchronized 3.5.0
+ term_glyph 1.2.2
+ test_api 0.7.12 (0.7.15 available)
+ timezone 0.11.2
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
+ vector_math 2.4.4
+ vibration 3.2.1
+ vibration_platform_interface 0.1.2
+ vm_service 15.4.0
+ web 1.1.2
+ web_socket 1.0.1
+ web_socket_channel 3.0.3
+ webview_flutter 4.14.1
+ webview_flutter_android 4.14.1
+ webview_flutter_platform_interface 2.15.1
+ webview_flutter_wkwebview 3.27.2
+ win32 6.4.0
+ win32_registry 3.0.3
+ xdg_directories 1.1.0
+ xml 7.1.0
+ yaml 3.1.4
+ yet_another_json_isolate 2.1.1
Changed 190 dependencies!
13 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Upgrading analysis_options.yaml to exclude build and platform directories.
```

## fmt
```
== dart fix --apply ==
Computing fixes in ezanapp...
Applying fixes...

lib/app/app_runtime.dart
  body_might_complete_normally_nullable - 1 fix

lib/core/services/ads_service.dart
  directives_ordering - 1 fix

lib/core/utils/wmm.dart
  prefer_const_declarations - 6 fixes

test/data/ads_test.dart
  directives_ordering - 1 fix

test/data/qibla_verification_test.dart
  directives_ordering - 1 fix

10 fixes made in 5 files.
== dart format ==
Formatted lib/core/ads/ads_consent.dart
Formatted lib/core/services/ads_service.dart
Formatted lib/core/utils/qibla_math.dart
Formatted lib/core/utils/wmm.dart
Formatted lib/features/zikir/zikir_screen.dart
Formatted test/data/qibla_verification_test.dart
Formatted 117 files (6 changed) in 1.31 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

  error • The constructor being called isn't a const constructor. Try removing 'const' from the constructor invocation • lib/core/ads/ads_consent.dart:52:9 • const_with_non_const
  error • Undefined name 'isFinite'. Try correcting the name to one that is defined, or defining the name • test/data/qibla_verification_test.dart:89:61 • undefined_identifier
  error • Undefined name 'isFinite'. Try correcting the name to one that is defined, or defining the name • test/data/qibla_verification_test.dart:90:61 • undefined_identifier
  error • Undefined name 'isFinite'. Try correcting the name to one that is defined, or defining the name • test/data/qibla_verification_test.dart:93:60 • undefined_identifier
  error • Undefined name 'isFinite'. Try correcting the name to one that is defined, or defining the name • test/data/qibla_verification_test.dart:94:63 • undefined_identifier
  error • Undefined name 'isFinite'. Try correcting the name to one that is defined, or defining the name • test/data/qibla_verification_test.dart:132:64 • undefined_identifier

6 issues found. (ran in 20.2s)
```

## test
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart
lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
Try using a constructor or factory that is 'const'.
        const ConsentRequestParameters(),
              ^^^^^^^^^^^^^^^^^^^^^^^^
00:00 +0 -1: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
  Try using a constructor or factory that is 'const'.
          const ConsentRequestParameters(),
                ^^^^^^^^^^^^^^^^^^^^^^^^
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
  
lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
Try using a constructor or factory that is 'const'.
        const ConsentRequestParameters(),
              ^^^^^^^^^^^^^^^^^^^^^^^^
00:00 +0 -2: loading /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
  Try using a constructor or factory that is 'const'.
          const ConsentRequestParameters(),
                ^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:00 +0 -2: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
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
  
00:00 +0 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
00:00 +1 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
00:00 +2 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer ekleri kaba biçimde kırpar
00:00 +3 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer eşleştirme aksan ve ek farklarını tolere eder
00:00 +4 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Arapça harekeleri kaldırır
00:00 +5 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer yüzde biçimi
00:00 +6 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime geri sayım ve dijital sayaç biçimi
00:00 +7 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime 24 saat ve 12 saat biçimi
00:00 +8 -2: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime gün karşılaştırması
00:00 +9 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri yedi gün × altı vakit için kimlikler benzersiz
00:00 +10 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri kimlikler ilgili aralıkta kalır
00:00 +11 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri vakit kimlikleri tekil bildirim kimlikleriyle çakışmaz
00:00 +12 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim yönlendirme yükü her hedef kendi yüküyle ayrışır
00:00 +13 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim yönlendirme yükü ayrıntılı yükler ve tanımsız yükler güvenli
00:00 +14 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları varsayılan olarak güneş vakti bildirilmez
00:00 +15 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları kullanıcı bir vakti kapatabilir
00:00 +16 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları bildirimler tümden kapatılınca hiçbir vakit bildirilmez
00:00 +17 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları eksik ayar güvenli tarafta kalır (kapalı sayılır)
00:00 +18 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu varsayılan sessiz saat kapalı
00:00 +19 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu sessiz saat aralığı gece yarısını aşabilir
00:00 +20 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu uyku modu 22:00–07:00 arasını kapsar
00:00 +21 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu öğle vakti sessiz saate girmez
00:00 +22 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı ön hatırlatma varsayılan olarak kapalı
00:00 +23 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı ön hatırlatma dakikası ayarlanabilir
00:00 +24 -2: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı zamanlanan gün sayısı makul aralıkta
lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
Try using a constructor or factory that is 'const'.
        const ConsentRequestParameters(),
              ^^^^^^^^^^^^^^^^^^^^^^^^
00:11 +25 -3: loading /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
  Try using a constructor or factory that is 'const'.
          const ConsentRequestParameters(),
                ^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:11 +25 -3: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
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
  
00:13 +25 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings varsayılan ayarlar Diyanet yöntemini kullanır
00:13 +26 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings JSON gidiş-dönüşü değerleri korur
00:13 +27 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings bozuk yedek varsayılanlara döner
00:13 +28 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings Hanefî ikindi yalnızca desteklenen yöntemlerde uygulanır
00:13 +29 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings manuel düzeltmeler her yöntemde aktarılır
00:13 +30 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod bilinmeyen kimlik Diyanet'e döner
00:13 +31 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod tüm yöntemler geçerli açılara sahip
00:13 +32 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe yönü Türkiye için güneydoğuyu gösterir
00:13 +33 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe koordinatında mesafe sıfıra yakındır
00:13 +34 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils İstanbul-Kâbe mesafesi ~2400 km
00:13 +35 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (setUpAll)
00:13 +35 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar bugünü hicri tarihe çevirir
00:13 +36 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar gün farkı hesabı ve geri dönüş tutarlı
00:13 +37 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar ay uzunluğu 29 veya 30 gündür
00:13 +38 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar Ramazan başlangıcı hicri 9. ayın 1. günüdür
00:13 +39 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (tearDownAll)
00:13 +39 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sıralı veri sağlıklı kabul edilir
00:13 +40 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:13 +41 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay bozuk veri sağlıksız kabul edilir
00:13 +42 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
test/data/qibla_verification_test.dart:89:61: Error: Undefined name 'isFinite'.
      expect(Wmm2025.declinationAtYear(41.0, 29.0, 2400.0), isFinite);
                                                            ^^^^^^^^
test/data/qibla_verification_test.dart:90:61: Error: Undefined name 'isFinite'.
      expect(Wmm2025.declinationAtYear(41.0, 29.0, 1980.0), isFinite);
                                                            ^^^^^^^^
test/data/qibla_verification_test.dart:93:60: Error: Undefined name 'isFinite'.
      expect(Wmm2025.declinationAtYear(89.9, 0.0, 2026.0), isFinite);
                                                           ^^^^^^^^
test/data/qibla_verification_test.dart:94:63: Error: Undefined name 'isFinite'.
      expect(Wmm2025.declinationAtYear(-89.9, 180.0, 2026.0), isFinite);
                                                              ^^^^^^^^
test/data/qibla_verification_test.dart:132:64: Error: Undefined name 'isFinite'.
      expect(GeoUtils.qiblaBearing(-21.4224779, -140.1748168), isFinite);
                                                               ^^^^^^^^
00:13 +43 -4: loading /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: test/data/qibla_verification_test.dart:89:61: Error: Undefined name 'isFinite'.
        expect(Wmm2025.declinationAtYear(41.0, 29.0, 2400.0), isFinite);
                                                              ^^^^^^^^
  test/data/qibla_verification_test.dart:90:61: Error: Undefined name 'isFinite'.
        expect(Wmm2025.declinationAtYear(41.0, 29.0, 1980.0), isFinite);
                                                              ^^^^^^^^
  test/data/qibla_verification_test.dart:93:60: Error: Undefined name 'isFinite'.
        expect(Wmm2025.declinationAtYear(89.9, 0.0, 2026.0), isFinite);
                                                             ^^^^^^^^
  test/data/qibla_verification_test.dart:94:63: Error: Undefined name 'isFinite'.
        expect(Wmm2025.declinationAtYear(-89.9, 180.0, 2026.0), isFinite);
                                                                ^^^^^^^^
  test/data/qibla_verification_test.dart:132:64: Error: Undefined name 'isFinite'.
        expect(GeoUtils.qiblaBearing(-21.4224779, -140.1748168), isFinite);
                                                                 ^^^^^^^^
  .
00:13 +43 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı en az 20 kayıt ve benzersiz kimlikler
00:13 +43 -4: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
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
  
00:13 +44 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı her kayıtta başlık, cevap, anahtar kelime ve kaynak var
00:13 +45 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler küçük harf ve ASCII (arama uyumu)
00:13 +46 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler yeterince ayırt edici
00:13 +47 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı ilişkili kayıt kimlikleri geçerli
00:13 +48 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı mezhep farkı notları en az birkaç kayıtta bulunur
00:13 +49 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı kaynak künyeleri kaynak türüne ayrılabiliyor
00:13 +50 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi namaz rekatı sorusu doğru kayda gider
00:13 +51 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi abdest sorusu doğru kayda gider
00:13 +52 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi zekât sorusu doğru kayda gider
00:13 +53 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kıble sorusu doğru kayda gider
00:13 +54 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz
00:13 +55 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır
00:13 +56 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi konu kelimesi genel kelimelere üstün gelir (vitir/teravih)
00:13 +57 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi ayırt edici kelime puanı, genel kelimelerden yüksektir
00:13 +58 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi harf düşmesi olan sorular da eşleşir (hatim → hatmi)
00:13 +59 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Kâbe yönü sorusu kıble kaydına gider
00:13 +60 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi önerilen sorular kimlik değil, okunabilir başlık olarak döner
00:13 +61 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kayda uymayan soru için uydurma cevap üretilmez
00:13 +62 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi soru boşsa eşleşme yapılmaz
00:13 +63 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi paylaşım metni kaynakları ve mezhep notlarını içerir
00:13 +64 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İslam'ın şartları sorusuna beş şartı doğru sırayla ve kaynaklı cevaplar
00:13 +65 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:13 +66 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir
lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
Try using a constructor or factory that is 'const'.
        const ConsentRequestParameters(),
              ^^^^^^^^^^^^^^^^^^^^^^^^
00:15 +67 -5: loading /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
  Try using a constructor or factory that is 'const'.
          const ConsentRequestParameters(),
                ^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:15 +67 -5: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
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
  
00:16 +67 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:16 +68 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
00:16 +69 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaklı uzak yanıt kabul edilir
  Skip: EZANAI_API_BASE tanımlı değil
00:16 +69 ~1 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaksız uzak yanıt reddedilir, yerel tabana düşülür
  Skip: EZANAI_API_BASE tanımlı değil
00:16 +69 ~2 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında sunucu hatasında (500) uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:16 +69 ~3 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bozuk JSON yanıtında uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:16 +69 ~4 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap
  Skip: EZANAI_API_BASE tanımlı değil
00:16 +69 ~5 -5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında uzak yanıtlara da öneri soruları eklenir
  Skip: EZANAI_API_BASE tanımlı değil
lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
Try using a constructor or factory that is 'const'.
        const ConsentRequestParameters(),
              ^^^^^^^^^^^^^^^^^^^^^^^^
00:27 +69 ~6 -6: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
  Try using a constructor or factory that is 'const'.
          const ConsentRequestParameters(),
                ^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:27 +69 ~6 -6: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
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
  
00:29 +69 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli JSON ayrıştırma tüm alanları okur
00:29 +70 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli eksik alanlar çökmez, kategori varsayılana düşer
00:29 +71 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli kaynak künyesi paylaşım metninde yer alır
00:29 +72 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli paylaşım metni Arapça, okunuş ve meali içerir
00:29 +73 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli Arapçası olmayan dua bile okunabilir paylaşılır
00:29 +74 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli arama diakritik ve büyük harf duyarsız
00:29 +75 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli künye metni de aranabilir
00:29 +76 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kategoriye göre süzer
00:29 +77 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş sorgu tüm listeyi döner
00:29 +78 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog sorguya göre süzer
00:29 +79 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kimliğe göre bulur
00:29 +80 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş katalog güvenli
00:29 +81 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:29 +81 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kategoriler tanımlı ve benzersiz
00:29 +82 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: en az 30 dua var ve kimlikler benzersiz
00:29 +83 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada ad, okunuş, meal ve kategori dolu
00:29 +84 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada kaynak künyesi var
00:29 +85 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kaynak künyeleri ya Kur'an ya muteber hadis kaynağına dayanır
00:29 +86 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duanın kategorisi kategori listesinde tanımlı
00:29 +87 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her kategoride en az bir dua var (boş sekme olmasın)
00:29 +88 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Kur'an kaynaklı duaların künyesi sure/ayet içerir
00:29 +89 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Arapça metin içeren dualar Arapça alfabede
00:29 +90 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: katalogda arama ve kategori süzme çalışıyor
00:29 +91 ~6 -6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (tearDownAll)
lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
Try using a constructor or factory that is 'const'.
        const ConsentRequestParameters(),
              ^^^^^^^^^^^^^^^^^^^^^^^^
00:40 +91 ~6 -7: loading /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: lib/core/ads/ads_consent.dart:52:15: Error: Cannot invoke a non-'const' constructor where a const expression is expected.
  Try using a constructor or factory that is 'const'.
          const ConsentRequestParameters(),
                ^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:40 +91 ~6 -7: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
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
  
00:41 +91 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:41 +91 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: doğrulama verisi yüklendi
00:41 +92 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±3 dakika içinde kalır
00:41 +93 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada
00:41 +94 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: Hanefî ikindi vakti Şâfiî'den sonra olur
00:41 +95 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:41 +96 ~6 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (tearDownAll)
00:41 +96 ~6 -7: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart
  ... and 3 more
```

## ai
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart
00:00 +0: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
  Skip: Bu koşuda backend adresi tanımlı
00:00 +0 ~1: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
  Skip: Bu koşuda backend adresi tanımlı
00:00 +0 ~2: backend yapılandırıldığında kaynaklı uzak yanıt kabul edilir
00:00 +1 ~2: backend yapılandırıldığında kaynaksız uzak yanıt reddedilir, yerel tabana düşülür
00:00 +2 ~2: backend yapılandırıldığında sunucu hatasında (500) uygulama çökmez
00:00 +3 ~2: backend yapılandırıldığında bozuk JSON yanıtında uygulama çökmez
00:00 +4 ~2: backend yapılandırıldığında bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap
00:00 +5 ~2: backend yapılandırıldığında uzak yanıtlara da öneri soruları eklenir
00:00 +6 ~2: All tests passed!
```

## build
```
Generating 2048-bit RSA key pair and self-signed certificate (SHA384withRSA) with a validity of 30 days
	for: CN=EzanAI CI, OU=QA, O=Yazilimceosu, L=Istanbul, C=TR
[Storing /home/runner/work/_temp/ci-release.jks]
Upgrading build.gradle.kts
Upgrading gradle.properties
Upgrading gradle.properties
Running Gradle task 'assembleRelease'...                        
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/home/runner/.gradle/wrapper/dists/gradle-8.14.3-all/10utluxaxniiv4wxiphsi49nj/gradle-8.14.3/lib/native-platform-0.22-milestone-28.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled


FAILURE: Build failed with an exception.

* What went wrong:
25.0.4.1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 21s
Running Gradle task 'assembleRelease'...                           22.1s
Gradle build failed due to Java/Gradle incompatibility.
The Java version used for the build is 25.0.4, which is incompatible with Gradle 8.14.3.
To fix this, you can either:
  1. Upgrade your project's Gradle version (typically in gradle-wrapper.properties to a version matching the range: compatible Gradle versions for Java 25.0.4 are 9.1.0 or newer).
  2. Use a different Java version for Flutter by running `flutter config --jdk-dir=<path>`.
```

## release
```
Running Gradle task 'bundleRelease'...                          
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/home/runner/.gradle/wrapper/dists/gradle-8.14.3-all/10utluxaxniiv4wxiphsi49nj/gradle-8.14.3/lib/native-platform-0.22-milestone-28.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled


FAILURE: Build failed with an exception.

* What went wrong:
25.0.4.1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 757ms
Running Gradle task 'bundleRelease'...                             882ms
Gradle build failed due to Java/Gradle incompatibility.
The Java version used for the build is 25.0.4, which is incompatible with Gradle 8.14.3.
To fix this, you can either:
  1. Upgrade your project's Gradle version (typically in gradle-wrapper.properties to a version matching the range: compatible Gradle versions for Java 25.0.4 are 9.1.0 or newer).
  2. Use a different Java version for Flutter by running `flutter config --jdk-dir=<path>`.
```
