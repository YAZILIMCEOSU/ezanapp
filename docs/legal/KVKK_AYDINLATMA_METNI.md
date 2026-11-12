# Ezan Vaktim Pro — KVKK Aydınlatma Metni ve Gizlilik Politikası

**Sürüm:** 1.0
**Son güncelleme:** 12 Kasım 2026
**Yürürlük:** Yayımlandığı tarih
**Veri sorumlusu:** YazılımCeosu (gerçek kişi geliştirici) — İstanbul, Türkiye
**Not:** Şirket/ticari unvan bulunmamaktadır; MERSİS ve VKN yoktur. Veri
sorumlusu gerçek kişidir ve KVKK m.6/2 ile VERBİS istisnası kapsamındadır.
**Başvuru / iletişim:** destek@ezanai.app
**Uygulama:** Ezan Vaktim Pro — Akıllı İslam Asistanı (`com.yazilimceosu.ezanai`)

> Bu metin, 6698 sayılı Kişisel Verilerin Korunması Kanunu (“KVKK”) m.10
> kapsamındaki **aydınlatma yükümlülüğünü** ve Google Play / App Store gizlilik
> politikası gerekliliklerini birlikte karşılamak için hazırlanmıştır. Metin
> hukuki görüş değildir; yayın öncesinde bir avukat tarafından gözden
> geçirilmelidir.

## 1. Kapsam ve temel ilke

Ezan Vaktim Pro; namaz vakitleri, ezan/vakit bildirimleri, kıble, Kur'an,
ilahi, tesbih, hadis, Ramazan ve kaynak gösteren yapay zekâ asistanı sunar.

**Temel ilke:** Uygulamanın çekirdek özellikleri için **hesap açmanız
gerekmez**. Konumunuz namaz vakti ve kıble hesabı için **cihazınızda** işlenir;
konum koordinatınız sunucuya gönderilmez. Yalnızca seçtiğiniz şehir/ilçe
kimliği vakit servisine iletilir.

Veri sorumlusu, uygulama üzerinden işlenen kişisel veriler bakımından
YazılımCeosu’dur. Uygulama mağazadan indirildiğinde ödeme ve indirme
verilerini Google/Apple kendi politikalarına göre işler; bu metin yalnızca
uygulamanın kendi işlemlerini kapsar.

## 2. İşlenen veriler, amaçlar ve hukuki sebepler

| # | Veri kategorisi | Somut veriler | Amaç | Hukuki sebep (KVKK) | Yer / alıcı |
|---|---|---|---|---|---|
| 1 | Konum | Yaklaşık/hassas konum, son seçilen şehir/ilçe | Namaz vakti, kıble, imsakiye | m.5/2-c (sözleşmenin ifası) ve m.5/2-f (meşru menfaat); izin vermezseniz şehir elle seçilir | **Cihazda işlenir.** Vakit servisine yalnızca seçilen ilçe kimliği gider. Diyanet servisi kullanılamazsa **yaklaşık koordinat (2 ondalık, ~1 km)** AlAdhan’a iletilir; tam koordinat gönderilmez |
| 2 | Uygulama içeriği | Favoriler, okuma ilerlemesi, zikir kayıtları, hatim/kaza orucu, Ramazan günlüğü | Özelliklerin çalışması | m.5/2-c | Cihazdaki SQLite. Bulut yedekleme **açık rıza** ile açılır |
| 3 | Yapay zekâ soruları | Soru metni, son 6 mesajlık sohbet bağlamı, mezhep tercihi (Hanefî), kaynak bağlamı | Kaynaklı cevap üretmek | **m.6/2 açık rıza** (dinî inanç özel nitelikli veri olabilir) + m.9 kapsamında aktarım güvencesi | Cihaz + yapılandırılmışsa yurt dışındaki AI backend’i; kimlikle ilişkilendirilmez |
| 4 | Bulut yedeği | Yukarıdaki içerik + anonim Supabase kullanıcı kimliği (UUID) | Cihaz değişiminde geri yükleme | **m.6/2 açık rıza** + m.9 aktarım güvencesi | Supabase (AB/ABD bölgesi seçilebilir); TLS + satır düzeyi güvenlik (RLS) |
| 5 | Reklam verileri | Reklam kimliği (AD_ID), IP’den türetilen yaklaşık konum, reklam etkileşimleri, cihaz/uygulama bilgisi | Ücretsiz sürümde reklam gösterimi ve ölçümü | Kişiselleştirilmiş reklam: **açık rıza**; kişiselleştirilmemiş reklam: m.5/2-f meşru menfaat (denge testi) | Google AdMob (yurt dışı) |
| 6 | Abonelik durumu | Satın alma/abonelik durumu, ürün kimliği | Premium özellikleri açmak | m.5/2-c | Google Play / App Store; ödeme kartı bilgisi bize ulaşmaz |
| 7 | Destek yazışması | E-posta adresiniz, yazışma içeriği | Destek ve talep yönetimi | m.5/2-c ve m.5/2-f | E-posta sağlayıcısı; 2 yıl saklanır |
| 8 | Bildirim jetonu (yalnızca Firebase yapılandırılırsa) | FCM cihaz jetonu | Duyuru/hatırlatma bildirimi | m.5/2-c; bildirim izni ayrıca alınır | Google Firebase (yurt dışı) |
| 9 | Harita ve cami arama | Harita görüntü alanı; cami aramasında 3 ondalık (~110 m) konum | Harita gösterimi, yakındaki camiler | m.5/2-c | OpenStreetMap/Esri (karolar), unpkg (Leaflet), Overpass API; kimlik gönderilmez. **Tam koordinat hiçbir harita/servise gönderilmez.** |

### 2.1 İşlemediğimiz veriler

Ad-soyad, e-posta (destek yazışması hariç), telefon numarası, kişi listesi,
fotoğraf, kamera, mikrofon, sağlık verisi, ödeme kartı bilgisi, TC kimlik
numarası, tam adres, biyometrik veri **toplanmaz**. Uygulama reklam amacıyla
dinî inanç, siyasi görüş veya sağlık kategorilerinde hedefleme yapmaz.

### 2.2 Özel nitelikli veriler

Dinî inanç ve ibadet alışkanlığına ilişkin veriler KVKK m.6 anlamında **özel
nitelikli** olabilir. Bu veriler yalnızca:

1. AI asistanına uzak soru gönderme,
2. bulut yedeklemeyi açma,
3. kişiselleştirilmiş reklamları açma

işlemlerinde ve **her biri için ayrı, geri alınabilir açık rızanız** ile
işlenir. Rıza vermezseniz AI çevrimdışı bilgi tabanıyla yanıt verir, bulut
yedekleme kapalı kalır, reklamlar kişiselleştirilmez. Ayrıntı ve birebir rıza
metinleri: [`ACIK_RIZA_METINLERI.md`](ACIK_RIZA_METINLERI.md).

## 3. Verilerin toplanma yöntemi

- **Doğrudan sizden:** şehir seçimi, AI sorusu, yedekleme düğmesi, destek
  e-postası.
- **Cihazdan otomatik:** konum izni verdiyseniz GPS; bildirim izni; reklam
  kimliği (yalnızca reklamlar açıksa).
- **Üçüncü taraflardan:** Google Play/App Store abonelik durumu.

## 4. Aktarım

### 4.1 Yurt içi

Verileriniz yurt içinde üçüncü kişilerle paylaşılmaz. Destek e-postası
sağlayıcısı veri işleyen sıfatıyla hareket eder.

### 4.2 Yurt dışına aktarım

| Alıcı | Ülke/Bölge | Veri | Amaç | Güvence |
|---|---|---|---|---|
| Google AdMob | ABD ve Google’ın hizmet bölgeleri | Reklam kimliği, IP, yaklaşık konum, etkileşim | Reklam | Google Ads Veri İşleme Şartları + standart sözleşme; kişiselleştirme için açık rıza |
| Supabase | AB (Frankfurt) veya ABD (yapılandırmaya göre) | Yedek paketi, anonim UUID | Bulut yedekleme | TLS, RLS, DPA; m.9 standard sözleşme |
| AI backend / model sağlayıcısı | Yapılandırmaya göre AB/ABD | Soru, son 6 mesaj, mezhep tercihi | Cevap üretimi | m.9 standard sözleşme; kimliksiz istek; saklama yok |
| Google Firebase (opsiyonel) | ABD | FCM jetonu, cihaz bilgisi | Push bildirim | Google DPA + standart sözleşme |
| AlAdhan (yedek vakit) | Sağlayıcı altyapısı (AB/İngiltere) | Yaklaşık koordinat (2 ondalık, ~1 km), tarih | Diyanet verisi alınamazsa vakit hesabı | Standart sözleşme; kimlik gönderilmez |

Kurul’un yeterlilik kararı bulunmadığından aktarımlar, 10 Temmuz 2024 tarihli
Yönetmelik kapsamında **standart sözleşme** ile yapılır; sözleşme imzasından
itibaren **5 iş günü** içinde Kurum’a bildirilir. Yurt dışı aktarımı
gerektirmeyen seçenekler (çevrimdışı AI, yedekleme kapalı, kişiselleştirilmemiş
reklam) her zaman sunulur.

## 5. Saklama süreleri

| Veri | Süre | Silme yöntemi |
|---|---|---|
| Cihazdaki içerik | Siz silene kadar | Ayarlar → Verilerimi sil; uygulamayı kaldırma |
| AI sohbeti | Siz silene kadar (cihazda) | Sohbet silme / Verilerimi sil |
| Bulut yedeği | Siz silene kadar; hareketsizlikte hedef 24 ay | Ayarlar → Bulut yedekleme → Sunucudaki yedeği sil; destek |
| AI sunucu isteği | Yanıt üretimiyle sınırlı; kalıcı saklama hedefi yok | Sağlayıcı sözleşmesiyle teyit |
| Destek yazışması | 2 yıl | Süre sonunda silinir |
| Reklam verileri | Google politikalarına göre | Google hesap/cihaz ayarları; kişiselleştirmeyi kapatma |
| Abonelik kaydı | Vergi/ticaret mevzuatı gereği mağaza tarafında | Google/Apple |

## 6. Veri güvenliği

KVKK m.12 kapsamında alınan başlıca tedbirler:

- TLS 1.2+ zorunlu, cleartext trafik kapalı (`usesCleartextTraffic=false`,
  network security config).
- Bulut yedeğinde satır düzeyi güvenlik (RLS): anonim kimlik yalnızca kendi
  satırını okur/yazar.
- API anahtarları uygulamaya gömülmez; AI ve katalog istekleri backend
  üzerinden yapılır.
- Yerel veritabanı uygulama alanında; Android yedeği kapalı
  (`allowBackup=false`).
- Loglarda konum, soru metni, e-posta gibi kişisel veriler maskelenir.
- Sürüm paketleri R8 + obfuscation ile üretilir; imza sabitleme ve paket
  bütünlüğü kontrolü vardır.
- Güvenlik açığı bildirimi: `SECURITY.md` ve `destek@ezanai.app`.

Ayrıntılı protokol: [`SIBER_GUVENLIK_PROTOKOLU.md`](SIBER_GUVENLIK_PROTOKOLU.md).

## 7. Haklarınız (KVKK m.11)

- Kişisel verilerinizin işlenip işlenmediğini öğrenme,
- işlenmişse buna ilişkin bilgi talep etme,
- işlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme,
- yurt içinde/yurt dışında aktarıldığı üçüncü kişileri öğrenme,
- eksik/yanlış işlenmişse düzeltilmesini isteme,
- m.7 kapsamında silinmesini/yok edilmesini isteme,
- düzeltme/silme işlemlerinin aktarıldığı üçüncü kişilere bildirilmesini isteme,
- münhasıran otomatik sistemlerle analiz sonucu aleyhinize bir sonucun ortaya
  çıkmasına itiraz etme,
- kanuna aykırı işleme nedeniyle zarara uğrarsanız tazminat talep etme.

**Başvuru:** destek@ezanai.app — konu satırı “KVKK Başvuru”. Talebiniz en geç
**30 gün** içinde ücretsiz yanıtlanır. Kimliğinizi doğrulamak için ek bilgi
istenebilir. Başvurunuz reddedilirse veya süresinde yanıtlanmazsa Kişisel
Verileri Koruma Kurulu’na şikâyet edebilirsiniz.

Uygulama içinden:

- **Ayarlar → Gizlilik ve rızalar:** rızaları görüntüleme/geri çekme,
- **Ayarlar → Verilerimi sil:** cihaz verilerini silme,
- **Ayarlar → Bulut yedekleme → Sunucudaki yedeği sil:** sunucu verisini silme,
- **Hakkında → Gizlilik / KVKK / Kullanım koşulları:** metinlere erişim.

## 8. Çocuklar

Uygulama 13 yaş altı çocuklara yönelik değildir ve bilerek çocuklardan veri
toplamaz. Mağaza yaş derecelendirmesi buna göre yapılır. Reklamlar çocuk
kategorilerine yönelik hedeflenmez.

## 9. Ticari iletişim

Uygulama pazarlama amaçlı e-posta, SMS veya push bildirimi göndermez.
Yalnızca kullanıcının etkinleştirdiği işlevsel bildirimler (vakit, ezan,
hatırlatma) gönderilir. İleride ticari iletişim eklenirse 6563 sayılı
Elektronik Ticaretin Düzenlenmesi Hakkında Kanun ve Ticari İletişim ve Ticari
Mesajlar Yönetmeliği uyarınca **önceden onay** alınır, onay İYS’ye kaydedilir
ve her mesajda ret hakkı sunulur.

## 10. Çerezler ve SDK’lar

Uygulama tarayıcı çerezi kullanmaz. Gömülü SDK’lar: Google Mobile Ads (UMP
onay yönetimi), isteğe bağlı Firebase Messaging, isteğe bağlı Supabase.
Bunların veri uygulamaları kendi politikalarına ve bu metindeki beyanlara
tabidir. Reklam kişiselleştirmesi varsayılan olarak **kapalıdır**.

## 11. Değişiklikler

Önemli değişiklikler uygulama içinde duyurulur ve yeni sürüm numarasıyla
yayımlanır. Metnin güncel sürümü her zaman bu sayfada bulunur. Metin
değişikliği, geriye dönük rıza gerektiren yeni bir işleme başlandığı anlamına
gelmez; yeni işleme için ayrıca rıza istenir.

## 12. Veri akışı (özet)

```
Konum (cihaz) ──► vakit/kıble hesabı (cihaz)  [tam koordinat sunucuya gitmez]
Şehir kimliği ──► Diyanet vakit servisi (ağ)
Yedek: ~1 km koordinat ──► AlAdhan (yalnızca Diyanet verisi alınamazsa)
AI sorusu ──► [rıza] ──► AI backend ──► cevap (cihazda saklanır)
Yerel veri ──► [rıza] ──► Supabase yedeği (UUID, TLS, RLS)
Reklam isteği ──► AdMob (kişiselleştirme varsayılan kapalı)
```

## 13. İletişim

**E-posta:** destek@ezanai.app
**Güvenlik bildirimi:** destek@ezanai.app — konu: “GÜVENLİK”
**Adres:** İstanbul, Türkiye (tam tebligat adresi talep üzerine ve mağaza
geliştirici bilgilerinde paylaşılır)

---

### English summary

Ezan Vaktim Pro works without an account. Your location is used **on-device**
for prayer times and qibla; the full coordinate is never uploaded. Only the
selected district ID is sent to the prayer-times service. If that service is
unavailable, an **approximate coordinate (2 decimals, ~1 km)** is sent to
AlAdhan as a fallback. Favorites, reading progress,
dhikr logs and AI chats are stored locally. Remote AI, cloud backup and
personalized ads are **optional, opt-in, and separately consented**; otherwise
the app uses its offline knowledge base, keeps backup off and serves
non-personalized ads. Payments are handled by Google Play/App Store; we never
receive card data. Special-category (religious) data is processed only with
explicit consent. You can withdraw consent and delete data in-app or via
destek@ezanai.app. Security: TLS, RLS, no embedded API keys, obfuscated builds.
