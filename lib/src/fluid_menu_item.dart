import 'package:flutter/material.dart';
import '../fluid_side_menu.dart';

/// Represents a menu option containing navigation data.
class FluidMenuItem {
  /// The text label shown in the menu option.
  final String label;

  /// The widget/page to display on the main screen when this item is selected.
  final Widget page;

  /// Optional prefix icon or widget to show next to the label.
  final Widget? icon;

  /// Optional custom text color for this specific menu item.
  final Color? textColor;

  /// Optional custom icon color for this specific menu item.
  final Color? iconColor;

  /// Creates a [FluidMenuItem] containing navigation and style properties.
  const FluidMenuItem({
    required this.label,
    required this.page,
    this.icon,
    this.textColor,
    this.iconColor,
  });
}

/// Internal widget that handles the staggered entry transitions for menu options.
class FluidStaggeredMenuItem extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Widget child;
  final double staggerDelay; // Delay multiplier per index
  final Offset slideOffset; // Initial translation offset for slide animation
  final FluidMenuAnimationType animationType; // Chosen entry animation type

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
    // Calculate staggered animation interval
    // Start revealing items after the background covers about half the screen (e.g. 0.45 progress)
    final double start = (0.45 + (index * staggerDelay)).clamp(0.0, 0.95);
    final double end = (start + 0.35).clamp(0.0, 1.0);

    final Animation<double> itemAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    // Wrap child with the selected transition type
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
