# Ezan Asistanı Pro — Veri Silme, Erişim ve Başvuru Prosedürü

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Veri sorumlusu:** YazılımCeosu — destek@ezanai.app
**Yasal dayanak:** KVKK m.7, m.11, m.13; Silme/Yok Etme/Anonimleştirme
Yönetmeliği; GDPR m.17 (uygulanabildiği ölçüde).
**Hedef yanıt süresi:** En geç **30 gün** (ücretsiz).

## 1. Silme kanalları

| Kanal | Kapsam | Süre | Durum |
|---|---|---|---|
| Ayarlar → Verilerimi sil | Cihazdaki tüm uygulama verisi | Anında | Uygulama içi |
| Ayarlar → Bulut yedekleme → Sunucudaki yedeği sil | Supabase yedeği + anonim oturum | Anında | Uygulama içi |
| Sohbet → Sohbeti sil | Tek AI sohbeti | Anında | Uygulama içi |
| destek@ezanai.app | Tüm veriler / özel talep | 30 gün | E-posta |
| `.../veri-silme.html` | Talep formu (e-posta oluşturur) | 30 gün | Web |

> Not: Uygulama hesap oluşturmadığı için “hesabı sil” adımı yoktur. Anonim
> bulut kimliği, yedek silindiğinde oturum kapatılarak etkisizleştirilir.

## 2. Uygulama içi silme adımları (kullanıcıya birebir)

1. **Ayarlar → Gizlilik ve veriler → Verilerimi sil**.
2. Onay penceresinde “Sil” seçilir.
3. Uygulama; yerel veritabanı tablolarını, ayarları, AI sohbetlerini,
   favorileri ve indirilmiş özel sesleri siler.
4. Ekranda “Verileriniz silindi” bildirimi görünür.
5. Bulut yedeği ayrıca silinmek istenirse:
   **Ayarlar → Bulut yedekleme → Sunucudaki yedeği sil → Onayla**.
6. Uygulama kaldırılırsa cihaz verisi işletim sistemi tarafından silinir
   (Android/iOS uygulama alanı).

**Silinmeyenler:** mağaza satın alma kayıtları (Google/Apple’da), yasal
saklama yükümlülüğü olan destek kayıtları (2 yıl), yedeklerdeki anonim teknik
loglar (en fazla 6 ay).

## 3. E-posta ile başvuru

**Adres:** destek@ezanai.app
**Konu:** `KVKK Veri Silme Talebi`

Aşağıdaki bilgiler istenir (hesap olmadığı için kimlik doğrulama sınırlıdır):

- Talep türü: silme / düzeltme / erişim / itiraz,
- Uygulama sürümü ve platform (Android/iOS),
- Varsa anonim yedek kimliği (Ayarlar → Bulut yedekleme ekranında görünen
  kısa kimlik) — yalnızca bulut yedeğini silmek için,
- Talebin kapsamı (tüm veriler / belirli kategori).

**Kimlik doğrulama:** E-posta adresiniz destek kaydıyla eşleşmiyorsa ek bilgi
istenebilir. Yanlış kişinin verisini silmemek için gerekli asgari doğrulama
yapılır; gereksiz kimlik belgesi istenmez.

## 4. İşlem akışı ve SLA

| Adım | Süre |
|---|---|
| Talebin alındı bildirimi | 2 iş günü |
| Kimlik/kapsam doğrulama | 5 iş günü |
| Silme/düzeltme uygulaması | 30 gün (en geç) |
| Sonuç bildirimi | İşlemle birlikte |
| İtiraz | Sonuç bildiriminden 15 gün içinde |

Reddedilen taleplerde gerekçe ve KVKK m.14 kapsamında Kurul’a başvuru yolu
bildirilir.

## 5. Yedeklerden silme

- Supabase günlük yedekleri 30 günlük döngüyle silinir; silme talebi bu
  döngü sonunda tüm yedeklere yansır.
- Aktif yedek derhâl silinir; pasif kopyalar en geç 30 gün içinde temizlenir.
- Silme işlemi kaydı (kimlik bilgisi olmadan) 3 yıl saklanır.

## 6. Üçüncü taraflarda silme

| Taraf | Yöntem | Not |
|---|---|---|
| Google AdMob | Cihaz ayarları → Reklam kimliğini sil/sıfırla; Google Hesabım | Geçmiş reklam verisi Google politikalarına tabi |
| Google Firebase | Bildirim iznini kapat / uygulama verisini sil | Jeton geçersizleşir |
| Supabase | Uygulama içi yedek silme | Anonim kimlik etkisiz |
| AI sağlayıcısı | Kalıcı saklama yok; saklama varsa 30 gün içinde silinir | Sözleşme gereği |

## 7. Erişim ve taşınabilirlik

Kullanıcı, verilerinin bir kopyasını isteyebilir:

- **Ayarlar → Yedekleme → Dosyaya aktar** ile JSON yedeği alınır.
- E-posta talebiyle 30 gün içinde makine okunabilir kopya (JSON) sağlanır.
- AI sohbetleri ve favoriler dahil edilir; üçüncü taraf verileri hariçtir.

## 8. Düzeltme

- Kullanıcı içeriği (favori, not, zikir) uygulama içinden düzenlenebilir.
- Destek kaydındaki hatalı bilgi e-posta ile düzeltilir.
- Düzeltme, aktarıldığı üçüncü kişilere bildirilir (KVKK m.11).

## 9. Özel durumlar

- **Çocuk verisi:** 13 yaş altı olduğu tespit edilirse veri derhâl silinir.
- **Yasal saklama:** Vergi/ticaret mevzuatı gereği saklanması zorunlu kayıtlar
  (varsa) silinmez; kullanıcıya gerekçesi bildirilir.
- **Abonelik:** Veri silme, aboneliği iptal etmez. Abonelik mağazadan iptal
  edilir; kullanıcıya bu uyarı gösterilir.
- **Silme sonrası:** Uygulama ilk açılış durumuna döner; bazı özellikler
  yeniden kurulum gerektirebilir.

## 10. Kayıt ve denetim

Her talep için: tarih, kanal, kapsam, yapılan işlem, sonuç, sorumlu kişi.
Kayıtlar kişisel veri içermeden 3 yıl saklanır; yıllık denetimde gözden
geçirilir.

## 11. İletişim

**destek@ezanai.app** · Konu: `KVKK`
**Web:** `.../veri-silme.html`
**Posta:** İstanbul, Türkiye (tam adres talep üzerine)

---

### English summary

You can delete all local data via Settings → Delete my data, and delete the
cloud backup via Settings → Cloud backup → Delete server backup. You may also
email destek@ezanai.app; requests are answered within 30 days free of charge.
Deleting data does not cancel a subscription. Store purchase records and
legally required records are retained by the respective store/authority.
