# Yayınlama rehberi (Android / Google Play)

Bu belge, EzanAI'nin imzalı sürümünü üretmek, arka uç servislerini bağlamak ve
Play Console'da yayınlamak için gereken tüm adımları içerir.

---

## 1. Sürüm numarası

`pubspec.yaml`:

```yaml
version: 1.0.0+1     # versionName+versionCode
```

Her mağaza yüklemesinde `build` numarası **artırılmalıdır**. Öneri: etiketli sürüm
(`v1.0.0`) + CI'da `--build-number=${{ github.run_number }}`.

## 2. İmzalama anahtarı

Anahtar deposu ve parolalar **depoya girmez** (`.gitignore` içindedir).

```bash
keytool -genkeypair -v -keystore ~/ezanai-upload.jks \
  -alias ezanai -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=EzanAI, OU=YazilimCeosu, O=YazilimCeosu, L=Istanbul, C=TR"
```

Ardından `android/key.properties` dosyasını oluşturun (örnek: `android/key.properties.example`):

```properties
storePassword=***
keyPassword=***
keyAlias=ezanai
storeFile=/absolute/yol/ezanai-upload.jks
```

`android/app/build.gradle.kts` bu dosya varsa `release` imzasını otomatik kullanır;
yoksa hata ayıklama anahtarıyla derler (yerel test için). **Play'e yüklenen ilk
sürümden sonra anahtarı kaybetmeyin**; Play App Signing kullanıyorsanız yükleme
anahtarını Play Console > Kurulum > Uygulama imzalama bölümünden yönetin.

## 3. Derleme zamanı yapılandırması

Tüm sırlar `--dart-define` veya `--dart-define-from-file` ile verilir; koda gömülmez.

`config/release.json` (depoya girmez):

```json
{
  "EZANAI_API_BASE": "https://api.ezanai.app",
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_...",
  "FIREBASE_ENABLED": true,
  "ILAHI_CATALOG_URL": "https://api.ezanai.app/ilahi/katalog.json",
  "ADMOB_BANNER_ID": "ca-app-pub-XXXX/YYYY",
  "ADMOB_INTERSTITIAL_ID": "ca-app-pub-XXXX/ZZZZ"
}
```

```bash
flutter build appbundle --release \
  --dart-define-from-file=config/release.json
# Çıktı: build/app/outputs/bundle/release/app-release.aab
```

Hata ayıklama derlemesi (reklamsız, daha hızlı):

```bash
flutter build apk --debug
```

## 4. Firebase (FCM + Crashlytics + Analytics)

1. Firebase konsolunda `com.yazilimceosu.ezanai` (ve test için
   `com.yazilimceosu.ezanai.debug`) Android uygulamasını ekleyin.
2. `google-services.json` dosyasını `android/app/` altına koyun (depoya girmez).
3. `FIREBASE_ENABLED=true` ile derleyin. Dosya yoksa Gradle eklentisi uygulanmaz ve
   uygulama **Firebase olmadan** çalışır; yalnızca uzak bildirimler devre dışı kalır.
4. Duyuru konuları (`PushService.subscribe`): `kandil_gecesi`, `cuma_hatirlatma`,
   `ramazan_duyuru`. Konulara abone olma kullanıcı tercihine bağlıdır.

Zamanlanmış vakit bildirimleri tamamen **yereldir** (`flutter_local_notifications`);
FCM yapılandırılmadığında bile ezan/vakit bildirimleri çalışır.

## 5. Supabase (bulut yedekleme)

1. Yeni proje → Settings > API: `Project URL` ve `publishable/anon` anahtarını alın.
2. Authentication > Providers: **Anonymous sign-in** etkinleştirin.
3. SQL Editor'da şemayı oluşturun (`supabase/schema.sql`):

```sql
create table if not exists public.user_data (
  user_id uuid primary key references auth.users (id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_data enable row level security;

create policy "kendi satiri okunur" on public.user_data
  for select using (auth.uid() = user_id);

create policy "kendi satiri yazilir" on public.user_data
  for insert with check (auth.uid() = user_id);

create policy "kendi satiri guncellenir" on public.user_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "kendi satiri silinir" on public.user_data
  for delete using (auth.uid() = user_id);
```

4. Uygulama anonim oturum açar; e-posta/ad/telefon istenmez. Yedek yükleme ve geri
   yükleme yalnızca kullanıcı istediğinde çalışır.

## 6. Google Play Billing (Premium)

Play Console > Para kazanma > Abonelikler:

| Ürün kimliği | Tür | Öneri |
|---|---|---|
| `ezanai_premium_monthly` | Abonelik | Aylık |
| `ezanai_premium_yearly` | Abonelik | Yıllık (indirimli) |
| `ezanai_premium_lifetime` | Tek seferlik ürün | Ömür boyu |

Kimlikler `AppConfig` içinde tanımlıdır; değiştirirseniz kodu güncelleyin.
Test: Play Console > Lisans testi kullanıcıları listesine Google hesabınızı ekleyin,
Play Store'dan iç uygulama paylaşımı bağlantısıyla test edin.

## 7. AdMob

- Ücretsiz sürümde banner/geçiş/rewarded birim kimlikleri `ADMOB_*` ile verilir.
- Premium kullanıcılarda reklam **hiç yüklenmez** (`AdsService.setPremium`).
- Yayın öncesi test birim kimlikleriyle doğrulayın; `ca-app-pub-3940256099942544/*`
  Google'ın resmî test kimlikleridir.

## 8. Ses içerikleri ve lisanslar

- Ezan tonları/melodi `tools/design/make_sounds.py` ile **proje içinde üretilir**
  (özgün, telifsiz) ve `android/app/src/main/res/raw/` altında paketlenir.
- Kur'an tilavet bağlantıları EveryAyah açık arşivine aittir; katalog yalnızca bu
  arşivin kendi CDN adreslerini kullanır.
- İlahi katalog **uzaktan** beslenir (`ILAHI_CATALOG_URL`); katalogda her parça için
  `license` alanı zorunludur ve lisans bilgisi olmayan parçalar arayüzde gösterilmez.
- Yeni içerik eklemeden önce `docs/DATA_SOURCES.md` içindeki lisansa uygunluğu
  doğrulayın.

## 9. Yayın öncesi kontrol listesi

- [ ] `flutter analyze` → 0 sorun
- [ ] `flutter test` → tümü geçiyor
- [ ] `flutter build appbundle --release` başarılı, `.aab` imzalı
- [ ] Sürüm numarası artırıldı (`versionName` + `versionCode`)
- [ ] `config/release.json` içindeki tüm değerler üretim değerleri
- [ ] `google-services.json` doğru pakete ait, `FIREBASE_ENABLED=true`
- [ ] Supabase şeması + RLS politikaları uygulandı, anonim giriş açık
- [ ] Play Billing ürünleri oluşturuldu ve test kullanıcıları tanımlı
- [ ] AdMob birim kimlikleri üretim değerleri (test kimliği değil)
- [ ] Gizlilik politikası URL'si Play Console'a girildi (`docs/PRIVACY.md` web'e yüklendi)
- [ ] Veri güvenliği formu `docs/PLAY_STORE.md` §5 ile eşleşiyor
- [ ] Ekran görüntüleri güncel sürümden alındı
- [ ] Gerçek cihazda: vakit bildirimi, ezan sesi, arka planda Kur'an, kıble kalibrasyonu
- [ ] Çevrimdışı testi: uçak modunda ana ekran, vakitler, Kur'an, hadis, tesbih
- [ ] Düşük RAM'li cihazda açılış süresi < 3 sn ve çökme yok

## 10. Yayınlama akışı

1. `main` dalından sürüm dalı oluşturun, testleri ve kontrol listesini tamamlayın.
2. `.aab` dosyasını Play Console > Üretim > Yeni sürüm ile yükleyin.
3. Aşamalı yayın: %20 → %50 → %100 (çökme oranı ve ANR verileri izlenir).
4. Sorun çıkarsa Play Console > Sürümleri durdur ile geri dönün.
5. Sürüm notlarını `docs/PLAY_STORE.md` §7 şablonuyla yazın.

## 11. Sürüm sonrası izleme

- Play Console > Android vitals: ANR/çökme oranı %1'in altında kalmalı.
- Firebase Crashlytics: yeni çökme grupları günlük kontrol edilir.
- Supabase: `user_data` tablosu boyutu ve yedek yükleme hataları izlenir.
- AI asistanı: cevap üretilemeyen istekler için hata mesajı ve yerel bilgi tabanına
  düşme davranışı doğrulanır.
