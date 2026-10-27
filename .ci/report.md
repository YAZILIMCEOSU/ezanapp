# CI raporu (2026-10-27 07:22 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | success |
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
Nothing to fix!
== dart format ==
Formatted 117 files (0 changed) in 1.32 seconds.
```

## analyze
```
Analyzing ezanapp...                                            
No issues found! (ran in 21.7s)
```

## test
```
00:05 +72 -17: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — tablet 1024×1366
00:05 +73 -17: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
00:05 +74 -17: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Dualar: künye özeti ve kategori çipleri görünür
Pending timers:
Timer (duration: 0:00:02.000000, periodic: false), created:
#0      new FakeTimer._ (package:fake_async/fake_async.dart:342:62)
#1      FakeAsync._createTimer (package:fake_async/fake_async.dart:260:29)
#2      FakeAsync.run.<anonymous closure> (package:fake_async/fake_async.dart:185:15)
#6      _AdBannerState._load (package:ezanai/features/widgets/ad_banner.dart:45:7)
#7      _AdBannerState.initState.<anonymous closure> (package:ezanai/features/widgets/ad_banner.dart:34:57)
#8      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#9      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1357:11)
#10     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#13     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#14     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#15     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#18     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#19     WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#20     renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:272:16)
#21     main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:85:13)
#22     main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:17)
#23     testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#24     TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 8 frames from dart:async and package:stack_trace)

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 2543 pos 12: '!timersPending'

When the exception was thrown, this was the stack:
#2      AutomatedTestWidgetsFlutterBinding._verifyInvariants (package:flutter_test/src/binding.dart:2543:12)
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1974:7)
<asynchronous suspension>
<asynchronous suspension>
(elided 3 frames from class _AssertionError and package:stack_trace)

The test description was:
  Dualar: künye özeti ve kategori çipleri görünür
════════════════════════════════════════════════════════════════════════════════════════════════════
00:05 +74 -18: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Dualar: künye özeti ve kategori çipleri görünür [E]
  Test failed. See exception logs above.
  The test description was: Dualar: künye özeti ve kategori çipleri görünür
  
00:05 +74 -18: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Hadis: başlık ve konu çipleri görünür
[hadis tanısı] çipler: false · yükleniyor: true · metinler: Hadis metni veya konu ara | Hadisler yükleniyor… | Hadis | Sahih kaynaklardan seçkiler
Pending timers:
Timer (duration: 0:00:02.000000, periodic: false), created:
#0      new FakeTimer._ (package:fake_async/fake_async.dart:342:62)
#1      FakeAsync._createTimer (package:fake_async/fake_async.dart:260:29)
#2      FakeAsync.run.<anonymous closure> (package:fake_async/fake_async.dart:185:15)
#6      _AdBannerState._load (package:ezanai/features/widgets/ad_banner.dart:45:7)
#7      _AdBannerState.initState.<anonymous closure> (package:ezanai/features/widgets/ad_banner.dart:34:57)
#8      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#9      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1357:11)
#10     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#13     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#14     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#15     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#18     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#19     WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#20     renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:272:16)
#21     main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:101:13)
#22     main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:17)
#23     testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#24     TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 8 frames from dart:async and package:stack_trace)

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 2543 pos 12: '!timersPending'

When the exception was thrown, this was the stack:
#2      AutomatedTestWidgetsFlutterBinding._verifyInvariants (package:flutter_test/src/binding.dart:2543:12)
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1974:7)
<asynchronous suspension>
<asynchronous suspension>
(elided 3 frames from class _AssertionError and package:stack_trace)

The test description was:
  Hadis: başlık ve konu çipleri görünür
════════════════════════════════════════════════════════════════════════════════════════════════════
00:05 +74 -19: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Hadis: başlık ve konu çipleri görünür [E]
  Test failed. See exception logs above.
  The test description was: Hadis: başlık ve konu çipleri görünür
  
00:05 +74 -19: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Zikir: tesbih ekranı sayaç ile çizilir
00:05 +75 -19: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Vakitler: liste başlığı ve ayar ipucu birlikte görünür
Pending timers:
Timer (duration: 0:00:02.000000, periodic: false), created:
#0      new FakeTimer._ (package:fake_async/fake_async.dart:342:62)
#1      FakeAsync._createTimer (package:fake_async/fake_async.dart:260:29)
#2      FakeAsync.run.<anonymous closure> (package:fake_async/fake_async.dart:185:15)
#6      _AdBannerState._load (package:ezanai/features/widgets/ad_banner.dart:45:7)
#7      _AdBannerState.initState.<anonymous closure> (package:ezanai/features/widgets/ad_banner.dart:34:57)
#8      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#9      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1357:11)
#10     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#13     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#14     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#15     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#18     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#19     WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#20     renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:272:16)
#21     main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:148:13)
#22     main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:17)
#23     testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#24     TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 8 frames from dart:async and package:stack_trace)

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 2543 pos 12: '!timersPending'

When the exception was thrown, this was the stack:
#2      AutomatedTestWidgetsFlutterBinding._verifyInvariants (package:flutter_test/src/binding.dart:2543:12)
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1974:7)
<asynchronous suspension>
<asynchronous suspension>
(elided 3 frames from class _AssertionError and package:stack_trace)

The test description was:
  Vakitler: liste başlığı ve ayar ipucu birlikte görünür
════════════════════════════════════════════════════════════════════════════════════════════════════
00:06 +75 -20: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Vakitler: liste başlığı ve ayar ipucu birlikte görünür [E]
  Test failed. See exception logs above.
  The test description was: Vakitler: liste başlığı ve ayar ipucu birlikte görünür
  
00:06 +75 -20: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Kur'an: sure listesi yüklenir
Pending timers:
Timer (duration: 0:00:02.000000, periodic: false), created:
#0      new FakeTimer._ (package:fake_async/fake_async.dart:342:62)
#1      FakeAsync._createTimer (package:fake_async/fake_async.dart:260:29)
#2      FakeAsync.run.<anonymous closure> (package:fake_async/fake_async.dart:185:15)
#6      _AdBannerState._load (package:ezanai/features/widgets/ad_banner.dart:45:7)
#7      _AdBannerState.initState.<anonymous closure> (package:ezanai/features/widgets/ad_banner.dart:34:57)
#8      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#9      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1357:11)
#10     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#13     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#14     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#15     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#18     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#19     WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#20     renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:272:16)
#21     main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:161:13)
#22     main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:17)
#23     testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#24     TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 8 frames from dart:async and package:stack_trace)

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 2543 pos 12: '!timersPending'

When the exception was thrown, this was the stack:
#2      AutomatedTestWidgetsFlutterBinding._verifyInvariants (package:flutter_test/src/binding.dart:2543:12)
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1974:7)
<asynchronous suspension>
<asynchronous suspension>
(elided 3 frames from class _AssertionError and package:stack_trace)

The test description was:
  Kur'an: sure listesi yüklenir
════════════════════════════════════════════════════════════════════════════════════════════════════
00:06 +75 -21: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Kur'an: sure listesi yüklenir [E]
  Test failed. See exception logs above.
  The test description was: Kur'an: sure listesi yüklenir
  
00:06 +75 -21: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Daha Fazla: tüm bölüm girişleri listelenir
00:06 +76 -21: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir hata görünümü anlaşılır mesaj ve "Tekrar dene" sunar
00:06 +77 -21: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir izni olmayan hatalarda "Tekrar dene" gösterilmez
00:06 +78 -21: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir vakitler cihazda hesaplandıysa uyarı şeridi görünür
Pending timers:
Timer (duration: 0:00:02.000000, periodic: false), created:
00:06 +79 -21: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir vakitler cihazda hesaplandıysa uyarı şeridi görünür
#0      new FakeTimer._ (package:fake_async/fake_async.dart:342:62)
#1      FakeAsync._createTimer (package:fake_async/fake_async.dart:260:29)
#2      FakeAsync.run.<anonymous closure> (package:fake_async/fake_async.dart:185:15)
#6      _AdBannerState._load (package:ezanai/features/widgets/ad_banner.dart:45:7)
#7      _AdBannerState.initState.<anonymous closure> (package:ezanai/features/widgets/ad_banner.dart:34:57)
#8      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#9      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1357:11)
#10     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#13     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#14     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#15     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#18     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#19     WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#20     renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:272:16)
#21     main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:241:13)
#22     main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:17)
#23     testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#24     TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 8 frames from dart:async and package:stack_trace)

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 2543 pos 12: '!timersPending'

When the exception was thrown, this was the stack:
#2      AutomatedTestWidgetsFlutterBinding._verifyInvariants (package:flutter_test/src/binding.dart:2543:12)
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1974:7)
<asynchronous suspension>
<asynchronous suspension>
(elided 3 frames from class _AssertionError and package:stack_trace)

The test description was:
  vakitler cihazda hesaplandıysa uyarı şeridi görünür
════════════════════════════════════════════════════════════════════════════════════════════════════
00:06 +79 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı her kayıtta başlık, cevap, anahtar kelime ve kaynak var
00:06 +79 -22: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir vakitler cihazda hesaplandıysa uyarı şeridi görünür [E]
  Test failed. See exception logs above.
  The test description was: vakitler cihazda hesaplandıysa uyarı şeridi görünür
  
00:06 +80 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler küçük harf ve ASCII (arama uyumu)
00:06 +81 -22: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: (tearDownAll)
00:06 +81 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler yeterince ayırt edici
00:06 +82 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı ilişkili kayıt kimlikleri geçerli
00:06 +83 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı mezhep farkı notları en az birkaç kayıtta bulunur
00:06 +84 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı kaynak künyeleri kaynak türüne ayrılabiliyor
00:06 +85 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi namaz rekatı sorusu doğru kayda gider
00:06 +86 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi abdest sorusu doğru kayda gider
00:06 +87 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi zekât sorusu doğru kayda gider
00:06 +88 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kıble sorusu doğru kayda gider
00:06 +89 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz
00:06 +90 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır
00:06 +91 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi konu kelimesi genel kelimelere üstün gelir (vitir/teravih)
00:06 +92 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi ayırt edici kelime puanı, genel kelimelerden yüksektir
00:06 +93 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi harf düşmesi olan sorular da eşleşir (hatim → hatmi)
00:06 +94 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Kâbe yönü sorusu kıble kaydına gider
00:06 +95 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi önerilen sorular kimlik değil, okunabilir başlık olarak döner
00:06 +96 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kayda uymayan soru için uydurma cevap üretilmez
00:06 +97 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi soru boşsa eşleşme yapılmaz
00:06 +98 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi paylaşım metni kaynakları ve mezhep notlarını içerir
00:06 +99 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İslam'ın şartları sorusuna beş şartı doğru sırayla ve kaynaklı cevaplar
00:06 +100 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:06 +101 -22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir
00:07 +102 -22: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması WMM-2025 modeli 16 şehirde NOAA referansıyla eşleşir
00:07 +103 -22: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması sapma işareti ve büyüklüğü jeofiziksel olarak tutarlı
00:07 +104 -22: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması model geçerlilik aralığı dışında çökmek yerine sabitlenir
00:07 +105 -22: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması ondalık yıl çevrimi doğru
00:07 +106 -22: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları dünya şehirleri için bilinen Kıble açıları
00:07 +107 -22: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları Kâbe üzerinde açı 0° (kuzeye) döner, antipodda tanımsız değil
00:07 +107 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları Kâbe üzerinde açı 0° (kuzeye) döner, antipodda tanımsız değil [E]
  Expected: a numeric value within <0.01> of <0.0>
    Actual: <180.0>
     Which:  differs by <180.0>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/data/qibla_verification_test.dart 131:7        main.<fn>.<fn>
  
00:07 +107 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları dijital pusula açısı gerçek kuzey açısıyla birebir aynıdır
00:07 +108 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri manyetik sapma gerçek kuzeye eklenir (Bağcılar)
00:07 +109 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri 0/360 sarmalaması doğru çalışır (batıya dönük kullanıcı)
00:07 +110 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri withQibla iki kez uygulansa da sonucu bozmaz (çift düzeltme yok)
00:07 +111 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri fark -180..180 aralığında ve en kısa yolu gösterir
00:07 +112 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri hizalama ve yakınlık eşikleri doğru
00:07 +113 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri geçersiz sensör paketleri reddedilir
00:07 +114 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi Kâbe rozeti her açıda doğru yerde durur
00:07 +115 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi kuzey etiketi telefonla birlikte döner
00:07 +116 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi hizalama yalnızca Kâbe yönünde gerçekleşir
00:07 +117 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi dönüş yönü işareti kullanıcıya doğru tarafı söyler
00:07 +118 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi harita vektörü ekran koordinatında Kâbe yönünü gösterir
00:07 +119 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları Bağcılar: kullanıcı telefonu Kâbe yönüne çevirdiğinde hizalanır
00:07 +120 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları kuzey yarımküre ve güney yarımküre şehirlerinde tutarlı
00:07 +121 -23: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları 30° yanlış sapma kullanılsa bile hata 30° ile sınırlı kalır
00:07 +121 -24: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları 30° yanlış sapma kullanılsa bile hata 30° ile sınırlı kalır [E]
  Expected: a numeric value within <0.01> of <30>
    Actual: <30.297367904782107>
     Which:  differs by <0.2973679047821065>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/data/qibla_verification_test.dart 393:7        main.<fn>.<fn>
  
00:07 +121 -24: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket test modunda Google resmî test birim kimlikleri kullanılır
00:07 +122 -24: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket altyapı başlatılmadan reklam istenmez (boş alan/hata yok)
00:07 +123 -24: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket premium kullanıcıda reklam tamamen kapanır
00:07 +124 -24: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket geçiş reklamı bekleme süresi kullanıcı dostu (3 dakika)
00:07 +125 -24: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket reklam anahtarı varsayılan olarak açık, test modu kapalı
00:08 +126 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:08 +127 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
00:08 +128 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaklı uzak yanıt kabul edilir
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +128 ~1 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaksız uzak yanıt reddedilir, yerel tabana düşülür
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +128 ~2 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında sunucu hatasında (500) uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +128 ~3 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bozuk JSON yanıtında uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +128 ~4 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +128 ~5 -24: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında uzak yanıtlara da öneri soruları eklenir
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +128 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: (setUpAll)
00:08 +128 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası Diyanet resmî verisi ilk sırada kullanılır ve önbelleğe yazılır
00:08 +129 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası Diyanet başarısızsa AlAdhan devreye girer
00:08 +130 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası her iki servis de çökerse yerel hesap devreye girer
00:09 +131 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası tutarsız (bozuk) servis verisi reddedilir ve zincir devam eder
00:09 +132 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış çevrimdışıyken son başarılı veri önbellekten okunur
00:09 +133 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış süresi geçmiş (6 saatten eski) önbellek kullanılmaz
00:09 +134 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış çevrimdışı ve önbellek boşsa yerel hesap sonuç üretir
00:09 +135 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış ilçe seçilmemişse (GPS) resmî servis çağrılmaz, hesap kullanılır
00:09 +136 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış bellek önbelleği aynı gün için tekrar sorguda ağa çıkmaz
00:09 +137 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış zorla yenileme önbelleği atlar
00:09 +138 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek aralığı kapsıyorsa ağa çıkılmaz
00:09 +139 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:09 +140 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) resmî yanıt çözümlenir (zarf + hicri tarih)
00:09 +141 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:09 +142 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) bozuk JSON çökme yerine kaynak hatası üretir
00:09 +143 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) ilçe kimliği yoksa servis çağrılmadan hata verir
00:09 +144 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) AlAdhan yanıtı çözümlenir ve hicri etiket üretilir
00:09 +145 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) AlAdhan boş vakit verisinde hata üretir
00:09 +146 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: kaynak bilgisi (kullanıcı mesajları) resmî veri varken son güncelleme bilgisi gösterilir
00:09 +147 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: kaynak bilgisi (kullanıcı mesajları) konum seçilmemişse hesap bilgisi gösterilir
00:09 +148 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: yerel hesap kalibrasyonu Diyanet yöntemiyle İstanbul için tutarlı vakitler üretir
00:09 +149 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: (tearDownAll)
00:09 +149 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli JSON ayrıştırma tüm alanları okur
00:09 +150 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli eksik alanlar çökmez, kategori varsayılana düşer
00:09 +151 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli kaynak künyesi paylaşım metninde yer alır
00:09 +152 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli paylaşım metni Arapça, okunuş ve meali içerir
00:09 +153 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli Arapçası olmayan dua bile okunabilir paylaşılır
00:09 +154 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli arama diakritik ve büyük harf duyarsız
00:09 +155 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli künye metni de aranabilir
00:09 +156 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kategoriye göre süzer
00:09 +157 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş sorgu tüm listeyi döner
00:09 +158 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog sorguya göre süzer
00:09 +159 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kimliğe göre bulur
00:09 +160 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş katalog güvenli
00:10 +161 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:10 +161 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kategoriler tanımlı ve benzersiz
00:10 +162 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: en az 30 dua var ve kimlikler benzersiz
00:10 +163 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada ad, okunuş, meal ve kategori dolu
00:10 +164 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada kaynak künyesi var
00:10 +165 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kaynak künyeleri ya Kur'an ya muteber hadis kaynağına dayanır
00:10 +166 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duanın kategorisi kategori listesinde tanımlı
00:10 +167 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her kategoride en az bir dua var (boş sekme olmasın)
00:10 +168 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Kur'an kaynaklı duaların künyesi sure/ayet içerir
00:10 +169 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Arapça metin içeren dualar Arapça alfabede
00:10 +170 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: katalogda arama ve kategori süzme çalışıyor
00:10 +171 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (tearDownAll)
00:10 +171 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: (setUpAll)
00:10 +171 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: AI kota, kaynak doğrulama ve fetva güvenliği günlük kota dolsa bile İslam'ın ve imanın şartları gibi onaylı cevaplar engellenmez
00:10 +172 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: AI kota, kaynak doğrulama ve fetva güvenliği fetva soruları tespit edilir ve uydurma kaynaklar elenir
00:10 +173 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) gün içinde aktif vakit, sıradaki vakit ve geri sayım tutarlıdır
00:10 +174 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) yatsı sonrasında sıradaki vakit yarının imsakıdır
00:10 +175 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) gece yarısı geçildiğinde aktif gün otomatik olarak yarına devreder
00:10 +176 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) hesaplama yöntemi ve Hanefî ikindi değişimi vakitleri yeniler
00:10 +177 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +178 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon geçersiz sensör verisi reddedilir
00:10 +179 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon manyetik kuzey sapması gerçek kuzeye doğru eklenir
00:10 +180 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon manyetik parazit ve telefon eğimi ayrı uyarılarla bildirilir
00:10 +181 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Gizlilik ve log temizliği AppLog.sanitize koordinat, e-posta ve anahtarları maskeler
00:10 +182 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu varsayılan ezan sesi Hicaz makamıdır ve vakit bazlı ses özelleştirmesi korunur
00:10 +183 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:10 +184 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu bildirim seslerinde çan ifadesi yer almaz; telifsiz ilahi ve ezan makamları kullanılır
00:10 +185 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu uygulama adı Ezan Vaktim Pro, dil desteği TR/EN/AR, meal seçimi, saat geri alma ve Esmaül Hüsna doğrulanır
00:10 +186 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +187 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +188 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +189 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +190 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +191 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +192 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Nafile namaz alarmları, Kâbe İmamı ezanı, global Kur'an oturumu ve genişletilmiş İslami Asistan doğrulanır
00:11 +193 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Bağcılar dahil tüm büyükşehir merkez ilçeleri GPS koordinatıyla doğru tespit edilir
00:11 +194 ~6 -24: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: (tearDownAll)
00:11 +194 ~6 -24: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları Kâbe üzerinde açı 0° (kuzeye) döner, antipodda tanımsız değil
  /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları 30° yanlış sapma kullanılsa bile hata 30° ile sınırlı kalır
  /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları Daha Fazla ekranı yalnızca açık modülleri listeler
  /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları ana ekran yalnızca MVP kartlarını gösterir
  ... and 20 more
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

BUILD FAILED in 19s
Running Gradle task 'assembleRelease'...                           20.5s
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

BUILD FAILED in 735ms
Running Gradle task 'bundleRelease'...                             851ms
Gradle build failed due to Java/Gradle incompatibility.
The Java version used for the build is 25.0.4, which is incompatible with Gradle 8.14.3.
To fix this, you can either:
  1. Upgrade your project's Gradle version (typically in gradle-wrapper.properties to a version matching the range: compatible Gradle versions for Java 25.0.4 are 9.1.0 or newer).
  2. Use a different Java version for Flutter by running `flutter config --jdk-dir=<path>`.
```
