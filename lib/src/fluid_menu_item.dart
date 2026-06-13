import 'package:flutter/material.dart';
import '../fluid_side_menu.dart';

/// Represents a single navigation option in a [FluidSideMenu].
///
/// Each item can display a [label], an optional prefix [icon], and an optional
/// [page] widget that is shown in the main content area when the item is selected.
///
/// Items can be grouped into collapsible dropdown menus of arbitrary depth by
/// providing a [subItems] list. An item with [subItems] does not need a [page];
/// tapping it toggles the expansion of its children instead of navigating.
///
/// ## Example — leaf item
/// ```dart
/// FluidMenuItem(
///   label: 'Home',
///   page: const HomeScreen(),
///   icon: const Icon(Icons.home),
/// )
/// ```
///
/// ## Example — dropdown parent with nested children
/// ```dart
/// FluidMenuItem(
///   label: 'Categories',
///   icon: const Icon(Icons.category),
///   subItems: [
///     FluidMenuItem(
///       label: 'Baskets',
///       page: const BasketsScreen(),
///       icon: const Icon(Icons.shopping_basket),
///     ),
///   ],
/// )
/// ```
class FluidMenuItem {
  /// The text label displayed next to the optional [icon] in the menu.
  final String label;

  /// The widget/page to display on the main screen when this item is selected.
  ///
  /// Required for leaf items (those without [subItems]). Can be omitted for
  /// parent items that act only as dropdown group headers.
  final Widget? page;

  /// An optional prefix icon or widget displayed to the left of [label].
  final Widget? icon;

  /// An optional custom text color for this specific item's [label].
  ///
  /// Takes precedence over [FluidSideMenu.menuItemTextColor].
  final Color? textColor;

  /// An optional custom icon color for this specific item's [icon].
  ///
  /// Takes precedence over [FluidSideMenu.menuItemIconColor].
  final Color? iconColor;

  /// An optional list of nested child [FluidMenuItem]s.
  ///
  /// When provided, tapping this item toggles a collapsible animated dropdown
  /// that reveals the children. Children may themselves have [subItems],
  /// enabling arbitrary nesting depth.
  final List<FluidMenuItem>? subItems;

  /// An optional custom callback executed when this item is tapped.
  ///
  /// This fires before any built-in expand/collapse or page navigation logic.
  /// Useful for side effects (e.g. analytics) that should run on every tap
  /// regardless of whether the item is a parent or leaf.
  final VoidCallback? onTap;

  /// An optional per-item text style override for this item's [label].
  ///
  /// **Priority (highest to lowest):**
  /// 1. This field (`FluidMenuItem.textStyle`)
  /// 2. [FluidSideMenu.subMenuItemTextStyle] (for child items)
  /// 3. [FluidSideMenu.menuItemTextStyle]
  /// 4. Automatic depth scaling (when [FluidSideMenu.scaleChildItemsBasedOnDepth] is `true`)
  ///
  /// The [color] component of this style is always superseded by [textColor]
  /// or [FluidSideMenu.menuItemTextColor] to ensure color resolution stays consistent.
  final TextStyle? textStyle;

  /// An optional per-item icon size override for this item's [icon].
  ///
  /// **Priority (highest to lowest):**
  /// 1. This field (`FluidMenuItem.iconSize`)
  /// 2. [FluidSideMenu.subMenuItemIconSize] (for child items)
  /// 3. Automatic depth scaling (when [FluidSideMenu.scaleChildItemsBasedOnDepth] is `true`)
  final double? iconSize;

  /// Creates a [FluidMenuItem] with the given navigation and style properties.
  ///
  /// Only [label] is required. All other parameters are optional.
  const FluidMenuItem({
    required this.label,
    this.page,
    this.icon,
    this.textColor,
    this.iconColor,
    this.subItems,
    this.onTap,
    this.textStyle,
    this.iconSize,
  });
}

/// An internal widget that handles staggered entry transitions for each menu option.
///
/// Each [FluidStaggeredMenuItem] is placed inside [FluidSideMenu]'s animated
/// item list and automatically computes an entry interval based on its [index]
/// within the list. The entry interval is offset from the start of the
/// fluid wave expansion (`0.45` progress), so items appear after the background
/// has covered a meaningful portion of the screen.
///
/// The [animationType] determines whether the item enters via a fade, scale,
/// or slide transition.
class FluidStaggeredMenuItem extends StatelessWidget {
  /// The position of this item in the full ordered item list (including header).
  ///
  /// Used to calculate the staggered entry start and end intervals.
  final int index;

  /// The parent animation driving the overall menu open/close transition.
  final Animation<double> animation;

  /// The widget to wrap with the entry transition.
  final Widget child;

  /// The fractional delay per index added on top of the base start offset.
  ///
  /// Defaults to `0.06`, meaning each successive item starts `6%` of the full
  /// animation duration later than the previous one.
  final double staggerDelay;

  /// The normalized offset from which the item slides in.
  ///
  /// Only relevant when [animationType] is [FluidMenuAnimationType.slide].
  /// Defaults to `Offset(0.0, 0.25)`, producing an upward slide.
  final Offset slideOffset;

  /// The entry animation type applied to this item.
  final FluidMenuAnimationType animationType;

  /// Creates a [FluidStaggeredMenuItem] that wraps [child] with a staggered
  /// entry animation driven by [animation].
  const FluidStaggeredMenuItem({
    super.key,
    required this.index,
    required this.animation,
    required this.child,
    this.staggerDelay = 0.06,
    this.slideOffset = const Offset(0.0, 0.25),
    this.animationType = FluidMenuAnimationType.slide,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate staggered animation interval.
    // Items begin appearing after the background covers about half the screen
    // (progress ~0.45), with each successive item delayed by [staggerDelay].
    final double start = (0.45 + (index * staggerDelay)).clamp(0.0, 0.95);
    final double end = (start + 0.35).clamp(0.0, 1.0);

    final Animation<double> itemAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    // Wrap child with the selected transition type.
    switch (animationType) {
      case FluidMenuAnimationType.fade:
        return FadeTransition(opacity: itemAnimation, child: child);
      case FluidMenuAnimationType.scale:
        return FadeTransition(
          opacity: itemAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.65, end: 1.0).animate(itemAnimation),
            child: child,
          ),
        );
      case FluidMenuAnimationType.slide:
        return FadeTransition(
          opacity: itemAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: slideOffset,
              end: Offset.zero,
            ).animate(itemAnimation),
            child: child,
          ),
        );
    }
  }
}
