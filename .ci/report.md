# CI raporu (2026-10-14 13:00 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | failure |
| test | failure |
| test (uzak AI sözleşmesi) | success |
| build (debug apk) | success |
| build (release appbundle) | success |
| dene-apk indirmeye açıldı | success |

## pubget
```
Resolving dependencies...
Downloading packages...
+ _flutterfire_internals 1.3.77
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
+ crypto 3.0.7
+ cupertino_ui 1.1.2
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
+ firebase_core 4.15.0
+ firebase_core_platform_interface 8.1.1
+ firebase_core_web 3.12.0
+ firebase_messaging 16.7.0
+ firebase_messaging_platform_interface 4.10.0
+ firebase_messaging_web 4.2.5
+ fixnum 1.1.1
+ fl_chart 1.2.0
+ flutter 0.0.0 from sdk flutter
+ flutter_cache_manager 3.4.5
+ flutter_lints 6.0.0
+ flutter_local_notifications 22.3.2
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
+ geolocator 14.1.1
+ geolocator_android 5.1.1+1
+ geolocator_apple 2.3.15
+ geolocator_linux 0.2.6
+ geolocator_platform_interface 4.4.0
+ geolocator_web 4.1.4
+ geolocator_windows 0.2.5
+ glob 2.2.0
+ go_router 18.0.2
+ google_mobile_ads 9.1.0
+ gotrue 2.27.3
+ gsettings 0.2.8 (0.2.9 available)
+ hooks 2.2.0
+ http 1.6.0
+ http_parser 4.1.2
+ in_app_purchase 3.3.1
+ in_app_purchase_android 0.5.4
+ in_app_purchase_platform_interface 1.4.1
+ in_app_purchase_storekit 0.4.13+2
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
+ material_ui 1.6.0
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
+ shared_preferences_android 2.4.28
+ shared_preferences_foundation 2.5.7
+ shared_preferences_linux 2.4.1
+ shared_preferences_platform_interface 2.4.2
+ shared_preferences_web 2.4.3
+ shared_preferences_windows 2.4.1
+ sky_engine 0.0.0 from sdk flutter
+ source_span 1.10.2
+ sqflite 2.4.4+2
+ sqflite_android 2.4.4+1
+ sqflite_common 2.5.14
+ sqflite_common_ffi 2.4.4
+ sqflite_darwin 2.4.4+1
+ sqflite_platform_interface 2.4.2
+ sqlite3 3.7.1
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
Changed 190 dependencies!
8 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Upgrading analysis_options.yaml to exclude build and platform directories.
```

## fmt
```
== dart fix --apply ==
Computing fixes in ezanapp...
Applying fixes...

lib/features/qibla/qibla_screen.dart
  prefer_const_declarations - 1 fix

1 fix made in 1 file.
== dart format ==
Formatted 111 files (0 changed) in 1.33 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

warning • Dead code. Try removing the code, or fixing the code before it so that it can be reached • lib/features/quran/surah_screen.dart:434:63 • dead_code
warning • The left operand can't be null, so the right operand is never executed. Try removing the operator and the right operand • lib/features/quran/surah_screen.dart:434:66 • dead_null_aware_expression

2 issues found. (ran in 21.7s)
```

## test
```
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#e2586 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#32653 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#ea856 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#24696 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#2cdf6 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#6d35d OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#968f5 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#355a9 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
---
A RenderFlex overflowed by 8.4 pixels on the bottom.
debugCreator: Column ← Padding ← DecoratedBox ← Container ← Listener ← RawGestureDetector ←
GestureDetector ← Semantics ← DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
The overflowing RenderFlex has an orientation of Axis.vertical.

The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.

This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.

The specific RenderFlex in question is: RenderFlex#65f45 OVERFLOWING:
  creator: Column ← Padding ← DecoratedBox ← Container ← Listener ←
    RawGestureDetector ← GestureDetector ← Semantics ←
    DefaultSelectionStyle ← Builder ← MouseRegion ← Semantics ← ⋯
  parentData: offset=Offset(7.0, 11.0) (can use size)
  constraints: BoxConstraints(w=74.0, h=71.6)
  size: Size(74.0, 71.6)
  direction: vertical
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0

◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤

When the exception was thrown, this was the stack:
#4      renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:300:5)
<asynchronous suspension>
#5      main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:69:11)
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
  file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart line 300
The test description was:
  Daha Fazla — küçük telefon 320×568
════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following message was thrown:
Multiple exceptions (25) were detected during the running of the current test, and at least one was
unexpected.
════════════════════════════════════════════════════════════════════════════════════════════════════
00:09 +169 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — küçük telefon 320×568 [E]
  Test failed. See exception logs above.
  The test description was: Daha Fazla — küçük telefon 320×568
  
00:09 +169 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — telefon 411×914
00:09 +170 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — tablet 1024×1366
00:09 +171 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ayarlar — küçük telefon 320×568
00:09 +172 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ayarlar — telefon 411×914
00:09 +173 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ayarlar — tablet 1024×1366
00:10 +174 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — küçük telefon 320×568
00:10 +175 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — telefon 411×914
00:10 +176 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:10 +177 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — küçük telefon 320×568
00:10 +178 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — telefon 411×914
00:10 +179 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — tablet 1024×1366
00:10 +180 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Dualar: künye özeti ve kategori çipleri görünür
00:10 +181 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Hadis: başlık ve konu çipleri görünür
[hadis tanısı] çipler: false · yükleniyor: true · metinler: Hadis metni veya konu ara | Hadisler yükleniyor… | Hadis | Sahih kaynaklardan seçkiler
00:10 +182 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Zikir: tesbih ekranı sayaç ile çizilir
00:10 +183 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Vakitler: liste başlığı ve ayar ipucu birlikte görünür
00:10 +184 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Kur'an: sure listesi yüklenir
00:11 +185 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Daha Fazla: tüm bölüm girişleri listelenir
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: at least one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Dualar": []>
   Which: means none were found but some were expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure>.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:184:11)
#5      renderScreen (file:///home/runner/work/ezanapp/ezanapp/test/support/test_runtime.dart:282:13)
<asynchronous suspension>
#6      main.<anonymous closure>.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:177:7)
<asynchronous suspension>
#7      main.screenTest.<anonymous closure> (file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart:47:7)
<asynchronous suspension>
#8      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#9      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart line 184
The test description was:
  Daha Fazla: tüm bölüm girişleri listelenir
════════════════════════════════════════════════════════════════════════════════════════════════════
00:11 +185 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Daha Fazla: tüm bölüm girişleri listelenir [E]
  Test failed. See exception logs above.
  The test description was: Daha Fazla: tüm bölüm girişleri listelenir
  
00:11 +185 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir hata görünümü anlaşılır mesaj ve "Tekrar dene" sunar
00:11 +186 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir izni olmayan hatalarda "Tekrar dene" gösterilmez
00:11 +187 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir vakitler cihazda hesaplandıysa uyarı şeridi görünür
00:11 +188 ~6 -3: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: (tearDownAll)
00:11 +188 ~6 -3: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları Daha Fazla ekranı yalnızca açık modülleri listeler
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Daha Fazla: tüm bölüm girişleri listelenir
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — küçük telefon 320×568
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
[==============                         ] 36% Unzipping... android-ndk-r28c/tool
[==============                         ] 37% Unzipping... android-ndk-r28c/tool
[===============                        ] 38% Unzipping... android-ndk-r28c/tool
[===============                        ] 39% Unzipping... android-ndk-r28c/tool
[===============                        ] 40% Unzipping... android-ndk-r28c/tool
[================                       ] 40% Unzipping... android-ndk-r28c/tool
[================                       ] 41% Unzipping... android-ndk-r28c/tool
[================                       ] 42% Unzipping... android-ndk-r28c/tool
[=================                      ] 43% Unzipping... android-ndk-r28c/tool
[=================                      ] 44% Unzipping... android-ndk-r28c/tool
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
Note: /home/runner/.pub-cache/hosted/pub.dev/geolocator_android-5.1.1+1/android/src/main/java/com/baseflow/geolocator/location/LocationMapper.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Expected to find fonts for (packages/cupertino_icons/CupertinoIcons, MaterialIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 30996 bytes (98.1% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Caught exception: Already watching path: /home/runner/work/ezanapp/ezanapp/android
Running Gradle task 'assembleRelease'...                          563.5s
✓ Built build/app/outputs/flutter-apk/app-release.apk (88.2MB)
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

Expected to find fonts for (packages/cupertino_icons/CupertinoIcons, MaterialIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 30996 bytes (98.1% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Caught exception: Already watching path: /home/runner/work/ezanapp/ezanapp/android
Running Gradle task 'bundleRelease'...                             23.4s
✓ Built build/app/outputs/bundle/release/app-release.aab (88.4MB)
```
