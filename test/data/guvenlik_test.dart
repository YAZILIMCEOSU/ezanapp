import 'dart:convert';

import 'package:ezanai/core/ads/ad_unit_ids.dart';
import 'package:ezanai/core/config/app_config.dart';
import 'package:ezanai/core/services/ads_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Kopya koruması / güvenlik sözleşmesi.**
///
/// Android tarafında (`MainActivity.buildIntegrityInfo`) hesaplanan alanların
/// biçimi ve satın alma doğrulamasının bu alanlara nasıl tepki verdiği
/// doğrulanır. Native taraf gerçek cihazda, burada ise sözleşme (alan adları,
/// tipler ve karar mantığı) test edilir.
void main() {
  group('1) Bütünlük raporu sözleşmesi', () {
    /// `buildIntegrityInfo()` çıktısının beklenen alanları.
    Map<String, Object?> sample({
      bool official = true,
      bool pinned = true,
      bool signatureMatches = true,
      bool tamper = false,
      bool cloned = false,
      bool debugger = false,
      bool playInstall = true,
    }) => <String, Object?>{
      'packageName': 'com.yazilimceosu.ezanai',
      'isOfficialPackage':
          official && !tamper && !cloned && signatureMatches,
      'installerPackage': playInstall ? 'com.android.vending' : null,
      'signingSha256': 'a' * 64,
      'signaturePinned': pinned,
      'signatureMatches': signatureMatches,
      'isClonedEnvironment': cloned,
      'hasTamperTools': tamper,
      'isDebuggerAttached': debugger,
      'isPlayStoreInstall': playInstall,
    };

    test('Play kurulumu + eşleşen imza → resmî paket', () {
      final Map<String, Object?> info = sample();
      expect(info['isOfficialPackage'], isTrue);
      expect(info['isPlayStoreInstall'], isTrue);
      expect(info['signaturePinned'], isTrue);
      expect(info['signatureMatches'], isTrue);
    });

    test('yeniden imzalanmış (farklı imza) paket resmî değil', () {
      final Map<String, Object?> info = sample(signatureMatches: false);
      expect(info['signatureMatches'], isFalse);
      expect(info['isOfficialPackage'], isFalse);
    });

    test('patch aracı / klon / debugger resmî paketi düşürür', () {
      expect(sample(tamper: true)['isOfficialPackage'], isFalse);
      expect(sample(cloned: true)['isOfficialPackage'], isFalse);
    });

    test('imza sabitleme kapalıyken (test/CI) kontrol atlanır', () {
      final Map<String, Object?> info = sample(pinned: false);
      expect(info['signaturePinned'], isFalse);
      expect(info['isOfficialPackage'], isTrue);
    });

    test('tüm alanlar JSON ile taşınabilir', () {
      final Map<String, Object?> info = sample();
      final Object? decoded = jsonDecode(jsonEncode(info));
      expect(decoded, isA<Map<String, Object?>>());
      expect(
        (decoded! as Map<String, Object?>)['signaturePinned'],
        isA<bool>(),
      );
    });
  });

  group('2) Ücretsiz paket sözleşmesi (reklamlar)', () {
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
      expect(ads.createBanner(), isNull);
    });

    test('premium kullanıcıda reklam tamamen kapanır', () {
      final AdsService ads = AdsService()..setPremium(true);
      expect(ads.isEnabled, isFalse);
      expect(ads.createBanner(), isNull);
    });

    test('geçiş reklamı bekleme süresi 3 dakika', () {
      expect(AdsService.interstitialCooldown, const Duration(minutes: 3));
    });

    test('reklam anahtarı varsayılan olarak açık, test modu kapalı', () {
      expect(AppConfig.adsEnabled, isTrue);
      expect(AppConfig.admobTestMode, isFalse);
    });
  });
}
