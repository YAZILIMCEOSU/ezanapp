# Ezan Vaktim Pro — Siber Güvenlik ve Olay Müdahale Protokolü

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Kapsam:** Uygulama, backend, Supabase, CI/CD, mağaza hesapları, geliştirici
makineleri ve destek e-postası.
**Sahip:** YazılımCeosu — destek@ezanai.app
**Gizlilik:** Bu belgenin kamuya açık sürümünde saldırı yüzeyi ayrıntıları
sınırlandırılır; tam sürüm özel saklanır.

> Dayanak: KVKK m.12 ve Kişisel Veri Güvenliği Rehberi; 7545 sayılı Siber
> Güvenlik Kanunu; TCK m.243–245; ISO/IEC 27001 (hedef); OWASP MASVS/ASVS.
> Hukuki görüş değildir.

## 1. Amaç ve ilkeler

1. Kişisel verilerin gizliliği, bütünlüğü ve erişilebilirliğini korumak.
2. Olayları **gecikmeksizin** tespit etmek, sınırlamak, bildirmek ve öğrenmek.
3. Yasal bildirim sürelerine uymak: **KVKK 72 saat**, **7545 gecikmeksizin**.
4. Varsayılan güvenli, en az yetki, derinlemesine savunma, kayıt tutma.

## 2. Varlık envanteri ve kritiklik

| Varlık | Kritiklik | Sahip | Not |
|---|---|---|---|
| Kullanıcı cihaz verisi (SQLite) | Yüksek | Kullanıcı | Uygulama alanı; `allowBackup=false` |
| Supabase projesi (yedekler) | Yüksek | Geliştirici | RLS zorunlu; servis anahtarı istemcide yok |
| AI backend / API anahtarları | Yüksek | Geliştirici | Sunucu tarafı; istemciye gömülmez |
| Play Console / App Store Connect | Kritik | Geliştirici | 2FA zorunlu |
| GitHub deposu + Actions | Yüksek | Geliştirici | Ana dal koruması, secret taraması |
| Release keystore | Kritik | Geliştirici | Çevrimdışı yedek, parola kasası |
| AdMob hesabı | Orta | Geliştirici | 2FA |
| Destek e-postası | Orta | Geliştirici | 2FA, bağımsız parola |
| Geliştirici makinesi | Yüksek | Geliştirici | Disk şifreleme, ekran kilidi |

## 3. Tehdit modeli (STRIDE özeti)

| Tehdit | Örnek | Önlem |
|---|---|---|
| Spoofing | Sahte AI backend, MITM | TLS pinning/sertifika doğrulama, sabit alan adı |
| Tampering | Değiştirilmiş APK, RLS atlatma | İmza, Play App Signing, RLS, sunucu doğrulama |
| Repudiation | Rıza inkârı | Zaman damgalı rıza kaydı, sunucu logu |
| Information disclosure | Yedek sızıntısı, log’da konum | RLS, şifreleme, log maskeleme, minimal veri |
| Denial of service | AI kota taşması | Hız sınırı, kota, 429, devre kesici |
| Elevation of privilege | Servis anahtarı ile RLS atlama | Anahtar istemcide yok, least privilege, rotasyon |

**Saldırı yüzeyi:** ağ (vakit/AI/Supabase/AdMob), yerel depolama, IPC
(bildirim/medya), izinler, bağımlılıklar, CI secret’ları, mağaza hesapları.

## 4. Erişim kontrolü

- **2FA** tüm yönetici hesaplarında zorunlu (GitHub, Google, Supabase, Apple).
- Parola yöneticisi; her hizmet için benzersiz parola; en az 16 karakter.
- Supabase: `service_role` anahtarı **yalnızca** sunucuda/CI secret’ında;
  istemci `anon` anahtarı + RLS kullanır.
- GitHub: `main` korumalı; zorunlu review, imzalı commit hedefi, secret
  scanning + Dependabot açık.
- Ayrıcalıklı işlemler (yayın, anahtar rotasyonu) kayıt altına alınır.
- Erişim üç ayda bir gözden geçirilir; ayrılan erişim derhâl kaldırılır.

## 5. Uygulama güvenliği (MASVS)

### 5.1. Ağ

- TLS 1.2+; `usesCleartextTraffic=false`; network security config.
- Sertifika doğrulama kapatılmaz; zayıf TLS yapılandırması yok.
- API anahtarı istemciye gömülmez; anahtar yalnızca backend’de.
- Hata yanıtları kullanıcıya teknik ayrıntı sızdırmaz; sunucu logunda iz
  numarası döner.
- Zaman aşımı ve üstel geri çekilme; 429/5xx devre kesici.

### 5.2. Depolama

- `allowBackup=false`, `fullBackupContent` yok; hassas veri harici depolamaya
  yazılmaz.
- Anonim oturum jetonu platform güvenli depolamasında (Keystore/Keychain).
- Bulut yedekleri TLS ile taşınır; RLS ile yalnız sahibi erişir.
- Cihazda düz metin parola/anahtar yok.

### 5.3. Kimlik doğrulama ve oturum

- Uygulama hesabı yok; Supabase anonim oturumu yalnızca yedekleme için.
- Anonim oturum cihazla sınırlı; oturum kapatma jetonu geçersiz kılar.
- Yeniden kimlik doğrulama gerektiren işlem: yedeği silme.

### 5.4. Platform etkileşimi

- Dışa açık activity/receiver yalnızca gerekli; `exported=false` varsayılan.
- Deep link doğrulaması; beyaz liste; parametre doğrulama.
- WebView kullanılmaz; kullanılırsa JS ve dosya erişimi kapalı.
- İzinler çalışma zamanında ve bağlam içinde istenir.

### 5.5. Kod kalitesi

- `flutter analyze` sıfır uyarı; test kapısı (≥300 test); bağımlılık taraması.
- R8/obfuscation; debug sembolleri ayrı saklanır.
- Gizli bilgi taraması (gitleaks) her PR’da.
- Üçüncü taraf paketler yalnızca pub.dev; sürüm kilitli (`pubspec.lock`).

### 5.6. Gizlilik

- Loglarda konum, soru metni, e-posta yok; maskelenir.
- Analytics/crash SDK yok; eklenirse rıza + Data safety güncellemesi.
- Üretim verisiyle test yapılmaz; anonim test verisi.

## 6. Backend ve bulut güvenliği

- Supabase RLS tüm tablolarda açık; politika: `auth.uid() = user_id`.
- Depolama kovası özel; imzalı URL, kısa süreli.
- Yönetici işlemleri yalnızca sunucu tarafı; istemciye `service_role` yok.
- Yedeklerde şifreleme; erişim logları; anormal indirme alarmı.
- AI backend: kimlik doğrulama, hız sınırı, girdi uzunluğu sınırı, çıktı
  filtresi, sağlayıcıda saklama yasağı (zero-retention).
- Sırlar ortam değişkeni/secret manager; depoda sır yok.

## 7. CI/CD ve tedarik zinciri

- GitHub Actions: sabitlenmiş action sürümleri (SHA), en az yetkili
  `GITHUB_TOKEN`.
- Secret’lar GitHub Secrets; log’a yazdırılmaz (`::add-mask::`).
- Yayın imzası CI’da; keystore base64 secret + parola secret.
- AAB/APK imza doğrulaması ve sürüm numarası kontrolü.
- Dependabot + `pub outdated`; kritik yamalar 7 gün içinde.
- Üçüncü taraf action’lar için tedarikçi güveni ve sürüm kilidi.

## 8. Olay müdahale planı

### 8.1. Önem dereceleri

| Seviye | Tanım | Örnek | İlk yanıt |
|---|---|---|---|
| P1 | Kişisel veri ihlali / yaygın kesinti | Yedek tablosu ifşası, anahtar sızması | 1 saat |
| P2 | Sınırlı ihlal / kritik zafiyet | Tek kullanıcı verisi, RCE | 4 saat |
| P3 | Orta | Kota aşımı, spam | 1 iş günü |
| P4 | Düşük | UI hatası, yanlış log | 5 iş günü |

### 8.2. Aşamalar

1. **Tespit:** izleme, kullanıcı bildirimi, mağaza uyarısı, güvenlik taraması.
2. **Sınıflandırma:** seviye, veri türü, etkilenen kişi sayısı.
3. **Sınırlama:** anahtar rotasyonu, oturum iptali, erişim kapatma, yama,
   gerekirse özellik kapatma (`feature flag`).
4. **Yok etme:** zafiyet giderimi, kök neden analizi.
5. **Bildirim:** §9.
6. **İyileştirme:** ders çıkarımı, test ve süreç güncellemesi, 30 gün içinde
   rapor.

### 8.3. Kanıt ve kayıt

- Olay numarası, zaman çizelgesi, etkilenen varlıklar, alınan aksiyonlar,
  bildirimler.
- Loglar değiştirilemez biçimde saklanır (WORM/append-only hedefi).
- Kişisel veri içeren kanıtlar şifreli saklanır; erişim sınırlıdır.

## 9. Yasal bildirimler

### 9.1. KVKK — 72 saat

- Veri ihlali öğrenildiğinde **en kısa sürede ve en geç 72 saat içinde**
  Kişisel Verileri Koruma Kurumu’na bildirilir (Kurul 2019/10).
- Bildirim: olayın niteliği, etkilenen veri kategorileri ve kişi sayısı,
  olası sonuçlar, alınan önlemler, iletişim.
- Veri sahibine makul olan en kısa sürede bildirim; yüksek risk varsa açık
  ve anlaşılır dilde.
- 72 saat içinde tamamlanamazsa **gerekçeli ara bildirim** yapılır.
- Kayıt: `docs/legal/olaylar/` altında (özel, depoya commit edilmez).

### 9.2. 7545 Siber Güvenlik Kanunu

- Siber güvenlik olayı ve tespit edilen zafiyet, **gecikmeksizin** Siber
  Güvenlik Başkanlığı’na bildirilir.
- KVKK bildirimi 7545 bildiriminin yerine geçmez; ikisi ayrı yürütülür.
- Kapsam ve usul, Başkanlıkça yayımlanan usul ve esaslara göre uygulanır.

### 9.3. Diğer

- Mağaza (Play/Apple) güvenlik bildirimi.
- Etkilenen tedarikçilere (Supabase, Google) bildirim.
- Gerekirse Cumhuriyet Başsavcılığı’na suç duyurusu (TCK 243–245).
- Kullanıcıya bildirim; 72 saatlik süreçte şeffaflık.

### 9.4. Bildirim şablonu

```
OLAY NO: EZANAI-YYYY-NNN
TESPİT: <tarih saat, kaynak>
SEVİYE: P1/P2
ÖZET: <ne oldu>
ETKİLENEN VERİ: <kategori, yaklaşık kişi sayısı>
KÖK NEDEN: <biliniyorsa>
SINIRLAMA: <yapılanlar, saat>
BİLDİRİMLER: KVKK <tarih/saat>, SGİB <tarih/saat>, kullanıcı <tarih>
İYİLEŞTİRME: <plan, sorumlu, tarih>
```

## 10. İzleme ve test

- Yayın sonrası çökme/ANR oranı; mağaza vitals.
- Supabase anormal erişim/indirme alarmı.
- Aylık bağımlılık ve secret taraması.
- Yılda en az bir kez sızma testi (harici veya OWASP MASVS tabanlı).
- Geri yükleme tatbikatı: 6 ayda bir yedekten geri dönme testi.
- Olay müdahale tatbikatı: yılda bir masa başı.

## 11. Yedekleme ve süreklilik

- Kaynak kod: GitHub + yerel şifreli yedek.
- Keystore: çevrimdışı, iki kopya, ayrı fiziksel konum.
- Supabase: günlük otomatik yedek + haftalık dışa aktarım.
- RTO hedefi 24 saat; RPO hedefi 24 saat.
- Kurtarma adımları yazılı ve test edilmiş.

## 12. Eğitim ve sorumluluk

- Geliştirici: güvenlik farkındalığı, oltalama, güvenli kod.
- Destek: kişisel veri talebi ve olay bildirimini tanıma.
- Yeni özellik öncesi gizlilik ve güvenlik kontrolü (PR şablonu).
- İhlal: disiplin ve hukuki süreç; gönüllü bildirim teşvik edilir.

## 13. Sürüm ve gözden geçirme

- Son güncelleme: 12 Kasım 2026
- Sonraki gözden geçirme: 12 Mayıs 2027 (veya büyük mimari değişiklikte)
- Onay: YazılımCeosu

## 14. Bağlantılı belgeler

- [`KVKK_AYDINLATMA_METNI.md`](KVKK_AYDINLATMA_METNI.md)
- [`VERI_ENVANTERI_ROPA.md`](VERI_ENVANTERI_ROPA.md)
- [`VERI_SILME_VE_BASVURU.md`](VERI_SILME_VE_BASVURU.md)
- [`UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md`](UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md)
- [`SES_VE_ICERIK_LISANSLARI.md`](SES_VE_ICERIK_LISANSLARI.md)
- [`YAYIN_UYUMLULUK_KONTROL_LISTESI.md`](YAYIN_UYUMLULUK_KONTROL_LISTESI.md)
