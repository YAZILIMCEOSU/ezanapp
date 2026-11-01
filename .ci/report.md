# CI raporu (2026-11-01 14:25 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | failure |
| test | failure |
| test (uzak AI sözleşmesi) | success |
| kıble doğrulaması (6 kontrol) | success |
| imza doğrulaması (apksigner) | skipped |
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
+ cupertino_ui 1.1.5
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
+ flutter_cache_manager 3.4.6
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
+ go_router 18.1.2
+ google_mobile_ads 9.2.0
+ gotrue 2.27.3
+ gsettings 0.2.8 (0.2.9 available)
+ hooks 2.2.0
+ http 1.6.0
+ http_parser 4.1.2
+ in_app_purchase 3.3.1
+ in_app_purchase_android 0.5.5
+ in_app_purchase_platform_interface 1.4.1
+ in_app_purchase_storekit 0.4.16
+ intl 0.20.3
+ jni 1.1.1
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
+ material_ui 1.9.0
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

lib/features/settings/prayer_verify_screen.dart
  prefer_const_constructors - 1 fix

1 fix made in 1 file.
== dart format ==
Formatted lib/core/services/location_service.dart
Formatted lib/data/prayer/aladhan_api_source.dart
Formatted lib/data/prayer/prayer_times_repository.dart
Formatted lib/features/home/home_screen.dart
Formatted lib/features/settings/prayer_verify_screen.dart
Formatted lib/features/settings/settings_screen.dart
Formatted lib/features/widgets/prayer_widgets.dart
Formatted lib/state/providers.dart
Formatted test/data/prayer_time_fidelity_test.dart
Formatted 133 files (9 changed) in 1.09 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

  error • The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'. Try importing the library that defines 'valueOrNull', correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull' • lib/features/settings/prayer_verify_screen.dart:205:53 • undefined_getter
  error • The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'. Try importing the library that defines 'valueOrNull', correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull' • lib/features/settings/prayer_verify_screen.dart:237:62 • undefined_getter

2 issues found. (ran in 18.9s)
```

## test
```
00:12 +27 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 3. Tutuş ağırlığı ve etiketleri Eğim (tilt) tutuş açısıyla birebir
00:12 +28 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 3. Tutuş ağırlığı ve etiketleri Geçersiz matris null döner
00:12 +29 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 4. Ekran dönüşü (yatay tutuş) eksen eşlemesi Dört ekran yönü de tanımlı ve birbirinden farklı
00:12 +30 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 4. Ekran dönüşü (yatay tutuş) eksen eşlemesi Dikey ekran için AXIS_X / AXIS_Y
00:12 +31 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 4. Ekran dönüşü (yatay tutuş) eksen eşlemesi Yan çevrilmiş ekranda eksenler döner (AY, -AX)
00:12 +32 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması WMM-2025 modeli 16 şehirde NOAA referansıyla eşleşir
00:12 +33 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması sapma işareti ve büyüklüğü jeofiziksel olarak tutarlı
00:12 +34 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması model geçerlilik aralığı dışında çökmek yerine sabitlenir
00:12 +35 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması ondalık yıl çevrimi doğru
00:12 +36 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları dünya şehirleri için bilinen Kıble açıları
00:12 +37 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları Kâbe üzerinde açı 0° (kuzeye) döner, antipodda tanımsız değil
00:12 +38 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları dijital pusula açısı gerçek kuzey açısıyla birebir aynıdır
00:12 +39 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri manyetik sapma gerçek kuzeye eklenir (Bağcılar)
00:12 +40 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri 0/360 sarmalaması doğru çalışır (batıya dönük kullanıcı)
00:12 +41 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri withQibla iki kez uygulansa da sonucu bozmaz (çift düzeltme yok)
00:12 +42 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri fark -180..180 aralığında ve en kısa yolu gösterir
00:12 +43 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri hizalama ve yakınlık eşikleri doğru
00:12 +44 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri geçersiz sensör paketleri reddedilir
00:12 +45 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi Kâbe rozeti her açıda doğru yerde durur
00:12 +46 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi kuzey etiketi telefonla birlikte döner
00:12 +47 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi hizalama yalnızca Kâbe yönünde gerçekleşir
00:12 +48 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi dönüş yönü işareti kullanıcıya doğru tarafı söyler
00:12 +49 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi harita vektörü ekran koordinatında Kâbe yönünü gösterir
00:12 +50 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları Bağcılar: kullanıcı telefonu Kâbe yönüne çevirdiğinde hizalanır
00:12 +51 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları kuzey yarımküre ve güney yarımküre şehirlerinde tutarlı
00:12 +52 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları 30° yanlış sapma kullanılsa bile hata 30° ile sınırlı kalır
00:12 +53 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi Play kurulumu + eşleşen imza → resmî paket
00:13 +54 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi yeniden imzalanmış (farklı imza) paket resmî değil
00:13 +55 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi patch aracı / klon / debugger resmî paketi düşürür
00:13 +56 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi imza sabitleme kapalıyken (test/CI) kontrol atlanır
00:13 +57 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi tüm alanlar JSON ile taşınabilir
00:13 +58 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) test modunda Google resmî test birim kimlikleri kullanılır
00:13 +59 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) altyapı başlatılmadan reklam istenmez (boş alan/hata yok)
00:13 +60 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) premium kullanıcıda reklam tamamen kapanır
00:13 +61 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) geçiş reklamı bekleme süresi 3 dakika
00:13 +62 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) reklam anahtarı varsayılan olarak açık, test modu kapalı
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
00:23 +63 ~6 -3: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
                shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                      ^^^^^^^^^^^
  lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
      final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                               ^^^^^^^^^^^
  .
00:23 +63 ~6 -3: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart [E]
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
  
00:24 +63 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket test modunda Google resmî test birim kimlikleri kullanılır
00:24 +64 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket altyapı başlatılmadan reklam istenmez (boş alan/hata yok)
00:24 +65 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket premium kullanıcıda reklam tamamen kapanır
00:24 +66 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket geçiş reklamı bekleme süresi kullanıcı dostu (3 dakika)
00:24 +67 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket reklam anahtarı varsayılan olarak açık, test modu kapalı
00:25 +68 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? 2 dakikalık konum tazedir
00:25 +69 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? 9 dakikalık konum tazedir (sınır altı)
00:25 +70 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? 15 dakikalık konum taze değildir
00:25 +71 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? tarih bilgisi yoksa taze sayılmaz
00:25 +72 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? gelecekteki zaman damgası negatif yaş üretmez
00:25 +73 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti 500 m doğruluk ilçe için yeterli
00:25 +74 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti 2 km doğruluk sınırda yeterli
00:25 +75 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti 3 km doğruluk ilçe için yetersiz (arka planda iyileştirilir)
00:25 +76 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti hassasiyet bilinmiyorsa yetersiz kabul edilir
00:25 +77 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: bütçe sabitleri tazelik penceresi ve GPS bütçesi makul
00:25 +78 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings varsayılan ayarlar Diyanet yöntemini kullanır
00:25 +79 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings JSON gidiş-dönüşü değerleri korur
00:25 +80 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings bozuk yedek varsayılanlara döner
00:25 +81 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings Hanefî ikindi yalnızca desteklenen yöntemlerde uygulanır
00:25 +82 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings manuel düzeltmeler her yöntemde aktarılır
00:25 +83 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod bilinmeyen kimlik Diyanet'e döner
00:25 +84 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod tüm yöntemler geçerli açılara sahip
00:25 +85 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe yönü Türkiye için güneydoğuyu gösterir
00:25 +86 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe koordinatında mesafe sıfıra yakındır
00:25 +87 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils İstanbul-Kâbe mesafesi ~2400 km
00:25 +88 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (setUpAll)
00:25 +88 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar bugünü hicri tarihe çevirir
00:25 +89 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar gün farkı hesabı ve geri dönüş tutarlı
00:25 +90 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar ay uzunluğu 29 veya 30 gündür
00:25 +91 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar Ramazan başlangıcı hicri 9. ayın 1. günüdür
00:25 +92 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (tearDownAll)
00:25 +92 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sıralı veri sağlıklı kabul edilir
00:25 +93 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:25 +94 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay bozuk veri sağlıksız kabul edilir
00:25 +95 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
00:34 +96 ~6 -4: loading /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
                shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                      ^^^^^^^^^^^
  lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
      final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                               ^^^^^^^^^^^
  .
00:34 +96 ~6 -4: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart [E]
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
  
00:36 +96 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:36 +96 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kategoriler tanımlı ve benzersiz
00:36 +97 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: en az 30 dua var ve kimlikler benzersiz
00:36 +98 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada ad, okunuş, meal ve kategori dolu
00:36 +99 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada kaynak künyesi var
00:36 +100 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kaynak künyeleri ya Kur'an ya muteber hadis kaynağına dayanır
00:36 +101 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duanın kategorisi kategori listesinde tanımlı
00:36 +102 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her kategoride en az bir dua var (boş sekme olmasın)
00:36 +103 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Kur'an kaynaklı duaların künyesi sure/ayet içerir
00:36 +104 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Arapça metin içeren dualar Arapça alfabede
00:36 +105 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: katalogda arama ve kategori süzme çalışıyor
00:36 +106 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (tearDownAll)
00:36 +106 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 1) Ana ekran widget verisi vakit saati 24 saat biçiminde ve hedef zamanı doğru taşınır
00:36 +107 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 1) Ana ekran widget verisi şehir bilgisi boşsa anlaşılır yedek metin kullanılır
00:36 +108 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni Arapça hat ayıklanır, Türkçe metin korunur
00:36 +109 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni Arapça ayıklama kapatılabilir
00:36 +110 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni kısa metin tek parça olarak döner
00:36 +111 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni boş metin sesli okunmaz
00:36 +112 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni uzun hutbe 4000 karakter sınırını aşmayan parçalara bölünür
00:36 +113 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni tek cümle sınırı aşarsa kelime sınırından zorunlu bölünür
00:36 +114 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim kaydedilir ve en yeni önce döner
00:36 +115 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi uzun yanıt 280 karakterlik özetle saklanır
00:36 +116 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim nedenleri kullanıcıya anlaşılır ve sıralı
00:36 +117 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi JSON gidiş-dönüşü kaybolmadan çalışır
00:37 +118 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı en az 20 kayıt ve benzersiz kimlikler
00:37 +119 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı her kayıtta başlık, cevap, anahtar kelime ve kaynak var
00:37 +120 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler küçük harf ve ASCII (arama uyumu)
00:37 +121 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler yeterince ayırt edici
00:37 +122 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı ilişkili kayıt kimlikleri geçerli
00:37 +123 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı mezhep farkı notları en az birkaç kayıtta bulunur
00:37 +124 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı kaynak künyeleri kaynak türüne ayrılabiliyor
00:37 +125 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi namaz rekatı sorusu doğru kayda gider
00:37 +126 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi abdest sorusu doğru kayda gider
00:37 +127 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi zekât sorusu doğru kayda gider
00:37 +128 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kıble sorusu doğru kayda gider
00:37 +129 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz
00:37 +130 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır
00:37 +131 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi konu kelimesi genel kelimelere üstün gelir (vitir/teravih)
00:37 +132 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi ayırt edici kelime puanı, genel kelimelerden yüksektir
00:37 +133 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi harf düşmesi olan sorular da eşleşir (hatim → hatmi)
00:37 +134 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Kâbe yönü sorusu kıble kaydına gider
00:37 +135 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi önerilen sorular kimlik değil, okunabilir başlık olarak döner
00:37 +136 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kayda uymayan soru için uydurma cevap üretilmez
00:37 +137 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi soru boşsa eşleşme yapılmaz
00:37 +138 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi paylaşım metni kaynakları ve mezhep notlarını içerir
00:37 +139 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İslam'ın şartları sorusuna beş şartı doğru sırayla ve kaynaklı cevaplar
00:37 +140 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:37 +141 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir
00:37 +142 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Bağcılar kıble açısı ±0,01° içinde
00:37 +143 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı İstanbul kıble açısı ±0,01° içinde
00:37 +144 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Ankara kıble açısı ±0,01° içinde
00:37 +145 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı New York kıble açısı ±0,01° içinde
00:37 +146 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Sidney kıble açısı ±0,01° içinde
00:37 +147 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Kâbe tam karşısında açı tanımsız ama sonlu kalır
00:37 +148 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Kutup noktalarında sonlu değer döner (çökme yok)
00:37 +149 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı İstanbul 21 Haziran 2026 12:00 (TRT)
00:37 +150 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı 21 Aralık 2026 12:00 — kış gündönümü, düşük güneş
00:37 +151 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı Gece yarısı güneş ufkun altındadır
00:37 +152 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı Güney yarımkürede yön doğru (Sidney öğlen güneşi kuzeyde)
00:37 +153 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı Julian günü bilinen değerle uyumlu (J2000)
00:37 +154 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 3. Kıble Günü — güneş Kâbe doğrultusunda 28 Mayıs 2026: İstanbul için fark < 0,2°
00:37 +155 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 3. Kıble Günü — güneş Kâbe doğrultusunda 15 Temmuz 2026: Ankara ve Bağcılar için fark < 0,2°
00:37 +156 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 3. Kıble Günü — güneş Kâbe doğrultusunda Önümüzdeki uygun gün 8° içinde bulunur ve hızlıdır
00:37 +157 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 3. Kıble Günü — güneş Kâbe doğrultusunda Kıble günü gölge yönü Kıble ile aynı (180° fark)
00:37 +158 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 3. Kıble Günü — güneş Kâbe doğrultusunda Güneşin ufkun üzerinde olduğu her yerde fark < 0,3°
00:37 +159 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 3. Kıble Günü — güneş Kâbe doğrultusunda Güneş ufkun altındaysa yöntem uygulanamaz (dürüst davranış)
00:37 +160 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 4. Tutuş (pose) ve hassasiyet mantığı Dik tutuş geçerli kullanımdır, kalibrasyon istemez
00:37 +161 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 4. Tutuş (pose) ve hassasiyet mantığı Geçiş açısı (±45°) uyarı üretir
00:37 +162 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 4. Tutuş (pose) ve hassasiyet mantığı Yatay sağlıklı ölçümde uyarı yok
00:37 +163 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 4. Tutuş (pose) ve hassasiyet mantığı withQibla poz bilgisini kaybetmez
00:37 +164 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 4. Tutuş (pose) ve hassasiyet mantığı Kadran dönüşü ve rozet açısı birbirini tutar
00:37 +165 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 5. Sayısal dayanıklılık Aşırı enlem/boylam değerleri NaN üretmez
00:37 +166 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 5. Sayısal dayanıklılık Azimut her zaman 0–360 aralığında normalize
00:37 +167 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 5. Sayısal dayanıklılık Kıble açısı ile güneş azimutu arasındaki fark simetriktir
00:38 +168 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri yedi gün × altı vakit için kimlikler benzersiz
00:38 +169 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri kimlikler ilgili aralıkta kalır
00:38 +170 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri vakit kimlikleri tekil bildirim kimlikleriyle çakışmaz
00:38 +171 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim yönlendirme yükü her hedef kendi yüküyle ayrışır
00:38 +172 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim yönlendirme yükü ayrıntılı yükler ve tanımsız yükler güvenli
00:38 +173 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları varsayılan olarak güneş vakti bildirilmez
00:38 +174 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları kullanıcı bir vakti kapatabilir
00:38 +175 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları bildirimler tümden kapatılınca hiçbir vakit bildirilmez
00:38 +176 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları eksik ayar güvenli tarafta kalır (kapalı sayılır)
00:38 +177 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu varsayılan sessiz saat kapalı
00:38 +178 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu sessiz saat aralığı gece yarısını aşabilir
00:38 +179 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu uyku modu 22:00–07:00 arasını kapsar
00:38 +180 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu öğle vakti sessiz saate girmez
00:38 +181 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı ön hatırlatma varsayılan olarak kapalı
00:38 +182 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı ön hatırlatma dakikası ayarlanabilir
00:38 +183 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı zamanlanan gün sayısı makul aralıkta
00:38 +184 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
00:38 +185 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
00:38 +186 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer ekleri kaba biçimde kırpar
00:38 +187 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer eşleştirme aksan ve ek farklarını tolere eder
00:38 +188 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Arapça harekeleri kaldırır
00:38 +189 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer yüzde biçimi
00:38 +190 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime geri sayım ve dijital sayaç biçimi
00:38 +191 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime 24 saat ve 12 saat biçimi
00:38 +192 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime gün karşılaştırması
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
00:47 +193 ~6 -5: loading /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
                shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                      ^^^^^^^^^^^
  lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
      final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                               ^^^^^^^^^^^
  .
00:48 +193 ~6 -5: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart [E]
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
  
00:49 +193 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:49 +193 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: doğrulama verisi yüklendi
00:49 +194 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±3 dakika içinde kalır
00:49 +195 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada
00:49 +196 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: Hanefî ikindi vakti Şâfiî'den sonra olur
00:49 +197 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:49 +198 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (tearDownAll)
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
00:59 +198 ~6 -6: loading /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
                shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                      ^^^^^^^^^^^
  lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
      final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                               ^^^^^^^^^^^
  .
00:59 +198 ~6 -6: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart [E]
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
  
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
01:10 +198 ~6 -7: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
                shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                      ^^^^^^^^^^^
  lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
   - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
   - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
      final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                               ^^^^^^^^^^^
  .
01:10 +198 ~6 -7: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart
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

## kible
```
# Ezan Vaktim Pro — Kıble 6 aşamalı doğrulama raporu
- Tarih referansı: ondalık yıl 2026.8
- Kâbe (uygulama): 21.4224779, 39.8251832
- Kâbe (resmî referans): 21.4225, 39.8262
- Test dosyası: test/data/qibla_verification_test.dart

## Kontrol 1 — Kâbe kerterizi (üç bağımsız yöntem)
| Şehir | Test sabiti | tan biçimi | vektör biçimi | Vincenty (WGS-84) | Maks. fark |
|---|---|---|---|---|---|
| Bağcılar | 151.37° | 151.3708° | 151.3708° | 151.2634° | 0.1074° |
| İstanbul | 151.62° | 151.6230° | 151.6230° | 151.5162° | 0.1068° |
| Londra | 118.99° | 118.9884° | 118.9884° | 118.8695° | 0.1188° |
| New York | 58.48° | 58.4824° | 58.4824° | 58.3967° | 0.0857° |
| Jakarta | 295.15° | 295.1515° | 295.1515° | 295.0244° | 0.1271° |
| Paris | 119.16° | 119.1643° | 119.1643° | 119.0406° | 0.1237° |
| Sidney | 277.50° | 277.4991° | 277.4991° | 277.3183° | 0.1808° |
| Tokyo | 293.02° | 292.9992° | 292.9992° | 293.0726° | 0.0734° |

- Yöntemler arası en büyük fark: **0.1808°** (elipsoit–küre farkı)
- Test sabitleriyle en büyük fark: **0.0208°**
- Uygulamadaki Kâbe noktası resmî konuma **105 m** uzaklıkta.

## Kontrol 2 — Manyetik sapma (NOAA WMM-2025, bağımsız kütüphane)
| Şehir | Test sabiti | pygeomag WMM-2025 | Fark |
|---|---|---|---|
| İstanbul | +6.079° | +6.079° | 0.0001° |
| Bağcılar | +6.073° | +6.073° | 0.0005° |
| Küçükçekmece | +6.060° | +6.060° | 0.0002° |
| Ankara | +6.174° | +6.174° | 0.0001° |
| İzmir | +5.525° | +5.525° | 0.0003° |
| Trabzon | +6.703° | +6.703° | 0.0003° |
| Van | +6.058° | +6.058° | 0.0005° |
| Mekke | +3.502° | +3.502° | 0.0002° |
| Londra | +1.213° | +1.213° | 0.0003° |
| New York | -12.462° | -12.462° | 0.0005° |
| Sidney | +12.827° | +12.827° | 0.0002° |
| Tokyo | -7.943° | -7.943° | 0.0002° |
| Jakarta | +0.650° | +0.650° | 0.0002° |
| Dubai | +2.239° | +2.239° | 0.0001° |
| Kuala Lumpur | +0.032° | +0.032° | 0.0001° |
| Paris | +2.089° | +2.089° | 0.0001° |

- En büyük fark: **0.0005°** → model test sabitleri resmî katsayılarla uyumlu.
- Bağcılar (2026.8) sapması **+6.07°** (doğu). Sapma uygulanmazsa Kıble 6.07° kayar; uygulamanın ±5° eşiği tek başına bunu telafi edemez.

## Kontrol 3 — Konum/ölçüm hata bütçesi
| Şehir | Zemin (0°) | ±0,05° konum | ±0,5° konum | 1° pusula | Sapma yok | Toplam üst sınır |
|---|---|---|---|---|---|---|
| Bağcılar | 0.00° | 0.176° | 1.78° | 1.00° | 6.07° | 1.38° |
| Gebze | 0.00° | 0.178° | 1.80° | 1.00° | 6.08° | 1.38° |
| İstanbul | 0.00° | 0.177° | 1.79° | 1.00° | 6.08° | 1.38° |
| Ankara | 0.00° | 0.183° | 1.86° | 1.00° | 6.17° | 1.38° |
| New York | 0.00° | 0.036° | 0.36° | 1.00° | 12.46° | 1.24° |
| Sidney | 0.00° | 0.052° | 0.53° | 1.00° | 12.83° | 1.25° |

- En kötü birleşik hata: **1.38°** → uygulamanın ±5° hizalama eşiğinin altında; "Kâbe yönündesiniz" yazdığında gerçek sapma ≤5°.

## Kontrol 4 — Uçtan uca tutarlılık (Bağcılar senaryosu)
- Bağcılar Kıble yönü (gerçek kuzey): **151.371°**
- Manyetik sapma: **+6.073°** → manyetik kuzeye göre Kıble **145.298°**
- Sensör 145.298° okur → gerçek kuzey 151.371° → fark +0.0000° (hizalı, eşik ±5°)
- Sarmalama: 356° + 6,073° = **2.073°** (0°'yi doğru geçiyor)
- Test dosyası: **5 grup / 21 test** (Kontrol 1–4 katmanlarını kapsar)

## Kontrol 5 — Güneşle doğrulama (Kıble Günü, 28 Mayıs / 15 Temmuz)
- 28 Mayıs 2026: Kâbe üzerinde güneş yüksekliği **89.37°** (≈9.34 UTC) — gölgeler Kâbe yönüne paralel.

### 28 Mayıs 2026 (gün boyu, en yakın dakika)
| Şehir | Kıble | Güneş azimutu | Fark | Yükseklik | Durum |
|---|---|---|---|---|---|
| Bağcılar | 151.37° | 151.30° | **0.066°** | 68.4° | gözlenebilir |
| İstanbul | 151.62° | 151.56° | **0.066°** | 68.4° | gözlenebilir |
| Ankara | 160.17° | 160.12° | **0.051°** | 70.6° | gözlenebilir |
| Londra | 118.99° | 118.93° | **0.056°** | 46.9° | gözlenebilir |
| Berlin | 136.69° | 136.64° | **0.047°** | 52.9° | gözlenebilir |
| New York | 58.48° | 65.86° | **7.379°** | 5.1° | bu enlemde gölge yöntemi yok |
| Sidney | 277.50° | 300.22° | **22.717°** | 5.2° | bu enlemde gölge yöntemi yok |

### 15 Temmuz 2026 (gün boyu, en yakın dakika)
| Şehir | Kıble | Güneş azimutu | Fark | Yükseklik | Durum |
|---|---|---|---|---|---|
| Bağcılar | 151.37° | 151.47° | **0.102°** | 68.4° | gözlenebilir |
| İstanbul | 151.62° | 151.73° | **0.103°** | 68.5° | gözlenebilir |
| Ankara | 160.17° | 160.31° | **0.143°** | 70.6° | gözlenebilir |
| Londra | 118.99° | 119.01° | **0.025°** | 47.0° | gözlenebilir |
| Berlin | 136.69° | 136.74° | **0.052°** | 52.9° | gözlenebilir |
| New York | 58.48° | 65.91° | **7.432°** | 5.1° | bu enlemde gölge yöntemi yok |
| Sidney | 277.50° | 300.20° | **22.703°** | 5.1° | bu enlemde gölge yöntemi yok |

- Eşik **0,25°**: bir insan gölgeyle 0,25°'den daha iyi ölçemez; uygulama bu anlarda pusulasız doğrulanabilir.
- Güneş ufkun altındaysa (ör. ABD'de o an gece) gölge yöntemi kullanılamaz; uygulama bu durumda "pusulayı kullanın" der.
- Uygulama tarafı: `lib/core/utils/sun_position.dart` (`QiblaSunCheck`) + `test/data/qibla_precision_test.dart`.

## Kontrol 6 — Tutuş füzyonu (dik/yatay tutuş, 180° hata testi)
| Yön | Eğim | Eski yöntem | Eski hata | Yeni füzyon | Yeni hata |
|---|---|---|---|---|---|
| 37.00° | 0° | 37.00° | 0.00° | 37.00° | 0.000° |
| 37.00° | 45° | 37.00° | 0.00° | 37.00° | 0.000° |
| 37.00° | 89° | 37.00° | 0.00° | 37.00° | 0.000° |
| 37.00° | 90° | tanımsız | — | 37.00° | 0.000° |
| 37.00° | 100° | 217.00° | 180.00° | 37.00° | 0.000° |
| 37.00° | 120° | 217.00° | 180.00° | 37.00° | 0.000° |
| 151.37° | 0° | 151.37° | 0.00° | 151.37° | 0.000° |
| 151.37° | 45° | 151.37° | 0.00° | 151.37° | 0.000° |
| 151.37° | 89° | 151.37° | 0.00° | 151.37° | 0.000° |
| 151.37° | 90° | tanımsız | — | 151.37° | 0.000° |
| 151.37° | 100° | 331.37° | 180.00° | 151.37° | 0.000° |
| 151.37° | 120° | 331.37° | 180.00° | 151.37° | 0.000° |

- Yeni füzyonun en büyük hatası: **0.0000°** (tüm tutuş açılarında).
- Eski yöntem 90°'de **tanımsız**, 100°'de **180° hatalı**; sahada "Kıble tersini gösteriyor" şikâyetinin kaynağı budur.
- Uygulama tarafı: `MainActivity.extractAnglesFromMatrix` (Kotlin) ve `lib/core/utils/pose_fusion.dart` (Dart referansı) + `test/data/pose_fusion_test.dart`.

## Sonuç
✅ **6/6 kontrol geçti** — Kıble hesabında bilinen hata yok.
```

## build
```
[====================                   ] 52% Unzipping... android-ndk-r28c/tool
[=====================                  ] 53% Unzipping... android-ndk-r28c/tool
[=====================                  ] 54% Unzipping... android-ndk-r28c/tool
[=====================                  ] 54% Unzipping... android-ndk-r28c/buil
[=====================                  ] 54% Unzipping... android-ndk-r28c/sour
[=====================                  ] 54% Unzipping... android-ndk-r28c/NOTI
[=====================                  ] 54% Unzipping... android-ndk-r28c/ndk-
[=====================                  ] 54% Unzipping... android-ndk-r28c/NOTI
[=====================                  ] 54% Unzipping... android-ndk-r28c/pyth
[=====================                  ] 54% Unzipping... android-ndk-r28c/preb
[=====================                  ] 54% Unzipping... android-ndk-r28c/ndk-
[=====================                  ] 54% Unzipping... android-ndk-r28c/sour
[=====================                  ] 54% Unzipping... android-ndk-r28c/simp
[=====================                  ] 55% Unzipping... android-ndk-r28c/simp
[=====================                  ] 55% Unzipping... android-ndk-r28c/CHAN
[=======================================] 100% Unzipping... android-ndk-r28c/CHA

Checking the license for package CMake 3.22.1 in /usr/local/lib/android/sdk/licenses
License for package CMake 3.22.1 accepted.
Preparing "Install CMake 3.22.1 v.3.22.1".
"Install CMake 3.22.1 v.3.22.1" ready.
Installing CMake 3.22.1 in /usr/local/lib/android/sdk/cmake/3.22.1
"Install CMake 3.22.1 v.3.22.1" complete.
"Install CMake 3.22.1 v.3.22.1" finished.
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
Note: /home/runner/.pub-cache/hosted/pub.dev/geolocator_android-5.2.1/android/src/main/java/com/baseflow/geolocator/location/LocationMapper.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
3 warnings
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.9-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 3m 24s
Running Gradle task 'assembleRelease'...                          204.6s
Gradle task assembleRelease failed with exit code 1
```

## release
```
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

Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
3 warnings
lib/features/settings/prayer_verify_screen.dart:205:53: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
                                                    ^^^^^^^^^^^
lib/features/settings/prayer_verify_screen.dart:237:62: Error: The getter 'valueOrNull' isn't defined for the type 'AsyncValue<TodayTimes>'.
 - 'AsyncValue' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-3.4.3/lib/src/framework.dart').
 - 'TodayTimes' is from 'package:ezanai/state/providers.dart' ('lib/state/providers.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull'.
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
                                                             ^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.9-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 56s
Running Gradle task 'bundleRelease'...                             56.8s
Gradle task bundleRelease failed with exit code 1
```
