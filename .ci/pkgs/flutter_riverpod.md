# flutter_riverpod (flutter_riverpod-3.4.3)

## CHANGELOG (ilk 150 satır)
```
## 3.4.3 - 2026-09-04
### Dependency changes

- `riverpod` upgraded to `3.4.3`

## 3.4.2 - 2026-07-28

Fix a different source of `markNeedsBuild` error. Those are tricky!

### Dependency changes

- `riverpod` upgraded to `3.4.2`

## 3.4.1 - 2026-07-26

- Update devtool extension

### Dependency changes

- `riverpod` upgraded to `3.4.1`

## 3.4.0 - 2026-07-26

- Deprecated `SyncProviderTransformerMixin`. It is replaced by the newly added APIs
- Devtool-only: Better support for scoped providers with multiple overrides.
- Upgraded `analyzer` to `<15.0.0`
- Added `CustomProviderListenable`, a slightly simplified way of making custom provider extensions
- Added the ability to do `ValueListenable<int> listenable = ref.watch(counterProvider.listenable)`.
  This uses the new `pkg:listen`.
- Fix `invalidate`/`refresh` not finding providers and families when called
  from a scoped `ProviderContainer`/`ProviderScope` with overrides, if the
  provider was never read through that scope. (thanks to @itsUndefined)
- Fix markNeedsBuild exception when flushing a provider inside Widget lifecycle
- Fix `invalidate`/`refresh` not finding providers and families when called
  from a scoped `ProviderScope` with overrides, if the provider was never
  read through that scope. (thanks to @itsUndefined)
- Fixed a listener leak if `ConsumerState.dispose` threw.

### Dependency changes

- `riverpod` upgraded to `3.4.0`

## 3.3.2 - 2026-06-10

- Fixes assertion error when providers are unpaused.
- Fixes assertion error when invalidating a provider after an autoDispose
  provider schedules disposal. (thanks to @a1573595)

### Dependency changes

- `riverpod` upgraded to `3.3.2`

## 3.3.2-dev.2 - 2026-05-06

### Dependency changes

- `riverpod` upgraded to `3.3.2-dev.2`

## 3.3.2-dev.1 - 2026-05-03

- Devtool-only:
  Added `debugTrackProviderCreation`, which can be set to `true` to enable the Riverpod devtool
  to jump to the source of a provider.
- Added `Ref.onManualInvalidation()` lifecycle method to listen for manual provider invalidations.
  This allows distinguishing between manual invalidations (via `refresh`/`invalidate`/`invalidateSelf`)
  and automatic invalidations caused by dependency changes. Additionally, providers can now forward
  invalidations to other providers within `onManualInvalidation` callbacks, enabling patterns like:

  ```dart
  final sourceProvider = Provider<String>(...);
  final derivedProvider = Provider((ref) {
    final thing = ref.watch(sourceProvider);
    ref.onManualInvalidation(() {
      ref.invalidate(sourceProvider);
    });
    return '$thing is derived!';
  });

  ref.invalidate(derivedProvider); // also invalidates sourceProvider!
  ```

  Which allows for users to invalidate only the providers they care about, while implementation details can be handled privately. (thanks to @TekExplorer)

- Added `ProviderContainer.allProviders()`, to obtain all providers accessible from said container. You can optionally specify `allProviders(family: myFamily)` to only include providers from said family.
- Refactored internal scheduling mechanism to solve some markNeedsBuild error.
- Removed `@internal` for `ProviderFamily.new`
- Added various life-cycles to `ProviderObserver`
- Fix `.future` incorrectly notifying listeners even when `AsyncValue` doesn't change.

### Dependency changes

- `riverpod` upgraded to `3.3.2-dev.1`

## 3.3.1 - 2026-03-09

- Add missing `disposeNotifier` flag on `overrideWith`.

## 3.3.0 - 2026-03-09

- Added `ChangeNotifierProvider(disposeNotifier: false)`, to disable the automatic
  disposal of the created `ChangeNotifier`. This enables simpler migration from `pkg:provider` to `pkg:riverpod`
  when a `ChangeNotifier` is reused between multiple providers.

## 3.2.1 - 2026-02-03

- Fixed a bug where resuming a paused provider could cause it to never
  notify its listener ever again.

### Dependency changes

- `riverpod` upgraded to `3.2.1`

## 3.2.0 - 2026-01-17

- Fix the IDE pausing on "markNeedsBuild" exceptions when checking "pause on all exceptions".
- `ConsumerWidget`'s now uses the TickerMode notifier instead of TickerMode.of to avoid unnecessary rebuilds when widgets are hidden (thanks to @Colton127)
- Added missing `weak` flags to `WidgetRef.listen/listenManual`
- Added `Ref.isPaused` to check if there are any active/non-paused listeners.
- Deprecated `family.overrideWith` in favour of `family.overrideWith2`
  The behaviour is the same, but the callback now takes the argument as a parameter.
  In 4.0.0, `overrideWith2` will be renamed to `overrideWith`.
- Fix a regression that caused Notifiers to lose their state when one of their dependencies changed. (thanks to @yegair)
- Fixed `ref.mounted` returning `true` for stale refs after provider rebuild, causing race conditions in async providers.
- Fixed a bug where providers with only weak listeners (`ref.listen(..., weak: true)`) would incorrectly initialize during hot reload (thanks to @tguerin)
- Fixes `selectAsync` sometimes throwing an exception when unsubscribed to.

### Dependency changes

- `riverpod` upgraded to `3.2.0`

## 3.1.0 - 2025-12-26

- Added an alternative way to combine asynchronous providers.
  This can be done by using `AsyncValue.requireValue` inside `FutureProvider`/`AsyncNotifier`
  like so:

  ```dart
  final sumProvider = FutureProvider((ref) { // Not async
    AsyncValue<int> a = ref.watch(aProvider);
    AsyncValue<int> b = ref.watch(bProvider);

    // The following is safe if used inside the init function of providers.
    return a.requireValue + b.requireValue;
  })
  ```

  This enables synchronously combining asynchronous providers.

  See [AsyncValue.requireValue](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue/requireValue.html)

```

## README (ilk 200 satır)
```
<p>
  <a href="https://flutter.dev/docs/development/packages-and-plugins/favorites">
    <img src="https://raw.githubusercontent.com/rrousselGit/riverpod/master/resources/flutter_favorite.png" width="100" align="left" />
  </a>
  <a href="https://github.com/rrousselGit/riverpod/actions"><img src="https://github.com/rrousselGit/riverpod/workflows/Build/badge.svg" alt="Build Status"></a>
  <a href="https://codecov.io/gh/rrousselgit/riverpod"><img src="https://codecov.io/gh/rrousselgit/riverpod/branch/master/graph/badge.svg" alt="codecov"></a>
  <a href="https://github.com/rrousselgit/riverpod"><img src="https://img.shields.io/github/stars/rrousselgit/riverpod.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
  <a href="https://discord.gg/GSt793j6eT"><img src="https://img.shields.io/discord/765557403865186374.svg?logo=discord&color=blue" alt="Discord"></a>

  <p>
    <a href="https://www.netlify.com">
      <img src="https://www.netlify.com/img/global/badges/netlify-color-accent.svg" alt="Deploys by Netlify" />
    </a>
  </p>

</p>

<p align="center">
  <img src="https://github.com/rrousselGit/riverpod/blob/master/resources/icon/Facebook%20Cover%20A.png?raw=true" width="100%" alt="Riverpod" />
</p>

---

A reactive caching and data-binding framework. https://riverpod.dev
Riverpod makes working with asynchronous code a breeze by:

- Handling errors/loading states by default. No need to manually catch errors
- Natively supporting advanced scenarios, such as pull-to-refresh
- Separating the logic from your UI
- Ensuring your code is testable, scalable and reusable

| riverpod         | [![pub package](https://img.shields.io/pub/v/riverpod.svg?label=riverpod&color=blue)](https://pub.dartlang.org/packages/riverpod)                 |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| flutter_riverpod | [![pub package](https://img.shields.io/pub/v/riverpod.svg?label=flutter_riverpod&color=blue)](https://pub.dartlang.org/packages/flutter_riverpod) |
| hooks_riverpod   | [![pub package](https://img.shields.io/pub/v/riverpod.svg?label=hooks_riverpod&color=blue)](https://pub.dartlang.org/packages/hooks_riverpod)     |

Welcome to [Riverpod] (anagram of [Provider])!

For learning how to use [Riverpod], see its documentation:
\>\>\> https://riverpod.dev <<<

Long story short:

- Define network requests by writing a function annotated with `@riverpod`:

  ```dart
  @riverpod
  Future<String> boredSuggestion(Ref ref) async {
    final response = await http.get(
      Uri.https('boredapi.com', '/api/activity'),
    );
    final json = jsonDecode(response.body);
    return json['activity']! as String;
  }
  ```

- Listen to the network request in your UI and gracefully handle loading/error states.

  ```dart
  class Home extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final boredSuggestion = ref.watch(boredSuggestionProvider);
      // Perform a switch-case on the result to handle loading/error states
      return switch (boredSuggestion) {
        AsyncData(:final value) => Text('data: $value'),
        AsyncError(:final error) => Text('error: $error'),
        _ => const Text('loading'),
      };
    }
  }
  ```

## Contributing

Contributions are welcome!

Here is a curated list of how you can help:

- Report bugs and scenarios that are difficult to implement
- Report parts of the documentation that are unclear
- Fix typos/grammar mistakes
- Update the documentation or add examples
- Implement new features by making a pull-request

## Sponsors

<p align="center">
  <a href="https://raw.githubusercontent.com/rrousselGit/freezed/master/sponsorkit/sponsors.svg">
    <img src='https://raw.githubusercontent.com/rrousselGit/freezed/master/sponsorkit/sponsors.svg'/>
  </a>
</p>

[provider]: https://github.com/rrousselGit/provider
[riverpod]: https://github.com/rrousselGit/riverpod
[flutter_hooks]: https://github.com/rrousselGit/flutter_hooks
[inheritedwidget]: https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html
[hooks_riverpod]: https://pub.dev/packages/hooks_riverpod
[flutter_riverpod]: https://pub.dev/packages/flutter_riverpod
```
