# Ezan Vaktim Pro — Ses, Görsel ve İçerik Lisansları

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Amaç:** Yayınlanan her içeriğin kaynağını ve lisansını belgelemek; telif,
kişilik hakkı ve yanıltıcı beyan riskini ortadan kaldırmak.
**Durum:** **Yayın engelleyici bulgular var** (aşağıda P0).

> Bu dosya hukuki görüş değildir. Lisans kanıtı (yazılı izin, lisans metni,
> satın alma belgesi) yoksa içerik yayınlanmaz.

## 1. Yönetici özeti

| Kategori | Kaynak | Lisans durumu | Karar |
|---|---|---|---|
| Ezan/ilahi sesleri (`assets/audio/adhan/*`) | `tools/design/make_sounds.py` — **formant sentezi** | Proje içi üretim; özgün | Etiketler “gerçek müezzin” diyemez; düzeltildi |
| Ezan `ezan_saba.mp3` | Belirsiz (192 kbps/44,1 kHz, diğerlerinden farklı) | **Kanıt yok** | Kaynak belgelenmezse sentetik sürümle değiştir |
| Uzak ilahi/ezan (`cdn.jsdelivr.net`) | Üçüncü taraf GitHub depoları | **Lisans yok** | **P0 — kaldırıldı/değiştirildi** |
| Kur’an tilaveti (EveryAyah) | EveryAyah.com akışı | “Ticari olmayan/eğitim” ibaresi | **P1 — ticari kullanım izni alınmalı** |
| Kur’an metni | Tanzil | CC BY-ND 3.0 | Uygun; atıf korunur |
| Türkçe meal | QuranEnc | Açık çeviri izni | Uygun; künye korunur |
| Hadis metni | Riyâzü’s-Sâlihîn açık veri | Kaynak künyesi | Uygun; doğrulama sürer |
| Vakit verisi | Diyanet/İmsakiyem, AlAdhan | Servis koşulları | Uygun; atıf |
| Harita | OpenStreetMap, Esri | ODbL / Esri koşulları | Atıf görünür olmalı |
| Fontlar | OFL fontlar | OFL 1.1 | Uygun; lisans dosyası |
| İkon/görseller | Proje içi (`make_icons.py`) | Özgün | Uygun |
| AI bilgi tabanı | Doğrulanmış kaynak özetleri | Kaynak gösterilir | Uygun; telifli metin kopyalanmaz |

## 2. Ses envanteri ve gerçek durum

`assets/audio/adhan/` (toplam ~13 MB):

| Dosya | Süre | Bit hızı | Üretim | Etiket |
|---|---|---|---|---|
| `ezan_melodi.mp3` | 202,5 sn | 16 kbps/16 kHz | Sentez | Hicaz makamı |
| `ezan_saba.mp3` | 188,2 sn | **192 kbps/44,1 kHz** | **Belirsiz** | **Kaldırıldı (12.11.2026)** |
| `ezan_segah.mp3` | 200,8 sn | 16 kbps/16 kHz | Sentez | Segâh makamı |
| `ezan_tekbir.mp3` | 203,7 sn | 16 kbps/16 kHz | Sentez | Tekbir |
| `ezan_ton_1..3.mp3` | 20–32,5 sn | 64–128 kbps | Sentez | Kısa bildirim |
| `ilahi_*.mp3` | 77–124 sn | 128 kbps | Sentez | İlahi |

**Bulgular:**

1. `tools/design/make_sounds.py` tüm sesleri **matematiksel formant senteziyle**
   üretir; gerçek müezzin kaydı değildir. Buna karşın kodda ve mağaza
   metinlerinde “Kâbe İmamı”, “Abdülbâsıt Abdüssamed”, “Muhammed Rıfat”,
   “Sıddîk el-Minşâvî”, “Harem-i Şerîf Müezzini” adları kullanılıyordu.
   Bu, **yanıltıcı ticari beyan** (6502 sayılı Kanun m.61) ve **kişilik
   hakkı/marka** riski doğurur. **Düzeltildi** (bkz. §5).
2. `ezan_saba.mp3` diğerlerinden farklı teknik imzaya sahipti; commit
   geçmişinde “gerçek müezzin ezan kayıtları” ifadesi var. Kaynak belgesi
   olmadığı için **12 Kasım 2026’da katalogdan ve paketten kaldırıldı**.
   Lisanslı kayıt sağlanınca yeniden eklenebilir.
3. Hiçbir MP3’te ID3/lisans etiketi yok. Metadata eklenmeli (eser, üretici,
   lisans, tarih).
4. `ilahi_siginirim`, `ilahi_tebessum` ve `ezan_minshawi_hicaz` kayıtları
   `cdn.jsdelivr.net` üzerinden üçüncü taraf GitHub depolarından akıtılıyordu;
   lisans kanıtı yok. **P0 — kaldırıldı.**
5. Uygulama içi açıklamalar “gerçek vokal”, “telifsiz” diyordu; sentetik
   üretim için “gerçek” ifadesi yanıltıcı. **Düzeltildi.**

## 3. Müzik/telifsizlik iddiası hakkında

- “Telifsiz” bir eser, **lisanssız** anlamına gelmez; üretici ve lisans
  koşulları belgelenmelidir.
- Sentetik eserlerde telif, eserin üretildiği ülke hukukuna göre doğar;
  proje sahibi hak sahibidir. Yine de üçüncü kişilerin ses/melodi
  benzerliği iddiası için kayıt ve üretim betiği saklanır.
- Kur’an tilaveti ve ezan kayıtları çoğu ülkede **komşu haklar** kapsamında
  korunur; “kamu malı” varsayımı yapılamaz.
- İlahilerde seslendiren sanatçı adı, ancak yazılı izin varsa kullanılır.

## 4. İçerik lisans matrisi (ayrıntı)

| İçerik | Kaynak | Lisans | Ticari kullanım | Atıf | Dosya |
|---|---|---|---|---|---|
| Kur’an Arapça metni | Tanzil.net | CC BY-ND 3.0 | Evet | Zorunlu | `assets/data/quran/*` |
| Türkçe meal | QuranEnc (Risan) | Açık çeviri izni | Evet | Zorunlu | `assets/data/quran/*` |
| Sure künyeleri | Tanzil `chapters.json` | CC BY-ND | Evet | Zorunlu | `assets/data/surah_meta.json` |
| Tilavet | EveryAyah | Belirsiz/ticari kısıt | **Teyit gerekli** | Evet | akış |
| Hadis | Riyâzü’s-Sâlihîn açık veri | Açık veri | Evet | Zorunlu | `assets/data/hadith/*` |
| Vakit | Diyanet/İmsakiyem | Servis | Evet | Evet | ağ |
| Yedek vakit | AlAdhan | Servis | Evet | Evet | ağ |
| Harita | OSM (ODbL), Esri | Açık/koşullu | Evet | **Görünür atıf** | UI |
| Font | OFL | OFL 1.1 | Evet | Lisans dosyası | `assets/fonts` |
| İkonlar | Proje | Özgün | Evet | — | `assets/images` |
| AI cevapları | Model çıktısı + kaynak özetleri | Kaynak gösterilir | Evet | Kaynak bağlantısı | — |

## 5. Yapılan düzeltmeler (12 Kasım 2026)

- [x] Gerçek sanatçı/müezzin adları kaldırıldı; “Vokal Sentez” etiketi.
- [x] “Gerçek”, “Kâbe”, “Harem-i Şerîf”, “Diyanet usulü gerçek” iddiaları
      kaldırıldı.
- [x] `cdn.jsdelivr.net` üzerinden gelen lisanssız kayıtlar katalogdan
      çıkarıldı.
- [x] `app_settings.dart` bildirim sesi adları/açıklamaları düzeltildi.
- [x] `adhan_sound_screen.dart` bilgilendirme metni düzeltildi.
- [x] `ezan_saba.mp3` kaynağı belgelenemediği için **kaldırıldı** (**P0**).
- [ ] EveryAyah ticari kullanım iznini al veya kaynağı değiştir (**P1**).
- [ ] MP3 ID3 lisans etiketleri ekle (**P2**).
- [ ] Mağaza metinlerindeki “gerçek müezzin” ifadelerini kaldır (**P0**).

## 6. Lisans kanıtı saklama

- Her lisans için: lisans metni, izin e-postası, satın alma faturası,
  kaynak URL ve erişim tarihi.
- Konum: özel arşiv (depo dışı) + `docs/legal/lisanslar/` altında yalnızca
  özet ve dosya adı (tam sözleşmeler gizli).
- Süre: içerik yayından kaldırıldıktan sonra 3 yıl.

## 7. Kaldırma (takedown) prosedürü

1. Bildirim destek@ezanai.app — konu: `TELİF BİLDİRİMİ`.
2. 2 iş günü içinde içerik geçici olarak yayından kaldırılır.
3. Hak sahipliği doğrulanır; karşı bildirim hakkı tanınır.
4. Haklı bulunursa kalıcı kaldırma + kaynak değişimi.
5. Mağaza ve hukuki süreç gerekirse yürütülür.

## 8. Mağaza metni kuralları

- “Resmî Diyanet uygulaması” **denemez**; “Diyanet yöntemiyle hesaplanan”
  denir.
- Lisans/izin yoksa sanatçı adı, makam kaydı iddiası, “orijinal Kayıt”
  ifadesi kullanılamaz.
- “Telifsiz” yerine “özgün üretim” veya “lisanslı” denir; ikisi aynı değildir.
- Ekran görüntülerinde gerçek ekran kullanılır; sahte rozet/ödül gösterilmez.

## 9. Açık kaynak atıfları

Uygulama içi **Hakkında → Açık kaynak lisansları** (`showLicensePage`)
Flutter paketlerinin lisanslarını gösterir. Ek olarak:

- Tanzil — <https://tanzil.net>
- QuranEnc — <https://quranenc.com>
- EveryAyah — <https://everyayah.com>
- OpenStreetMap — <https://www.openstreetmap.org/copyright>
- Esri — <https://www.esri.com/en-us/legal/terms/full-master-agreement>
- Google Maps — <https://maps.google.com/help/terms_maps/>

## 10. Sürüm geçmişi

| Tarih | Değişiklik |
|---|---|
| 12 Kasım 2026 | İlk denetim; sentetik ses gerçeği, yanlış atıflar, jsDelivr riski, EveryAyah sorusu |
