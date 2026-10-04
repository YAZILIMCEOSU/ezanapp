# CI raporu (2026-10-04 13:08 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | success |
| test | success |
| build | success |

## pubget
```
Resolving dependencies...
Because flutter_local_notifications >=22.0.0 <23.0.0-dev.1 depends on flutter_local_notifications_linux ^8.0.1 which depends on dbus ^0.7.8, flutter_local_notifications >=22.0.0 <23.0.0-dev.1 requires dbus ^0.7.8.
And because connectivity_plus >=7.3.2 depends on nm ^0.6.0 which depends on dbus ^0.8.0, flutter_local_notifications >=22.0.0 <23.0.0-dev.1 is incompatible with connectivity_plus >=7.3.2.
So, because ezanai depends on both connectivity_plus ^7.3.2 and flutter_local_notifications ^22.3.1, version solving failed.


You can try the following suggestion to make the pubspec resolve:
* Consider downgrading your constraint on connectivity_plus: flutter pub add connectivity_plus:^7.3.1
Failed to update packages.
```

## fmt
```
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/core/constants/app_constants.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/core/utils/app_time.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Changed lib/core/utils/app_time.dart
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/data/models/prayer.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Changed lib/data/models/prayer.dart
Changed lib/data/models/prayer_times_day.dart
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/data/prayer/prayer_calculator.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Could not format because the source could not be parsed:

line 13, column 1 of lib/data/prayer/prayer_calculator.dart: The library directive must appear before all other directives.
   ╷
13 │ library;
   │ ^^^^^^^
   ╵
line 30, column 32 of lib/data/prayer/prayer_calculator.dart: Expected to find '('.
   ╷
30 │     this.temkin = const Temkin.diyanet,
   │                                ^^^^^^^
   ╵
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/design/app_colors.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Changed lib/design/app_colors.dart
Changed lib/design/app_spacing.dart
Changed lib/design/app_theme.dart
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/main.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Warning: Package resolution error when reading "analysis_options.yaml" file for "test/placeholder_test.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/home/runner/work/ezanapp/ezanapp/analysis_options.yaml".
Formatted 9 files (6 changed) in 0.03 seconds.
```

## analyze
```
  error • The name 'WidgetState' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'WidgetState' • lib/design/app_theme.dart:236:16 • non_type_as_type_argument
  error • The method 'IconThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'IconThemeData' • lib/design/app_theme.dart:236:40 • undefined_method
  error • Undefined name 'WidgetState'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:238:36 • undefined_identifier
  error • The method 'BottomNavigationBarThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'BottomNavigationBarThemeData' • lib/design/app_theme.dart:242:33 • undefined_method
  error • Undefined name 'BottomNavigationBarType'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:246:15 • undefined_identifier
  error • The method 'BottomSheetThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'BottomSheetThemeData' • lib/design/app_theme.dart:249:25 • undefined_method
  error • Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:251:27 • undefined_identifier
  error • The name 'RoundedRectangleBorder' isn't a class. Try correcting the name to match an existing class • lib/design/app_theme.dart:253:22 • creation_with_non_type
  error • Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:254:25 • undefined_identifier
  error • The method 'DialogThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'DialogThemeData' • lib/design/app_theme.dart:257:20 • undefined_method
  error • Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:259:27 • undefined_identifier
  error • The name 'RoundedRectangleBorder' isn't a class. Try correcting the name to match an existing class • lib/design/app_theme.dart:260:22 • creation_with_non_type
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:261:68 • undefined_identifier
  error • The method 'SnackBarThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'SnackBarThemeData' • lib/design/app_theme.dart:263:22 • undefined_method
  error • Undefined name 'SnackBarBehavior'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:264:19 • undefined_identifier
  error • The name 'RoundedRectangleBorder' isn't a class. Try correcting the name to match an existing class • lib/design/app_theme.dart:269:22 • creation_with_non_type
  error • The method 'ProgressIndicatorThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'ProgressIndicatorThemeData' • lib/design/app_theme.dart:272:31 • undefined_method
  error • The method 'SliderThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'SliderThemeData' • lib/design/app_theme.dart:277:20 • undefined_method
  error • The method 'SwitchThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'SwitchThemeData' • lib/design/app_theme.dart:283:20 • undefined_method
  error • Undefined name 'WidgetStateProperty'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:284:21 • undefined_identifier
  error • The name 'Color' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Color' • lib/design/app_theme.dart:284:53 • non_type_as_type_argument
  error • The name 'WidgetState' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'WidgetState' • lib/design/app_theme.dart:285:16 • non_type_as_type_argument
  error • Undefined name 'WidgetState'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:286:31 • undefined_identifier
  error • Undefined name 'WidgetStateProperty'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:288:21 • undefined_identifier
  error • The name 'Color' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Color' • lib/design/app_theme.dart:288:53 • non_type_as_type_argument
  error • The name 'WidgetState' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'WidgetState' • lib/design/app_theme.dart:289:16 • non_type_as_type_argument
  error • Undefined name 'WidgetState'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:290:31 • undefined_identifier
  error • The method 'TabBarThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TabBarThemeData' • lib/design/app_theme.dart:293:20 • undefined_method
  error • Undefined name 'TabBarIndicatorSize'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:296:24 • undefined_identifier
  error • Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:297:23 • undefined_identifier
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:298:64 • undefined_identifier
  error • The method 'TooltipThemeData' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TooltipThemeData' • lib/design/app_theme.dart:300:21 • undefined_method
  error • The method 'BoxDecoration' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'BoxDecoration' • lib/design/app_theme.dart:301:21 • undefined_method
  error • Undefined class 'TextTheme'. Try changing the name to the name of an existing class, or creating a class with the name 'TextTheme' • lib/design/app_theme.dart:312:10 • undefined_class
  error • Undefined class 'ColorScheme'. Try changing the name to the name of an existing class, or creating a class with the name 'ColorScheme' • lib/design/app_theme.dart:312:31 • undefined_class
  error • Undefined class 'Color'. Try changing the name to the name of an existing class, or creating a class with the name 'Color' • lib/design/app_theme.dart:313:11 • undefined_class
  error • Undefined class 'Color'. Try changing the name to the name of an existing class, or creating a class with the name 'Color' • lib/design/app_theme.dart:314:11 • undefined_class
  error • The method 'TextTheme' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextTheme' • lib/design/app_theme.dart:315:12 • undefined_method
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:316:21 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:316:57 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:317:22 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:317:58 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:318:21 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:318:57 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:319:23 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:319:59 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:320:22 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:320:58 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:321:19 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:321:55 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:322:20 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:322:56 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:323:19 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:323:55 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:324:18 • undefined_method
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:325:19 • undefined_method
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:326:18 • undefined_method
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:327:19 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:327:55 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:328:20 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:328:56 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:329:19 • undefined_method
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:329:57 • undefined_identifier
  error • Undefined class 'TextStyle'. Try changing the name to the name of an existing class, or creating a class with the name 'TextStyle' • lib/design/app_theme.dart:334:10 • undefined_class
  error • Undefined class 'TextTheme'. Try changing the name to the name of an existing class, or creating a class with the name 'TextTheme' • lib/design/app_theme.dart:334:27 • undefined_class
  error • Undefined class 'Color'. Try changing the name to the name of an existing class, or creating a class with the name 'Color' • lib/design/app_theme.dart:334:63 • undefined_class
  error • Undefined class 'FontWeight'. Try changing the name to the name of an existing class, or creating a class with the name 'FontWeight' • lib/design/app_theme.dart:334:77 • undefined_class
  error • Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name • lib/design/app_theme.dart:334:97 • undefined_identifier
  error • The method 'TextStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle' • lib/design/app_theme.dart:335:7 • undefined_method
  error • Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • lib/main.dart:1:8 • uri_does_not_exist
  error • The function 'runApp' isn't defined. Try importing the library that defines 'runApp', correcting the name to the name of an existing function, or defining a function named 'runApp' • lib/main.dart:3:16 • undefined_function
  error • The name 'Placeholder' isn't a class. Try correcting the name to match an existing class • lib/main.dart:3:29 • creation_with_non_type
warning • The asset directory 'assets/data/adhkar/' doesn't exist. Try creating the directory or fixing the path to the directory • pubspec.yaml:79:7 • asset_directory_does_not_exist
warning • The asset directory 'assets/audio/adhan/' doesn't exist. Try creating the directory or fixing the path to the directory • pubspec.yaml:80:7 • asset_directory_does_not_exist
warning • The asset directory 'assets/images/' doesn't exist. Try creating the directory or fixing the path to the directory • pubspec.yaml:81:7 • asset_directory_does_not_exist
  error • Target of URI doesn't exist: 'package:flutter_test/flutter_test.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist • test/placeholder_test.dart:1:8 • uri_does_not_exist
  error • The function 'test' isn't defined. Try importing the library that defines 'test', correcting the name to the name of an existing function, or defining a function named 'test' • test/placeholder_test.dart:4:3 • undefined_function
  error • The function 'expect' isn't defined. Try importing the library that defines 'expect', correcting the name to the name of an existing function, or defining a function named 'expect' • test/placeholder_test.dart:4:29 • undefined_function

411 issues found. (ran in 0.5s)
```

## test
```
Error: cannot run without a dependency on either "package:flutter_test" or "package:test". Ensure the following lines are present in your pubspec.yaml:

dev_dependencies:
  flutter_test:
    sdk: flutter

```

## build
```
Build failed due to use of deleted Android v1 embedding.
```
