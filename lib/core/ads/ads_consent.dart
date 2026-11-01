import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/logger.dart';

/// Avrupa Ekonomik Alanı (AB/AEA), Birleşik Krallık ve İsviçre kullanıcıları
/// için **Google Kullanıcı Mesajlaşma Platformu (UMP)** onay akışı.
///
/// **Neden zorunlu?**
/// * Kişiselleştirilmiş reklam yayınlamak için GDPR/DMA kapsamında açık rıza
///   gerekir.
/// * Play Store "Veri güvenliği" beyanında reklam kimliği (AD_ID) kullanımı
///   belirtilmelidir; onay akışı olmadan yayına alınan reklamlı uygulamalar
///   politika ihlali nedeniyle kaldırılabilir.
///
/// Bu sınıf **hiçbir koşulda uygulamayı kilitlemez**: onay akışı 8 saniye
/// içinde yanıt vermezse veya hata verirse uygulama sessizce reklamsız devam
/// eder (kullanıcı namaz vaktini her durumda görür).
class AdsConsent {
  AdsConsent();

  bool _resolved = false;
  bool _canRequestAds = true;
  bool _privacyOptionsRequired = false;

  /// Onay akışı çözüldü mü?
  bool get isResolved => _resolved;

  /// Reklam istenebilir mi? (Google politikasına uygunluk)
  bool get canRequestAds => _canRequestAds;

  /// Ayarlar ekranında "Reklam gizlilik ayarları" girişi gösterilmeli mi?
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Onay bilgisini tazeler ve gerekiyorsa **ilk açılışta onay formunu** gösterir.
  ///
  /// [timeout] aşılırsa reklamlar bu oturumda kapalı kalır; uygulama akışı
  /// etkilenmez.
  Future<bool> ensureConsent({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (!_supportedPlatform) {
      _resolved = true;
      _canRequestAds = false;
      return false;
    }
    final Completer<bool> completer = Completer<bool>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            _privacyOptionsRequired =
                (await ConsentInformation.instance
                    .getPrivacyOptionsRequirementStatus()) ==
                PrivacyOptionsRequirementStatus.required;
            await ConsentForm.loadAndShowConsentFormIfRequired((
              FormError? formError,
            ) async {
              if (formError != null) {
                AppLog.warning(
                  'Onay formu gösterilemedi: ${formError.message}',
                );
              }
              _canRequestAds = await ConsentInformation.instance
                  .canRequestAds();
              _resolved = true;
              if (!completer.isCompleted) completer.complete(_canRequestAds);
            });
          } catch (error) {
            AppLog.warning('Onay formu hatası: $error');
            _resolved = true;
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        (FormError error) {
          AppLog.warning('Onay bilgisi alınamadı: ${error.message}');
          _resolved = true;
          _canRequestAds = false;
          if (!completer.isCompleted) completer.complete(false);
        },
      );
    } catch (error) {
      AppLog.warning('UMP başlatılamadı: $error');
      _resolved = true;
      _canRequestAds = false;
      return false;
    }
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        AppLog.warning('Onay akışı zaman aşımına uğradı — reklamlar kapalı.');
        _resolved = true;
        _canRequestAds = false;
        return false;
      },
    );
  }

  /// Kullanıcının rızasını sonradan değiştirmesini sağlar
  /// (Ayarlar > Reklam gizlilik ayarları).
  Future<void> showPrivacyOptions() async {
    if (!_supportedPlatform) return;
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? formError) async {
        if (formError != null) {
          AppLog.warning('Gizlilik ayarları açılamadı: ${formError.message}');
          return;
        }
        _canRequestAds = await ConsentInformation.instance.canRequestAds();
      });
    } catch (error) {
      AppLog.warning('Gizlilik ayarları hatası: $error');
    }
  }

  static bool get _supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
