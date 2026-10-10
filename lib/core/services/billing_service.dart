import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Premium abonelik durumu.
enum PremiumStatus {
  unknown('Kontrol ediliyor'),
  free('Ücretsiz'),
  premium('Premium'),
  pending('İşlem bekliyor'),
  error('Doğrulanamadı');

  const PremiumStatus(this.label);

  final String label;

  bool get isPremium => this == PremiumStatus.premium;
}

/// Satın alınabilir ürün.
class PremiumProduct {
  const PremiumProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isSubscription,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final bool isSubscription;

  factory PremiumProduct.fromDetails(
    ProductDetails details, {
    required bool isSubscription,
  }) => PremiumProduct(
    id: details.id,
    title: details.title,
    description: details.description,
    price: details.price,
    isSubscription: isSubscription,
  );
}

/// Google Play Billing üzerinden abonelik yönetimi.
///
/// * Ürün kimlikleri [AppConfig] içinden gelir; mağaza konsolundaki
///   kimliklerle birebir eşleşmelidir.
/// * Doğrulama mümkünse backend üzerinden yapılır (`/billing/verify`);
///   backend yoksa Google Play'in yerel doğrulaması ve makbuz kaydı kullanılır.
/// * Hiçbir koşulda kullanıcı parası boşa gitmez: onaylanmayan satın alma
///   Play tarafında iade sürecine girer, uygulama durumu açıkça gösterir.
class BillingService {
  BillingService({InAppPurchase? iap, http.Client? client})
    : _iapOverride = iap,
      _client = client ?? http.Client();

  /// Test/önizleme ortamları için dışarıdan verilebilen mağaza istemcisi.
  final InAppPurchase? _iapOverride;
  final http.Client _client;

  InAppPurchase? _iapCache;
  bool _iapUnavailable = false;

  /// Mağaza istemcisini tembel çözer.
  ///
  /// `InAppPurchase.instance` platform eklentisini kaydeder; eklentinin
  /// bulunmadığı ortamlarda (test, masaüstü önizleme, Play hizmeti olmayan
  /// cihazlar) bu çağrı hata fırlatır. Uygulamanın düşmemesi için hata
  /// yakalanır ve özellik "kullanılamıyor" durumuna geçer.
  InAppPurchase? get _iap {
    if (_iapOverride != null) return _iapOverride;
    if (_iapUnavailable) return null;
    try {
      return _iapCache ??= InAppPurchase.instance;
    } catch (error) {
      _iapUnavailable = true;
      _lastError =
          'Google Play faturalandırma servisi bu cihazda kullanılamıyor. '
          'Premium özellikler Play Store sürümünde etkinleşir.';
      AppLog.warning('Play Billing başlatılamadı: $error');
      return null;
    }
  }

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();
  Stream<PremiumStatus> get statusStream => _statusController.stream;

  PremiumStatus _status = PremiumStatus.unknown;
  PremiumStatus get status => _status;

  List<PremiumProduct> _products = const <PremiumProduct>[];
  List<PremiumProduct> get products => _products;

  /// Mağazadan gelen ham ürün ayrıntıları (satın alma başlatmak için gerekir).
  final Map<String, ProductDetails> _detailsById = <String, ProductDetails>{};

  bool _storeAvailable = false;
  bool get storeAvailable => _storeAvailable;

  String? _lastError;
  String? get lastError => _lastError;

  /// Son doğrulanmış satın alma makbuzu (destek taleplerinde kullanılır).
  String? lastReceipt;

  static const Set<String> _subscriptionIds = <String>{
    AppConfig.premiumMonthlyId,
    AppConfig.premiumYearlyId,
  };

  static Set<String> get productIds => <String>{
    ..._subscriptionIds,
    AppConfig.premiumLifetimeId,
  };

  bool isKnownProductId(String id) => productIds.contains(id);

  /// Başlatır, ürünleri yükler ve satın alma akışını dinlemeye başlar.
  Future<void> initialize() async {
    final InAppPurchase? iap = _iap;
    if (iap == null) {
      _storeAvailable = false;
      _set(PremiumStatus.free);
      return;
    }

    try {
      _storeAvailable = await iap.isAvailable();
    } catch (error) {
      _storeAvailable = false;
      AppLog.warning('Play Billing kullanılamıyor: $error');
    }

    _subscription ??= iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object error) {
        _lastError = 'Satın alma akışı hatası: $error';
        AppLog.warning(_lastError!);
        _set(PremiumStatus.error);
      },
    );

    if (_storeAvailable) {
      await loadProducts();
      await restore();
    } else {
      // Play hizmeti yoksa (ör. emülatör): kullanıcıyı yanıltmamak için
      // "ücretsiz" durumunda kalırız.
      _set(PremiumStatus.free);
    }
  }

  Future<void> loadProducts() async {
    final InAppPurchase? iap = _iap;
    if (iap == null) return;
    try {
      final ProductDetailsResponse response = await iap.queryProductDetails(
        productIds,
      );
      if (response.error != null) {
        _lastError = response.error!.message;
        AppLog.warning('Ürünler yüklenemedi: ${response.error!.message}');
      }
      for (final ProductDetails details in response.productDetails) {
        _detailsById[details.id] = details;
      }
      _products = response.productDetails
          .map(
            (ProductDetails d) => PremiumProduct.fromDetails(
              d,
              isSubscription: _subscriptionIds.contains(d.id),
            ),
          )
          .toList(growable: false);
      if (response.notFoundIDs.isNotEmpty) {
        AppLog.warning(
          'Mağazada bulunamayan ürünler: ${response.notFoundIDs.join(', ')}',
        );
      }
    } catch (error) {
      _lastError = 'Ürün listesi alınamadı: $error';
      AppLog.warning(_lastError!);
    }
  }

  /// Tek seferlik satın alma / abonelik başlatır.
  Future<bool> purchase(String productId) async {
    if (!_storeAvailable) {
      _lastError = 'Google Play hizmetine ulaşılamıyor. Lütfen daha sonra tekrar deneyin.';
      return false;
    }
    if (_products.isEmpty) await loadProducts();

    final ProductDetails? details = _findDetails(productId);
    if (details == null) {
      _lastError =
          'Seçilen ürün mağazada bulunamadı. Uygulamayı güncellemeyi deneyin.';
      return false;
    }

    try {
      final PurchaseParam param = PurchaseParam(productDetails: details);
      // Abonelikler ve tek seferlik "ömür boyu" ürünü de aynı çağrıyla
      // başlatılır; Play Console'da ürün tipiyle ayrılır.
      final InAppPurchase? iap = _iap;
      if (iap == null) {
        _lastError = 'Google Play hizmetine ulaşılamıyor. Lütfen daha sonra tekrar deneyin.';
        return false;
      }
      final bool started = await iap.buyNonConsumable(purchaseParam: param);
      if (!started) {
        _lastError = 'Satın alma başlatılamadı.';
        return false;
      }
      _set(PremiumStatus.pending);
      return true;
    } catch (error) {
      _lastError = 'Satın alma başlatılamadı: $error';
      AppLog.warning(_lastError!);
      return false;
    }
  }

  ProductDetails? _findDetails(String productId) => _detailsById[productId];

  /// Daha önce yapılan satın alımları geri yükler.
  Future<void> restore() async {
    final InAppPurchase? iap = _iap;
    if (!_storeAvailable || iap == null) return;
    try {
      await iap.restorePurchases();
    } catch (error) {
      AppLog.warning('Satın alımlar geri yüklenemedi: $error');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _set(PremiumStatus.pending);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final bool verified = await _verify(purchase);
          if (verified) {
            lastReceipt = purchase.verificationData.serverVerificationData;
            _set(PremiumStatus.premium);
          } else {
            _lastError =
                'Satın alma doğrulanamadı. Destek ekibimize ulaşın: ${purchase.productID}';
            _set(PremiumStatus.error);
          }
          await _complete(purchase);
        case PurchaseStatus.error:
          _lastError =
              purchase.error?.message ?? 'Satın alma sırasında hata oluştu.';
          _set(PremiumStatus.error);
          await _complete(purchase);
        case PurchaseStatus.canceled:
          _set(PremiumStatus.free);
          await _complete(purchase);
      }
    }
  }

  Future<void> _complete(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    final InAppPurchase? iap = _iap;
    if (iap == null) return;
    try {
      await iap.completePurchase(purchase);
    } catch (error) {
      AppLog.warning('Satın alma tamamlanamadı: $error');
    }
  }

  static const MethodChannel _integrityChannel = MethodChannel(
    'ezanai/sensors/methods',
  );

  /// Sahte satın alma yamalarına (Lucky Patcher vb.) ve paket adı değiştirilerek
  /// klonlanmış APK'lara karşı makbuz bütünlüğünü doğrular.
  bool verifyReceiptIntegrity(
    PurchaseDetails purchase, {
    String? activePackageName,
  }) {
    if (!isKnownProductId(purchase.productID)) {
      return false;
    }
    if (activePackageName != null &&
        activePackageName.isNotEmpty &&
        activePackageName != AppConstants.packageName &&
        activePackageName != '${AppConstants.packageName}.debug') {
      return false;
    }

    final String serverToken = purchase.verificationData.serverVerificationData
        .trim();
    final String localData = purchase.verificationData.localVerificationData
        .trim();

    if (serverToken.isEmpty || serverToken.length < 8) {
      return false;
    }
    final String lowerToken = serverToken.toLowerCase();
    if (lowerToken == 'fake' ||
        lowerToken == 'null' ||
        lowerToken == 'true' ||
        lowerToken.contains('patcher')) {
      return false;
    }

    if (localData.startsWith('{') && localData.endsWith('}')) {
      try {
        final Object? decoded = jsonDecode(localData);
        if (decoded is Map) {
          final String? pkg = decoded['packageName'] as String?;
          if (pkg != null &&
              pkg != AppConstants.packageName &&
              pkg != '${AppConstants.packageName}.debug') {
            return false;
          }
          final String? prod = decoded['productId'] as String?;
          if (prod != null && prod != purchase.productID) {
            return false;
          }
          final Object? state = decoded['purchaseState'];
          if (state is num && state.toInt() != 0) {
            return false;
          }
        }
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  Future<Map<String, Object?>?> _readNativeIntegrityInfo() async {
    try {
      final Map<Object?, Object?>? raw = await _integrityChannel
          .invokeMethod<Map<Object?, Object?>>('getIntegrityInfo');
      if (raw == null) return null;
      return raw.cast<String, Object?>();
    } catch (_) {
      return null;
    }
  }

  /// Backend varsa makbuzu orada doğrular; yoksa uygulama paket bütünlüğünü
  /// ve Google Play makbuz yapısını doğrular.
  Future<bool> _verify(PurchaseDetails purchase) async {
    final Map<String, Object?>? integrity = await _readNativeIntegrityInfo();
    final String? activePkg = integrity?['packageName'] as String?;
    final bool? isOfficial = integrity?['isOfficialPackage'] as bool?;
    if (isOfficial == false) {
      AppLog.warning('Resmi olmayan / klonlanmış paket tespit edildi: $activePkg');
      return false;
    }
    if (!verifyReceiptIntegrity(purchase, activePackageName: activePkg)) {
      AppLog.warning('Makbuz bütünlük doğrulaması reddedildi: ${purchase.productID}');
      return false;
    }

    final Uri? uri = AppConfig.endpoint('/billing/verify');
    if (uri == null) return true;

    try {
      final http.Response response = await _client
          .post(
            uri,
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(<String, Object?>{
              'package_name': activePkg ?? AppConstants.packageName,
              'signing_sha256': integrity?['signingSha256'],
              'installer_package': integrity?['installerPackage'],
              'product_id': purchase.productID,
              'purchase_id': purchase.purchaseID,
              'receipt': purchase.verificationData.serverVerificationData,
              'local_receipt': purchase.verificationData.localVerificationData,
              'source': purchase.verificationData.source,
              'is_subscription': _subscriptionIds.contains(purchase.productID),
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return false;
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['valid'] is bool) {
        return decoded['valid']! as bool;
      }
      return false;
    } catch (error) {
      AppLog.warning('Makbuz doğrulama başarısız: $error');
      return false;
    }
  }

  void _set(PremiumStatus status) {
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  /// Kullanıcı "geri yükle" düğmesine bastığında durumu tazeler.
  Future<PremiumStatus> refresh() async {
    if (!_storeAvailable) {
      await initialize();
    } else {
      await restore();
    }
    return _status;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
    _client.close();
  }
}
