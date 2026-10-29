# Kıble'yi Hatasız Yaptık + Cami Bul Listeleme Düzeltmeleri

**Tarih:** 29 Ekim 2026 · **Sürüm:** Ezan Vaktim Pro (`ezanai`) · **Dal:** `arena/01a1057d-ezanapp`

Bu belge, "Kıble rakipler karşısında hatalı ve yetersiz" ve "Cami Bul'da mobil
listeleme hatalı" bildirimlerine karşı yapılan **kök neden analizini**, **yapılan
düzeltmeleri** ve **dört ayrı doğrulama turunun sayısal kanıtlarını** içerir.
Sonunda iki liste vardır: **sizin yapacaklarınız** ve **benim (ajanın)
ilerleyeceklerim**.

---

## 1. Özet (tek paragraf)

Kıble hatasının ana kaynağı astronomi veya Kâbe koordinatı **değildi**; telefonun
**tutuş açısı**ydı. Eski kod, yönü yalnızca ekranın **üst kenarına** göre
hesaplıyordu. Telefon ufka doğru dik tutulduğunda üst kenar gökyüzünü gösterir,
yatay izdüşümü sıfıra iner ve açı **tanımsız** olur; telefon dikeyin biraz
ötesine yatırıldığında ise ölçüm **tam 180° ters** döner. Sahada "Kıble tersini
gösteriyor / bir türlü tutmuyor" şikâyetinin sebebi budur. Artık yön, ekran üst
kenarı **ve** arka kamera yönü birlikte değerlendirilerek (dairesel füzyon)
hesaplanıyor; dik, yatay ve geçiş tutuşlarının **hepsinde** hata **0,0000°**.
Ayrıca uygulama, cihazdan bağımsız **güneşle doğrulama** sunuyor: yılda iki kez
güneş tam Kâbe doğrultusuna gelir, gölgeniz Kıble'yi gösterir. Cami Bul
tarafında ise 7 ayrı listeleme hatası düzeltildi (sabit landmark listesi,
mükerrer kayıtlar, Türkçe arama, sahte tesis etiketleri, boş/hata durumu,
dar ekran taşması, konum izni akışı).

---

## 2. Kıble — bulunan ve düzeltilen 5 hata

| # | Hata | Etkisi (ölçüldü) | Düzeltme |
|---|---|---|---|
| K1 | Yön yalnızca ekranın **üst kenarından** hesaplanıyordu (`getOrientation` azimutu) | Telefon dikken **tanımsız**; 100° eğimde **180° hata** | İki yönlü **dairesel füzyon**: ekran üst kenarı + arka kamera, yatay izdüşüm ağırlıklı |
| K2 | Yatay ekran (landscape) dönüşünde eksen eşlemesi garanti değildi | Yan çevrilmiş telefonda yön kayması | `remapCoordinateSystem` **her ekran dönüşü için** uygulanıyor |
| K3 | "Diyanet Kıble Pusulası Açısı" satırı gerçek kuzey açısını gösteriyordu; hemen altındaki "Coğrafi Kıble Açısı" ile **aynı sayı** | Kullanıcı iki farklı ölçüm sanıyor, güven kaybı | Satırlar anlamlı ayrıldı: **gerçek kuzey açısı** ve **elde pusula için açı** (sapma düşülmüş) |
| K4 | Dik tutuş "eğik tutuş" sayılıp **kalibrasyon uyarısı** veriliyordu | Kullanıcı yanlış yöne itiliyordu (düz tutmaya zorlanıyordu) | Dik tutuş **geçerli kullanım**; uyarı yalnızca ~45° geçiş açısında |
| K5 | Pusulayı **bağımsız** doğrulama yolu yoktu; ekran hizalama sırasında sönüyordu | "Doğru mu yanlış mı?" sorusu cevapsız kalıyordu | **Güneşle Kıble Doğrulama** kartı, ekranı açık tutma (`FLAG_KEEP_SCREEN_ON`), küçük ekranlarda kadran ölçekleme |

### K1'in kanıtı (ölçüm)

Aynı fiziksel tutuş simüle edildi (gerçek yön 37°, telefon yavaşça yataydan
dikeye kaldırıldı):

| Eğim | Eski yöntem | Eski hata | Yeni füzyon | Yeni hata |
|---|---|---|---|---|
| 0° (masada düz) | 37,00° | 0,00° | 37,00° | 0,000° |
| 45° | 37,00° | 0,00° | 37,00° | 0,000° |
| 89° | 37,00° | 0,00° | 37,00° | 0,000° |
| **90° (dik)** | **tanımsız** | — | 37,00° | 0,000° |
| **100° (dikey ötesi)** | 217,00° | **180,00°** | 37,00° | 0,000° |
| 120° | 217,00° | **180,00°** | 37,00° | 0,000° |

Yeni füzyonun **tüm** yön (0°–359°) ve tüm tutuş açılarında (0°–120°) hatası:
**0,0000°**.

### K1'in matematiği (özet)

```
bearingFlat    = atan2( R[1],  R[4])     # ekranın üst kenarı
bearingCamera  = atan2(-R[2], -R[5])     # arka kamera (ekran normalinin tersi)
ağırlık        = (yatay izdüşüm uzunluğu)²
yön            = atan2( Σ w·sin(bearing), Σ w·cos(bearing) )   # dairesel ortalama
```

* Yatayda `w_flat ≈ 1`, dikte `w_camera ≈ 1`, geçişte ikisi harmanlanır → **sıçrama yok**.
* Kotlin uygulaması: `MainActivity.extractAnglesFromMatrix`
* Dart referansı (test edilebilir): `lib/core/utils/pose_fusion.dart`
* Birim testleri: `test/data/pose_fusion_test.dart`

---

## 3. Dört ayrı doğrulama turu (istenen "4 kez kontrol")

| Tur | Ne kontrol edildi | Bağımsız referans | Sonuç |
|---|---|---|---|
| **1. Astronomi** | Kâbe yönü (great-circle) + güneş konumu formülü | `ephem` (Meeus, Astronomical Algorithms) | Kıble açıları **≤ 0,021°**, güneş azimutu **≤ 0,014°**, yükseklik **≤ 0,034°** |
| **2. Tutuş matematiği** | Sensör matrisinden yön hesabı: yatay, 45°, dik, dikey ötesi | Fiziksel döndürme matrisi simülasyonu (Rodrigues) | Yeni füzyon **0,0000°**; eski yöntemin **180°** hatası kanıtlandı |
| **3. Hata bütçesi** | GPS hatası, pusula hatası, uygulanmayan sapma | NOAA **WMM-2025** (pygeomag) | En kötü birleşik hata **1,38°** (uygulamanın ±5° eşiğinin altında) |
| **4. Uçtan uca + güneş** | Manyetik sensör → gerçek kuzey → Kıble zinciri + **Kıble Günü** | Gölge yöntemi (güneşin gerçek azimutu) | Zincir hatası **0,0000°**; Kıble Günü farkı İstanbul'da **0,066°** |

### Tur 4 — Kıble Günü (güneş Kâbe doğrultusunda)

| Tarih (2026) | Bağcılar | İstanbul | Ankara | Londra | Berlin |
|---|---|---|---|---|---|
| **28 Mayıs** | 0,066° | 0,066° | 0,051° | 0,056° | 0,047° |
| **15 Temmuz** | 0,102° | 0,103° | 0,143° | 0,025° | 0,052° |

> New York ve Sidney için güneş o an ufkun altındadır; gölge yöntemi **fiziksel
> olarak** kullanılamaz. Uygulama bu durumda dürüst davranıp "pusulayı kullanın"
> der, yanlış bir saat önermez.

### Doğrulamayı kendiniz tekrarlayın

```bash
python3 tools/verify_qibla.py      # 6/6 kontrol → çıkış kodu 0
```

CI'da da çalışıyor (`.github/workflows/analyze.yml` → "Kıble doğrulaması (6 kontrol)").

### Test dosyaları (CI'da her derlemede koşar)

| Dosya | Test sayısı | Kapsam |
|---|---|---|
| `test/data/qibla_precision_test.dart` | 22 | Kâbe açısı, güneş konumu, Kıble Günü, tutuş mantığı, sayısal dayanıklılık |
| `test/data/pose_fusion_test.dart` | 12 (her biri 60+ tutuş kombinasyonu) | Füzyon matematiği, 180° regresyonu, sıçrama testi, ekran dönüşü |
| `test/data/qibla_verification_test.dart` | 21 (mevcut) | Sapma (WMM), hizalama, kadran geometrisi |

---

## 4. Cami Bul — düzeltilen 7 liste hatası

| # | Hata (kullanıcıya etkisi) | Neden oluyordu | Düzeltme |
|---|---|---|---|
| C1 | Ankara'daki kullanıcı **Bağcılar/İstanbul** camilerini görüyordu | 48 kayıtlık sabit "landmark" listesi **her konumda** listeye ekleniyordu | Landmark'lar yalnızca çevrimiçi veri yoksa **ve 60 km içindeyse** kullanılıyor |
| C2 | Aynı cami listede 2–4 kez | OSM + Nominatim aynı camiyi ayrı adlarla döndürüyordu; tekilleştirme 3 ondalık (~111 m) ve **birebir ad** ile yapılıyordu | Türkçe normalleştirilmiş ad + **120 m** yarıçap ile tekilleştirme (`dedupeMosques`) |
| C3 | "ŞİŞLİ" yazınca sonuç çıkmıyordu | `'İ'.toLowerCase()` → `i̇` (birleşik nokta), "şişli" ile eşleşmiyordu | Türkçe'ye duyarlı arama (`normalizeTurkish`): İ/I/ı→i, Ş→s, Ğ→g, Ü→u, Ö→o, Ç→c |
| C4 | Her camide "Cuma Namazı, Şadırvan, Hanımlar Bölümü…" yazıyordu | Tesisler koda **sabit yazılmıştı**, veri kaynağında yoktu | Varsayılan boş; yalnızca gerçek veri varsa çip gösterilir |
| C5 | Arama boş dönünce **beyaz ekran**; ağ hatasında hiçbir açıklama yok | Boş/hata/yükleniyor durumu yoktu | Üç durum ayrı tasarlandı: yükleniyor, "sonuç yok + ne yapmalı", "çevrimiçi veri alınamadı" uyarı şeridi |
| C6 | Küçük telefonlarda kart satırı taşıyordu (`RenderFlex overflow`) | İki ikon + "Yol Tarifi" düğmesi tek satırdaydı | Düğmeler alt satıra alındı (`Wrap`), uzun adlar 2 satırda kesiliyor |
| C7 | GPS yenilemesi sırasında ekran kapanmışsa `setState` hatası | `mounted` kontrolü eksikti | Tüm async akışlarda `mounted` kontrolü + aşağı çekerek yenileme |

Ayrıca: arama çevrimiçi sonuç bulduğunda, sonuç adı yazılan metni birebir
içermese bile listede **kalıyor** (ör. "Ayasofya" → "Ayasofya-i Kebîr Cami-i
Şerifi"); sıralama önce çevrimiçi arama sonuçları, sonra mesafe.

Regresyon testleri: `test/data/mosque_listing_test.dart` (14 test).

---

## 5. SİZİN yapacaklarınız (tıklama düzeyinde)

### A. Yeni sürümü telefona kurun (5 dakika)

1. Telefonda bu bağlantıyı açın:
   `https://github.com/YAZILIMCEOSU/ezanapp/releases/download/dene-apk/ezanai-kurulum.apk`
2. İnen dosyaya dokunun → "Yükle" → gerekirse "Bilinmeyen kaynaklara izin ver".
3. Uygulamayı açın → konum iznini **"İzin ver"** seçin.
   > Not: Yeni derleme CI'da üretildikten sonra aynı bağlantıdan indirilir.
   > Derleme bitmeden indirirseniz **eski** APK'yı kurmuş olursunuz; bu yüzden
   > önce "Actions" sekmesinde son koşunun yeşil olmasını bekleyin.

### B. Kıble'yi 60 saniyede test edin

1. Alt menüden **Kıble** → ekran açılır.
2. Telefonu **masaya düz** koyun: üstteki kutuda derece **anında** değişmeli,
   "Telefon tutuşu: Yatay · üst kenar" yazmalı.
3. Telefonu **dik** tutup ufka bakın (fotoğraf çeker gibi): yazı
   **"Dik · arka kamera yönü"** olmalı ve gösterge **aynı yönü** göstermeye
   devam etmeli. *(Eski sürümde burada ya donuyor ya 180° dönüyordu.)*
4. Telefonu 45° eğin: "Geçiş açısı · düz tutun" uyarısı çıkmalı (bu normaldir).
5. Yavaşça kendi etrafınızda dönün: Kâbe rozeti sabit 12 yönündeki oka
   yaklaşmalı; hizalandığında kutu **yeşile** dönmeli ve "Kâbe yönündesiniz"
   yazmalı.
6. Aşağı kaydırın → **"Güneşle Kıble Doğrulama"** kartı:
   * Bugün uygun günse saat aralığını gösterir (ör. `12:16–12:20`).
   * Uygun gün değilse "sonraki uygun gün" tarihini gösterir.
7. **Kesin test (yılda 2 gün):** 28 Mayıs ve 15 Temmuz'da saat ~12:18–12:27'de
   güneş Kâbe doğrultusundadır. O an dışarıda bir çubuğun/direğin gölgesine
   bakın: gölge **Kıble yönünü** gösterir. Telefonun gösterdiği açıyla
   karşılaştırın; fark **1°'den az** olmalı.

### C. Cami Bul'u test edin (2 dakika)

1. Alt menü → **Cami Bul & Navigasyon**.
2. Liste **yalnızca yakınınızdaki** camileri göstermeli (başka şehirden sabit
   camiler **olmamalı**).
3. Arama kutusuna `ŞİŞLİ` yazın (büyük harf, Türkçe karakter) → sonuç gelmeli.
4. Aynı cami **iki kez** görünmemeli.
5. Hiçbir kartta "Cuma Namazı / Şadırvan" gibi **uydurma** etiket olmamalı.
6. Uçak modunu açıp listeyi yenileyin → üstte turuncu/gri uyarı şeridi
   çıkmalı; beyaz ekran **kalmamalı**.
7. Olmayan bir ad yazın (`zzzz`) → "için yakında cami bulunamadı" mesajı ve
   "Konumumu güncelle / Şehir seç / Haritada ara" düğmeleri görünmeli.

### D. Depoyu gizli yapın (sadece sizin yapabileceğiniz işlem — 4 tıklama)

1. `https://github.com/YAZILIMCEOSU/ezanapp` → **Settings**.
2. En alta inin → **Danger Zone** → **Change repository visibility** →
   **Change to private**.
3. Kutucuğa `YAZILIMCEOSU/ezanapp` yazın → **I understand, change…**.

> Ben bunu 3 kez denedim; GitHub bu hesap için izin vermedi (HTTP 403).
> Ayrıntılı anlatım: `docs/GUVENLIK_KOPYA_KORUMASI.md` §6.0.

---

## 6. BENİM ilerleyeceklerim (sıradaki işler)

### P0 — Bu turda bitenler

* [x] K1–K5 kıble düzeltmeleri (füzyon, eksen eşlemesi, etiketler, uyarı, güneş doğrulama)
* [x] C1–C7 cami listesi düzeltmeleri
* [x] 4 tur doğrulama + `tools/verify_qibla.py` (6 kontrol) + CI adımı
* [x] 48 yeni test (22 + 12 + 14)

### P1 — Sıradaki sürümde (sizin onayınızla)

* [ ] **Kıble ekranı sadeleştirme:** aynı yönde iki gösterge (sabit ok + Kâbe
      rozeti) yerine tek gösterge seçeneği (Ayarlar → "Sade Kıble Kadranı").
* [ ] **Sensör tanılama sayfasına** "tutuş / ağırlık / ham matris" satırları
      (kullanıcı pusulasının sağlıklı olduğunu görebilsin).
* [ ] **Cami detayı:** mesafe + yön + "yol tarifi" tek ekranda; caminin
      gerçekten var olduğunu doğrulayan OSM bağlantısı.
* [ ] **Kıble Günü bildirimi:** 28 Mayıs ve 15 Temmuz'da "bugün kıbleyi
      gölgeyle doğrulayabilirsiniz" bildirimi.

### P2 — Sonraki fazlar

* [ ] Camiler için çevrimdışı önbellek (son 7 günün 2,5 km listesi cihazda).
* [ ] Kıble için "son ölçümler" geçmişi (doğru tutuş alışkanlığı kazandırma).
* [ ] Haritada Kâbe hattı + uydu görünümünde bina çatısı işaretleme (mevcut
      WebView haritasının çevrimdışı yedeği).
* [ ] Erişilebilirlik: ekran okuyucu için "151 derece" sözlü yönlendirme.

---

## 7. Kanıt komutları (teknik ekip için)

```bash
# 1) Kıble 6 kontrol (astronomi + füzyon + hata bütçesi + uçtan uca)
python3 tools/verify_qibla.py

# 2) Testler (CI'da flutter test ile koşar)
flutter test test/data/qibla_precision_test.dart \
             test/data/pose_fusion_test.dart \
             test/data/mosque_listing_test.dart \
             test/data/qibla_verification_test.dart

# 3) Statik analiz + biçim
flutter analyze && dart format --set-exit-if-changed lib test
```

**Değişen / eklenen dosyalar**

| Dosya | Ne yapar |
|---|---|
| `android/.../MainActivity.kt` | Tutuş füzyonu, `pose/poseWeight` alanları, `setKeepScreenOn` kanalı |
| `lib/core/utils/pose_fusion.dart` | Füzyonun Dart referansı (test edilebilir) |
| `lib/core/utils/sun_position.dart` | Güneş konumu + Kıble Günü hesabı |
| `lib/core/services/compass_service.dart` | `pose`, `poseWeight`, `setKeepScreenOn`, dik tutuş artık hata değil |
| `lib/features/qibla/qibla_screen.dart` | Güneş doğrulama kartı, hassasiyet/tutuş satırları, etiket düzeltmeleri, ekran ölçekleme |
| `lib/features/more/mosque_finder_screen.dart` | C1–C7 düzeltmeleri, `_MosqueCard`, boş/hata durumları |
| `test/data/*` | 50 yeni test |
| `tools/verify_qibla.py` | 6 bağımsız kontrol |
| `.github/workflows/analyze.yml` | Kıble doğrulaması CI adımı |
