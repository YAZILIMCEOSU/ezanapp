# Sıfırdan Play Store'a — adım adım rehber

Bu rehber **hiç yazılım bilmeyen** biri için yazıldı. Hiçbir yere kod yazmayacaksın;
sadece **tıklayacak**, **indirecek** ve **kopyala-yapıştır** yapacaksın.
Her adımda şunu bulacaksın: **ne yapıyorsun → ekranda ne göreceksin → doğru yaptığını nasıl anlarsın.**

---

## Başlamadan: elinde olması gerekenler

| Gereken | Neden | Not |
|---|---|---|
| **Android telefon** | Uygulamayı denemek ve Play testleri için | iPhone olmaz (uygulama şimdilik Android için) |
| **Bilgisayar** (Windows/Mac) | Dosya indirmek ve form doldurmak için | Herhangi bir program kurman **gerekmiyor** |
| **Google hesabı** | Play Console için | Zaten kullandığın Gmail olabilir |
| **Kredi kartı** | Google'ın **tek seferlik 25 dolar** geliştirici ücreti | Abonelik değil, bir kez ödenir |
| **1–2 saat boş zaman** | İlk gün yapılacaklar için | Kapalı testin 14 günlük beklemesi sonra başlıyor |
| **Kendine e-posta atabilme** | Anahtarı ve parolayı yedeklemek için | Bunu ileride anlatacağım |

**Terimler (karmaşık görünen 5 kelime):**

- **Depo (repository):** Kodun ve dosyaların durduğu GitHub klasörü. Senin depon: `YAZILIMCEOSU/ezanapp`.
- **Derleme (build):** Kaynak koddan kurulabilir uygulama dosyası üretme işi. Bunu bizim robot yapıyor.
- **APK:** Telefona kurulabilen dosya (deneme için).
- **AAB:** Play Store'a **yüklenen** dosya (mağazaya yüklenir, telefona kurulmaz).
- **İmzalama anahtarı:** Play'in "bu dosya gerçekten bu geliştiriciden geldi" diye kontrol ettiği dijital kimlik. Bir kez üretilir, saklanır.

**Toplam süre:** Bugün 3–4 saatlik tıklama + Google'ın **zorunlu 14 günlük** test beklemesi (kişisel hesap için).

---

## BÖLÜM 1 — Uygulamayı telefonuna kur ve gez (bugün, ~15 dakika)

Bu adım Play ile ilgili değil; uygulamanı gerçekten görüp beğenip beğenmediğini anlamak için.

1. Bilgisayarda tarayıcıyı aç, şu adrese git:
   **https://github.com/YAZILIMCEOSU/ezanapp/actions**
2. En üstteki yeşil ✓ işaretli satırı aç (adı "analyze" ile başlar).
3. Sayfayı en alta kaydır. **"Artifacts"** (çıktılar) bölümünü göreceksin.
4. **`ezanai-derlemeleri`** yazan dosyaya tıkla → bilgisayarına **.zip dosyası** iner.
5. İnen .zip dosyasına çift tıkla, içinden **`app-debug.apk`** dosyasını çıkar.
6. Bu dosyayı telefona ulaştır. En kolay iki yol:
   - **Kablo ile:** Telefonu USB ile bağla, açılan klasörde "İndirilenler" içine sürükle-bırak.
   - **Google Drive ile:** drive.google.com'a yükle, sonra telefonda Drive uygulamasından indir.
7. Telefonda **Dosyalar** (veya İndirilenler) uygulamasını aç, `app-debug.apk` dosyasına dokun.
8. Telefon "Bilinmeyen kaynaklardan yüklemeye izin ver" derse → **İzin ver** → **Kur** → **Aç**.

**Doğru yaptığının kanıtı:** Telefonda "EzanAI" uygulaması açılır, vakitler ve geri sayım görünür.

> ⚠️ Bu dosya **deneme** sürümüdür; Play'e yüklenmez, sadece telefonda denenir. İnternet olmadan da vakitlerin görünmesi gerekiyor (uçak modunu açıp dene — çökmezse doğrudur).

---

## BÖLÜM 2 — Ekran görüntülerini al (~20 dakika)

Play, mağaza sayfası için **en az 2** ekran görüntüsü şart koşuyor. 6 tane çekmen yeterli.

1. Telefonda ilgili ekranı aç ve **güç düğmesi + ses kısma** tuşlarına aynı anda bas.
   (Bazı telefonlarda: güç düğmesine uzun bas → "Ekran görüntüsü".)
2. Şu 6 ekranın fotoğrafını çek:

   | # | Hangi ekran | Nasıl bulunur |
   |---|---|---|
   | 1 | Ana sayfa (geri sayım) | Uygulama açılışta gelir |
   | 2 | Vakitler tablosu | Alt menü **Vakitler** → sağ üstteki **Tablo** |
   | 3 | Bildirim ayarları | Alt menü **Daha Fazla** → **Bildirim Ayarları** |
   | 4 | Kıble | Alt menü **Daha Fazla** → **Kıble** |
   | 5 | Tesbih | Alt menü **Daha Fazla** → **Tesbih ve Zikir** |
   | 6 | Hicri takvim | Alt menü **Daha Fazla** → **Hicri Takvim ve Önemli Günler** |

3. Fotoğrafları bilgisayara aktar (USB kablo → telefonun `DCIM/Screenshots` klasörü).
   Bilgisayarda bir klasöre koy, ör. `Masaüstü/ezanai-gorseller`.

**Doğru yaptığının kanıtı:** Bilgisayarda 6 tane .png/.jpg dosyası var ve içlerinde uygulamanın ekranları görünüyor.

---

## BÖLÜM 3 — Gizlilik adresini yayına al (GitHub, ~15 dakika)

Play, mağaza kaydında **çalışan bir gizlilik politikası internet adresi** ister.
Bu adres bizim hazırladığımız sayfadan gelecek. Sırasıyla:

### 3.1 — Hazır değişiklikleri birleştir

1. Bilgisayarda **https://github.com/YAZILIMCEOSU/ezanapp/pulls** adresine git.
2. **"EzanAI: tam uygulama + yayın paketi"** başlıklı kaydı aç (numarası #1).
3. Yeşil **"Merge pull request"** düğmesine bas → çıkan ekranda yine yeşil
   **"Confirm merge"** düğmesine bas.

**Doğru yaptığının kanıtı:** Sayfada mor renkte **"Merged"** yazısı görünür.

### 3.2 — İnternet sayfasını aç (GitHub Pages)

1. Depo sayfasında üstteki **Settings** sekmesine tıkla.
2. Sol menüde aşağı kaydırıp **Pages** yazısına tıkla.
3. "Build and deployment" altındaki **Source** kutusunda **Deploy from a branch** seç.
4. Hemen altında **Branch** kutusu: **main** seç; yanındaki klasör kutusu: **/docs** seç → **Save**.
5. 1–2 dakika bekle, sayfayı yenile. Üstte şuna benzer bir adres görünecek:
   `https://KULLANICI.github.io/ezanapp/`
   (`KULLANICI` yerine GitHub kullanıcı adın yazılı olacak.)

### 3.3 — Adresi not al

Tarayıcıda şu adresi aç:

```
https://KULLANICI.github.io/ezanapp/privacy.html
```

**Doğru yaptığının kanıtı:** Sayfa açılır ve "EzanAI — Gizlilik Politikası" başlığını görürsün.
**Bu adresi bir yere kopyala** (Notlar uygulaması, e-posta taslağı) — §5'te Play'e yazacaksın.

> Not: Adres ilk 1–2 dakikada açılmazsa panik yapma; GitHub bazen gecikir. 5 dakika sonra tekrar dene.

---

## BÖLÜM 4 — Google Play geliştirici hesabı aç (~30 dakika + onay beklemesi)

1. Bilgisayarda **https://play.google.com/console** adresine git, Google hesabınla giriş yap.
2. **"Hesap oluştur"** / **"Create account"** düğmesine bas.
3. **Hesap türü** sorulur:
   - **Kişisel (Personal):** Bireysel geliştirici. **Bu seçilirse: Play, ürünü yayınlamadan önce
     12 kişiyle 14 günlük kapalı test şartı koyar.**
   - **Kurumsal (Organization):** Şirket/dernek adına. Bu şart **yoktur** ama şirket bilgisi ve
     doğrulama belgeleri ister.
   - **Öneri:** Tek kişiysen **Kişisel** seç ve 14 günlük testi bugün planla (Bölüm 9).
4. Kayıt ücreti **25 ABD doları** — kredi kartı bilgilerini gir.
5. Kimlik doğrulaması: adını, adresini gir; kimlik ve adres belgesi fotoğrafı isteyebilir.
   Google bu onayı genelde **1–2 gün** içinde tamamlar.

**Doğru yaptığının kanıtı:** Play Console ana ekranı açılır ve "Uygulama oluştur" düğmesini görürsün.

> ⚠️ **En önemli uyarı:** Kişisel hesapta Google, ürünü herkese açmadan önce
> **en az 12 kişinin 14 gün boyunca** test sürümünü kullanmasını şart koşuyor.
> Bu süre kısaltılamaz. Bu yüzden **12 kişiyi bugün ayarlamaya başla**:
> aile, arkadaş, komşu, cemaatten gönüllüler… Onlardan tek istenen: Gmail adresi vermek ve
> Bölüm 9'da göndereceğin bağlantıya tıklayıp uygulamayı **kurup açık tutmak**.

---

## BÖLÜM 5 — Play'de uygulamanı oluştur (~2–3 saat, parça parça yapılabilir)

### 5.1 — Uygulamayı oluştur

1. **"Uygulama oluştur"** düğmesine bas.
2. Uygulama adı: **EzanAI: Namaz Vakitleri**
3. Varsayılan dil: **Türkçe (tr-TR)**
4. Tür: **Uygulama** · Ücretsiz/Ücretli: **Ücretsiz**
5. Beyanları işaretle → **Oluştur**.

### 5.2 — Mağaza sayfasını doldur

Sol menüden **"Mağaza varlığı → Uygulama girişi"** (Store listing) bölümüne gir:

- **Kısa açıklama (80 karakter):**
  `Namaz vakitleri, ezan bildirimi, kıble ve tesbih: çevrimdışı da çalışır.`
- **Tam açıklama:** `docs/MAGAZA_GORSELLERI.md` dosyasının **§2** bölümündeki uzun metni
  kopyala, buraya yapıştır. (Kapalı modüllerden söz etmeyen, ilk sürüme uygun metin orada.)
- **Uygulama simgesi:** depodaki `store/play_icon_512.png` dosyasını indir → buraya yükle.
- **Öne çıkan görsel:** depodaki `store/play_feature_graphic_1024x500.png` → yükle.
- **Ekran görüntüleri:** Bölüm 2'de çektiğin 6 fotoğrafı yükle (en az 2 zorunlu).

### 5.3 — "Uygulama içeriği" formları

Sol menü → **"Politika → Uygulama içeriği"**. Sırayla açılan formları doldur.
**Yanıtların hazır** — `docs/MAGAZA_GORSELLERI.md` **§3** tablosuna bak ve aynısını işaretle.
En kritik üçü:

- **Gizlilik politikası:** Bölüm 3'te not aldığın adresi buraya yaz.
- **Veri güvenliği:** Tablodaki yanıtları işaretle (konum: cihazda işlenir, sunucuya gönderilmez).
- **Reklam:** İlk sürümde reklam ayarlanmadıysa **"Uygulama reklam içermiyor"** seç.

**Doğru yaptığının kanıtı:** Sol menüdeki uyarı işaretleri (kırmızı ünlem) kaybolur,
"Yayınlanmaya hazır" göstergesi yeşile yaklaşır.

---

## BÖLÜM 6 — İmzalama anahtarını üret (sadece tıklamalarla, ~20 dakika)

Burası normalde yazılımcıların komut satırında yaptığı bir iştir; biz senin için
GitHub'a **düğme** koyduk. Bilgisayarına hiçbir şey kurmayacaksın.

> ⚠️ **Neden önce depoyu geçici olarak gizli yapıyoruz?** Ürettiğimiz dosya senin
> dijital imzandır. Depo herkese açıkken o dosyayı başkaları indirebilir. Bu yüzden
> bu işi yaparken depoyu özel yapıp, indirdikten sonra tekrar açacağız.

### 6.1 — Depoyu geçici olarak gizli yap

1. Depo → **Settings** → sol menü en altta **General**.
2. Sayfayı en alta kaydır → **Danger Zone** → **Change repository visibility** →
   **Change to private** → ekrandaki onay metnini yaz → onayla.

(Endişelenme: Bölüm 6.5'te tekrar **public** yapacağız, yoksa gizlilik sayfası kapanır.)

### 6.2 — Parolanı belirle

1. Depo → **Settings** → sol menü **Secrets and variables** → **Actions**.
2. **New repository secret** düğmesine bas.
3. **Name** kutusuna: `KEYSTORE_PASSWORD`
4. **Secret** kutusuna: kendi belirlediğin **uzun bir parola** yaz (ör. 20+ karakter,
   büyük-küçük harf, rakam, işaret karışık). **Bu parolayı şimdi bir yere kaydet** —
   sonra bir daha gösterilmeyecek (kaybedersen Google'dan anahtar sıfırlatabilirsin).
5. **Add secret** düğmesine bas.

### 6.3 — Anahtarı üret

1. Depo → **Actions** sekmesi.
2. Sol listede **"1) İmzalama anahtarı oluştur (bir kez)"** yazısına tıkla.
3. Sağda **Run workflow** düğmesi → **Run workflow** (yeşil).
4. ~1 dakika bekle, sayfayı yenile. Yeşil ✓ çıkar.
5. Çalışmanın sayfasında en alta kaydır → **Artifacts** → **`imzalama-anahtari`** → indir (.zip).

### 6.4 — İndirdiğin dosyayı sakla (çok önemli)

ZIP'in içinde iki dosya var:

- **`upload.jks`** → Anahtarın kendisi. Kaybedersen Play Console'dan yeni anahtar isteyebilirsin ama iş uzar.
- **`keystore.base64.txt`** → Aynı anahtarın metin hâli; GitHub'a yüklemek için gerekli.

Yap:

1. ZIP'i bilgisayarında güvenli bir klasöre çıkar (ör. `Belgeler/ezanai-anahtar`).
2. **`upload.jks` ve parolanı kendine e-posta at** (ör. konu: "EzanAI imzalama anahtarı yedeği").
3. `keystore.base64.txt` dosyasını **Not Defteri** (Windows) veya **TextEdit** (Mac) ile aç,
   içindeki tüm metni **kopyala** (Ctrl+A, Ctrl+C).
4. Depo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:
   - **Name:** `KEYSTORE_BASE64`
   - **Secret:** az önce kopyaladığın uzun metni yapıştır
   - **Add secret**.

**Doğru yaptığının kanıtı:** Actions secret listesinde iki satır görünür:
`KEYSTORE_PASSWORD` ve `KEYSTORE_BASE64`.

### 6.5 — Depoyu tekrar herkese açık yap

1. **Settings** → **General** → **Danger Zone** → **Change visibility** → **Change to public**.
2. Bölüm 3'teki gizlilik adresini tekrar aç, çalıştığını doğrula.

---

## BÖLÜM 7 — Play'e yüklenecek dosyayı üret (~20 dakika)

Play her yüklemede bir öncekinden **büyük** bir sürüm numarası ister. İlk yüklemede
mevcut numara uygundur; sonraki yüklemelerde **§7.1**'i tekrarlaman gerekir.

### 7.1 — (Sadece 2. ve sonraki yüklemelerde) sürüm numarasını artır

1. Depo → **pubspec.yaml** dosyasına tıkla → sağ üstteki **kalem** (Edit) simgesine bas.
2. En üstlerde şu satırı bul: `version: 1.0.0+1`
3. Sonundaki **+1**'i **+2** yap (sonraki sefer +3, +4 …).
4. Sayfayı aşağı kaydır → **Commit changes** → tekrar **Commit changes**.

### 7.2 — Dosyayı üret

1. Depo → **Actions** → sol listede **"2) Play'e yüklenecek dosyayı üret (imzalı AAB)"**.
2. **Run workflow** → kapsam kutusunda **mvp** bırak (ilk sürüm için doğru olan bu)
   → **Run workflow**.
3. ~15 dakika bekle (sayfayı yenileyerek ilerlemeyi görebilirsin). Yeşil ✓ çıkmalı.
4. Çalışma sayfasının altındaki **Artifacts** → **`play-yukleme-dosyasi`** → indir.
5. ZIP'i çıkar: içinde **`app-release.aab`** var. Play'e yükleyeceğin dosya bu.

**Doğru yaptığının kanıtı:** `app-release.aab` dosyası bilgisayarında ve boyutu ~70–90 MB.

---

## BÖLÜM 8 — İlk test: kendi telefonunda (dahili test, ~30 dakika)

1. Play Console → sol menü **Test ve yayınlama → Test → Dahili test**.
2. **Yeni sürüm oluştur** → Play, "App signing" / uygulama imzalama için onay ister → kabul et
   (Google'ın kendi imzası önerilir; sen yine de kendi anahtarını sakla).
3. **Yükle** → `app-release.aab` dosyasını seç.
4. **Sürüm notları** alanına `docs/MAGAZA_GORSELLERI.md` **§4**'teki metni yapıştır.
5. Sağ üstteki **İncele** / **Kaydet** → **Sürümü başlat** (Release).
6. Sol menüde **Test kullanıcıları** (Testers) sekmesi → **E-posta listesi oluştur** →
   kendi Gmail adresini ekle → **Kaydet**.
7. Sayfada çıkan **"Katılma bağlantısı"**nı telefonunda aç → **Katıl** → **Uygulamayı indir** → kur.

**Doğru yaptığının kanıtı:** Uygulama Play üzerinden telefonuna kuruldu ve açılıyor.
Bu noktada ürün **Play'de yayında** demektir (yalnızca senin görebildiğin bir test kanalında).

---

## BÖLÜM 9 — Kapalı test: 12 kişi, 14 gün (kurulum ~1 gün + 14 gün bekleme)

**Bu, Google'ın kişisel hesaplar için zorunlu tuttuğu ve atlanamayan tek adımdır.**

1. Play Console → **Test ve yayınlama → Test → Kapalı test (Closed testing)** →
   **Yeni sürüm oluştur** → aynı `app-release.aab` dosyasını yükle → sürümü başlat.
2. **Test kullanıcıları** sekmesi → yeni liste oluştur → **en az 14 kişinin Gmail adresini** ekle.
   (12 şart; 2 kişilik yedek, erken ayrılan olursa sayacın sıfırlanmaması için.)
3. Listeye şu mesajı gönder (WhatsApp/e-posta; kopyala-yapıştır):

   > Merhaba! EzanAI adlı namaz vakti uygulamasını test ediyorum. Google, yayına almadan önce
   > 14 gün boyunca en az 12 kişinin denemesini şart koşuyor. İster misin?
   > Yapman gereken tek şey: aşağıdaki bağlantıya tıklayıp "Katıl" ve uygulamayı kurmak,
   > sonraki 14 gün boyunca **silmemek** (arada açıp kullanman da yeterli).
   > Bağlantı: [Play Console'daki katılma bağlantısını buraya yapıştır]

4. Kişiler "Katıl"a tıklayıp uygulamayı kurunca Play Console'daki sayaç işlemeye başlar.
   - **14 gün kesintisiz** olmalı: biri çıkıp tekrar katılırsa o kişinin süresi baştan başlar.
   - Kimse para ödemez; test sürümü ücretsizdir ve herkese açık değildir.

**Doğru yaptığının kanıtı:** Play Console → **Dashboard** sayfasında
"Kapalı test sürüyor — 12+ test kullanıcısı" benzeri bir bilgi ve gün sayacı görünür.

---

## BÖLÜM 10 — Üretim erişimi ve yayın (Google'ın kararı)

1. 14 gün tamamlanınca Play Console ana sayfasında **"Üretim erişimi için başvur"**
   (Apply for production) düğmesi görünür.
2. Başvuruda sorulur: test sürecinde ne geri bildirim aldın, neyi düzelttin, ürüne neden güveniyorsun.
   Dürüst ve kısa cevaplar yeterli (ör. "12 kullanıcı 14 gün kullandı; bildirim zamanlaması
   ve vakit doğruluğu geri bildirimlerine göre düzeltmeler yapıldı").
3. Google incelemesi genelde **7 gün** içinde sonuçlanır.
4. Onaydan sonra **Üretim → Yeni sürüm oluştur** → aynı AAB'yi yükle → **Üretime gönder**.
5. Son inceleme (yine ~7 güne kadar) sonrası uygulama **herkesin** indirebileceği hâle gelir.

---

## BÖLÜM 11 — Takılırsan (sık sorunlar ve çözümleri)

| Sorun | Sebep | Çözüm |
|---|---|---|
| `app-debug.apk` telefon kurmuyor | "Bilinmeyen kaynak" kapalı | Telefon → Ayarlar → Uygulamalar → Dosyalar/Chrome → "Bilinmeyen uygulamaları yükle" iznini aç |
| Pages adresi 404 veriyor | Yayın gecikmesi veya yanlış klasör | 5 dk bekle; Settings → Pages'te Branch = `main`, Folder = `/docs` olduğunu kontrol et |
| "Run workflow" düğmesi görünmüyor | Workflow henüz `main`'de değil | Bölüm 3.1'deki birleştirmeyi yaptığından emin ol, sayfayı yenile |
| "2) …" işi kırmızı bitiyor, "gizli değişken eksik" yazıyor | Secret adı yanlış | İsimlerin birebir `KEYSTORE_BASE64` ve `KEYSTORE_PASSWORD` olduğunu kontrol et |
| Play "Sürüm kodu artırılmalı" diyor | Aynı numarayla ikinci yükleme | §7.1: `pubspec.yaml` → `version: 1.0.0+2` yap, §7.2'yi tekrar çalıştır |
| Play "gizlilik politikası geçersiz" diyor | Adres açılmıyor | Adresi tarayıcıda aç; açılmıyorsa Bölüm 3'ü tamamla |
| Anahtarı kaybettim | — | Play Console → Sorun giderme → "Yükleme anahtarı sıfırlama" isteği gönder (uzun ama çözülebilir) |
| Test kullanıcım uygulamayı bulamıyor | Bağlantı yerine Play'de aramış | Bağlantıyı ona özel gönder; uygulama kapalı testteyken aramada çıkmaz |
| 14 gün sayacı sıfırlandı | Bir kullanıcı testten çıktı | Yedek kişileri listeye ekle; 12'nin altına düşmemeye çalış |

---

## Bugün yapılacaklar kontrol listesi

- [ ] **1.** APK'yı telefona kur, uygulamayı gez (~15 dk)
- [ ] **2.** 6 ekran görüntüsü çek (~20 dk)
- [ ] **3.** PR'ı birleştir + Pages'i aç + gizlilik adresini not al (~15 dk)
- [ ] **4.** Play Console hesabı aç, 25 $ öde (~30 dk, onay 1–2 gün)
- [ ] **5.** 12–14 test kullanıcısının Gmail adreslerini topla (bugün başla!)
- [ ] **6.** İmzalama anahtarını üret ve yedekle (~20 dk)
- [ ] **7.** İmzalı AAB'yi üret (~20 dk)
- [ ] **8.** Mağaza metinlerini yükle (~2 saat, parça parça)
- [ ] **9.** Dahili test → kendi telefonunda kur (~30 dk) ← **ürün Play'de**
- [ ] **10.** Kapalı testi başlat → 14 gün say (~1 gün kurulum)
- [ ] **11.** Üretim başvurusu → herkese açık yayın (Google kararı)

---

## İlerlemeni takip etmek istersen

Her adımdan sonra bana **"3. adımı yaptım"** gibi yazabilirsin; ben:
- takıldığın yerde ekran ekran yardım ederim,
- hata mesajlarını yorumlarım,
- "Play'in istediği düzeltmeyi koda işle" gibi teknik işleri ben yaparım,
- yeni sürüm çıkarman gerektiğinde (§7.1) sürüm numarasını ve notları hazırlarım.
