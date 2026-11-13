# EzanAI — kalıcı ajan çalışma kuralları

Bu dosya, bu depoda çalışan **her yapay zekâ ajanı ve geliştirici** için
bağlayıcıdır. Kullanıcı ayrıca söylemese bile aşağıdaki kalite kapısı **her
istekte** uygulanır.

## 1. Her istekte zorunlu sıra

1. **Senkronize ol.** `git fetch origin` ve geçerli dalı (`arena/01a1057d-ezanapp`)
   `origin` ile karşılaştır. Yerel ağaç temiz değilse önce yedek al; asla
   kullanıcı değişikliğini ezme.
2. **Önce hata taraması yap.** Yeni özellik yazmadan önce:
   `dart format --set-exit-if-changed lib test`, `flutter analyze`,
   `flutter test` ve `python3 tools/verify_qibla.py`.
   Flutter SDK yoksa bu adımların CI'da koşacağını açıkça söyle; "test ettim"
   deme.
3. **Bulduğun her hatayı aynı turda düzelt.** Bilinen ama ertelenen hata
   varsa gerekçesini ve takip maddesini yaz.
4. **Kanıt üret.** Davranış değişikliği için test ekle/güncelle. Test
   eklenemiyorsa nedenini ve elle doğrulama adımlarını yaz.
5. **Dokümanı güncelle.** İlgili `docs/` dosyası ve `docs/KALITE_KAPISI.md`
   kaydı olmadan iş bitmiş sayılmaz.
6. **CI'yı bekle.** `gh run watch <id> --exit-status` sonucu **success**
   olmadan teslim etme. Kırmızıysa düzelt, rebase et, yeniden push et.
7. **Türkçe ve tıklama düzeyinde raporla.** Hangi hata, ne yapıldı, telefonda
   nasıl doğrulanır — üçü de yazılır.

## 2. Değişmez kurallar

- Başarılı test ve yeşil CI olmadan **"sorunsuz", "tamamlandı", "düzeldi"**
  denmez.
- Sahte buton, placeholder ekran, çalışmayan bağlantı bırakılmaz.
- Dini hüküm verilmez; kaynak (Kur'an, sahih hadis, güvenilir fıkıh) gösterilir.
- Sentetik ezan/ilahi tonu kullanılmaz; yalnızca gerçek insan sesi.
- API anahtarı, kişisel konum ve imza anahtarı loglanmaz/depolanmaz.
- Vakit doğruluğu her şeyden önce gelir: resmî Diyanet verisi 0 fark, cihaz
  hesabı ±1 dakika sınırındadır.

## 3. Tek komut

```bash
bash tools/quality_gate.sh
```

Flutter SDK varsa biçim, analiz, test ve kıble kontrollerini sırayla koşar.
SDK yoksa hangi kontrolün CI'da yapılacağını yazar ve **yeşil sonuç
uydurmaz**. Ayrıntı: [`docs/KALITE_KAPISI.md`](docs/KALITE_KAPISI.md).
