# Rakip Uyum Karşılaştırması — Ezan Asistanı Pro

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Amaç:** Pazardaki büyük ezan uygulamalarının **kamuya açık** uyum
özelliklerini karşılaştırıp Ezan Asistanı Pro’nun farkını ve risklerini
belirlemek. Bu belge hukuki iddia değildir; mağaza sayfaları ve kamuya açık
kaynaklara dayanır. Karşılaştırma yalnızca özellik/fiyat düzeyindedir;
hiçbir rakip uygulamanın adı, ikonu, metni veya kodu kopyalanmamıştır.
Ad benzerliği riski [`GOOGLE_PLAY_UYUM.md`](GOOGLE_PLAY_UYUM.md) §1.1’de
ayrıca ele alınmıştır.

## 1. Pazar özeti

| Uygulama | Ücretsiz sürüm | Premium (2026 civarı) | Öne çıkan uyum konusu |
|---|---|---|---|
| Muslim Pro | Reklamlı | ~$3,99/ay · ~$29,99/yıl | 2020’de konum verisinin üçüncü taraflara satıldığı iddiası; veri simsarcılığı yasağı ve şeffaflık beklentisi |
| Ezan Vakti Pro (EDR Software Corp. / Ela İnternet) | Reklamlı | ~€1,99/ay · ~€22,99/yıl | Türkiye pazarı; KVKK aydınlatma ve reklam rızası; **bizimle bağlantısı yok** |
| Athan Pro | Reklamlı | ~$4,99/yıl | Basit abonelik; veri minimizasyonu |
| **Ezan Asistanı Pro** | Reklamlı | **₺79,99/ay · ₺599,99/yıl · ₺1.499,99 ömürlük** | **Hesapsız, cihazda konum, rızasız uzak AI/yedekleme yok, veri simsarcısı yok** |

> Fiyatlar mağaza sayfalarından derlenmiştir ve ülkeye/ kampanyaya göre
> değişebilir. Ezan Asistanı Pro fiyatları için tek kaynak
> [`ABONELIK_VE_IADE.md`](ABONELIK_VE_IADE.md).

## 2. Muslim Pro 2020 dersi

2020’de yayımlanan haberlere göre Muslim Pro, konum verisini reklam/veri
broker ekosistemine aktaran bir SDK ile çalıştı; verilerin ABD Savunma
Bakanlığı’na bağlı bir birime kadar ulaştığı iddia edildi. Şirket uygulamayı
ve SDK’yı kaldırdığını açıkladı.

**Bizim için bağlayıcı dersler:**

1. **Veri simsarcısı yok.** Konum hiçbir üçüncü tarafa satılmaz, reklam
   hedeflemesinde kullanılmaz.
2. **Tam koordinat sunucuya gitmez.** Vakit servisine yalnızca ilçe kimliği
   gider; yedek serviste ~1 km yuvarlama uygulanır.
3. **Dinî veri özel nitelikli sayılır.** AI ve yedekleme ayrı açık rıza ister.
4. **SDK sayısı asgaridir.** Analitik/çökme SDK’sı yoktur; her SDK ROPA’da
   listelenir.
5. **Reklam kişiselleştirmesi varsayılan kapalıdır.**
6. **Silme gerçekten çalışır.** Cihaz + sunucu + destek kanalı.

## 3. Uyum özellikleri karşılaştırması

| Özellik | Muslim Pro | Ezan Vakti Pro | Athan Pro | **Ezan Asistanı Pro** |
|---|---|---|---|---|
| Hesapsız kullanım | Kısmi | Kısmi | Kısmi | **Evet** |
| Konumun cihazda işlenmesi | Belgelenmemiş | Belgelenmemiş | Belgelenmemiş | **Evet** |
| Tam koordinatın gönderilmemesi | Belgelenmemiş | Belgelenmemiş | Belgelenmemiş | **Evet (2 ondalık yedek)** |
| Ayrı AI açık rızası | Yok | Yok | Yok | **Evet** |
| Ayrı bulut yedekleme rızası | Yok | Yok | Yok | **Evet** |
| Rıza geri çekme (uygulama içi) | Kısmi | Kısmi | Kısmi | **Evet** |
| Uygulama içi veri silme | Var | Var | Var | **Evet** |
| Sunucudaki yedeği silme | Kısmi | Kısmi | Kısmi | **Evet** |
| Analitik/çökme SDK’sı | Var | Var | Var | **Yok** |
| Kişiselleştirilmiş reklam varsayılanı | Açık (bölgeye göre) | Açık | Açık | **Kapalı (UMP)** |
| KVKK aydınlatma + açık rıza | Var | Var | Kısmi | **Var** |
| Yurt dışı aktarım kaydı | Kamuya açık değil | Kamuya açık değil | Kamuya açık değil | **Var** |
| 72 saat ihlal planı | Kamuya açık değil | Kamuya açık değil | Kamuya açık değil | **Var** |
| AI yanıtı bildirme | Var | Yok | Yok | **Var** |
| “Fetva vermez” açıklaması | Kısmi | Kısmi | Kısmi | **Var** |
| Ses lisansı belgesi | Kamuya açık değil | Kamuya açık değil | Kamuya açık değil | **Envanter + P0 kural** |
| Mağaza fiyat şeffaflığı | Var | Var | Var | **Var (tek kaynak)** |

> “Belgelenmemiş” ifadesi, ilgili uygulamanın kamuya açık politika metninde
> bu konuda net bir taahhüt bulunmadığını belirtir; aksi yönde iddia değildir.

## 4. Ezan Asistanı Pro’nun uyum avantajları

1. **Hesapsız mimari:** E-posta/ad/telefon toplanmaz; ihlal yüzeyi küçüktür.
2. **Veri minimizasyonu:** Koordinat cihazda; yedek serviste ~1 km.
3. **Rıza ayrılığı:** AI, yedekleme ve reklam birbirinden bağımsız.
4. **SDK disiplini:** Analitik/çökme SDK’sı yok; her SDK envanterde.
5. **Şeffaf ses lisansı:** Sentetik kayıtlar “Vokal Sentez” olarak etiketli;
   lisanssız üçüncü taraf kayıt yok.
6. **Olay müdahalesi:** KVKK 72 saat + 7545 bildirimi + kanıt zinciri.
7. **Mağaza uyumu:** Data safety / App Privacy / politika metni tek kaynaktan.

## 5. Kalan riskler ve rakiplerden fark

| Risk | Durum | Rakip durumu |
|---|---|---|
| EveryAyah ticari kullanım izni | Açık (P1) | Rakiplerde de belirsiz |
| iOS sürümü | Yok | Rakiplerde var |
| Kullanıcı tabanı/ölçek | Düşük | Yüksek |
| Marka bilinirliği | Düşük | Yüksek |
| Ödeme altyapısı | Play/App Store | Aynı |
| VERBİS kaydı | İstisna değerlendirmesi | Rakiplerde kurumsal kayıt |

**Sonuç:** Uyum tarafında rakiplere göre daha şeffaf ve daha kısıtlayıcı bir
model benimsenmiştir. Ticari başarı için bunun **pazarlama diliyle** de
anlatılması gerekir: “Konumunuz satılmaz, dinî veriniz rızanız olmadan
işlenmez.”

## 6. Kaynaklar

- Muslim Pro 2020: LA Times, Al Jazeera, ZDNet haberleri (kamuya açık).
- Mağaza sayfaları: Google Play / App Store (erişim: Kasım 2026).
- Fiyatlar: ilgili mağaza listeleri; ülkeye göre değişir.
- KVKK: <https://www.kvkk.gov.tr>
- 7545 Siber Güvenlik Kanunu: <https://www.mevzuat.gov.tr>
