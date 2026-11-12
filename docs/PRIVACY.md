# Ezan Vaktim Pro — Gizlilik Politikası (özet)

**Son güncelleme:** 12 Kasım 2026
**Veri sorumlusu:** YazılımCeosu — destek@ezanai.app
**Kanonik metin:** [`legal/KVKK_AYDINLATMA_METNI.md`](legal/KVKK_AYDINLATMA_METNI.md)
**Yayın sayfası:** `https://yazilimceosu.github.io/ezanapp/privacy.html`

> Bu dosya yalnızca hızlı özettir. Mağaza ve hukuki metin olarak **kanonik
> belge** yukarıdaki KVKK aydınlatma metnidir. İki metin çelişirse kanonik
> belge geçerlidir; çelişki ivedilikle giderilir.

## Kısa özet

- **Hesap gerekmez.** Temel özellikler hesap açmadan çalışır.
- **Konum cihazda işlenir.** Namaz vakti ve kıble hesabı cihazda yapılır.
  Koordinat vakit servisine gönderilmez; yalnızca seçilen ilçe kimliği
  gönderilir. Diyanet servisine ulaşılamazsa **yaklaşık koordinat (2 ondalık,
  ~1 km)** AlAdhan servisine iletilir.
- **Yerel veriler** (favoriler, okuma ilerlemesi, zikir, hatim/kaza, Ramazan,
  AI sohbetleri) cihazdaki SQLite’ta saklanır.
- **Uzak AI isteğe bağlıdır** ve **ayrı açık rıza** gerektirir. Rıza yoksa
  hiçbir soru metni sunucuya gitmez; çevrimdışı bilgi tabanı kullanılır.
- **Bulut yedekleme isteğe bağlıdır** ve **ayrı açık rıza** gerektirir.
  Anonim Supabase kimliği, TLS ve satır düzeyi güvenlik (RLS) kullanılır.
  Uçtan uca şifreleme (E2EE) **değildir**; sunucu veriyi işleyebilir.
- **Reklamlar** yalnızca ücretsiz sürümde, Google AdMob ile; kişiselleştirme
  UMP onayına bağlıdır ve varsayılan olarak kişiselleştirilmemiştir.
  Premium’da reklam yoktur.
- **Analitik/çökme SDK’sı yoktur.** Ayarlardaki anahtarlar varsayılan
  **kapalıdır**; ileride SDK eklenirse rıza ve mağaza beyanı güncellenir.
- **Ödeme kartı bilgisi bize ulaşmaz**; ödeme Google Play/App Store’dadır.
- **Silme:** Ayarlar → Verilerimi sil; Ayarlar → Bulut yedekleme →
  Sunucudaki yedeği sil; destek@ezanai.app (30 gün).

## İşlenen veriler (özet)

| Veri | Amaç | Yer | Rıza |
|---|---|---|---|
| Konum / ilçe | Vakit, kıble | Cihaz; ilçe kimliği vakit servisi | İzin |
| Yerel içerik | Uygulama işlevi | Cihaz | — |
| AI soru + son 6 mesaj | Cevap üretimi | Cihaz + (rıza varsa) AI backend | **Açık rıza** |
| Yedek paketi + UUID | Geri yükleme | Supabase | **Açık rıza** |
| AD_ID / IP / reklam etkileşimi | Reklam | Google AdMob | UMP; kişiselleştirme rıza |
| Abonelik durumu | Premium | Google/Apple | Sözleşme |
| Destek e-postası | Destek | E-posta sağlayıcı | Meşru menfaat |

## Haklar ve başvuru

KVKK m.11 hakları için destek@ezanai.app — konu “KVKK”. Talepler en geç
**30 gün** içinde ücretsiz yanıtlanır. Ayrıntı, saklama süreleri, yurt dışı
aktarım ve VERBİS değerlendirmesi:

- [`legal/KVKK_AYDINLATMA_METNI.md`](legal/KVKK_AYDINLATMA_METNI.md)
- [`legal/ACIK_RIZA_METINLERI.md`](legal/ACIK_RIZA_METINLERI.md)
- [`legal/VERI_ENVANTERI_ROPA.md`](legal/VERI_ENVANTERI_ROPA.md)
- [`legal/VERI_SILME_VE_BASVURU.md`](legal/VERI_SILME_VE_BASVURU.md)
- [`legal/UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md`](legal/UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md)

## English summary

No account is required. Location is processed on-device for prayer times and
qibla; only the selected district ID is sent to the prayer-times service, and
if that service is unavailable an **approximate coordinate (2 decimals, ~1 km)**
is sent to AlAdhan. Remote AI and cloud backup are **opt-in with separate
explicit consent**; without consent the app stays offline/local. Cloud backup
uses TLS and row-level security, and is **not** end-to-end encrypted. Ads are
served only in the free tier via Google AdMob, non-personalized by default.
There is no analytics/crash SDK. Payments are handled by Google Play/App Store.
Delete data in-app or email destek@ezanai.app (response within 30 days).
