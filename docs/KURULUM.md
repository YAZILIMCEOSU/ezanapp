# Bugün ilerleme planı — koddan Play Store'a

Bu belge, **kod tarafı bittiği noktadan** (CI tamamen yeşil) itibaren yapılacakları
sıraya koyar. Her adımın **sorumlusu** ve **tahmini süresi** yazar.

> Durum özeti: `.ci/report.md` → 7/7 adım `success` (analyze, 166 test, uzak AI
> sözleşmesi, debug APK, release AAB). Yani "uygulama çalışıyor mu?" sorusu
> otomatik olarak yanıtlanmış durumda. Kalan işler **hesap, anahtar ve cihaz**
> işidir; bunlar bu depodan yapılamaz.

## 0. Nerede duruyoruz?

| Parça | Durum | Kanıt / not |
|---|---|---|
| Kod, testler, derleme | ✅ bitti | `.ci/report.md`: 7/7 success |
| Cihazda çalışan APK | ✅ hazır | Actions → Artifacts → `ezanai-derlemeleri` (`app-debug.apk`) |
| Yükleme (upload) anahtarı | ❌ sende | `android/key.properties` + `.jks` (bu depoya girmez) |
| Firebase (FCM/Crashlytics) | ❌ sende | `google-services.json` yoksa uygulama **Firebase'siz** çalışır |
| Play Console kaydı + mağaza metinleri | ❌ sende | Metinler hazır: `docs/PLAY_STORE.md` |
| Mağaza görselleri | 🟡 kısmi | Simge + öne çıkan görsel `store/` içinde; **ekran görüntüleri sende** |
| 12 kullanıcı × 14 gün kapalı test | ⏳ takvim | Kişisel hesaplarda zorunlu (bkz. §5) |

## 1. Kritik yol (tek bakışta)

| # | İş | Sorumlu | Süre | Bitti mi? |
|---|---|---|---|---|
| 1 | Debug APK'yı telefona kur, uygulamayı gez | sen | 15 dk | ☐ |
| 2 | `docs/PHASES.md` §4 cihaz kontrol listesi (12 madde) | sen | 1–2 saat | ☐ |
| 3 | Yükleme anahtarı oluştur + `key.properties` (§2) | sen | 10 dk | ☐ |
| 4 | Firebase projesi + `google-services.json` (bildirim/Crashlytics için) | sen | 30 dk | ☐ |
| 5 | Kendi anahtarınla release AAB derle (§3) | sen | 10 dk | ☐ |
| 6 | Play Console: uygulama kaydı, mağaza metni/görselleri, veri güvenliği | sen | 2–4 saat | ☐ |
| 7 | **Dahili test** kanalına AAB yükle, kendi telefonunda doğrula | sen | 1 saat | ☐ |
| 8 | **Kapalı test** başlat (≥12 kullanıcı) — sayaç burada başlar | sen + 12 kişi | 1 gün kurulum | ☐ |
| 9 | 14 gün aralıksız kapalı test | 12 kullanıcı | **14 gün** | ☐ |
| 10 | Üretim erişimi başvurusu + inceleme | Google | ≤7 gün | ☐ |
| 11 | Üretime yayın | Google | ≤7 gün | ☐ |

**En erken Play Store tarihi:** kapalı testi bugün başlatsan ~3 hafta.
**En erken telefonda görme tarihi:** bugün (adım 1).

## 2. Yükleme anahtarı (10 dakika)

```bash
# 1) Anahtarı üret (parolaları bir parola yöneticisine kaydet!)
keytool -genkeypair -v -keystore ~/ezanai-upload.jks \
  -alias ezanai -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=EzanAI, OU=YazilimCeosu, O=YazilimCeosu, L=Istanbul, C=TR"

# 2) Yapılandırmayı oluştur
cp android/key.properties.example android/key.properties
# dosyayı aç ve doldur: storePassword, keyPassword, keyAlias, storeFile (mutlak yol)

# 3) Doğrula
flutter build appbundle --release     # → build/app/outputs/bundle/release/app-release.aab
```

⚠️ **Bu anahtarı kaybetme.** Play App Signing kullanıyorsan (önerilir) Play,
yayın anahtarını kendisi yönetir; senin anahtarın yalnızca "yükleme anahtarı"
olur. Kaybolursa Play Console'dan sıfırlama talep edilir.

⚠️ CI'ın ürettiği `app-release.aab` **tek kullanımlık deneme anahtarıyla**
imzalanır — Play'e yüklemeyin, sadece derlemenin çalıştığının kanıtıdır.

## 3. Firebase (30 dakika, atlanabilir)

Gerekli **değil**, ama FCM/Crashlytics/Analytics için:

1. Firebase konsolu → yeni proje → Android uygulaması ekle:
   `com.yazilimceosu.ezanai` (test için ayrıca `com.yazilimceosu.ezanai.debug`).
2. `google-services.json` dosyasını `android/app/` altına koy (depoya girmez).
3. `config/release.json` içinde `"FIREBASE_ENABLED": true` ile derle.

Dosya yoksa Gradle eklentisi hiç uygulanmaz; **yerel vakit bildirimleri
çalışmaya devam eder**, yalnızca uzak duyuru bildirimleri devre dışı kalır.

## 4. Play Console kaydı (2–4 saat)

1. [Play Console](https://play.google.com/console) → hesap türü (kişisel/kurumsal).
2. **Uygulama oluştur:** ad `EzanAI`, dil Türkçe, ücretsiz, uygulama.
3. **Mağaza girişi:** `docs/PLAY_STORE.md` §1–3 metinlerini kopyala-yapıştır.
4. **Görseller:** `store/play_icon_512.png`, `store/play_feature_graphic_1024x500.png`
   hazır; **ekran görüntüleri** gerekli (en az 2, en fazla 8 telefon görseli).
   Uygulamayı cihazda açıp ana sayfa / vakitler / Kur'an / kıble / tesbih
   ekranlarından çek — kısa kenar ≥320 px, uzun kenar ≤3840 px.
5. **Uygulama içeriği:** veri güvenliği formu (`docs/PLAY_STORE.md` §5),
   içerik derecelendirmesi, reklam beyanı (uygulamada AdMob var),
   **gizlilik politikası URL'si** (metin: `docs/PRIVACY.md`).
6. **Abonelik ürünleri:** Play Console → Monetize → ürün kimlikleri
   `AppConfig` içindekilerle **birebir** olmalı (`docs/RELEASE.md` §6).
7. **Hedef API:** gerek yok — `targetSdk`, Flutter'ın güncel varsayılanıyla
   **36** olarak derleniyor (Play'in 2026 gereksinimini karşılar).

## 5. Kapalı test ve üretim erişimi

Kişisel geliştirici hesapları için (13 Kasım 2023 sonrası açılanlar) Google,
üretim erişiminden önce **en az 12 test kullanıcısının aralıksız 14 gün**
kapalı teste kayıtlı kalmasını şart koşar. Kurumsal hesaplar bu şartın dışındadır.

- Kullanıcıları **e-posta listesi** ya da **Google Grubu** ile ekle; en az 14–15
  kişi davet et (testi erken bırakan olursa sayaç sıfırlanmasın).
- Kullanıcılar Play'de "Katıl" bağlantısına tıklayıp uygulamayı **kurmalı**;
  yalnızca davet edilmek yetmez.
- Sayaç kesintisiz opt-in ile işler: bir kişi çıkıp yeniden katılırsa o kişi
  için 14 gün yeniden başlar.
- Play Console, koşullar sağlanınca **Dashboard → "Üretim erişimi için başvur"**
  düğmesini açar; başvuruda test süreci ve yapılan iyileştirmeler sorulur.

## 6. Sık yapılan hatalar

| Hata | Doğrusu |
|---|---|
| CI'ın AAB'sini Play'e yüklemek | Kendi anahtarınla derlediğin AAB'yi yükle |
| `key.properties`/`.jks` dosyasını depoya eklemek | `.gitignore`'da; asla commit etme |
| Aynı `versionCode` ile ikinci yükleme | Her yüklemede `pubspec.yaml` `+N` değerini artır |
| Kapalı testi mağaza metinleri hazır olmadan başlatmak | Play, testi başlatmadan önce mağaza girişini eksiksiz ister |
| Ekran görüntülerini sonraya bırakmak | Kapalı test başvurusu bunlarsız ilerlemez |
| `google-services.json` olmadan FCM beklemek | Yerel bildirimler çalışır; uzak bildirim için dosya şart |
