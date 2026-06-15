## 1.3.0

* Add customizable hover styles on menu items:
  * `hoverColor` (`Color?`): Shifts text/icon color on hover.
  * `hoverBackgroundColor` (`Color?`): Displays a smooth, material-style rounded pill background.
  * `hoverScale` (`double`): Scales the menu item.
  * `hoverOffset` (`Offset`): Slides/offsets the menu item.
* Animate hover color changes smoothly using `TweenAnimationBuilder` (for icons and dropdown chevrons) and `AnimatedDefaultTextStyle` (for labels).
* Disable hover effects and cursor changes for disabled menu items.
* Update example app with a `HOVER STYLING CONFIGURATOR` section to test different hover colors, background pill overlays, scale levels, and slide displacements at runtime.

## 1.2.0

* Add `isEnabled` property to `FluidMenuItem` (default `true`) to statically disable menu items. Disabled items are visually grayed out, ignore selection animations, and do not respond to tap/pointer interactions.
* Add programmatic control to enable or disable menu items dynamically from anywhere in the app using `FluidSideMenu.of(context)?.setItemEnabled(path, enabled)`.
* Add custom hover cursor behaviors on desktop/web platforms (`SystemMouseCursors.forbidden` for disabled items, `SystemMouseCursors.click` for active items).
* Update example app to demonstrate static and dynamic disabling behaviors.

## 1.1.0

* Add swipe gestures to open and close the drawer: pull from the left edge (controlled by `edgeDragWidth`) to open, swipe left anywhere when fully open to close.
* Add velocity-sensitive drag finishing — fast flings snap the drawer in the fling direction.
* Add `enableSwipeGestures` parameter (default `true`) and `edgeDragWidth` parameter (default `30.0`).
* Add `animationCurve` parameter to `FluidSideMenu` and `FluidMenuPainter` for custom easing of the fluid wave transition (default `Curves.easeInOutCubic`).
* Add `revealOrigin` parameter (`Offset?`) to set a custom origin point for the gooey wave reveal.
* Add `enableHapticFeedback` parameter (default `true`): fires `HapticFeedback.lightImpact` on open/close and `HapticFeedback.selectionClick` on item selection. Haptics are de-duplicated — a single pulse fires at drag-start so no double haptic occurs on snap-to-open/close.
* Add `itemAlignment` parameter accepting the new `FluidMenuItemAlignment` enum (`left`, `center`, `right`) to align all menu items within the drawer.
* Add `subMenuItemTextStyle` and `subMenuItemIconSize` parameters for a widget-level style applied to all nested child items.
* Add `onSubItemTapped` callback triggered with the parent and child index when a nested item is selected.
* Update `FluidMenuItem`: make `page` optional, add `subItems` (`List<FluidMenuItem>?`) for collapsible dropdown groups of arbitrary depth, add `onTap` custom callback, add `textStyle` and `iconSize` per-item size overrides.
* Add `enableScroll` parameter (default `true`): wraps the item column in a `SingleChildScrollView` so long lists remain reachable on small screens.
* Add `scrollPhysics` (`ScrollPhysics?`) and `scrollController` (`ScrollController?`) parameters for custom scroll behavior and programmatic control.
* Add `scaleChildItemsBasedOnDepth` parameter (default `true`): controls whether font and icon sizes are automatically reduced per nesting level.
* Add `menuItemPadding` (`EdgeInsets?`) and `subMenuItemPadding` (`EdgeInsets?`) to override default spacing around top-level and nested items respectively.
* Implement recursive `buildMenuItemNode` renderer with `AnimatedSize` expand/collapse transitions and `AnimatedRotation` chevron indicators for dropdown groups.
* Implement path-based active item and tap-feedback tracking (`List<int>`) supporting arbitrary nesting depth.
* Size resolution priority (highest to lowest): per-item `FluidMenuItem.textStyle`/`iconSize` > widget-level `subMenuItemTextStyle`/`subMenuItemIconSize` > automatic depth scaling.

## 1.0.0

* Initial release of `fluid_side_menu`.
* Implement organic fluid gooey liquid-reveal background transitions driven by distance-staggered custom vector splines.
* Support customizable staggered option entrance animations (`fade`, `scale`, `slide`).
* Support customizable tap selection feedback animations (`scalePulse`, `slideRight`, `scaleDownOthers`, `fadeOthers`, `none`, `iconSlideSwap`).
* Add item-level and global color settings (`textColor`, `iconColor`, `menuItemTextColor`, `menuItemIconColor`).
* Add optional `menuHeader` and `menuFooter` widget slots.
* Optimize rendering performance using isolated `RepaintBoundary` layers.
* Expose `FluidSideMenu.of(context)` static accessor and `open()`, `close()`, `toggle()` programmatic controls on `FluidSideMenuState`.