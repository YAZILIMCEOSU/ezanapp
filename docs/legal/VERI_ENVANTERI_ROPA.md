# Ezan Vaktim Pro — Kişisel Veri İşleme Envanteri (ROPA)

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Veri sorumlusu:** YazılımCeosu — destek@ezanai.app
**Amaç:** KVKK m.16 ve GDPR m.30 ile uyumlu kayıt tutma; VERBİS başvurusuna
temel oluşturma.

> Bu envanter uygulamanın **gerçek veri akışına** göre hazırlanmıştır. Yeni
> SDK, özellik veya sunucu eklenmeden önce güncellenmelidir. Hukuki görüş
> değildir.

## 1. İşleme faaliyetleri

| ID | Faaliyet | Veri sahibi | Veri kategorisi | Amaç | Hukuki sebep | Alıcı | Aktarım | Saklama | Silme |
|---|---|---|---|---|---|---|---|---|---|
| R-01 | Namaz vakti ve kıble hesabı | Kullanıcı | Konum (cihaz), şehir kimliği | Vakit/kıble | m.5/2-c, m.5/2-f | Vakit servisi (yalnızca ilçe kimliği) | Sınırlı | Cihazda son konum | Uygulama içi silme |
| R-02 | Kur’an/ilahi/tesbih kullanımı | Kullanıcı | Kullanım içeriği (favori, ilerleme, zikir) | Özellik | m.5/2-c | Yok | Yok | Cihazda | Ayarlar → Verilerimi sil |
| R-03 | AI asistanı | Kullanıcı | Soru, son 6 mesaj, mezhep tercihi (özel nitelikli olabilir) | Cevap üretimi | m.6/2 açık rıza | AI backend | Yurt dışı — SCC | Cihazda; sunucuda kalıcı değil | Sohbet silme + rıza geri çekme |
| R-04 | Bulut yedekleme | Kullanıcı | Tüm yerel içerik + anonim UUID | Yedekleme | m.6/2 açık rıza | Supabase | Yurt dışı — SCC | Silinene kadar; hedef 24 ay | Sunucudaki yedeği sil |
| R-05 | Reklam | Kullanıcı | AD_ID, IP, yaklaşık konum, etkileşim | Reklam/ölçüm | Kişiselleştirme: açık rıza; NPA: m.5/2-f | Google AdMob | Yurt dışı — SCC | Google politikası | Cihaz/Google ayarları |
| R-06 | Abonelik | Kullanıcı | Ürün kimliği, abonelik durumu | Premium | m.5/2-c | Google/Apple | Mağaza | Mağaza + vergi mevzuatı | Mağaza |
| R-07 | Destek | Kullanıcı | E-posta, mesaj | Destek | m.5/2-c, m.5/2-f | E-posta sağlayıcı | Yurt dışı olabilir | 2 yıl | Süre sonu |
| R-08 | Push (opsiyonel) | Kullanıcı | FCM jetonu | Bildirim | m.5/2-c | Firebase | Yurt dışı — SCC | Jeton geçerliliği | Jeton silme/izin kapatma |
| R-09 | Güvenlik günlükleri | Kullanıcı/cihaz | IP, hata kaydı (konum ve soru metni maskeli) | Güvenlik | m.5/2-f | Barındırma | Yurt dışı olabilir | 6 ay | Otomatik silme |

**Özel nitelikli veri notu:** R-03 ve R-04’te dinî inanç/ibadet verisi
işlenebilir. Bu faaliyetler yalnızca açık rıza ile ve ek güvenlik tedbirleriyle
yürütülür (KVKK m.6/2).

## 2. Veri sahibi grupları

- Uygulama kullanıcıları (13 yaş üstü hedef kitle),
- Destek e-postası gönderenler,
- Premium aboneler.

Çalışan/aday/müşteri verisi işlenmez (tek kişilik geliştirici).

## 3. Alıcılar ve veri işleyenler

| Tedarikçi | Rol | Hizmet | Bölge | Sözleşme | Durum |
|---|---|---|---|---|---|
| Google LLC (AdMob) | Veri işleyen/bağımsız | Reklam | ABD/AB | Google Ads DPA + SCC | Mevcut |
| Google LLC (Firebase) | Veri işleyen | Push | ABD | Google DPA + SCC | Opsiyonel |
| Supabase Inc. | Veri işleyen | Bulut yedek | AB (Frankfurt) / ABD | DPA + SCC | Opsiyonel |
| AI backend sağlayıcısı | Veri işleyen | Model çıkarımı | Yapılandırmaya göre | DPA + SCC + saklama yasağı | Yapılandırılacak |
| E-posta sağlayıcısı | Veri işleyen | Destek | AB/ABD | DPA | Mevcut |
| GitHub (barındırma) | Veri işleyen | Kaynak/Pages | ABD | GitHub DPA | Mevcut |

**Not:** Google Play/App Store, ödeme ve dağıtımda **bağımsız veri
sorumlusu** olarak kendi politikalarına tabidir.

## 4. Yurt dışı aktarım kaydı

| Aktarım | Ülke | Mekanizma | Kurum bildirimi | Durum |
|---|---|---|---|---|
| AdMob | ABD | Standart sözleşme | 5 iş günü içinde | Yapılacak |
| Supabase | AB/ABD | Standart sözleşme | 5 iş günü içinde | Yapılacak |
| AI backend | Değişken | Standart sözleşme | 5 iş günü içinde | Yapılacak |
| Firebase | ABD | Standart sözleşme | 5 iş günü içinde | Opsiyonel |

Aktarım öncesi **aktarım etki değerlendirmesi** ve alıcı ülkede hak arama
imkânı kontrolü yapılır. Yeterlilik kararı bulunmayan ülkelerde yalnızca
standart sözleşme/uygun güvence ile aktarım yapılır.

## 5. Saklama ve imha takvimi

| Veri | Süre | Dayanak | İmha yöntemi |
|---|---|---|---|
| Cihaz içeriği | Kullanıcı silene kadar | Hizmet | Uygulama içi silme / kaldırma |
| Bulut yedeği | Silinene kadar; hedef 24 ay | Rıza | Sunucu silme + yedek rotasyonu |
| AI sohbeti (yerel) | Kullanıcı silene kadar | Hizmet | Sohbet silme |
| Destek e-postası | 2 yıl | Meşru menfaat | Silme |
| Güvenlik logu | 6 ay | Güvenlik | Otomatik rotasyon |
| Abonelik kaydı | 10 yıl (mağaza/vergi) | Yasal | Mağaza |

İmha, KVKK’nın Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale
Getirilmesi Hakkında Yönetmelik’e uygun yapılır; silme talebi 30 gün içinde
yanıtlanır.

## 6. Veri güvenliği tedbirleri (özet)

- Erişim: en az yetki, ayrı yönetici hesapları, 2FA.
- Şifreleme: TLS 1.2+, RLS, cihazda uygulama alanı; yedekte şifreli taşıma.
- Gizlilik: log maskeleme, konum/İçerik loglanmaması, analitik SDK yok.
- Dayanıklılık: yedekleme, geri yükleme testi, sürüm geri alma.
- Yazılım: R8/obfuscation, imza sabitleme, bütünlük kontrolü, bağımlılık
  taraması.
- Olay: 72 saat KVKK bildirimi, 7545 kapsamında gecikmeksizin SGİB bildirimi.
- Denetim: yıllık gözden geçirme, sızma testi (hedef).

Ayrıntı: [`SIBER_GUVENLIK_PROTOKOLU.md`](SIBER_GUVENLIK_PROTOKOLU.md).

## 7. VERBİS değerlendirmesi

Kurul’un 2018/87 ve 2023/1154 sayılı kararlarına göre:

- Yıllık çalışan sayısı **50’den az** ve yıllık mali bilanço **100 milyon
  TL’den az** olup **ana faaliyet konusu özel nitelikli veri işleme olmayan**
  veri sorumluları VERBİS’ten istisnadır.
- Ana faaliyeti özel nitelikli veri işleme olanlar için eşik **10 çalışan /
  10 milyon TL**’dir.

**Değerlendirme:** Uygulamanın ana faaliyeti dinî içerik ve vakit hizmetidir;
özel nitelikli veri (AI/backup) isteğe bağlı ve ikincildir. Bu nedenle mevcut
ölçekte **istisna** değerlendirmesi yapılmıştır. Ancak:

- Özel nitelikli veri işleme ana faaliyet hâline gelirse,
- Çalışan/bilanço eşiği aşılırsa,
- Yurt dışında yerleşik veri sorumlusu söz konusu olursa

VERBİS kaydı zorunlu olur. Nihai karar avukat tarafından verilmelidir; karar
tarihi ve gerekçesi bu dosyada saklanır.

## 8. Etki değerlendirmesi (DPIA) özeti

| Risk | Olasılık | Etki | Önlem |
|---|---|---|---|
| Dinî verinin ifşası | Düşük | Yüksek | Ayrı rıza, TLS, RLS, minimal veri, log yasağı |
| Konumun izinsiz kullanımı | Düşük | Yüksek | Cihazda işleme, koordinat gönderilmez |
| Reklam kimliğiyle profilleme | Orta | Orta | Varsayılan NPA, rıza, dinî hedefleme yasağı |
| Tedarikçi ihlali | Orta | Yüksek | DPA/SCC, bildirim yükümlülüğü, olay planı |
| Çocuk verisi | Düşük | Yüksek | 13+ hedef, çocuk reklam hedeflemesi yok |
| Yetkisiz erişim | Orta | Yüksek | 2FA, en az yetki, log izleme |

## 9. Sorumluluk ve gözden geçirme

- **Veri sorumlusu:** YazılımCeosu
- **İletişim:** destek@ezanai.app
- **Gözden geçirme:** 6 ayda bir veya yeni özellik/SDK öncesi
- **Son gözden geçirme:** 12 Kasım 2026
- **Sonraki:** 12 Mayıs 2027
