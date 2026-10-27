# CI raporu (2026-10-27 08:01 UTC)

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
Formatted lib/core/services/tts_service.dart
Formatted lib/features/ai/ai_screen.dart
Formatted lib/features/dua/dua_screen.dart
Formatted test/data/phase4_test.dart
Formatted 123 files (4 changed) in 1.05 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

  error • The named parameter 'fireImmediately' isn't defined. Try correcting the name to an existing named parameter's name, or defining a named parameter with the name 'fireImmediately' • lib/features/widgets/home_widget_sync.dart:45:8 • undefined_named_parameter

1 issue found. (ran in 17.5s)
```

## test
```
(package:flutter/src/widgets/framework.dart:5884:14)
          #447    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #448    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #449    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #450    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #451    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #452    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #453    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #454    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #455    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #456    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #457    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #458    SingleChildRenderObjectElement.visitChildren
(package:flutter/src/widgets/framework.dart:7114:14)
          #459    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #460    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #461    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #462    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #463    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #464    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #465    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #466    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #467    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #468    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #469    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #470    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #471    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #472    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #473    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #474    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #475    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #476    SingleChildRenderObjectElement.visitChildren
(package:flutter/src/widgets/framework.dart:7114:14)
          #477    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #478    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #479    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #480    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #481    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #482    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #483    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #484    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #485    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #486    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #487    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #488    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #489    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #490    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #491    SingleChildRenderObjectElement.visitChildren
(package:flutter/src/widgets/framework.dart:7114:14)
          #492    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #493    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #494    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #495    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #496    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #497    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #498    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #499    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #500    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #501    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #502    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #503    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #504    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #505    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #506    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #507    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #508    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #509    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #510    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #511    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #512    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #513    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #514    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #515    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #516    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #517    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #518    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #519    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #520    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #521    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #522    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #523    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #524    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #525    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #526    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #527    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #528    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #529    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #530    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #531    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #532    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #533    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #534    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #535    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #536    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #537    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #538    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #539    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #540    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #541    _InactiveElements._unmount.<anonymous closure>
(package:flutter/src/widgets/framework.dart:2117:7)
          #542    ComponentElement.visitChildren
(package:flutter/src/widgets/framework.dart:5884:14)
          #543    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2115:13)
          #544    ListIterable.forEach (dart:_internal/iterable.dart:49:13)
          #545    _InactiveElements._unmountAll (package:flutter/src/widgets/framework.dart:2128:25)

          #546    BuildOwner.lockState (package:flutter/src/widgets/framework.dart:3033:15)
          #547    BuildOwner.finalizeTree (package:flutter/src/widgets/framework.dart:3357:7)
          #548    AutomatedTestWidgetsFlutterBinding.drawFrame
(package:flutter_test/src/binding.dart:2454:19)
          #549    RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:558:5)
          #550    SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1430:15)
          #551    SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1345:9)
          #552    AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure>
(package:flutter_test/src/binding.dart:2261:9)
          #555    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
          #556    AutomatedTestWidgetsFlutterBinding.pump
(package:flutter_test/src/binding.dart:2250:27)
          #557    WidgetTester.pumpWidget.<anonymous closure>
(package:flutter_test/src/widget_tester.dart:598:22)
          #560    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
          #561    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
          #562    renderScreen
(file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:291:16)
          <asynchronous suspension>
          #563    main.<anonymous closure>.<anonymous closure>
(file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:85:7)
          <asynchronous suspension>
          #564    main.screenTest.<anonymous closure>
(file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:7)
          <asynchronous suspension>
          #565    testWidgets.<anonymous closure>.<anonymous closure>
(package:flutter_test/src/widget_tester.dart:192:15)
          <asynchronous suspension>
          #566    TestWidgetsFlutterBinding._runTestBody
(package:flutter_test/src/binding.dart:1953:5)
          <asynchronous suspension>
          <asynchronous suspension>
          (elided 5 frames from dart:async and package:stack_trace)
          ═════════════════════════════════════════════════════════════════

          ]
Beklenmeyen çizim hatası:
Bad state: Using "ref" when a widget is about to or has been unmounted is unsafe.
Ref relies on BuildContext, and BuildContext is unsafe to use when the widget is deactivated.
To safely refer to the state of providers inside State.dispose(), save the provider state in a field
of your State class.

When the exception was thrown, this was the stack:
#4      renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:311:5)
<asynchronous suspension>
#5      main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:85:7)
<asynchronous suspension>
#6      main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:7)
<asynchronous suspension>
#7      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#8      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart line 311
The test description was:
  Dualar: künye özeti ve kategori çipleri görünür
════════════════════════════════════════════════════════════════════════════════════════════════════
00:05 +88 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Dualar: künye özeti ve kategori çipleri görünür [E]
  Test failed. See exception logs above.
  The test description was: Dualar: künye özeti ve kategori çipleri görünür
  
00:05 +88 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Hadis: başlık ve konu çipleri görünür
[hadis tanısı] çipler: false · yükleniyor: true · metinler: Hadis metni veya konu ara | Hadisler yükleniyor… | Hadis | Sahih kaynaklardan seçkiler
00:05 +89 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Zikir: tesbih ekranı sayaç ile çizilir
00:05 +90 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Vakitler: liste başlığı ve ayar ipucu birlikte görünür
00:05 +91 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Kur'an: sure listesi yüklenir
00:05 +92 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Daha Fazla: tüm bölüm girişleri listelenir
00:05 +93 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir hata görünümü anlaşılır mesaj ve "Tekrar dene" sunar
00:05 +94 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir izni olmayan hatalarda "Tekrar dene" gösterilmez
00:05 +95 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir vakitler cihazda hesaplandıysa uyarı şeridi görünür
00:05 +96 -4: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: (tearDownAll)
00:06 +96 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı en az 20 kayıt ve benzersiz kimlikler
00:06 +97 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı her kayıtta başlık, cevap, anahtar kelime ve kaynak var
00:06 +98 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler küçük harf ve ASCII (arama uyumu)
00:06 +99 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler yeterince ayırt edici
00:06 +100 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı ilişkili kayıt kimlikleri geçerli
00:06 +101 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı mezhep farkı notları en az birkaç kayıtta bulunur
00:06 +102 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı kaynak künyeleri kaynak türüne ayrılabiliyor
00:06 +103 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi namaz rekatı sorusu doğru kayda gider
00:06 +104 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi abdest sorusu doğru kayda gider
00:06 +105 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi zekât sorusu doğru kayda gider
00:06 +106 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kıble sorusu doğru kayda gider
00:06 +107 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz
00:06 +108 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır
00:06 +109 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi konu kelimesi genel kelimelere üstün gelir (vitir/teravih)
00:06 +110 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi ayırt edici kelime puanı, genel kelimelerden yüksektir
00:06 +111 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi harf düşmesi olan sorular da eşleşir (hatim → hatmi)
00:06 +112 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Kâbe yönü sorusu kıble kaydına gider
00:06 +113 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi önerilen sorular kimlik değil, okunabilir başlık olarak döner
00:06 +114 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kayda uymayan soru için uydurma cevap üretilmez
00:06 +115 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi soru boşsa eşleşme yapılmaz
00:06 +116 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi paylaşım metni kaynakları ve mezhep notlarını içerir
00:06 +117 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İslam'ın şartları sorusuna beş şartı doğru sırayla ve kaynaklı cevaplar
00:06 +118 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:06 +119 -4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir
00:06 +120 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması WMM-2025 modeli 16 şehirde NOAA referansıyla eşleşir
00:06 +121 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması sapma işareti ve büyüklüğü jeofiziksel olarak tutarlı
00:06 +122 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması model geçerlilik aralığı dışında çökmek yerine sabitlenir
00:06 +123 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 1) Matematik katmanı — WMM-2025 manyetik sapması ondalık yıl çevrimi doğru
00:06 +124 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları dünya şehirleri için bilinen Kıble açıları
00:06 +125 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları Kâbe üzerinde açı 0° (kuzeye) döner, antipodda tanımsız değil
00:06 +126 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 2) Kâbe kerterizi (qibla bearing) referansları dijital pusula açısı gerçek kuzey açısıyla birebir aynıdır
00:06 +127 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri manyetik sapma gerçek kuzeye eklenir (Bağcılar)
00:06 +128 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri 0/360 sarmalaması doğru çalışır (batıya dönük kullanıcı)
00:06 +129 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri withQibla iki kez uygulansa da sonucu bozmaz (çift düzeltme yok)
00:06 +130 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri fark -180..180 aralığında ve en kısa yolu gösterir
00:06 +131 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri hizalama ve yakınlık eşikleri doğru
00:06 +132 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 3) Sensör katmanı — manyetik → gerçek kuzey zinciri geçersiz sensör paketleri reddedilir
00:06 +133 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi Kâbe rozeti her açıda doğru yerde durur
00:06 +134 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi kuzey etiketi telefonla birlikte döner
00:06 +135 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi hizalama yalnızca Kâbe yönünde gerçekleşir
00:06 +136 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi dönüş yönü işareti kullanıcıya doğru tarafı söyler
00:06 +137 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 4) Arayüz katmanı — e-Diyanet kadran geometrisi harita vektörü ekran koordinatında Kâbe yönünü gösterir
00:06 +138 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları Bağcılar: kullanıcı telefonu Kâbe yönüne çevirdiğinde hizalanır
00:06 +139 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları kuzey yarımküre ve güney yarımküre şehirlerinde tutarlı
00:06 +140 -4: /home/runner/work/ezanapp/ezanapp/test/data/qibla_verification_test.dart: 5) Uçtan uca gerçek kullanım senaryoları 30° yanlış sapma kullanılsa bile hata 30° ile sınırlı kalır
00:06 +141 -4: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket test modunda Google resmî test birim kimlikleri kullanılır
00:06 +142 -4: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket altyapı başlatılmadan reklam istenmez (boş alan/hata yok)
00:07 +143 -4: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket premium kullanıcıda reklam tamamen kapanır
00:07 +144 -4: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket geçiş reklamı bekleme süresi kullanıcı dostu (3 dakika)
00:07 +145 -4: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket reklam anahtarı varsayılan olarak açık, test modu kapalı
00:07 +146 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:07 +147 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
00:07 +148 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaklı uzak yanıt kabul edilir
  Skip: EZANAI_API_BASE tanımlı değil
00:07 +148 ~1 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaksız uzak yanıt reddedilir, yerel tabana düşülür
  Skip: EZANAI_API_BASE tanımlı değil
00:07 +148 ~2 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında sunucu hatasında (500) uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:07 +148 ~3 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bozuk JSON yanıtında uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:07 +148 ~4 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap
  Skip: EZANAI_API_BASE tanımlı değil
00:07 +148 ~5 -4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında uzak yanıtlara da öneri soruları eklenir
  Skip: EZANAI_API_BASE tanımlı değil
00:08 +148 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: (setUpAll)
00:08 +148 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası Diyanet resmî verisi ilk sırada kullanılır ve önbelleğe yazılır
00:08 +149 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası Diyanet başarısızsa AlAdhan devreye girer
00:08 +150 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası her iki servis de çökerse yerel hesap devreye girer
00:08 +151 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası tutarsız (bozuk) servis verisi reddedilir ve zincir devam eder
00:08 +152 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış çevrimdışıyken son başarılı veri önbellekten okunur
00:08 +153 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış süresi geçmiş (6 saatten eski) önbellek kullanılmaz
00:08 +154 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış çevrimdışı ve önbellek boşsa yerel hesap sonuç üretir
00:08 +155 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış ilçe seçilmemişse (GPS) resmî servis çağrılmaz, hesap kullanılır
00:08 +156 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış bellek önbelleği aynı gün için tekrar sorguda ağa çıkmaz
00:08 +157 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış zorla yenileme önbelleği atlar
00:08 +158 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli JSON ayrıştırma tüm alanları okur
00:08 +159 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek aralığı kapsıyorsa ağa çıkılmaz
00:08 +160 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek aralığı kapsıyorsa ağa çıkılmaz
00:08 +161 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli kaynak künyesi paylaşım metninde yer alır
00:08 +162 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +163 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +164 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +165 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +166 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +167 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +168 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:08 +169 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog sorguya göre süzer
00:08 +170 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) resmî yanıt çözümlenir (zarf + hicri tarih)
00:08 +171 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) resmî yanıt çözümlenir (zarf + hicri tarih)
00:08 +172 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) resmî yanıt çözümlenir (zarf + hicri tarih)
00:08 +173 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:08 +174 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) bozuk JSON çökme yerine kaynak hatası üretir
00:08 +175 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) ilçe kimliği yoksa servis çağrılmadan hata verir
00:08 +176 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) AlAdhan yanıtı çözümlenir ve hicri etiket üretilir
00:09 +177 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) AlAdhan boş vakit verisinde hata üretir
00:09 +178 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: kaynak bilgisi (kullanıcı mesajları) resmî veri varken son güncelleme bilgisi gösterilir
00:09 +179 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: kaynak bilgisi (kullanıcı mesajları) konum seçilmemişse hesap bilgisi gösterilir
00:09 +180 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: yerel hesap kalibrasyonu Diyanet yöntemiyle İstanbul için tutarlı vakitler üretir
00:09 +181 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: (tearDownAll)
00:09 +181 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:09 +181 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kategoriler tanımlı ve benzersiz
00:09 +182 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: en az 30 dua var ve kimlikler benzersiz
00:09 +183 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada ad, okunuş, meal ve kategori dolu
00:09 +184 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada kaynak künyesi var
00:09 +185 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kaynak künyeleri ya Kur'an ya muteber hadis kaynağına dayanır
00:09 +186 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duanın kategorisi kategori listesinde tanımlı
00:09 +187 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her kategoride en az bir dua var (boş sekme olmasın)
00:09 +188 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Kur'an kaynaklı duaların künyesi sure/ayet içerir
00:09 +189 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Arapça metin içeren dualar Arapça alfabede
00:09 +190 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: katalogda arama ve kategori süzme çalışıyor
00:09 +191 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (tearDownAll)
00:10 +191 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: (setUpAll)
00:10 +191 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: AI kota, kaynak doğrulama ve fetva güvenliği günlük kota dolsa bile İslam'ın ve imanın şartları gibi onaylı cevaplar engellenmez
00:10 +192 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: AI kota, kaynak doğrulama ve fetva güvenliği fetva soruları tespit edilir ve uydurma kaynaklar elenir
00:10 +193 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) gün içinde aktif vakit, sıradaki vakit ve geri sayım tutarlıdır
00:10 +194 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) yatsı sonrasında sıradaki vakit yarının imsakıdır
00:10 +195 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) gece yarısı geçildiğinde aktif gün otomatik olarak yarına devreder
00:10 +196 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) hesaplama yöntemi ve Hanefî ikindi değişimi vakitleri yeniler
00:10 +197 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +198 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +199 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +200 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +201 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +202 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +203 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +204 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +205 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:10 +206 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim kaydedilir ve en yeni önce döner
00:10 +207 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim kaydedilir ve en yeni önce döner
00:10 +208 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon manyetik kuzey sapması gerçek kuzeye doğru eklenir
00:10 +209 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi uzun yanıt 280 karakterlik özetle saklanır
00:10 +210 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon manyetik parazit ve telefon eğimi ayrı uyarılarla bildirilir
00:10 +211 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim nedenleri kullanıcıya anlaşılır ve sıralı
00:10 +212 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Gizlilik ve log temizliği AppLog.sanitize koordinat, e-posta ve anahtarları maskeler
00:10 +213 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi JSON gidiş-dönüşü kaybolmadan çalışır
00:10 +214 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu varsayılan ezan sesi Hicaz makamıdır ve vakit bazlı ses özelleştirmesi korunur
00:10 +215 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:10 +216 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu bildirim seslerinde çan ifadesi yer almaz; telifsiz ilahi ve ezan makamları kullanılır
00:10 +217 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu uygulama adı Ezan Vaktim Pro, dil desteği TR/EN/AR, meal seçimi, saat geri alma ve Esmaül Hüsna doğrulanır
00:10 +218 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:11 +219 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Nafile namaz alarmları, Kâbe İmamı ezanı, global Kur'an oturumu ve genişletilmiş İslami Asistan doğrulanır
00:11 +220 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Bağcılar dahil tüm büyükşehir merkez ilçeleri GPS koordinatıyla doğru tespit edilir
00:11 +221 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: (tearDownAll)
00:11 +221 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:11 +221 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: doğrulama verisi yüklendi
00:11 +222 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±3 dakika içinde kalır
00:11 +223 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada
00:11 +224 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: Hanefî ikindi vakti Şâfiî'den sonra olur
00:11 +225 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:11 +226 ~6 -4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (tearDownAll)
00:11 +226 ~6 -4: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Dualar: künye özeti ve kategori çipleri görünür
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Dualar — küçük telefon 320×568
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Dualar — tablet 1024×1366
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Dualar — telefon 411×914
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
[=================                      ] 45% Unzipping... android-ndk-r28c/tool
[==================                     ] 45% Unzipping... android-ndk-r28c/tool
[==================                     ] 46% Unzipping... android-ndk-r28c/tool
[==================                     ] 47% Unzipping... android-ndk-r28c/tool
[===================                    ] 48% Unzipping... android-ndk-r28c/tool
[===================                    ] 49% Unzipping... android-ndk-r28c/tool
[===================                    ] 50% Unzipping... android-ndk-r28c/tool
[====================                   ] 50% Unzipping... android-ndk-r28c/tool
[====================                   ] 51% Unzipping... android-ndk-r28c/tool
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
lib/features/widgets/home_widget_sync.dart:45:8: Error: No named parameter with the name 'fireImmediately'.
    }, fireImmediately: true);
       ^^^^^^^^^^^^^^^
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
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.8-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 4m 57s
Running Gradle task 'assembleRelease'...                          297.7s
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
lib/features/widgets/home_widget_sync.dart:45:8: Error: No named parameter with the name 'fireImmediately'.
    }, fireImmediately: true);
       ^^^^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.8-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 57s
Running Gradle task 'bundleRelease'...                             57.8s
Gradle task bundleRelease failed with exit code 1
```
