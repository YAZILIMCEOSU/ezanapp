# Ezan Vaktim Pro — Açık Rıza Metinleri

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Veri sorumlusu:** YazılımCeosu — destek@ezanai.app
**İlgili metin:** [`KVKK_AYDINLATMA_METNI.md`](KVKK_AYDINLATMA_METNI.md)

Bu dosyadaki rızalar **birbirinden ayrıdır**. Birine “evet” demek diğerlerini
kabul etmek anlamına gelmez. Her rıza, uygulama içinden aynı kolaylıkla geri
çekilebilir. Rıza vermemek uygulamanın temel özelliklerini kullanmanızı
engellemez.

Rıza kaydı cihazda **tarih/saat damgasıyla** saklanır
(`aiConsentAt`, `backupConsentAt`, `personalizedAdsConsentAt`). Sunucuya rıza
kaydı gönderilmez.

---

## A. Yapay zekâ asistanına uzak soru gönderme (özel nitelikli veri)

**Kutucuk metni:**

> ☐ Yapay zekâ asistanına yazdığım soruların, son 6 mesajlık sohbet
> bağlamının ve seçtiğim mezhep tercihinin, cevap üretmek amacıyla yurt
> dışındaki yapay zekâ sunucularına aktarılmasına **açık rıza veriyorum**.
> Sorularım dinî inanç/ibadet bilgisi içerebilir. Kimliğimle
> ilişkilendirilmediğini, kalıcı olarak saklanmaması için sözleşmeyle
> güvence sağlandığını biliyorum. Rızamı istediğim zaman geri çekebilirim.

**Kapsam:**

- Soru metni ve varsa son 6 mesaj (yalnızca bağlam için),
- `madhab: hanefi` tercihi (varsayılan; kullanıcı değiştirebilir),
- doğrulanmış kaynaklardan seçilen kısa alıntılar (`retrieved_context`),
- yanıtın üretildiği sağlayıcıya ait teknik istek bilgileri (IP, cihaz/uygulama
  sürümü — sağlayıcı politikasına tabi).

**Amaç:** Kaynak gösteren cevap üretmek. Pazarlama, profilleme veya reklam
hedeflemesi **yapılmaz**.

**Saklama:** Cevap üretimiyle sınırlıdır; sağlayıcıda kalıcı saklama
hedeflenmez. Sohbet geçmişi yalnızca cihazınızda tutulur.

**Geri çekme:** Ayarlar → Gizlilik ve rızalar → “Yapay zekâ uzak erişimi”
kapat. Kapatıldığında sorular yalnızca çevrimdışı, önceden doğrulanmış bilgi
tabanına gider; uzak servise hiçbir metin gönderilmez.

**Rıza vermezseniz:** AI asistanı çevrimdışı bilgi tabanıyla çalışmaya devam
eder. Bazı ayrıntılı sorulara “çevrimdışı kaynakta bulunamadı” yanıtı gelir.

---

## B. Bulut yedekleme (özel nitelikli veri + yurt dışı aktarım)

**Kutucuk metni:**

> ☐ Favorilerim, okuma ilerlemem, zikir/hatim/kaza orucu/Ramazan kayıtlarım ve
> yapay zekâ sohbetlerimin, cihaz değişiminde geri yükleyebilmem için **anonim
> bir kimlikle** yurt dışındaki Supabase sunucularına yedeklenmesine **açık
> rıza veriyorum**. Bu veriler dinî inanç/ibadet bilgisi içerebilir. Yedeğin
> TLS ile şifrelendiğini ve yalnızca benim anonim kimliğimin erişebildiğini
> biliyorum. Rızamı geri çekebilir, sunucudaki yedeği silebilirim.

**Yedeklenen tablolar:** `quran_bookmarks`, `reading_progress`,
`hadith_favorites`, `zikir_daily`, `zikir_sessions`, `zikir_custom`,
`ilahi_favorites`, `ilahi_recents`, `playlists`, `playlist_items`,
`hatim_progress`, `kaza_fasts`, `ramadan_log`, `ai_conversations`,
`ai_messages`.

**Yedeklenmeyenler:** konum koordinatı, e-posta, ad-soyad, telefon, ödeme
bilgisi, reklam kimliği.

**Saklama:** Siz silene kadar; hesap/cihaz hareketsizliğinde hedef en fazla
24 aydır. Silme: Ayarlar → Bulut yedekleme → **Sunucudaki yedeği sil** veya
destek@ezanai.app.

**Geri çekme:** Aynı ekrandan oturumu kapatmak ve sunucudaki yedeği silmek
yeterlidir. Rıza geri çekildiğinde yeni yedek yüklenmez.

**Rıza vermezseniz:** Yerel kullanım ve dosya olarak yedekleme (Ayarlar →
Yedekleme) çalışmaya devam eder; bulut yedeği kapalı kalır.

---

## C. Kişiselleştirilmiş reklamlar

**Kutucuk metni:**

> ☐ Ücretsiz sürümde gördüğüm reklamların ilgi alanlarıma göre
> kişiselleştirilmesi için reklam kimliğimin (AD_ID), IP’den türetilen
> yaklaşık konumun ve reklam etkileşimlerimin Google AdMob tarafından
> işlenmesine **açık rıza veriyorum**. Reklamların dinî inanç, siyasi görüş
> veya sağlık durumuna göre hedeflenmeyeceğini biliyorum. Rızamı istediğim
> zaman geri çekebilirim.

**Varsayılan:** **Kapalı.** Kapatıkken Google’a `npa=1` (kişiselleştirilmemiş
reklam) sinyali gönderilir. Premium’da hiç reklam gösterilmez.

**Kapsam:** reklam kimliği, IP, yaklaşık konum, cihaz/uygulama bilgisi, reklam
gösterimi/tıklama olayları. Amaç: reklam gösterimi, sıklık sınırı, sahtekârlık
önleme ve ölçüm.

**Geri çekme:** Ayarlar → Veri ve gizlilik → **Açık rızalarım (KVKK)** →
“Kişiselleştirilmiş reklamlar” anahtarını kapat; ayrıca cihaz ayarlarından
reklam kimliğini sıfırla/sil. AB/AEA kullanıcıları için UMP “Gizlilik
ayarları” ekranı da kullanılabilir.

**Rıza vermezseniz:** Reklamlar kişiselleştirilmeden gösterilir veya reklam
altyapısı kapatılır; uygulama işlevleri etkilenmez.

---

## D. Bildirimler (izin — açık rıza değil)

Bildirimler hizmetin parçasıdır ve Android 13+/iOS izin penceresiyle sorulur.
Pazarlama amaçlı bildirim gönderilmez. İzni sistem ayarlarından veya uygulama
içi “Bildirimler” ekranından kapatabilirsiniz.

## E. Destek yazışması

destek@ezanai.app adresine yazdığınızda e-posta adresiniz ve yazışma içeriği,
talebinizi yanıtlamak ve yasal kayıt için 2 yıl saklanır. Talebiniz üzerine
silinir; yasal saklama zorunluluğu olan kayıtlar hariçtir.

---

## Rızanın hukuki niteliği

- Rıza, **belirli bir konuya ilişkin, bilgilendirilmiş ve özgür iradeyle**
  açıklanır (KVKK m.3/1-a).
- Rıza vermek için uygulamanın tamamını kabul etmek gerekmez; hizmetler
  birbirinden ayrıdır.
- Rıza geri çekildiğinde, geri çekmeden önce hukuka uygun yapılan işlemler
  etkilenmez.
- Rıza metinleri sürümlenir; metin değişirse yeniden rıza istenir.
- 18 yaş altı kullanıcılar için yasal temsilci onayı gerekir.

## Uygulama içi erişim

- **Ayarlar → Gizlilik ve rızalar** (rıza yönetimi)
- **Ayarlar → Bildirimler** (izin durumu ve test)
- **Ayarlar → Bulut yedekleme** (yedekleme ve sunucudan silme)
- **Hakkında → KVKK / Gizlilik / Kullanım koşulları**
