## 1.3.0

* Add `enableScroll` parameter to `FluidSideMenu` (default `true`) so the menu item column automatically scrolls when content overflows the available screen height.
* Add `scrollPhysics` parameter to supply custom `ScrollPhysics` (defaults to `ClampingScrollPhysics`).
* Add `scrollController` parameter to expose an external `ScrollController` for programmatic scroll position control.
* Add `scaleChildItemsBasedOnDepth` parameter (default `true`) to control whether automatic font/icon size reduction at each nesting level is active; set `false` when using explicit per-item sizes.
* Add `menuItemPadding` parameter (`EdgeInsets?`) to override default vertical spacing around top-level menu items.
* Add `subMenuItemPadding` parameter (`EdgeInsets?`) to override default spacing above each nested child item.
* Add `textStyle` property to `FluidMenuItem` — a per-item `TextStyle` override with the highest resolution priority, superseding both widget-level style parameters and automatic depth scaling.
* Add `iconSize` property to `FluidMenuItem` — a per-item icon size override with the highest resolution priority.
* Refactor item size resolution in `buildItemRow` to follow a clear three-tier priority: per-item override > widget-level sub-style > automatic depth scaling.

## 1.2.0

* Add `itemAlignment` parameter to `FluidSideMenu` accepting the new `FluidMenuItemAlignment` enum (`left`, `center`, `right`) to align all menu items within the drawer.
* Add `subMenuItemTextStyle` parameter to `FluidSideMenu` for a widget-level text style applied to all nested child items.
* Add `subMenuItemIconSize` parameter to `FluidSideMenu` for a widget-level icon size applied to all nested child items.
* Add `onSubItemTapped` callback to `FluidSideMenu`, triggered when any nested sub-item is selected, receiving the parent index and sub-item index.
* Update `FluidMenuItem` to make `page` optional (supports parent items that act only as dropdown headers).
* Add `subItems` property to `FluidMenuItem` to declare a list of nested child items.
* Add `onTap` callback property to `FluidMenuItem` for a custom action executed when a specific item is tapped.
* Implement recursive `buildMenuItemNode` renderer with `AnimatedSize` expand/collapse transitions and `AnimatedRotation` chevron indicators.
* Implement path-based active item and tap-feedback tracking (`List<int>`) supporting arbitrary nesting depth.
* Wrap menu layout in `Align` + `SingleChildScrollView` to support left/center/right alignment and vertical overflow scrolling.

## 1.1.0

* Add `animationCurve` parameter to `FluidSideMenu` and `FluidMenuPainter` for custom easing of the fluid wave transition.
* Add `enableSwipeGestures` parameter (default `true`) to allow swiping from the left edge to open and swiping left to close the menu.
* Add `edgeDragWidth` parameter to control the width of the left edge drag detection zone.
* Add `revealOrigin` parameter to set a custom `Offset` from which the gooey wave reveal originates.
* Add `enableHapticFeedback` parameter (default `true`) to trigger `HapticFeedback.lightImpact` on open/close and `HapticFeedback.selectionClick` on item selection.
* Guard `open()` and `close()` to be no-ops when the animation is already running in the correct direction, preventing double haptic triggers.
* Move swipe drag-start haptics to fire exactly once at the beginning of each gesture, suppressing duplicate triggers on snap-to-open/close release.

## 1.0.0

* Initial release of `fluid_side_menu`.
* Implement organic fluid gooey liquid-reveal background transitions driven by distance-staggered custom vector splines.
* Support customizable staggered option entrance animations (`fade`, `scale`, `slide`).
* Support customizable tap selection feedback animations (`scalePulse`, `slideRight`, `scaleDownOthers`, `fadeOthers`, `none`, `iconSlideSwap`).
* Add item-level and global color settings (`textColor`, `iconColor`, `menuItemTextColor`, `menuItemIconColor`).
* Add optional `menuHeader` and `menuFooter` widget slots.
* Optimize rendering performance using isolated `RepaintBoundary` layers.
* Expose `FluidSideMenu.of(context)` static accessor and `open()`, `close()`, `toggle()` programmatic controls on `FluidSideMenuState`.