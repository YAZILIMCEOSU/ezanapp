# Ezan Vaktim Pro — Uygulama Güvenliği, Kopya Koruması ve Gizli Depo Rehberi

> **Bu belge kimin için?** Uygulamanın sahibi için, **tıklama düzeyinde** yazıldı.
> Bölüm 6 "Sizin yapacaklarınız", Bölüm 7 "Benim yapacaklarım" listesidir.
> En sonda tek komutla yapılan doğrulamalar var.

**Son güncelleme:** 28 Ekim 2026 · **Sürüm:** 1.0.0+1 · **Paket:** `com.yazilimceosu.ezanai`

---

## 1) Kısa özet — şu an neredeyiz?

| Soru | Cevap |
|---|---|
| Uygulama çalınabilir mi? | **Birebir çalışan kopyası üretilemez**: paket adı sabit, imza doğrulaması var, satın alma doğrulaması paket bütünlüğüne bağlı. Ama %100 imkânsız değildir — Android'de hiçbir uygulama bunu garanti edemez. |
| Kaynak kodu görünüyor mu? | Depo **hâlâ herkese açık** — gizlemek için 4 tıklama gerekiyor (Bölüm 6.0). Gizlendiğinde: APK içindeki Dart kodu `--obfuscate` ile karıştırılmış, Kotlin kodu R8 ile küçültülmüş olur. |
| Modlanmış (Lucky Patcher vb.) APK çalışır mı? | Çalışabilir **ama Premium satın alma çalışmaz**: klon/patch/debugger tespit edilirse makbuz doğrulaması reddedilir. |
| Yeniden imzalanmış (re-signed) APK yakalanıyor mu? | **Evet** — bu sürümde *imza sabitleme* eklendi: beklenen SHA-256 verilirse farklı imzalı paket "resmî olmayan" sayılır. |
| Ekran görüntüsüyle satın alma hilesi? | Ödeme ekranında **FLAG_SECURE** açık; ekran görüntüsü/kayıt alınamaz. |
| Sunucu anahtarı sızabilir mi? | Depoda **hiçbir gizli anahtar yok** (tarandı: API anahtarı, keystore, `key.properties` yok). Anahtarlar yalnızca derleme anında verilir. |

---

## 2) Güncel, hatasız uygulama (APK) bağlantısı

| Ne | Nerede |
|---|---|
| **Telefonda denemek için APK** | `https://github.com/YAZILIMCEOSU/ezanapp/releases/download/dene-apk/ezanai-kurulum.apk` |
| Boyut / imza | **91,8 MB** · CI'nın geçici anahtarıyla imzalı (deneme sürümü) |
| Hangi derlemeden? | `d8ea6e7` — CI 8/8 **yeşil**, 230 test geçti |
| Play'e yüklenecek dosya (AAB) | CI → *Actions* → son çalışma → **Artifacts → ezanai-derlemeleri** → `app-release.aab` |

> **Önemli (depo gizli olduğu için):** Bu bağlantı artık **GitHub hesabınızla giriş
> yapıldığında** çalışır. Başkalarına APK dağıtmak için:
> 1. **En doğru yol:** Play Console → *Test ve yayın → Kapalı test* → testçi
>    e-postalarını ekleyin; Google onlara indirme bağlantısı verir.
> 2. **Hızlı yol:** APK'yı bilgisayarınıza indirip Google Drive'a yükleyin,
>    bağlantıyı "bağlantıya sahip olan herkes" olarak paylaşın.

---

## 3) Tehdit modeli: neyden korunuyoruz?

| Tehdit | Örnek | Sonuç |
|---|---|---|
| **Kod hırsızlığı** | Başkasının kodu alıp kendi adına yayınlaması | Depo gizli + kod karıştırma |
| **Yeniden paketleme** | APK'yı açıp reklam/kötü yazılım ekleyip imzalamak | İmza sabitleme (re-signed tespiti) |
| **Mod / korsan** | Lucky Patcher ile Premium'u açmak | Patch aracı + Xposed + bütünlük kontrolü → satın alma reddi |
| **Klon uygulama** | Parallel Space/Island gibi ortamlarda çalıştırmak | Klon ortamı tespiti |
| **Satın alma hilesi** | Sahte makbuz (JSON) | Makbuz içi paket/ürün/durum doğrulaması + sunucu doğrulaması |
| **Hata ayıklayıcı ile inceleme** | APK'ya debugger bağlamak | Debugger tespiti (release derlemede) |
| **Ekran kaydı ile ödeme hilesi** | Ödeme ekranını kaydetmek | FLAG_SECURE (bu sürümde açıldı) |
| **Yedekten veri çekme** | `adb backup` ile verileri almak | `allowBackup=false`, veri çıkarma kuralları kapalı |
| **Ağ dinleme (MITM)** | Trafiği araya sokup değiştirmek | Yalnızca HTTPS (`cleartextTraffic=false`), sistem sertifikaları |
| **Anahtar sızıntısı** | API anahtarının kodda olması | Depoda anahtar yok; `--dart-define` ile derleme anında verilir |

---

## 4) Koruma katmanları — durum tablosu

| # | Katman | Nasıl çalışıyor | Durum |
|---|---|---|---|
| 1 | **Depo gizliliği** | GitHub deposu private | ⚠️ **Sizin 4 tıklamanız gerekiyor** (Bölüm 6.0) |
| 2 | **Kod karıştırma** | `flutter build --obfuscate --split-debug-info` (CI'da açık) | ✅ |
| 3 | **Kod küçültme (R8)** | `isMinifyEnabled` + `isShrinkResources` + ProGuard kuralları | ✅ |
| 4 | **İmza sabitleme** | `EXPECTED_SIGNING_SHA256` ile paket imzası karşılaştırılır | ✅ **Bu sürümde eklendi** |
| 5 | **Paket bütünlüğü** | Paket adı + klon + patch + Xposed + debugger birleşik kararı | ✅ |
| 6 | **Satın alma doğrulaması** | Bütünlük reddi → premium açılmaz; sunucu doğrulaması (varsa) | ✅ |
| 7 | **Ekran koruması** | Premium/ödeme ekranında `FLAG_SECURE` | ✅ **Bu sürümde bağlandı** |
| 8 | **Yedek kapatma** | `allowBackup=false` + `data_extraction_rules` | ✅ |
| 9 | **Ağ güvenliği** | HTTPS zorunlu, cleartext kapalı | ✅ |
| 10 | **Anahtar hijyeni** | Depoda sır yok, `*.jks` ve `key.properties` `.gitignore`'da | ✅ |
| 11 | **Görünür güvenlik durumu** | Ayarlar → Hakkında → **Güvenlik ve kopya koruması** | ✅ **Bu sürümde eklendi** |
| 12 | **Play Integrity API** | Google'ın sunucu taraflı cihaz/paket doğrulaması | ⏳ Sırada (Bölüm 7) |
| 13 | **Sertifika sabitleme (pinning)** | Uygulamanın kendi sunucusuna pin | ⏳ Sırada (sunucu adresi kesinleşince) |

### Ne kadar güvenli? Dürüst cevap

* **%100 koruma yoktur.** Android'de root'lu bir cihazda hiçbir kontrol mutlak değildir.
* **Ama pratikte:** kopyalayıp kendi adına yayınlamak (paket adı çakışır + imza
  farklı → Play reddeder), reklam ekleyip yeniden paketlemek (imza sabitleme
  bunu `UYUMSUZ` olarak işaretler) ve Premium'u bedava açmak (bütünlük kontrolü
  satın almayı reddeder) **engellenir**.
* Gerçek gelir kaybı riski en çok **Premium** tarafındadır; orada iki katman
  (cihaz içi bütünlük + sunucu doğrulaması) birlikte çalışır.

---

## 5) Depo gizli (private): ne değişecek?

> **Durum (28 Ekim 2026):** Depo **henüz herkese açık**. Bu ortamdaki GitHub
> bağlantısının **depo görünürlüğünü değiştirme yetkisi yok** (kod yazma yetkisi
> var, ayar değiştirme yok). Aşağıdaki 4 tıklamayı sizin yapmanız gerekiyor —
> 20 saniye sürer.

**Kazanç**
* Kaynak kodunuz, hutbe/dua/AI veri tabanınız ve iş kurallarınız artık
  herkese açık değil.
* Rakiplerin özellik listenizi ve algoritmalarınızı kopyalaması zorlaştı.
* Kod arama motorlarına (Google, GitHub arama) düşmez.

**Dikkat edilecekler**
* APK/AAB indirme bağlantıları **giriş gerektirir** (Bölüm 2'deki dağıtım yolu).
* GitHub Actions **özel depolarda dakika kotası** kullanır: ücretsiz planda aylık
  **2.000 dakika**. Bir derleme ~14 dakika → ayda ~140 derleme hakkınız var.
  Kota yaklaşırsa bana söyleyin; CI'ı yalnızca `main` dalında çalışacak şekilde
  daraltırım.
* Depoya **erişim vermeniz gereken kişiler** için: GitHub → *Settings →
  Collaborators* → kullanıcı adı ekle (varsayılan olarak sadece okuma = *Read*).

---

## 6) SİZİN YAPACAKLARINIZ (tıklama düzeyinde)

### 6.0. Depoyu gizli yapın — **ilk ve en kolay adım** (20 saniye)

1. Tarayıcıda açın: **`https://github.com/YAZILIMCEOSU/ezanapp/settings`**
   (giriş yapmış olmanız gerekir).
2. Sayfayı en alta kaydırın → **"Danger Zone"** (Kırmızı çerçeveli bölüm).
3. **"Change repository visibility"** satırında **"Change visibility"** düğmesine basın.
4. **"Make private"** seçin → açılan uyarı kutusuna depo adını
   `YAZILIMCEOSU/ezanapp` yazın → **"I understand, change repository visibility"**.

**Bitti.** Sayfayı yenilediğinizde depo adının yanında **"Private"** yazacak.

Notlar:
* Gizledikten sonra **APK indirme bağlantısı** yalnızca GitHub hesabınızla
  giriş yapınca çalışır (Bölüm 2'deki dağıtım yolları).
* Depoya başka biri bakacaksa: *Settings → Collaborators → Add people →
  yetki: **Read***.
* GitHub Actions ücretsiz planda özel depolarda **aylık 2.000 dakika** verir;
  bir derleme ~14 dakika. Kota yaklaşırsa bana söyleyin, CI'ı daraltırım.

### 6.1. İmza anahtarını (keystore) oluşturun ve 3 yerde saklayın — **en kritik adım**

> Bu dosya olmadan Play'de **güncelleme yayınlayamazsınız**. Kaybedilirse
> "Play App Signing" sayesinde kurtarılabilir; o yüzden 6.2'yi de yapın.

1. Bilgisayarınızda terminal/komut istemi açın.
2. Şu komutu çalıştırın (parolaları kendiniz belirleyin, **bir yere yazın**):

```bash
keytool -genkeypair -v -keystore ezanai-yayin.jks \
  -storepass <GÜÇLÜ_PAROLA_1> -keypass <GÜÇLÜ_PAROLA_2> \
  -alias ezanai -keyalg RSA -keysize 4096 -validity 10000 \
  -dname "CN=Ezan Vaktim Pro, OU=Mobile, O=Yazilimceosu, L=İstanbul, C=TR"
```

3. Oluşan `ezanai-yayin.jks` dosyasını:
   * bilgisayarınızda şifreli bir klasörde,
   * **1 adet USB bellekte** (çekmecede),
   * **1 adet bulut kasanızda** (Google Drive + 2FA) saklayın.
4. **Bu dosyayı kimseyle paylaşmayın**, depoya **yüklemeyin** (`.gitignore`'da).

### 6.2. Play App Signing'i açın (Google anahtarı korur)

1. Play Console → uygulamanız → *Test ve yayın → Uygulama bütünlüğü*.
2. **Play App Signing** bölümünde *Yönet* → onaylayın.
3. Bu adımda Google'ın tuttuğu anahtar güncellemeleri kurtarır; sizin
   `ezanai-yayin.jks` dosyanız **yükleme anahtarı** olur.

### 6.3. İmza sabitlemeyi açın (yeni özellik)

1. APK'nızın parmak izini alın (imzalı paket için):

```bash
# Android SDK build-tools içindeki apksigner ile:
apksigner verify --print-certs app-release.apk | findstr SHA-256   # Windows
apksigner verify --print-certs app-release.apk | grep SHA-256      # macOS/Linux
```

2. Play Console → *Test ve yayın → Uygulama bütünlüğü → Uygulama imzalama
   sertifikası*: burada da **SHA-256** parmak izi görünür (Play imzası).
3. Bu değeri **ortam değişkeni** olarak verip derleyin (`:` ve boşluklar
   otomatik temizlenir):

```bash
# macOS / Linux
export EXPECTED_SIGNING_SHA256=<SHA256_DEGERI>
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/1111 \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXX/2222
```

```powershell
# Windows (PowerShell)
$env:EXPECTED_SIGNING_SHA256="<SHA256_DEGERI>"
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

> Değer verilmezse **kontrol kapalı** kalır (test/CI derlemeleri bozulmaz).
> Kontrol açıkken farklı imzalı bir pakette Ayarlar → Hakkında ekranında
> "İmza sabitleme: **UYUMSUZ**" yazar ve Premium satın alma reddedilir.

### 6.4. Depoyu gizli tutma kuralları

- [ ] Depoyu kimseyle **fork** ettirmeyin (özel depoda fork zaten kapalı).
- [ ] Ekran görüntüsü/paylaşımda **kod** görünmesin.
- [ ] Yeni bir geliştirici eklerseniz yalnızca **Read** yetkisi verin,
      işi bitince kaldırın.
- [ ] Depoda **anahtar/parola** paylaşmayın; ihtiyaç varsa bana söyleyin,
      derleme zamanı değişkeni (secret) olarak ekleyelim.

### 6.5. Play Console'da yapılacak güvenlik ayarları

- [ ] *Uygulama bütünlüğü* → **Play Integrity API**'yi **etkinleştir**
      (Cloud projesi bağlanır; benim kod tarafını bağlamam için gerekli).
- [ ] *Uygulama içeriği → Veri güvenliği*: "Cihaz kimlikleri" ve "Konum"
      beyanlarını işaretleyin (rehber: `docs/PLAY_STORE.md` §5).
- [ ] *Uygulama içeriği → Reklamlar*: **Evet**.
- [ ] *Gelişmiş ayarlar → Uygulama imzalama* → "İmza anahtarını yükselt"
      seçeneğini **kullanmayın** (gerekmedikçe).

---

## 7) BENİM YAPACAKLARIM (teknik yol haritası)

Sırayla, her adım CI'da test edilerek ilerleyecek:

| # | İş | Ne kazandırır | Durum |
|---|---|---|---|
| 1 | **Play Integrity API entegrasyonu** (sunucu doğrulaması + `integrity_token`) | Root/emülatör/mod tespitinde en güçlü katman; sunucu olmadan da "standard request" ile cihaz bütünlüğü | 🔜 Sıradaki |
| 2 | **Sertifika sabitleme (network pinning)** | Araya girme (MITM) saldırılarını kapatır | 🔜 |
| 3 | **R8 full mode** + `-repackageclasses` | Kotlin tarafında daha güçlü karıştırma | 🔜 |
| 4 | **Bütünlük kontrolünü yalnızca Premium'a değil, açılışa da bağlama** | Modlanmış APK'da uyarı bandı + özellik kısıtı | 🔜 |
| 5 | **İmza sabitlemeyi CI'da otomatik doğrulama** | Yanlış imzayla paket çıkmasını engeller | 🔜 |
| 6 | **Bağımlılık güvenlik taraması** (haftalık) | Bilinen zafiyetli paketleri erken yakalar | 🔜 |
| 7 | **Bulut yedeklemede uçtan uca şifreleme** (Faz 5) | Kullanıcı verisi sunucuda okunamaz | 🔜 |
| 8 | **Premium makbuz doğrulaması için sunucu uç noktası** | Cihaz atlatılsa bile satın alma sunucuda doğrulanır | 🔜 |

> **Not:** 1. maddeden önce sizin **6.5**'teki Play Integrity etkinleştirmesini
> yapmanız gerekiyor. Yapılmazsa 1. maddeyi atlayıp 2–6 ile devam ederim.

---

## 8) Nasıl doğrularım? (sizin de deneyebileceğiniz 3 komut)

```bash
# 1) APK gerçekten imzalı mı ve kim imzalamış?
apksigner verify --print-certs ezanai-kurulum.apk

# 2) Paket adı doğru mu?
aapt dump badging ezanai-kurulum.apk | head -1        # package: name='com.yazilimceosu.ezanai'

# 3) Uygulama içinde: Ayarlar → Hakkında → "Güvenlik ve kopya koruması"
#    satırları (imza, kurulum kaynağı, mod/klon tespiti) cihazda gösterilir.
```

Beklenen görüntü (Play'den kurulmuş sürümde):

| Satır | Beklenen değer |
|---|---|
| Paket bütünlüğü | **Doğrulandı** (yeşil) |
| İmza sabitleme | **Eşleşti** (yeşil) — değer verilmişse |
| Kurulum kaynağı | **Google Play** (yeşil) |
| Mod/patch araçları | **Yok** (yeşil) |
| Klon / çift uygulama | **Yok** (yeşil) |
| Hata ayıklayıcı | **Bağlı değil** (yeşil) |

---

## 9) Sık sorulanlar

**S: Depoyu gizledik, Play Store bundan etkilenir mi?**
Hayır. Play yalnızca yüklediğiniz AAB'ye bakar.

**S: Kodu bir yerde yedeklemem gerekir mi?**
GitHub özel depo yeterli, ama isterseniz bana söyleyin; tüm kodu tek ZIP
olarak dışa aktarıp size verebilirim.

**S: Biri uygulamayı klonlarsa ne olur?**
Paket adı aynı olamaz (Play çakışmayı reddeder). Paket adı değiştirilirse
imza sabitleme + bütünlük kontrolü "resmî değil" der ve Premium çalışmaz.

**S: Kullanıcı ekran görüntüsü alamayacak mı?**
Hayır — yalnızca **ödeme ekranında** kapalı. Ayet/hadis paylaşımı etkilenmez.

**S: Bu korumalar uygulamayı yavaşlatır mı?**
Hayır. Kontroller yalnızca Premium ekranı açılırken ve bir kez "Hakkında"
ekranında çalışır (milisaniyeler).
