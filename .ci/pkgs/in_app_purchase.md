# in_app_purchase (in_app_purchase-3.3.1)

## CHANGELOG (ilk 150 satır)
```
## 3.3.1

* Updates README examples and doc excerpts to match the current package API and extraction workflow.

## 3.3.0

* Updates `in_app_purchase_android` dependency to `^0.5.0`.

## 3.2.4

* Bump org.json:json from 20251224 to 20260522 in example.
* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.
* Updates README to reflect currently supported OS versions for the latest
  versions of the endorsed platform implementations.
  * Applications built with older versions of Flutter will continue to
    use compatible versions of the platform implementations.
* Clarifies `completePurchase` usage and the consequences of unfinished transactions in the README and docstrings.

## 3.2.3
* Updates minimum `in_app_purchase_storekit` version to 0.4.0.

## 3.2.2

* Updates README with Storekit 2 examples.
* Updates README to indicate that Andoid SDK <21 is no longer supported.

## 3.2.1

* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.
* Updates `in_app_purchase_android` to 0.4.0.

## 3.2.0

* Adds `countryCode` API.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates support matrix in README to indicate that iOS 11 is no longer supported.
* Clients on versions of Flutter that still support iOS 11 can continue to use this
  package with iOS 11, but will not receive any further updates to the iOS implementation.

## 3.1.13

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 3.1.12

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 3.1.11

* Updates documentation reference of `finishPurchase` to `completePurchase`.

## 3.1.10

* Updates example code for current versions of Flutter.

## 3.1.9

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 3.1.8

* Updates documentation on handling subscription price changes to match Android's billing client v5.

## 3.1.7

* Fixes unawaited_futures violations.

## 3.1.6

* Bumps minimum in_app_purchase_android version to 0.3.0.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Aligns Dart and Flutter SDK constraints.

## 3.1.5

* Updates links for the merge of flutter/plugins into flutter/packages.

## 3.1.4

* Updates iOS minimum version in README.

## 3.1.3

* Ignores a lint in the example app for backwards compatibility.

## 3.1.2

* Updates example code for `use_build_context_synchronously` lint.
* Updates minimum Flutter version to 3.0.

## 3.1.1

* Adds screenshots to pubspec.yaml.

## 3.1.0

* Adds macOS as a supported platform.

## 3.0.8

* Updates minimum Flutter version to 2.10.
* Bumps minimum in_app_purchase_android to 0.2.3.

## 3.0.7

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 3.0.6

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 3.0.5

* Updates references to the obsolete master branch.

## 3.0.4

* Minor fixes for new analysis options.

## 3.0.3

* Removes unnecessary imports.
* Adds OS version support information to README.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 3.0.2

* Adds additional explanation on why it is important to complete a purchase.

## 3.0.1

* Internal code cleanup for stricter analysis options.

## 3.0.0

* **BREAKING CHANGE** Updates `restorePurchases` to emit an empty list of purchases on StoreKit when there are no purchases to restore (same as Android).
  * This change was listed in the CHANGELOG for 2.0.0, but the change was accidentally not included in 2.0.0.

## 2.0.1

* Removes the instructions on initializing the plugin since this functionality is deprecated.

## 2.0.0

* **BREAKING CHANGES**:
  * Adds a new `PurchaseStatus` named `canceled`. This means developers can distinguish between an error and user cancellation.
  * ~~Updates `restorePurchases` to emit an empty list of purchases on StoreKit when there are no purchases to restore (same as Android).~~
```

## README (ilk 200 satır)
```
<?code-excerpt path-base="example/lib"?>
A storefront-independent API for purchases in Flutter apps.

<!-- If this package were in its own repo, we'd put badges here -->

This plugin supports in-app purchases (_IAP_) through an _underlying store_,
which can be the App Store (on iOS and macOS) or Google Play (on Android).

|             | Android | iOS   | macOS  |
|-------------|---------|-------|--------|
| **Support** | SDK 24+ | 13.0+ | 10.15+ |

<p>
  <img src="https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/doc/iap_ios.gif?raw=true"
    alt="An animated image of the iOS in-app purchase UI" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/doc/iap_android.gif?raw=true"
   alt="An animated image of the Android in-app purchase UI" height="400"/>
</p>

## Features

Use this plugin in your Flutter app to:

* Show in-app products that are available for sale from the underlying store.
   Products can include consumables, permanent upgrades, and subscriptions.
* Load in-app products that the user owns.
* Send the user to the underlying store to purchase products.
* Present a UI for redeeming subscription offer codes. (iOS 14 only)

## Getting started

This plugin relies on the App Store and Google Play for making in-app purchases.
It exposes a unified surface, but you still need to understand and configure
your app with each store. Both stores have extensive guides:

* [App Store documentation](https://developer.apple.com/in-app-purchase/)
* [Google Play documentation](https://developer.android.com/google/play/billing/billing_overview)

> NOTE: Further in this document the App Store and Google Play will be referred
> to as "the store" or "the underlying store", except when a feature is specific
> to a particular store.

For a list of steps for configuring in-app purchases in both stores, see the
[example app README](https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/example/README.md).

Once you've configured your in-app purchases in their respective stores, you
can start using the plugin. Two basic options are available:

1. A generic, idiomatic Flutter API: [in_app_purchase](https://pub.dev/documentation/in_app_purchase/latest/in_app_purchase/in_app_purchase-library.html).
   This API supports most use cases for loading and making purchases.
   
  > **NOTE**: On iOS and macOS, the generic API uses StoreKit 2 by default. If you need to fall back to StoreKit 1, call `InAppPurchaseStoreKitPlatform.enableStoreKit1()` before registering the platform.

2. Platform-specific Dart APIs: [store_kit_wrappers](https://pub.dev/documentation/in_app_purchase_storekit/latest/store_kit_wrappers/store_kit_wrappers-library.html)
   and [billing_client_wrappers](https://pub.dev/documentation/in_app_purchase_android/latest/billing_client_wrappers/billing_client_wrappers-library.html).
   These APIs expose platform-specific behavior and allow for more fine-tuned
   control when needed. However, if you use one of these APIs, your
   purchase-handling logic is significantly different for the different
   storefronts.

See also the codelab for [in-app purchases in Flutter](https://codelabs.developers.google.com/codelabs/flutter-in-app-purchases) for a detailed guide on adding in-app purchase support to a Flutter App.

## Usage

This section has examples of code for the following tasks:

* [Listening to purchase updates](#listening-to-purchase-updates)
* [Connecting to the underlying store](#connecting-to-the-underlying-store)
* [Loading products for sale](#loading-products-for-sale)
* [Restoring previous purchases](#restoring-previous-purchases)
* [Making a purchase](#making-a-purchase)
* [Completing a purchase](#completing-a-purchase)
* [Upgrading or downgrading an existing in-app subscription](#upgrading-or-downgrading-an-existing-in-app-subscription)
* [Accessing platform specific product or purchase properties](#accessing-platform-specific-product-or-purchase-properties)
* [Presenting a code redemption sheet (iOS 14)](#presenting-a-code-redemption-sheet-ios-14)

**Note:** It is not necessary to depend on `com.android.billingclient:billing` in your own app's `android/app/build.gradle` file. If you choose to do so know that conflicts might occur.

### Listening to purchase updates

In your app's `initState` method, subscribe to any incoming purchases. These
can propagate from either underlying store.
You should always start listening to purchase update as early as possible to be able
to catch all purchase updates, including the ones from the previous app session.
To listen to the update:

<?code-excerpt "readme_examples.dart (purchase-updates)"?>
```dart
class _ExampleAppState extends State<ExampleApp> {
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // handle error here.
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
```

Here is an example of how to handle purchase updates:

<?code-excerpt "readme_examples.dart (purchase-updates-handler)"?>
```dart
Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
  for (final purchaseDetails in purchaseDetailsList) {
    try {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    } catch (error) {
      // Handle or log the error here so other purchases can still be processed.
    }
  }
}
```

### Connecting to the underlying store

<?code-excerpt "readme_examples.dart (store-availability)"?>
```dart
final bool available = await InAppPurchase.instance.isAvailable();
if (!available) {
  // The store cannot be reached or accessed. Update the UI accordingly.
}
```

### Loading products for sale

<?code-excerpt "readme_examples.dart (product-query)"?>
```dart
const productIds = <String>{'product1', 'product2'};
final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(
  productIds,
);
if (response.notFoundIDs.isNotEmpty) {
  // Handle the error.
}
final List<ProductDetails> products = response.productDetails;
```

### Restoring previous purchases

Restored purchases will be emitted on the `InAppPurchase.purchaseStream`, make
sure to validate restored purchases following the best practices for each
underlying store:

* [Verifying App Store purchases](https://developer.apple.com/documentation/storekit/in-app_purchase/validating_receipts_with_the_app_store)
* [Verifying Google Play purchases](https://developer.android.com/google/play/billing/security#verify)


<?code-excerpt "readme_examples.dart (restore-purchases)"?>
```dart
await InAppPurchase.instance.restorePurchases();
```

Note that the App Store does not have any APIs for querying consumable
products, and Google Play considers consumable products to no longer be owned
once they're marked as consumed and fails to return them here. For restoring
these across devices you'll need to persist them on your own server and query
that as well.

### Making a purchase

Both underlying stores handle consumable and non-consumable products differently. If
you're using `InAppPurchase`, you need to make a distinction here and
call the right purchase method for each type.

<?code-excerpt "readme_examples.dart (purchase-flow)"?>
```
