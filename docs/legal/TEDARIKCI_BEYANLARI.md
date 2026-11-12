# Tedarikçi Beyanları ve Gönderime Hazır Metinler

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Amaç:** Kapatılması gereken üç açık kalemi (Kur'an tilaveti lisansı, yapay
zekâ
sağlayıcısı veri politikası, Android tam alarm beyanı) tek dosyada,
gönderilmeye/kopyalanmaya hazır metinlerle toplamak.

> Bu dosya hukuki görüş değildir. Gönderimden önce avukat teyidi alınır.

---

## 1. KUR'AN TİLAVETİ — kritik bulgu

### 1.1 Tespit (12.11.2026)

| Kaynak | Yayımlanmış lisans | Ticari kullanım | Uygulamadaki durum |
|---|---|---|---|
| **everyayah.com** (eski adı versebyversequran.com) | **Site genelinde lisans YOK.** Yalnız `timings_files/000_disclaimer.txt` metni var: “© VerseByVerseQuran.com … siteye geri bağlantı verin”. Bir setin `info.txt` dosyasında “Recitation license: UNKNOWN” yazıyor. | **Belirsiz / pratikte yasak.** Yaygın topluluk yorumu CC-BY-NC; site ticari kullanım için izin vermiyor. | **Kullanılıyor** — `Alafasy_128kbps`, 10 hazır sure + tüm ayetler |
| Quran Foundation Content API (Quran.com) | Developer Terms (yürürlük 14.09.2026) + FAQ | **Evet** — “Developer may charge for an Application, offer subscriptions or in-app purchases, display advertising … freemium” | Kullanılmıyor |

**Uygulamanın mevcut iddiası yanlıştı:** `quran_screen.dart` içinde
“Tilavetler **açık lisanslı** EveryAyah arşivinden akıtılır” yazıyordu.
Bu ifade gerçeğe aykırıydı; 12.11.2026'da düzeltildi.

### 1.2 Risk

- Play/App Store telif şikâyeti (DMCA) → uygulama **kaldırılır**, hesap
  askıya alınır.
- Türkiye'de 5846 sayılı FSEK m.71 uyarınca ticari amaçla izinsiz çoğaltma
  suçtur.
- Reklam geliri ve Premium satışı “ticari kullanım” sayılır; ücretsiz
  dağıtım bile tek başına izin vermez.

### 1.3 Karar (üç seçenek, sırayla)

**A. Lisanslı kaynağa geç (ÖNERİLEN, kalıcı çözüm)**
Quran Foundation Content API:
- Ücretsiz Developer Console hesabı: <https://dev-console.quran.foundation/>
- OAuth2 client-credentials; **anahtar yalnız sunucuda** (mobil uygulamaya
  gömülmez — mevcut mimari kuralımızla uyumlu).
- Kural: önbellek **en fazla 7 gün**; içerik yeniden dağıtılmaz; her yerde
  **“Quran data provided by Quran Foundation”** atfı; tilavet edisyonu
  ayrıca anılır.
- Uygulama tarafı: `Reciter` kataloğunda `audioUrl` alanı QF uç noktasına
  çevrilir; indirme önbelleği 7 gün TTL ile sınırlanır.

**B. EveryAyah'tan yazılı izin iste (hızlı ama belirsiz)**
Metin §1.4'te. Yanıt gelmezse 30 gün sonra A'ya geçilir.

**C. Ayet sesini kaldır (en hızlı uyum)**
`quran_screen.dart` oynatıcısı “ses yok” moduna alınır; yalnız metin/meal
kalır. Premium vaatlerinden “tilavet” çıkarılır. **Önerilmez** — ürünün
temel vaadini zayıflatır.

**Bu turda yapılan:** Uygulama içi yanlış “açık lisanslı” ifadesi kaldırıldı,
kaynak ve olası kısıt kullanıcıya açıkça yazıldı. Kaynak değişimi (A) ayrı
bir kod turu ve QF anahtarı gerektirir.

### 1.4 EveryAyah'a gönderilecek metin

> **Konu:** Ticari mobil uygulamada tilavet kullanımı için yazılı izin talebi
>
> Sayın EveryAyah ekibi,
>
> “Ezan Vaktim Pro” (Android/iOS, paket `com.yazilimceosu.ezanai`) adlı
> uygulamamızda `everyayah.com/data/` altındaki Maher Al-Muaiqly
> (`Alafasy_128kbps`) tilavetlerini ayet bazında akıtıyoruz. Uygulama
> ücretsizdir; reklam ve isteğe bağlı Premium abonelik içerir.
>
> Sitenizde yayımlanmış açık bir lisans bulunmadığından, ticari kullanım
> için **yazılı izin** talep ediyoruz. Şartlarınızı kabul etmeye hazırız:
> okuyucu ve everyayah.com atfı, siteye geri bağlantı, kayıtları
> değiştirmeme, yeniden dağıtmama. İsterseniz aylık dinleme/indirme
> istatistiği paylaşabiliriz.
>
> İzin vermemeniz hâlinde 30 gün içinde tilavetleri kaldıracağımızı veya
> lisanslı bir sağlayıcıya geçeceğimizi taahhüt ederiz.
>
> Saygılarımızla,
> YazılımCeosu — destek@ezanai.app

### 1.5 Kabul ölçütü

- [ ] QF Developer Console başvurusu yapıldı **veya** EveryAyah yazılı izni
      alındı
- [ ] Uygulamada atıf görünür: “Quran data provided by Quran Foundation”
      **veya** “Tilavet: everyayah.com”
- [ ] Önbellek TTL ≤ 7 gün (QF yolu seçilirse)
- [ ] Test: çevrimdışı indirme 7 gün sonra yeniden doğrulanıyor

---

## 2. YAPAY ZEKÂ SAĞLAYICISI — sıfır saklama taahhüdü

### 2.1 Neden gerekli

ROPA'da “AI sorusu” kişisel veri olarak işleniyor; dinî inanç **özel
nitelikli** veridir (KVKK m.6). Sağlayıcı isteği eğitim için kullanıyorsa
ayrıca açık rıza ve aktarım dayanağı gerekir.

### 2.2 Sağlayıcıya gönderilecek metin

> **Konu:** API veri işleme ve sıfır saklama taahhüdü talebi
>
> … ürünümüzde kullandığımız API için aşağıdaki şartları yazılı olarak
> teyit etmenizi rica ederiz:
>
> 1. Gönderilen istemler (prompt) ve yanıtlar **model eğitimi veya
>    iyileştirme** amacıyla kullanılmaz.
> 2. İstem ve yanıtlar **30 günden uzun** saklanmaz; kötüye kullanım
>    izleme dışında saklama yoktur.
> 3. Saklama zorunluysa süre, amaç ve silme tarihi yazılı bildirilir.
> 4. Veriler **AB/ABD dışına** aktarılmaz; alt işleyen listesi paylaşılır.
> 5. KVKK m.9 ve GDPR md.28 kapsamında **veri işleyen sözleşmesi** (DPA)
>    imzalanır.
> 6. İhlal hâlinde **24 saat** içinde tarafımıza bildirim yapılır.
>
> Bu teyit alınana kadar uzak AI özelliği varsayılan **kapalı** kalacaktır.

### 2.3 Uygulama tarafı mevcut durum (doğrulandı)

- `AiService.ask(allowRemote:)` — rıza yoksa ağ çağrısı yapılmaz.
- `AiRepository.askWithQuota` varsayılanı `false`.
- Rıza zaman damgası: `aiConsentAt`.
- Test: `test/core/privacy_defaults_test.dart` + `AiRepository.askWithQuota`
  varsayılanının `false` olması (rıza yokken 0 ağ isteği).

### 2.4 Kabul ölçütü

- [ ] Sağlayıcıdan imzalı DPA + sıfır saklama teyidi
- [ ] Teyit `docs/legal/VERI_ENVANTERI_ROPA.md` R-03 satırına işlendi
- [ ] Teyit alınana kadar `allowRemote` yalnız kullanıcı rızasıyla açık

---

## 3. ANDROID TAM ALARM (`USE_EXACT_ALARM`) BEYANI

### 3.1 Mevcut durum

`AndroidManifest.xml` içinde **iki** izin var:

```xml
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### 3.2 Play politikası

`USE_EXACT_ALARM` yalnızca **çekirdek işlevi alarm/saat/takvim** olan
uygulamalara verilir ve **kullanıcı izni gerektirmez**. Ezan vakti
hatırlatıcısı, vaktin tam anında ses çalması gerektiği için bu tanıma
girer; ancak Play inceleme ekibi beyan ister.

### 3.3 Play Console beyan metni (kopyala-yapıştır)

> **Çekirdek işlev:** Uygulama, kullanıcının seçtiği il/ilçeye göre namaz
> vakitlerini hesaplar ve her vaktin **tam başlangıç anında** ezan
> bildirimi/sesi çalar. Bu zamanlama, uygulamanın ana işlevidir; saniye
> düzeyinde doğruluk gerektirir.
>
> `SCHEDULE_EXACT_ALARM` kullanıcı tarafından verilebilir; reddedilirse
> uygulama yaklaşık alarm ile çalışmaya devam eder ve kullanıcıya pil
> optimizasyonu ayarını gösterir.
>
> `USE_EXACT_ALARM` yalnızca bu çekirdek zamanlama için kullanılır; başka
> amaçla (pazarlama, hatırlatma, yeniden etkileşim) kullanılmaz.

### 3.4 Karar

- [ ] Beyan Play Console'a girildi (önerilen)
- [ ] **Alternatif:** `USE_EXACT_ALARM` satırı manifestten kaldırılır;
      yalnız `SCHEDULE_EXACT_ALARM` kalır. Bu durumda Android 13+
      kullanıcıları “Alarmlar ve hatırlatıcılar” iznini elle verir;
      verilmezse ezan ± birkaç dakika kayabilir. **Ürün vaadi zayıflar.**
- [ ] Karar `YAYIN_UYUMLULUK_KONTROL_LISTESI.md` §B'ye işlendi

---

## 4. ÖZET TABLO

| # | Kalem | Durum | Engel |
|---|---|---|---|
| 1 | Kur'an tilaveti lisansı | **AÇIK — P0** | QF anahtarı veya EveryAyah izni |
| 2 | AI sıfır saklama | **AÇIK — P1** | Sağlayıcı yanıtı |
| 3 | `USE_EXACT_ALARM` beyanı | **HAZIR — P1** | Play Console'a giriş |
| 4 | GitHub Pages | **AÇIK — P0** | Kullanıcı: Settings → Pages |
| 5 | Depo private | **AÇIK — P1** | Kullanıcı: Settings → Danger zone |
| 6 | Marka araştırması | **AÇIK — P0** | Turkpatent sorgusu |
