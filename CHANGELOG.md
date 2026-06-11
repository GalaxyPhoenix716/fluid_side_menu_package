## 1.0.0

* Initial release of `fluid_side_menu` (formerly `liquid_side_menu`).
* Implement organic fluid gooey liquid-reveal background transitions driven by distance-staggered custom vector splines.
* Support customizable staggered option entrance animations (`fade`, `scale`, `slide`).
* Support customizable tap selection feedback animations, including the smooth `iconSlideSwap` centering transition.
* Add item-level and global color settings (`textColor`, `iconColor`, `menuItemTextColor`, `menuItemIconColor`).
* Expose a customizable `animationCurve` parameter to configure the transition's easing curve (defaulting to `Curves.easeInOutCubic`).
* Standardize `content` parameter to `child` to match standard Flutter widget tree conventions.
* Optimize rendering performance using isolated `RepaintBoundary` layers.
* Refactor example application to use proper modular `StatelessWidget` page classes and provide an interactive Transition Configurator panel with solid/gradient background toggles.
