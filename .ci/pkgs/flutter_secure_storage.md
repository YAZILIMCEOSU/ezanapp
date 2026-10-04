# flutter_secure_storage (flutter_secure_storage-11.2.0)

## CHANGELOG (ilk 150 satır)
```
# Changelog

## [11.2.0](https://github.com/juliansteenbakker/flutter_secure_storage/compare/flutter_secure_storage-v11.1.1...flutter_secure_storage-v11.2.0) (2026-09-16)


### Features

* **android:** requireBiometricsPerOperation flag ([#1264](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1264)) ([321cf97](https://github.com/juliansteenbakker/flutter_secure_storage/commit/321cf97c72e78ddb81e888484560ebca74414614))


### Bug Fixes

* **android:** don't hang when biometric negative button is tapped ([#1267](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1267)) ([405c6e6](https://github.com/juliansteenbakker/flutter_secure_storage/commit/405c6e6299c665dfb8a7211192b42319da2e88bc))
* **android:** fix fresh biometric install crash on non-namespaced stores ([120bdf4](https://github.com/juliansteenbakker/flutter_secure_storage/commit/120bdf4ddb75e94d0c7d40519e2da9cea953a2c1))
* **android:** port the shared-key multi-instance fixes to v11.x ([6cc9ddc](https://github.com/juliansteenbakker/flutter_secure_storage/commit/6cc9ddc55df42255edd4afb72bac56458997885d))
* **android:** recover biometric-protected storage on post-auth cipher failure ([#1271](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1271)) ([77eed59](https://github.com/juliansteenbakker/flutter_secure_storage/commit/77eed597eaa244106b946cd02c4d7edb3eb9fa05))
* **android:** recover the biometric app key on a namespace switch ([31f6eeb](https://github.com/juliansteenbakker/flutter_secure_storage/commit/31f6eeb79ad8187a49d8675bbf58d81b050f506f))
* **android:** scope deleteAll to the key prefix instead of clearing the file ([#1266](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1266)) ([34170b2](https://github.com/juliansteenbakker/flutter_secure_storage/commit/34170b2caf52c642efa5b6584fa4cc5072f6c697))
* **darwin:** find keychain items across accessibility levels ([#1269](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1269)) ([9ae0e42](https://github.com/juliansteenbakker/flutter_secure_storage/commit/9ae0e422d6ad6376ddf7960186d42342b0370baf))
* don't report pending namespace recovery as data loss in checkUpgradeStatus ([f795d52](https://github.com/juliansteenbakker/flutter_secure_storage/commit/f795d52488450d6ef04ee580c895d98c59b737f3))

## [11.1.1](https://github.com/juliansteenbakker/flutter_secure_storage/compare/flutter_secure_storage-v11.1.0...flutter_secure_storage-v11.1.1) (2026-09-11)


### Bug Fixes

* **android:** read saved key-cipher marker instead of toString() on a KeyCipher ([#1256](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1256)) ([73f0ef5](https://github.com/juliansteenbakker/flutter_secure_storage/commit/73f0ef5b0666a25912ae07694211414dfcabcf23))

## [11.1.0](https://github.com/juliansteenbakker/flutter_secure_storage/compare/flutter_secure_storage-v11.0.0...flutter_secure_storage-v11.1.0) (2026-09-10)


### Features

* add checkUpgradeStatus() to report data lost on a direct major upgrade ([#1243](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1243)) ([fc716ea](https://github.com/juliansteenbakker/flutter_secure_storage/commit/fc716ea7b3973db985d953776107b44b5984f591))


### Bug Fixes

* **android:** move wrapped key when switching between sharedPreferencesName and storageNamespace ([2482e34](https://github.com/juliansteenbakker/flutter_secure_storage/commit/2482e34e377cae7e6e082c0c0c867c2d5857a531))
* **android:** use flutter.compileSdkVersion (36) instead of pinning compileSdk (37) ([#1236](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1236)) ([0530fe7](https://github.com/juliansteenbakker/flutter_secure_storage/commit/0530fe74174743b234adc14c5305d13cbdac7764)), closes [#1224](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1224)
* require flutter_secure_storage_platform_interface ^2.1.0 for checkUpgradeStatus ([#1247](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1247)) ([0d3d6f2](https://github.com/juliansteenbakker/flutter_secure_storage/commit/0d3d6f21201cb844ef085b2cb0a3999e45f125e1))

## [11.0.0](https://github.com/juliansteenbakker/flutter_secure_storage/compare/flutter_secure_storage-v10.3.1...flutter_secure_storage-v11.0.0) (2026-08-06)

**Breaking changes**

items deprecated in v10 have been removed. 
Any data saved using deprecated algorithms or features will be unusable after this upgrade. If you used a version prior to v10, upgrade to v10 first so existing data is migrated.

### Android

- Removed `KeyCipherAlgorithm.RSA_ECB_PKCS1Padding`. Upgrade to v10 first so existing data is migrated to `RSA_ECB_OAEPwithSHA_256andMGF1Padding` before upgrading to v11.
- Removed `StorageCipherAlgorithm.AES_CBC_PKCS7Padding`. Upgrade to v10 first so existing data is migrated to `AES_GCM_NoPadding` before upgrading to v11.
- Removed `encryptedSharedPreferences` parameter from `AndroidOptions` and `AndroidOptions.biometric`. The Jetpack Security (EncryptedSharedPreferences) backend is no longer supported; any remaining data was automatically migrated to custom cipher storage in v10.
- Removed `sharedPreferencesName` from `AndroidOptions`. Use `storageNamespace` instead for full namespace isolation.
- Raised `minSdk` to 24 and `compileSdk` to 37. Flutter 3.35 raised its own Android minimum to API 24, making API 23 support unverifiable with any supported Flutter version. The legacy AES-CBC cipher path that supported API 21-22 has been removed.

### Features

* **android:** add requireBiometricConfirmation option to AndroidOptions ([7f5f7de](https://github.com/juliansteenbakker/flutter_secure_storage/commit/7f5f7de0ea98a6482c02e768faf7c82c2e5b959b))


### Bug Fixes

* **android:** catch Throwable on worker thread so keystore Errors don't crash the app ([d5802ff](https://github.com/juliansteenbakker/flutter_secure_storage/commit/d5802ff6b422a391501145d1113ca9da4c39f1f0))
* **android:** don't swallow VM errors, catch Throwable on biometric thread too ([d413d3f](https://github.com/juliansteenbakker/flutter_secure_storage/commit/d413d3fb2e8c0faaf78f986be9300e5f1ca6105c))
* **linux:** handle missing default keyring ([b39c7c1](https://github.com/juliansteenbakker/flutter_secure_storage/commit/b39c7c1db6c1fe651367031c9d0033d590784de0))
* **linux:** fail closed on orphaned keyring data ([2e720ff](https://github.com/juliansteenbakker/flutter_secure_storage/commit/2e720ff7e6b956a5d1197a5077bb8be39a5d5632))
* remove redundant ./ prefix from part directives ([cc7018d](https://github.com/juliansteenbakker/flutter_secure_storage/commit/cc7018d15eae56b389348d73f788ae1a03c606c6))

## 10.3.1

### Android
- Fixed `AEADBadTagException` when biometric authentication is cancelled on first launch: a stale IV is now cleared and the cipher re-initialised in encrypt mode so the next authentication attempt succeeds.
- Fixed `NullPointerException` when retrying an operation after a cancelled biometric prompt: `preferences` is now only assigned once cipher initialisation completes successfully, allowing a clean retry.

## 10.3.0

### Android
- Added `AndroidBiometricType` enum and `biometricType` option to `AndroidOptions` to control which authentication methods are accepted during biometric prompts (requires `KeyCipherAlgorithm.AES_GCM_NoPadding`).
  - `AndroidBiometricType.biometricOrDeviceCredential` (default) accepts Class 3 biometrics or device credentials (PIN/pattern/password), preserving previous behaviour.
  - `AndroidBiometricType.strongBiometricOnly` restricts authentication to Class 3 (strong) biometrics only; device credentials are explicitly rejected.
- Fully enforced on Android 11+ (API 30+) via `setAllowedAuthenticators` on `BiometricPrompt` and `setUserAuthenticationParameters` on the KeyStore key. On earlier API levels the system may still permit device credentials.
- Added `biometricPromptNegativeButton` option to `AndroidOptions` to customise the dismiss button label on the biometric prompt. Required when using `strongBiometricOnly` or on Android 10 and lower.

### iOS / macOS
- Fixed `secStoreAvailabilitySink` not being called when protected data availability changes.
- Fixed `kSecUseDataProtectionKeychain` being added to Keychain queries unconditionally; it is now only set when `useDataProtectionKeychain` is explicitly enabled.

### Windows
- Fixed `deleteAll` and `containsKey` not acquiring the mutex lock, which could cause data races under concurrent access.
  If you are on Dart >=3.10.0, this fix is applied automatically. Otherwise, pin `flutter_secure_storage_windows: ^4.2.2` in your `pubspec.yaml` to opt in and make sure your constraint is set for minimum of Dart >=3.10.0.

### Linux
- Fixed `deleteKeyring` storing the string `"null"` instead of an empty JSON object `{}`.
- Fixed non-UTF-8 error messages from libsecret causing a `FormatException` on the Dart side; messages are now sanitised before being sent through the method channel.
- Fixed locked or unavailable keyring now surfacing as a catchable `PlatformException` with code `KeyringLocked`.
- Fixed JSON parse errors and other C++ exceptions now surfacing as a `PlatformException` with code `StorageError` instead of sending malformed bytes through the channel.
## 10.2.0

### Android
- Deprecated `KeyCipherAlgorithm.RSA_ECB_PKCS1Padding`. Existing data is automatically migrated to the default `RSA_ECB_OAEPwithSHA_256andMGF1Padding` when `migrateOnAlgorithmChange` is true.
- Deprecated `StorageCipherAlgorithm.AES_CBC_PKCS7Padding`. Existing data is automatically migrated to the default `AES_GCM_NoPadding` when `migrateOnAlgorithmChange` is true.
- Fixed Gradle space-assignment warnings in `build.gradle`.

### iOS / macOS
- Fixed iOS build by updating availability annotation for Secure Enclave methods from `iOS 11.3` to `iOS 13.0`.

### Windows
- Fixed compatibility with `win32` 6.0.0 in `flutter_secure_storage_windows 4.2.0`.
  If you are on Dart >=3.10.0, this fix is applied automatically. Otherwise, pin `flutter_secure_storage_windows: ^4.2.0` in your `pubspec.yaml` to opt in and make sure your constraint is set for minimum of Dart >=3.10.0.

## 10.1.0

### Windows
- Updated `flutter_secure_storage_windows` to 4.2.0 with compatibility fixes for `win32` 6.0.0.

### Android
- Added `storageNamespace` option to `AndroidOptions` for full namespace isolation across storage instances (SharedPreferences, KeyStore aliases, config/key storage). Use this instead of `sharedPreferencesName` when running multiple `FlutterSecureStorage` instances with different cipher configurations.
- Deprecated `sharedPreferencesName` in favor of `storageNamespace`, which provides complete isolation rather than data-only isolation.
- Added `migrateWithBackup` option to `AndroidOptions` for crash-resistant migration. When enabled, backup copies of encrypted data are created before migration starts, allowing recovery if migration fails or the app crashes mid-migration. Works in conjunction with `migrateOnAlgorithmChange`.
- Made `KeyCipherAlgorithm` and `StorageCipherAlgorithm` public enums.

**Fixes:**
- Fixed crash on biometric failure (not error).
- Fixed null safety issue in `MethodRunner` that could cause a crash on Android.
- Fixed config being overwritten on initialization.
- Fixed default Android key cipher not aligning with the Flutter default.

### iOS / macOS
- Added `useSecureEnclave` option to `IOSOptions` and `MacOsOptions` to store keys in the device's Secure Enclave for hardware-backed security.

**Fixes:**
- Fixed `kSecAttrSynchronizable` being silently dropped when no access control flags are set.
- Fixed `readAll` not returning Secure Enclave items correctly.

## 10.0.0
This major release brings significant security improvements, platform updates, and modernization across all supported platforms.

### Android
Due to the deprecation of Jetpack Security library, the Android implementation has been largely rewritten with custom secure ciphers, enhanced biometrics support, and migration tools.

**Breaking Changes:**
- `AndroidOptions().encryptedSharedPreferences` is now deprecated due to Jetpack Crypto package deprecation
  - Migration will automatically happen due to `migrateOnAlgorithmChange: true`, which can also be set to false if not wanted.
- ResetOnError will now automatically be true, because most errors are unrecoverable due to key storage problems. It can still be disabled with `resetOnError: false`
- Default key cipher changed to `RSA_ECB_OAEPwithSHA_256andMGF1Padding`
- Default storage cipher changed to `AES_GCM_NoPadding`
- Minimum Android SDK changed from 19 to 23
- Target SDK updated to 36
```

## README (ilk 200 satır)
```
# flutter_secure_storage

[![Pub Version](https://img.shields.io/pub/v/flutter_secure_storage.svg)](https://pub.dev/packages/flutter_secure_storage)
[![Pub Version Prerelease](https://img.shields.io/pub/v/flutter_secure_storage.svg?include_prereleases)](https://pub.dev/packages/flutter_secure_storage)
[![Build Status](https://github.com/mogol/flutter_secure_storage/actions/workflows/code-quality.yml/badge.svg)](https://github.com/juliansteenbakker/flutter_secure_storage/actions/workflows/code-quality.yml)
[![Code Quality: Very Good Analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Codecov](https://codecov.io/gh/juliansteenbakker/flutter_secure_storage/graph/badge.svg?token=UUVTJ6MS4A)](https://codecov.io/gh/juliansteenbakker/flutter_secure_storage)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/juliansteenbakker)](https://github.com/sponsors/juliansteenbakker)

A Flutter plugin to securely store sensitive data in a key-value pair format using platform-specific secure storage solutions. It supports Android, iOS, macOS, Windows, and Linux.

## Features

- **Secure Data Storage**: Uses Keychain for iOS/macOS, custom secure ciphers with optional biometric authentication for Android, and platform-specific secure mechanisms for Windows, Linux, and Web.
- **Encryption**: Encrypts data before storing it using platform-specific encryption (RSA OAEP + AES-GCM on Android by default).
- **Cross-Platform**: Works seamlessly across Android, iOS, macOS, Windows, Linux, and Web.
- **Biometric Authentication**: Optional biometric authentication support on Android (API 23+) and iOS/macOS.
- **Customizable Options**: Configure encryption algorithms, accessibility attributes, biometric requirements, and more.

## Important notice for Android
Version 10.0.0 introduces a major security update with custom cipher implementations. The deprecated Jetpack Security library's `encryptedSharedPreferences` is no longer recommended.

**Key Changes:**
- New default ciphers: RSA OAEP (key cipher) + AES-GCM (storage cipher)
- New `AndroidOptions()` and `AndroidOptions.biometric()` constructors
- Automatic migration from old ciphers via `migrateOnAlgorithmChange` (enabled by default)
- Minimum Android SDK is now 23 (Android 6.0+)
- Enhanced biometric authentication with graceful degradation

## Important notice for Web
flutter_secure_storage only works on HTTPS or localhost environments. [Please see this issue for more information.](https://github.com/juliansteenbakker/flutter_secure_storage/issues/320#issuecomment-976308930)

## Installation

If not present already, please call WidgetsFlutterBinding.ensureInitialized() in your main before you do anything with the MethodChannel. [Please see this issue  for more info.](https://github.com/juliansteenbakker/flutter_secure_storage/issues/336)

Add the dependency in your `pubspec.yaml` file:

```
dependencies:
flutter_secure_storage: ^<latest_version>
```

Then run:

`flutter pub get`

## Usage

### Import the Package


`import 'package:flutter_secure_storage/flutter_secure_storage.dart';`

### Create an Instance

```dart
// Default secure storage - Uses RSA OAEP + AES-GCM (recommended)
final storage = FlutterSecureStorage();

// Or with explicit Android options
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(),
);

// Biometric storage with graceful degradation
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions.biometric(
    enforceBiometrics: false, // Works without biometrics
    biometricPromptTitle: 'Authenticate to access data',
  ),
);

// Strict biometric enforcement (requires device security)
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions.biometric(
    enforceBiometrics: true, // Requires biometric/PIN/pattern
    biometricPromptTitle: 'Authentication Required',
  ),
);
```

### Write Data

`await storage.write(key: 'username', value: 'flutter_user');`

### Read Data

`String? username = await storage.read(key: 'username');`

### Delete Data

`await storage.delete(key: 'username');`

### Delete All Data

`await storage.deleteAll();`

### Check for Key Existence

`bool containsKey = await storage.containsKey(key: 'username');`

## Configuration

Each platform provides its own set of configuration options to tailor secure storage behavior. For example, on iOS, the `IOSOptions` class includes an `accessibility` option that determines when the app can access secure values stored in the Keychain.

The `accessibility` option allows you to specify conditions under which secure values are accessible. For instance:

- `first_unlock`: Enables access to secure values after the device is unlocked for the first time after a reboot.
- `first_unlock_this_device`: Allows access to secure values only after the device is unlocked for the first time since installation on this device.
- `unlocked` (default): Values are accessible only when the device is unlocked.

Here’s an example of configuring the accessibility option on iOS:

```dart
final options = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
await storage.write(key: key, value: value, iOptions: options);
```

By setting `accessibility`, you can control when secure values are accessible, enhancing security and usability for your app on iOS. Similar platform-specific options are available for other platforms as well.

### Android

#### Disabling Auto Backup

_Note_ By default Android backups data on Google Drive. It can cause exception `java.security.InvalidKeyException: Failed to unwrap key`.
You need to:

- [Disable autobackup](https://developer.android.com/guide/topics/data/autobackup#EnablingAutoBackup), [details](https://github.com/juliansteenbakker/flutter_secure_storage/issues/13#issuecomment-421083742)
- [Exclude sharedprefs](https://developer.android.com/guide/topics/data/autobackup#IncludingFiles) used by `FlutterSecureStorage`, [details](https://github.com/juliansteenbakker/flutter_secure_storage/issues/43#issuecomment-471642126)

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<application
  android:allowBackup="false"
  ...>
</application>
```

#### Encryption Options (Version 10.0.0+)

Version 10 introduces new cipher options and biometric support. Choose the configuration that fits your security requirements:

| Constructor                                                                                              | Key Cipher                            | Storage Cipher    | Biometric Support | Description                                                                                                                                          |
|----------------------------------------------------------------------------------------------------------|---------------------------------------|-------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `AndroidOptions()`                                                                                       | RSA/ECB/OAEPWithSHA-256AndMGF1Padding | AES/GCM/NoPadding | No                | **Default.** Standard secure storage with RSA OAEP key wrapping. Strong authenticated encryption without biometrics. Recommended for most use cases. |
| `AndroidOptions.biometric(enforceBiometrics: false)`                                                     | AES/GCM/NoPadding                     | AES/GCM/NoPadding | Optional          | KeyStore-based with optional biometric authentication. Gracefully degrades if biometrics unavailable.                                                |
| `AndroidOptions.biometric(enforceBiometrics: true)`                                                      | AES/GCM/NoPadding                     | AES/GCM/NoPadding | Required          | KeyStore-based requiring biometric/PIN authentication. Throws error if device security not available. Requires API 28+ for biometric enforcement.    |
| `AndroidOptions.biometric(enforceBiometrics: true, biometricType: AndroidBiometricType.strongBiometricOnly)` | AES/GCM/NoPadding                 | AES/GCM/NoPadding | Required (strong) | Same as above but restricts authentication to Class 3 (strong) biometrics only. Device credentials (PIN/pattern/password) are rejected.              |

#### Custom Cipher Combinations (Advanced)

For advanced users, all combinations below are supported using the `AndroidOptions()` constructor with custom parameters:

| Key Cipher Algorithm                    | Storage Cipher Algorithm | Implementation  | Biometric Support                  |
|-----------------------------------------|--------------------------|-----------------|------------------------------------|
| `RSA_ECB_PKCS1Padding`                  | `AES_CBC_PKCS7Padding`   | RSA-wrapped AES | No                                 |
| `RSA_ECB_PKCS1Padding`                  | `AES_GCM_NoPadding`      | RSA-wrapped AES | No                                 |
| `RSA_ECB_OAEPwithSHA_256andMGF1Padding` | `AES_CBC_PKCS7Padding`   | RSA-wrapped AES | No                                 |
| `RSA_ECB_OAEPwithSHA_256andMGF1Padding` | `AES_GCM_NoPadding`      | RSA-wrapped AES | No                                 |
| `AES_GCM_NoPadding`                     | `AES_CBC_PKCS7Padding`   | KeyStore AES    | Optional (via `enforceBiometrics`) |
| `AES_GCM_NoPadding`                     | `AES_GCM_NoPadding`      | KeyStore AES    | Optional (via `enforceBiometrics`) |

**Notes:**
- **RSA key ciphers** wrap the AES encryption key with RSA. No biometric support.
- **AES key cipher** stores the key directly in Android KeyStore. Supports optional biometric authentication.
- **`enforceBiometrics` parameter** (default: `false`):
    - `false`: Gracefully degrades if biometrics unavailable
    - `true`: Strictly requires device security (PIN/pattern/biometric), throws exception if unavailable

#### Migration with Backup Protection

When upgrading between versions that use different encryption algorithms, `flutter_secure_storage` can automatically migrate your data. To protect against data loss during migration (e.g., app crashes), enable backup protection:

```dart
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    migrateWithBackup: true, // Enable crash-resistant migration
  ),
);
```

**How it works:**

1. **Before migration:** Creates backup copies of encrypted data with `_BACKUP` suffix
2. **During migration:** Tracks progress per-key using `_MIGRATED` markers
3. **After migration:** Automatically cleans up backup and progress markers
4. **On crash:** Resumes from last checkpoint without data loss

**When to use:**
- Recommended for production apps storing critical data (wallet seeds, credentials, etc.)
- Protects against data loss if migration crashes mid-process
- Enables safe recovery to pre-migration state if needed

**Default behavior:**
- `migrateWithBackup: false` (default for backward compatibility)
- When disabled, automatic migration is turned off to prevent unsafe data loss
- Enable this option if you want crash-resistant migrations

```
