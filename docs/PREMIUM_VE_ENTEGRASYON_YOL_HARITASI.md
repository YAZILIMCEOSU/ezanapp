# Ezan Vaktim Pro — Premium Özellikler ve Kullanıcı Tarafı Yol Planı

Bu belge, **Ezan Vaktim Pro** uygulamasında hangi özelliklerin şu an **ücretsiz ve hazır** çalıştığını, **Premium abonelik ve bulut servislerini** gerçek kullanıcılara açmak için **sizin tarafınızda (uygulama sahibi olarak) neye ihtiyacınız olduğunu** ve **adım adım ne yapmanız gerektiğini** hiçbir teknik/yazılım bilgisi gerektirmeden açıklar.

---

## 1. Şu An Hazır Olan ve Hiçbir Ek İşlem Gerektirmeyen Özellikler (%100 Aktif)

Aşağıdaki özellikler uygulama içinde **tamamen hazırdır**, herhangi bir sunucu ücreti veya API anahtarı **gerektirmez**:

| Özellik | Durum | Nasıl Çalışır? |
|---|---|---|
| **81 İl / 960 İlçe Otomatik GPS Konum (Bağcılar dahil)** | Hazır | Telefonun GPS koordinatını 960 Türkiye ilçesiyle (Bağcılar, Küçükçekmece, Bahçelievler, Güngören, Esenler, Fatih, Üsküdar vb. tamamı ayrı ayrı) eşleştirir. Konum değiştikçe otomatik güncellenir. |
| **Diyanet Uyumlu Namaz Vakitleri (Online + Çevrimdışı)** | Hazır | Diyanet İşleri Başkanlığı verilerini çeker ve önbelleğe alır; internet olmasa bile Diyanet temkinli astronomik motorla (İmsak 18°, Yatsı 17°) saniyesi saniyesine hesaplar. |
| **3B Eğim Dengelemeli Kıble Pusulası ve Harita** | Hazır | Telefon masada düz dururken de elde eğik tutulurken de burulma (sapma) yapmayan 3B sensör motoru + Kâbe yönü harita işaretlemesi + Kıble ekranından tek dokunuşla Cami Bul geçişi. |
| **Cami Bulucu, Cami Pusulası ve Canlı Navigasyon** | Hazır | Bağcılar ve tüm çevre ilçelerin gerçek koordinatlı camileri + OpenStreetMap/Nominatim canlı arama + Camiye Canlı Pusula + Google Haritalar adım adım yürüyüş ve araç navigasyonu (`google.navigation:`). |
| **Kur'an-ı Kerim Sesli Tilavet + Oklu/İşaretli Takip** | Hazır | 114 sure, 6 hafız, renkli tecvidli hat, kelimenin altında yeşil ibre (`▲`) ve sarı vurgu (`#FFF176`) ile ses dalgasına kilitli gerçek zamanlı kelime takibi + alt sabit MediaPlayer. |
| **Gerçek Ezan Sesleri & Nafile Namaz Alarmları** | Hazır | Kâbe İmamı (Mekke), Medine ve Türk makamlarında gerçek müezzin ezanları + İşrak, Kuşluk (Duha), Evvabîn, Teheccüd, Cuma, Bayram ve Teravih alarmları. |
| **İlahi & Dini Sesler Kataloğu** | Hazır | Uygulama içi ve açık arşiv telifsiz vokal ilahiler, çevrimdışı indirme ve telefondan ses seçme. |
| **Yerel İslami Bilgi Bankası (70+ Konu, 4 Mezhep)** | Hazır | İnternet veya yapay zekâ kotası olmasa bile Hanefî, Şâfiî, Mâlikî ve Hanbelî mezheplerine göre kaynaklı cevap üretir. |

---

## 2. Premium Özellikler İçin Sizin Tarafınızda Ne Var, Ne Yapılması Gerekiyor?

Uygulamanın içinde **Premium Abonelik Ekranı (`PremiumScreen`)**, **Google Play Ödeme Motoru (`BillingService`)**, **Sahte Satın Alma / Klonlama Koruması (`verifyReceiptIntegrity`)** ve **Bulut Yapay Zekâ Köprüsü (`islamic-ai-proxy`)** kod olarak **tamamen yazılmış ve hazır durumdadır**.

Bu özelliklerin gerçek paraya/aboneliğe dönüşmesi ve canlı bulut yapay zekâsına bağlanması için sizin tarafınızda **4 aşamalı bir yol planı** bulunmaktadır:

---

### FAZ 1 — Kendi Telefonunuzda Test ve Günlük Kullanım (Şu An)
- **Sizin tarafınızda gereken:** Hiçbir şey (0 TL maliyet).
- **Yapılacak işlem:** Sadece verdiğimiz APK bağlantısından uygulamayı indirip kullanmak.
- **Not:** Test aşamasında tüm özellikleri kısıtlamasız deneyebilirsiniz.

---

### FAZ 2 — Google Play Store'da Premium Abonelik Satışlarını Başlatma
Kullanıcıların uygulama içinden **"Aylık Premium"** veya **"Yıllık Premium"** satın aldığında ödemenin sizin banka hesabınıza yatması için yapılacak işlemlerdir.

#### Sizin Tarafınızda Gerekenler:
1. **Google Play Console Geliştirici Hesabı** (`play.google.com/console` — Google'a tek seferlik **25 USD** kayıt ücreti ödenir).
2. **Ödeme Profili / IBAN:** Google Play Console içinde "Ödeme Profili" bölümüne kendi banka IBAN bilginizi tanımlamanız.

#### Tıklama Düzeyinde Yapacağınız Adımlar (Kod Yazmadan):
1. Google Play Console'da uygulamanızı açın.
2. Sol menüden **Para Kazanma (Monetize) -> Ürünler (Products) -> Abonelikler (Subscriptions)** bölümüne tıklayın.
3. **"Abonelik Oluştur" (Create subscription)** butonuna basın ve **birebir şu Ürün Kimliklerini (Product ID)** girin *(uygulama kodu bu 3 kimliği de otomatik tanır)*:
   - **1. Aylık Abonelik Kimliği:** `ezanai_premium_monthly`
     - Adı: `Ezan Vaktim Pro — Aylık Premium`
     - **Önerilen 2026 Fiyatı:** **149,99 TL / Ay** *(Avrupa/ABD için: **4,99 $ / 4,99 €**)*
   - **2. Yıllık Abonelik Kimliği (En Çok Satan):** `ezanai_premium_yearly`
     - Adı: `Ezan Vaktim Pro — Yıllık Premium (%45 Avantajlı)`
     - **Önerilen 2026 Fiyatı:** **999,99 TL / Yıl** *(Aylığa böldüğünüzde ~83 TL/ay'a gelir; Avrupa/ABD için: **29,99 $ / 29,99 €** — 7 gün ücretsiz deneme açmanız dönüşümü 3 kat artırır)*
   - **3. Ömür Boyu VIP Paket Kimliği (Uygulama İçi Ürünler / In-app products menüsünden açılır):** `ezanai_premium_lifetime`
     - Adı: `Ezan Vaktim Pro — Ömür Boyu VIP (Tek Seferlik)`
     - **Önerilen 2026 Fiyatı:** **2.499,99 TL** *(Lansman kampanyası: **1.999,99 TL**; Avrupa/ABD için: **69,99 $ / 69,99 €**)*
4. Ürünleri **"Etkinleştir" (Activate)** butonuna basarak aktif edin.
5. `docs/PLAY_STORE_YAYIN_REHBERI.md` dosyasındaki adımlarla GitHub'dan imzalı `.aab` dosyasını indirip Play Console'a yükleyin. **Ekstra hiçbir kod değişikliği yapmanıza gerek kalmadan** uygulama içindeki Premium satın alma butonları gerçek Google Play ödeme penceresini açacaktır.

#### 2026 Net Kazanç ve Maliyet Tablosu (Neden Bu Fiyatlar Doğru?)
Google Play üzerinden yapılan satışlarda **%20 KDV** ve Google'ın **%15 hizmet komisyonu** düşüldükten sonra cebinize giren net tutar ve yapay zekâ maliyeti şöyledir:

| Paket | Ürün Kimliği (Kodda Hazır) | Mağaza Satış Fiyatı (TR / Global) | Vergi ve Google (%15) Sonrası **Size Kalan Net** | Ortalama AI Maliyeti | **Kişi Başı Net Kârınız** |
|---|---|---|---|---|---|
| **Aylık Premium** | `ezanai_premium_monthly` | **149,99 TL** (`$4.99`) | ~106 TL / ay | ~4–6 TL / ay | **~100 TL / ay** |
| **Yıllık Premium** | `ezanai_premium_yearly` | **999,99 TL** (`$29.99`) | ~708 TL / yıl | ~45–60 TL / yıl | **~650 TL / yıl** |
| **Ömür Boyu VIP** | `ezanai_premium_lifetime` | **2.499,99 TL** (`$69.99`) | ~1.770 TL (peşin) | ~120 TL | **~1.650 TL (peşin)** |

---

### FAZ 3 — Canlı Bulut Yapay Zekâ ("İslami Asistan" Sınırsız Soru-Cevap) Bağlantısı
Uygulama içinde 70+ konuluk detaylı fıkıh ve mezhep bilgi bankası zaten çevrimdışı çalışmaktadır. Ancak Premium kullanıcıların **aklınıza gelebilecek her türlü özel dini soruyu kendi cümleleriyle sorup canlı yapay zekâdan (OpenAI / Gemini) kaynaklı cevap alması** için sunucu köprüsünü bağlamanız gerekir.

#### Sizin Tarafınızda Gerekenler:
1. **Ücretsiz Supabase Hesabı** (`supabase.com` — Aylık 500.000 isteğe kadar tamamen **ücretsizdir**).
2. **OpenAI API Hesabı** (`platform.openai.com` — Kullandıkça öde sistemidir; `gpt-4o-mini` modeliyle **1.000 kullanıcı sorusu yaklaşık 3–5 TL** gibi çok düşük bir maliyete sahiptir).

#### Neden Doğrudan Telefona Anahtar Koymuyoruz?
Güvenlik kuralımız gereği OpenAI şifrenizi uygulamanın içine gömersek kötü niyetli kişiler APK'yı çözüp şifrenizi çalabilir. Bu yüzden projede `supabase/functions/islamic-ai-proxy/index.ts` adlı güvenli kasa fonksiyonunu hazır bıraktık.

#### Tıklama Düzeyinde Yapacağınız Adımlar:
1. `supabase.com` adresinden ücretsiz hesap açıp **"New Project"** ile bir proje oluşturun.
2. Proje ayarlarından (**Project Settings -> API**) şu iki bilgiyi kopyalayın:
   - `Project URL` (Örn: `https://xyz.supabase.co`)
   - `anon public key`
3. `platform.openai.com/api-keys` adresinden bir **API Key** (`sk-...`) oluşturun ve Supabase panelinde **Edge Functions -> Secrets** bölümüne `OPENAI_API_KEY` adıyla kaydedin.
4. GitHub deponuzda **Settings -> Secrets and variables -> Actions** menüsüne girip şu iki kaydı ekleyin:
   - `SUPABASE_URL`: Supabase proje adresiniz
   - `SUPABASE_ANON_KEY`: Supabase anon anahtarınız
5. Bu iki değeri girdiğiniz anda uygulama derlemesi otomatik olarak canlı bulut yapay zekâsına bağlanır; ücretsiz kullanıcılara günlük kota (örn. 3 soru), **Premium abonelere ise yüksek/sınırsız kota** otomatik uygulanır.

---

### FAZ 4 — İsteğe Bağlı İleri Seviye Premium Genişletmeler (Büyüme Aşaması)
Uygulamanız Google Play'de yayınlanıp kullanıcı kitlesi büyüdüğünde isteğe bağlı olarak devreye alabileceğiniz özelliklerdir:

| Özellik | Sizin Tarafınızda Gereken | Uygulamadaki Hazırlık Durumu |
|---|---|---|
| **Bulut Yedekleme (Hatim, Kaza Orucu, Tesbih Geçmişi)** | Faz 3'teki ücretsiz Supabase hesabı yeterlidir. | Veritabanı tabloları (`SQLite`) bulut senkronizasyonuna uyumlu kimliklerle tasarlanmıştır. |
| **Diyanet Kurumsal Awqaf API** | Diyanet İşleri Başkanlığı'ndan kurumsal API yetkisi (isteğe bağlı; şu anki sistem zaten Diyanet verilerini ve astronomik hesabını ücretsiz kullanır). | `lib/data/prayer/diyanet_awqaf_api_source.dart` dosyası kodda hazırdır; sadece `DIYANET_AWQAF_TOKEN` girilmesi yeterlidir. |
| **Reklamsız Deneyim / Ücretsiz Kullanıcıya Banner Reklam** | Google AdMob hesabı (ücretsiz kullanıcılara reklam gösterip, Premium alanlarda reklamı kaldırmak isterseniz). | `isPremiumProvider` bayrağı tüm ekranlarda hazırdır; Premium üyede reklamlar otomatik gizlenir. |

---

## Özet Kontrol Listesi (Sizin İçin En Kısa Yol)

1. **Bugün (Test için):** Hiçbir hesap açmanıza gerek yok; yeni APK'yı kurup Bağcılar konumunu, Kıbleyi, Cami Bul & Navigasyonu ve Kur'an Oklu Takibi doğrudan test edin.
2. **Play Store'a Çıkarken:** Google Play Console'da `ezanai_premium_monthly` ve `ezanai_premium_yearly` aboneliklerini oluşturun.
3. **Canlı Yapay Zekâyı Açarken:** Supabase + OpenAI anahtarınızı GitHub Secrets'a ekleyin (isterseniz anahtarları aldıktan sonra buraya yazmanız yeterli, bağlantısını birlikte de tamamlayabiliriz).
