import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_unit_ids.dart';
import '../ads/ads_consent.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Reklam yerleşimleri (ücretsiz / reklamlı paket).
///
/// **İlkeler**
/// * Premium kullanıcıda **hiç reklam yüklenmez** ([setPremium]).
/// * Birim kimlikleri tanımlı değilse reklamlar tamamen kapanır; arayüzde
///   boş/bozuk alan görünmez.
/// * Test modunda Google'ın **resmî test kimlikleri** kullanılır; yayında
///   asla test kimliği ile yayın yapılmaz ([AppConfig.admobTestMode]).
/// * Açılışta UMP onay akışı tamamlanmadan reklam istenmez
///   ([AdsConsent]); AB/AEA kullanıcıları için yasal zorunluluktur.
/// * Geçiş (interstitial) reklamları **en fazla 3 dakikada bir** ve yalnızca
///   doğal duraklamalarda (ör. tesbih hedefi tamamlandığında) gösterilir.
class AdsService {
  AdsService({AdsConsent? consent}) : _consent = consent ?? AdsConsent();

  final AdsConsent _consent;

  bool _initialized = false;
  bool _enabled = false;
  bool _premium = false;
  DateTime? _lastInterstitialAt;
  Object? lastError;

  /// Geçiş reklamları arasındaki en kısa süre (kullanıcı deneyimi koruması).
  static const Duration interstitialCooldown = Duration(minutes: 3);

  AdsConsent get consent => _consent;

  /// Google test birimleri kullanılıyor mu?
  bool get isTestMode => AppConfig.admobTestMode || kDebugMode;

  String? get bannerId => _id(AppConfig.admobBannerId, AdUnitIds.testBanner);
  String? get interstitialId =>
      _id(AppConfig.admobInterstitialId, AdUnitIds.testInterstitial);
  String? get rewardedId =>
      _id(AppConfig.admobRewardedId, AdUnitIds.testRewarded);

  String? _id(String configured, String testId) {
    if (configured.isNotEmpty) return configured;
    if (isTestMode) return testId;
    return null;
  }

  bool get isEnabled => _enabled && !_premium;
  bool get bannerAvailable => isEnabled && (bannerId?.isNotEmpty ?? false);
  bool get interstitialAvailable =>
      isEnabled && (interstitialId?.isNotEmpty ?? false);
  bool get rewardedAvailable => isEnabled && (rewardedId?.isNotEmpty ?? false);

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  /// Reklam altyapısını hazırlar.
  ///
  /// Sıra: premium kontrolü → onay (UMP) → MobileAds başlatma. Herhangi bir
  /// adım başarısız olursa reklamlar kapalı kalır, uygulama çalışmaya devam
  /// eder.
  Future<void> initialize({required bool premium}) async {
    _premium = premium;
    if (premium) {
      _enabled = false;
      return;
    }
    if (!AppConfig.adsEnabled) {
      _enabled = false;
      AppLog.info('Reklamlar derleme zamanında kapatıldı (ADS_ENABLED=false).');
      return;
    }
    if (!isTestMode &&
        AppConfig.admobBannerId.isEmpty &&
        AppConfig.admobInterstitialId.isEmpty) {
      _enabled = false;
      AppLog.info('AdMob kimlikleri tanımlı değil — reklamlar kapalı.');
      return;
    }
    if (!_supportedPlatform) {
      _enabled = false;
      return;
    }
    if (_initialized) return;
    try {
      final bool consented = await _consent.ensureConsent();
      if (!consented) {
        _enabled = false;
        AppLog.info('Reklam onayı alınamadı — bu oturumda reklam yok.');
        return;
      }
      await MobileAds.instance.initialize();
      _initialized = true;
      _enabled = true;
      AppLog.info(
        'AdMob başlatıldı${isTestMode ? ' (TEST reklam kimlikleri)' : ''}.',
      );
      unawaited(preloadInterstitial());
      unawaited(preloadRewarded());
    } catch (error) {
      lastError = error;
      _enabled = false;
      AppLog.warning('AdMob başlatılamadı: $error');
    }
  }

  /// Premium durumu değiştiğinde çağrılır; reklamlar anında kapanır.
  void setPremium(bool premium) {
    _premium = premium;
    if (premium) dispose();
  }

  /// Ayarlar ekranındaki "Reklam gizlilik ayarları" girişi gerekli mi?
  bool get privacyOptionsRequired => _consent.privacyOptionsRequired;

  Future<void> showPrivacyOptions() => _consent.showPrivacyOptions();

  static bool get _supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // ------------------------------------------------------------ Banner

  /// Banner reklamı oluşturur; kimlik yoksa null döner (arayüz boşluk bırakmaz).
  BannerAd? createBanner({
    AdSize size = AdSize.banner,
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) {
    final String? unitId = bannerId;
    if (!bannerAvailable || unitId == null) return null;
    return BannerAd(
      size: size,
      adUnitId: unitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          AppLog.debug('Banner yüklendi.');
          onLoaded?.call();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          lastError = error;
          AppLog.warning('Banner yüklenemedi: ${error.message}');
          ad.dispose();
          onFailed?.call();
        },
      ),
    );
  }

  // ------------------------------------------------------- Geçiş reklamı

  /// Geçiş reklamını önceden yükler (kullanıcıyı bekletmemek için).
  Future<void> preloadInterstitial() async {
    final String? unitId = interstitialId;
    if (!interstitialAvailable || unitId == null || !_initialized) return;
    if (_interstitial != null) return;
    await InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) => _interstitial = ad,
        onAdFailedToLoad: (LoadAdError error) {
          lastError = error;
          _interstitial = null;
          AppLog.warning('Geçiş reklamı yüklenemedi: ${error.message}');
        },
      ),
    );
  }

  /// Yüklenmiş geçiş reklamını gösterir; yoksa sessizce yenisini yükler.
  ///
  /// 3 dakikalık bekleme süresi dolmadıysa reklam gösterilmez (`false`).
  Future<bool> showInterstitial({String? placement}) async {
    final String? unitId = interstitialId;
    if (!interstitialAvailable || unitId == null || !_initialized) return false;
    final DateTime now = DateTime.now();
    final DateTime? last = _lastInterstitialAt;
    if (last != null && now.difference(last) < interstitialCooldown) {
      return false;
    }
    final InterstitialAd? ad = _interstitial;
    if (ad == null) {
      unawaited(preloadInterstitial());
      return false;
    }
    _interstitial = null;
    _lastInterstitialAt = now;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        unawaited(preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        lastError = error;
        ad.dispose();
        unawaited(preloadInterstitial());
      },
    );
    AppLog.debug(
      'Geçiş reklamı gösterildi${placement == null ? '' : ' ($placement)'}',
    );
    await ad.show();
    return true;
  }

  // -------------------------------------------------------- Ödüllü reklam

  Future<void> preloadRewarded() async {
    final String? unitId = rewardedId;
    if (!rewardedAvailable || unitId == null || !_initialized) return;
    if (_rewarded != null) return;
    await RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) => _rewarded = ad,
        onAdFailedToLoad: (LoadAdError error) {
          lastError = error;
          _rewarded = null;
          AppLog.warning('Ödüllü reklam yüklenemedi: ${error.message}');
        },
      ),
    );
  }

  /// Ödüllü reklamı gösterir; [onReward] yalnızca kullanıcı ödülü hak ettiğinde
  /// çağrılır.
  Future<bool> showRewarded({
    required void Function(int amount) onReward,
    VoidCallback? onDismissed,
  }) async {
    final String? unitId = rewardedId;
    if (!rewardedAvailable || unitId == null || !_initialized) return false;
    final RewardedAd? ad = _rewarded;
    if (ad == null) {
      unawaited(preloadRewarded());
      return false;
    }
    _rewarded = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        onDismissed?.call();
        unawaited(preloadRewarded());
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        lastError = error;
        ad.dispose();
        unawaited(preloadRewarded());
      },
    );
    await ad.show(
      onUserEarnedReward: (AdWithoutView _, RewardItem reward) =>
          onReward(reward.amount.toInt()),
    );
    return true;
  }

  void dispose() {
    _interstitial?.dispose();
    _interstitial = null;
    _rewarded?.dispose();
    _rewarded = null;
  }
}
