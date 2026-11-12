# Ezan Vaktim Pro — Yasal ve Uyum Paketi

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Hizmet sağlayıcı:** YazılımCeosu (gerçek kişi geliştirici), İstanbul
**İletişim:** destek@ezanai.app
**Uygulama:** `com.yazilimceosu.ezanai`

Bu klasör, uygulamanın Google Play ve Apple App Store politikalarına, 6698
sayılı KVKK’ya, 6502 sayılı Tüketicinin Korunması Kanunu’na ve 7545 sayılı
Siber Güvenlik Kanunu’na uyumunu belgeleyen **tek kaynak**tır.

> **Hukuki uyarı:** Bu belgeler bilgilendirme amaçlıdır ve hukuki görüş
> yerine geçmez. Yayından önce bir avukat tarafından gözden geçirilmelidir.

## 1. Belgeler

| # | Belge | Kapsam | Hedef kitle |
|---|---|---|---|
| 1 | [KVKK Aydınlatma ve Gizlilik](KVKK_AYDINLATMA_METNI.md) | Veri sorumlusu, veri türleri, amaç, aktarım, haklar | Tüm kullanıcılar, Play/Apple |
| 2 | [Açık Rıza Metinleri](ACIK_RIZA_METINLERI.md) | AI, bulut yedekleme, reklam rızaları | Kullanıcı, ürün |
| 3 | [Kullanım Koşulları (EULA)](KULLANIM_KOSULLARI.md) | Lisans, dinî içerik sınırı, sorumluluk, Apple şartları | Kullanıcı, mağaza |
| 4 | [Abonelik ve İade](ABONELIK_VE_IADE.md) | Fiyat, otomatik yenileme, cayma, iade | Kullanıcı, mağaza |
| 5 | [Veri Envanteri (ROPA)](VERI_ENVANTERI_ROPA.md) | İşleme kayıtları, alıcılar, saklama, VERBİS | KVKK, denetim |
| 6 | [Veri Silme ve Başvuru](VERI_SILME_VE_BASVURU.md) | Silme kanalları, SLA, haklar | Kullanıcı, KVKK |
| 7 | [Üçüncü Taraf SDK ve Aktarımlar](UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md) | SDK envanteri, yurt dışı aktarım | KVKK, mağaza |
| 8 | [Ses ve İçerik Lisansları](SES_VE_ICERIK_LISANSLARI.md) | Telif, atıf, yanıltıcı beyan riski | Hukuk, içerik |
| 9 | [Google Play Uyum](GOOGLE_PLAY_UYUM.md) | Data safety, izinler, AI, abonelik | Play Console |
| 10 | [Apple App Store Uyum](APPLE_APP_STORE_UYUM.md) | Privacy label, xcprivacy, ATT, IAP | App Store Connect |
| 11 | [Siber Güvenlik Protokolü](SIBER_GUVENLIK_PROTOKOLU.md) | Olay müdahale, 72 saat, 7545 | Geliştirici, denetim |
| 12 | [Yayın Kontrol Listesi](YAYIN_UYUMLULUK_KONTROL_LISTESI.md) | P0/P1 maddeleri, imza | Yayın sorumlusu |
| 13 | [Teknik Düzeltme Planı](TEKNIK_DUZELTME_PLANI.md) | Kod değişiklikleri, testler | Geliştirici |
| 14 | [Rakip Uyum Karşılaştırması](RAKIP_UYUM_KARSILASTIRMA.md) | Muslim Pro/Ezan Vakti/Athan uyum kıyası | Ürün, pazarlama |

## 2. Yayın (web) sayfaları

`docs/` altında GitHub Pages ile yayımlanır:

- `privacy.html` — gizlilik politikası (Play/Apple zorunlu)
- `kvkk.html` — KVKK aydınlatma
- `acik-riza.html` — açık rıza metinleri
- `terms.html` — kullanım koşulları
- `abonelik.html` — abonelik ve iade
- `veri-silme.html` — veri silme
- `guvenlik.html` — güvenlik ve olay bildirimi
- `yasal.html` — dizin

Sayfalar `tools/build_legal_pages.py` ile Markdown’dan üretilir. **Elle
düzenlemeyin**; Markdown kaynağını güncelleyip betiği çalıştırın.

Yayın için **bir kez** GitHub → Settings → Pages → Source:
**Deploy from a branch** → Branch: `main`, Folder: `/docs` → Save yapılır.
Sonraki güncellemeler `main` dalına push edildiğinde otomatik yayımlanır.

## 3. Yayın öncesi tek sayfa özet

1. **P0:** Gizlilik/KVKK/koşullar sayfaları canlı ve 200.
2. **P0:** Data safety / App Privacy beyanları kodla aynı.
3. **P0:** Rızasız uzak AI ve bulut yedekleme **çalışmıyor**.
4. **P0:** Tüm ses etiketleri doğru; lisanssız kayıt yok.
5. **P0:** Target API 36; imza ve sürüm doğru.
6. **P1:** iOS projesi + `PrivacyInfo.xcprivacy`.
7. **P1:** EveryAyah ticari kullanım teyidi.

Ayrıntı: [Yayın Kontrol Listesi](YAYIN_UYUMLULUK_KONTROL_LISTESI.md).

## 4. Bakım kuralları

- Her yeni SDK/özellik → ROPA + SDK envanteri + mağaza beyanı + bu README.
- Metin değişikliği → sürüm numarası + tarih + `git` kaydı.
- Rıza metni değişirse kullanıcıdan **yeniden rıza** alınır.
- Lisans kanıtı olmayan içerik yayınlanmaz.
- Yasal metinlerdeki bir ifade kodla çelişiyorsa **kod değil, ikisi birlikte**
  düzeltilir; çelişki kapatılmadan yayın yapılmaz.

## 5. Sürüm geçmişi

| Sürüm | Tarih | Değişiklik |
|---|---|---|
| 1.0 | 12 Kasım 2026 | İlk tam paket: KVKK, EULA, Play, Apple, güvenlik, lisanslar |
