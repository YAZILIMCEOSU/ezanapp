# Apple App Store Uyum Dosyası — Ezan Vaktim Pro (iOS)

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Durum:** Depoda **iOS projesi yok** (`ios/` klasörü bulunmuyor). Bu dosya,
iOS sürümü hazırlanırken uygulanacak zorunlu gereksinimleri ve App Store
Connect beyanlarını tanımlar.

> Kaynaklar: App Store Review Guidelines, App Store Connect Help, Apple
> Privacy Manifest (PrivacyInfo.xcprivacy), Apple Developer Program License
> Agreement. Bağlantılar §10’da. Hukuki görüş değildir.

## 1. Yayın kimliği

| Alan | Değer |
|---|---|
| Bundle ID | `com.yazilimceosu.ezanai` (Play ile aynı olabilir; ayrı Apple ID) |
| SKU | `ezanai-ios-1` |
| Uygulama adı (30 karakter) | `Ezan Vaktim Pro: Ezan & Kıble` |
| Alt başlık | `Namaz vakti, kıble, Kur'an` |
| Kategori | Lifestyle (birincil), Reference (ikincil) |
| Yaş derecesi | 4+ (dinî içerik; şiddet/uygunsuz içerik yok) |
| Fiyat | Ücretsiz + IAP |
| Gizlilik URL’si | `.../privacy.html` (App Store Connect’te zorunlu) |
| Kullanım koşulları | `.../terms.html` (EULA) |
| Destek URL’si | `.../` |

## 2. Zorunlu App Store gereksinimleri

### 2.1. Gizlilik politikası (5.1.1(i))

- Uygulama içinde **ve** App Store Connect’te erişilebilir olmalı.
- Veri türleri, amaç, saklama, paylaşım ve silme açıklanmalı.
- Metin, Play Data safety ve App Privacy beyanıyla aynı olmalı.

### 2.2. Hesap ve veri silme (5.1.1(v))

Uygulama hesap oluşturmuyor; ancak kullanıcı verisini uygulama içinden
silebilmelidir. App Store Connect’te “veri silme” talebi için:

- Uygulama içi: Ayarlar → Verilerimi sil
- Web: `.../veri-silme.html`
- E-posta: destek@ezanai.app

### 2.3. App Privacy (nutrition label)

| Kategori | Veri | Bağlantılı mı? | İzleme (tracking)? | Amaç |
|---|---|---|---|---|
| Location | Coarse Location (cihazda) | Hayır | Hayır | App Functionality |
| Location | Coarse Location (~1 km, AlAdhan yedek) | Hayır | Hayır | App Functionality |
| Location | Coarse (AdMob IP) | Hayır | **Evet** (rıza ile) | Advertising |
| Identifiers | Device ID (IDFA) | Hayır | **Evet** (ATT izni ile) | Advertising |
| Identifiers | User ID (Supabase UUID) | Evet (anonim) | Hayır | App Functionality |
| User Content | Other User Content (AI soruları) | Hayır | Hayır | App Functionality |
| Usage Data | Advertising Data | Hayır | **Evet** | Advertising |
| Diagnostics | Crash Data | **Hayır** (SDK yok) | Hayır | — |
| Purchases | Purchase History | Evet | Hayır | App Functionality |

**Önemli:** ATT izni (`NSUserTrackingUsageDescription`) verilmezse veya
kullanıcı reddederse **IDFA okunamaz**; bu durumda “tracking: Hayır” beyanı
verilir ve reklamlar kişiselleştirilmez.

### 2.4. Privacy Manifest — `PrivacyInfo.xcprivacy`

Her uygulama ve üçüncü taraf SDK için zorunludur (ITMS-91053 reddi).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <true/> <!-- ATT izni verilirse; SDK/config ile kapatılabilir -->
  <key>NSPrivacyTrackingDomains</key>
  <array>
    <string>googleads.g.doubleclick.net</string>
    <string>googleadservices.com</string>
  </array>
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeCoarseLocation</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <true/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAdvertising</string></array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeDeviceID</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <true/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAdvertising</string></array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeOtherUserContent</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string></array>
    </dict>
  </array>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>C617.1</string></array>
    </dict>
  </array>
</dict>
</plist>
```

> Not: ATT izni verilmezse `NSPrivacyTracking=false` yapılmalı ve reklam SDK’sı
> IDFA okumayacak şekilde yapılandırılmalıdır.

### 2.5. Uygulama içi satın alma

- Dijital özellikler yalnızca **StoreKit IAP** ile satılır (3.1.1).
- Harici ödeme yönlendirmesi yok (3.1.3 istisnaları Türkiye’de geçerli
  değildir).
- Abonelik ekranında: ürün adı, süre, fiyat, otomatik yenileme, iptal yolu,
  gizlilik ve kullanım koşulları bağlantıları (3.1.2).
- “Restore Purchases” düğmesi zorunlu.
- Abonelik grubu: `ezanai_premium`; ürünler `monthly/yearly/lifetime`.

### 2.6. ATT (App Tracking Transparency)

- `NSUserTrackingUsageDescription`: “Reklamların ilgi alanlarınıza göre
  gösterilmesi için izin istenir. İzin vermezseniz kişiselleştirilmemiş reklam
  görürsünüz.”
- ATT istemi **uygulama açılışında değil**, reklam rızası bağlamında
  gösterilir.
- Reddedilirse `npa=1` ve IDFA kullanılmaz.

### 2.7. Bildirimler ve arka plan

- `UNUserNotificationCenter` izni; reddedilirse uygulama içi uyarı.
- Sesli ezan `AVAudioSession` `.playback` + `UIBackgroundModes: audio`.
- Ses, kullanıcı durdurmadıkça kesilmez; kilit ekranında kontroller.
- Kritik alarm (critical alerts) kullanılmaz; entitlement gerektirir ve dinî
  uygulama için uygun değildir.

### 2.8. Dinî içerik ve 1.1.6 / 5.2

- Yanıltıcı dinî iddia yok; “fetva” değil “bilgi”.
- Kaynak gösterimi görünür.
- Üçüncü taraf telifli ses/meal kullanılıyorsa lisans kanıtı saklanır.
- Kullanıcıya ait içerik bildirimi (AI yanıtı) uygulama içinde.

### 2.9. Kırık link ve çökme (2.1)

- Gizlilik, koşullar, destek URL’leri yayın öncesi **200** dönmeli.
- Uygulama açılışta çökmemeli; boş durumlar ele alınmalı.
- Demo/inceleme hesabı gerekmiyorsa “Sign-in required” işaretlenmez.

## 3. iOS teknik gereksinimleri

| Gereklilik | Uygulama |
|---|---|
| Minimum iOS | 15.0+ (Flutter 3.47 varsayılanı; cihaz dağılımına göre) |
| Xcode | 16+ / iOS 18 SDK |
| Mimari | arm64 |
| Privacy manifest | Eklenmeli |
| ATT | Eklenmeli |
| StoreKit 2 | Tercih edilir |
| App Groups | Yedekleme/dosya paylaşımı gerekiyorsa |
| Keychain | Anonim oturum jetonu için |
| Swift Package Manager / CocoaPods | Kilitli sürümler |
| App icon | 1024×1024, alfa yok |
| Ekran görüntüleri | 6.9", 6.5", 5.5", iPad (gerekliyse) |
| App preview | Opsiyonel |

## 4. App Store Connect beyan metinleri

**Promosyon metni:** “Namaz vakitleri, ezan, kıble, Kur’an ve kaynak gösteren
yapay zekâ asistanı. Reklamsız Premium seçeneği.”

**Açıklama (özet):** “Ezan Vaktim Pro, Diyanet yöntemiyle hesaplanan namaz
vakitleri, tam vaktinde ezan bildirimi, kıble, Kur’an-ı Kerim ve meal, ilahi,
tesbih, hadis ve kaynak gösteren AI asistanı sunar. Konumunuz cihazınızda
işlenir; tam koordinat sunucuya gönderilmez. Diyanet servisi kullanılamazsa
yaklaşık koordinat (2 ondalık, ~1 km) AlAdhan’a gönderilir. AI ve bulut
yedekleme isteğe bağlıdır ve ayrı rıza gerektirir.”

**Anahtar kelimeler:** ezan, namaz vakti, kıble, kuran, ilahi, tesbih, ramazan,
imsakiye, hadis

## 5. İnceleme notu (App Review Notes)

> Uygulama hesap gerektirmez. Tüm temel özellikler giriş yapmadan çalışır.
> AI asistanı ilk açılışta çevrimdışı bilgi tabanıyla yanıt verir; uzak AI
> için Ayarlar → Gizlilik ve rızalar üzerinden açık rıza gerekir. Premium
> ürünleri StoreKit ile sunulur; “Restore Purchases” mevcuttur. Reklamlar
> yalnızca ücretsiz sürümde ve kişiselleştirme varsayılan kapalı olarak
> gösterilir. Gizlilik: .../privacy.html, Koşullar: .../terms.html.

## 6. Red riskleri ve önlemler

| Risk | Guideline | Önlem |
|---|---|---|
| Kırık gizlilik linki | 5.1.1(i), 2.1 | Yayın öncesi 200 kontrolü + CI link testi |
| Eksik PrivacyInfo | ITMS-91053 | Manifest + SDK manifestleri |
| Hesap silme yok | 5.1.1(v) | Uygulama içi silme + web sayfası |
| Abonelik metni eksik | 3.1.2 | Fiyat/dönem/yenileme/iptal + linkler |
| IDFA izinsiz | 5.1.2 | ATT + NPA varsayılan |
| Dinî içerikte yanıltma | 1.1.6, 5.2 | “Fetva değildir” + kaynak |
| Telifli ses | 5.2 | Lisans kanıtı; yoksa değiştir |
| Yalnızca Android mantığı | 2.1 | iOS testi, çökme testi |

## 7. iOS yayın kontrol listesi

- [ ] `ios/` projesi oluşturuldu (`flutter create --platforms=ios .`)
- [ ] Bundle ID ve imza profili
- [ ] `PrivacyInfo.xcprivacy` eklendi
- [ ] ATT metni ve izni
- [ ] StoreKit ürünleri App Store Connect’te tanımlı
- [ ] Restore Purchases test edildi
- [ ] Gizlilik/koşullar/destek URL’leri 200
- [ ] Ekran görüntüleri (6.9"/6.5"/5.5")
- [ ] App Privacy beyanı §2.3 ile aynı
- [ ] TestFlight iç testi
- [ ] App Review Notes §5
- [ ] Yaş derecesi 4+
- [ ] Ses lisansları doğrulandı
- [ ] Türkçe + İngilizce yerelleştirme

## 8. Ortak metin kaynakları

- Gizlilik: [`KVKK_AYDINLATMA_METNI.md`](KVKK_AYDINLATMA_METNI.md)
- Koşullar: [`KULLANIM_KOSULLARI.md`](KULLANIM_KOSULLARI.md)
- Abonelik: [`ABONELIK_VE_IADE.md`](ABONELIK_VE_IADE.md)
- Silme: [`VERI_SILME_VE_BASVURU.md`](VERI_SILME_VE_BASVURU.md)
- SDK’lar: [`UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md`](UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md)

## 9. Uygulama içi bağlantılar (iOS)

- Hakkında → Gizlilik / KVKK / Kullanım koşulları / Abonelik koşulları
- Ayarlar → Gizlilik ve rızalar
- Ayarlar → Verilerimi sil
- Premium → “Aboneliği geri yükle” + “Aboneliği yönet”

## 10. Resmî kaynaklar

- App Store Review Guidelines: <https://developer.apple.com/app-store/review/guidelines/>
- App Privacy Details: <https://developer.apple.com/app-store/app-privacy-details/>
- Privacy manifest: <https://developer.apple.com/documentation/bundleresources/privacy_manifest_files>
- ATT: <https://developer.apple.com/documentation/apptrackingtransparency>
- Auto-renewable subscriptions: <https://developer.apple.com/app-store/subscriptions/>
- StoreKit: <https://developer.apple.com/storekit/>
