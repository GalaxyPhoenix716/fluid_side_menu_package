export 'src/fluid_side_menu_widget.dart' show FluidSideMenu, FluidSideMenuState;
export 'src/fluid_menu_item.dart' show FluidMenuItem;

/// The type of entry animation applied to each menu option.
enum FluidMenuAnimationType {
  /// Simple fade-in animation
  fade,

  /// Staggered scale and fade-in animation
  scale,

  /// Staggered springy slide-up and fade-in animation
  slide,
}

/// The type of selection feedback animation applied when a menu option is tapped.
enum FluidMenuSelectAnimationType {
  /// Selected item scales up slightly; other items fade down.
  scalePulse,

  /// Selected item slides slightly to the right; other items fade down.
  slideRight,

  /// Selected item remains stable; other items scale down and fade.
  scaleDownOthers,

  /// Selected item remains stable; other items just fade down.
  fadeOthers,

  /// No animation feedback on selection.
  none,

  /// Icon slides to the position of the label, and label slides out.
  iconSlideSwap,
}

/// The alignment of the menu items within the menu container.
enum FluidMenuItemAlignment {
  /// Align items to the left.
  left,

  /// Align items in the center.
  center,

  /// Align items to the right.
  right,
}
