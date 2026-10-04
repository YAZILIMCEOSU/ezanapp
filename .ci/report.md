# CI raporu (2026-10-04 13:47 UTC)

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

7 fixes made in 6 files.
== dart format ==
Formatted lib/core/services/push_service.dart
Formatted lib/core/services/sync_service.dart
Formatted lib/features/settings/backup_screen.dart
Formatted test/core/text_normalizer_test.dart
Formatted test/data/models_test.dart
Formatted 93 files (5 changed) in 0.94 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

  error • The getter 'inAppAdhan' isn't defined for the type 'NotificationSettings'. Try importing the library that defines 'inAppAdhan', correcting the name to the name of an existing getter, or defining a getter or field named 'inAppAdhan' • lib/app/app.dart:47:35 • undefined_getter
warning • The value of the field '_app' isn't used. Try removing the field, or using it • lib/core/services/push_service.dart:78:16 • unused_field
   info • 'anonKey' is deprecated and shouldn't be used. Use publishableKey instead. anonKey will be removed in a future major version. Try replacing the use of the deprecated member with the replacement • lib/core/services/sync_service.dart:66:11 • deprecated_member_use
  error • There's no constant named 'buffering' in 'PlaybackStatus'. Try correcting the name to the name of an existing constant, or defining a constant named 'buffering' • lib/features/ilahi/player_controller.dart:45:68 • undefined_enum_constant
  error • The expression doesn't evaluate to a function, so it can't be invoked • lib/features/ilahi/player_controller.dart:328:35 • invocation_of_non_function_expression
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/more/islamic_days_screen.dart:69:17 • creation_with_non_type
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/more/islamic_days_screen.dart:121:17 • creation_with_non_type
  error • The method 'push' isn't defined for the type 'BuildContext'. Try correcting the name to the name of an existing method, or defining a method named 'push' • lib/features/qibla/qibla_screen.dart:110:44 • undefined_method
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/qibla/qibla_screen.dart:159:17 • creation_with_non_type
  error • The name 'AyahSearchResult' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AyahSearchResult' • lib/features/quran/quran_search_screen.dart:27:8 • non_type_as_type_argument
  error • The name 'AyahSearchResult' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AyahSearchResult' • lib/features/quran/quran_search_screen.dart:27:44 • non_type_as_type_argument
  error • The name 'AyahSearchResult' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AyahSearchResult' • lib/features/quran/quran_search_screen.dart:59:27 • non_type_as_type_argument
  error • The name 'AyahSearchResult' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AyahSearchResult' • lib/features/quran/quran_search_screen.dart:70:18 • non_type_as_type_argument
  error • A value of type 'dynamic' can't be assigned to a variable of type 'List<InvalidType>'. Try changing the type of the variable, or casting the right-hand type to 'List<InvalidType>' • lib/features/quran/quran_search_screen.dart:70:46 • invalid_assignment
warning • The type argument(s) of the function 'read' can't be inferred. Use explicit type argument(s) for 'read' • lib/features/quran/quran_search_screen.dart:71:12 • inference_failure_on_function_invocation
  error • Undefined name 'runtimeProvider'. Try correcting the name to one that is defined, or defining the name • lib/features/quran/quran_search_screen.dart:71:17 • undefined_identifier
  error • Undefined class 'AyahSearchResult'. Try changing the name to the name of an existing class, or creating a class with the name 'AyahSearchResult' • lib/features/quran/quran_search_screen.dart:174:15 • undefined_class
  error • The getter 'values' isn't defined for the type 'Iterable<ItemPosition>'. Try importing the library that defines 'values', correcting the name to the name of an existing getter, or defining a getter or field named 'values' • lib/features/quran/surah_screen.dart:49:75 • undefined_getter
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/ramadan/ramadan_screen.dart:190:17 • creation_with_non_type
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/ramadan/ramadan_screen.dart:192:17 • creation_with_non_type
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/ramadan/ramadan_screen.dart:194:17 • creation_with_non_type
  error • The name 'SectionHeader' isn't a class. Try correcting the name to match an existing class • lib/features/ramadan/ramadan_screen.dart:196:17 • creation_with_non_type
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check. Guard a 'State.context' use with a 'mounted' check on the State, and other BuildContext use with a 'mounted' check on the BuildContext • lib/features/settings/notification_settings_screen.dart:345:36 • use_build_context_synchronously
warning • Dead code. Try removing the code, or fixing the code before it so that it can be reached • lib/features/zikir/zikir_screen.dart:288:64 • dead_code
warning • The left operand can't be null, so the right operand is never executed. Try removing the operator and the right operand • lib/features/zikir/zikir_screen.dart:288:67 • dead_null_aware_expression
  error • The name 'Override' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Override' • lib/main.dart:54:21 • non_type_as_type_argument
  error • A value of type 'dynamic' can't be assigned to a variable of type 'Object'. Try changing the type of the variable, or casting the right-hand type to 'Object' • test/prayer_calculation_test.dart:22:28 • invalid_assignment

27 issues found. (ran in 20.6s)
```

## test
```
  package:intl/src/intl_helpers.dart 222:19      verifiedLocale
  package:intl/src/intl/date_format.dart 267:25  new DateFormat
  package:ezanai/core/utils/app_time.dart 58:12  AppTime.formatTime
  test/core/text_normalizer_test.dart 65:22      main.<fn>.<fn>
  
00:00 +14 -6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:00 +15 -6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:00 +16 -6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay bozuk veri sağlıksız kabul edilir
00:00 +17 -6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
00:00 +18 -6: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:00 +18 -6: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: doğrulama verisi yüklendi
00:00 +19 -6: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±3 dakika içinde kalır
00:00 +19 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yerel hesap, Diyanet vakitlerine ±3 dakika içinde kalır [E]
  Expected: empty
    Actual: [
              'Adana 2022-01-15 imsak: hesap 18:20, Diyanet 06:20 (20520.0 dk)',
              'Adana 2022-01-15 gunes: hesap 19:44, Diyanet 07:44 (24059.6 dk)',
              'Adana 2022-01-15 ogle: hesap 00:53, Diyanet 12:53 (43199.7 dk)',
              'Adana 2022-01-15 ikindi: hesap 03:30, Diyanet 15:30 (53819.8 dk)',
              'Adana 2022-01-15 aksam: hesap 05:52, Diyanet 17:52 (60899.8 dk)',
              'Adana 2022-01-15 yatsi: hesap 07:11, Diyanet 19:11 (67979.5 dk)',
              'Adana 2022-03-21 imsak: hesap 17:15, Diyanet 05:15 (16979.9 dk)',
              'Adana 2022-03-21 gunes: hesap 18:35, Diyanet 06:34 (20519.0 dk)',
              'Adana 2022-03-21 ogle: hesap 00:51, Diyanet 12:51 (43199.5 dk)',
              'Adana 2022-03-21 ikindi: hesap 04:17, Diyanet 16:17 (57359.7 dk)',
              'Adana 2022-03-21 aksam: hesap 06:58, Diyanet 18:58 (64440.0 dk)',
              'Adana 2022-03-21 yatsi: hesap 08:13, Diyanet 20:12 (71519.3 dk)',
              'Adana 2022-06-21 imsak: hesap 15:27, Diyanet 03:27 (9899.7 dk)',
              'Adana 2022-06-21 gunes: hesap 17:13, Diyanet 05:12 (16979.2 dk)',
              'Adana 2022-06-21 ogle: hesap 00:46, Diyanet 12:45 (43199.2 dk)',
              'Adana 2022-06-21 ikindi: hesap 04:37, Diyanet 16:37 (57360.2 dk)',
              'Adana 2022-06-21 aksam: hesap 08:09, Diyanet 20:09 (71520.2 dk)',
              'Adana 2022-06-21 yatsi: hesap 09:47, Diyanet 21:46 (75059.4 dk)',
              'Adana 2022-09-23 imsak: hesap 17:01, Diyanet 05:00 (16979.5 dk)',
              'Adana 2022-09-23 gunes: hesap 18:20, Diyanet 06:20 (20519.6 dk)',
              'Adana 2022-09-23 ogle: hesap 00:37, Diyanet 12:36 (43199.3 dk)',
              'Adana 2022-09-23 ikindi: hesap 04:02, Diyanet 16:02 (57359.5 dk)',
              'Adana 2022-09-23 aksam: hesap 06:43, Diyanet 18:42 (64439.0 dk)',
              'Adana 2022-09-23 yatsi: hesap 07:58, Diyanet 19:57 (67979.3 dk)',
              ...
            ]
  Adana 2022-01-15 imsak: hesap 18:20, Diyanet 06:20 (20520.0 dk)
  Adana 2022-01-15 gunes: hesap 19:44, Diyanet 07:44 (24059.6 dk)
  Adana 2022-01-15 ogle: hesap 00:53, Diyanet 12:53 (43199.7 dk)
  Adana 2022-01-15 ikindi: hesap 03:30, Diyanet 15:30 (53819.8 dk)
  Adana 2022-01-15 aksam: hesap 05:52, Diyanet 17:52 (60899.8 dk)
  Adana 2022-01-15 yatsi: hesap 07:11, Diyanet 19:11 (67979.5 dk)
  Adana 2022-03-21 imsak: hesap 17:15, Diyanet 05:15 (16979.9 dk)
  Adana 2022-03-21 gunes: hesap 18:35, Diyanet 06:34 (20519.0 dk)
  Adana 2022-03-21 ogle: hesap 00:51, Diyanet 12:51 (43199.5 dk)
  Adana 2022-03-21 ikindi: hesap 04:17, Diyanet 16:17 (57359.7 dk)
  Adana 2022-03-21 aksam: hesap 06:58, Diyanet 18:58 (64440.0 dk)
  Adana 2022-03-21 yatsi: hesap 08:13, Diyanet 20:12 (71519.3 dk)
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/prayer_calculation_test.dart 93:5              main.<fn>
  
00:00 +19 -7: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada
00:00 +19 -8: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: vakitler gün içinde artan sırada [E]
  Expected: a value greater than <17.41661458903598>
    Actual: <1.1797826165299405>
     Which: is not a value greater than <17.41661458903598>
  1. vakit sonraki vakitten geç olmamalı
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/prayer_calculation_test.dart 105:7             main.<fn>
  
00:00 +19 -8: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: Hanefî ikindi vakti Şâfiî'den sonra olur
00:00 +20 -8: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:00 +21 -8: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (tearDownAll)
00:00 +21 -8: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime 24 saat ve 12 saat biçimi
  /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer ekleri kaba biçimde kırpar
  /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
  /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings bozuk yedek varsayılanlara döner
  ... and 4 more
```

## build
```
                                           ^^^^^^^^^^^^^^^^
lib/features/quran/quran_search_screen.dart:59:27: Error: 'AyahSearchResult' isn't a type.
        _results = const <AyahSearchResult>[];
                          ^^^^^^^^^^^^^^^^
lib/features/quran/quran_search_screen.dart:70:18: Error: 'AyahSearchResult' isn't a type.
      final List<AyahSearchResult> results = await ref
                 ^^^^^^^^^^^^^^^^
lib/features/quran/quran_search_screen.dart:71:17: Error: The getter 'runtimeProvider' isn't defined for the type '_QuranSearchScreenState'.
 - '_QuranSearchScreenState' is from 'package:ezanai/features/quran/quran_search_screen.dart' ('lib/features/quran/quran_search_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'runtimeProvider'.
          .read(runtimeProvider)
                ^^^^^^^^^^^^^^^
lib/features/quran/quran_search_screen.dart:174:15: Error: 'AyahSearchResult' isn't a type.
        final AyahSearchResult result = _results[index];
              ^^^^^^^^^^^^^^^^
lib/features/quran/surah_screen.dart:49:75: Error: The getter 'values' isn't defined for the type 'Iterable<ItemPosition>'.
 - 'Iterable' is from 'dart:core'.
 - 'ItemPosition' is from 'package:scrollable_positioned_list/src/item_positions_listener.dart' ('../../../.pub-cache/hosted/pub.dev/scrollable_positioned_list-0.3.8/lib/src/item_positions_listener.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'values'.
    final Iterable<ItemPosition> visible = _positions.itemPositions.value.values
                                                                          ^^^^^^
lib/features/ramadan/ramadan_screen.dart:190:17: Error: Not a constant expression.
          const SectionHeader(title: 'Hatim takibi'),
                ^^^^^^^^^^^^^
lib/features/ramadan/ramadan_screen.dart:192:17: Error: Not a constant expression.
          const SectionHeader(title: 'Kaza orucu takibi'),
                ^^^^^^^^^^^^^
lib/features/ramadan/ramadan_screen.dart:194:17: Error: Not a constant expression.
          const SectionHeader(title: 'İmsakiye'),
                ^^^^^^^^^^^^^
lib/features/ramadan/ramadan_screen.dart:196:17: Error: Not a constant expression.
          const SectionHeader(title: 'Günün duası'),
                ^^^^^^^^^^^^^
lib/features/ilahi/player_controller.dart:45:68: Error: Member not found: 'buffering'.
      status == PlaybackStatus.loading || status == PlaybackStatus.buffering;
                                                                   ^^^^^^^^^
lib/features/ilahi/player_controller.dart:328:51: Error: The method 'call' isn't defined for the type 'String'.
Try correcting the name to the name of an existing method, or defining a method named 'call'.
        onTap: () => context.push(AppRoutes.player(player.track!.id)),
                                                  ^
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.6-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 4m 7s
Running Gradle task 'assembleDebug'...                            248.6s
Gradle task assembleDebug failed with exit code 1
```
