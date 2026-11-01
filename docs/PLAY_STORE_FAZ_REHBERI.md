# Ezan — GitHub Güvenliği ve Google Play Store Yayın Yol Haritası (Faz Faz Rehber)

Bu rehber **hiçbir kod, terminal, Java veya bilgisayar kurulumu gerektirmeden**, yalnızca telefon veya bilgisayar tarayıcısından tıklayarak ilerleyebilmeniz için **4 faz** halinde hazırlanmıştır.

---

## FAZ 1: Son Cihaz Testi ve GitHub Klonlama Koruması (Depoyu Gizli / Private Yapma)

### Adım 1.1 — Güncel APK'yı Telefona Kurup Kontrol Edin
1. Telefonunuzdan şu bağlantıya dokunun ve yeni paketi indirin:
   - https://github.com/YAZILIMCEOSU/ezanapp/releases/download/dene-apk/ezanai-kurulum.apk
2. Kontrol noktaları:
   - **Daha Fazla → Ezan ve Bildirim Sesi:** **Türkiye Makamı (3 dk 08 sn)**, **Mekke-i Mükerreme (3 dk 22 sn)**, **Abdülbâsıt (3 dk 21 sn)** ve **Muhammed Rıfat (3 dk 24 sn)** ezanlarını dinleyin; 30–40 saniye sonra kesilmeden sonuna (*"Lâ ilâhe illallâh"*) kadar okunduğunu doğrulayın.
   - **Kur'an → Herhangi bir Sure (ör. Yâsîn veya Fâtiha):** Ekranın en altında **yatay Kur'an MediaPlayer çubuğunun** çıktığını, **➤ Ok Takibi Açık** ve **Yaşlı Modu (A+)** düğmeleriyle okunan ayetin ve kelimenin **`⬅` ok işaretiyle** adım adım takip edildiğini doğrulayın.

### Adım 1.2 — GitHub Deposunu Klonlanmaya Karşı "Private" (Gizli) Yapın
Kodlarınızın başkaları tarafından görülmesini, kopyalanmasını (fork/clone) tamamen kapatmak için:
1. Tarayıcınızdan **https://github.com/YAZILIMCEOSU/ezanapp/settings** sayfasını açın.
2. Sayfanın en altına, kırmızı çerçeveli **"Danger Zone" (Tehlikeli Bölge)** bölümüne inin.
3. **"Change repository visibility"** satırındaki **"Change visibility"** düğmesine dokunun ve **"Make private"** seçeneğini seçin.
4. Onay kutusuna **`YAZILIMCEOSU/ezanapp`** yazıp onaylayın.
> **Not:** Depo *Private* olduğunda dışarıdan hiç kimse kaynak kodunuza veya dosyalarınıza erişemez; yalnızca sizin GitHub hesabınız erişebilir.

---

## FAZ 2: Resmi Üretim İmza Anahtarı (Keystore) ve Play Store Paketi (.aab)

Uygulama içinde halihazırda şu güvenlik kalkanları aktiftir:
- **Dart + R8 Kod Karartma (Obfuscation):** APK/AAB tersine mühendislikle açılsa bile sınıf ve fonksiyon isimleri şifrelenmiştir.
- **Paket ve İmza Doğrulaması (`MainActivity.kt` + `BillingService`):** Uygulama kendi paket adını (`com.yazilimceosu.ezanai`) ve SHA-256 sertifika imzasını kontrol eder; sahte/klonlanmış paketlerde ve yama (Lucky Patcher vb.) denemelerinde sahte premium makbuzlarını reddeder.

Play Store'a yüklenecek resmi `.aab` paketini tek tıkla üretmek için:
1. GitHub deponuzun üst menüsünden **Actions** sekmesine dokunun.
2. Sol listeden **"1 — İmza anahtarı üret (bir kez)"** (`signing.yml`) iş akışını seçip **"Run workflow"** düğmesine basın.
3. İşlem bittiğinde oluşan 4 gizli anahtar değerini (`KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`) **Settings → Secrets and variables → Actions** altına ekleyin.
4. Ardından **"2 — İmzalı yayın paketi üret (AAB + APK)"** (`release-signed.yml`) iş akışını çalıştırarak Google Play'e hazır **`app-release.aab`** dosyanızı indirin.

---

## FAZ 3: Google Play Console'da "Ezan" Uygulamasını Oluşturma

1. **https://play.google.com/console** adresine girin ve **"Uygulama oluştur"** düğmesine dokunun:
   - **Uygulama adı:** `Ezan`
   - **Varsayılan dil:** `Türkçe (tr-TR)`
   - **Uygulama veya oyun:** `Uygulama`
   - **Ücretsiz veya ücretli:** `Ücretsiz`
2. **Mağaza Görselleri ve Metinleri:**
   - Deponuzdaki `store/play_icon_512.png` (512×512 ikon) ve `store/play_feature_graphic_1024x500.png` (1024×500 özellik grafiği) dosyalarını doğrudan yükleyin.
   - Kısa ve uzun açıklamaları `docs/KOPYALA-YAPISTIR.md` dosyasından kopyalayıp yapıştırın.

---

## FAZ 4: Uygulama İçeriği Beyanları ve Yayınlama

1. **Gizlilik Politikası:** `docs/privacy.html` sayfasının adresini Play Console → *Gizlilik politikası* alanına yapıştırın.
2. **Veri Güvenliği ve İzin Açıklamaları:**
   - **Konum (`ACCESS_FINE_LOCATION`):** Bulunulan şehre göre Diyanet namaz vakitlerini, kıble açısını ve yakındaki camileri hesaplamak için kullanılır; üçüncü taraflarla paylaşılmaz.
   - **Tam Alarm (`USE_EXACT_ALARM`):** Namaz vakti girdiğinde ezan bildirimini saniyesi saniyesine çalmak için kullanılır.
   - **Medya Oynatma (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`):** Ezan, Kur'an tilaveti ve ilahilerin ekran kapalıyken kesilmeden çalması için kullanılır.
3. **Üretim (Production) → Yeni sürüm oluştur:** İndirdiğiniz **`app-release.aab`** dosyasını yükleyip incelemeye gönderin.
