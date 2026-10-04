import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

/// Reklam yerleşimleri.
///
/// **İlke:** Reklam birim kimlikleri derleme zamanında verilmezse reklamlar
/// tamamen kapanır ve arayüzde hiçbir boş/bozuk alan görünmez. Premium
/// kullanıcılar için de reklam yüklenmez.
class AdsService {
  AdsService();

  bool _initialized = false;
  bool _enabled = false;
  bool _premium = false;
  Object? lastError;

  bool get isEnabled => _enabled && !_premium;
  bool get bannerAvailable => isEnabled && AppConfig.admobBannerId.isNotEmpty;
  bool get interstitialAvailable => isEnabled && AppConfig.admobInterstitialId.isNotEmpty;
  bool get rewardedAvailable => isEnabled && AppConfig.admobRewardedId.isNotEmpty;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  Future<void> initialize({required bool premium}) async {
    _premium = premium;
    _enabled = AppConfig.adsConfigured;
    if (!_enabled) {
      AppLog.info('AdMob kimlikleri tanımlı değil — reklamlar kapalı.');
      return;
    }
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      AppLog.info('AdMob başlatıldı.');
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

  // ------------------------------------------------------------ Banner

  /// Banner reklamı oluşturur; kimlik yoksa null döner (arayüz boşluk bırakmaz).
  BannerAd? createBanner({AdSize size = AdSize.banner, VoidCallback? onLoaded, VoidCallback? onFailed}) {
    if (!bannerAvailable) return null;
    return BannerAd(
      size: size,
      adUnitId: AppConfig.admobBannerId,
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
    if (!interstitialAvailable || _interstitial != null) return;
    await InterstitialAd.load(
      adUnitId: AppConfig.admobInterstitialId,
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
  Future<bool> showInterstitial({String? placement}) async {
    if (!interstitialAvailable) return false;
    final InterstitialAd? ad = _interstitial;
    if (ad == null) {
      unawaited(preloadInterstitial());
      return false;
    }
    _interstitial = null;
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
    AppLog.debug('Geçiş reklamı gösterildi${placement == null ? '' : ' ($placement)'}');
    await ad.show();
    return true;
  }

  // -------------------------------------------------------- Ödüllü reklam

  Future<void> preloadRewarded() async {
    if (!rewardedAvailable || _rewarded != null) return;
    await RewardedAd.load(
      adUnitId: AppConfig.admobRewardedId,
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
  Future<bool> showRewarded({required void Function(int amount) onReward, VoidCallback? onDismissed}) async {
    if (!rewardedAvailable) return false;
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
    await ad.show(onUserEarnedReward: (AdWithoutView _, RewardItem reward) => onReward(reward.amount.toInt()));
    return true;
  }

  void dispose() {
    _interstitial?.dispose();
    _interstitial = null;
    _rewarded?.dispose();
    _rewarded = null;
  }
}
