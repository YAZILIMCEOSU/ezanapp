# CI raporu (2026-10-04 13:19 UTC)

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
Changed lib/core/services/connectivity_service.dart
Changed lib/core/services/location_service.dart
Changed lib/core/services/notification_service.dart
Changed lib/core/services/preferences_service.dart
Changed lib/core/utils/app_time.dart
Changed lib/core/utils/geo.dart
Changed lib/core/utils/logger.dart
Changed lib/core/utils/text_normalizer.dart
Changed lib/data/ai/ai_service.dart
Changed lib/data/ai/knowledge_base.dart
Changed lib/data/hijri/hijri_calendar.dart
Changed lib/data/models/ai_models.dart
Changed lib/data/models/app_settings.dart
Changed lib/data/models/city.dart
Changed lib/data/models/hadith_models.dart
Changed lib/data/models/hijri_date.dart
Changed lib/data/models/ilahi_models.dart
Changed lib/data/models/prayer.dart
Changed lib/data/models/prayer_times_day.dart
Changed lib/data/models/quran_models.dart
Changed lib/data/models/ramadan_models.dart
Changed lib/data/models/zikir_models.dart
Changed lib/data/prayer/aladhan_api_source.dart
Changed lib/data/prayer/diyanet_api_source.dart
Changed lib/data/prayer/local_calculation_source.dart
Changed lib/data/prayer/prayer_calculator.dart
Changed lib/data/prayer/prayer_times_cache.dart
Changed lib/data/prayer/prayer_times_repository.dart
Changed lib/data/prayer/prayer_times_source.dart
Changed lib/data/repositories/ai_repository.dart
Changed lib/data/repositories/daily_content_repository.dart
Changed lib/data/repositories/hadith_repository.dart
Changed lib/data/repositories/ilahi_repository.dart
Changed lib/data/repositories/quran_repository.dart
Changed lib/data/repositories/ramadan_repository.dart
Changed lib/data/repositories/zikir_repository.dart
Changed lib/design/app_colors.dart
Changed lib/design/app_spacing.dart
Changed lib/design/app_theme.dart
Formatted 47 files (44 changed) in 0.14 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

warning • Support for legacy plugins is deprecated, and will be removed in an upcoming version of Dart. See https://dart.dev/tools/analyzer-plugins for documentation regarding the new analyzer plugin system • analysis_options.yaml:14:3 • analysis_options_deprecated_plugins
  error • The named parameter 'stackTrace' isn't defined. Try correcting the name to an existing named parameter's name, or defining a named parameter with the name 'stackTrace' • lib/core/audio/audio_service.dart:72:69 • undefined_named_parameter
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/audio/audio_service.dart:115:8 • require_trailing_commas
warning • Unused import: 'package:flutter/foundation.dart'. Try removing the import directive • lib/core/services/notification_service.dart:5:8 • unused_import
   info • The type of the right operand ('int') isn't a subtype or a supertype of the left operand ('Duration'). Try changing one or both of the operands • lib/core/services/notification_service.dart:148:45 • unrelated_type_equality_checks
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/services/notification_service.dart:179:76 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/services/notification_service.dart:181:63 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/services/notification_service.dart:183:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/services/notification_service.dart:185:65 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/services/notification_service.dart:187:82 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/core/services/notification_service.dart:189:59 • require_trailing_commas
  error • The name 'PlatformException' isn't a type and can't be used in an on-catch clause. Try correcting the name to match an existing class • lib/core/services/notification_service.dart:503:10 • non_type_in_catch_clause
   info • Local variables should be final. Try making the variable final • lib/core/services/notification_service.dart:590:5 • prefer_final_locals
   info • Use 'const' for final variables initialized to a constant value. Try replacing 'final' with 'const' • lib/core/utils/geo.dart:28:5 • prefer_const_declarations
  error • Undefined name 'AppLogger'. Try correcting the name to one that is defined, or defining the name • lib/data/ai/ai_service.dart:156:9 • undefined_identifier
  error • Undefined name 'AppLogger'. Try correcting the name to one that is defined, or defining the name • lib/data/ai/ai_service.dart:157:9 • undefined_identifier
   info • Use 'const' for final variables initialized to a constant value. Try replacing 'final' with 'const' • lib/data/ai/ai_service.dart:242:5 • prefer_const_declarations
  error • A value of type 'List<double>' can't be assigned to a variable of type 'List<int>'. Try changing the type of the variable, or casting the right-hand type to 'List<int>' • lib/data/hijri/hijri_calendar.dart:37:9 • invalid_assignment
  error • The method 'charCodeAt' isn't defined for the type 'String'. Try correcting the name to the name of an existing method, or defining a method named 'charCodeAt' • lib/data/hijri/hijri_calendar.dart:37:56 • undefined_method
warning • Unused import: '../../core/constants/app_constants.dart'. Try removing the import directive • lib/data/models/app_settings.dart:6:8 • unused_import
warning • The value of the field '_asrOverridable' isn't used. Try removing the field, or using it • lib/data/models/app_settings.dart:448:28 • unused_field
   info • Unnecessary braces in a string interpolation. Try removing the braces • lib/data/models/hadith_models.dart:61:40 • unnecessary_brace_in_string_interps
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/prayer/aladhan_api_source.dart:57:52 • require_trailing_commas
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:82:23 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:83:23 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:84:22 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:85:24 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:86:23 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:87:23 • map_value_type_not_assignable
warning • The receiver can't be 'null' because of short-circuiting, so the null-aware operator '?[' can't be used. Try replacing the operator '?[' with '[' • lib/data/prayer/aladhan_api_source.dart:99:81 • invalid_null_aware_operator
warning • The receiver can't be 'null' because of short-circuiting, so the null-aware operator '?[' can't be used. Try replacing the operator '?[' with '[' • lib/data/prayer/aladhan_api_source.dart:99:141 • invalid_null_aware_operator
warning • The receiver can't be 'null' because of short-circuiting, so the null-aware operator '?[' can't be used. Try replacing the operator '?[' with '[' • lib/data/prayer/aladhan_api_source.dart:145:63 • invalid_null_aware_operator
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:163:25 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:164:25 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:165:24 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:166:26 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:167:25 • map_value_type_not_assignable
  error • The element type 'DateTime?' can't be assigned to the map value type 'DateTime' • lib/data/prayer/aladhan_api_source.dart:168:25 • map_value_type_not_assignable
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/prayer/aladhan_api_source.dart:176:12 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/prayer/diyanet_api_source.dart:78:80 • require_trailing_commas
   info • Local variables should be final. Try making the variable final • lib/data/prayer/prayer_calculator.dart:344:5 • prefer_final_locals
   info • Local variables should be final. Try making the variable final • lib/data/prayer/prayer_calculator.dart:345:5 • prefer_final_locals
  error • The argument type 'int' can't be assigned to the parameter type 'double'.  • lib/data/prayer/prayer_calculator.dart:396:27 • argument_type_not_assignable
  error • The argument type 'int' can't be assigned to the parameter type 'double'.  • lib/data/prayer/prayer_calculator.dart:397:27 • argument_type_not_assignable
  error • The argument type 'int' can't be assigned to the parameter type 'double'.  • lib/data/prayer/prayer_calculator.dart:398:26 • argument_type_not_assignable
  error • The argument type 'int' can't be assigned to the parameter type 'double'.  • lib/data/prayer/prayer_calculator.dart:399:29 • argument_type_not_assignable
  error • The argument type 'int' can't be assigned to the parameter type 'double'.  • lib/data/prayer/prayer_calculator.dart:400:27 • argument_type_not_assignable
  error • The argument type 'int' can't be assigned to the parameter type 'double'.  • lib/data/prayer/prayer_calculator.dart:401:27 • argument_type_not_assignable
warning • Unused import: '../../core/services/location_service.dart'. Try removing the import directive • lib/data/prayer/prayer_times_repository.dart:6:8 • unused_import
  error • The argument type 'String' can't be assigned to the parameter type 'CalculationMethod?'.  • lib/data/prayer/prayer_times_repository.dart:182:76 • argument_type_not_assignable
   info • Use the null-aware operator '?.' rather than an explicit 'null' comparison. Try using '?.' • lib/data/prayer/prayer_times_repository.dart:201:18 • prefer_null_aware_operators
  error • Undefined name 'AppLogger'. Try correcting the name to one that is defined, or defining the name • lib/data/repositories/ai_repository.dart:104:9 • undefined_identifier
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/hadith_repository.dart:108:56 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:233:8 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ilahi_repository.dart:351:8 • require_trailing_commas
   info • Use 'const' with the constructor to improve performance. Try adding the 'const' keyword to the constructor invocation • lib/data/repositories/quran_repository.dart:51:14 • prefer_const_constructors
  error • Target of URI doesn't exist: 'prayer_times_repository.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/data/repositories/ramadan_repository.dart:9:8 • uri_does_not_exist
  error • Undefined class 'PrayerTimesRepository'. Try changing the name to the name of an existing class, or creating a class with the name 'PrayerTimesRepository' • lib/data/repositories/ramadan_repository.dart:16:9 • undefined_class
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ramadan_repository.dart:243:66 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/ramadan_repository.dart:244:33 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • lib/data/repositories/zikir_repository.dart:73:14 • require_trailing_commas
   info • Use 'const' with the constructor to improve performance. Try adding the 'const' keyword to the constructor invocation • lib/data/repositories/zikir_repository.dart:106:34 • prefer_const_constructors
  error • Invalid constant value • lib/design/app_theme.dart:134:31 • invalid_constant
  error • The method 'CupertinoPageTransitionsBuilder' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'CupertinoPageTransitionsBuilder' • lib/design/app_theme.dart:134:31 • undefined_method
  error • The values in a const map literal must be constant. Try removing the keyword 'const' from the map literal • lib/design/app_theme.dart:134:31 • non_constant_map_value
warning • The asset directory 'assets/images/' doesn't exist. Try creating the directory or fixing the path to the directory • pubspec.yaml:81:7 • asset_directory_does_not_exist

66 issues found. (ran in 9.4s)
```

## test
```
Error: unable to find directory entry in pubspec.yaml: /home/runner/work/ezanapp/ezanapp/assets/images/
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

BUILD FAILED in 1m 32s
Running Gradle task 'assembleDebug'...                             94.6s

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
