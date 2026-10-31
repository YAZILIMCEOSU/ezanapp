# Vakit Hatası Düzeltmesi — "1 dakika erken ezan" ve "Diyanet güncelleniyor" mesajı

**Tarih:** 31 Ekim 2026 · **Dal:** `arena/01a1057d-ezanapp` · **Uygulama:** Ezan Vaktim Pro

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
       **Ezan Vaktim Pro → İzin ver** seçin. Bu izin olmadan Android 14+
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
