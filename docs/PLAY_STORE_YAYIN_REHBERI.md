# Ezan Vaktim Pro — Google Play Store Eksik Analizi ve Adım Adım Yayın Rehberi

Bu rehber, **Ezan Vaktim Pro** (`com.yazilimceosu.ezanai`) uygulamasını bilgisayarınıza hiçbir yazılım (Java, Android Studio, Flutter) kurmadan, **yalnızca tarayıcıdan tıklayarak** Google Play Store'da yayına almanız için hazırlanmıştır.

---

## 1. Play Store Hazırlık Denetimi (Neler Tamamlandı / Sizin Yapacağınız Neler Kaldı?)

### A) Uygulama ve Kod Tarafında Tamamlananlar (%100 Hazır)
| Kontrol Kalemi | Durum | Açıklama |
|---|---|---|
| **Hedef Android Sürümü (`targetSdk`)** | ✅ **Hazır (`36`)** | Google Play'in 2026 zorunluluğu olan API 35+ şartını tam karşılar. |
| **Paket Adı (`applicationId`)** | ✅ **Hazır** | `com.yazilimceosu.ezanai` |
| **Görünen Uygulama Adı** | ✅ **Hazır** | `Ezan Vaktim Pro` (Gizlilik politikası ve mağaza metinleriyle birebir uyumlu). |
| **512×512 Mağaza İkonu** | ✅ **Hazır** | `store/play_icon_512.png` (Telefon ve tablette net okunaklı **PRO** rozetli Turkuvaz Cami ikonu). |
| **1024×500 Özellik Grafiği** | ✅ **Hazır** | `store/play_feature_graphic_1024x500.png` (Turkuvaz Cami + PRO mağaza kapak görseli). |
| **Gizlilik Politikası & Koşullar** | ✅ **Hazır** | `docs/privacy.html` ve `docs/terms.html` (**Ezan Vaktim Pro** adıyla güncellendi). |
| **Google Play İzin Politikası Temizliği** | ✅ **Hazır** | Reddedilme sebebi olabilen kullanılmayan `FOREGROUND_SERVICE_DATA_SYNC` ve kısıtlı `USE_EXACT_ALARM` kaldırıldı; yalnızca gerçek kullanılan izinler bırakıldı. |
| **Kod Küçültme & Karartma (R8 + Obfuscation)** | ✅ **Hazır** | Tersine mühendisliğe karşı R8 + `--obfuscate` aktif. |

### B) Yayına Çıkmak İçin Sizin Tamamlayacağınız 5 Adım (Özet)
1. **GitHub Pages'i açmak** (Gizlilik Politikası internet adresini aktif etmek için — 1 dakika).
2. **İmzalı `.aab` (Play Store yayın paketi) dosyasını indirmek** (GitHub üzerinden tek tıkla).
3. **Telefonunuzdan 4–6 adet ekran görüntüsü almak** (Ana Sayfa, Kıble, Kur'an Oklu Takip, Vakitler, İlahi, Daha Fazla).
4. **Google Play Console'da "Uygulama İçeriği" formlarını doldurmak** (Aşağıdaki kopyala-yapıştır cevap anahtarıyla 10 dakika).
5. **Bireysel hesap ise 12 test kullanıcısıyla 14 gün Kapalı Test (Closed Testing) sürecini başlatmak** (Kurumsal/Şirket hesabı ise doğrudan **Üretim / Production** kanalına gönderebilirsiniz).

---

## 2. Adım Adım Tıklama Düzeyinde Yayın Rehberi

### ADIM 1 — Gizlilik Politikası Linkini Aktif Etme (1 Dakika)
Google Play, gizlilik politikasının herkese açık bir internet adresinde olmasını şart koşar. Sayfanız depoda hazırdır:
1. GitHub'da **`YAZILIMCEOSU/ezanapp`** sayfasını açın ve üst menüden **Settings** (Ayarlar) sekmesine tıklayın.
2. Sol menüden **Pages** seçeneğine tıklayın.
3. **Branch** kısmında **`main`** (veya aktif dalınızı), klasör kısmında **`/docs`** seçip **Save** butonuna basın.
4. 1–2 dakika sonra gizlilik politikanız şu adreste yayına girer:
   `https://yazilimceosu.github.io/ezanapp/privacy.html`

---

### ADIM 2 — Mağaza Metinleri ve Görsellerini Yükleme (Ana Mağaza Girişi)
Google Play Console'da **Büyüme > Mağaza varlığı > Ana mağaza girişi** ekranına girin ve şu bilgileri yapıştırın:

- **Uygulama Adı (30 karakter sınırı):**
  ```text
  Ezan Vaktim Pro
  ```
- **Kısa Açıklama (80 karakter sınırı):**
  ```text
  Diyanet uyumlu namaz vakitleri, ezan alarmı, hassas Kıble, Kur'an, ilahi, zikir
  ```
- **Tam Açıklama:**
  ```text
  Ezan Vaktim Pro, günlük ibadetlerinizi tek uygulamada buluşturan modern, reklamsız deneyime uygun ve güvenilir İslami yaşam asistanıdır.

  ÖNE ÇIKAN ÖZELLİKLER:
  • Diyanet Uyumlu Namaz Vakitleri: GPS ile konum değiştikçe otomatik güncellenen il/ilçe vakitleri, sonraki vakte canlı geri sayım, hicri takvim ve kerahat/nafile vakit uyarıları.
  • Gerçek Müezzin Ezan Bildirimleri & Nafile Alarmları: Kâbe İmamı (Mekke), Medine, İstanbul makamları ve cihazınızdan ses seçme imkânı. İşrak, Kuşluk (Duha), Evvabîn, Teheccüd, Cuma, Teravih ve Bayram namazları için özel alarm kurma.
  • 3B Eğim Dengeli Hassas Kıble Pusulası & Cami Bulucu: Jiroskop destekli sensör füzyonu ile telefon eğik tutulsa bile şaşmayan Kıble açısı, harita üzerinde Kâbe yönü ve yakın cami arama.
  • Kur'an-ı Kerim (Renkli Tecvid & Oklu Kelime Takibi): 114 sure Arapça Mushaf ve liste görünümü, çok dilli meal seçimi (Türkçe, İngilizce, Arapça), Diyanet TV mukabele tarzı yeşil ibreli (▲) ve sarı vurgulu kelime takibi, arka planda kesintisiz tilavet.
  • Vokal İlahi Arşivi & Kur'an Radyo: Enstrümansız (acapella/def) vokal ilahiler, çevrimdışı indirme ve cihazdan ses ekleme.
  • Akıllı Tesbih, Sahih Hadis, Esmaül Hüsna, Kaza & Hutbe Takibi, Ramazan İmsakiyesi ve Kaynaklı Dini Rehber Asistanı.

  Not: Ezan Vaktim Pro bilgilendirme ve ibadet kolaylığı amaçlıdır; dini konularda kesin fetva/hüküm yerine geçmez.
  ```
- **Uygulama İkonu (512×512):** Depodaki `store/play_icon_512.png` dosyasını yükleyin.
- **Özellik Grafiği (1024×500):** Depodaki `store/play_feature_graphic_1024x500.png` dosyasını yükleyin.
- **Telefon ve Tablet Ekran Görüntüleri:** Uygulamayı telefonunuzda açıp şu 6 ekranın görüntüsünü (Screenshot) alarak yükleyin:
  1. **Ana Sayfa** (Yeni e-Diyanet modu: sol 3×2 vakit ızgarası + sağ cami silüetli geri sayım + yuvarlak modüller)
  2. **Kıble Pusulası** (Kâbe yönü ve harita/pusula ekranı)
  3. **Kur'an-ı Kerim** (Oklu Takip ve renkli tecvidli sure ekranı)
  4. **Vakitler & Nafile Alarmları** (Günlük/Aylık vakitler ve İşrak/Duha/Teheccüd alarmları)
  5. **İlahi & Dinleti** (Vokal ilahi çalar ekranı)
  6. **Daha Fazla Menüsü** (Tüm modüllerin görünümü)

---

### ADIM 3 — "Uygulama İçeriği" (App Content) Formları Cevap Anahtarı
Google Play Console sol menüsünde **Politika ve programlar > Uygulama içeriği** bölümündeki görevleri sırayla şu şekilde doldurun:

1. **Gizlilik Politikası:**
   - `https://yazilimceosu.github.io/ezanapp/privacy.html`
2. **Reklamlar:**
   - İlk sürümde AdMob kapalıysa: **"Hayır, uygulamamda reklam yok"** (İleride AdMob açıldığında "Evet" olarak güncellenir).
3. **Uygulama Erişimi:**
   - **"Tüm işlevler herhangi bir kısıtlama olmadan kullanılabilir"** (Uygulama üyelik/şifre gerektirmeden açılır).
4. **İçerik Derecelendirmesi (IARC Anketi):**
   - Kategori: **Referans, Haber veya Eğitim** (veya **Yardımcı Program / Üretkenlik**).
   - Şiddet, cinsellik, kumar, yaş kısıtlı içerik, kullanıcıların birbirini bulup mesajlaşması: **Hepsine "Hayır"**.
5. **Hedef Kitle ve İçerik:**
   - Hedef yaş grupları: **13–15, 16–17, 18 ve üzeri** seçin (**13 yaş altını seçmeyin**; seçerseniz Google Aile Politikası gereği ek kısıtlamalar çıkar).
6. **Devlet Uygulamaları / Finansal Özellikler / Sağlık:**
   - Üçüne de **"Hayır / Uygulamam bu özellikleri içermiyor"** işaretleyin.
7. **Veri Güvenliği (Data Safety) Formu:**
   - *Uygulamanız gerekli kullanıcı verilerini topluyor veya paylaşıyor mu?* → **Evet**
   - *Toplanan tüm veriler aktarım sırasında şifreleniyor mu (HTTPS)?* → **Evet**
   - *Kullanıcıların verilerinin silinmesini talep etmesi için bir yol sunuyor musunuz?* → **"Veriler yalnızca cihazda tutulur / hesap oluşturulmaz, uygulama silindiğinde veya uygulama içi verileri sıfırla seçeneğiyle silinir"** (veya destek e-postası).
   - İşaretlenecek veri türü: **Konum > Yaklaşık konum ve Kesin konum**:
     - Yalnızca **Uygulama işlevselliği** (Namaz vakitleri ve Kıble açısı hesabı) için kullanılır.
     - **Üçüncü taraflarla paylaşılmaz**, **Geçici olarak işlenir (Ephemeral)**, **İsteğe bağlıdır** (Kullanıcı manuel şehir de seçebilir).
8. **Hassas İzinler ve API Beyanları (Çok Önemli!):**
   Google Play Console `.aab` dosyasını yüklediğinizde şu iki izin için kısa açıklama sorabilir; aşağıdaki metinleri birebir yapıştırın:
   - **`FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Ön Plan Medya Oynatma Servisi) Açıklaması:**
     ```text
     Kullanıcı Kur'an-ı Kerim tilaveti, ilahi dinletisi veya tam ezan sesini başlattığında, ekran kapansa veya başka bir ekrana geçilse bile sesin kesilmemesi ve bildirim çubuğundaki medya kontrollerinden (durdur/devam et/kapat) yönetilebilmesi için mediaPlayback ön plan servisi kullanılmaktadır.
     ```
     *(Video linki istenirse: Telefonda Kur'an veya İlahi başlatıp ekranı kilitleyerek kilit ekranındaki medya oynatıcıyı gösteren 15 saniyelik bir ekran kaydını YouTube'a "Liste Dışı / Unlisted" yükleyip linkini yapıştırın.)*
   - **`USE_FULL_SCREEN_INTENT` (Tam Ekran Bildirim) Açıklaması:**
     ```text
     Kullanıcının kendi kurduğu namaz vakti ve ezan alarmlarının vakit girdiğinde kilit ekranında zamanında uyarı göstermesi (alarm işlevi) için kullanılmaktadır.
     ```

---

### ADIM 4 — İmzalı Yayın Paketini (`.aab`) Üretme ve Yükleme
1. Eğer henüz imza anahtarınız (`upload.jks`) yoksa `docs/BASLA.md` içindeki **Bölüm 5**'te anlatıldığı gibi tek komutla oluşturup GitHub **Settings > Secrets and variables > Actions** altına `UPLOAD_KEYSTORE_BASE64`, `KEY_STORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` olarak ekleyin.
2. GitHub'da **Actions > Release Build** iş akışını çalıştırarak Google Play'e yüklenecek imzalı **`app-release.aab`** dosyasını indirin.
3. Google Play Console > **Test ve yayın > Üretim** (veya Bireysel hesapta önce **Kapalı test > Alpha**) > **Yeni sürüm oluştur** ekranına `app-release.aab` dosyasını sürükleyip bırakın.

---

### ADIM 5 — 12 Test Kullanıcısı × 14 Gün Kuralı (Bireysel Hesaplar İçin)
- Google Play'in yeni bireysel geliştirici hesapları kuralı gereği, **Üretim (Production)** sekmesinin kilidini açmak için **Kapalı Test (Closed Testing)** kanalında en az **12 gerçek Google hesabının** uygulamayı indirip **14 gün boyunca** cihazında tutması gerekir.
- 14. günün sonunda Play Console ana ekranında **"Üretim erişimi için başvur"** butonu aktif olur; başvuru onaylandığında tek tıkla **Üretim (Production)** kanalında tüm dünyaya yayınlanır.
