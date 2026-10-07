import '../constants/app_constants.dart';

/// Derleme zamanı yapılandırması.
///
/// **Güvenlik:** Hiçbir sır (API anahtarı, servis anahtarı) uygulama içine
/// gömülmez. Tüm ağ istekleri kendi backend'imiz üzerinden yapılır; backend
/// yapılandırılmadıysa ilgili özellikler kullanıcıya açıkça "yapılandırılmadı"
/// durumu gösterir ve uygulamanın geri kalanı çalışmaya devam eder.
///
/// Kullanım:
/// ```
/// flutter build apk --dart-define=EZANAI_API_BASE=https://api.ezanai.app \
///   --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=... \
///   --dart-define=ADMOB_BANNER_ID=ca-app-pub-xxx/yyy
/// ```
abstract final class AppConfig {
  /// Kendi backend adresi (AI asistan, katalog, senkronizasyon).
  static const String apiBaseUrl = String.fromEnvironment(
    'EZANAI_API_BASE',
    defaultValue: '',
  );

  /// Supabase (bulut senkronizasyon + kimlik doğrulama). Anon anahtarı
  /// herkese açık olacak şekilde tasarlanmıştır; yetki RLS ile sınırlanır.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Firebase: `google-services.json` eklendiğinde otomatik etkinleşir.
  static const bool firebaseEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: false,
  );

  /// İlahi/dini ses kataloğu (lisanslı içerik sağlayıcı uç noktası).
  static const String ilahiCatalogUrl = String.fromEnvironment(
    'ILAHI_CATALOG_URL',
    defaultValue: '',
  );

  /// AdMob birim kimlikleri — boşsa reklamlar tamamen devre dışı kalır.
  static const String admobBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: '',
  );
  static const String admobInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: '',
  );
  static const String admobRewardedId = String.fromEnvironment(
    'ADMOB_REWARDED_ID',
    defaultValue: '',
  );

  /// Web adresleri (gizlilik politikası ve destek).
  ///
  /// Play Console'a girilen gizlilik politikası adresiyle aynı olmalıdır;
  /// uygulama içinden de erişilebilir (Hakkında > Yasal).
  static const String websiteUrl = AppConstants.websiteUrl;
  static const String privacyPolicyUrl = AppConstants.privacyUrl;
  static const String termsUrl = AppConstants.termsUrl;
  static const String supportEmail = AppConstants.supportEmail;

  /// Abonelik ürün kimlikleri (Google Play Console ile eşleşmeli).
  static const String premiumMonthlyId = 'ezanai_premium_monthly';
  static const String premiumYearlyId = 'ezanai_premium_yearly';
  static const String premiumLifetimeId = 'ezanai_premium_lifetime';

  static bool get hasBackend => apiBaseUrl.isNotEmpty;
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasIlahiCatalog => ilahiCatalogUrl.isNotEmpty;
  static bool get adsConfigured =>
      admobBannerId.isNotEmpty || admobInterstitialId.isNotEmpty;

  static Uri? endpoint(String path, [Map<String, String>? query]) {
    if (!hasBackend) return null;
    final Uri base = Uri.parse(
      apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/',
    );
    return base.replace(
      path: path.startsWith('/') ? path.substring(1) : path,
      queryParameters: query,
    );
  }
}
