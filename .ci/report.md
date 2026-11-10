# CI raporu (2026-11-10 08:21 UTC)

| adım | sonuç |
|---|---|
| pub get | success |
| format | success |
| analyze | success |
| test | failure |
| test (uzak AI sözleşmesi) | success |
| kıble doğrulaması (6 kontrol) | success |
| imza doğrulaması (apksigner) | success |
| build (debug apk) | success |
| build (release appbundle) | success |
| dene-apk indirmeye açıldı | success |

## pubget
```
Resolving dependencies...
Downloading packages...
+ _flutterfire_internals 1.3.77 (1.3.79 available)
+ app_links 7.2.2
+ app_links_linux 1.0.5
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
+ code_assets 2.2.0
+ collection 1.19.1
+ connectivity_plus 7.3.1 (7.3.2 available)
+ connectivity_plus_platform_interface 2.1.0
+ convert 3.1.2
+ cross_file 0.3.5+5 (0.4.0 available)
+ crypto 3.0.8
+ cupertino_ui 1.1.6
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
+ fl_chart 1.3.1
+ flutter 0.0.0 from sdk flutter
+ flutter_cache_manager 3.5.0
+ flutter_lints 6.0.0
+ flutter_local_notifications 22.3.3 (23.0.0 available)
+ flutter_local_notifications_linux 8.0.2 (9.0.0 available)
+ flutter_local_notifications_platform_interface 12.2.0 (13.0.0 available)
+ flutter_local_notifications_web 1.0.0 (2.0.0 available)
+ flutter_local_notifications_windows 3.1.1 (4.0.0 available)
+ flutter_localizations 0.0.0 from sdk flutter
+ flutter_riverpod 3.5.0
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
+ go_router 18.1.4
+ google_mobile_ads 9.2.0
+ gotrue 2.27.3
+ gsettings 0.2.8 (0.2.9 available)
+ hooks 2.2.0
+ http 1.6.0
+ http_parser 4.1.2
+ in_app_purchase 3.3.1
+ in_app_purchase_android 0.5.5
+ in_app_purchase_platform_interface 1.4.1
+ in_app_purchase_storekit 0.4.17
+ intl 0.20.3
+ jni 1.1.2
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
+ material_ui 1.11.0
+ meta 1.19.0
+ mime 2.1.0
+ native_toolchain_c 0.19.6
+ nm 0.5.0 (0.6.0 available)
+ objective_c 9.6.3
+ package_config 3.0.0
+ package_info_plus 10.2.2
+ package_info_plus_platform_interface 4.1.0
+ passkeys_platform_interface 2.11.0
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
+ riverpod 3.5.0
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
+ sqflite 2.4.6
+ sqflite_android 2.4.6
+ sqflite_common 2.5.17
+ sqflite_common_ffi 2.4.6
+ sqflite_darwin 2.4.6
+ sqflite_platform_interface 2.4.4
+ sqlite3 3.9.1
+ stack_trace 1.12.2
+ state_notifier 1.0.0
+ storage_client 2.8.1
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ supabase 2.16.5
+ supabase_common 0.1.2
+ supabase_flutter 2.18.3
+ synchronized 3.6.1+1
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
18 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Upgrading analysis_options.yaml to exclude build and platform directories.
```

## fmt
```
== dart fix --apply ==
Computing fixes in ezanapp...
Nothing to fix!
== dart format ==
Formatted 135 files (0 changed) in 1.09 seconds.
```

## analyze
```
Analyzing ezanapp...                                            
No issues found! (ran in 17.1s)
```

## test
```
00:00 +0: loading /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart
00:00 +0: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: sekme yolları beş ana sekme de çözümlenir
00:00 +1: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: tüm sabit yollar çözümlenir sabit yol sabitleri
00:00 +2: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: tüm sabit yollar çözümlenir parametreli yollar çözümlenir
00:00 +3: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: tüm sabit yollar çözümlenir son sekmedeki alt sayfalar da çözümlenir
00:00 +4: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: bildirim yönlendirmesi her bildirim hedefi geçerli bir yola gider
00:00 +5: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: bildirim yönlendirmesi eski bildirim yükleri doğru ekrana yönlendirir
00:00 +6: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: kaynak taraması app_router.dart içindeki her yol sabiti çözümlenir
00:00 +7: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: bilinmeyen yol tanımsız yol hata ekranına düşer (çökme yok)
00:00 +8: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: yol sabitleri tutarlı yol sabitleri Türkçe ve küçük harfli
00:00 +9: /home/runner/work/ezanapp/ezanapp/test/router/navigation_test.dart: yol sabitleri tutarlı sure/ayet yolu sorgu parametresiyle kurulur
00:01 +10: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında soru yerel bilgi tabanından kaynaklı yanıtlanır
00:01 +11: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırılmadığında bilinmeyen soruda dürüst "bilmiyorum" cevabı döner
00:01 +12: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaklı uzak yanıt kabul edilir
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +12 ~1: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında kaynaksız uzak yanıt reddedilir, yerel tabana düşülür
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +12 ~2: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında sunucu hatasında (500) uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +12 ~3: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bozuk JSON yanıtında uygulama çökmez
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +12 ~4: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında bilinmeyen soruda uzaktan kaynaksız yanıt gelirse dürüst cevap
  Skip: EZANAI_API_BASE tanımlı değil
00:01 +12 ~5: /home/runner/work/ezanapp/ezanapp/test/data/ai_remote_test.dart: backend yapılandırıldığında uzak yanıtlara da öneri soruları eklenir
  Skip: EZANAI_API_BASE tanımlı değil
00:02 +12 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings varsayılan ayarlar Diyanet yöntemini kullanır
00:02 +13 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings JSON gidiş-dönüşü değerleri korur
00:02 +14 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings bozuk yedek varsayılanlara döner
00:02 +15 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings Hanefî ikindi yalnızca desteklenen yöntemlerde uygulanır
00:02 +16 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: AppSettings manuel düzeltmeler her yöntemde aktarılır
00:02 +17 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod bilinmeyen kimlik Diyanet'e döner
00:02 +18 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: CalculationMethod tüm yöntemler geçerli açılara sahip
00:02 +19 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe yönü Türkiye için güneydoğuyu gösterir
00:02 +20 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils Kâbe koordinatında mesafe sıfıra yakındır
00:02 +21 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: GeoUtils İstanbul-Kâbe mesafesi ~2400 km
00:02 +22 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (setUpAll)
00:02 +22 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar bugünü hicri tarihe çevirir
00:02 +23 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar gün farkı hesabı ve geri dönüş tutarlı
00:02 +24 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar ay uzunluğu 29 veya 30 gündür
00:02 +25 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar Ramazan başlangıcı hicri 9. ayın 1. günüdür
00:02 +26 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: HijriCalendar (tearDownAll)
00:02 +26 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sıralı veri sağlıklı kabul edilir
00:02 +27 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay sonraki vakit ve içinde bulunulan vakit doğru bulunur
00:02 +28 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay bozuk veri sağlıksız kabul edilir
00:02 +29 ~6: /home/runner/work/ezanapp/ezanapp/test/data/models_test.dart: PrayerTimesDay JSON gidiş-dönüşü vakitleri korur
00:04 +30 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: (setUpAll)
00:04 +30 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V1+V6 — Diyanet ile dakika farkı yerel hesap Diyanet ile **yansız** (±0,5 dk ortalama) eşleşir
00:04 +31 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V1+V6 — Diyanet ile dakika farkı ikindi asla 1 dk'dan fazla geç olmaz (V11)
00:04 +32 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V1+V6 — Diyanet ile dakika farkı temkin: akşam/yatsı düzeltmeleri Diyanet ile aynı (V6)
00:04 +33 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V1+V6 — Diyanet ile dakika farkı AlAdhan yanıtına yöntemin temkin düzeltmesi uygulanır (V1)
00:04 +34 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V1+V6 — Diyanet ile dakika farkı temkinsiz yöntem (MWL) AlAdhan ham değerini korur
00:04 +35 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V2+V3 — resmî veri ve kullanıcı düzeltmeleri Hanefî ikindi seçilse de resmî Diyanet verisi kullanılır (V2)
00:04 +36 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V2+V3 — resmî veri ve kullanıcı düzeltmeleri önbellekten okunan resmî veriye de Hanefî kaydırma uygulanır (V8)
00:04 +37 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V2+V3 — resmî veri ve kullanıcı düzeltmeleri manuel düzeltme önbellekten okurken iki kez uygulanmaz (V3)
00:04 +38 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V2+V3 — resmî veri ve kullanıcı düzeltmeleri düzeltmeli yöntem ayrı önbellek anahtarı kullanır (V3)
00:04 +39 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V4 — bugünkü ekran ile haftalık tablo/bildirim aynı dakika gün ve aralık aynı vakitleri döndürür
00:04 +40 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V5 — bayat aralık önbelleği yenilenir 7 saatlik önbellek yeniden çekilir
00:04 +41 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V9 — aralık eksiksiz (ay sınırı, bildirim boşluğu) ay sonunu aşan aralıkta tüm günler döner
00:04 +42 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V9 — aralık eksiksiz (ay sınırı, bildirim boşluğu) istediğin aralık dışındaki günler atılır
00:04 +43 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V7 — dünya şehri saat dilimi Kâbil çevrimdışı hesapta +4,5 saat dilimini kullanır
00:04 +44 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: V7 — dünya şehri saat dilimi Türkiye ilçesi her zaman UTC+3 kullanır
00:04 +45 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: Kaynak etiketi — "güncelleme" ifadesi netleşti kaynak ve tazelik ayrı ayrı okunur
00:04 +46 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: Kaynak etiketi — "güncelleme" ifadesi netleşti cihaz hesabı ve yedek servis ayrı etiketlenir
00:04 +47 ~6: /home/runner/work/ezanapp/ezanapp/test/data/prayer_time_fidelity_test.dart: (tearDownAll)
00:04 +47 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı en az 20 kayıt ve benzersiz kimlikler
00:04 +48 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı her kayıtta başlık, cevap, anahtar kelime ve kaynak var
00:04 +49 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler küçük harf ve ASCII (arama uyumu)
00:04 +50 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı anahtar kelimeler yeterince ayırt edici
00:04 +51 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı ilişkili kayıt kimlikleri geçerli
00:04 +52 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı mezhep farkı notları en az birkaç kayıtta bulunur
00:04 +53 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: KnowledgeBase yapısı kaynak künyeleri kaynak türüne ayrılabiliyor
00:04 +54 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi namaz rekatı sorusu doğru kayda gider
00:04 +55 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi abdest sorusu doğru kayda gider
00:04 +56 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi zekât sorusu doğru kayda gider
00:04 +57 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kıble sorusu doğru kayda gider
00:04 +58 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz
00:04 +59 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır
00:04 +60 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi konu kelimesi genel kelimelere üstün gelir (vitir/teravih)
00:04 +61 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi ayırt edici kelime puanı, genel kelimelerden yüksektir
00:04 +62 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi harf düşmesi olan sorular da eşleşir (hatim → hatmi)
00:04 +63 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi Kâbe yönü sorusu kıble kaydına gider
00:04 +64 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi önerilen sorular kimlik değil, okunabilir başlık olarak döner
00:04 +65 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi kayda uymayan soru için uydurma cevap üretilmez
00:04 +66 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi soru boşsa eşleşme yapılmaz
00:04 +67 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi paylaşım metni kaynakları ve mezhep notlarını içerir
00:04 +68 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İslam'ın şartları sorusuna beş şartı doğru sırayla ve kaynaklı cevaplar
00:04 +69 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar
00:04 +70 ~6: /home/runner/work/ezanapp/ezanapp/test/data/knowledge_base_test.dart: LocalKnowledgeSource eşleştirmesi birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir
00:05 +71 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 1) Ana ekran widget verisi vakit saati 24 saat biçiminde ve hedef zamanı doğru taşınır
00:05 +72 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 1) Ana ekran widget verisi şehir bilgisi boşsa anlaşılır yedek metin kullanılır
00:05 +73 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni Arapça hat ayıklanır, Türkçe metin korunur
00:05 +74 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni Arapça ayıklama kapatılabilir
00:05 +75 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni kısa metin tek parça olarak döner
00:05 +76 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni boş metin sesli okunmaz
00:05 +77 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni uzun hutbe 4000 karakter sınırını aşmayan parçalara bölünür
00:05 +78 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 2) Sesli okuma metni tek cümle sınırı aşarsa kelime sınırından zorunlu bölünür
00:05 +79 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim kaydedilir ve en yeni önce döner
00:05 +80 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi uzun yanıt 280 karakterlik özetle saklanır
00:05 +81 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi bildirim nedenleri kullanıcıya anlaşılır ve sıralı
00:05 +82 ~6: /home/runner/work/ezanapp/ezanapp/test/data/phase4_test.dart: 3) Yapay zekâ yanıtı bildirimi JSON gidiş-dönüşü kaybolmadan çalışır
00:06 +83 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (setUpAll)
00:06 +83 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kategoriler tanımlı ve benzersiz
00:06 +84 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: en az 30 dua var ve kimlikler benzersiz
00:06 +85 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada ad, okunuş, meal ve kategori dolu
00:06 +86 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duada kaynak künyesi var
00:06 +87 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: kaynak künyeleri ya Kur'an ya muteber hadis kaynağına dayanır
00:06 +88 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her duanın kategorisi kategori listesinde tanımlı
00:06 +89 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: her kategoride en az bir dua var (boş sekme olmasın)
00:06 +90 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Kur'an kaynaklı duaların künyesi sure/ayet içerir
00:06 +91 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: Arapça metin içeren dualar Arapça alfabede
00:06 +92 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: katalogda arama ve kategori süzme çalışıyor
00:06 +93 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_assets_test.dart: (tearDownAll)
00:06 +93 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 0.0° · tüm tutuş açılarında ±0,001°
00:06 +94 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 37.0° · tüm tutuş açılarında ±0,001°
00:06 +95 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 90.0° · tüm tutuş açılarında ±0,001°
00:06 +96 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 151.371° · tüm tutuş açılarında ±0,001°
00:06 +97 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 180.0° · tüm tutuş açılarında ±0,001°
00:06 +98 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 270.0° · tüm tutuş açılarında ±0,001°
00:06 +99 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir yön 359.0° · tüm tutuş açılarında ±0,001°
00:06 +100 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 1. Füzyon her tutuşta doğru yönü verir Bağcılar kıble yönü (151.371°) dikey tutuşta da doğru
00:06 +101 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 2. Eski yöntemin 180° hatası artık yok Dikey tutuşta eski yöntem tanımsız, yeni yöntem doğru
00:06 +102 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 2. Eski yöntemin 180° hatası artık yok Dikeyin ötesinde (100°) eski yöntem 180° hatalı, yeni doğru
00:06 +103 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 2. Eski yöntemin 180° hatası artık yok Yatay → dik geçişinde açı sıçramaz
00:06 +104 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 3. Tutuş ağırlığı ve etiketleri Yatayda flat, 45° geçişte blend, dikte upright
00:06 +105 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 3. Tutuş ağırlığı ve etiketleri Ağırlık 0 → 1 arasında ve tek yönlü artar
00:06 +106 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 3. Tutuş ağırlığı ve etiketleri Eğim (tilt) tutuş açısıyla birebir
00:06 +107 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 3. Tutuş ağırlığı ve etiketleri Geçersiz matris null döner
00:06 +108 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 4. Ekran dönüşü (yatay tutuş) eksen eşlemesi Dört ekran yönü de tanımlı ve birbirinden farklı
00:06 +109 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 4. Ekran dönüşü (yatay tutuş) eksen eşlemesi Dikey ekran için AXIS_X / AXIS_Y
00:06 +110 ~6: /home/runner/work/ezanapp/ezanapp/test/data/pose_fusion_test.dart: 4. Ekran dönüşü (yatay tutuş) eksen eşlemesi Yan çevrilmiş ekranda eksenler döner (AY, -AX)
00:08 +111 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: (setUpAll)
00:08 +111 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: AI kota, kaynak doğrulama ve fetva güvenliği günlük kota dolsa bile İslam'ın ve imanın şartları gibi onaylı cevaplar engellenmez
00:08 +112 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: AI kota, kaynak doğrulama ve fetva güvenliği fetva soruları tespit edilir ve uydurma kaynaklar elenir
00:08 +113 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) gün içinde aktif vakit, sıradaki vakit ve geri sayım tutarlıdır
00:08 +114 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) yatsı sonrasında sıradaki vakit yarının imsakıdır
00:08 +115 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) gece yarısı geçildiğinde aktif gün otomatik olarak yarına devreder
00:08 +116 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Namaz vakitleri tekil anlık görüntü (PrayerScheduleSnapshot) hesaplama yöntemi ve Hanefî ikindi değişimi vakitleri yeniler
00:08 +117 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Dijital tesbih tutarlılığı ve kalıcılığı oturum sayacı, günlük toplam, hedef değişimi, sıfırlama ve yeniden açılış tutarlıdır
00:09 +118 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon geçersiz sensör verisi reddedilir
00:09 +119 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon manyetik kuzey sapması gerçek kuzeye doğru eklenir
00:09 +120 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Kıble pusulası doğrulama, manyetik sapma ve kalibrasyon manyetik parazit ve telefon eğimi ayrı uyarılarla bildirilir
00:09 +121 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Gizlilik ve log temizliği AppLog.sanitize koordinat, e-posta ve anahtarları maskeler
00:09 +122 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu varsayılan ezan sesi Hicaz makamıdır ve vakit bazlı ses özelleştirmesi korunur
00:09 +123 ~6: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Bağcılar kıble açısı ±0,01° içinde
00:09 +124 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:09 +125 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:09 +126 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:09 +127 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:09 +128 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:09 +129 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu ilahi ve dini sesler kataloğu telifsiz ve indirilebilir içeriklerle dolu gelir
00:09 +130 ~6: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 1. Kâbe yönü (great-circle) — ephem referansı Kutup noktalarında sonlu değer döner (çökme yok)
00:09 +131 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu bildirim seslerinde çan ifadesi yer almaz; telifsiz ilahi ve ezan makamları kullanılır
00:09 +132 ~6: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı İstanbul 21 Haziran 2026 12:00 (TRT)
00:09 +133 ~6: /home/runner/work/ezanapp/ezanapp/test/data/qibla_precision_test.dart: 2. Güneş konumu — ephem referansı İstanbul 21 Haziran 2026 12:00 (TRT)
00:09 +134 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +135 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +136 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +137 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +138 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +139 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +140 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +141 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +142 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +143 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +144 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +145 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +146 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +147 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +148 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +149 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +150 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +151 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +152 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Kur'an meal seçimleri (TR Diyanet, TR Vakıf, EN Saheeh, AR الميسر) sure içeriğini gerçekten değiştirir ve tüm ezan/ilahi ses varlıkları mevcuttur
00:09 +153 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Nafile namaz alarmları, Kâbe İmamı ezanı, global Kur'an oturumu ve genişletilmiş İslami Asistan doğrulanır
00:09 +154 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: Ezan makamları, vakit bazlı ses ve telifsiz ilahi kataloğu Bağcılar dahil tüm büyükşehir merkez ilçeleri GPS koordinatıyla doğru tespit edilir
00:09 +155 ~6: /home/runner/work/ezanapp/ezanapp/test/data/audit_verification_test.dart: (tearDownAll)
00:10 +155 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli JSON ayrıştırma tüm alanları okur
00:10 +156 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli eksik alanlar çökmez, kategori varsayılana düşer
00:10 +157 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli kaynak künyesi paylaşım metninde yer alır
00:10 +158 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli paylaşım metni Arapça, okunuş ve meali içerir
00:10 +159 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli Arapçası olmayan dua bile okunabilir paylaşılır
00:10 +160 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli arama diakritik ve büyük harf duyarsız
00:10 +161 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: Dua modeli künye metni de aranabilir
00:10 +162 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kategoriye göre süzer
00:10 +163 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş sorgu tüm listeyi döner
00:10 +164 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog sorguya göre süzer
00:10 +165 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog kimliğe göre bulur
00:10 +166 ~6: /home/runner/work/ezanapp/ezanapp/test/data/dua_models_test.dart: DuaCatalog boş katalog güvenli
00:11 +167 ~6: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket test modunda Google resmî test birim kimlikleri kullanılır
00:11 +168 ~6: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket altyapı başlatılmadan reklam istenmez (boş alan/hata yok)
00:11 +169 ~6: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket premium kullanıcıda reklam tamamen kapanır
00:11 +170 ~6: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket geçiş reklamı bekleme süresi kullanıcı dostu (3 dakika)
00:11 +171 ~6: /home/runner/work/ezanapp/ezanapp/test/data/ads_test.dart: Reklam altyapısı — ücretsiz paket reklam anahtarı varsayılan olarak açık, test modu kapalı
00:11 +172 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi Play kurulumu + eşleşen imza → resmî paket
00:11 +173 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi yeniden imzalanmış (farklı imza) paket resmî değil
00:11 +174 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi patch aracı / klon / debugger resmî paketi düşürür
00:11 +175 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi imza sabitleme kapalıyken (test/CI) kontrol atlanır
00:11 +176 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 1) Bütünlük raporu sözleşmesi tüm alanlar JSON ile taşınabilir
00:11 +177 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) test modunda Google resmî test birim kimlikleri kullanılır
00:11 +178 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) altyapı başlatılmadan reklam istenmez (boş alan/hata yok)
00:11 +179 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) premium kullanıcıda reklam tamamen kapanır
00:11 +180 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) geçiş reklamı bekleme süresi 3 dakika
00:11 +181 ~6: /home/runner/work/ezanapp/ezanapp/test/data/guvenlik_test.dart: 2) Ücretsiz paket sözleşmesi (reklamlar) reklam anahtarı varsayılan olarak açık, test modu kapalı
00:12 +182 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Türkçe arama normalizasyonu Büyük/küçük harf ve noktalı İ eşleşir
00:12 +183 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Türkçe arama normalizasyonu Türkçe karakter yazılmasa da eşleşir
00:12 +184 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Türkçe arama normalizasyonu Fazla boşluklar kırpılır
00:12 +185 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Türkçe arama normalizasyonu Boş metin güvenli
00:12 +186 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mükerrer cami temizliği Aynı ad + 120 m içindeki kayıtlar tekilleşir
00:12 +187 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mükerrer cami temizliği Aynı ad ama uzak camiler korunur
00:12 +188 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mükerrer cami temizliği Farklı adlar korunur
00:12 +189 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mükerrer cami temizliği Uzun adlarda kısaltma da mükerrer sayılır
00:12 +190 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mükerrer cami temizliği Boş girdi güvenli
00:12 +191 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mesafe ve yön etiketleri Aynı noktada 0 m
00:12 +192 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mesafe ve yön etiketleri 1 km altı metre cinsinden
00:12 +193 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mesafe ve yön etiketleri Uzak mesafe km cinsinden
00:12 +194 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Mesafe ve yön etiketleri Yön etiketi 8 yönden biri
00:12 +195 ~6: /home/runner/work/ezanapp/ezanapp/test/data/mosque_listing_test.dart: Uydurma tesis etiketi yok Varsayılan kayıtta tesis listesi boş
00:13 +196 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? 2 dakikalık konum tazedir
00:13 +197 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? 9 dakikalık konum tazedir (sınır altı)
00:13 +198 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? 15 dakikalık konum taze değildir
00:13 +199 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? tarih bilgisi yoksa taze sayılmaz
00:13 +200 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: tazelik: GPS beklenmeden kullanılabilir mi? gelecekteki zaman damgası negatif yaş üretmez
00:13 +201 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti 500 m doğruluk ilçe için yeterli
00:13 +202 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti 2 km doğruluk sınırda yeterli
00:13 +203 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti 3 km doğruluk ilçe için yetersiz (arka planda iyileştirilir)
00:13 +204 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: ilçe eşleştirme hassasiyeti hassasiyet bilinmiyorsa yetersiz kabul edilir
00:13 +205 ~6: /home/runner/work/ezanapp/ezanapp/test/data/location_speed_test.dart: bütçe sabitleri tazelik penceresi ve GPS bütçesi makul
00:13 +206 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: ayarlar bozuk veriye dayanıklı yanlış türdeki alanlar varsayılana düşer
00:13 +207 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: ayarlar bozuk veriye dayanıklı bozuk bildirim ayarları açılışı düşürmez
00:13 +208 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: ayarlar bozuk veriye dayanıklı yarım kalmış JSON varsayılanlara döner
00:13 +209 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: ayarlar bozuk veriye dayanıklı geçerli kısmi yedek okunur
00:13 +210 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: ayarlar bozuk veriye dayanıklı alakasız JSON yedek sayılmaz (ayarlar silinmez)
00:13 +211 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı (setUpAll)
00:13 +211 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı geçerli satır okunur
00:13 +212 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı bozuk satır atlanır, sağlam satır korunur
00:13 +213 ~6: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı tek satır okuması bozuk kayıtta null döner
00:14 +213 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı tek satır okuması bozuk kayıtta null döner [E]
  SqfliteFfiException(sqlite_error: 1299, , SqliteException(1299): while executing statement, NOT NULL constraint failed: prayer_times_cache.fetched_at, constraint failed (code 1299)
    Causing statement: INSERT INTO prayer_times_cache (district_id, date, imsak, gunes, ogle, ikindi, aksam, yatsi, source, hijri, fetched_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL), parameters: district:9543, 2026-11-12, 06:12, 07:39, 12:54, 15:34, 17:59, 19:21, diyanet}) sql INSERT INTO prayer_times_cache (district_id, date, imsak, gunes, ogle, ikindi, aksam, yatsi, source, hijri, fetched_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL) args [district:9543, 2026-11-12, 06:12, 07:39, 12:54, 15:34, 17:59, 19:21, diyanet] {details: {database: {path: :memory:, id: 4, readOnly: false, singleInstance: false}}}
  package:sqflite_common_ffi/src/database_factory_ffi_io.dart 100:5  ffiMethodCallHandleNoIsolate
  
00:14 +213 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı (tearDownAll)
00:15 +213 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: (setUpAll)
00:15 +213 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası Diyanet resmî verisi ilk sırada kullanılır ve önbelleğe yazılır
00:15 +214 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası Diyanet başarısızsa AlAdhan devreye girer
00:15 +215 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası her iki servis de çökerse yerel hesap devreye girer
00:15 +216 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: zincir sırası tutarsız (bozuk) servis verisi reddedilir ve zincir devam eder
00:15 +217 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış çevrimdışıyken son başarılı veri önbellekten okunur
00:15 +218 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış süresi geçmiş (6 saatten eski) önbellek kullanılmaz
00:15 +219 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış çevrimdışı ve önbellek boşsa yerel hesap sonuç üretir
00:15 +220 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış ilçe seçilmemişse (GPS) Diyanet atlanır, koordinatla yedek servis denenir
00:15 +221 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış bellek önbelleği aynı gün için tekrar sorguda ağa çıkmaz
00:15 +222 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: önbellek ve çevrimdışı davranış zorla yenileme önbelleği atlar
00:15 +223 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek aralığı kapsıyorsa ağa çıkılmaz
00:15 +224 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: aralık (haftalık/aylık tablo) önbellek yoksa çevrimdışı aralık yerel hesapla doldurulur
00:15 +225 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) resmî yanıt çözümlenir (zarf + hicri tarih)
00:15 +226 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +227 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +228 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +229 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +230 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +231 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +232 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +233 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +234 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +235 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +236 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +237 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +238 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +239 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +240 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +241 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +242 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +243 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +244 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +245 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +246 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:15 +247 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) 5xx yanıtı geçici hata olarak bildirilir
00:16 +248 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) bozuk JSON çökme yerine kaynak hatası üretir
00:16 +249 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) ilçe kimliği yoksa servis çağrılmadan hata verir
00:16 +250 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) AlAdhan yanıtı çözümlenir ve hicri etiket üretilir
00:16 +251 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: Diyanet HTTP katmanı (sahte istemci) AlAdhan boş vakit verisinde hata üretir
00:16 +252 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: kaynak bilgisi (kullanıcı mesajları) resmî veri varken kaynak ve son kontrol bilgisi gösterilir
00:16 +253 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: kaynak bilgisi (kullanıcı mesajları) konum seçilmemişse hesap bilgisi gösterilir
00:16 +254 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: resmî servis dayanıklılığı (Kasım 2026) üretilmiş ilçe kimliği il kimliğine indirgenir
00:16 +255 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: resmî servis dayanıklılığı (Kasım 2026) gün, tek istekle daily uç noktasından alınır
00:16 +256 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: resmî servis dayanıklılığı (Kasım 2026) aralık isteği range uç noktasını kullanır
00:16 +257 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: resmî servis dayanıklılığı (Kasım 2026) birincil sunucu boş dönerse yedek resmî sunucu kullanılır
00:16 +258 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: resmî servis dayanıklılığı (Kasım 2026) konum ilçeyle eşleşmese de yedek servis kullanılır
00:16 +259 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: resmî servis dayanıklılığı (Kasım 2026) yurt dışı şehirde Diyanet atlanır (kimlik çakışması)
00:16 +260 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: yerel hesap kalibrasyonu Diyanet yöntemiyle İstanbul için tutarlı vakitler üretir
00:16 +261 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/data/prayer_chain_test.dart: (tearDownAll)
00:17 +261 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: (setUpAll)
00:17 +261 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ana sayfa — küçük telefon 320×568
00:17 +262 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ana sayfa — küçük telefon 320×568
00:17 +263 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ana sayfa — küçük telefon 320×568
00:17 +264 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ana sayfa — küçük telefon 320×568
00:18 +265 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları ana ekran yalnızca MVP kartlarını gösterir
00:18 +266 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları ana ekran yalnızca MVP kartlarını gösterir
00:18 +267 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları ana ekran yalnızca MVP kartlarını gösterir
00:18 +268 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları ana ekran yalnızca MVP kartlarını gösterir
00:18 +269 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları ana ekran yalnızca MVP kartlarını gösterir
00:18 +270 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Vakitler — tablet 1024×1366
00:19 +271 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/mvp_mode_test.dart: MVP ekranları Daha Fazla ekranı yalnızca açık modülleri listeler
00:19 +272 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Kur'an — küçük telefon 320×568
00:19 +273 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Kur'an — telefon 411×914
00:19 +274 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Kur'an — tablet 1024×1366
00:19 +275 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Dualar — küçük telefon 320×568
00:19 +276 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Dualar — telefon 411×914
00:19 +277 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Dualar — tablet 1024×1366
00:19 +278 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hadis — küçük telefon 320×568
00:20 +279 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hadis — telefon 411×914
00:20 +280 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hadis — tablet 1024×1366
00:20 +281 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — küçük telefon 320×568
00:20 +282 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — küçük telefon 320×568
00:20 +283 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — küçük telefon 320×568
00:20 +284 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — küçük telefon 320×568
00:20 +285 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — küçük telefon 320×568
00:20 +286 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — küçük telefon 320×568
00:20 +287 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — telefon 411×914
00:20 +288 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Zikir — tablet 1024×1366
00:20 +289 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hicri takvim — küçük telefon 320×568
00:20 +290 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hicri takvim — telefon 411×914
00:20 +291 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hicri takvim — tablet 1024×1366
00:20 +292 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — küçük telefon 320×568
00:20 +293 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — telefon 411×914
00:20 +294 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Daha Fazla — tablet 1024×1366
00:20 +295 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ayarlar — küçük telefon 320×568
00:20 +296 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ayarlar — telefon 411×914
00:21 +297 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Ayarlar — tablet 1024×1366
00:21 +298 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — küçük telefon 320×568
00:21 +299 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — telefon 411×914
00:21 +300 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +301 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +302 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +303 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +304 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +305 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +306 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +307 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +308 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Bildirim ayarları — tablet 1024×1366
00:21 +309 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/text_normalizer_test.dart: AppTime gün karşılaştırması
00:21 +310 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — küçük telefon 320×568
00:21 +311 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — telefon 411×914
00:21 +312 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Hakkında — tablet 1024×1366
00:21 +313 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Vakit doğrulama — küçük telefon 320×568
00:21 +314 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Vakit doğrulama — telefon 411×914
00:21 +315 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: taşma ve çizim hatası yok Vakit doğrulama — tablet 1024×1366
00:21 +316 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Vakit doğrulama: konum, yöntem ve gösterilen vakitler çizilir
00:21 +317 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Dualar: künye özeti ve kategori çipleri görünür
00:21 +318 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Hadis: başlık ve konu çipleri görünür
[hadis tanısı] çipler: false · yükleniyor: true · metinler: Hadis metni veya konu ara | Hadisler yükleniyor… | Hadis | Sahih kaynaklardan seçkiler
00:21 +319 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Zikir: tesbih ekranı sayaç ile çizilir
00:21 +320 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Vakitler: liste başlığı ve ayar ipucu birlikte görünür
00:22 +321 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Kur'an: sure listesi yüklenir
00:22 +322 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: içerik gerçekten çiziliyor Daha Fazla: tüm bölüm girişleri listelenir
00:22 +323 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir hata görünümü anlaşılır mesaj ve "Tekrar dene" sunar
00:22 +324 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir izni olmayan hatalarda "Tekrar dene" gösterilmez
00:22 +325 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir vakitler cihazda hesaplandıysa uyarı şeridi görünür
00:22 +326 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir konum ilçeyle eşleşmediyse "Şehir seç" düğmesi çıkar
00:22 +327 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_plan_test.dart: (setUpAll)
00:22 +327 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +328 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +329 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +330 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +331 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +332 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +333 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +334 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +335 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +336 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +337 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +338 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +339 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +340 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +341 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +342 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +343 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +344 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +345 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +346 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir kesin alarm izni yoksa ana ekranda uyarı ve "İzin ver" çıkar
00:22 +347 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: hata ve uyarı durumları kullanıcıya bildirilir servis hatasında "Yenile" düğmesi çıkar
00:22 +348 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/widget/responsive_test.dart: (tearDownAll)
00:23 +348 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: bildirim sağlığı kanal kapatılmışsa engellenmiş sayılır
00:23 +349 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: bildirim sağlığı kanal açık ve izin varsa engel yok
00:23 +350 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: bildirim sağlığı bildirim izni yoksa engellenmiş sayılır
00:23 +351 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: bildirim sağlığı servis başlatılamadıysa engellenmiş sayılır
00:23 +352 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: bildirim sağlığı Android dışı ortamda uyarı gösterilmez
00:23 +353 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: zamanlama raporu hata yoksa başarılı
00:23 +354 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: zamanlama raporu tek hata bile raporu başarısız yapar
00:23 +355 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: kanal kimlikleri sessiz ses namaz kanalını kullanır
00:23 +356 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: kanal kimlikleri sistem sesi ayrı (v5) kanal kullanır
00:23 +357 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: kanal kimlikleri her ezan sesi için kanal kimliği benzersiz
00:23 +358 ~6 -1: /home/runner/work/ezanapp/ezanapp/test/core/notification_health_test.dart: iptal ufku planlama ufkunu kapsar 15 günlük planın tüm kimlikleri iptal aralığında
00:23 +359 ~6 -1: Some tests failed.

Failing tests:
  /home/runner/work/ezanapp/ezanapp/test/data/robustness_test.dart: vakit önbelleği bozuk satıra dayanıklı tek satır okuması bozuk kayıtta null döner
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

## sign
```
V2 Signer: certificate DN: CN=EzanAI CI, OU=QA, O=Yazilimceosu, L=Istanbul, C=TR
V2 Signer: certificate SHA-256 digest: 32a745f29d1c3cf50a2267f37ea8c0988b0f80643017c402bf7b3edaa2c81ca8
V2 Signer: certificate SHA-1 digest: fbddd811408ff4a98d6715d346e524e8ece3825d
V2 Signer: certificate MD5 digest: 296d9d52b6dc6ccf2f9cd8caa7e281bd
```

## build
```
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
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
Note: /home/runner/.pub-cache/hosted/pub.dev/geolocator_android-5.2.1/android/src/main/java/com/baseflow/geolocator/location/LocationMapper.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
3 warnings
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Expected to find fonts for (packages/cupertino_icons/CupertinoIcons, MaterialIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 36004 bytes (97.8% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
3 warnings
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Caught exception: Already watching path: /home/runner/work/ezanapp/ezanapp/android
Running Gradle task 'assembleRelease'...                          451.4s
✓ Built build/app/outputs/flutter-apk/app-release.apk (92.7MB)
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
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 36004 bytes (97.8% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Warning: The generated ELF library contains unobfuscated DWARF debugging information.
         To avoid this, use --strip to remove it.
Caught exception: Already watching path: /home/runner/work/ezanapp/ezanapp/android
Running Gradle task 'bundleRelease'...                             73.8s
✓ Built build/app/outputs/bundle/release/app-release.aab (92.8MB)
```
