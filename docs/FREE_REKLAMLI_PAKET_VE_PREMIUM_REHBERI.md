# Ezan Vaktim Pro — Ücretsiz (Reklamlı) Paket + Premium Rehberi

> **Bu belge kimin için?** Yazılım bilgisi olmayan uygulama sahibi için,
> **tıklama düzeyinde** yazıldı. Sırayla uygulayın; her adımda "ne göreceksiniz"
> ve "ne yapacaksınız" açıkça yazılı.
>
> **Bugünkü durum (27 Ekim 2026):** Uygulama Play Store kurallarına uygun
> biçimde `targetSdk 36` (Android 16) ile derleniyor. Google, **31 Ağustos
> 2026'dan** itibaren yeni uygulama ve güncellemelerde **API 36** şartı
> koydu; bizim paketimiz bu şartı **zaten karşılıyor**, ek süre (1 Kasım 2026)
> talep etmenize gerek yok.

---

## 0) Özet: Hangi paketi kime vereceğiz?

| Paket | Kime | Reklam | Gelir modeli | Derleme komutu |
|---|---|---|---|---|
| **Ücretsiz (reklamlı)** | Herkes | Var (banner + seyrek geçiş reklamı) | AdMob reklam geliri | `flutter build appbundle --release` + AdMob kimlikleri |
| **Premium** | Abone olanlar | **Hiç yok** | Aylık / yıllık / ömürlük satın alma | Aynı dosya, uygulama içinden açılır |
| **Test (dene-apk)** | Siz ve testçiler | Var, **Google test reklamları** | — | `--dart-define=ADMOB_TEST_MODE=true` |

Tek bir uygulama (`com.yazilimceosu.ezanai`) yayınlanır. Premium, aynı
uygulamanın içinde **"reklamsız + ek özellikler"** olarak açılır.

---

## 0.1) Şimdi sıra sizde — 7 adım (tahmini süre: 1 akşam + 14 gün test)

| # | Yapılacak | Nerede | Süre |
|---|---|---|---|
| 1 | AdMob hesabı + **banner** ve **geçiş** reklam birimi oluşturun | Bölüm 2.2 | 10 dk |
| 2 | `app-ads.txt` dosyasını `ezanai.app` kök dizinine yükleyin | Bölüm 2.4 | 5 dk |
| 3 | Play Console'da **uygulama oluşturun** + mağaza metinlerini girin | `docs/PLAY_STORE.md` | 30 dk |
| 4 | **Uygulama içeriği** formları: Reklamlar = Evet, Veri güvenliği, IARC | Bölüm 6.4 | 20 dk |
| 5 | **Kapalı test** kanalına AAB yükleyin, **12 test kullanıcısı** ekleyin | Bölüm 6.5 | 15 dk |
| 6 | **14 gün** test + geri bildirim düzeltmeleri | — | 14 gün |
| 7 | Üretime **kademeli %20** yayın; ardından Premium aboneliği açın | Bölüm 3 + 6.5 | 20 dk |

> **Sıra önemli:** Premium aboneliğini, ücretsiz sürüm yayına çıkmadan önce de
> açabilirsiniz; ancak **kapalı test bitmeden** üretim yayını yapılamaz.
> Reklamlar ücretsiz sürümde, Premium'da **hiç** gösterilmez (kod hazır).

---

## 1) Play Store'u iyice inceledik: 2026'da sizi ne bekliyor?

| Konu | 2026 kuralı | Bizim durumumuz |
|---|---|---|
| **Hedef API** | Yeni uygulama/güncelleme: **API 36** (31.08.2026'dan beri) | ✅ `targetSdk 36` |
| **16 KB sayfa boyutu** | Android 15+ cihazlar için `targetSdk 35+` uygulamalarda zorunlu | ✅ Flutter 3.47 / AGP 8.12 uyumlu |
| **Paket biçimi** | Play'e **AAB** yüklenir (APK değil) | ✅ CI `appbundle` üretiyor |
| **Reklam beyanı** | "Bu uygulama reklam içeriyor" → **Evet** | Ücretsiz pakette Evet |
| **Veri güvenliği formu** | Konum, cihaz kimliği (reklam kimliği) beyanı zorunlu | AdMob entegrasyonu ile beyan edilecek (Bölüm 3.7) |
| **Gizlilik politikası** | Zorunlu, herkese açık URL | `AppConstants.privacyUrl` (ezanai.app/privacy.html) — **yayında olmalı** |
| **Kapalı test** | **Kişisel** geliştirici hesapları üretime geçmeden önce **12 test kullanıcısı ile 14 gün** kesintisiz kapalı test yapmalı | Planlandı (Bölüm 6) |
| **AI üreten içerik** | Üretken AI sunan uygulamalarda **kullanıcı bildirim/şikâyet mekanizması** ve politika uyumu | İslami AI Asistanı ekranında "Bildir" akışı (Faz 4) |
| **Ön plan servisi** | Android 14+ `FOREGROUND_SERVICE_MEDIA_PLAYBACK` Play Console'da **beyan** edilmeli | Ses oynatma için beyan edilecek (Bölüm 6.4) |
| **Kesin alarm** | `SCHEDULE_EXACT_ALARM` kullanıcı tarafından kapatılabilir; uygulama buna dayanıklı olmalı | ✅ "Pil Optimizasyonu İstisnası" + hatırlatma |
| **Hassas izin** | Konum izni gerekçesi veri güvenliği formunda açıkça yazılmalı | ✅ Yalnızca vakit/kıble için, cihazda işlenir |

> **Not:** Play Console, yeni uygulamalarda ilk yüklemeden sonra 1–7 gün
> inceleme bekletebilir. İlk yükleme için **kapalı test** kanalını kullanın.

---

## 2) ÜCRETSİZ (REKLAMLI) PAKET — kurulum

### 2.1. Uygulamada zaten hazır olanlar
* `Google Mobile Ads` SDK bağlı (`google_mobile_ads: ^9.1.0`).
* Banner alanları: Ana ekran, Vakitler, Kur'an sure listesi, Hadis, Dua,
  İlahi, Ramazan, More ve Ayarlar alt bölümü.
* Geçiş reklamı: **yalnızca** tesbih hedefi ilk kez tamamlandığında ve
  **en fazla 3 dakikada bir**.
* **Premium kullanıcıda hiç reklam yüklenmez** (ağ isteği bile yapılmaz).
* **UMP (GDPR/DMA) onay akışı**: AB/AEA kullanıcısına ilk açılışta Google'ın
  onay formu gösterilir; Ayarlar > *Reklam gizlilik ayarları* ile değiştirilebilir.
* `AndroidManifest` içinde `com.google.android.gms.permission.AD_ID` izni var.
* Reklamlar açılışta **ilk kareyi bekletmez**; altyapı hazır olana kadar
  banner alanı hiç çizilmez (boş/bozuk alan görünmez).

### 2.2. AdMob hesabı açın (5 dakika)

1. Tarayıcıdan **admob.google.com** → *Başlayın* → Google hesabınızla giriş.
2. Ülke **Türkiye**, para birimi **TRY (₺)**, saat dilimi **İstanbul**.
3. *Uygulamalar* → **Uygulama ekle** → **Android** → "Uygulama mağazada
   yayında değil" seçin → Uygulama adı: **Ezan Vaktim Pro**.
4. Kaydettikten sonra size bir **Uygulama Kimliği** verilir:
   `ca-app-pub-XXXXXXXX~YYYYYYYY` (tilde `~` işaretli olan).
   → Bu kimlik `ANDROID_APP_ID` olarak derlemede kullanılır.
5. *Reklam birimleri* → **Reklam birimi ekle**:
   * **Banner** → adı `ana_ekran_banner` → kimliği `ca-app-pub-XXXX/1111`.
   * **Geçiş reklamı (Interstitial)** → adı `tesbih_hedef` → `ca-app-pub-XXXX/2222`.
   * (İsteğe bağlı) **Ödüllü** → `ca-app-pub-XXXX/3333`.
6. **Ödeme bilgileri** → AdMob *Ödemeler* bölümünde adres/vergi bilgisi
   girin. 100 ABD doları eşiğinde ödeme yapılır.

### 2.3. Uygulamayı derlerken kimlikleri verin

```bash
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/1111 \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXX/2222 \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-XXXX/3333 \
  --dart-define=ADMOB_TEST_MODE=false
```

ve `android/gradle.properties` (ya da ortam değişkeni) içine:

```properties
ADMOB_ANDROID_APP_ID=ca-app-pub-XXXX~YYYY
```

> Kimlik verilmezse **reklamlar tamamen kapalı** çalışır: uygulama bozulmaz,
> boş alan da görünmez. Bu davranış bilerek böyle tasarlandı.

**Kendi cihazınızda test ederken** (Play'e yüklemeden önce) mutlaka:

```bash
flutter build apk --release --dart-define=ADMOB_TEST_MODE=true
```

Bu komut, Google'ın resmî **test reklam** kimliklerini kullanır. Böylece
"geçersiz tıklama" nedeniyle AdMob hesabınız **askıya alınmaz**.

### 2.4. `app-ads.txt` (AdMob doğrulaması için zorunlu)

1. AdMob → *Uygulamalar* → uygulamanız → **app-ads.txt** sekmesi →
   verilen satırı kopyalayın (şuna benzer):
   `google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0`
2. Web sitenizin **kök dizinine** `app-ads.txt` adıyla yükleyin:
   `https://ezanai.app/app-ads.txt`
3. Play Console'daki *Mağaza girişi* → **Web sitesi** alanı bu alan adıyla
   aynı olmalı. AdMob doğrulaması 24–48 saat sürer.

### 2.5. AdMob politika kontrol listesi (kritik)

- [x] Reklamlar içerik düğmelerinin **üzerine binmiyor**, yanlış tıklama yok.
- [x] Açılışta tam ekran reklam **yok** (uygulama açılış reklamı göstermiyor).
- [x] Kullanıcı **ezan dinlerken / Kur'an okurken** reklam gösterilmiyor.
- [x] Geçiş reklamı 3 dakika sınırlı; art arda gösterilmiyor.
- [x] AB/AEA kullanıcısına **UMP onay formu** gösteriliyor.
- [ ] Play Console > *Uygulama içeriği* → **Reklamlar: Evet** işaretlenecek.
- [ ] Play Console > *Veri güvenliği* → **Cihaz veya diğer kimlikler
      (Reklam kimliği)** beyan edilecek.

---

## 3) PREMIUM — sizin yapacağınız adımlar (tıklama düzeyinde)

> Premium'u **biz kodladık** (3 plan: aylık / yıllık / ömürlük + satın alma
> doğrulama + geri yükleme). Sizin yapmanız gereken tek şey **Play
> Console'da ürünleri oluşturmak** ve **fiyat girmek**.

### 3.1. Ön koşul: Ödeme (Merchant) hesabı
1. **play.google.com/console** → sol menü **Kurulum** → **Ödemeler profili**.
2. Satıcı bilgileri: şahıs/şirket, IBAN, vergi bilgileri, adres.
3. Onay 1–3 iş günü sürebilir. **Ödeme profili onaylanmadan abonelik
   oluşturulamaz.**

### 3.2. Abonelikleri oluşturma
1. Sol menü **Paraya dönüştür** → **Ürünler** → **Abonelikler** →
   **Abonelik oluştur**.
2. **Ürün kimliği** (değiştirmeyin, kodda bu kimlikler yazılı):
   * `ezanai_premium_monthly`
   * `ezanai_premium_yearly`
3. **Temel plan** ekleyin:
   * Aylık: **faturalama dönemi = 1 ay**, otomatik yenileme açık.
   * Yıllık: **faturalama dönemi = 1 yıl**, otomatik yenileme açık.
4. **Ücretsiz deneme** (isteğe bağlı): *Teklif ekle* → **Ücretsiz deneme**
   → **7 gün** (yıllık için 14 gün önerilir).
5. **Fiyat**: Play otomatik kur çevirisi önerir; Türkiye için
   * Aylık ₺79,99
   * Yıllık ₺599,99 (≈ ayda ₺50 → "%37 tasarruf" rozeti)
   * Ömürlük ₺1.499,99
   (Rakip analizi: e-Diyanet reklamlı ücretsiz, Muslim Pro aylık ~₺120.
   Bizim fiyat konumlandırmamız **agresif ama sürdürülebilir**.)
6. **Ülke/bölge**: Tüm ülkeler (Türkiye dahil).

### 3.3. Ömürlük (lifetime) ürün
1. **Paraya dönüştür** → **Ürünler** → **Uygulama içi ürünler** →
   **Ürün oluştur**.
2. Kimlik: `ezanai_premium_lifetime` — ad: *Ezan Vaktim Pro Ömürlük*.
3. Fiyat: ₺1.499,99 → **Etkinleştir**.
   > Ömürlük ürün **abonelik değil, tek seferlik üründür**; kodumuz bunu
   > doğru şekilde ayırıyor (`BillingService._subscriptionIds`).

### 3.4. Test kartıyla satın alma testi
1. Play Console → **Kurulum** → **Lisans testi** → kendi Google hesabınızı
   **lisans test kullanıcısı** olarak ekleyin.
2. Play Console → **Kapalı test** kanalına AAB yükleyin, test kullanıcısı
   olarak katılın.
3. Uygulama → **Premium** ekranı → plan seçin → ödeme sayfasında
   **"Test kartı, her zaman onaylanır"** yazar.
4. Satın alma sonrası: reklamlar **anında** kaybolur (kod bunu garanti eder),
   Premium rozeti görünür.
5. **Geri yükle** düğmesiyle aynı hesapta satın alma geri gelir.

### 3.5. Sunucu tarafı doğrulama (opsiyonel ama önerilir)
* `BillingService` satın alma makbuzunu `/billing/verify` endpoint'ine
  gönderebilir (`EZANAI_API_BASE` tanımlıysa).
* Backend yoksa Google Play'in yerel doğrulaması kullanılır; uygulama
  premium durumunu cihazda önbelleğe alır (`premiumCache`).

### 3.6. İade ve iptal
* Abonelik iptali: Play Store → *Abonelikler* → iptal. Uygulama durumu
  `statusStream` ile anında günceller, reklamlar geri gelir.
* İade: Play Console → *Sipariş yönetimi* → **İade**.

### 3.7. Veri güvenliği formu (reklam + premium için)
Play Console → **Uygulama içeriği** → **Veri güvenliği**:

| Soru | Cevap |
|---|---|
| Konum toplanıyor mu? | **Evet** — yaklaşık/kesin konum, *Uygulama işlevi* amacıyla, **cihazda işlenir**, aktarılmaz (backend yoksa) |
| Cihaz veya diğer kimlikler? | **Evet** — reklam kimliği (AdMob), *Reklam* amacıyla |
| Veriler şifreli aktarılıyor mu? | **Evet** (HTTPS) |
| Kullanıcı veri silmeyi talep edebilir mi? | **Evet** — Ayarlar > *Verilerimi sil* |
| Reklam içeriyor mu? | **Evet** (Premium'da kaldırılabilir) |

---

## 4) Premium'da ne satıyoruz? (özellik matrisi)

| Özellik | Ücretsiz (reklamlı) | Premium |
|---|---|---|
| Namaz vakitleri, ezan bildirimi, kıble, Kur'an, tesbih | ✅ | ✅ |
| Reklamlar | Banner + seyrek geçiş | ❌ **Hiç yok** |
| AI İslam Asistanı | Günde **10** soru | **Sınırsız** |
| İlahi indirme (çevrimdışı) | 3 ilahi | **Sınırsız** |
| Ezan sesleri | 3 ses | **Tüm sesler + özel ezan** |
| Bulut yedekleme (favoriler, kaza, hatim) | ❌ | ✅ |
| Ana ekran widget'ı (Faz 3) | ❌ | ✅ |
| Kıble hassas modu / kamera ile nişan | ✅ | ✅ (herkese açık kalır) |
| Özel temalar (Faz 5) | 2 tema | **6 tema** |
| Hutbe/dua sesli okuma (Faz 3) | ❌ | ✅ |

> **İlke:** Temel ibadet özellikleri (vakit, ezan, kıble, Kur'an) **asla**
> premium'a kilitlenmez. Play Store'un "temel işlevsellik" politikası ve
> kullanıcı güveni bunu gerektirir.

---

## 5) Kıble doğrulaması — 4 aşamalı kontrol (bu sürümde yapıldı)

| Aşama | Ne kontrol edildi | Sonuç |
|---|---|---|
| **1. Matematik** | Kâbe kerterizi 8 şehir referansı + **WMM-2025** manyetik sapma modeli (16 şehir, NOAA referansı) | Sapma hatası **< 0.15°** (Türkiye'de < 0.01°) |
| **2. Sensör** | Ham manyetik açı → gerçek kuzey → Kıble farkı zinciri, 0/360 sarmalaması, çift düzeltme | Tüm testler geçti |
| **3. Arayüz** | e-Diyanet kadranı: sabit 12 yönü oku, `qibla − heading` rozeti, dönüş yönü, ±5° hizalama | 120 açıda doğrulandı |
| **4. Uçtan uca** | Bağcılar / İstanbul / Londra / New York / Sidney / Tokyo senaryoları | Hizalama hatası **< 0.01°** |

**2026-10-27 — bağımsız tekrar doğrulama (4/4 geçti):** Uygulama kodundan
bağımsız olarak `python3 tools/verify_qibla.py` ile yeniden hesaplandı:
kerteriz üç ayrı matematik yöntemiyle (küresel `tan`, vektör biçimi, WGS-84
Vincenty) **en büyük fark 0.181°**; 16 şehirde manyetik sapma resmî NOAA
`WMM_2025.COF` katsayılarıyla **en büyük fark 0.0005°**; konum + pusula +
çizim hatalarının birleşik üst sınırı **1.38°** (±5° eşiğinin çok altında).
Ayrıntılı tablolar: **`docs/KIBLE_DOGRULAMA_RAPORU.md`**.

**Eski hata (giderildi):** Manyetik sapma, Türkiye dışında 12°'ye kadar
yanlış hesaplanıyordu (Sidney +12°, New York −8.5°). Artık resmî NOAA
WMM-2025 küresel harmonik modeli kullanılıyor; cihazın kendi
`GeomagneticField` değeri varsa o daha öncelikli.

**Ek düzeltmeler:**
* Konum değişince sapma açısı **otomatik yenileniyor** (eskiden ekran
  açılışındaki değerde kalıyordu).
* Sensör verisi gelmeden üst kutuda **uydurma açı** gösterilmiyor (`—`).
* Telefonu dik tutup Kâbe'ye nişan alırken artık **"eğik tutuyorsunuz"**
  uyarısı çıkmıyor.

---

## 6) Play Store'a çıkış — adım adım kontrol listesi

### 6.1. Hesap
- [ ] **play.google.com/console** → 25 $ tek seferlik kayıt ücreti.
- [ ] Kimlik doğrulama (kimlik kartı + adres).
- [ ] **Kişisel hesap** ise: *Ayarlar > Geliştirici hesabı*, D-U-N-S gerekmez.

### 6.2. Uygulama oluşturma
- [ ] *Tüm uygulamalar* → **Uygulama oluştur**.
- [ ] Ad: **Ezan Vaktim Pro** · Dil: **Türkçe** · Tür: **Uygulama** ·
      Ücretsiz/Premium: **Ücretsiz** (uygulama içi satın alma var).
- [ ] Beyanlar: *Uygulama*, *Oyun değil*, *Çocuklara yönelik değil*.

### 6.3. Mağaza girişi (Store listing)
- [ ] Kısa açıklama (80 karakter), tam açıklama (4000 karakter).
- [ ] **512×512 ikon** (turkuvaz, "PRO" okunaklı — `docs/MAGAZA_GORSELLERI.md`).
- [ ] **1024×500 öne çıkan görsel**, **en az 2 telefon ekran görüntüsü**
      (telefon + tablet önerilir).
- [ ] Gizlilik politikası URL'si.
- [ ] İletişim e-postası + web sitesi.

### 6.4. Uygulama içeriği formları
- [ ] **Gizlilik politikası**: URL girin.
- [ ] **Uygulama erişimi**: Tüm işlevler giriş gerektirmeden kullanılabilir.
- [ ] **Reklamlar**: **Evet**.
- [ ] **İçerik derecelendirmesi (IARC)**: anket → beklenen **3+ / Herkes**.
- [ ] **Hedef kitle**: 18+ / genel.
- [ ] **Veri güvenliği**: Bölüm 3.7'deki tablo.
- [ ] **Ön plan servisi**: *Medya oynatma* (Kur'an/ilahi arka planda çalar).
- [ ] **Hassas izin**: Konum (vakit + kıble) gerekçesi.
- [ ] **AI üretilen içerik**: asistanın kaynak gösterdiği + "bildir" akışı
      olduğu beyanı (Faz 4).

### 6.5. Yükleme ve yayın
- [ ] CI'dan inen `app-release.aab` → **Test ve yayın > Kapalı test** → **Yeni sürüm**.
- [ ] Sürüm notları (Türkçe): "Kıble hassasiyeti WMM-2025 ile güncellendi…"
- [ ] **12 test kullanıcısı** ekleyin, **14 gün** kesintisiz test.
- [ ] Test geri bildirimleri → düzeltmeler → **Üretim** → *Kademeli yayın* **%20**.

---

## 7) Sıradaki fazlar ve eksikler

| Faz | Kapsam | Durum |
|---|---|---|
| **Faz 1** | Kıble pusulası e-Diyanet hassasiyeti, WMM-2025, sabit ok, canlı derece, kalibrasyon | ✅ Tamamlandı |
| **Faz 2** | 32 hutbelik arşiv, 8 kategori, arama, ana ekrandan geçiş | ✅ Tamamlandı |
| **Faz 3** | **Ücretsiz reklamlı paket** (AdMob + UMP + sıklık sınırı) | ✅ Bu sürümde tamamlandı |
| **Faz 4** | Ana ekran **Android widget'ı** (vakit + Chronometer geri sayım), hutbe/dua **sesli okuma (TTS)**, AI asistanına **"bildir"** akışı | ✅ Tamamlandı |
| **Faz 5** | **Bulut yedekleme** (Supabase) + cihazlar arası eşitleme, özel temalar | 🔜 Planlandı |
| **Faz 6** | **Kâbe canlı yayını + Diyanet/Kur'an radyosu**, çevrimdışı ilahi indirme yöneticisi | 🔜 Planlandı |
| **Faz 7** | Premium abonelik canlı testi, mağaza görselleri, kapalı test → üretim yayını | 🔜 Yayın fazı |

### Bilinen eksikler (dürüst liste, 2026-10-27)
1. **Bulut yedekleme** altyapısı hazır ama Supabase anahtarları girilmedi
   (Faz 5).
2. İlahi kataloğu **lisanslı kaynak** gerektiriyor; şu an açık lisanslı
   (no-music) kayıtlar kullanılıyor, katalog genişletilecek (Faz 6).
3. **Play Store mağaza görselleri** (telefon + tablet ekran görüntüleri)
   üretilecek — metinler hazır (`docs/PLAY_STORE.md`), görseller sırada.
4. Gerçek cihazda **saha testi**: metalden uzak 8 çizerek kalibrasyon ve
   e-Diyanet ile yan yana karşılaştırma (matematik/test tarafı hazır).
5. AdMob hesabı + gerçek birim kimlikleri + `app-ads.txt` yayına alınacak
   (Bölüm 2.2–2.4).

> Faz 4 kapsamı (widget, TTS, AI "bildir") **tamamlandı**; 1, 2 ve 6 numaralı
> eski eksikler giderildi.

---

## 8) Hızlı komut özeti

```bash
# 1) Test reklamlarıyla dene (Play'e YÜKLEMEYİN)
flutter build apk --release --dart-define=ADMOB_TEST_MODE=true

# 2) Yayın paketi (gerçek AdMob kimlikleriyle)
flutter build appbundle --release --obfuscate \
  --split-debug-info=build/symbols \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/1111 \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXX/2222 \
  --dart-define=ADMOB_TEST_MODE=false

# 3) Reklamsız özel dağıtım (ör. kurumsal)
flutter build apk --release --dart-define=ADS_ENABLED=false
```

---

### Sık sorulanlar

**Reklamlar görünmüyor, neden?**
Kimlikler verilmediyse `ADMOB_TEST_MODE=true` ile derleyin. Yayın paketinde
ise AdMob hesabı onayı, `app-ads.txt` doğrulaması ve UMP onayı tamamlanmış
olmalı. Uygulama hiçbir durumda boş reklam alanı bırakmaz.

**Premium alınca reklamlar hemen kalkar mı?**
Evet — `BillingService.statusStream` → `AdsService.setPremium(true)` anında
çalışır, yüklü reklamlar bellekten atılır.

**Kıble 1–2° oynuyor, hata mı?**
Hayır. Telefon manyetometreleri ±3–5° tipik hata payına sahiptir. Uygulama
bu yüzden ±5° "hizalı" kabul eder ve manyetik parazit uyarısı gösterir.
Kesin yön için: telefonu 8 çizer gibi hareket ettirin (kalibrasyon), metal
kılıf/masa kenarından uzaklaşın, dik tutup nişan alın.
