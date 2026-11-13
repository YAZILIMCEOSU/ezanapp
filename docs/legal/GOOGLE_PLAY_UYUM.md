# Google Play Uyum Dosyası — Ezan Asistanı Pro

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Hedef:** Google Play Console beyanları ile uygulamanın gerçek davranışını
**birebir** uyumlu hâle getirmek ve yayın reddini önlemek.

> Kaynaklar: Google Play Developer Program Policy, Data safety, Target API
> level, Permissions & APIs, Payments, AI-Generated Content, Families, Ads.
> Bağlantılar §12’de. Bu dosya hukuki görüş değildir.

## 1. Yayın künyesi

| Alan | Değer |
|---|---|
| Uygulama adı | Ezan Asistanı Pro — Namaz Vakti, Kıble ve Kur’an |
| Paket | `com.yazilimceosu.ezanai` |
| Sürüm | `1.0.0+1` (yayın öncesi artırılacak) |
| Kategori | Yaşam Tarzı / Referans |
| İçerik derecesi | IARC anketi sonrası; dinî içerik, şiddet/cinsellik yok → hedef 3+/7+ |
| Hedef kitle | 13 yaş ve üzeri |
| Reklam | Ücretsiz sürümde var; Premium’da yok |
| Uygulama içi satın alma | Var (aylık/yıllık/ömürlük) |
| Hesap | Zorunlu değil; bulut yedeklemede anonim oturum |
| Gizlilik politikası | `https://yazilimceosu.github.io/ezanapp/privacy.html` |
| Destek | `https://yazilimceosu.github.io/ezanapp/` · destek@ezanai.app |
| Geliştirici türü | **Bireysel (gerçek kişi)** — şirket, ticari unvan, MERSİS/VKN **yok** |
| Geliştirici hesabı | Play Console bireysel hesap → 12 test kullanıcısı / 14 gün kapalı test şartı |

## 1.1 Ad, marka ve “copycat” riski

### Karar (12.11.2026)

Ürün adı **“Ezan Asistanı Pro”** olarak belirlendi. Önceki çalışma adı
“Ezan Vaktim Pro” idi; bu ad Play Store’daki “Ezan Vakti Pro” kayıtlarıyla
**tek harf** farkı taşıdığı için App Store 4.1 (Copycats) ve Play taklit
kuralları bakımından riskliydi. Ad değişikliğiyle bu risk kapatıldı.

### Pazardaki benzer adlar (12.11.2026 kontrolü)

| Mağaza kaydı | Geliştirici | Paket | Durum |
|---|---|---|---|
| Ezan Vakti Pro: Namaz Saatleri | EDR Software Corp. | `com.dogrusoftware.ezanvaktipro` | Yayında |
| Ezan Vakti Pro: Namaz Vakti | Ela İnternet Hizmetleri San. Tic. Ltd. Şti. | — | Yayında |
| Ezan Vakti Pro | Ezan Saati | `ezan.vakti.pro` | **Kaldırıldı** (Eylül 2024) |

**Bizim kaydımız:** “Ezan Asistanı Pro” · `com.yazilimceosu.ezanai` ·
geliştirici YazılımCeosu. Yukarıdaki uygulamalarla **hiçbir bağlantımız
yoktur**; ad, ikon, ekran görüntüsü ve kod kullanılmamıştır.

### Kalan riskler

1. **Genel “ezan … pro” kalıbı:** Sektörde yaygın olduğu için tamamen
   ayırt edici değildir; ancak artık belirli bir uygulamanın adının
   kopyası değildir.
2. **Marka hakkı:** “Ezan Asistanı” üçüncü kişi adına tescilli olabilir.
3. **Play/Apple taklit değerlendirmesi:** İkon, ekran görüntüsü ve mağaza
   metni özgün olduğu sürece risk düşüktür.

### Azaltma ve yapılacaklar

- [x] Özgün paket kimliği, ikon, ekran görüntüleri ve metinler.
- [x] Addan bağımsız ayırt edici alt başlık: “Namaz Vakti, Kıble ve Kur’an”.
- [x] Uygulama içi ad, Android etiketi, bildirim başlıkları, mağaza
      metinleri ve yasal belgeler **tek kaynaktan** güncellendi
      (`AppConstants.appName`).
- [ ] Yayın öncesi **Turkpatent** araştırması: “Ezan Asistanı” (sınıf 9, 42).
- [ ] Şikâyet hâlinde 5 iş günü içinde yedek ada geçiş hazırlığı:
      **“Asistan Vakit”**, **“Mihrap”**, **“Vaktim”**.
- [ ] Mağaza açıklamasında rakip adı **anılmaz**.

## 2. Data safety — veri türleri

Aşağıdaki tablo, **reklam kimlikleri yapılandırılmış** yayın derlemesi için
doldurulacak beyandır. `ADS_ENABLED=false` veya reklam kimliği yoksa reklam
satırları “toplanmıyor” olarak işaretlenir; diğer satırlar değişmez.

| Veri türü | Toplanıyor mu? | Paylaşılıyor mu? | Amaç | İsteğe bağlı? | Silinebilir? |
|---|---|---|---|---|---|
| Yaklaşık konum | Evet (AdMob, IP’den) | Evet (Google) | Reklam/analitik | Reklam kapatılırsa hayır | Cihaz/Google ayarları |
| Hassas konum (tam koordinat) | **Hayır** (cihazda kalır; sunucuya gönderilmez) | Hayır | — | — | Uygulama içi |
| Yaklaşık konum (yedek vakit) | Evet — 2 ondalık, ~1 km | Evet (AlAdhan) | Uygulama işlevi | Diyanet servisi yoksa | AlAdhan politikası |
| Ad / e-posta / telefon | **Hayır** | — | — | — | — |
| Kullanıcı kimlikleri (anonim UUID) | Evet (yalnızca yedekleme açıksa) | Hayır (Supabase işleyen) | Uygulama işlevi | Evet (rıza) | Uygulama içi + e-posta |
| Dinî inançlar | Evet (AI/backup isteğe bağlı) | Hayır (işleyenlerle sınırlı) | Uygulama işlevi | **Evet (ayrı rıza)** | Uygulama içi + e-posta |
| Diğer kullanıcı içeriği (AI soruları) | Evet (yalnızca uzak AI rızası) | Hayır (işleyen) | Uygulama işlevi | Evet | Sohbet silme |
| Uygulama etkinliği (reklam etkileşimi) | Evet (AdMob) | Evet (Google) | Reklam/ölçüm | Reklam kapatılırsa hayır | Google ayarları |
| Cihaz veya diğer kimlikler (AD_ID, FCM jetonu) | Evet (reklam/push) | Evet (Google) | Reklam, bildirim | Reklam/push kapatılabilir | Google/cihaz ayarları |
| Uygulama bilgisi ve performansı | Evet (AdMob teknik veri) | Evet (Google) | Reklam | — | Google |
| Satın alma geçmişi | Evet (abonelik durumu) | Hayır | Uygulama işlevi | Hayır (Premium ise) | Mağaza |
| Kişiler, fotoğraf, mikrofon, sağlık | **Hayır** | — | — | — | — |

**Güvenlik cevapları:**

- Veriler aktarımda şifreleniyor mu? **Evet** (TLS).
- Kullanıcı silme talep edebiliyor mu? **Evet** (uygulama içi + e-posta).
- Veri işleme bağımsız denetimden geçti mi? **Hayır** (henüz).
- Aile/çocuk politikası: uygulama 13+; çocuklara yönelik değil.

**Tutarlılık kuralı:** Play Data safety, gizlilik politikası ve mağaza metni
**aynı** ifadeleri kullanmalıdır. “Tam koordinat sunucuya gönderilmez”
denirken; AdMob’un IP’den yaklaşık konum alması ve Diyanet servisi
kullanılamadığında AlAdhan’a **2 ondalık (~1 km) koordinat** gönderilmesi
ayrıca beyan edilir.

## 3. İzin beyanları

| İzin | Neden | Play beyanı |
|---|---|---|
| `POST_NOTIFICATIONS` | Vakit/ezan bildirimi | Çalışma zamanı izni; bağlam içinde istenir |
| `SCHEDULE_EXACT_ALARM` | Ezanın tam vaktinde çalması | Kullanıcı “Alarmlar ve hatırlatıcılar” ekranından verir; reddedilirse yaklaşık alarm |
| `USE_EXACT_ALARM` | Çekirdek işlev: vakit alarmı | **“Alarmlar ve hatırlatıcılar” beyanı.** Play yalnızca çekirdeği alarm/saat-takvim olan uygulamalara izin verir; ezan vakti alarmı çekirdek işlevdir. Red riski varsa bu izin kaldırılır, `SCHEDULE_EXACT_ALARM` yeterli olur |
| `USE_FULL_SCREEN_INTENT` | Kilit ekranında ezan | Alarm kategorisi; Android 14+ kullanıcı onayı |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Arka planda ezan | Çekirdek işlev; alternatif olarak pil ayarları ekranı gösterilir |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Ekran kapalıyken Kur’an/ilahi | `mediaPlayback` türü manifestte |
| `ACCESS_FINE/COARSE_LOCATION` | Vakit/kıble | Yalnızca ön planda; konum cihazda işlenir; izin reddedilirse şehir seçimi |
| `AD_ID` | Reklam | Data safety’de beyan; kişiselleştirme varsayılan kapalı |
| `RECEIVE_BOOT_COMPLETED` | Yeniden başlatmada alarmları geri kurma | Zamanlanmış bildirimler |

**Beyan metni (kopyala-yapıştır):**

> Ezan Asistanı Pro, namaz vakti ve ezan alarmlarının tam zamanında çalması için
> kesin alarm API’sini kullanır. Bu, uygulamanın çekirdek işlevidir. Kullanıcı
> izin vermezse alarm yaklaşık moda düşer ve uygulama bunu kullanıcıya bildirir.
> Konum yalnızca ön planda, vakit ve kıble hesabı için cihazda kullanılır;
> tam koordinat sunucuya gönderilmez; Diyanet servisi kullanılamazsa
> yaklaşık koordinat (2 ondalık, ~1 km) AlAdhan servisine gönderilir. Reklam
> kimliği yalnızca ücretsiz sürümde,
> kişiselleştirme varsayılan kapalı olarak kullanılır.

## 4. AI-Generated Content politikası

| Gereklilik | Durum | Kanıt |
|---|---|---|
| Uygunsuz içeriği önleme | Kısmi | Kaynak zorunluluğu, `require_verified_sources=true`, yerel filtre; backend moderasyonu sözleşmede |
| Uygulama içi bildir/flag | **Var** | AI yanıt kartı → “Bu cevabı bildir” → neden seçimi |
| Bildirimlerin incelenmesi | Var (yerel kayıt + destek) | `AiReportService` |
| Dış form/mailto yeterli değil | Uygun | Uygulama içi diyalog |
| AI olduğunun açıklanması | Var | “Yapay zekâ yardımıyla” uyarısı |
| Dinî hüküm vermeme | Var | Disclaimer + kaynak gösterimi |
| Mağaza görsellerinde AI beyanı | Yayın öncesi kontrol | Görseller AI ile üretildiyse işaretle |

## 5. Abonelik ve ödeme

- Play Billing kullanılır; harici ödeme bağlantısı yoktur (Türkiye).
- Ürünler: `ezanai_premium_monthly`, `ezanai_premium_yearly`,
  `ezanai_premium_lifetime`.
- Satın alma ekranında fiyat, dönem, otomatik yenileme ve iptal yolu gösterilir.
- “Aboneliği yönet” Play abonelik sayfasını açar.
- İade/iptal Play kurallarına tabidir; uygulama kullanıcıyı mağaza dışına
  yönlendirmez.
- Ücretsiz deneme varsa süre ve dönüşüm koşulu açıkça yazılır.

## 6. Hesap ve veri silme

- Uygulama **hesap oluşturmaz**; bu nedenle Play’in “hesap silme” zorunluluğu
  kapsamında değildir.
- Yine de kullanıcı:
  - **Ayarlar → Verilerimi sil** ile cihaz verilerini,
  - **Ayarlar → Bulut yedekleme → Sunucudaki yedeği sil** ile sunucu verisini,
  - destek@ezanai.app ile tüm talepleri
  silebilir.
- Silme talep sayfası: `.../veri-silme.html`.
- Abonelik silme değildir; abonelik mağazadan iptal edilir (kullanıcıya uyarı
  gösterilir).

## 7. Reklam politikası

- Ücretsiz sürümde AdMob; Premium’da hiç reklam yok.
- **Kişiselleştirme varsayılan kapalı**; kullanıcı açık rıza verirse açılır.
- Dinî inanç, siyasi görüş, sağlık, cinsel yönelim temelli hedefleme yok.
- Reklam içeriği filtreleri: yetişkin/dating/kumar/alkol kategorileri
  engellenir (AdMob blocking controls).
- Çocuklara yönelik değil; `tagForChildDirectedTreatment` false,
  `tagForUnderAgeOfConsent` false.
- Reklamlar içerik üzerine kapatıcı biçimde yerleştirilmez; yanıltıcı tıklama
  yok.

## 8. Mağaza metni ve görseller

- “Resmî Diyanet uygulaması” ifadesi kullanılmaz; “Diyanet yöntemi” denir.
- Lisans kanıtı yoksa “gerçek müezzin/Kâbe imamı” adı kullanılmaz.
- Ekran görüntüleri uygulamanın gerçek ekranı olmalı; sahte özellik yok.
- AI özelliği mağaza metninde “kaynak gösterir, fetva vermez” olarak anlatılır.
- Kısa açıklama 80, tam açıklama 4000 karakter; anahtar kelime doldurma yok.

## 9. Teknik uyum

| Gereklilik | Durum | Eylem |
|---|---|---|
| Target API 36 (Android 16) | **Doğrulanacak** | CI’da `aapt2 dump badging` kapısı; <36 ise yayın durur |
| 16 KB sayfa boyutu (Android 15+) | Flutter 3.47/AGP 8.12 ile uyumlu | Yayın öncesi `zipalign -c -P 16` doğrulaması |
| Edge-to-edge (API 35+) | Flutter varsayılanı | Cihaz testi |
| Predictive back | `enableOnBackInvokedCallback=true` | Test |
| FGS türü | `mediaPlayback` | Manifestte |
| Cleartext kapalı | `usesCleartextTraffic=false` | Mevcut |
| Yedekleme kapalı | `allowBackup=false` | Mevcut |
| İmza | Release keystore + Play App Signing | CI imza kontrolü |
| 64-bit | Flutter AAB | Mevcut |

## 10. Test ve yayın akışı

1. Kapalı test: yeni kişisel geliştirici hesabı için **en az 12 test
   kullanıcısı / 14 gün** (Play kuralı).
2. Üretim öncesi: Data safety, içerik derecesi, hedef kitle, reklam beyanı,
   gizlilik URL’si, mağaza görselleri.
3. Aşamalı yayın: %10 → %50 → %100; çökme oranı ve ANR izlenir.
4. Sürüm notları Türkçe; kullanıcıya görünen değişiklikler yazılır.

## 11. Yayın öncesi kontrol listesi

- [ ] Gizlilik URL’si canlı ve uygulama içi bağlantıyla aynı
- [ ] KVKK aydınlatma + açık rıza metinleri yayında
- [ ] Data safety tablosu §2 ile birebir
- [ ] AI bildir düğmesi çalışıyor
- [ ] Kişiselleştirilmiş reklam varsayılan kapalı
- [ ] Abonelik ekranında otomatik yenileme bilgisi
- [ ] Target API 36 doğrulandı
- [ ] 16 KB uyumu doğrulandı
- [ ] İmza/parmak izi kaydedildi
- [ ] Ses lisansları belgelendi (§ `SES_VE_ICERIK_LISANSLARI.md`)
- [ ] “Resmî Diyanet” iddiası yok
- [ ] Kapalı test 12/14 tamam
- [ ] Destek e-postası çalışıyor

## 12. Resmî kaynaklar

- Target API: <https://support.google.com/googleplay/android-developer/answer/11926878>
- Data safety: <https://support.google.com/googleplay/android-developer/answer/10787469>
- AI-Generated Content: <https://support.google.com/googleplay/android-developer/answer/16479678>
- Permissions & APIs: <https://support.google.com/googleplay/android-developer/answer/9888170>
- Payments: <https://support.google.com/googleplay/android-developer/answer/10281818>
- Ads policy: <https://support.google.com/googleplay/android-developer/answer/9857753>
- Families: <https://support.google.com/googleplay/android-developer/answer/9893335>
- Developer verification: <https://support.google.com/googleplay/android-developer/answer/14151465>
