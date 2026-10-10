# Faz Yol Haritası ve Doğrulama Kapıları

Bu belge, ürün yol haritasını (MVP → Faz 7) **kabul kapıları** olarak kullanır.
Kod tarafında fazların tamamı yazılı durumdadır; burada her fazın *hangi kanıtla*
doğrulandığı ve hangi kontrollerin **yalnızca gerçek cihazda/hesaplarda**
yapılabileceği listelenir.

> Kural: Bir faz "tamam" sayılmaz, **aşağıdaki 7 kontrol geçmeden** bir sonraki
> faza geçilmez (bkz. §3).

## 1. Faz durum matrisi

| Faz | Kapsam | Durum | Otomatik kanıt |
|---|---|---|---|
| **MVP** | Ana sayfa, vakitler, bildirim, kıble, tesbih, ayarlar | ✅ Yazılı + CI yeşil | `navigation_test.dart`, `notification_plan_test.dart`, `prayer_calculation_test.dart`, debug/release derleme |
| **Faz 2** | Kur'an, hadis, **dualar** | ✅ Yazılı + CI yeşil | `dua_models_test.dart`, `dua_assets_test.dart`, `knowledge_base_test.dart` |
| **Faz 3** | İlahi + player + indirme + playlist | ✅ Yazılı + CI yeşil | `navigation_test.dart` (yollar), `responsive_test.dart` (ekranlar), release derleme; cihaz testi bekliyor |
| **Faz 4** | AI İslam asistanı | ✅ Yazılı + sözleşme testleri | `knowledge_base_test.dart`, `ai_remote_test.dart` (kaynak zorunluluğu, zarif bozulma) |
| **Faz 5** | Ramazan + kişisel takip/istatistik | ✅ Yazılı + CI yeşil | `navigation_test.dart`, `models_test.dart`, `responsive_test.dart`; Ramazan başlangıcı cihazda |
| **Faz 6** | Premium + reklam + abonelik | ✅ Yazılı (konsol kurulumu bekliyor) | release derleme; Play Billing cihaz/hesap testi bekliyor |
| **Faz 7** | Hesap, bulut, cami bulucu, widget, Wear OS, çoklu dil | ⛔ Planlı (hesap/senkron altyapısı hazır) | — |

## 2. Faz başına kod haritası

### MVP

| Madde | Kod | Doğrulama |
|---|---|---|
| Tarih, hicri tarih, konum | `lib/features/home/home_screen.dart`, `lib/data/models/hijri_date.dart` | `models_test.dart` (hicri takvim) |
| Sonraki namaz + geri sayım | `home_screen.dart`, `prayer_countdown_chip.dart` | `prayer_calculation_test.dart` |
| Günlük 5 vakit (6 vakit) | `lib/features/prayers/prayers_screen.dart` | `prayer_calculation_test.dart` ±3 dk |
| Günün ayeti / hadisi | `duaListProvider` ekranları, `dailyContentProvider` | `navigation_test.dart` |
| Otomatik konum + manuel şehir | `locationStatusProvider`, `city_picker_screen.dart` | `navigation_test.dart` |
| Günlük/aylık takvim | `AppRoutes.calendar` (`/takvim`), `imsakiyeProvider` | `navigation_test.dart` |
| Ezan bildirimi, vakit başına aç/kapat | `notification_service.dart`, `notification_settings_screen.dart` | `notification_plan_test.dart` |
| Sessiz saat / uyku modu | `NotificationSettings.isInQuietHours` | `notification_plan_test.dart` |
| Kıble pusulası, derece, kalibrasyon | `lib/features/qibla/qibla_screen.dart`, `compass_service.dart` | `models_test.dart` (İstanbul 151,6°), cihaz testi §4 |
| Tesbih sayaç, hedef, titreşim | `lib/features/zikir/zikir_screen.dart` | `navigation_test.dart`, cihaz testi §4 |
| Ayarlar (tema, dil, yöntem, ses) | `lib/features/settings/settings_screen.dart` | `models_test.dart` (yöntem/ayar serileştirme) |

### Faz 2 — Kur'an, hadis, dualar

| Madde | Kod | Doğrulama |
|---|---|---|
| 114 sure, Arapça, meal | `lib/features/quran/quran_screen.dart`, `surah_screen.dart` | `assets/data/quran/`, `navigation_test.dart` |
| Arama, favoriler, son okunan | `quran_search_screen.dart`, `quran_bookmarks_screen.dart` | `navigation_test.dart` |
| Yazı boyutu, gece modu, paylaşma | `surah_screen.dart` (paylaşım `share_plus`) | cihaz testi §4 |
| Sesli Kur'an | `AppAudioService` + EveryAyah kataloğu | cihaz testi §4 |
| Günün hadisi, kategoriler, arama, kaynak | `lib/features/hadith/*`, `hadith_riyazus_salihin.json` | `assets/data`, `navigation_test.dart` |
| **Dualar (kategorili bölüm)** | `lib/features/dua/dua_screen.dart`, `dua_models.dart`, `duaCatalogProvider` | `dua_models_test.dart`, `dua_assets_test.dart`, `navigation_test.dart` (`/dualar`) |

### Faz 3 — İlahi ve ses platformu

| Madde | Kod | Doğrulama |
|---|---|---|
| Kategori, sanatçı, albüm, arama | `ilahi_screen.dart` + `ilahi_*Provider` | `navigation_test.dart` |
| Favoriler, son dinlenenler, playlist | `playlist_screen.dart`, `ilahiDownloads` | `navigation_test.dart` |
| Player, arka planda/ekran kapalıyken çalma | `player_screen.dart`, `AppAudioService`, `audio_service` | cihaz testi §4 |
| Çevrimdışı indirme | `downloads_screen.dart` | cihaz testi §4 |
| Lisans zorunluluğu | `IlahiTrack.license` + uzak katalog filtresi | `models_test.dart`, `docs/DATA_SOURCES.md` §7 |

### Faz 4 — AI İslam asistanı

| Madde | Kod | Doğrulama |
|---|---|---|
| Ana ekranda "EzanAI'ya Sor" | `home_screen.dart` → `AppRoutes.ai` | `navigation_test.dart` |
| Kaynak gösteren cevap | `knowledge_base.dart` (24 kayıt, `citations` zorunlu) | `knowledge_base_test.dart` |
| Mezhep farkları | `madhabNotes` + UI bölümü | `knowledge_base_test.dart` |
| Kesin hüküm vermeme | `AiAnswer.disclaimer`, eşleşme eşiği 2,2 | `knowledge_base_test.dart` (negatif sorular) |
| Backend sözleşmesi, kaynaksız yanıtı reddetme | `ai_service.dart` | `ai_remote_test.dart` |
| API çökerse çalışmaya devam | Yerel taban → dürüst yanıt zinciri | `ai_remote_test.dart` (500/bozuk JSON) |

### Faz 5 — Ramazan ve kişisel takip

| Madde | Kod | Doğrulama |
|---|---|---|
| Sahur/iftar geri sayımı, imsakiye | `ramadan_screen.dart`, `imsakiyeProvider` | `navigation_test.dart`, cihaz testi §4 |
| Hatim takibi, kaza orucu, zikir hedefi | `hatimProgressProvider`, `kazaFastsProvider`, `zikirDailyProvider` | `navigation_test.dart` |
| Günlük/haftalık istatistik | `zikir_stats_screen.dart`, `todayLogProvider` | `navigation_test.dart` |
| Ramazan bildirimleri (sahur/iftar) | `scheduleRamadan` | `notification_plan_test.dart` (kimlik kararları) |

### Faz 6 — Premium ve gelir modeli

| Madde | Kod | Doğrulama |
|---|---|---|
| Reklamsız/premium kilitleri | `isPremiumProvider`, `AdsService` | `models_test.dart`; cihaz+hesap testi §4 |
| Google Play Billing abonelik | `BillingService`, `ezanai_premium_*` | Play Console kurulumu bekliyor (`docs/RELEASE.md` §6) |
| AdMob | `AdBanner`, `ADMOB_*` dart-define | Boş kimlikte reklam göstermez (güvenli varsayılan) |
| Ücretsiz AI kotası | `kFreeDailyAiLimit`, `aiUsageProvider` | Ürün kararı; cihazda doğrulanır |

### Faz 7 — Platform seviyesi (planlı)

Hesap (Supabase Auth) ve bulut yedekleme (`SyncService`, `user_data` tablosu) altyapısı
**hazırdır**; cami bulucu, widget, Wear OS/Android Auto ve çoklu dil henüz yoktur.
Bu faz kullanıcı kitlesi oluştuktan sonra açılır.

## 3. Her faz sonunda koşulacak 7 kontrol

| # | Kontrol | Komut / kanıt |
|---|---|---|
| 1 | Kod derlenir/çalışır | `flutter analyze` (0 sorun) + `flutter test` |
| 2 | Android build alınır | `flutter build apk --debug` **ve** `flutter build appbundle --release` (CI'da her push'ta) |
| 3 | Navigasyon çalışır | `flutter test test/router/navigation_test.dart` |
| 4 | API çalışır / çöktüğünde uygulama durmaz | `flutter test test/data/ai_remote_test.dart` (deneme backend adresiyle) |
| 5 | Bildirim çalışır | `flutter test test/core/notification_plan_test.dart` + cihaz kontrolü §4 |
| 6 | Responsive (telefon + tablet) | Cihaz/emülatör kontrolü §4 (otomatik test yok) |
| 7 | Hatalar temizlendi | `.ci/report.md` tablosunda tüm satırlar `success` (son koşu: ✅ 7/7) |

## 4. Yalnızca cihazda yapılabilen kontroller

Aşağıdakiler gerçek Android cihaz/emülatör gerektirir; CI bunları doğrulayamaz.

| # | Kontrol | Adım |
|---|---|---|
| 1 | Bildirim izinleri ve ezan sesi | Ayarlar > Bildirimler > izin ver; "Test bildirimi gönder" ile sesi doğrula; sessiz modda davranışı gözle |
| 2 | Tam zamanlı alarm (Android 12+) | Ayarlar > Uygulamalar > EzanAI > Alarmlar ve hatırlatıcılar açık olmalı |
| 3 | Vakit bildirimi zamanlaması | Bir sonraki vakti 2 dk sonrasına ayarlayıp (veya sistemi ileri alıp) bildirimin geldiğini gör |
| 4 | Kıble pusulası | Açık alanda telefonu 8 çizerek kalibre et; Kâbe yönü ile 151–152° (İstanbul) uyumunu kontrol et |
| 5 | Tesbih titreşimi/haptik | Sayaç artırımında titreşim; hedef tamamlanınca geri bildirim |
| 6 | Arka planda ses (Kur'an/ilahi/ezan) | Ekranı kapat, kilit ekranı kontrollerini, Bluetooth/kulaklık tuşlarını dene |
| 7 | Çevrimdışı indirme | Bir ilahiyi indir, uçak modunda çal → çalmalı |
| 8 | Çevrimdışı vakitler | Uçak modunda uygulamayı aç → son önbellekten vakitler görünmeli, çökme olmamalı |
| 9 | Konum izni reddi | İzni reddet → manuel şehir seçimi ile uygulama çalışmalı |
| 10 | Tablet/responsive | 7" ve 10" (veya katlanabilir) ekranda tüm sekmeler + kıble/Kur'an okuma düzeni |
| 11 | Premium akışı | Play Console lisans test kullanıcısıyla abonelik satın al/al/iptal; reklamların kalktığını doğrula |
| 12 | FCM + Crashlytics | `google-services.json` ile derle, test bildirimi gönder, kasıtlı çökme sonrası Crashlytics kaydını gör |

## 5. Sürüm kapsamı seçenekleri

Yol haritası "önce MVP" diyor; kod tabanı ise tüm fazları içeriyor. İki yol var:

**A) Tam kapsamlı ilk sürüm (önerilen, mevcut durum):**
Tüm fazlar zaten çalışır ve CI'dan geçer. Play incelemesi için ek beyanlar gerekir
(abonelik, reklam, AI içerik politikası, sağlık değil — dinî içerik beyanı).
Avantaj: tek pazarlama hikâyesi, farklılaştırıcı (AI) ilk günden görünür.
Dezavantaj: daha uzun inceleme, daha çok manuel test yüzeyi.

**B) MVP kapılı ilk sürüm:**
Faz 2+ özellikleri derleme zamanı bayraklarıyla gizlenir (`AppConfig` içine
`FEATURE_*` bayrakları), Play'e yalnızca MVP gönderilir; sonraki sürümlerde
bayraklar açılır. Avantaj: hızlı ve düşük riskli inceleme, kademeli pazarlama.
Dezavantaj: bayrak bakımı ve iki kez test yükü.

Karar verilmeden **hiçbir özellik koddan çıkarılmaz**; B seçilirse yalnızca
bayraklama yapılır (geri dönüşü kolay, veri kaybı yok).

> **Karar (7 Ekim 2026): B — MVP kapılı ilk sürüm.**
> Bayraklar `lib/core/config/app_features.dart` içinde tanımlı ve varsayılan olarak
> **açık** (CI tam kapsamı test eder); Play derlemesinde `--dart-define=FEATURE_*=false`
> ile kapatılır. Kapalı modüllerin sekmeleri ve girişleri gizlenir, kapalı yollara
> gelen bağlantılar ana sayfaya yönlendirilir. Davranış
> `test/widget/mvp_mode_test.dart` ile doğrulanır; derleme komutu ve mağaza metinleri
> `docs/KURULUM.md` §6 ile `docs/MAGAZA_GORSELLERI.md` içindedir.

## 6. Önerilen sıradaki iş sırası

1. ~~**Dualar bölümü** (Faz 2'nin tek gerçek eksiği)~~ ✅ Tamamlandı.
2. ~~**Responsive otomatik testi**: 320×568 / 411×914 / 1024×1366 için anahtar
   ekranların (11 ekran) overflow üretmediğini doğrulayan widget testleri~~
   ✅ Tamamlandı — CI'da tüm satırlar `success`
   (`.ci/report.md`: analyze + test + uzak AI sözleşmesi + debug APK + release AAB).
3. ~~**Vakit zinciri testi**: önbellek → Diyanet → Aladhan → yerel hesap
   sırasının bozulmadığını doğrulayan repository testi (sahte HTTP + geçici DB)~~
   ✅ Tamamlandı (`test/data/prayer_chain_test.dart`, 6 grup / 24 test).
4. **Cihaz kontrol listesi** (§4) sizin cihazınızda uygulanır; çıkan hatalar
   bu belgeye işlenir. → **Sıradaki adım.**
5. Ardından Faz 6 kurulumu (Play Console ürünleri) ve imzalama/`google-services.json`.

## 7. Yayın (Play Store) zaman çizelgesi ve kapılar

| Aşama | Kim yapar | Süre (tipik) |
|---|---|---|
| Kod + CI yeşil (analyze, test, APK, AAB) | tamamlandı | ✅ bitti |
| Cihazda kurulum (CI'daki debug APK ya da kendi derlemeniz) | siz | 10 dakika |
| Cihaz kontrol listesi (§4, 12 madde) | siz | 1–2 saat |
| Firebase (`google-services.json`) + imzalama anahtarı (`key.properties`) | siz | 1 saat |
| Play Console: uygulama kaydı, mağaza metni/görselleri, veri güvenliği, içerik derecelendirmesi | siz (metinler `docs/PLAY_STORE.md`) | 2–4 saat |
| **Dahili test** kanalı (kendi telefonunuz) | siz | Yükleme sonrası ~1 saat içinde kurulabilir |
| **Kapalı test**: en az 12 test kullanıcısı, 14 gün aralıksız | siz + 12 kişi | **zorunlu 14 gün** |
| Üretim erişimi başvurusu + inceleme | Google | genelde ≤ 7 gün |
| Üretime yayın (inceleme) | Google | genelde ≤ 7 gün |

> **Önemli (kişisel geliştirici hesapları, 13 Kasım 2023 sonrası açılanlar):**
> Google, üretim erişimi vermeden önce **en az 12 test kullanıcısının aralıksız
> 14 gün** kapalı teste kayıtlı kalmasını şart koşar. Kurumsal (organizasyon)
> hesaplar bu şartın dışındadır. Bu 14 gün, kod tarafında hızlandırılamayan tek
> kapıdır; kapalı test takvimi bu yüzden **en erken** başlatılmalıdır.
> Kaynak: Google Play Console Yardım — "Yeni kişisel geliştirici hesapları için
> uygulama test şartları".
