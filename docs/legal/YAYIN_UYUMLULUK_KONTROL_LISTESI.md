# Ezan Asistanı Pro — Yayın Uyumluluk Kontrol Listesi

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Kullanım:** Her yayın öncesi kopyalanır, maddeler işaretlenir, tarih ve
kanıt bağlantısı yazılır. İşaretlenmemiş **P0** maddesi varsa yayın yapılmaz.

## A. Yasal metinler ve bağlantılar (P0)

- [ ] Gizlilik politikası canlı ve **200** dönüyor
      (`.../privacy.html`)
- [ ] KVKK aydınlatma metni canlı (`.../kvkk.html`)
- [ ] Açık rıza metinleri canlı (`.../acik-riza.html`)
- [ ] Kullanım koşulları/EULA canlı (`.../terms.html`)
- [ ] Abonelik ve iade bilgilendirmesi canlı (`.../abonelik.html`)
- [ ] Veri silme sayfası canlı (`.../veri-silme.html`)
- [ ] Güvenlik/olay bildirimi sayfası canlı (`.../guvenlik.html`)
- [ ] Uygulama içi **Hakkında → Yasal** bağlantıları aynı adresleri açıyor
- [ ] Play Console gizlilik URL’si = uygulama içi URL
- [ ] App Store Connect gizlilik URL’si = uygulama içi URL
- [ ] Koşullar ve abonelik linkleri satın alma ekranında görünür

**Kanıt:** URL + erişim tarihi + ekran görüntüsü.

## B. Google Play (P0/P1)

- [ ] Target API **36** doğrulandı (`aapt2 dump badging`)
- [ ] 16 KB sayfa boyutu uyumu doğrulandı
- [ ] Data safety tablosu `GOOGLE_PLAY_UYUM.md` §2 ile birebir
- [x] “Konum sunucuya gönderilmez” ifadesi AlAdhan istisnasıyla tutarlı
  (2 ondalık ~1 km; Hakkında ekranı ve KVKK metni güncellendi)
- [x] AI-Generated Content: uygulama içi “Bu cevabı bildir” çalışıyor
  (`AiReportService`, cihazda saklanır)
- [ ] `USE_EXACT_ALARM` beyanı hazır veya izin kaldırıldı (P1)
- [x] Reklamlar: kişiselleştirme UMP ile yönetiliyor; varsayılan NPA
  (`AdsService.nonPersonalizedAds`, rıza `personalizedAdsConsentAt` ile)
- [x] Premium: Play Billing, otomatik yenileme bilgisi, “Aboneliği yönet”,
  abonelik/EULA/gizlilik bağlantıları (Premium ekranı)
- [ ] Hesap/veri silme: uygulama içi + web sayfası
- [ ] İçerik derecesi anketi tamamlandı (dinî içerik, 3+/7+)
- [ ] Hedef kitle 13+, çocuk politikası beyanı
- [ ] Mağaza metninde “resmî Diyanet uygulaması” yok
- [ ] Mağaza metninde doğrulanmamış sanatçı/müezzin adı yok
- [ ] Kapalı test: **12 test kullanıcısı / 14 gün** tamamlandı
- [ ] Aşamalı yayın planı (%10 → %50 → %100) hazır
- [ ] Destek e-postası ve geliştirici iletişimi doğrulandı
- [ ] **Marka/ad çakışması:** Turkpatent’te “Ezan Vakti/Vaktim” (sınıf 9, 42)
      araştırıldı; benzer adlı Play/App Store uygulamalarıyla karışma riski
      değerlendirildi (bkz. `GOOGLE_PLAY_UYUM.md` §1.1)

## C. Apple App Store (iOS hazırlanırken)

- [ ] `ios/` projesi oluşturuldu, bundle ID tanımlı
- [ ] `PrivacyInfo.xcprivacy` eklendi (ITMS-91053 önlemi)
- [ ] ATT metni + IDFA yapılandırması (izin yoksa tracking=false)
- [ ] App Privacy beyanı = `APPLE_APP_STORE_UYUM.md` §2.3
- [ ] StoreKit ürünleri + “Restore Purchases” test edildi
- [ ] Abonelik ekranında fiyat/dönem/yenileme/iptal/linkler
- [ ] Hesap silme + veri silme sayfası
- [ ] Gizlilik/koşullar/destek URL’leri 200
- [ ] Ekran görüntüleri 6.9"/6.5"/5.5", 1024 ikon (alfa yok)
- [ ] App Review Notes hazır (demo hesap gerekmiyor)
- [ ] TestFlight iç testi tamamlandı

## D. KVKK ve veri koruma (P0)

- [ ] ROPA güncel (`VERI_ENVANTERI_ROPA.md`)
- [ ] Rıza kayıtları cihazda zaman damgalı (AI + backup)
- [ ] Uzak AI rıza yoksa **hiçbir metin gönderilmiyor**
- [ ] Bulut yedekleme rıza yoksa çalışmıyor
- [ ] Sunucudaki yedeği sil akışı test edildi
- [ ] “Verilerimi sil” tüm yerel tabloları siliyor (test)
- [ ] Yurt dışı aktarım: standart sözleşme imzalı + 5 iş günü bildirim
- [ ] VERBİS istisna değerlendirmesi yazılı (avukat onayı)
- [ ] İhlal müdahale planı ve 72 saat şablonu hazır
- [ ] Destek e-postası KVKK başvurusu alabiliyor
- [ ] Aydınlatma metni ile Data safety aynı veri türlerini sayıyor

## E. Ses ve içerik lisansları (P0)

- [x] `ezan_saba.mp3` lisans kanıtı olmadığı için kaldırıldı
- [x] `cdn.jsdelivr.net` bağımlılığı kaldırıldı (kodda yok)
- [ ] Tüm “gerçek müezzin/sanatçı” etiketleri kaldırıldı (kodda yok)
- [ ] EveryAyah ticari kullanım izni alındı **veya** kaynak değişti
- [ ] MP3 ID3 lisans/üretici etiketleri eklendi (P2)
- [ ] Tanzil/QuranEnc atıfları görünür
- [ ] OSM/Esri atıfları haritada görünür
- [ ] Mağaza görsellerinde “gerçek kayıt” iddiası yok
- [ ] Lisans kanıtları özel arşivde

## F. Siber güvenlik (P0/P1)

- [ ] Tüm yönetici hesaplarında 2FA
- [ ] Supabase RLS testleri geçti (başka kullanıcı verisi okunamıyor)
  - [x] Statik politika denetimi: `tools/verify_rls.py` — 16/16, CI kapısı
  - [ ] Canlı test: iki anonim kullanıcı, A'nın satırı B tarafından okunamıyor
- [ ] `service_role` anahtarı istemcide/repoda yok (gitleaks temiz)
- [ ] TLS zorunlu, cleartext kapalı
- [ ] Release keystore yedeği + parola kasası
- [ ] Bağımlılık taraması ve Dependabot temiz
- [ ] Olay müdahale tatbikatı (masa başı) yapıldı
- [ ] Yedekten geri yükleme tatbikatı yapıldı
- [ ] 7545 bildirim kanalı ve şablonu hazır
- [ ] Güvenlik açığı bildirim adresi yayında

## G. Teknik kalite (P0)

- [ ] `flutter analyze` sıfır uyarı
- [ ] Test kapısı ≥300 test yeşil
- [ ] Kıble doğrulama 6/6
- [ ] Vakit doğrulama (Diyanet karşılaştırma) ±0 dk
- [ ] Bildirim: kilitli ekran, pil optimizasyonu, yeniden başlatma testi
- [ ] Ezan yarıda kesilmiyor; her ekrandan durdurulabiliyor
- [ ] Çevrimdışı açılış ve boş durumlar
- [ ] Android 13/14/15/16 cihaz testi
- [ ] Düşük RAM ve büyük yazı tipi testi
- [ ] Çökme/ANR oranı yayın öncesi <%1

## H. Yayın sonrası

- [ ] Mağaza yorumları ve AI bildirimleri izleniyor
- [ ] 72 saat olay nöbeti (ilk hafta)
- [ ] Haftalık yedek doğrulama
- [ ] Aylık lisans/SDK gözden geçirme
- [ ] 6 aylık ROPA ve gizlilik gözden geçirme
- [ ] Yıllık sızma testi

## İmza

| Rol | Ad | Tarih | İmza |
|---|---|---|---|
| Geliştirici | YazılımCeosu (gerçek kişi — şirket yok, MERSİS/VKN yok) |  |  |
| Hukuk danışmanı (varsa) |  |  |  |

> **Kural:** P0 maddelerinden biri açıksa yayın **durdurulur**. P1 maddeleri
> için risk kabulü yazılı olarak kaydedilir.
