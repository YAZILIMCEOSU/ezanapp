# Vakit Hatası Düzeltmesi — "1 dakika erken ezan" ve "Diyanet güncelleniyor" mesajı

**Tarih:** 31 Ekim 2026 · **Dal:** `arena/01a1057d-ezanapp` · **Uygulama:** Ezan Asistanı Pro

Bu belge, kullanıcı bildirimi olan iki sorunun kök nedenini, yapılan düzeltmeleri,
bunların nasıl kanıtlandığını ve telefonunuzda 5 dakikada nasıl doğrulayacağınızı
anlatır. Yazılım bilmeyen biri de son bölümü takip ederek kontrol edebilir.

---

## 1. Kısa özet

| Sorun | Gerçek sebep | Durum |
|---|---|---|
| Yatsı ve diğer vakitler **1 dakika erken** | Resmî Diyanet verisi bazı ayarlarda **hiç kullanılmıyordu**; uygulama sessizce uluslararası bir yedek servise düşüyordu. O servis Diyanet'in "temkin" (emniyet payı) düzeltmesini bilmediği için akşam 7, öğle 5, ikindi 4 dakika erken gösteriyordu. | Düzeltildi + test edildi |
| "**Diyanet veritabanı güncelleniyor**" mesajı | Ekranda `Diyanet verisi · güncelleme 14:32` yazıyordu. "Güncelleme" kelimesi "veritabanı güncelleniyor" gibi okunuyordu; saat de tarih içermiyordu. | Metin değişti + test edildi |

Ek olarak genel hata taramasında **15 ayrı sorun** bulundu ve düzeltildi (bkz. §3).

---

## 2. "1 dakika erken" hatası — kök neden

Uygulama vakitleri şu sırayla alır:

```
önbellek (taze ise) → Diyanet resmî servisi → uluslararası yedek servis → cihazda hesap
```

### 2.1 Asıl hata: resmî veri atlanıyordu

Eski kodda Diyanet kaynağı yalnızca şu koşulda deneniyordu:

```dart
final bool useDiyanetOfficial =
    (method.id == 'diyanet' || method.id == 'diyanet_high_lat') &&
    method.asrFactor == CalculationMethod.diyanet.asrFactor;
```

Yani kullanıcı **Hanefî ikindi** seçtiğinde veya **elle dakika düzeltmesi**
yaptığında `useDiyanetOfficial` `false` oluyor, zincir Diyanet'i **tamamen
atlayıp** yedek servise düşüyordu. O servis Diyanet'in temkin düzeltmesini
bilmediği için vakitler erken görünüyordu.

Ölçüm (Diyanet resmî = 0 kabul edilerek, 55 resmî kayıt):

| Vakit | Yedek servis sapması | En kötü |
|---|---|---|
| Akşam | **−7,1 dk** | 9,4 dk erken |
| Öğle | −5,1 dk | 6,8 dk |
| İkindi | −4,1 dk | 5,8 dk |
| Yatsı | −1,0 dk | 2,4 dk |
| Güneş | +6,9 dk | 8,0 dk |

"Yatsı ve diğer vakitlerde 1 dakika erken" şikâyeti bu tabloyla birebir uyuşuyor.

**Düzeltme:** zincir artık **her koşulda** `Diyanet → yedek → cihazda hesap`
sırasını izler. Hanefî farkı ve elle düzeltmeler resmî vakitlerin **üzerine**
eklenir (`_refineRemote`).

### 2.2 İkinci hata: yedek servis temkin uygulamıyordu

AlAdhan (yedek servis) Diyanet yöntemini bilse de **temkin** payını eklemez.
Artık yanıt çözümlendikten sonra yöntemin temkin dakikaları ekleniyor —
hem günlük hem haftalık/aylık istekte.

### 2.3 Üçüncü hata: önbellek kaynağı yanlış işaretleniyordu

SQLite'tan okunan her kayıt `source: 'cache'` olarak işaretleniyordu. Bu yüzden
"resmî veri mi?" kontrolü başarısız oluyor ve **önbellekten okunan resmî veriye
Hanefî ikindi kaydırması uygulanmıyordu**. Ekranda 15:46, bildirimde 16:26 gibi
tutarsızlık üretebiliyordu. Artık kaynağın aslı (Diyanet/AlAdhan) korunuyor;
"Kayıtlı veri" etiketi sadece gösterimde ekleniyor.

### 2.4 Dördüncü hata: bayat aralık önbelleği

Haftalık/aylık tablo ve **bildirim zamanlaması** aynı aralık verisini kullanır.
Bu önbellek hiç tazelik denetiminden geçmiyordu: bir hafta önce çekilmiş (ya da
cihazda hesaplanmış) kayıtlar "taze" sayılıp bildirimler bu eski saatlere
kuruluyordu. Ekran güncel resmî veriyi, bildirim eski değeri kullanabildiği için
ezan 1–2 dakika erken çalabiliyordu.

Artık aralık önbelleği de `alınma zamanı + 6 saat` kuralına tabidir.

### 2.5 Beşinci hata: cihaz hesabındaki temkin yanlıydı

Yerel (çevrimdışı) hesap, Diyanet'e göre **sistematik olarak geç** gösteriyordu:
güneş +0,87, akşam +0,86, yatsı +0,96 dakika. Temkin tablosu **işaretli hata**
üzerinden yeniden kalibre edildi:

| Vakit | Eski temkin | Yeni temkin | Ortalama sapma (yeni) | En kötü |
|---|---|---|---|---|
| İmsak | 0 | 0 | −0,05 dk | 2,0 dk |
| Güneş | −6 | **−7** | −0,13 dk | 2,0 dk |
| Öğle | +5 | +5 | −0,18 dk | 2,0 dk |
| İkindi | +4 | +4 | −0,15 dk | 2,0 dk |
| Akşam | +8 | **+7** | −0,18 dk | 2,0 dk |
| Yatsı | +1 | **0** | −0,00 dk | 2,0 dk |

330 ölçümün 326'sı ±2 dakika içinde. **Yuvarlama** incelendi: `round` en iyi
(ortalama −0,05…−0,18), `ceil` +0,4, `floor` −0,6 dakika sapma veriyor —
mevcut yuvarlama doğru, "1 dakika erken" için bahane değil.

> Not: "erken" olduğu düşünülen yerel hesap aslında hafif **geç**ti; temkini elle
> "erken" diye kaydırmak yanlış yol olurdu. Doğrusu resmî veriyi korumak ve
> ortalamayı sıfıra çekmekti.

---

## 3. Genel hata taramasında bulunan ve düzeltilen diğer sorunlar

| # | Bulgu | Etkisi | Düzeltme |
|---|---|---|---|
| H1 | Yedek servis temkin uygulamıyor (günlük) | 1–9 dk erken | Temkin eklendi |
| H2 | Yedek servis temkin uygulamıyor (aralık) | Tablo/bildirim erken | Temkin eklendi |
| H3 | Hanefî/manuel düzeltme seçilince Diyanet atlanıyor | 1–9 dk erken | Zincir koşulsuz |
| H4 | Önbellek kaynağı `cache` olarak eziliyor | Hanefî kaydırma kayboluyor | Kaynak korunuyor |
| H5 | Elle düzeltme önbelleğe yazılıyor | Aynı dakika iki kez ekleniyor | Ham veri saklanıyor |
| H6 | Aralık önbelleği tazelik denetimsiz | Bildirim eski saate | 6 saat kuralı |
| H7 | Aralık `off-by-one` (`+1` yok) | Son gün (yarın) eksik → sabah bildirimi kurulmuyor | `+1` eklendi |
| H8 | Bellek aralık önbelleği süresiz | Uygulama açıkken eski saat | Tazelik denetimi |
| H9 | Yerel hesap temkini yanlı | +1 dk geç (yatsı) | Yeniden kalibre |
| H10 | Yurt dışı şehirde saat dilimi +3 varsayımı | Kâbil'de 1,5 saat kayma | Boylamdan çözümleme |
| H11 | "güncelleme 14:32" metni | "Veritabanı güncelleniyor" gibi okunuyor | "3 saat önce alındı" |
| H12 | Yedek servise düşünce sessiz | Kullanıcı kaynağı bilmiyor | Açık uyarı bandı |
| H13 | Diyanet'te tek seferlik hata | Gereksiz yedek servise düşme | 1 kez tekrar + 6 saat bellek önbelleği |
| H14 | Bildirim ufku 7–8 gün | Tatilde bildirimler duruyor | 14 gün |
| H15 | Bugünün uyarısı yarının verisi çekilirken siliniyor | Uyarı hiç görünmüyor | Uyarı saklanıyor |
| H16 | Android 14+ kesin alarm izni görünmüyor | Ezan birkaç dk kayabilir | Ayar satırı + izin ekranı |
| H17 | Hanefî kaydırmada saniye artığı | Ekranda 17:10, bildirim 17:10:34 | Tam dakika |

---

## 4. "Diyanet veritabanı güncelleniyor" mesajı

Uygulamada "veritabanı güncelleniyor" yazan bir metin **yoktu**. Ekranda şu satır
vardı:

```
Diyanet resmî verisi · güncelleme 14:32
```

Bu ifade iki şeyi yanlış anlatıyordu:

1. "güncelleme" kelimesi veritabanının güncellendiği izlenimi veriyordu,
2. saat, verinin ne zaman alındığını değil sadece bir saati söylüyordu.

Yeni metin:

```
Diyanet resmî verisi · 3 saat önce alındı
Kayıtlı veri · 2 gün önce alındı
Cihazda hesaplandı (Diyanet kalibrasyonlu) · az önce alındı
Yedek servis (Diyanet temkinine göre düzeltildi) · 5 dk önce alındı
```

Ayarlar ekranındaki kaynak bilgisi de `Diyanet resmî verisi • ilçe: Bağcılar ·
son kontrol 3 saat önce` biçiminde ayrıştırıldı.

---

## 5. Kanıt: yeni testler

`test/data/prayer_time_fidelity_test.dart` — her hata için ayrı test:

| Test | Neyi kanıtlar |
|---|---|
| `yerel hesap Diyanet ile yansız eşleşir` | 330 ölçümde ortalama sapma < 0,5 dk, en kötü < 3 dk, 2 dk'dan fazla erken örnek yok |
| `AlAdhan yanıtına temkin uygulanır` | Akşam 19:34 → 19:41, öğle 13:00 → 13:05, ikindi 16:24 → 16:28 |
| `Hanefî ikindi seçilse de resmî veri kullanılır` | Yedek servis hiç çağrılmıyor; diğer 5 vakit birebir aynı; ikindi +40…90 dk |
| `önbellekten okunan resmî veriye de Hanefî kaydırma` | Kaynak korunuyor, kaydırma uygulanıyor |
| `manuel düzeltme iki kez uygulanmaz` | +3 dk bir kez; önbellekten okurken +6 olmuyor |
| `gün ve aralık aynı vakitleri döndürür` | Ana ekran = haftalık tablo = bildirim |
| `bayat aralık önbelleği yeniden çekilir` | 7 saatlik kayıt kullanılmıyor |
| `Kâbil +4,5 saat dilimini kullanır` | Yurt dışı çevrimdışı hesap doğru |
| `kaynak ve tazelik ayrı okunur` | Metinde "güncelleme" geçmiyor |

Ek olarak `test/data/prayer_chain_test.dart` ve `test/prayer_calculation_test.dart`
güncel davranışa göre güncellendi.

---

## 5.1. Doğrulama kaydı (CI)

| Kontrol | Sonuç |
|---|---|
| `flutter analyze` | **No issues found** (21,1 sn) |
| `flutter test` | **312 test geçti**, 6 atlandı (platform gerektirenler) |
| Kıble doğrulaması | **6/6 kontrol** |
| Release APK derlemesi | Başarılı — 91,9 MB |
| İmza doğrulaması | Başarılı (CI deneme anahtarı) |
| Çalışma | GitHub Actions **41222902245**, tüm adımlar `success` |

APK indirme bağlantısı (telefonda denemek için):
`https://github.com/YAZILIMCEOSU/ezanapp/releases/download/dene-apk/ezanai-kurulum.apk`

---

## 6. Yazılım bilmeyenler için: 5 dakikada doğrulama

Bilgisayar, terminal, SDK gerekmez. Yalnızca telefon.

1. **Uygulamayı güncelle**
   - Tarayıcıda şu adresi açın: `https://github.com/YAZILIMCEOSU/ezanapp/releases/tag/dene-apk`
   - `ezanai-kurulum.apk` dosyasına dokunup indirin.
   - İndirilen dosyayı açın → "Bilinmeyen kaynaklara izin ver" derse onaylayın →
     **Kur**'a dokunun. (Eski sürümün üzerine kurulur; ayarlarınız silinmez.)
2. **Ana ekranı açın.**
   - Vakitlerin altında artık `Diyanet resmî verisi · … önce alındı` yazmalı.
   - `güncelleme 14:32` yazısı **görünmemeli**.
3. **Bir vakit saatini karşılaştırın.**
   - Uygulamada yazan akşam saatini, cami takvimi veya
     `https://vakit.vercel.app` gibi bir Diyanet kaynağıyla karşılaştırın.
   - Aradaki fark **0 veya 1 dakika** olmalı (Diyanet bazı illerde yuvarlama
     yapar; 2 dakikadan fazla fark normal değildir).
4. **Hanefî ayarını deneyin** (şikâyetin en sık sebebi):
   - Alt menüden **Ayarlar → Vakit ayarları → Mezhep → Hanefî** seçin.
   - Ana ekrana dönün: akşam, yatsı, imsak **değişmemeli**; yalnızca **ikindi**
     40–90 dakika ileri gitmeli. Eğer akşam/yatsı da değiştiyse hata devam
     ediyor demektir.
5. **Bildirimi test edin:**
   - **Ayarlar → Bildirimler → Test bildirimi gönder**. Bildirim gelmeli.
   - Aynı ekranda **"Kesin alarm izni (ezan tam vaktinde)"** satırına bakın:
     - `Açık` yazıyorsa hiçbir şey yapmayın.
     - `Kapalı` yazıyorsa satıra dokunun, açılan Android ekranında
       **Ezan Asistanı Pro → İzin ver** seçin. Bu izin olmadan Android 14+
       telefonlarda ezan birkaç dakika kayabilir.
6. **Pil ayarını kontrol edin:**
   - **Ayarlar → Bildirimler → Pil Optimizasyonu İstisnası** → izin verin.
   - Bu, uygulama kapalıyken ezanın tam vaktinde çalması için gereklidir.

Bir sorun görürseniz ekran görüntüsünü ve **hangi vakit / hangi şehir / saat
kaçta çaldı** bilgisini not edin; bu üç bilgi sorunun kaynağını tek adımda
gösterir.

---

## 7. Geliştirici notu

Değişen dosyalar:

```
lib/data/prayer/prayer_calculator.dart        temkin kalibrasyonu + asrShiftMinutes
lib/data/prayer/prayer_times_repository.dart  zincir, _refineRemote, tazelik, off-by-one
lib/data/prayer/aladhan_api_source.dart       temkin (gün + aralık)
lib/data/prayer/diyanet_api_source.dart       6 saat bellek önbelleği + 1 kez tekrar
lib/data/prayer/prayer_times_cache.dart       kaynak bilgisi korunuyor
lib/data/prayer/local_calculation_source.dart TimeZoneResolver kullanımı
lib/data/prayer/time_zone_resolver.dart       (yeni) saat dilimi çözümleyici
lib/data/models/prayer_times_day.dart         sourceLabel / freshnessLabel / displaySource
lib/data/models/city.dart                     hasTimeZone alanı
lib/core/utils/geo.dart                       approximateUtcOffsetHours
lib/core/services/notification_service.dart   kesin alarm durumu + uyarı
lib/features/settings/notification_settings_screen.dart  izin satırı
lib/features/widgets/prayer_widgets.dart      "güncelleme" metni kaldırıldı
lib/state/providers.dart                      bildirim ufku 15 gün + uyarı saklama
lib/data/models/app_settings.dart             daysToSchedule = 14
```

Doğrulama: GitHub Actions `analyze` iş akışı (analyze + test + kıble 6/6 + APK).
Sonuç raporu depodaki `.ci/report.md` dosyasında ve Actions sekmesinde görünür.

---

## 8. 1 Kasım 2026 — "ikindi 1 dk geç" + "konum geç geliyor"

Kullanıcı bildirimi iki başlıktı: **ikindi hâlâ 1 dakika geç** ve **konum
bilgisi geç alınıyor**. Yapılan incelemede üç ayrı kök neden bulundu.

### 8.1 Konum neden geç geliyordu?

| # | Neden | Düzeltme |
|---|---|---|
| K1 | Uygulama açılışında GPS isteği **bildirim izni penceresinin arkasında** bekliyordu: kullanıcı izin penceresini kapatana kadar konum hiç başlamıyordu. | Konum isteği artık izin penceresiyle **paralel** başlıyor (`lib/app/app.dart`). |
| K2 | Her açılışta GPS kilidi bekleniyordu (açık havada 5–30 sn). | Sıra: **son bilinen konum (10 dk'dan yeni, ≈10 ms)** → düşük doğruluk (Wi-Fi) → orta → yüksek; toplam **9 sn** bütçe (`LocationService.defaultBudget`). |
| K3 | İzin durumu her konum isteğinde platformdan yeniden okunuyordu. | 20 saniyelik izin önbelleği (`_statusTtl`). |
| K4 | Kaba (Wi-Fi) konum yanlış ilçeye eşleşip vakitleri 1–2 dk kaydırabiliyordu. | Kaba konumla vakit hemen gösterilir, **arka planda** hassas konum alınıp ilçe düzeltilir (`_refineDistrict`); ilçe değişirse vakitler kendiliğinden yenilenir. |

### 8.2 İkindi neden 1 dakika oynayabiliyordu?

1. **Asıl kaynak karışıklığı (düzeltildi):** Ana ekran Diyanet resmî verisini
   gösterirken, haftalık tablo ve **bildirim zamanlaması** aralık isteğinden
   besleniyordu. Aralık isteği başarısız olunca yedek servise (AlAdhan)
   düşüyor, aynı gün için ekranda 16:26, bildirimde 16:27 olabiliyordu.
   Artık **tek zincir** var: Diyanet → eksik günler tek tek Diyanet'ten
   tamamlanır → ancak o da olmazsa yedek/hesap. `getRange` her zaman istenen
   **her günü** döndürür (`_fillMissingDays`).
2. **Aralık önbelleği tazelik denetimi yapmıyordu:** günlerce eski saatler
   "taze" sayılıp bildirim o saatlere kuruluyordu. Artık `_isRangeFresh`.
3. **Ay sınırı boşluğu:** Diyanet'in `monthly` uç noktası yalnızca içinde
   bulunulan ayı döndürüyordu; 28 Ekim → 11 Kasım gibi aralıklarda Kasım
   günleri hiç gelmiyor, o günler için **bildirim kurulmuyordu**. Eksik
   kaldıysa `yearly` uç noktasından tamamlanır.
4. **Yedek servis bütün ayı döndürüyordu:** haftalık tablo 31 güne çıkıyor,
   bildirim ufku kayıyordu. Artık istenen pencere dışındaki günler atılır.

### 8.3 Kalan ±1 dakika hakkında dürüst açıklama

Diyanet resmî verisi kullanıldığında fark **0 dakikadır**. Fark yalnızca
**cihaz hesabına** düşüldüğünde (çevrimdışı ya da servis hatası) oluşur:
55 resmî kayıtla yapılan doğrulamada ikindi **41/55 birebir**, 4 kayıtta +1 dk,
10 kayıtta −1…−2 dk. Bu, iki ayrı yuvarlamanın (Diyanet ve cihaz) kaçınılmaz
sonucudur; ±1 dakika fark **hiçbir hesap yöntemiyle sıfırlanamaz**.

Bu yüzden uygulama artık farkı saklamıyor, **söylüyor**:

* Vakit altındaki kaynak etiketi: `Cihazda hesaplandı (Diyanet kalibrasyonlu, ±1 dk)`.
* Ana ekranda **manuel düzeltme uyarısı**: "Manuel düzeltme açık: ikindi +1 dk… [Sıfırla]".
* Ayarlar → **Vakit doğrulama**: uygulamanın gösterdiği saat ile Diyanet'in
  resmî saati yan yana, fark dakika olarak; konum/koordinat/hassasiyet, saat
  dilimi, yöntem ve açık düzeltmeler tek ekranda.

Kanıt testleri: `test/data/prayer_time_fidelity_test.dart`
(V9 ay sınırı, V10 aralık dışı günler, V11 ikindi asla 1 dk'dan fazla geç
olmaz) ve `test/data/location_speed_test.dart` (tazelik, ilçe hassasiyeti,
bütçe sabitleri).

---

## 9. Kasım 2026 — "Resmî vakit servisine ulaşılamadı" uyarısı haksız yere çıkıyordu

Kullanıcı bildirimi: *"Resmî vakit servisine ulaşılamadı; vakitler cihazda
hesaplandı"* yazıyor. Oysa internet vardı ve Diyanet servisi ayaktaydı.
İncelemede **üç ayrı kök neden** bulundu.

### 9.1 Kök nedenler

| # | Neden | Düzeltme |
|---|---|---|
| V1 | Veri kümesindeki 96 yeni ilçe **üretilmiş kimlik** taşıyor (`9541_bagcilar`). Servis bu kimliği tanımıyor, `200 + data: []` dönüyor. Uygulama bunu "servis yok" sayıp cihaz hesabına düşüyordu. | `_apiDistrictId` üretilmiş kimliği **il kimliğine** indirger (`9541_bagcilar` → `9541`). API'de bu ilçeler zaten il merkezi verisine yönlenir; vakitler birebir resmîdir. |
| V2 | İlçe eşleşmediğinde (salt GPS) zincir `[cihaz hesabı]` oluyordu; **AlAdhan hiç denenmiyordu**. | Zincir artık `online ? [Diyanet (TR ise), AlAdhan, cihaz] : [cihaz]`. AlAdhan koordinatla çalışır; ilçe seçilmemiş olması servis hatası değildir. |
| V3 | Ana ekran yarının verisini de çekiyor; `lastWarning` tek alan olduğu için **yarının** uyarısı bugünün şeridinde görünebiliyordu. | Uyarı ve kaynak detayı `TodayTimes` içinde **bugüne sabitlenir** (`warning`, `sourceDetail`). |

Ek olarak: `monthly` uç noktası **istenen günü kapsamıyorsa** (ay sınırı) artık
`daily?startDate=` → `monthly` → `yearly` → **yedek resmî sunucu**
(`ezanvakti.emushaf.net`) sırası denenir. Tüm zincir 8 saniyelik toplam
bütçeyle sınırlıdır; açılış dakikalarca beklemez.

### 9.2 Uyarı metinleri artık üç durumu ayırıyor

| Durum | Metin |
|---|---|
| Çevrimdışı | "Çevrimdışısınız; vakitler cihazda hesaplandı. İnternet gelince otomatik yenilenir." |
| İlçe eşleşmedi | "Konumunuz bir ilçeyle eşleştirilemedi… Resmî Diyanet saati için şehir seçebilirsiniz." (düğme: **Şehir seç**) |
| Servis gerçekten yok | "Resmî vakit servisine ulaşılamadı; vakitler cihazda hesaplandı (±1 dk). 'Yenile' ile tekrar deneyin." |
| Diyanet yok, AlAdhan var | "Diyanet resmî verisine şu an ulaşılamadı; yedek servis kullanıldı (Diyanet temkinine göre düzeltildi)." |

### 9.3 Tanılama

Ayarlar → **Vakit doğrulama** ekranı artık hangi yoldan gelindiğini yazar:
"günlük / aylık / yıllık / aralık / yedek sunucu", "Yedek servis (AlAdhan)",
"Kayıtlı resmî veri", "Cihaz hesabı". "Karşılaştır" düğmesi 6 saatlik bellek
önbelleğini de atlar, yani **şu anda** servisin cevap verip vermediğini gösterir.

Kanıt testleri (`test/data/prayer_chain_test.dart` → "resmî servis
dayanıklılığı"): üretilmiş kimlik indirgeme, tek istekle günlük veri, aralık
uç noktası, yedek sunucuya düşüş, ilçe yokken AlAdhan'ın denenmesi,
yurt dışında Diyanet'in atlanması.

---

## 10. Kasım 2026 — "1 dakika gecikmeli ezan"

Kullanıcı bildirimi: **ezan, vakit girdikten yaklaşık 1 dakika sonra
duyuluyor.** İncelemede iki ayrı kök neden bulundu; ikisi de düzeltildi.

### 10.1 Android kesin alarm izni verilmemiş olabilir (asıl neden)

Android 14 (API 34) ile birlikte `SCHEDULE_EXACT_ALARM` izni **yeni
kurulumlarda varsayılan olarak kapalıdır**. İzin yoksa uygulama alarmı
`alarmClock` → `exactAllowWhileIdle` sırasıyla kurmayı dener; ikisi de
`exact_alarms_not_permitted` hatası verir ve kod sessizce
`inexactAllowWhileIdle` moduna düşer. Bu modda Android alarmı dakika sınırına
yuvarlar / erteler — tam olarak "1 dakika gecikmeli ezan" olarak görülür.

| # | Neden | Düzeltme |
|---|---|---|
| E1 | Manifest'te yalnızca `SCHEDULE_EXACT_ALARM` vardı; Android 14+ yeni kurulumlarda bu izin kapalı. | `USE_EXACT_ALARM` eklendi (Android 13+ çekirdek işlevi alarm olan uygulamalarda kurulumda otomatik verilir; Play "Alarmlar ve hatırlatıcılar" kapsamında beyan edilir). |
| E2 | İzin yalnızca **bildirim izni ilk kez istenirken** talep ediliyordu; bildirim izni zaten verilmiş kullanıcıda kesin alarm izni hiç istenmiyordu. | Açılışta durum okunuyor (`refreshExactAlarmStatus`), eksikse ana ekranda **"İzin ver"** düğmeli uyarı çıkıyor. |
| E3 | İzin sonradan verilse bile eski (inexact) alarmlar bir sonraki açılışa kadar kalıyordu. | İzin verildiğinde bildirimler **anında** yeniden zamanlanıyor; uygulamaya dönüşte durum tazeleniyor. |
| E4 | Hata yalnızca log'a yazılıyordu, kullanıcı göremiyordu. | Ana ekran uyarısı + Bildirim ayarlarındaki "Kesin alarm izni" satırı. |

### 10.2 Uygulama içi ezan uykudan sonra geç tetikleniyordu

Saniyelik saat (`clockProvider`) telefon uykuya geçince durur. Uygulamaya
dönüldüğünde ilk tik vaktin **40 saniye** sonrasına düşebiliyor ve
`_checkPrayerTimeEntered` 45 saniyelik geniş pencere nedeniyle ezanı gecikmeli
başlatıyordu.

* Pencere **5 saniyeye** indirildi (`NotificationService.isAdhanWindow`).
* Ek olarak uygulamanın gerçekten **ön planda** olması şartı eklendi
  (`_foreground`); arka plandan dönüşte ezan ikinci kez okunmaz, çünkü sistem
  bildirimi zaten çalmıştır.

### 10.3 Zamanlama matematiği kilitlendi

* `NotificationService.scheduledInstant` tek zamanlama noktası oldu; 15:33 için
  kurulan alarmın **15:33:00** olduğu testle kilitlendi (bir dakika eklenmesi
  artık testten geçemez).
* Gece yarısı / gün sınırı ve yaz saati kaydırması da test edilir.

Telefonda doğrulama: **Ayarlar → Bildirimler → "Kesin alarm izni"** satırı
"Açık: ezan tam vakitte çalar" demeli. Kapalıysa ana ekrandaki **İzin ver**
düğmesine dokunun; Android "Alarmlar ve hatırlatıcılar" ekranı açılır.

## 11. Kasım 2026 — "Bildirim çubuğunda hiç çıkmıyor"

Kullanıcı bildirimi: *"Bildirim çubuğunda telefonda da çıkmıyor."* Bu, tek bir
hatadan değil, birbirinden bağımsız **beş ayrı halkadan** kaynaklanabiliyordu.
Hepsi kapatıldı ve her halka artık ekranda görünür.

### 11.1 Simge hatası bütün bildirim sistemini durduruyordu

`initialize()` küçük simge olarak `@mipmap/ic_launcher` kullanıyordu. Android
küçük simgesinin **drawable** olması gerekir; bazı cihaz/derlemelerde bu isim
çözülemiyor ve `invalid_icon` hatası fırlıyor. Hata `_warmUp` içinde yutulduğu
için uygulama açılıyor ama **hiçbir bildirim** kurulamıyordu.

* `res/drawable/ic_stat_ezan.xml` (beyaz hilal) eklendi.
* `initialize()` önce bu simgeyi, başarısızsa `@mipmap/ic_launcher`'ı dener.
* İki deneme de başarısız olursa durum **gizlenmez**: ana ekranda
  "Bildirim sistemi başlatılamadı" uyarısı çıkar.
* `keep.xml` zaten `@drawable/*` koruyor; R8 release derlemesinde simge
  silinmiyor.

### 11.2 İzin bir kez reddedilince bir daha sorulmuyordu

Android 13+ `POST_NOTIFICATIONS` izni ikinci redden sonra **pencere
göstermez**. Uygulama yalnızca `requestNotificationsPermission()` çağırdığı
için kullanıcı "izin ver" dese bile hiçbir şey olmuyordu.

* Ana ekrana **"Bildirim iznini aç"** uyarısı eklendi.
* İzin penceresi açılmazsa doğrudan **uygulamanın bildirim ayarları** açılır
  (`ezanai/notifications` yerel köprüsü → `ACTION_APP_NOTIFICATION_SETTINGS`).
* Sistem ayarlarından dönüşte izin durumu yeniden okunur ve izin yeni
  verildiyse bildirimler anında yeniden zamanlanır.

### 11.3 Kanal sessizce kapatılabiliyordu

Uygulama düzeyinde izin açık olsa bile kullanıcı "Ezan ve vakit bildirimleri"
**kanalını** kapatabilir. Bu durumda `areNotificationsEnabled()` `true` kalır,
bildirim yine görünmez.

* Kanal önemi yerel köprüden okunur (`channelState`).
* Kanal kapalıysa ana ekran ve Bildirim ayarları uyarı gösterir; **"Kanalı aç"**
  doğrudan o kanalın sistem ayarını açar.

### 11.4 Tek bir bildirim hatası bütün planı düşürüyordu

`_schedule` hata fırlattığında `scheduleForDays` döngüsü tamamen duruyor,
kalan günler/vakitler hiç kurulmuyordu. Artık her bildirim ayrı denenir;
başarısız olan sayılır, tur devam eder ve sonuç raporlanır
(`NotificationScheduleReport`).

Ek olarak iptal ufku 14 → **20 gün** yapıldı; 15 günlük plan ile iptal aralığı
artık çakışmıyor.

### 11.5 Eşzamanlı yeniden zamanlama birbirini siliyordu

Açılış, ayar değişikliği ve konum yenilemesi aynı anda `reschedule()`
çağırabiliyor; biri `cancel`, diğeri `schedule` yaparken araya girerse
bildirimler silinebiliyordu. Tüm turlar artık tek bir kuyrukta sırayla çalışır.

### 11.6 Medya bildirimi hiç başlatılmıyordu (bildirim çubuğu boş kalıyordu)

`just_audio_background` paketi `pubspec.yaml`'da vardı ama
`JustAudioBackground.init()` **hiç çağrılmıyordu**. Bu yüzden ezan/Kur'an
çalarken kilit ekranı ve bildirim çubuğunda medya denetimi görünmüyor,
uygulama arka plana atıldığında ses kesilebiliyordu.

* `main()` içinde ilk `AudioPlayer`'dan önce `JustAudioBackground.init()`
  çağrılıyor; kanal adı, simgesi ve "çalarken bildirimi koru" ayarları verildi.
* Her ses kaynağına `MediaItem` etiketi eklendi (paketin zorunlu şartı):
  ezan, Kur'an kuyruğu, ilahi ve indirilen dosyalar.
* `MainActivity` artık `AudioServiceActivity`'den türüyor; bildirime
  dokunulduğunda uygulama ön plana gelir.

### 11.7 Telefonda 30 saniyelik doğrulama

1. **Ayarlar → Bildirimler → "Test bildirimi gönder"**.
2. Ekrana çıkan pencerede "Test bildirimi kuruldu" yazmalı ve yaklaşık
   **8 saniye sonra** bildirim çubuğunda görünmeli.
3. Görünmezse pencere size hangi ayarın kapalı olduğunu söyler ve
   **"Ayarları aç"** düğmesi doğrudan ilgili sistem ekranına götürür.
4. Aynı ekranda **"Zamanlanmış bildirim: N"** satırı görünmeli; `N = 0` ise
   hiçbir alarm kurulamamış demektir.

## 12. Kasım 2026 — genel hata taraması

Bildirim sorununun ardından bütün kod tabanı tarandı; kullanıcıya
dokunabilecek beş hata daha bulunup düzeltildi.

### 12.1 Yaz saati / yolculuk sonrası alarmlar bir saat kayıyordu

`tz.local` yalnızca uygulama açılırken **bir kez** çözülüyordu. Yaz saati
uygulamasına geçen bir ülkede veya uçakla başka saat dilimine gidildiğinde
eski kaydırma kullanılmaya devam ediyor, kurulan alarmlar **bir saat**
kayıyordu.

* `NotificationService.refreshTimeZone()` eklendi; kaydırma değiştiğinde
  bölge yeniden çözülür.
* Her zamanlama turundan (ve test bildiriminden) önce çağrılır.
* Haftalık/günlük tekrarlayan bildirimlerin "sonraki gün" hesabı
  `add(Duration(days: 1))` yerine tarih yeniden kurularak yapılır; 23/25
  saatlik günlerde saat kaymaz.

### 12.2 Ezan iki kez üst üste çalıyordu

Uygulama açıkken vakit girdiğinde hem sistem bildirimi (ezan sesiyle) hem de
uygulama içi ezan aynı saniyede başlıyordu. Artık uygulama içi ezan
tetiklendiğinde o vakit için kurulmuş sistem bildirimi iptal edilir
(`suppressSystemAdhan`); tek ezan duyulur.

### 12.3 Bozuk önbellek satırı bütün vakitleri kilitleyebiliyordu

`prayer_times_cache` okunurken `DateTime.parse` / `int.parse` doğrudan
kullanılıyordu. Eski şemadan kalan ya da yarım yazılmış tek bir satır
`FormatException` fırlatıyor ve vakit listesi hiç yüklenemiyordu.

* Satırlar artık doğrulanarak okunur; bozuk satır **atlanır**.
* Tarih/saat alanları `tryParse` + aralık kontrolünden geçer.
* Bozuk kayıt yüzünden uygulama çökmez; vakitler ağ/hesap yedeğinden gelir.

### 12.4 Geçersiz ayar yedeği bütün ayarları siliyordu

"Yedekten geri yükle" ekranına rastgele bir metin yapıştırıldığında
`importJson` hata yutup **varsayılan ayarları** döndürüyor, ekran da
"Ayarlar geri yüklendi" diyordu. Kullanıcının tema, konum, bildirim gibi tüm
tercihleri sessizce sıfırlanıyordu.

* `AppSettings.tryImportJson` eklendi: metin geçerli bir ayar yedeği değilse
  `null` döner ve **hiçbir şey değişmez**.
* Ekran "Yedek okunamadı; ayarlar değiştirilmedi." uyarısı gösterir.

### 12.5 Bozuk ayar verisi uygulamayı açılmaz hâle getirebiliyordu

`AppSettings.fromPrefs` ve `NotificationSettings.fromJson` alanları doğrudan
`as bool` / `as num` / `as String` ile okuyordu. Yanlış türde tek bir alan
(TypeError) uygulamanın **açılışta** çökmesine yol açabilirdi. Tüm alanlar
tür kontrolünden geçirilerek okunur; hatalı değer varsayılana düşer.

### 12.6 Küçük düzeltmeler

* Diyalogda oluşturulan iki `TextEditingController` artık `dispose` ediliyor.
* Ezan sesi başlatılamazsa kullanıcı sessiz kalmıyor: "Ezan sesi
  başlatılamadı" uyarısı gösteriliyor.
* Planlanan gün sayısı (14) ile bildirim ufku (15) hizalandı.

---

## 13. Kalıcı hata taraması (2026-11-10, 3. tur)

Kullanıcı isteği: "Hataları kontrol et, düzelt; her istekte kalıcı olarak bu
işlem yapılsın." İki parça uygulandı: (A) bu turda bulunan gerçek hata, (B)
kalıcı kalite kapısı.

### 13.1 Yaz saati/günlük hatırlatma kayması (saat dilimi çözümü)

Bildirimler `tz.local` bölgesine göre kurulur. Bölge adı yalnızca cihazın
**o anki UTC kaydırmasına** bakılarak tahmin ediliyordu. Sabit listelerde
aynı kaydırmayı paylaşan bölgeler karışabildiği için (ör. Berlin kışın +1 iken
liste önce Londra'yı seçebiliyordu) günlük/haftalık tekrarlayan hatırlatmalar
yaz saati geçişinden sonra **bir saat** kayabiliyordu.

* Android tarafına `timeZone` kanal metodu eklendi:
  `java.util.TimeZone.getDefault().id` → gerçek IANA adı (`Europe/Istanbul`).
* `refreshTimeZone` önce bu adı dener; ad geçerli ve kaydırmayla uyumluysa
  doğrudan kullanır.
* Yedek çözüm: yaygın bölge listesi → **tam kaydırma eşleşen herhangi bir
  bölge** → `Etc/GMT±N`.
* Yarım saatlik dilimlerde (±5:30, +3:30, −3:30) eski `~/ 60` kısaltması 30
  dakikalık kayma üretiyordu; tam eşleşme araması bunu kaldırdı.
* Test: `test/core/timezone_resolution_test.dart` (4 test).

### 13.2 Başlatma hatası oturumu kalıcı susturuyordu

Bildirim servisi bir kez başlatılamadığında `_initialized = true` kalıyor ve
uygulama kapanana kadar **bir daha hiç denenmiyordu**. Açılışta eklenti
motoru henüz hazır değilse (geçici hata) bütün bildirimler sessizce ölü
kalıyordu.

* `initialize()` artık başarısız durumda en fazla **3 kez** yeniden dener;
  "Test bildirimi" ve ekran açılışları da bu turları tetikler.
* Üst sınır aşıldığında gereksiz deneme yapılmaz, hata sağlık ekranında kalır.
* Test: `test/core/notification_init_retry_test.dart`.

### 13.3 Kalıcı kalite kapısı

* `AGENTS.md`: her istekte uygulanacak sıra (senkron → tarama → düzeltme →
  test → doküman → yeşil CI → Türkçe rapor) ve değişmez kurallar.
* `docs/KALITE_KAPISI.md`: kapının adımları, kanıt standardı, sık dönen hata
  sınıfları.
* `tools/quality_gate.sh`: Flutter varsa biçim/analiz/test/kıble; yoksa yeşil
  sonuç uydurmadan CI'ya yönlendirir.
* CI'ya **test sayısı kapısı** eklendi: 300'den az test keşfedilirse iş
  kırmızı olur (derleme hatası yüzünden testlerin sessizce atlanması önlenir).

Bundan sonraki her istekte bu üç adım zorunludur: **tara → düzelt → yeşil CI
ile kanıtla.**
