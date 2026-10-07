# Mağaza görselleri, MVP listelemesi ve sürüm notu

Bu belge, Play Console'a yüklenecek **görselleri** ve **metinleri** MVP kapsamına
göre tanımlar. Amaç: mağazada **yalnızca gerçekten var olan özelliklerin** görünmesi
(Play politikası: listeleme, uygulamanın gerçek işlevlerini yansıtmalıdır).

> Kapsam kararı: ilk sürüm **MVP** (kapsam B, `docs/PHASES.md` §5-B). Kur'an, hadis,
> dualar, ilahi, Ramazan modülü, AI asistanı ve premium abonelik **bayraklarla
> kapalı** derlenir; bu yüzden mağaza metni ve ekran görüntüleri bunları **içermez**.
> Sonraki sürümlerde bayraklar açıldıkça hem listeleme hem görseller güncellenir.

## 1. Ekran görüntüsü listesi (çekim planı)

Play, telefon için **en az 2, en fazla 8** görsel ister (önerilen: 6). Her görsel
uygulamanın gerçek bir ekranı olmalı; cihaz çerçevesi/mockup eklenebilir ama ekran
içeriği temsilî çizim olamaz.

| # | Ekran | Nasıl alınır | Üzerine yazılacak kısa metin (isteğe bağlı) |
|---|---|---|---|
| 1 | **Ana sayfa** — büyük geri sayım + günün vakitleri | Uygulamayı aç, bir sonraki vakit görünürken bekle (geri sayım canlı) | "Sonraki namaza kalan süre, tek bakışta" |
| 2 | **Vakitler** — haftalık/aylık tablo | Vakitler sekmesi → "Tablo" | "Haftalık ve aylık imsakiye" |
| 3 | **Bildirim ayarları** — vakit bazlı bildirimler + ezan sesi | Vakitler → uzun bas → bildirimler (veya Ayarlar → Bildirimler) | "Her vakit için ayrı bildirim ve ezan sesi" |
| 4 | **Kıble** — pusula, Kâbe yönü, mesafe | Kıble ekranı (açık alanda kalibre et) | "Kalibre edilmiş pusula ile Kâbe yönü" |
| 5 | **Tesbih** — sayaç + günlük hedef | Tesbih sekmesi, birkaç zikri işaretledikten sonra | "Dokunsal sayaç ve günlük hedef takibi" |
| 6 | **Hicri takvim** — kandiller/bayramlar | Daha Fazla → Hicri Takvim | "Hicri takvim ve mübarek günler" |

Görsel kuralları:

- Biçim **PNG veya JPEG**, kısa kenar ≥ **320 px**, uzun kenar ≤ **3840 px**,
  en-boy oranı 16:9 veya 9:16 (dikey telefon görseli için 1080×1920 idealdir).
- Durum çubuğunda **gerçek saat/pil** görünür; sorun değildir ama kişisel bildirim
  içeriği (ör. isim, mesaj) görünmemelidir.
- Aynı ekranın iki varyantını yüklemeyin; her görsel farklı bir yeteneği göstersin.
- MVP derlemesinde Kur'an/İlahi sekmeleri **görünmez** — görselde onları beklemeyin.

### Ekran görüntüsü nasıl alınır (USB ile bağlı cihaz)

```bash
# Cihazı bağlayın (USB hata ayıklama açık) ve kontrol edin:
flutter devices

# Ekran görüntüsü al (bilgisayara kaydeder):
adb exec-out screencap -p > ~/Masaüstü/ezanai_01_anasayfa.png
```

Alternatif: telefonda **güç + ses kısma** tuşlarıyla alıp dosyayı bilgisayara aktarın.
Görseli kırpmak/çerçevelemek isterseniz: en-boy oranını 9:16'ya tamamlayın, ekran
içeriğini bulanıklaştırmayın veya başka bir ekranla birleştirmeyin.

### Zaten hazır olan görseller

| Dosya | Kullanım | Durum |
|---|---|---|
| `store/play_icon_512.png` | Uygulama simgesi (512×512) | ✅ hazır |
| `store/play_feature_graphic_1024x500.png` | Öne çıkan görsel (1024×500) | ✅ hazır |
| — | Telefon ekran görüntüleri (yukarıdaki 6 kare) | ⛔ çekilecek |
| — | Tablet ekran görüntüleri (isteğe bağlı, 7"/10") | ⛔ isteğe bağlı |

## 2. Mağaza metinleri (MVP kapsamı)

Tam kapsamlı metinler `docs/PLAY_STORE.md` içinde durur. **İlk sürümde** aşağıdaki
metinleri kullanın; kapalı modüllerden söz etmeyin.

**Uygulama adı (30 karakter):**

```
EzanAI: Namaz Vakitleri
```

**Kısa açıklama (80 karakter):**

```
Namaz vakitleri, ezan bildirimi, kıble ve tesbih: çevrimdışı da çalışır.
```

**Tam açıklama (MVP):**

```
EzanAI, günlük ibadetlerinizi kolaylaştıran sade ve güvenilir bir namaz vakti
asistanıdır. İnternet olmasa bile vakitlerinizi gösterir; reklamlar yalnızca
ücretsiz sürümde görünür.

• NAMAZ VAKİTLERİ
Diyanet İşleri Başkanlığı yöntemiyle hesaplanır ve resmî verilerle kalibre
edilmiştir. 4.900'den fazla şehir arasından seçin veya konumunuzu otomatik
kullanın. Günlük, haftalık ve aylık imsakiye tablosu; yaz/kış saati ve vakit
bazlı manuel düzeltme desteği.

• EZAN VE BİLDİRİMLER
Her vakit için ayrı bildirim, ezan sesi seçimi, önceden hatırlatma, sessiz/uyku
modu, Cuma günü hatırlatması. Bildirimler çevrimdışıyken de planlanır.

• KIBLE
Pusula ve ivmeölçer füzyonuyla Kâbe yönü, kalibrasyon uyarısı, mesafe bilgisi ve
haritada yön gösterimi.

• TESBİH VE ZİKİR
Dokunsal geri bildirimli sayaç, günlük hedef, otomatik ilerleme, geçmiş ve
istatistikler.

• HİCRİ TAKVİM
Hicri tarih dönüşümü, kandil ve bayram günleri, önemli gün hatırlatmaları.

• GİZLİLİK ÖNCE
Hesap açmanız gerekmez. Konum bilgisi cihazınızda kalır, sunucuya gönderilmez.
Tüm kayıtlarınız cihazınızda saklanır ve dilediğiniz an silinebilir.

EzanAI bir bilgilendirme uygulamasıdır; dinî konularda kesin hüküm vermez.
Vakitlerde tereddüt hâlinde bulunduğunuz yerin resmî ilanlarını esas alın.
```

**Kategori:** Yaşam Tarzı (alternatif: Kişiselleştirme) · **Etiketler:** namaz, ezan, kıble, tesbih, hicri takvim

## 3. Veri güvenliği formu (MVP yanıtları)

| Soru | Yanıt |
|---|---|
| Uygulama kullanıcı verisi topluyor mu? | **Evet** (konum, uygulama içi etkinlik) |
| Konum — toplanıyor mu? | Evet, **isteğe bağlı**; amaç: uygulama işlevi (vakit/kıble); cihazda işlenir, paylaşılmaz |
| Veriler aktarım sırasında şifreleniyor mu? | Evet (TLS) |
| Kullanıcı veri silmeyi talep edebiliyor mu? | Evet (uygulama içi silme + destek adresi) |
| Reklam kimliği kullanılıyor mu? | Ücretsiz sürümde AdMob (premium kapalıysa ilk sürümde AdMob kimlikleri boşsa **hayır**) |
| Çökme/kullanım verisi | Firebase yapılandırıldıysa evet, **isteğe bağlı** ve kapatılabilir |

> Not: İlk sürümde AdMob kimlikleri tanımlanmadıysa reklam hiç gösterilmez; bu durumda
> mağaza listelemesinde "reklam içerir" beyanı **gerekmez** ve forma "hayır" yazılır.

## 4. Sürüm notu şablonu

İlk sürüm (dahili/kapalı test yüklemesi) için:

```
İlk sürüm: namaz vakitleri, ezan ve vakit bildirimleri, kıble, tesbih ve hicri takvim.

Bu sürümde ne var?
• Diyanet yöntemiyle vakitler, 4.900+ şehir, otomatik konum veya manuel seçim
• Her vakit için ayrı bildirim, ezan sesi seçimi, sessiz/uyku modu
• Pusula ile kıble, mesafe ve harita yönü
• Dokunsal tesbih sayacı, günlük hedef ve istatistikler
• Hicri takvim ve mübarek günler

Geri bildiriminiz bizim için değerli: destek@ezanai.app
```

Sonraki sürümlerde modül açıldıkça tek cümlelik madde ekleyin, ör.:

```
• Kur'an-ı Kerim: 114 surenin tamamı Arapça + Türkçe meal, sesli tilavet
• AI İslam Asistanı: kaynak gösteren, mezhep farklarını belirten yanıtlar
```

## 5. Yayın günü kontrolü

- [ ] Ekran görüntüleri MVP derlemesinden alındı (kapalı sekmeler görünmüyor)
- [ ] Kısa/tam açıklama yalnızca MVP özelliklerini anlatıyor
- [ ] Gizlilik politikası adresi canlı: `https://<kullanıcı>.github.io/ezanapp/privacy.html`
      ve uygulama içi bağlantı aynı adrese ayarlı (`--dart-define=PRIVACY_URL=...`)
- [ ] Veri güvenliği formu `docs/PRIVACY.md` ile tutarlı
- [ ] Sürüm notu yazıldı, `pubspec.yaml` sürümü artırıldı (`1.0.0+1`)
