# Veri kaynakları, lisanslar ve atıf yükümlülükleri

EzanAI, dini metinleri ve coğrafi verileri **yalnızca lisansa uygun, açık kaynaklı
veya izinli** kaynaklardan alır. Bu belge hangi içeriğin nereden geldiğini, hangi
lisansa tabi olduğunu ve uygulamada nasıl atıf yapıldığını açıklar.

> Yeni bir veri kümesi eklemeden önce bu tabloyu güncelleyin ve lisans uygunluğunu
> doğrulayın. Telifli ses içerikleri (ilahi) yalnızca lisans bilgisi kayıtla birlikte
> tutulduğunda listelenir; `license` alanı boş olan parça arayüzde gösterilmez.

## 1. Kur'an-ı Kerim

| İçerik | Kaynak | Lisans / izin | Yükümlülük |
|---|---|---|---|
| Arapça metin (Uthmani) | [Tanzil.net](https://tanzil.net) — `risan/quran-json` üzerinden | Tanzil metni serbest dağıtım, **CC BY-ND** | Metin **değiştirilmeden** kullanılmalı; kaynak ve site adı belirtilmeli. Uygulamada "Arapça metin: Tanzil" olarak atıf yapılır. |
| Türkçe meal | [QuranEnc](https://quranenc.com) — `risan/quran-json` `quranenc/turkish_*.json` | Yayın izinli açık çeviri (QuranEnc kullanım koşulları) | Çevirmen ve kaynak künyesi korunur; metin değiştirilmez. |
| Sure künyeleri, cüz başlangıçları | Tanzil `chapters.json` | Aynı | Atıf korunur. |
| Tilavet (ayet/sure bazlı) | [EveryAyah.com](https://everyayah.com) açık arşivi | Arşiv kendi CDN'i üzerinden ücretsiz akış | Uygulama dosyaları yeniden dağıtmaz, arşivin adreslerini kullanır. |

İlgili dosyalar: `assets/data/quran/*.json`, `assets/data/surah_meta.json`
(içinde `sources` alanı bulunur). Üretim betiği: `tools/data/build_assets.py`.

## 2. Hadis

| İçerik | Kaynak | Lisans | Not |
|---|---|---|---|
| Riyâzü's-Sâlihîn (Arapça + Türkçe çeviri + künye) | `HasanEksi/Riyazus-Salihin-Veritabani-HadisKitaplari.com` | Açık veri kümesi (kaynakta yayımlanmış) | Her hadiste `ref` (kitap/hadis no) ve `src` alanı korunur; uygulama bu künyeleri gösterir. |

Dosya: `assets/data/hadith_riyazus_salihin.json` —
`{id, ar, tr, ref, src, topics[]}`.

## 3. Zikir ve dualar

Kur'an ayetleri ve sahih hadis kaynaklı zikir metinleri; Arapça metin, okunuş,
anlam ve **kaynak künyesi** birlikte verilir.
Dosya: `assets/data/adhkar/adhkar.json` —
`{key, name, arabic, transliteration, meaning, reference}`.

## 4. Namaz vakti verisi ve kalibrasyon

| Katman | Kaynak | Lisans / durum |
|---|---|---|
| Yerel hesap motoru | `lib/data/prayer/prayer_calculator.dart` — Diyanet parametreleri (imsak 18°, yatsı 17°, temkin) | Özgün kod (MIT benzeri proje lisansı) |
| Resmî vakit doğrulaması | T.C. Diyanet İşleri Başkanlığı resmî vakitleri (açık API: `ezanvakti.imsakiyem.com`) | Kamuya açık resmî vakit verisi; yalnızca **kalibrasyon ve doğrulama** için örneklem olarak kullanılır |
| Alternatif kaynak | [Aladhan API](https://aladhan.com/prayer-times-api) (method 13, school 1) | Ücretsiz API kullanım koşulları |
| Doğrulama fikstürü | `assets/data/diyanet_validation_sample.json` (11 il × 6 tarih) | Yukarıdaki resmî verilerden türetilmiş küçük örneklem |

Kalibrasyon yöntemi: 37.379 resmî kayıt üzerinde en küçük kareler fit'i
(`tools/data/calibrate_diyanet.py`). Elde edilen temkin değerleri kodda sabittir ve
testlerle korunur (ortalama sapma ~0,8 dk, en büyük 2,3 dk).

## 5. Şehir ve koordinat verisi

| İçerik | Kaynak | Not |
|---|---|---|
| Türkiye 81 il / 864 ilçe (Diyanet ilçe kimlikleri) | `furkantektas/EzanVaktiAPI` tabanlı açık yer veri kümesi | Kimlikler Diyanet ilçe numaralarıyla uyumludur |
| 118 ülke / 4.917 şehir | Aynı veri kümesinin uluslararası bölümü | Koordinatlar açık coğrafi verilerden |
| İlçe adları | `isubas/iller_ve_ilceler` (lisans: MIT) | Türkçe imla doğrulaması için karşılaştırma kaynağı |

Dosyalar: `assets/data/cities_turkey.json`, `assets/data/cities_world.json`.
Üretim: `tools/data/build_assets.py`.

## 6. Hicri takvim

Ümmü'l-Kurâ takvimi tabanlı ay uzunlukları (1343–1500 H),
`assets/data/hijri_ummalqura.json` (~2 KB). Hesaplama tamamen cihazda yapılır ve
Diyanet'in yayımladığı hicri tarihlerle aynı aralıktadır.

## 7. Ses içerikleri

| İçerik | Kaynak | Lisans |
|---|---|---|
| Ezan tonları (`ezan_ton_1..3`), melodi | `tools/design/make_sounds.py` ile proje içinde üretildi | Özgün eser — projeye ait |
| Bildirim sesleri | Aynı betik | Özgün eser |
| Kur'an tilaveti | EveryAyah açık arşivi (akış) | Arşiv koşulları |
| İlahi kataloğu | Uzak katalog (`ILAHI_CATALOG_URL`) | **Her parça için lisans/izin alanı zorunlu**; boşsa listelenmez |

## 8. Yazı tipleri, simgeler ve görseller

| Varlık | Kaynak | Lisans |
|---|---|---|
| Plus Jakarta Sans | Google Fonts | SIL Open Font License 1.1 |
| Amiri (Arapça) | Google Fonts | SIL Open Font License 1.1 |
| Uygulama simgesi ve öne çıkan görsel | Proje içinde üretildi (`tools/design/make_icons.py`) | Özgün eser |
| Arayüz simgeleri | Material Icons (Flutter ile birlikte) | Apache 2.0 |

## 9. Yazılım bileşenleri

Kullanılan tüm Dart/Flutter paketlerinin lisansları uygulama içinde
**Hakkında > Açık kaynak lisansları** ekranından görüntülenebilir
(`showLicensePage`). Kayıtlı liste: `.ci/deps.txt`, çözümlenmiş sürümler:
`.ci/resolved_packages.txt`.

## 10. Atıf özeti (mağaza ve uygulama içi)

- Kur'an Arapça metni: **Tanzil.net** (CC BY-ND)
- Türkçe meal: **QuranEnc**
- Tilavet: **EveryAyah.com**
- Hadis: **Riyâzü's-Sâlihîn** açık veri kümesi
- Vakit doğrulaması: **T.C. Diyanet İşleri Başkanlığı** resmî vakitleri
- Yazı tipleri: **Google Fonts** (OFL)

Bu atıflar uygulamada *Hakkında > Veri kaynakları* bölümünde ve mağaza açıklamasında
yer alır.
