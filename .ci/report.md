# CI raporu (2026-10-04 13:24 UTC)

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
  prefer_const_declarations - 1 fix

lib/data/models/app_settings.dart
  directives_ordering - 1 fix

lib/data/models/hadith_models.dart
  unnecessary_brace_in_string_interps - 1 fix

lib/data/prayer/aladhan_api_source.dart
  require_trailing_commas - 2 fixes

lib/data/prayer/diyanet_api_source.dart
  require_trailing_commas - 1 fix

lib/data/prayer/prayer_calculator.dart
  prefer_final_locals - 2 fixes

lib/data/prayer/prayer_times_repository.dart
  prefer_null_aware_operators - 1 fix

lib/data/repositories/hadith_repository.dart
  require_trailing_commas - 1 fix

lib/data/repositories/ilahi_repository.dart
  require_trailing_commas - 2 fixes

lib/data/repositories/quran_repository.dart
  prefer_const_constructors - 1 fix

lib/data/repositories/ramadan_repository.dart
  require_trailing_commas - 2 fixes

lib/data/repositories/zikir_repository.dart
  prefer_const_constructors - 1 fix
  require_trailing_commas - 1 fix

lib/state/providers.dart
  prefer_null_aware_operators - 1 fix

27 fixes made in 16 files.
== dart format ==
Formatted lib/data/prayer/aladhan_api_source.dart
Formatted lib/data/prayer/diyanet_api_source.dart
Formatted lib/data/prayer/local_calculation_source.dart
Formatted lib/data/prayer/prayer_calculator.dart
Formatted lib/data/prayer/prayer_times_cache.dart
Formatted lib/data/prayer/prayer_times_repository.dart
Formatted lib/data/prayer/prayer_times_source.dart
Formatted lib/data/repositories/ai_repository.dart
Formatted lib/data/repositories/city_repository.dart
Formatted lib/data/repositories/daily_content_repository.dart
Formatted lib/data/repositories/hadith_repository.dart
Formatted lib/data/repositories/ilahi_repository.dart
Formatted lib/data/repositories/quran_repository.dart
Formatted lib/data/repositories/ramadan_repository.dart
Formatted lib/data/repositories/zikir_repository.dart
Formatted lib/design/app_colors.dart
Formatted lib/design/app_spacing.dart
Formatted lib/design/app_theme.dart
Formatted lib/state/providers.dart
Formatted 52 files (49 changed) in 0.18 seconds.
```

## analyze
```
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:78:75 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:80:62 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:108:61 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:108:62 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:108:63 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:135:71 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ai_repository.dart:188:57 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/city_repository.dart:30:69 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/city_repository.dart:137:48 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/city_repository.dart:185:33 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/city_repository.dart:275:61 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/daily_content_repository.dart:74:39 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/daily_content_repository.dart:105:54 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/hadith_repository.dart:47:57 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/hadith_repository.dart:51:78 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/hadith_repository.dart:56:47 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/hadith_repository.dart:151:59 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:85:61 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:123:61 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:150:64 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:150:65 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:164:50 • require_trailing_commas
   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/data/repositories/ilahi_repository.dart:166:7 • curly_braces_in_flow_control_structures
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:176:70 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:203:47 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:223:61 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:277:47 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:313:63 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:410:67 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/quran_repository.dart:35:54 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/quran_repository.dart:89:47 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/quran_repository.dart:125:65 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/quran_repository.dart:125:66 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/quran_repository.dart:282:31 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/quran_repository.dart:299:73 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ramadan_repository.dart:150:29 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ramadan_repository.dart:193:52 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ramadan_repository.dart:246:21 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/zikir_repository.dart:32:56 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/zikir_repository.dart:36:47 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/zikir_repository.dart:156:7 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/zikir_repository.dart:212:70 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_colors.dart:64:3 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_colors.dart:68:3 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_colors.dart:72:3 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:209:63 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:334:23 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:340:23 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:346:23 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:351:24 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:356:24 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:361:24 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:377:22 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/design/app_theme.dart:385:46 • require_trailing_commas
  error • The getter 'valueOrNull' isn't defined for the type 'AsyncValue<bool>'. Try importing the library that defines 'valueOrNull', correcting the name to the name of an existing getter, or defining a getter or field named 'valueOrNull' • lib/state/providers.dart:37:39 • undefined_getter
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:48:43 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:64:79 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:89:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:106:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:110:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:130:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:134:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:138:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:142:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:180:32 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:274:72 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:280:51 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:353:19 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:430:32 • require_trailing_commas
  error • Arguments of a constant creation must be constant expressions. Try making the argument a valid constant, or use 'new' to call the constructor • lib/state/providers.dart:434:17 • const_with_non_constant_argument
  error • The getter 'tiles_rounded' isn't defined for the type 'Icons'. Try importing the library that defines 'tiles_rounded', correcting the name to the name of an existing getter, or defining a getter or field named 'tiles_rounded' • lib/state/providers.dart:434:23 • undefined_getter
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:453:38 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:488:32 • require_trailing_commas
  error • Undefined class 'AutoDisposeStreamProvider'. Try changing the name to the name of an existing class, or creating a class with the name 'AutoDisposeStreamProvider' • lib/state/providers.dart:491:7 • undefined_class
   info • Type could be non-nullable. Try changing the type to be non-nullable • lib/state/providers.dart:491:43 • unnecessary_nullable_for_final_variable_declarations
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:494:56 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:621:79 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/state/providers.dart:634:67 • require_trailing_commas

206 issues found. (ran in 4.9s)
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

FAILURE: Build failed with an exception.

* Where:
Build file '/home/runner/work/ezanapp/ezanapp/android/app/build.gradle.kts' line: 3

* What went wrong:
An exception occurred applying plugin request [id: 'dev.flutter.flutter-gradle-plugin']
> Failed to apply plugin 'dev.flutter.flutter-gradle-plugin'.
   > Error: Your project's Gradle version (8.12.0) is lower than Flutter's minimum supported version of 8.14.0. Please upgrade your Gradle version. 
     Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

     Potential fix: Your project's gradle version is typically defined in the gradle wrapper file. By default, this can be found at /home/runner/work/ezanapp/ezanapp/android/gradle/wrapper/gradle-wrapper.properties. 
     For more information, see https://docs.gradle.org/current/userguide/gradle_wrapper.html.


* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 33s
Running Gradle task 'assembleDebug'...                             95.5s

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
