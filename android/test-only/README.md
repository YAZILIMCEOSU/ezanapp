# TEST ONLY — herkese açık deneme anahtarı

`ezanai-test.p12` yalnızca **`dene-apk` deneme sürümünü** imzalamak için
kullanılır. Amaç: her CI koşusunda imzanın değişmesini engellemek. İmza
değişince Android, kurulu uygulamanın üzerine güncelleme yapmıyor ve
“Uygulama yüklenmedi” hatası veriyor.

| Alan | Değer |
|---|---|
| Dosya | `ezanai-test.p12` (PKCS#12) |
| Takma ad | `ezanai-test` |
| Parola | `ezanai-test` |
| Geçerlilik | 2056-11-05 |
| SHA-256 (sertifika) | `4512f5855ac02d76bfe5a094fa54a95171daf76cfbf421fa00f1d28d11e6ffc5` |

> ⚠️ **BU ANAHTAR KAMUYA AÇIKTIR.** Depo herkese açık olduğu için parola ve
> anahtar herkes tarafından okunabilir. Bu yüzden:
>
> - **Google Play'e ASLA yüklenmez.** Play yüklemesi `release-signed.yml`
>   içindeki `KEYSTORE_BASE64` gizli değişkeniyle yapılır.
> - Bu anahtarla imzalanmış APK yalnızca deneme/QA amaçlıdır.
> - CI her derlemede parmak izini `SHA256.txt` ile karşılaştırır; değişirse
>   iş düşer (yanlışlıkla anahtar değiştirme koruması).
