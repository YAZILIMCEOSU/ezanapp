# Veri hattı (ham kaynak → gömülü varlık)

Uygulamanın çevrimdışı çalışmasını sağlayan gömülü varlıklar (`assets/data/**`)
buradaki betiklerle üretilir. **Ham veriler depoda tutulmaz**
(`tools/data/raw/` klasörü `.gitignore` içindedir); aşağıdaki komutlarla yeniden
indirilir.

## Hızlı başlangıç

```bash
bash tools/data/fetch_sources.sh            # ham kaynakları indir
python3 tools/data/build_assets.py          # assets/data/** üret
python3 tools/data/calibrate_diyanet.py     # vakit kalibrasyonunu doğrula
flutter test                                 # doğrulama testleri
```

## Betikler

| Betik | Görev | Çıktı |
|---|---|---|
| `fetch_sources.sh` | Kur'an (Tanzil + QuranEnc), hadis (Riyâzü's-Sâlihîn), şehir verisi gibi ham JSON kaynaklarını GitHub üzerinden indirir | `tools/data/raw/*.json` |
| `build_assets.py` | Ham kaynakları uygulama biçimine dönüştürür: sure başına ayet dosyaları, hadis filtresi, şehir listeleri, hicri takvim, zikir metinleri | `assets/data/**` |
| `fetch_official_times.py` | Diyanet resmî vakitlerini açık API'den indirir (kalibrasyon/doğrulama verisi) | `tools/data/raw/official_diyanet_sample.json` |
| `calibrate_diyanet.py` | Resmî vakitlerle hesap motorunun temkin değerlerini en küçük kareler yöntemiyle fit eder | Konsol raporu + Dart kodu bloğu |
| `../design/make_icons.py` | Uygulama simgeleri ve mağaza görselleri | `android/.../mipmap-*/`, `store/` |
| `../design/make_sounds.py` | Ezan tonları ve bildirim sesleri (özgün, telifsiz) | `android/app/src/main/res/raw/`, `assets/audio/adhan/` |

## Gömülü varlıklar

| Varlık | Boyut | Kaynak |
|---|---|---|
| `assets/data/quran/{1..114}.json` | ~2,2 MB | Tanzil (Arapça) + QuranEnc (meal) |
| `assets/data/surah_meta.json` | 18 KB | Tanzil `chapters.json` + jüz tablosu |
| `assets/data/hadith_riyazus_salihin.json` | 2,8 MB | Riyâzü's-Sâlihîn açık veri kümesi |
| `assets/data/cities_turkey.json` | 79 KB | Diyanet ilçe kimlikleri + açık yer verisi |
| `assets/data/cities_world.json` | 293 KB | Aynı veri kümesinin uluslararası bölümü |
| `assets/data/adhkar/adhkar.json` | ~30 KB | Kur'an ve sahih hadis kaynaklı zikir/dualar |
| `assets/data/hijri_ummalqura.json` | 2 KB | Ümmü'l-Kurâ takvimi |
| `assets/data/diyanet_validation_sample.json` | 9,7 KB | Resmî vakitlerden türetilmiş doğrulama fikstürü |

## Namaz vakti kalibrasyonu

Yerel hesap motoru (`lib/data/prayer/prayer_calculator.dart`) Diyanet parametrelerini
(imsak 18°, yatsı 17°, ufuk −0,833°, ikindi gölge katsayısı 1) kullanır. Resmî
vakitlerle aradaki küçük fark, **temkin** adı verilen sabit dakika düzeltmeleriyle
kapatılır.

```bash
python3 tools/data/fetch_official_times.py --months 6      # veri topla
python3 tools/data/calibrate_diyanet.py                     # fit et + raporla
python3 tools/data/calibrate_diyanet.py --check              # koddaki değerlerle karşılaştır
```

Fit edilen değerler `Temkin.diyanet` sabitine yazılır; `flutter test` içindeki
`prayer_calculation_test.dart` bu değerlerle 330 ölçümü ±3 dakika toleransla
doğrular (güncel sapma: ortalama ~0,8 dk, en büyük 2,3 dk).

### İki bağımsız doğrulama

| Kaynak | Ölçüm | Sonuç |
|---|---|---|
| 11 il × 6 tarih resmî fikstür (`assets/data/diyanet_validation_sample.json`) | 330 vakit | Kod değerleriyle en büyük sapma **2,3 dk** (test bunu zorunlu kılar) |
| 81 il × ~460 gün resmî örneklem (37.379 kayıt) | 224.274 vakit | Fit **0 / −7 / +5 / +4 / +7 / 0**, koddaki değerlerle fark ≤ 1 dk |

Bu iki veri kümesi farklı yıllardan ve farklı coğrafi kapsamdan geldiği için
sonuçların örtüşmesi hesap motorunun doğruluğunu bağımsız olarak teyit eder.

### Bilinen veri kalitesi notu

Ham örneklemde **Kırıkkale** kayıtları (150 gün) diğer 80 ilin ortalamasından
~25 dk sapıyor; bu, örneklemin o il için hatalı eşlenmesinden kaynaklanır ve
uygulamayı etkilemez. `calibrate_diyanet.py` bu tür uç değerleri medyan
toleransıyla ayıklar ve raporlar.

> **Not:** `calibrate_diyanet.py`, Dart hesap motorunun birebir aynısını uygular.
> Formüllerde değişiklik yaparsanız betiği de güncelleyin; iki tarafın ayrışması
> kalibrasyonu geçersiz kılar.

## Lisanslar

Kaynakların lisansları ve atıf yükümlülükleri: [`../../docs/DATA_SOURCES.md`](../../docs/DATA_SOURCES.md)
