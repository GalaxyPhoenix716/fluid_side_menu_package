/// The main entry point for the `fluid_side_menu` package.
///
/// Import this file to access all public types:
/// ```dart
/// import 'package:fluid_side_menu/fluid_side_menu.dart';
/// ```
library;

export 'src/fluid_side_menu_widget.dart' show FluidSideMenu, FluidSideMenuState;
export 'src/fluid_menu_item.dart' show FluidMenuItem;

/// The type of entry animation applied to each menu option as the drawer opens.
///
/// Used as the value of [FluidSideMenu.menuAnimationType].
enum FluidMenuAnimationType {
  /// A simple fade-in animation.
  ///
  /// Each item fades from fully transparent to fully opaque during its
  /// staggered entry interval.
  fade,

  /// A staggered scale and fade-in animation.
  ///
  /// Each item scales from `0.65` to `1.0` while fading in, giving a
  /// subtle zoom-in entry effect.
  scale,

  /// A staggered springy slide-up and fade-in animation (default).
  ///
  /// Each item slides up from an offset position with a spring-like
  /// `easeOutBack` curve while fading in.
  slide,
}

/// The type of selection feedback animation applied when a menu option is tapped.
///
/// Used as the value of [FluidSideMenu.selectAnimationType].
enum FluidMenuSelectAnimationType {
  /// The selected item scales up slightly; all other items fade to a lower opacity.
  ///
  /// The selected item scales to `1.08` while unselected items dim to
  /// `0.35` opacity.
  scalePulse,

  /// The selected item slides slightly to the right; all other items fade.
  ///
  /// The selected item shifts right by `0.08` of its width while unselected
  /// items dim to `0.35` opacity.
  slideRight,

  /// The selected item remains stable; all other items scale down and fade.
  ///
  /// Unselected items scale to `0.9` and dim to `0.45` opacity.
  scaleDownOthers,

  /// The selected item remains stable; all other items just fade.
  ///
  /// Unselected items dim to `0.45` opacity with no scaling.
  fadeOthers,

  /// No animation feedback on selection.
  ///
  /// Navigation executes immediately without any visual transition applied to
  /// the item list.
  none,

  /// The selected item's label fades and collapses; the icon slides to center.
  ///
  /// The label animates to zero opacity and zero width, and the icon slides
  /// horizontally into the vacated space. All other items dim to `0.35` opacity.
  iconSlideSwap,
}

/// Controls the horizontal alignment of all menu items within the drawer.
///
/// Used as the value of [FluidSideMenu.itemAlignment].
enum FluidMenuItemAlignment {
  /// Align all items to the left edge of the drawer.
  ///
  /// Nested child items are additionally indented proportional to their depth.
  left,

  /// Align all items in the horizontal center of the drawer (default).
  center,

  /// Align all items to the right edge of the drawer.
  ///
  /// Nested child items are additionally indented from the right proportional
  /// to their depth.
  right,
}
