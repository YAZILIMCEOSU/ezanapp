# Ezan Vaktim Pro — Üçüncü Taraf SDK, Servis ve Aktarım Envanteri

**Sürüm:** 1.0 · **Tarih:** 12 Kasım 2026
**Amaç:** Mağaza beyanları (Data safety / App Privacy), KVKK m.9 aktarım
kayıtları ve tedarikçi denetimi için tek kaynak.

> Her satırda **gerçek kod davranışı** esas alınmıştır. Yeni SDK eklenirse bu
> dosya, `KVKK_AYDINLATMA_METNI.md` ve mağaza beyanları **aynı PR’da**
> güncellenmelidir.

## 1. Özet tablo

| Servis/SDK | Sağlayıcı | Amaç | Gönderilen veri | Kimlik? | Aktarım | Rıza | Kodda durum |
|---|---|---|---|---|---|---|---|
| Google Mobile Ads (AdMob) + UMP | Google LLC | Reklam, onay yönetimi | AD_ID, IP→yaklaşık konum, cihaz/uygulama bilgisi, reklam etkileşimi | Hayır (reklam kimliği) | ABD/AB | Kişiselleştirme: açık rıza; NPA varsayılan | **Var** (`ads_service.dart`) |
| Supabase (PostgREST/Auth) | Supabase Inc. | Bulut yedekleme | 15 tablo içeriği, anonim UUID | Anonim oturum | AB (Frankfurt) veya ABD | Açık rıza | **Var** (`sync_service.dart`) |
| AI backend (`/ai/ask`) | Proje backend’i | Kaynaklı cevap | Soru, son 6 mesaj, mezhep, kaynak bağlamı | Hayır | Yapılandırmaya göre | Açık rıza | **Var** (`ai_service.dart`) |
| Firebase Cloud Messaging | Google LLC | Push bildirim | FCM jetonu, cihaz bilgisi | Jeton | ABD | Bildirim izni | **Koşullu** (`push_service.dart`) |
| Diyanet vakit servisi (İmsakiyem) | Üçüncü taraf | Resmî vakit | İlçe kimliği, tarih | Hayır | TR | Sözleşme ifası | **Var** (`diyanet_api_source.dart`) |
| AlAdhan API | AlAdhan | Yedek vakit | **Yaklaşık enlem/boylam (2 ondalık, ~1 km)** | Hayır | AB/İngiltere | Sözleşme ifası | **Var** (`aladhan_api_source.dart`) — yuvarlama uygulandı |
| EveryAyah CDN | EveryAyah | Kur’an tilaveti | IP, ayet yolu | Hayır | ABD/AB | Hizmet | **Var** — lisans teyidi gerekli |
| QuranEnc / Tanzil | — | Meal/metin | Yok (paket içi) | — | — | — | **Var** |
| alquran.cloud | AlQuran Cloud | Meal/tefsir çevrimiçi | Sure/edition | Hayır | AB | Hizmet | **Var** (`quran_repository.dart`) |
| OpenStreetMap tile / Overpass | OSM Vakfı / topluluk | Harita, cami arama | Görüntü alanı koordinatları / arama kutucuğu, IP | Hayır | AB | Hizmet | **Var** (`mosque_finder_screen.dart`, harita) |
| Esri ArcGIS tiles | Esri | Uydu harita | Görüntü alanı koordinatları, IP | Hayır | ABD | Hizmet | **Var** (`qibla_screen.dart`) |
| cdn.jsdelivr.net (GitHub) | jsDelivr | Uzak ilahi/ezan akışı | IP, dosya yolu | Hayır | ABD | — | **Var** — lisanssız, kaldırılmalı |
| Google Maps (dış link) | Google | Yol tarifi | Yalnızca kullanıcı tıklarsa | — | ABD | Kullanıcı eylemi | **Var** |

## 2. Veri akışları

```
Cihaz
 ├─ Konum ──► yerel vakit/kıble hesabı        (koordinat sunucuya gitmez)
 ├─ İlçe kimliği ──► Diyanet servisi          (koordinat yok)
 ├─ Konum (yedek) ──► AlAdhan                 (koordinat — 2 ondalığa yuvarlanmalı)
 ├─ Harita ekranı ──► OSM/Esri tile            (görüntü alanı)
 ├─ Cami ara ──► Overpass                     (arama kutucuğu)
 ├─ AI sorusu ──► AI backend                  (yalnızca rıza ile)
 ├─ Yedek ──► Supabase                        (yalnızca rıza ile)
 └─ Reklam ──► AdMob                          (kişiselleştirme varsayılan kapalı)
```

## 3. SDK envanteri (paket bazlı)

| Paket | Sürüm kaynağı | Veri erişimi | Not |
|---|---|---|---|
| `google_mobile_ads` | pubspec | Reklam kimliği, ağ | UMP onayı öncesi yükleme yok |
| `supabase_flutter` | pubspec | Ağ, güvenli depolama | Anonim oturum |
| `firebase_core`, `firebase_messaging` | pubspec | Push jetonu | Yapılandırılmazsa kapalı |
| `geolocator` | pubspec | Konum | Yalnızca ön planda |
| `flutter_local_notifications` | pubspec | Bildirim | Yerel |
| `just_audio`, `audio_service` | pubspec | Medya | Yerel/uzak ses |
| `url_launcher` | pubspec | Dış link | Kullanıcı eylemi |
| `flutter_map` (leaflet benzeri) | pubspec | Harita tile | Ağ |
| `http`, `dio` | pubspec | Ağ | TLS |

> Tam liste `pubspec.lock` ve `flutter pub deps` çıktısından üretilir; CI
> adımı `flutter pub deps --style=compact` çıktısını arşivler.

## 4. Aktarım hukuki dayanağı ve mekanizma

| Aktarım | Ülke | Yeterlilik kararı | Mekanizma | Bildirim |
|---|---|---|---|---|
| AdMob | ABD | Yok | Standart sözleşme + DPA | 5 iş günü |
| Supabase | AB/ABD | AB için GDPR yeterliliği; TR Kurul kararı yok | Standart sözleşme + DPA | 5 iş günü |
| AI backend | Değişken | Yok | Standart sözleşme + saklama yasağı | 5 iş günü |
| Firebase | ABD | Yok | Standart sözleşme + DPA | 5 iş günü |
| jsDelivr | ABD | Yok | **Kaldırılacak** (lisans yok) | — |

**Standart sözleşme:** Kurul’un 2024/… model sözleşmesi kullanılır; imzadan
sonra 5 iş günü içinde Kurum’a bildirilir. Sözleşme kopyaları özel arşivde
saklanır (depoya commit edilmez).

## 5. Tedarikçi denetim soruları

Her yeni tedarikçi için:

1. Veri işleyen sıfatı ve DPA var mı?
2. Alt işleyenler kimler, hangi ülkelerde?
3. Veri saklama süresi ve silme API’si var mı?
4. İhlal bildirimi süresi (bize kaç saat içinde bildirir)?
5. Şifreleme (aktarım/dinlenme) ve erişim kontrolü?
6. Denetim raporu (SOC 2/ISO 27001) var mı?
7. Çocuk verisi ve reklam kullanımı politikası?
8. Model eğitimi için veri kullanımı (AI için **hayır** olmalı)?

## 6. Kaldırılacak / düzeltilecekler (öncelik)

| # | Konu | Risk | Aksiyon | Öncelik |
|---|---|---|---|---|
| 1 | `cdn.jsdelivr.net` üzerinden ilahi/ezan akışı | Telif + kaynak belirsizliği | Yerel lisanslı varlıkla değiştir veya kaldır | **P0** |
| 2 | AlAdhan’a tam koordinat | Gizlilik beyanıyla çelişki | **Yapıldı:** 2 ondalığa yuvarlandı + politikada belirtildi | **P0** |
| 3 | EveryAyah ticari kullanım teyidi | Lisans uyumsuzluğu | Yazılı izin/alternatif kaynak | **P1** |
| 4 | AdMob kişiselleştirme varsayılanı | UMP/consent uyumu | **Yapıldı:** varsayılan NPA (`nonPersonalizedAds: true`); rıza ile açılır | **P0 ✓** |
| 5 | Supabase RLS doğrulaması | Veri sızıntısı | Politikaları test et | **P0** |
| 6 | AI sağlayıcısında saklama | KVKK m.9 | Zero-retention sözleşmesi | **P1** |
| 7 | Firebase jetonu | Veri minimizasyonu | Yapılandırma yoksa paketleri devre dışı bırak | **P2** |
| 8 | OSM/Esri tile kullanımı | Kullanım koşulları | Atıf + kullanım limiti | **P2** |

## 7. Mağaza beyanıyla eşleştirme

- Play **Data safety** → `GOOGLE_PLAY_UYUM.md` §2
- Apple **App Privacy** → `APPLE_APP_STORE_UYUM.md` §2.3
- Gizlilik politikası → `KVKK_AYDINLATMA_METNI.md`

Üç belge aynı veri türlerini, aynı amaçları ve aynı “isteğe bağlı” bayraklarını
kullanmalıdır. CI’da metin karşılaştırma testi hedeflenir.

## 8. Sürüm geçmişi

| Tarih | Değişiklik |
|---|---|
| 12 Kasım 2026 | İlk sürüm; AdMob, Supabase, AI, FCM, harita, AlAdhan envanteri |
