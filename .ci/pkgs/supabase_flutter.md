# supabase_flutter (supabase_flutter-2.18.0)

## CHANGELOG (ilk 150 satır)
```
## 2.18.0

 - **FEAT**(supabase_flutter): add RealtimeLifecycleOptions to delay or skip the realtime disconnect on pause ([#1900](https://github.com/supabase/supabase-flutter/issues/1900)). ([ea93c9a6](https://github.com/supabase/supabase-flutter/commit/ea93c9a6c3b19ad0adc6b8c32df27f36948ae714))

## 2.17.2

 - Update a dependency to the latest release.

## 2.17.1

 - Update a dependency to the latest release.

## 2.17.0

 - **REFACTOR**: extract shared code into supabase_common package ([#1573](https://github.com/supabase/supabase-flutter/issues/1573)). ([46601bbb](https://github.com/supabase/supabase-flutter/commit/46601bbb80ca2f52929f8e0c2a6e5456d3e32360))
 - **FIX**(realtime_client): faster channel rejoin on web ([#1471](https://github.com/supabase/supabase-flutter/issues/1471)). ([bc06a310](https://github.com/supabase/supabase-flutter/commit/bc06a310cf09bdba87668695b48bc8b8f353c495))
 - **FEAT**(auth): support friendlyName and user.name fallback for WebAuthn passkey enrollment ([#1603](https://github.com/supabase/supabase-flutter/issues/1603)). ([558b0346](https://github.com/supabase/supabase-flutter/commit/558b03461441d340b1656606d1086382481611f8))
 - **FEAT**(client): add opt-in trace context propagation headers ([#1564](https://github.com/supabase/supabase-flutter/issues/1564)). ([85780e60](https://github.com/supabase/supabase-flutter/commit/85780e607a00904870fe7f68dbd45ee5797256b6))
 - **FEAT**(client): add session-URL-detection predicate and persistSession flag ([#1558](https://github.com/supabase/supabase-flutter/issues/1558)). ([c8b02ed0](https://github.com/supabase/supabase-flutter/commit/c8b02ed062d78145671eecc2504875c19377a221))
 - **DOCS**(auth): document getOAuthSignInUrl for URL-without-launch, mark oauth parity implemented ([#1548](https://github.com/supabase/supabase-flutter/issues/1548)). ([1a1c95bf](https://github.com/supabase/supabase-flutter/commit/1a1c95bf178a0af8301d54366ebbf999f911d8f0))

## 2.16.0

 - **FIX**(supabase_flutter): drop passkeys requireResidentKey workaround, bump dependency ([#1521](https://github.com/supabase/supabase-flutter/issues/1521)). ([7907c6cb](https://github.com/supabase/supabase-flutter/commit/7907c6cbc3dc31500a5cf85a81b97efc04f3006c))
 - **FEAT**(supabase_flutter): default debug logging off under flutter test ([#1530](https://github.com/supabase/supabase-flutter/issues/1530)). ([941ee804](https://github.com/supabase/supabase-flutter/commit/941ee80498f7f6d1351351aca449b8a5bc2655da))

## 2.15.4

 - **FIX**(supabase_flutter): preserve hash routes and repeated query keys when clearing auth params ([#1511](https://github.com/supabase/supabase-flutter/issues/1511)). ([4fca4126](https://github.com/supabase/supabase-flutter/commit/4fca4126fe3649f218b296b0e40bb4bc2de87890))

## 2.15.3

 - **FIX**(supabase_flutter): backfill requireResidentKey when omitted by the server ([#1502](https://github.com/supabase/supabase-flutter/issues/1502)). ([cf382968](https://github.com/supabase/supabase-flutter/commit/cf3829686fdbceb559fe41ad558089b44fcc9af1))

## 2.15.2

 - **FIX**(supabase_flutter): full web and WASM support ([#1497](https://github.com/supabase/supabase-flutter/issues/1497)). ([2f860f2c](https://github.com/supabase/supabase-flutter/commit/2f860f2cd2c4d45b5b2b695641702b0d543ec4ea))

## 2.15.1

 - **REFACTOR**: dedupe bucket payload and OAuth launch logic ([#1463](https://github.com/supabase/supabase-flutter/issues/1463)). ([c5f9b247](https://github.com/supabase/supabase-flutter/commit/c5f9b2471c64d65b604802cbda36221cca0a6506))
 - **REFACTOR**: de-abbreviate cond* platform getters to conditional* ([#1438](https://github.com/supabase/supabase-flutter/issues/1438)). ([9e71a240](https://github.com/supabase/supabase-flutter/commit/9e71a240bc7ed30126b5d90a81697303cb515ef7))
 - **FIX**(supabase_flutter): accept PasskeyAuthenticatorInterface instead of depending on passkeys ([#1444](https://github.com/supabase/supabase-flutter/issues/1444)). ([f05d4c6c](https://github.com/supabase/supabase-flutter/commit/f05d4c6c544591905c2dbacf815526733ffabd5a))
 - **FIX**(auth): recognize error query parameter in auth callback redirects ([#1472](https://github.com/supabase/supabase-flutter/issues/1472)). ([cb7e7e62](https://github.com/supabase/supabase-flutter/commit/cb7e7e62d04d887d888fd3e73ef83a584ae45d77))
 - **FIX**(supabase_flutter): clear auth params from web URL after exchange ([#1456](https://github.com/supabase/supabase-flutter/issues/1456)). ([8b1e1b22](https://github.com/supabase/supabase-flutter/commit/8b1e1b22aae6da4366dd8c404de8f3351dcc57a1))
 - **FIX**: correctness fixes across gotrue, postgrest, storage, supabase and supabase_flutter ([#1445](https://github.com/supabase/supabase-flutter/issues/1445)). ([bf31389d](https://github.com/supabase/supabase-flutter/commit/bf31389d4adb64bad92205015224882ccd75d48a))
 - **DOCS**: add Supabase logo to supabase_flutter README so it renders on pub.dev ([#1458](https://github.com/supabase/supabase-flutter/issues/1458)). ([7354d1c8](https://github.com/supabase/supabase-flutter/commit/7354d1c8f06ec376b9a526f1f62f3a6fc21ac8bc))

## 2.15.0

 - **FIX**: raise min Dart SDK to 3.4.0 across all packages ([#1409](https://github.com/supabase/supabase-flutter/issues/1409)). ([311f883f](https://github.com/supabase/supabase-flutter/commit/311f883f73406b60a0e95ea05e3444a4bab80c5a))
 - **FIX**(auth): update session on email change links in PKCE flow ([#1395](https://github.com/supabase/supabase-flutter/issues/1395)). ([6b7871d9](https://github.com/supabase/supabase-flutter/commit/6b7871d920836a1751699fe0dfde90d460c4df16))
 - **FEAT**(supabase_flutter): add passkey ceremony helpers ([#1408](https://github.com/supabase/supabase-flutter/issues/1408)). ([8c8ec84e](https://github.com/supabase/supabase-flutter/commit/8c8ec84ef61915566a1af6e3227a6e9f9a98a831))

## 2.14.2

 - **DOCS**(supabase_flutter): fix Facebook native login for iOS and Android ([#1386](https://github.com/supabase/supabase-flutter/issues/1386)). ([8cbea828](https://github.com/supabase/supabase-flutter/commit/8cbea8283e38c2a765da715ffa79e045471b1257))
 - **DOCS**: update facebook native login docs ([#1322](https://github.com/supabase/supabase-flutter/issues/1322)). ([213f6277](https://github.com/supabase/supabase-flutter/commit/213f6277869c47ac5667779f3499cc11ba0aea69))

## 2.14.1

 - Update a dependency to the latest release.

## 2.14.0

 - **FIX**: make `defaultHeaders` unmodifiable to prevent accidental mutation ([#1370](https://github.com/supabase/supabase-flutter/issues/1370)). ([957d7507](https://github.com/supabase/supabase-flutter/commit/957d7507a93f23ffab5f449a4da85804cb0c0010))
 - **FEAT**: update X-Client-Info to use structured semicolon-delimited metadata ([#1362](https://github.com/supabase/supabase-flutter/issues/1362)). ([71653422](https://github.com/supabase/supabase-flutter/commit/71653422f1ce79ef83ae007eb52b411e09cdf86e))

## 2.13.0

 - **FEAT**: rename anon key → publishable key, service role key → secret key ([#1360](https://github.com/supabase/supabase-flutter/issues/1360)). ([d4e23707](https://github.com/supabase/supabase-flutter/commit/d4e237077899c49f1c5e1faeeebf17f9a82d3d76))
 - **DOCS**(gotrue): require onError handler in onAuthStateChange ([#1355](https://github.com/supabase/supabase-flutter/issues/1355)). ([74bb1725](https://github.com/supabase/supabase-flutter/commit/74bb1725d3ba61c6d07a7f5fe81f9ebcf0088188))

## 2.12.4

 - **FIX**(supabase_flutter): log instead of swallow auth state stream errors ([#1346](https://github.com/supabase/supabase-flutter/issues/1346)). ([77ca5dbe](https://github.com/supabase/supabase-flutter/commit/77ca5dbe96681c72b21be550ee48befcf24f8616))
 - **FIX**(postgrest): replace SCREAMING_SNAKE_CASE HTTP method constants with enum ([#1347](https://github.com/supabase/supabase-flutter/issues/1347)). ([13e8b39e](https://github.com/supabase/supabase-flutter/commit/13e8b39e791c85d532b078bccaaf9027b774e9c0))
 - **FIX**(supabase_flutter): simplify lifecycle reconnection with serial Future chain ([#1340](https://github.com/supabase/supabase-flutter/issues/1340)). ([7121ac2b](https://github.com/supabase/supabase-flutter/commit/7121ac2bcfb0eba5697b22a08eac6c016c933b66))
 - **FIX**(realtime): prevent null check crash in connect() during rapid lifecycle transitions ([#1321](https://github.com/supabase/supabase-flutter/issues/1321)). ([61f7cd1c](https://github.com/supabase/supabase-flutter/commit/61f7cd1c4e3aa56a06e089459efdded4ea7bb28d))
 - **DOCS**(realtime,supabase_flutter): add class-level dartdoc to RealtimeClient and SupabaseAuth ([#1344](https://github.com/supabase/supabase-flutter/issues/1344)). ([b662dfd5](https://github.com/supabase/supabase-flutter/commit/b662dfd538ecef275cb684545dc51df351c2a269))

## 2.12.3

 - **FIX**(realtime): prevent null check crash in connect() during rapid lifecycle transitions ([#1321](https://github.com/supabase/supabase-flutter/issues/1321)). ([61f7cd1c](https://github.com/supabase/supabase-flutter/commit/61f7cd1c4e3aa56a06e089459efdded4ea7bb28d))

## 2.12.2

 - Update a dependency to the latest release.

## 2.12.1

 - Update a dependency to the latest release.

## 2.12.0

 - **FEAT**(postgrest): add missing PostgREST v12 operators ([#1273](https://github.com/supabase/supabase-flutter/issues/1273)). ([f6270260](https://github.com/supabase/supabase-flutter/commit/f627026038344d6f2fdaa8ff8f7e0c968a8dad1b))
 - **DOCS**: update signInWithIdToken provider documentation ([#1264](https://github.com/supabase/supabase-flutter/issues/1264)). ([b10d0c88](https://github.com/supabase/supabase-flutter/commit/b10d0c88171d9d257694743d1ad24b7b6a1c190f))

## 2.11.0

 - **FEAT**(gotrue): introduce getClaims method to verify and extract JWT claims ([#1246](https://github.com/supabase/supabase-flutter/issues/1246)). ([615d687f](https://github.com/supabase/supabase-flutter/commit/615d687f012040c89df1f7349ba59fe4026969ff))

## 2.10.3

 - **DOCS**: update google_sign_in example ([#1240](https://github.com/supabase/supabase-flutter/issues/1240)). ([cad17842](https://github.com/supabase/supabase-flutter/commit/cad1784261bdfa43c2bf6169b6d1e75df8dcfa61))

## 2.10.2

 - Update a dependency to the latest release.

## 2.10.1

 - **FIX**: Prevent web incompatibility due to import of dart:io ([#1220](https://github.com/supabase/supabase-flutter/issues/1220)). ([3c8d4db6](https://github.com/supabase/supabase-flutter/commit/3c8d4db62aec26835e5d8ff387c4b32c91ce8676))

## 2.10.0

 - **FIX**(supabase_flutter): Safely check if conn is not null to avoid null check operator ([#1178](https://github.com/supabase/supabase-flutter/issues/1178)). ([6a5be512](https://github.com/supabase/supabase-flutter/commit/6a5be5124026d27d48675749d2c5759d8c61a9b3))
 - **FEAT**(supabase_flutter): Make `Supabase.initialize()` idempotent ([#1194](https://github.com/supabase/supabase-flutter/issues/1194)). ([cc058e70](https://github.com/supabase/supabase-flutter/commit/cc058e709850e178641060942be7de3ca643049c))

## 2.9.1

 - Update a dependency to the latest release.
 - The `auth.mfa.enroll()` method return value now has a nullable `totp` property to support phone MFA enrollment.

## 2.9.0

 - Require Dart >=3.3.0 and flutter >=3.19.0
 - **FIX**: Dispose supabase client after flutter web hot-restart ([#1142](https://github.com/supabase/supabase-flutter/issues/1142)). ([ce582e3e](https://github.com/supabase/supabase-flutter/commit/ce582e3ee7e5d9922d5e38554dfe36a97a47d988))
 - **FEAT**(gotrue,supabase,supabase_flutter,realtime_client): Use web package to access web APIs ([#1135](https://github.com/supabase/supabase-flutter/issues/1135)). ([dfa71c9a](https://github.com/supabase/supabase-flutter/commit/dfa71c9a308b9c51f037f379196ed6f6a9e78f18))

## 2.8.4

 - **FIX**: Allow null to be returned from accessToken function when the user is not signed in ([#1099](https://github.com/supabase/supabase-flutter/issues/1099)). ([d04d9e63](https://github.com/supabase/supabase-flutter/commit/d04d9e63bcc46c2ee71e311b4c3addb216f0f520))
 - **DOCS**: Fix typos ([#1108](https://github.com/supabase/supabase-flutter/issues/1108)). ([46b483f8](https://github.com/supabase/supabase-flutter/commit/46b483f83a70fb7785ef3bccca6849fa6b07852c))

## 2.8.3

 - Update a dependency to the latest release.

## 2.8.2

 - Update a dependency to the latest release.

## 2.8.1

 - **FIX**: Support custom access token ([#1073](https://github.com/supabase/supabase-flutter/issues/1073)). ([fc9ad2c9](https://github.com/supabase/supabase-flutter/commit/fc9ad2c94a02921ca8ced4564d9bcd8cde2c2397))

## 2.8.0

 - **FIX**: Rename logger from gotrue to auth ([#1055](https://github.com/supabase/supabase-flutter/issues/1055)). ([eea1ea6c](https://github.com/supabase/supabase-flutter/commit/eea1ea6c4e200e8ffc52d8343c0684c19670e3ed))
```

## README (ilk 200 satır)
```
<br />
<p align="center">
  <a href="https://supabase.com">
    <img alt="Supabase Logo" width="300" src="https://raw.githubusercontent.com/supabase/supabase/master/packages/common/assets/images/logo-preview.jpg">
  </a>

  <h1 align="center">supabase_flutter</h1>

  <p align="center">
    Flutter client library for <a href="https://supabase.com">Supabase</a>.
  </p>

  <p align="center">
    <a href="https://supabase.com/docs/guides/with-flutter">Guides</a>
    ·
    <a href="https://supabase.com/docs/reference/dart/introduction">Reference Docs</a>
  </p>
</p>

<div align="center">

[![pub package](https://img.shields.io/pub/v/supabase_flutter.svg)](https://pub.dev/packages/supabase_flutter)
[![pub test](https://github.com/supabase/supabase-flutter/workflows/Test/badge.svg)](https://github.com/supabase/supabase-flutter/actions?query=workflow%3ATest)

</div>

## Getting Started

Import the package:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

Initialize `Supabase` before using it:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    publishableKey: SUPABASE_KEY,
  );

  runApp(MyApp());
}

// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;
```

## Usage example

* [Authentication](#authentication)
  * [Native Apple Sign in](#native-apple-sign-in)
  * [Native Google sign in](#native-google-sign-in)
  * [OAuth login](#oauth-login)
  * [Passkeys](#passkeys)
* [Database](#database)
* [Realtime](#realtime)
  * [Postgres Changes](#postgres-changes)
  * [Broadcast](#broadcast)
  * [Presence](#presence)
* [Storage](#storage)
* [Edge Functions](#edge-functions)
* [Deep Links](#deep-links)
* [Custom LocalStorage](#custom-localstorage)
- [Logging](#logging)


### <a id="authentication"></a>[Authentication](https://supabase.com/docs/guides/auth)

```dart
final supabase = Supabase.instance.client;

// Email and password sign up
await supabase.auth.signUp(
  email: email,
  password: password,
);

// Email and password login
await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Magic link login
await supabase.auth.signInWithOtp(email: 'my_email@example.com');

// Listen to auth state changes
supabase.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;
  // Do something when there is an auth event
});
```

#### <a id="native-apple-sign-in"></a>Native Apple Sign in

You can perform Apple sign in using the [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple) package on Flutter.
Follow the instructions on README of the `sign_in_with_apple` package to setup the native Apple sign in on iOS and macOS.

Once the setup is complete on the Flutter app, add the bundle ID of your app to your Supabase dashboard in `Authentication -> Providers -> Apple` in order to register your app with Supabase.

```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Performs Apple sign in on iOS or macOS
Future<AuthResponse> signInWithApple() async {
  final rawNonce = supabase.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw const AuthException(
        'Could not find ID Token from generated credential.');
  }

  return signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );
}
```

#### <a id="native-google-sign-in"></a>Native Google sign in

You can perform native Google sign in on Android and iOS using [google_sign_in](https://pub.dev/packages/google_sign_in).
For platform specific settings, follow the instructions on README of the package.

First, create client IDs for your app. You need to create a web client ID as well to perform Google sign-in with Supabase.

- [Steps to obtain web client ID](https://developers.google.com/identity/sign-in/android/start-integrating#configure_a_project)
- [Steps to obtain Android client ID](https://developers.google.com/identity/sign-in/android/start-integrating#configure_a_project)
- [Steps to obtain iOS client ID](https://developers.google.com/identity/sign-in/ios/start-integrating#get_an_oauth_client_id)

Once you have registered your app and created the client IDs, add the web client ID in your Supabase dashboard in `Authentication -> Providers -> Google`. Also turn on the `Skip nonce check` option, which will enable Google sign-in on iOS.

At this point you can perform native Google sign in using the following code. Be sure to replace the `webClientId` and `iosClientId` with your own.

The following example is very basic. Please refer to the [google_sign_in](https://pub.dev/packages/google_sign_in) package for the correct details.

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

...

Future<AuthResponse> _googleSignIn() async {
  /// TODO: update the Web client ID with your own.
  ///
  /// Web Client ID that you registered with Google Cloud.
  const webClientId = 'my-web.apps.googleusercontent.com';

  /// TODO: update the iOS client ID with your own.
  ///
  /// iOS Client ID that you registered with Google Cloud.
  const iosClientId = 'my-ios.apps.googleusercontent.com';

  // Google sign in on Android will work without providing the Android
  // Client ID registered on Google Cloud.

  final GoogleSignIn signIn = GoogleSignIn.instance;

  // At the start of your app, initialize the GoogleSignIn instance
  unawaited(
    signIn.initialize(clientId: iosClientId, serverClientId: webClientId));

  // Perform the sign in
  final googleAccount = await signIn.authenticate();
  final googleAuthorization = await googleAccount.authorizationClient.authorizationForScopes([]);
  final googleAuthentication = googleAccount!.authentication;
  final idToken = googleAuthentication.idToken;
  final accessToken = googleAuthorization.accessToken;

  if (idToken == null) {
    throw 'No ID Token found.';
  }

  return supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}
...
```
