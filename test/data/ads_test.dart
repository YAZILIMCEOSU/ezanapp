import 'package:ezanai/core/ads/ad_unit_ids.dart';
import 'package:ezanai/core/config/app_config.dart';
import 'package:ezanai/core/services/ads_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ücretsiz (reklamlı) paket sözleşmesi.
///
/// Reklamların Play Store politikalarına uygun davranması için:
/// * Test/debug derlemesinde **Google'ın resmî test birimleri** kullanılır.
/// * Altyapı (onay + MobileAds) başlatılmadan hiçbir reklam istenmez.
/// * Premium kullanıcıda hiçbir reklam yüklenmez/gösterilmez.
/// * Geçiş reklamları en fazla 3 dakikada bir gösterilir.
void main() {
  group('Reklam altyapısı — ücretsiz paket', () {
    test('test modunda Google resmî test birim kimlikleri kullanılır', () {
      final AdsService ads = AdsService();
      expect(ads.isTestMode, isTrue, reason: 'flutter test kDebugMode=true');
      expect(ads.bannerId, AdUnitIds.testBanner);
      expect(ads.interstitialId, AdUnitIds.testInterstitial);
      expect(ads.rewardedId, AdUnitIds.testRewarded);
    });

    test('altyapı başlatılmadan reklam istenmez (boş alan/hata yok)', () {
      final AdsService ads = AdsService();
      expect(ads.isEnabled, isFalse);
      expect(ads.bannerAvailable, isFalse);
      expect(ads.interstitialAvailable, isFalse);
      expect(ads.rewardedAvailable, isFalse);
      expect(ads.createBanner(), isNull);
    });

    test('premium kullanıcıda reklam tamamen kapanır', () {
      final AdsService ads = AdsService()..setPremium(true);
      expect(ads.isEnabled, isFalse);
      expect(ads.bannerAvailable, isFalse);
      expect(ads.createBanner(), isNull);
    });

    test('geçiş reklamı bekleme süresi kullanıcı dostu (3 dakika)', () {
      expect(AdsService.interstitialCooldown, const Duration(minutes: 3));
    });

    test('reklam anahtarı varsayılan olarak açık, test modu kapalı', () {
      expect(AppConfig.adsEnabled, isTrue);
      expect(AppConfig.admobTestMode, isFalse);
      // Test modu olmadan ve kimlik verilmeden reklam kapalı kalmalıdır:
      expect(AdUnitIds.testBanner, contains('ca-app-pub-3940256099942544'));
    });
  });
}
