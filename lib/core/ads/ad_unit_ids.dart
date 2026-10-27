/// Google AdMob **resmî test reklam birim kimlikleri**.
///
/// * Bu kimlikler gerçek gelir üretmez, tıklamalar Google tarafından korunur.
/// * Play Store'a yüklenen **yayın** sürümünde asla kullanılmaz; yayında
///   `docs/FREE_REKLAMLI_PAKET_VE_PREMIUM_REHBERI.md` içindeki adımlarla
///   kendi AdMob birim kimlikleriniz `--dart-define` ile verilir.
/// * `ADMOB_TEST_MODE=true` ile derlenen paketlerde (ve `kDebugMode`
///   derlemelerinde) reklamlar bu kimliklerle çalışır; böylece reklam
///   yerleşimleri gerçek cihazda güvenle test edilebilir.
abstract final class AdUnitIds {
  /// Android uygulama kimliği (AndroidManifest `APPLICATION_ID`).
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';

  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewarded = 'ca-app-pub-3940256099942544/5224354917';
}
