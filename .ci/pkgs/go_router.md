# go_router (go_router-18.0.2)

## CHANGELOG (ilk 150 satır)
```
## 18.0.2

- Fixes `ShellRoute`/`StatefulShellRoute` shell chrome (e.g. a side rail or app bar painted before the routed child) being dropped from the semantics tree by the active route's `ModalBarrier`.
Fixes pushed routes nested within a shell being lost when a dynamic routing configuration changes.

## 18.0.1

Clarifies `onEnter` documentation regarding evaluation order relative to `redirect:` chains.

## 18.0.0

- Migrates to material_ui and cupertino_ui.
- Updates minimum supported SDK version to Flutter 3.44/Dart 3.12.

## 17.5.0

- Adds route `metadata` support, including inheritance and override behavior with exposure on `GoRouterState`.
- Documents support for regular expression constraints in GoRoute path parameters.

## 17.4.0

- Fixes onExit ignored for GoRoute nested inside ShellRoute
- Adds `BlockedInitialNavigationException` (a `GoException` subtype), raised when the initial navigation is blocked by `onEnter` with no prior route to restore, so apps can distinguish this case in `onException` without string matching.

## 17.3.0

- Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.
- Adds `hasOverriddenOnExit` parameter to `GoRouteData.$route` and `RelativeGoRouteData.$route` helper methods for type-safe routes. When set to `true`, enables custom `onExit` callback invocation from route data classes extending `GoRouteData` or `RelativeGoRouteData` when the route is removed from the navigation stack.

## 17.2.3

- Fixes an assertion failure when navigating to URLs with hash fragments missing a leading slash.

## 17.2.2

- Fixes `pop()` restoring stale configuration when route has `onExit`, which could cause the popped route to reappear with async redirects.

## 17.2.1

- Fixes chained top-level redirects not being fully resolved (e.g. `/ → /a → /b` stopping at `/a`).
- Fixes route-level redirects not triggering top-level redirect re-evaluation on the new location.

## 17.2.0

- Fixes `Block.then()` and `Allow.then()` navigation callbacks being silently lost when triggered by `refreshListenable` due to re-entrant route processing.
- Adds `encoder`, `decoder` and `compare` parameters to `TypedQueryParameter` annotation for custom encoding, decoding and comparison of query parameters in `TypedGoRoute` constructors.

## 17.1.0

- Adds `TypedQueryParameter` annotation to override parameter names in `TypedGoRoute` constructors.

## 17.0.1

- Fixes an issue where `onEnter` blocking causes navigation stack loss (stale state restoration).
- Updates minimum supported SDK version to Flutter 3.32/Dart 3.8.

## 17.0.0

- **BREAKING CHANGE**
  - `ShellRoute`'s navigating changes notify `GoRouter`'s observers by default.
  - Adds `notifyRootObserver` to `ShellRouteBase`, `ShellRoute`, `StatefulShellRoute`, `ShellRouteData.$route`, `TypedShellRoute`, `TypedStatefulShellRoute`.

## 16.3.0

- Adds a top-level `onEnter` callback with access to current and next route states.

## 16.2.5

- Fixes `GoRouter.of(context)` access inside redirect callbacks by providing router access through Zone-based context tracking.
- Adds support for using context extension methods (e.g., `context.namedLocation()`, `context.go()`) within redirect callbacks.

## 16.2.4

- Fix Android Cold Start deep link with empty path losing scheme and authority.

## 16.2.3

- Fixes an issue where iOS back gesture pops entire ShellRoute instead of the active sub-route.

## 16.2.2

- Fixes broken links in readme.

## 16.2.1

- Adds state restoration topic to documentation.

## 16.2.0

- Adds `RelativeGoRouteData` and `TypedRelativeGoRoute`.
- Updates minimum supported SDK version to Flutter 3.29/Dart 3.7.

## 16.1.0

- Adds annotation for go_router_builder that enable custom string encoder/decoder [#110781](https://github.com/flutter/flutter/issues/110781). **Requires go_router_builder >= 3.1.0**.

## 16.0.0

- **BREAKING CHANGE**
  - Bump major version for `GoRouteData` breaking changes.
  - (Previously 15.2.4) Fixes routing to treat URLs with different cases (e.g., `/Home` vs `/home`) as distinct routes.
  - (Previously 15.2.3) Updates Type-safe routes topic documentation to use the mixin from `go_router_builder` 3.0.0.
  - (Previously 15.2.2) Fixes calling `PopScope.onPopInvokedWithResult` in branch routes.
  - (Previously 15.2.1) Fixes Popping state and re-rendering scaffold at the same time doesn't update the URL on web.
  - (Previously 15.2.0) `GoRouteData` now defines `.location`, `.go(context)`, `.push(context)`, `.pushReplacement(context)`, and `replace(context)` to be used for [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html). **Requires go_router_builder >= 3.0.0**.

## 15.1.3

- Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.
- Fixes typo in API docs.

## 15.1.2

- Fixes focus request propagation from `GoRouter` to `Navigator` by properly handling the `requestFocus` parameter.

## 15.1.1

- Adds missing `caseSensitive` to `GoRouteData.$route`.

## 15.1.0

- Adds `caseSensitive` to `TypedGoRoute`.

## 15.0.0

- **BREAKING CHANGE**
  - URLs are now case sensitive.
  - Adds `caseSensitive` parameter to `GoRouter` (default to `true`).
  - See [Migrating to 15.0.0](https://flutter.dev/go/go-router-v15-breaking-changes)

## 14.8.1

- Secured canPop method for the lack of matches in routerDelegate's configuration.

## 14.8.0

- Adds `preload` parameter to `StatefulShellBranchData.$branch`.

## 14.7.2

- Add missing `await` keyword to `onTap` callback in `navigation.md`.

## 14.7.1

- Fixes return type of current state getter on `GoRouter` and `GoRouterDelegate` to be non-nullable.

## 14.7.0

- Adds fragment support to GoRouter, enabling direct specification and automatic handling of fragments in routes.

```

## README (ilk 200 satır)
```
# go_router
A declarative routing package for Flutter that uses the Router API to provide a
convenient, url-based API for navigating between different screens. You can
define URL patterns, navigate using a URL, handle deep links, and a number of
other navigation-related scenarios.

## Features
GoRouter has a number of features to make navigation straightforward:

- Parsing path and query parameters using a template syntax (for example, "user/:id')
- Displaying multiple screens for a destination (sub-routes)
- Redirection support - you can re-route the user to a different URL based on
  application state, for example to a sign-in when the user is not
  authenticated
- Support for multiple Navigators via
  [ShellRoute](https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class.html) -
  you can display an inner Navigator that displays its own pages based on the
  matched route. For example, to display a BottomNavigationBar that stays
  visible at the bottom of the
  screen
- Support for both Material and Cupertino apps
- Backwards-compatibility with Navigator API

## Documentation
See the API documentation for details on the following topics:

- [Getting started](https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html)
- [Upgrade an existing app](https://pub.dev/documentation/go_router/latest/topics/Upgrading-topic.html)
- [Configuration](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
- [Navigation](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)
- [Redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- [Web](https://pub.dev/documentation/go_router/latest/topics/Web-topic.html)
- [Deep linking](https://pub.dev/documentation/go_router/latest/topics/Deep%20linking-topic.html)
- [Transition animations](https://pub.dev/documentation/go_router/latest/topics/Transition%20animations-topic.html)
- [Type-safe routes](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html)
- [Named routes](https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html)
- [Error handling](https://pub.dev/documentation/go_router/latest/topics/Error%20handling-topic.html)
- [State restoration](https://pub.dev/documentation/go_router/latest/topics/State%20restoration-topic.html)

## Migration Guides
- [Migrating to 18.0.0](https://flutter.dev/go/go-router-v18-breaking-changes).
- [Migrating to 17.0.0](https://flutter.dev/go/go-router-v17-breaking-changes).
- [Migrating to 16.0.0](https://flutter.dev/go/go-router-v16-breaking-changes).
- [Migrating to 15.0.0](https://flutter.dev/go/go-router-v15-breaking-changes).
- [Migrating to 14.0.0](https://flutter.dev/go/go-router-v14-breaking-changes).
- [Migrating to 13.0.0](https://flutter.dev/go/go-router-v13-breaking-changes).
- [Migrating to 12.0.0](https://flutter.dev/go/go-router-v12-breaking-changes).
- [Migrating to 11.0.0](https://flutter.dev/go/go-router-v11-breaking-changes).
- [Migrating to 10.0.0](https://flutter.dev/go/go-router-v10-breaking-changes).
- [Migrating to 9.0.0](https://flutter.dev/go/go-router-v9-breaking-changes).
- [Migrating to 8.0.0](https://flutter.dev/go/go-router-v8-breaking-changes).
- [Migrating to 7.0.0](https://flutter.dev/go/go-router-v7-breaking-changes).
- [Migrating to 6.0.0](https://flutter.dev/go/go-router-v6-breaking-changes)
- [Migrating to 5.1.2](https://flutter.dev/go/go-router-v5-1-2-breaking-changes)
- [Migrating to 5.0](https://flutter.dev/go/go-router-v5-breaking-changes)
- [Migrating to 4.0](https://flutter.dev/go/go-router-v4-breaking-changes)
- [Migrating to 3.0](https://flutter.dev/go/go-router-v3-breaking-changes)
- [Migrating to 2.5](https://flutter.dev/go/go-router-v2-5-breaking-changes)
- [Migrating to 2.0](https://flutter.dev/go/go-router-v2-breaking-changes)

## Changelog
See the
[Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
for a list of new features and breaking changes.

## Triage
See the [GitHub issues](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3A"p%3A%20go_router")
for all Go Router issues.

The project follows the same priority system as flutter framework.
[P0](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3A"p%3A%20go_router"+label%3AP0)
[P1](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3A"p%3A%20go_router"+label%3AP1)
[P2](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3A"p%3A%20go_router"+label%3AP2)
[P3](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3A"p%3A%20go_router"+label%3AP3)

[Package PRs](https://github.com/flutter/packages/pulls?q=is%3Aopen+is%3Apr+label%3A%22p%3A+go_router%22)

## Roadmap

This package is considered feature-complete.  The Flutter team's primary focus will be on
addressing bug fixes and ensuring stability.  While active feature development is not currently
planned, we still welcome and encourage community contributions to expand the package's
functionality.
```
