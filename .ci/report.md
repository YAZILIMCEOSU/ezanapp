# CI raporu (2026-10-22 14:27 UTC)

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
+ _flutterfire_internals 1.3.77 (1.3.78 available)
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
+ firebase_core 4.15.0 (5.0.0 available)
+ firebase_core_platform_interface 8.1.1
+ firebase_core_web 3.12.0 (4.0.0 available)
+ firebase_messaging 16.7.0 (17.0.0 available)
+ firebase_messaging_platform_interface 4.10.0 (4.11.0 available)
+ firebase_messaging_web 4.2.5 (4.3.0 available)
+ fixnum 1.1.1
+ fl_chart 1.3.0
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
+ geolocator 14.1.2
+ geolocator_android 5.2.1
+ geolocator_apple 2.4.2
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
+ shared_preferences_android 2.5.2
+ shared_preferences_foundation 2.6.0
+ shared_preferences_linux 2.4.1
+ shared_preferences_platform_interface 2.4.2
+ shared_preferences_web 2.4.3
+ shared_preferences_windows 2.4.1
+ sky_engine 0.0.0 from sdk flutter
+ source_span 1.10.2
+ sqflite 2.4.5
+ sqflite_android 2.4.5
+ sqflite_common 2.5.14
+ sqflite_common_ffi 2.4.4
+ sqflite_darwin 2.4.4+1
+ sqflite_platform_interface 2.4.3
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
+ vm_service 15.4.0
+ web 1.1.1
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
Formatted lib/features/more/kaza_tracker_screen.dart
Formatted lib/features/qibla/qibla_screen.dart
Formatted 111 files (2 changed) in 1.31 seconds.
```

## analyze
```
Analyzing ezanapp...                                            

  error • Invalid constant value • lib/features/more/kaza_tracker_screen.dart:866:38 • invalid_constant
  error • The getter 'gold300' isn't defined for the type 'AppColors'. Try importing the library that defines 'gold300', correcting the name to the name of an existing getter, or defining a getter or field named 'gold300' • lib/features/more/kaza_tracker_screen.dart:866:48 • undefined_getter
  error • The method 'arabicStyle' isn't defined for the type 'AppTheme'. Try correcting the name to the name of an existing method, or defining a method named 'arabicStyle' • lib/features/more/kaza_tracker_screen.dart:1080:37 • undefined_method

3 issues found. (ran in 21.2s)
```

## test
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart
00:00 +0: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: (setUpAll)
00:00 +0: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:00 +1: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:00 +2: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:00 +3: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:00 +4: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:00 +4: /home/runner/work/ezanapp/ezanapp/test/prayer_calculation_test.dart: yüksek enlemlerde gece ortası kuralı vakit üretir
00:00 +5: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kategoriler tanımlı ve benzersiz
00:00 +6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: en az 30 dua var ve kimlikler benzersiz
00:00 +7: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada ad, okunuş, meal ve kategori dolu
00:00 +8: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada kaynak künyesi var
00:00 +9: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kaynak künyeleri ya Kur'an ya muteber hadis kaynağına dayanır
00:00 +10: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duanın kategorisi kategori listesinde tanımlı
00:00 +11: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her kategoride en az bir dua var (boş sekme olmasın)
00:00 +12: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Kur'an kaynaklı duaların künyesi sure/ayet içerir
00:00 +13: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Arapça metin içeren dualar Arapça alfabede
00:00 +14: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: katalogda arama ve kategori süzme çalışıyor
00:00 +15: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (tearDownAll)
00:00 +15: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı en az 20 kayıt ve benzersiz kimlikler
00:00 +16: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı her kayıtta başlık, cevap, anahtar kelime ve kaynak var
00:00 +17: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler küçük harf ve ASCII (arama uyumu)
00:00 +18: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler yeterince ayırt edici
00:00 +19: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı ilişkili kayıt kimlikleri geçerli
00:00 +20: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı mezhep farkı notları en az birkaç kayıtta bulunur
00:00 +21: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı kaynak künyeleri kaynak türüne ayrılabiliyor
00:00 +22: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi namaz rekatı sorusu doğru kayda gider
00:00 +23: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi abdest sorusu doğru kayda gider
00:00 +24: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi zekât sorusu doğru kayda gider
00:00 +25: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kıble sorusu doğru kayda gider
00:00 +26: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz
00:00 +27: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır
00:00 +28: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:00 +29: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:00 +30: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:00 +31: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:00 +32: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:00 +33: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:01 +34: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:01 +35: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:01 +36: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi paylaşım metni kaynakları ve mezhep notlarını içerir
00:01 +37: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
00:01 +38: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
00:01 +39: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +39: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaklı uzak yanıt kabul edilir
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +39 ~1: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +39 ~1: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaksız uzak yanıt reddedilir, yerel tabana düşülür
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +39 ~2: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +39 ~2: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında sunucu hatasında (500) uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +39 ~3: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +39 ~3: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bozuk JSON yanıtında uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +39 ~4: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +39 ~4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +39 ~5: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +39 ~5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında uzak yanıtlara da öneri soruları eklenir
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +39 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:01 +40 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir
00:01 +41 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli JSON ayrıştırma tüm alanları okur
00:01 +42 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli eksik alanlar çökmez, kategori varsayılana düşer
00:01 +43 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli kaynak künyesi paylaşım metninde yer alır
00:01 +44 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli paylaşım metni Arapça, okunuş ve meali içerir
00:01 +45 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli Arapçası olmayan dua bile okunabilir paylaşılır
00:01 +46 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli arama diakritik ve büyük harf duyarsız
00:01 +47 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli künye metni de aranabilir
00:01 +48 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kategoriye göre süzer
00:01 +49 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş sorgu tüm listeyi döner
00:01 +50 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog sorguya göre süzer
00:01 +51 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kimliğe göre bulur
00:01 +52 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş katalog güvenli
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
00:13 +53 ~6 -1: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                                color: AppColors.gold300,
                                                 ^^^^^^^
  lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                      style: AppTheme.arabicStyle(
                                      ^^^^^^^^^^^
  .
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
00:26 +53 ~6 -2: loading /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                                color: AppColors.gold300,
                                                 ^^^^^^^
  lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                      style: AppTheme.arabicStyle(
                                      ^^^^^^^^^^^
  .
00:28 +53 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings varsayılan ayarlar Diyanet yöntemini kullanır
00:28 +54 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings JSON gidiş-dönüşü değerleri korur
00:28 +55 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings bozuk yedek varsayılanlara döner
00:28 +56 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings Hanefî ikindi yalnızca desteklenen yöntemlerde uygulanır
00:28 +57 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings manuel düzeltmeler her yöntemde aktarılır
00:28 +58 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod bilinmeyen kimlik Diyanet'e döner
00:28 +59 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod tüm yöntemler geçerli açılara sahip
00:28 +60 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe yönü Türkiye için güneydoğuyu gösterir
00:28 +61 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe koordinatında mesafe sıfıra yakındır
00:28 +62 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils İstanbul-Kâbe mesafesi ~2400 km
00:28 +63 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (setUpAll)
00:28 +63 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar bugünü hicri tarihe çevirir
00:28 +64 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar gün farkı hesabı ve geri dönüş tutarlı
00:28 +65 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar ay uzunluğu 29 veya 30 gündür
00:28 +66 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar Ramazan başlangıcı hicri 9. ayın 1. günüdür
00:28 +67 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (tearDownAll)
00:28 +67 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sıralı veri sağlıklı kabul edilir
00:28 +68 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:28 +69 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay bozuk veri sağlıksız kabul edilir
00:28 +70 ~6 -2: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
00:40 +71 ~6 -3: loading /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                                color: AppColors.gold300,
                                                 ^^^^^^^
  lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                      style: AppTheme.arabicStyle(
                                      ^^^^^^^^^^^
  .
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
00:53 +71 ~6 -4: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                                color: AppColors.gold300,
                                                 ^^^^^^^
  lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                      style: AppTheme.arabicStyle(
                                      ^^^^^^^^^^^
  .
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
01:06 +71 ~6 -5: loading /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart [E]
  Failed to load "/home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart":
  Compilation failed for testPath=/home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                                color: AppColors.gold300,
                                                 ^^^^^^^
  lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                      style: AppTheme.arabicStyle(
                                      ^^^^^^^^^^^
  .
01:08 +71 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri yedi gün × altı vakit için kimlikler benzersiz
01:08 +72 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri kimlikler ilgili aralıkta kalır
01:08 +73 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim kimlikleri vakit kimlikleri tekil bildirim kimlikleriyle çakışmaz
01:08 +74 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim yönlendirme yükü her hedef kendi yüküyle ayrışır
01:08 +75 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: bildirim yönlendirme yükü ayrıntılı yükler ve tanımsız yükler güvenli
01:08 +76 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları varsayılan olarak güneş vakti bildirilmez
01:08 +77 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları kullanıcı bir vakti kapatabilir
01:08 +78 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları bildirimler tümden kapatılınca hiçbir vakit bildirilmez
01:08 +79 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: vakit bildirimi kararları eksik ayar güvenli tarafta kalır (kapalı sayılır)
01:08 +80 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu varsayılan sessiz saat kapalı
01:08 +81 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu sessiz saat aralığı gece yarısını aşabilir
01:08 +82 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu uyku modu 22:00–07:00 arasını kapsar
01:08 +83 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: sessiz saat ve uyku modu öğle vakti sessiz saate girmez
01:08 +84 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı ön hatırlatma varsayılan olarak kapalı
01:08 +85 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: ön hatırlatma ve gün sayısı ön hatırlatma dakikası ayarlanabilir
01:08 +86 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
01:08 +87 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Türkçe karakterleri sadeleştirir
01:08 +88 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer kelimelere ayırır ve kısa kelimeleri atar
01:08 +89 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer ekleri kaba biçimde kırpar
01:08 +90 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer eşleştirme aksan ve ek farklarını tolere eder
01:08 +91 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer Arapça harekeleri kaldırır
01:08 +92 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: TextNormalizer yüzde biçimi
01:08 +93 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime geri sayım ve dijital sayaç biçimi
01:08 +94 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime 24 saat ve 12 saat biçimi
01:08 +95 ~6 -5: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime gün karşılaştırması
01:08 +96 ~6 -5: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart
  /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart
  /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart
  /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart
  /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: loading /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart
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
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
Note: /home/runner/.pub-cache/hosted/pub.dev/geolocator_android-5.2.1/android/src/main/java/com/baseflow/geolocator/location/LocationMapper.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.7-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 3m 45s
Running Gradle task 'assembleRelease'...                          226.1s
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
lib/features/more/kaza_tracker_screen.dart:866:48: Error: Member not found: 'gold300'.
                              color: AppColors.gold300,
                                               ^^^^^^^
lib/features/more/kaza_tracker_screen.dart:1080:37: Error: Member not found: 'AppTheme.arabicStyle'.
                    style: AppTheme.arabicStyle(
                                    ^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.47.7-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 13s
Running Gradle task 'bundleRelease'...                             73.7s
Gradle task bundleRelease failed with exit code 1
```
