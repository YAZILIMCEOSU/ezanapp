# Güvenlik Politikası — Ezan Vaktim Pro

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**İletişim:** destek@ezanai.app — konu satırı **GÜVENLİK**
**Kapsam:** `com.yazilimceosu.ezanai` mobil uygulaması, resmî backend,
Supabase yedekleme altyapısı ve CI/CD süreçleri.

## 1. Bildirim

Güvenlik açığı veya kişisel veri ihlali şüphesini **destek@ezanai.app**
adresine bildirin. Konu satırına `GÜVENLİK` yazın.

Bildirimde bulunursanız:

- Açığın türü ve etkisi,
- Yeniden üretme adımları (ekran görüntüsü/log),
- Etkilenen sürüm/platform,
- Varsa önerilen düzeltme

bilgilerini ekleyin. **Kişisel verileri ve üçüncü kişilerin verilerini
paylaşmayın.**

## 2. Yanıt süreleri

| Aşama | Hedef |
|---|---|
| Alındı bildirimi | 2 iş günü |
| İlk değerlendirme | 5 iş günü |
| Kritik (P1) düzeltme | 7 gün |
| Orta (P2) düzeltme | 30 gün |
| Düşük (P3) düzeltme | 90 gün |

KVKK kapsamında kişisel veri ihlali tespit edilirse Kurum’a **72 saat**
içinde, 7545 sayılı Kanun kapsamında Siber Güvenlik Başkanlığı’na
**gecikmeksizin** bildirim yapılır.

## 3. Kapsam

**Kapsam içi:**

- Uygulama ikili dosyaları ve kaynak kodu,
- Kimlik doğrulama/yetkilendirme (Supabase RLS, anonim oturum),
- Yerel veri depolama ve yedekleme,
- Ağ iletişimi (TLS, API uç noktaları),
- Ödeme doğrulama ve premium erişim kontrolleri,
- CI/CD ve sır yönetimi.

**Kapsam dışı:**

- Üçüncü taraf hizmetlerin (Google, Supabase, Apple) kendi altyapısı —
  doğrudan ilgili sağlayıcıya bildirin,
- Sosyal mühendislik, fiziksel erişim, hizmet dışı bırakma (DoS),
- Otomatik tarayıcıların gürültülü çıktıları,
- Kullanıcı cihazının root/jailbreak edilmiş olması,
- Yalnızca teoriye dayanan, kanıtsız raporlar.

## 4. Kurallar

- Yalnızca **kendi** hesaplarınız/verilerinizle test yapın.
- Üçüncü kişilerin verilerine erişmeyin, kopyalamayın, paylaşmayın.
- Hizmeti bozacak, veri kaybına yol açacak testler yapmayın.
- Açığı kamuya açıklamadan önce düzeltme için makul süre tanıyın
  (90 gün önerilir).
- Yasal sınırlar içinde hareket edin.

## 5. Güvenli liman

İyi niyetle, bu politikaya uygun şekilde yapılan güvenlik araştırmaları için
hukuki işlem başlatılması amaçlanmaz. Bu, üçüncü kişilerin haklarını veya
yürürlükteki hukuku bağlamaz.

## 6. Ödül

Bağımsız bir geliştirici projesi olduğundan ödeme garantisi verilmez.
Katkınız, düzeltme sonrası **teşekkür listesinde** (izin verirseniz) anılır.

## 7. Desteklenen sürümler

Yalnızca mağazadaki **en son** sürüm güvenlik yamalarını alır. Eski sürümler
desteklenmez; güncellemeniz önerilir.

## 8. Bağlantılı belgeler

- [`docs/legal/SIBER_GUVENLIK_PROTOKOLU.md`](docs/legal/SIBER_GUVENLIK_PROTOKOLU.md)
- [`docs/legal/VERI_SILME_VE_BASVURU.md`](docs/legal/VERI_SILME_VE_BASVURU.md)
- [`docs/legal/KVKK_AYDINLATMA_METNI.md`](docs/legal/KVKK_AYDINLATMA_METNI.md)
