# EzanAI — Gizlilik Politikası

**Son güncelleme:** 5 Ekim 2026
**Yürürlük tarihi:** Yayın tarihi itibarıyla
**Veri sorumlusu:** EzanAI (YazılımCeosu) — destek@ezanai.app

Bu politika, **EzanAI — Akıllı İslam Asistanı** mobil uygulamasında (paket adı
`com.yazilimceosu.ezanai`) hangi verilerin işlendiğini, neden işlendiğini, nerede
saklandığını ve haklarınızı nasıl kullanabileceğinizi açıklar.

Kısa özet: **Uygulamanın temel özellikleri için hesap açmanız gerekmez.** Konum
bilgisi namaz vakti ve kıble hesabı için cihazınızda kullanılır, sunucuya
gönderilmez. Favoriler, okuma geçmişi, zikir kayıtları ve AI sohbetleri cihazınızdaki
veritabanında saklanır. Bulut yedekleme yalnızca siz açtığınızda ve yalnızca anonim
bir kimlikle çalışır.

---

## 1. İşlenen veriler

| Veri | Amaç | Konum | Paylaşım |
|---|---|---|---|
| **Konum (yaklaşık/hassas)** | Namaz vakti hesabı, kıble yönü, imsakiye | Cihazda (ayarlarda saklanan son konum) | Gönderilmez. Yalnızca vakit sorgusu yaparken seçtiğiniz şehir/ilçe kimliği vakit servisine iletilir. |
| **Şehir/ilçe seçimi** | Vakit ve imsakiye verisi | Cihazda | Vakit servisine şehir kimliği olarak |
| **Favoriler, okuma ilerlemesi, zikir kayıtları, hatim/kaza orucu, Ramazan günlüğü** | Uygulama işlevleri | Cihazdaki SQLite veritabanı | Yalnızca bulut yedeklemeyi açtıysanız şifreli bağlantıyla yedeğe dahil edilir |
| **AI sohbet metinleri** | Sorunuza cevap üretmek | Cihazda saklanır; cevap üretimi için backend'e iletilir | Yalnızca cevap üretimi amacıyla, kimliğinizle ilişkilendirilmeden |
| **Abonelik durumu** | Premium özelliklerin açılması | Google Play üzerinden | Ödeme bilgileriniz bize hiçbir zaman ulaşmaz; satın alma doğrulaması Google Play Billing ile yapılır |
| **Reklam kimliği** | Ücretsiz sürümde reklam gösterimi | Google AdMob | AdMob gizlilik politikasına tabidir; Premium'da reklam gösterilmez |
| **Çökme ve kullanım verileri (isteğe bağlı)** | Kararlılık ve hata giderme | Firebase Crashlytics / Analytics | Ayarlar > Gizlilik bölümünden **kapatılabilir**; kapalıyken veri gönderilmez |
| **Anonim yedekleme kimliği** | Bulut yedeğini yalnızca sizin cihazlarınızla eşleştirmek | Supabase | E-posta, ad, telefon istenmez; anonim oturum kimliği kullanılır |

**İşlemediğimiz veriler:** ad-soyad, e-posta, telefon numarası, kişi listesi, fotoğraf,
takvim, mikrofon, kamera, sağlık verisi, ödeme kartı bilgisi, hassas kimlik verisi.

## 2. İzinler ve gerekçeleri

| Android izni | Neden |
|---|---|
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | Bulunduğunuz yere göre vakit ve kıble hesabı. İzin vermezseniz şehri elle seçebilirsiniz; uygulama çalışmaya devam eder. |
| `POST_NOTIFICATIONS` | Ezan, vakit, sahur/iftar ve hatırlatma bildirimleri. |
| `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` | Vakit bildirimlerinin tam zamanında ve cihaz yeniden başladıktan sonra da çalışması. |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Ekran kapalıyken Kur'an/ilahi/ezan çalmaya devam etmesi. |
| `INTERNET`, `ACCESS_NETWORK_STATE` | Vakit servisi, AI, katalog, reklam ve yedekleme. |
| `VIBRATE` | Tesbih/zikir dokunsal geri bildirimi (kapatılabilir). |
| `com.android.vending.BILLING` | Premium abonelik. |

İzinler yalnızca ilgili özellik ilk kullanıldığında istenir; reddedilmesi durumunda
uygulama kullanıcı dostu bir açıklama gösterir ve alternatif yol sunar.

## 3. Verilerin saklanması ve silinmesi

- Cihazdaki veriler siz silene kadar saklanır: **Ayarlar > Verilerimi sil**.
- Bulut yedeği kullanıyorsanız **Ayarlar > Bulut yedekleme > Oturumu kapat** ile
  erişim sonlandırılabilir; silme talebi için destek@ezanai.app adresine yazabilirsiniz.
  Talebiniz en geç 30 gün içinde işlenir.
- AI sohbet geçmişini uygulama içinden tek tek veya toplu olarak silebilirsiniz.
- Yedekler aktarım sırasında TLS ile, sunucuda satır düzeyi güvenlik (RLS) ile
  korunur; yalnızca kendi anonim kimliğiniz kendi satırınıza erişebilir.

## 4. Üçüncü taraf hizmetler

| Hizmet | Amaç | Politika |
|---|---|---|
| Google AdMob | Ücretsiz sürümde reklam | <https://policies.google.com/technologies/ads> |
| Firebase (Analytics, Crashlytics, FCM) | Kararlılık, isteğe bağlı istatistik, duyuru bildirimleri | <https://firebase.google.com/support/privacy> |
| Supabase | Bulut yedekleme (isteğe bağlı) | <https://supabase.com/privacy> |
| Aladhan API | Vakit karşılaştırma/alternatif kaynak | <https://aladhan.com/privacy> |
| Google Play Billing | Abonelik işlemleri | <https://policies.google.com/privacy> |

## 5. Çocukların gizliliği

Uygulama genel kitleye yöneliktir ve 13 yaş altı çocuklardan bilerek veri toplamaz.
Kişisel veri toplamadığı için çocukların kullanımında ek risk oluşmaz; reklamlar
Google politikalarına uygun şekilde, hassas kategoriler hariç tutularak gösterilir.

## 6. Haklarınız (KVKK / GDPR)

- Verilerinize erişme, düzeltme, silme ve işlemeye itiraz etme hakkınız vardır.
- Konum iznini sistem ayarlarından, analitik/çökme raporlarını uygulama
  ayarlarından, reklam kişiselleştirmesini cihaz ayarlarından kapatabilirsiniz.
- Talepleriniz için: **destek@ezanai.app**

## 7. Dinî içerik ve AI sınırları

AI asistanı **kesin dinî hüküm vermez**; cevapları Kur'an, sahih hadis ve güvenilir
fıkıh kaynaklarına dayandırır, mezhep farklarını ayrıca belirtir ve tereddüt hâlinde
ehil bir âlime veya resmî fetva kurumuna danışmanızı önerir. AI'ya yazdığınız metinler
yalnızca cevap üretmek amacıyla işlenir.

## 8. Politika değişiklikleri

Bu politika güncellendiğinde "Son güncelleme" tarihi değişir; önemli değişiklikler
uygulama içinde duyurulur. Güncel sürüm her zaman bu sayfada yayımlanır.

---

## English summary

EzanAI does not require an account. Location is used **on-device** for prayer times
and qibla; it is not uploaded. Favorites, reading progress, dhikr logs and AI chats
are stored locally in SQLite and are only included in an end-to-end encrypted backup
if you explicitly enable cloud backup, which uses an **anonymous** identity (no email,
no name). Crash/usage analytics are **opt-in** and can be disabled in Settings. Ads
are served by Google AdMob in the free tier only; Premium is ad-free. Payments are
handled by Google Play Billing — we never receive your payment details. The AI
assistant never issues definitive religious rulings, cites sources, and notes
differences of opinion between schools of jurisprudence. Contact: destek@ezanai.app
