# Ezan Vaktim Pro — Uyum İçin Teknik Düzeltme Planı

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Amaç:** Hukuki metinlerdeki beyanları kodla **birebir** uyumlu hâle getirmek.
**Durum:** Bu turda uygulananlar ✅, kalanlar ⏳.

## 1. Bu turda uygulanan düzeltmeler

| # | Dosya | Değişiklik | Gerekçe | Durum |
|---|---|---|---|---|
| 1 | `lib/core/constants/app_constants.dart` | Yasal URL’ler GitHub Pages’e bağlandı; KVKK, rıza, silme, abonelik, güvenlik URL’leri eklendi | Kırık `ezanai.app` linkleri (mağaza reddi 2.1) | ✅ |
| 2 | `lib/core/config/app_config.dart` | Yeni URL getter’ları | Uygulama içi erişim | ✅ |
| 3 | `lib/features/settings/about_screen.dart` | KVKK, açık rıza, abonelik, silme, güvenlik bağlantıları; konum/analitik metni düzeltildi | Gizlilik metni-kod çelişkisi | ✅ |
| 4 | `lib/data/models/app_settings.dart` | Analitik/çökme varsayılanı **false** | PRIVACY “varsayılan kapalı” beyanı | ✅ |
| 5 | `lib/data/models/app_settings.dart` | Ezan sesi adları “Vokal Sentez” | Gerçek müezzin adı/yanıltıcı beyan | ✅ |
| 6 | `lib/features/settings/adhan_sound_screen.dart` | “Gerçek kayıt” metni kaldırıldı | Aynı | ✅ |
| 7 | `lib/data/repositories/ilahi_repository.dart` | Sahte sanatçı adları kaldırıldı; `cdn.jsdelivr.net` kayıtları çıkarıldı | Telif + kişilik hakkı | ✅ |
| 8 | `lib/data/prayer/aladhan_api_source.dart` | Koordinat 2 ondalığa yuvarlandı | KVKK veri minimizasyonu | ✅ |
| 9 | `lib/data/ai/ai_service.dart`, `ai_repository.dart` | `allowRemote` bayrağı; varsayılan **false** (repo) | Rızasız uzak AI’yı engelleme | ✅ |
| 10 | `lib/state/content_providers.dart` | AI çağrısı rıza kaydına bağlandı | KVKK m.6/2 | ✅ |
| 11 | `lib/features/ai/ai_screen.dart` | İlk uzak soruda açık rıza diyaloğu | Aydınlatma + rıza | ✅ |
| 12 | `lib/state/providers.dart` | Rıza verme/geri çekme + zaman damgası | Kanıt ve geri çekme | ✅ |
| 13 | `lib/features/settings/backup_screen.dart` | Yedekleme/geri yükleme rıza kapısı + rıza anahtarı | KVKK m.9 | ✅ |
| 13b | `lib/core/services/sync_service.dart` | Servis katmanında rıza kontrolü (UI atlansa bile veri gönderilmez) | Savunma derinliği | ✅ |
| 14 | `lib/features/settings/settings_screen.dart` | “Açık rızalarım” yönetim diyaloğu | Geri çekme hakkı | ✅ |
| 15 | `docs/legal/*` + `docs/*.html` | Belgeler ve yayın sayfaları | Mağaza/mevzuat | ✅ |

> **Not:** Flutter SDK bu ortamda yok; `flutter analyze`/`test` CI’da
> çalıştırılır. Bu değişiklikler push sonrası ilk CI turunda doğrulanmalıdır.

## 2. Kalan işler (yayın öncesi zorunlu)

| # | İş | Dosya/Alan | Öncelik | Kabul ölçütü |
|---|---|---|---|---|
| 1 | ~~`ezan_saba.mp3` kaynağını belgele veya değiştir~~ **Yapıldı:** lisans kanıtı olmadığı için kaldırıldı | `assets/audio/adhan/` | **P0** | Dosya ve enum kaldırıldı; testler güncellendi |
| 2 | EveryAyah ticari kullanım teyidi | `docs/DATA_SOURCES.md`, tilavet | **P1** | Yazılı izin veya alternatif kaynak |
| 3 | GitHub Pages’i aç | GitHub Settings → Pages | **P0** | Tüm yasal URL’ler 200 |
| 4 | `USE_EXACT_ALARM` kararı | `AndroidManifest.xml`, Play beyanı | **P1** | Beyan onayı veya izin kaldırma |
| 5 | `ios/` projesi + PrivacyInfo | `ios/` | **P1** | App Store ön koşulu |
| 6 | Target API 36 doğrulaması | `android/app/build.gradle.kts` | **P0** | `aapt2 dump badging` |
| 7 | 16 KB sayfa boyutu | CI | **P1** | `zipalign -c -P 16` |
| 8 | Supabase RLS testi | Supabase | **P0** | Çapraz kullanıcı erişimi reddedilir |
| 9 | Yurt dışı aktarım sözleşmeleri | Hukuk | **P0** | İmzalı SCC + 5 iş günü bildirim |
| 10 | MP3 ID3 lisans etiketleri | Ses dosyaları | **P2** | `mutagen` ile doğrulama |
| 11 | Mağaza metinlerini güncelle | Play/App Store | **P0** | “Gerçek müezzin” yok |
| 12 | Fiyat tek kaynak | Dokümanlar + Console | **P0** | ₺79,99 / ₺599,99 / ₺1.499,99 |

## 3. Fiyat tutarlılığı

**Tek doğru kaynak:** `FREE_REKLAMLI_PAKET_VE_PREMIUM_REHBERI.md`

| Ürün | Kimlik | Fiyat |
|---|---|---|
| Aylık | `ezanai_premium_monthly` | ₺79,99 |
| Yıllık | `ezanai_premium_yearly` | ₺599,99 |
| Ömürlük | `ezanai_premium_lifetime` | ₺1.499,99 |

`PREMIUM_VE_ENTEGRASYON_YOL_HARITASI.md` bu değerlere göre düzeltilmeli;
Play Console/App Store Connect fiyatları da aynı olmalı. Yerel mağaza fiyatı
satın alma ekranında gösterilir.

## 4. Test planı

### 4.1. Birim testleri (CI)

- [ ] `AppSettings` varsayılanları: analitik/çökme **false**
- [ ] `askWithQuota(allowRemote: false)` → `AiAnswerMode.offline`
- [ ] `askWithQuota(allowRemote: true)` + backend yok → offline
- [ ] AlAdhan URI’sinde koordinat 2 ondalık
- [ ] Rıza anahtarları: ver/geri çek (prefs)

### 4.2. Widget testleri

- [ ] AI ilk soruda rıza diyaloğu gösterir
- [ ] “Rıza vermeden devam et” → offline yanıt
- [ ] Yedekleme rıza yokken buton uyarı verir
- [ ] “Açık rızalarım” diyaloğu durum değiştirir

### 4.3. Elle test (cihaz)

1. Temiz kurulum → Ayarlar → analitik/çökme **kapalı**.
2. AI’da ilk soru → rıza diyaloğu → reddet → cevap çevrimdışı.
3. Rıza ver → soru sunucuya gider; Ayarlar → rızalar → geri çek.
4. Bulut yedekleme → rıza yok → uyarı; rıza ver → yüklenir.
5. Sunucudaki yedeği sil → tekrar giriş → veri yok.
6. Hakkında → tüm yasal bağlantılar açılır.
7. Ezan sesi ekranı → “Vokal Sentez” etiketleri; “gerçek müezzin” yok.
8. İlahi kataloğu → uzak jsDelivr parçası yok.

## 5. CI kapıları

```bash
flutter analyze
flutter test --reporter expanded
python3 tools/verify_qibla.py
bash tools/quality_gate.sh
```

Ek olarak önerilen:

```bash
# Yasal URL kontrolü (Pages açıldıktan sonra)
for p in privacy terms kvkk acik-riza abonelik veri-silme guvenlik; do
  curl -fsS -o /dev/null -w "$p %{http_code}\n" \
    "https://yazilimceosu.github.io/ezanapp/$p.html"
done
```

## 6. Geri alma

- URL değişikliği: `--dart-define=PRIVACY_URL=...` ile eski adres.
- AI rıza kapısı: `allowRemote` varsayılanı değiştirilmeden yalnızca UI
  kapatılabilir; **güvenlik nedeniyle varsayılan false kalmalıdır**.
- Ses kataloğu: kaldırılan parçalar geri eklenmez; lisans kanıtı olmadan
  yayınlanmaz.

## 7. Sorumluluk

| Alan | Sorumlu | Tarih |
|---|---|---|
| Kod | Geliştirici | 12 Kasım 2026 |
| Hukuk | Avukat (gözden geçirme) | Yayın öncesi |
| Mağaza | Geliştirici | Yayın öncesi |
