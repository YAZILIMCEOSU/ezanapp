# EzanAI — Akıllı İslam Asistanı

Namaz vakitleri, ezan, kıble, Kur'an, ilahi, tesbih, hadis, Ramazan ve yapay zekâ
destekli İslami soru-cevap özelliklerini tek uygulamada birleştiren, çevrimdışı
çalışabilen bir Müslüman yaşam asistanı.

- **Platform:** Flutter (Android öncelikli, iOS'a taşınabilir mimari)
- **Uygulama kimliği:** `com.yazilimceosu.ezanai`
- **Dil:** Türkçe arayüz, Türkçe içerik (Kur'an meali, hadis, dua, zikir)
- **Paket adı:** `ezanai`

---

## 1. Özellikler

| Modül | Öne çıkanlar |
|---|---|
| **Ana sayfa** | Konuma göre güncel vakitler, sonraki namaza canlı geri sayım, günün ayeti/hadisi, günlük zikir özeti, hızlı erişim (Kıble, Kur'an, Tesbih) |
| **Vakitler** | Diyanet yöntemi (imsak 18°, yatsı 17°, temkin düzeltmeleri), 118 ülke / 4.917 şehir + 81 il / 864 ilçe, otomatik GPS veya manuel şehir, 13 farklı hesap yöntemi, yaz/kış saati, hicri takvim, günlük–haftalık–aylık tablo, vakit bazlı manuel düzeltme |
| **Ezan ve bildirimler** | Her vakit için ayrı bildirim, ezan sesi seçimi (dahili tonlar + melodi), önceden hatırlatma, sessiz/uyku modu, Cuma bildirimi, Ramazan sahur/iftar hatırlatması, uygulama içi ezan okuma |
| **Kıble** | Manyetometre + ivmeölçer füzyonu, Mekke açısı, kalibrasyon uyarısı ve doğruluk göstergesi, haritada Kâbe yönü, mesafe bilgisi |
| **Kur'an** | 114 surenin tamamı gömülü (Arapça + Türkçe meal), ayet bazlı arama, favoriler, son okunan ayet ve geçmiş, gece modu, yazı boyutu, ayet paylaşma, 8 okuyucuyla sesli tilavet ve indirilebilir sure sesleri |
| **İlahi / dini ses** | Kategori–sanatçı–albüm filtreleri, favoriler, son dinlenenler, çalma listeleri, arka planda ve ekran kapalıyken oynatma, indirip çevrimdışı dinleme, cihazdan dosya ekleme, **yalnızca lisans bilgisi bulunan içerik** |
| **Tesbih / zikir** | Dokunsal geri bildirim, ses, hedef belirleme, günlük hedef, otomatik ilerleme, geçmiş ve istatistik grafikleri, özel zikir tanımlama |
| **Hadis** | Günün hadisi, konu kategorileri, metin arama, favoriler, kaynak künyesi (kitap/hadis no) ve paylaşım |
| **Ramazan** | Sahur/iftar geri sayımı, imsakiye, günlük dua, hatim takibi, zikir takibi, kaza orucu takibi, Ramazan bildirimleri |
| **AI İslam Asistanı** | Doğal dil soru-cevap; cevaplar Kur'an, sahih hadis ve güvenilir fıkıh kaynaklarına dayandırılır, mezhep farklılıkları ayrıca belirtilir, **kesin hüküm vermez** ve tereddütte müftülüğe yönlendirir |
| **Freemium** | Ücretsiz: vakitler, kıble, Kur'an, tesbih, temel içerik (reklamlı). Premium: reklamsız, sınırsız AI, premium ilahi, gelişmiş istatistik, bulut yedekleme |

## 2. Mimari

```
lib/
├── main.dart                 # Üretim girişi: hata yakalama, arka plan ses, ProviderScope
├── app/                      # Kök widget + servis konteyneri (AppRuntime)
├── core/
│   ├── config/               # Derleme zamanı yapılandırma (AppConfig)
│   ├── constants/            # Anahtarlar, kanal kimlikleri, PrefKeys
│   ├── db/                   # SQLite şeması (23 tablo, v1)
│   ├── services/             # Konum, pusula, bildirim, ses, faturalandırma, reklam, FCM, senkron
│   ├── audio/                # just_audio sarmalayıcı (ezan, tilavet, ilahi)
│   ├── errors/               # Result<T> / AppException
│   └── utils/                # Zaman, coğrafya, metin normalizasyonu, günlükleyici
├── data/
│   ├── models/               # Veri modelleri
│   ├── prayer/               # Vakit kaynakları: Diyanet → Aladhan → yerel hesap + önbellek
│   ├── repositories/         # Kur'an, hadis, zikir, ilahi, ramazan, AI, şehir
│   ├── hijri/                # Ümmü'l-Kurâ hicri takvim dönüştürücü
│   └── ai/                   # Yerel bilgi tabanı + AI servis katmanı
├── design/                   # Renkler, boşluklar, tema (AMOLED koyu + açık)
├── features/                 # Ekranlar (home, prayers, qibla, quran, ilahi, hadis, zikir, ramazan, ai, settings, more)
├── router/                   # go_router yapılandırması (bildirim ve derin bağlantı yönlendirmeleri)
└── state/                    # Riverpod sağlayıcıları ve denetleyiciler
```

### Vakit verisi akışı (API çökse bile çalışır)

```
bellek önbelleği → SQLite (prayer_times_cache, 6 saat TTL)
   → Diyanet resmî verisi → Aladhan (method 13, school 1)
      → yerel astronomik hesap (Diyanet parametreleri + temkin)
```

Her yanıt `source` etiketiyle (`diyanet | aladhan | calculation | cache`) saklanır ve
arayüzde gösterilir. İnternet yoksa vakitler cihazda hesaplanır; uygulama hiçbir
durumda vakit gösteremez hâle gelmez.

### Durum yönetimi

Riverpod 3 (`NotifierProvider`, `AsyncNotifierProvider`, `FutureProvider.family`).
Tüm servisler `AppRuntime` üzerinden tek bir konteynerde toplanır ve `ProviderScope`
override'ı ile arayüze verilir.

## 3. Kurulum

```bash
git clone https://github.com/YAZILIMCEOSU/ezanapp.git
cd ezanapp
flutter pub get
flutter run --dart-define=EZANAI_API_BASE=https://api.ezanai.app
```

### Derleme zamanı değişkenleri

Tümü isteğe bağlıdır; verilmezse ilgili özellik "yapılandırılmadı" durumunu gösterir
ve uygulamanın kalanı çalışmaya devam eder.

| Değişken | Açıklama |
|---|---|
| `EZANAI_API_BASE` | Kendi backend adresi (AI asistan, ilahi katalogu) |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Bulut yedekleme (anonim oturum + RLS) |
| `FIREBASE_ENABLED` | `true` ise FCM köprüsü etkinleşir (`google-services.json` gerekir) |
| `ILAHI_CATALOG_URL` | Lisanslı ilahi katalogu uç noktası |
| `ADMOB_BANNER_ID`, `ADMOB_INTERSTITIAL_ID`, `ADMOB_REWARDED_ID` | AdMob birim kimlikleri (boşsa reklam yok) |

> **Güvenlik:** Hiçbir API anahtarı uygulamaya gömülmez. AI, katalog ve senkron
> istekleri backend üzerinden yapılır; Supabase anon anahtarı yalnızca satır düzeyi
> güvenlik (RLS) ile sınırlandırılmış erişim için kullanılır.

## 4. Veri varlıkları

Gömülü içerik `assets/data/` altındadır (toplam ~8,8 MB) ve uygulama ilk açılışta
internet gerektirmez:

| Dosya | İçerik |
|---|---|
| `quran/{1..114}.json` | Arapça metin + Türkçe meal (ayet ayet) |
| `surah_meta.json` | Sure künyeleri, cüz başlangıçları, okuyucu listesi, kaynak künyeleri |
| `hadith_riyazus_salihin.json` | Hadis metinleri (Arapça + Türkçe) ve kaynak künyeleri |
| `adhkar/adhkar.json` | Zikir ve dualar (Arapça, okunuş, anlam, kaynak) |
| `cities_turkey.json`, `cities_world.json` | Şehir/ilçe ve koordinat verisi |
| `hijri_ummalqura.json` | Hicri takvim (Ümmü'l-Kurâ, 1343–1500 H) |
| `diyanet_validation_sample.json` | Resmî vakit doğrulama fikstürü (11 il × 6 tarih) |

Ham kaynakların nasıl indirildiği ve varlıkların nasıl üretildiği:
[`tools/data/README.md`](tools/data/README.md) · Lisanslar: [`docs/DATA_SOURCES.md`](docs/DATA_SOURCES.md)

## 5. Test ve doğrulama

```bash
flutter analyze          # 0 sorun hedefi
flutter test             # birim + veri doğrulama testleri
flutter build apk --debug
```

- `test/prayer_calculation_test.dart` — yerel hesap motoru, Diyanet'in resmî
  vakitleriyle karşılaştırılır (330 ölçüm, ortalama sapma ~0,8 dk, en büyük 2,3 dk).
- `test/data/models_test.dart` — ayarlar, hesap yöntemleri, coğrafya, hicri takvim,
  vakit modeli.
- `test/core/text_normalizer_test.dart` — Türkçe/arapça metin normalizasyonu ve
  zaman biçimlendirme.

CI (`.github/workflows/analyze.yml`) her push'ta `dart fix` + `dart format`,
`flutter analyze`, `flutter test` ve `flutter build apk --debug` çalıştırır; sonucu
`.ci/report.md` dosyasına yazar.

Vakit kalibrasyonu yeniden üretilebilir:

```bash
python3 tools/data/fetch_official_times.py     # resmî vakit örneklemi
python3 tools/data/calibrate_diyanet.py        # temkin değerlerini fit eder
```

## 6. Yayınlama

- İmzalama, `google-services.json`, Play Console kurulumu: [`docs/RELEASE.md`](docs/RELEASE.md)
- Mağaza metinleri ve görsel listesi: [`docs/PLAY_STORE.md`](docs/PLAY_STORE.md)
- Gizlilik politikası: [`docs/PRIVACY.md`](docs/PRIVACY.md)
- Veri kaynakları ve lisanslar: [`docs/DATA_SOURCES.md`](docs/DATA_SOURCES.md)

## 7. İlkeler

1. **Çalışmayan özellik yok.** Her ekran gerçek veriye ve gerçek navigasyona bağlıdır;
   yapılandırılmamış servisler kullanıcıya açıkça bildirilir.
2. **Çevrimdışı öncelikli.** Vakitler, Kur'an, hadis, zikir ve hicri takvim internetsiz
   çalışır; ağ hataları uygulamayı durdurmaz.
3. **Kaynak gösterimi.** Hadis ve fıkıh içerikleri kaynak künyesiyle sunulur.
4. **Dini sorumluluk.** AI asistanı kesin hüküm vermez; mezhep farklarını belirtir ve
   ehil mercilere yönlendirir.
5. **Telif duyarlılığı.** Yalnızca lisansı/izni belgelenmiş içerik kullanılır.
6. **Gizlilik.** Konum ve kişisel veriler cihazda kalır; anahtarlar uygulamaya gömülmez.
