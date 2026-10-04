# scrollable_positioned_list (scrollable_positioned_list-0.3.8)

## CHANGELOG (ilk 150 satır)
```
# 0.3.8
* Add ScrollOffsetController to allow pixel-based changes in offset.
* Bump min sdk version to 2.15.0

# 0.3.7
* Add ScrollOffsetListener to allow listening to changes in scroll offset.

# 0.3.6
* Fix cache extents for horizontal lists
* scrollTo future doesn't complete until scrolling is done.

# 0.3.5
* Fix extraneous animation controller declaration in 0.3.4.

# 0.3.4
* Disposed the animation controller when disposing the scrollable list.

# 0.3.3
* Fix potential crash when reading from RenderBox.size.

# 0.3.2
* Re-apply Flutter framework bindings' null safety calls but set SDK
  constraints correctly to 2.12.0 instead.

# 0.3.1
* Reverts change from 0.3.0 where the Flutter version constraint should have
  been set to 2.12.0 instead of 2.10.5.

# 0.3.0
  * Move to Flutter version 2.10.5 and update dependencies' null safety calls.

# 0.2.3
  * Support shrink wrap.
# 0.2.2
  * Move dependencies from pre-release versions to released versions.

# 0.2.1
  * Fix crash on NaN or infinite offset.

# 0.2.0-nullsafety.0
  * Update to null safety.

# 0.1.10
  * Update the home page URL to fix
    [issue #190](https://github.com/google/flutter.widgets/issues/190).
  * Miscellaneous tweaks to the example.
  * Added documentation to address
    [issue #96](https://github.com/google/flutter.widgets/issues/96).
  * Miscellaneous other cleanup.
  * Restructured `_ScrollablePositionedListState` to try to simplify logic.
  * Fixed an issue with `ItemScrollController.scrollTo` where it could scroll to
    the wrong item if a non-zero `alignment` was specified and if the list was
    manually scrolled by dragging.

# 0.1.9
  * Fixed the example in `README.md`.  Fixes
    [issue #191](https://github.com/google/flutter.widgets/issues/191).
  * Made the example runnable with `flutter run`.  Fixes
    [issue #211](https://github.com/google/flutter.widgets/issues/211).
  * Updates to computation of semantic clip.
  * Smoother transition between views on long scrolls.
  * New controls over transition between views on long scrolls.

# 0.1.8
  * Set updateScheduled to false when short circuiting due to empty list.
    To fix https://github.com/google/flutter.widgets/issues/182.

# 0.1.7
  * Apply viewport dimensions in UnboundedRenderedViewport.performResize.
    To work around change in https://github.com/flutter/flutter/pull/61973
    causing breakage

# 0.1.6
  * Change to do local scroll (without a fade) whenever target item is found
    within the cache.
  * Added sdk constraints to the example.
  * Moved `itemScrollControllerDetachment` to
    `_ScrollablePositionedListState.deactivate`.

# 0.1.5

  * Added minCacheExtent to ScrollablePositionedList
  * Fixes the issue when item count updated from zero to one and `index` in
    `itemBuilder` becomes `-1`.  Fixes
    [issue #104](https://github.com/google/flutter.widgets/issues/104).

# 0.1.4

  *  itemBuilders should not be called with indices > itemCount - 1.  Fixes
     [issue #42](https://github.com/google/flutter.widgets/issues/42) and
     [issue #77](https://github.com/google/flutter.widgets/issues/77).

# 0.1.3

  * Don't build items when `itemCount` is 0. Fixes
    [issue #78](https://github.com/google/flutter.widgets/issues/78).

  * Fix typos in `README.md`.

# 0.1.2

  * Store scroll state in page storage to fix
    [issue #43](https://github.com/google/flutter.widgets/issues/43).

# 0.1.1

  * Fix padding for horizontal lists.

  * Add `ScrollablePositionedList.separated` constructor to complete
    [issue #34](https://github.com/google/flutter.widgets/issues/34).

  * Add `isAttached` method to `ItemScrollController`.

# 0.1.0

  * Properly bound `ScrollablePositionedList` to fix
    [issue #23](https://github.com/google/flutter.widgets/issues/23).

  * Allow `ScrollablePositionedList` alignment outside `[0..1]` to fix
    [issue #31](https://github.com/google/flutter.widgets/issues/31).

  * Moved `ScrollablePositionedList` example into `example` subdirectory.

# 0.0.1

* Added `ScrollablePositionedList`.
```

## README (ilk 200 satır)
```
# scrollable_positioned_list

A flutter list that allows scrolling to a specific item in the list.

Also allows determining what items are currently visible.

## Usage

A `ScrollablePositionedList` works much like the builder version of `ListView`
except that the list can be scrolled or jumped to a specific item.

### Example

A `ScrollablePositionedList` can be created with:

```dart
final ItemScrollController itemScrollController = ItemScrollController();
final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create()

ScrollablePositionedList.builder(
  itemCount: 500,
  itemBuilder: (context, index) => Text('Item $index'),
  itemScrollController: itemScrollController,
  scrollOffsetController: scrollOffsetController,
  itemPositionsListener: itemPositionsListener,
  scrollOffsetListener: scrollOffsetListener,
);
```

One then can scroll to a particular item with:

```dart
itemScrollController.scrollTo(
  index: 150,
  duration: Duration(seconds: 2),
  curve: Curves.easeInOutCubic);
```

or jump to a particular item with:

```dart
itemScrollController.jumpTo(index: 150);
```

One can monitor what items are visible on screen with:

```dart
itemPositionsListener.itemPositions.addListener(() => ...);
```

### Experimental APIs (subject to bugs and changes)

Changes in scroll position can be monitored with:

```dart
scrollOffsetListener.changes.listen((event) => ...)
```

see `ScrollSum` in [this test](test/scroll_offset_listener_test.dart) for an example of how the current offset can be 
calculated from the stream of scroll change deltas.  This feature is new and experimental.

Changes in scroll position in pixels, relative to the current scroll position, can be made with:

```dart
scrollOffsetController.animateScroll(offset: 100, duration: Duration(seconds: 1));
```

A full example can be found in the example folder.

--------------------------------------------------------------------------------

This is not an officially supported Google product.
```
