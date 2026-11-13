# Kalite kapısı — her istekte hata taraması

Bu belge, EzanAI deposunda **her kullanıcı isteğinde** uygulanan kalıcı
kontrolün tanımıdır. Ajan talimatı: [`AGENTS.md`](../AGENTS.md).

## Neden kalıcı?

Geçmişte bildirim, vakit kayması ve bozuk veri hataları tek tek bildirildi.
Tek seferlik düzeltme yeterli olmadı; her değişiklikte aynı hata sınıflarının
yeniden oluşmadığını kanıtlamak gerekiyor. Bu yüzden kontrol, hatırlamaya
değil **otomatik kapıya** bağlıdır.

## Kapının adımları

| # | Kontrol | Komut | Kırmızıysa |
|---|---|---|---|
| 1 | Biçim | `dart format --set-exit-if-changed lib test` | `dart format lib test` |
| 2 | Statik analiz | `flutter analyze --no-pub` | Uyarıyı koda düzelt, `// ignore` ekleme |
| 3 | Testler | `flutter test --no-pub` | Testi veya kodu düzelt; testi silme |
| 4 | Test keşfi | CI'da en az **300** test sayılır | Test dosyası/dizini bozulmuştur |
| 5 | Kıble | `python3 tools/verify_qibla.py` (6 kontrol) | Astronomi/manyetik sabitlerini kontrol et |
| 6 | Uzak AI sözleşmesi | `flutter test test/data/ai_remote_test.dart --dart-define=EZANAI_API_BASE=...` | Zarif bozulma ve kaynak zorunluluğu |
| 7 | Derleme | `flutter build apk --release` + `appbundle` | Gradle/Kotlin/ProGuard hatası |
| 8 | İmza | `apksigner verify --print-certs` | İmza yapılandırması |

Bu adımların tamamı `.github/workflows/analyze.yml` içinde koşar; sonuç
`.ci/report.md` dosyasına yazılır ve her push'ta güncellenir. İşlerden biri
kırmızıysa iş **başarısız** olur (`.ci` raporu yine yazılır).

## Her istekte ajan ne yapar?

1. `git fetch origin` ile dalı senkronlar.
2. `bash tools/quality_gate.sh` çalıştırır (SDK varsa) veya CI'ya push eder.
3. Hata varsa **aynı turda** düzeltir; her düzeltme için test ekler.
4. `gh run watch <id> --exit-status` ile yeşili görür.
5. Türkçe, tıklama düzeyinde rapor verir: hata → düzeltme → telefonda doğrulama.

## Kanıt standardı

- "Düzeldi" demek için: **yeşil CI + en az bir test + telefonda adım**.
- "Sorunsuz" demek için: yukarıdakilerin üçü de tamam.
- Flutter SDK'nın bulunmadığı bir ortamda yalnızca CI kanıt sayılır; yerel
  test uydurulmaz.

## Sık dönen hata sınıfları ve kapıdaki karşılığı

| Hata sınıfı | Yakalayan kontrol |
|---|---|
| Bildirim kurulmuyor / simge geçersiz | Test + APK derlemesi + `ic_stat_ezan` kaynağı |
| Saat dilimi / yaz saati kayması | `test/core/timezone_resolution_test.dart`, `notification_plan_test.dart` |
| Bozuk önbellek/ayar verisi | `test/data/robustness_test.dart` |
| Çift ezan | `notification_plan_test.dart` + `suppressSystemAdhan` |
| Kıble sapması | `tools/verify_qibla.py` (6 bağımsız kontrol) |
| Kotlin/Dart sözleşme uyumsuzluğu | APK + AAB derlemesi, `MethodChannel` testleri |

## CI sonucunu okuma

```bash
gh run list --branch arena/01a1057d-ezanapp --limit 1
gh run watch <run-id> --exit-status
git show origin/arena/01a1057d-ezanapp:.ci/report.md | sed -n 1,20p
```

Rapor tablosunda `test` satırı `success`, `analyze` satırı `success` ve
`build (debug apk)` satırı `success` olmalıdır. APK boyutu raporda ve
`dene-apk` sürümünde görünür.
