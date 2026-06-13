import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../fluid_side_menu.dart';
import 'fluid_menu_painter.dart';
import 'fluid_menu_item.dart';

/// A premium, highly-customizable fluid side navigation drawer widget.
///
/// It renders an organic, gooey liquid-reveal background transition across
/// five distance-staggered expansion centers, reveals menu options using
/// staggered entry animations, and provides rich interactive selection feedback.
class FluidSideMenu extends StatefulWidget {
  /// Optional static override for child. If null, the selected page from
  /// `menuItems` will be shown automatically.
  final Widget? child;

  /// Optional custom builder for content.
  final Widget Function(BuildContext context, Animation<double> animation)?
  contentBuilder;

  /// Helper method to access the state of the closest ancestor [FluidSideMenu]
  /// from any descendant widget (e.g. to open or close the menu programmatically).
  static FluidSideMenuState? of(BuildContext context) {
    return context.findAncestorStateOfType<FluidSideMenuState>();
  }

  /// The list of items to show in the menu, each containing a label, page, and optional icon.
  final List<FluidMenuItem> menuItems;

  /// Callback triggered when an item is tapped. The menu will automatically
  /// perform selection feedback, switch the active page, and close itself.
  final ValueChanged<int>? onItemTapped;

  /// Optional header widget shown at the top of the menu.
  final Widget? menuHeader;

  /// Optional footer widget shown at the bottom of the menu.
  final Widget? menuFooter;

  /// Entry animation type for all menu items.
  final FluidMenuAnimationType menuAnimationType;

  /// Background color for the fluid transition.
  final Color fluidColor;

  /// Optional gradient background for the fluid transition.
  final Gradient? fluidGradient;

  /// Duration of the transition animation.
  final Duration duration;

  /// Whether to show the default built-in menu and close toggle buttons.
  final bool showBuiltInButtons;

  /// Custom icon/widget for the menu toggle button.
  final Widget? menuIcon;

  /// Custom icon/widget for the close toggle button.
  final Widget? closeIcon;

  /// The button radius for the initial menu button.
  final double buttonRadius;

  /// The type of selection feedback animation applied when a menu option is tapped.
  final FluidMenuSelectAnimationType selectAnimationType;

  /// Custom text style for the menu options.
  final TextStyle? menuItemTextStyle;

  /// Custom text color for the menu options. Defaults to white.
  final Color? menuItemTextColor;

  /// Custom icon color for the menu options.
  final Color? menuItemIconColor;

  /// Spacing between the icon and the text label.
  final double menuItemSpacing;

  /// Easing curve for the fluid transition.
  final Curve animationCurve;

  /// Whether to enable swipe gestures to open or close the menu.
  final bool enableSwipeGestures;

  /// The width of the drag zone at the left edge of the screen when the menu is closed.
  final double edgeDragWidth;

  /// Creates a [FluidSideMenu] navigation drawer with transition properties.
  const FluidSideMenu({
    super.key,
    required this.menuItems,
    this.child,
    this.contentBuilder,
    this.onItemTapped,
    this.menuHeader,
    this.menuFooter,
    this.menuAnimationType = FluidMenuAnimationType.slide,
    this.fluidColor = Colors.black,
    this.fluidGradient,
    this.duration = const Duration(milliseconds: 650),
    this.showBuiltInButtons = true,
    this.menuIcon,
    this.closeIcon,
    this.buttonRadius = 20.0,
    this.selectAnimationType = FluidMenuSelectAnimationType.scalePulse,
    this.menuItemTextStyle,
    this.menuItemTextColor,
    this.menuItemIconColor,
    this.menuItemSpacing = 12.0,
    this.animationCurve = Curves.easeInOutCubic,
    this.enableSwipeGestures = true,
    this.edgeDragWidth = 30.0,
  });

  @override
  State<FluidSideMenu> createState() => FluidSideMenuState();
}

/// State for the [FluidSideMenu] widget that drives the transition animations.
class FluidSideMenuState extends State<FluidSideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isMenuInteractable = false;

  // Track tapped index to play selection feedback
  int? _tappedIndex;

  // Track currently active page index
  int _activePageIndex = 0;

  bool _isDragging = false;

  /// Returns whether the side navigation drawer is currently open.
  bool get isMenuOpen => _controller.value > 0.5;

  /// Returns the current transition progress animation.
  Animation<double> get animation => _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation =
        _controller; // Linear progress to avoid double-curving in the painter

    _controller.addListener(() {
      final interactable = _controller.value > 0.55;
      if (interactable != _isMenuInteractable) {
        setState(() {
          _isMenuInteractable = interactable;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // Reset selection feedback when menu is completely closed
        setState(() {
          _tappedIndex = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant FluidSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Open the fluid menu programmatically
  void open() {
    _controller.forward();
  }

  /// Close the fluid menu programmatically
  void close() {
    _controller.reverse();
  }

  /// Toggle the fluid menu programmatically
  void toggle() {
    if (_controller.value > 0.5) {
      close();
    } else {
      open();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enableSwipeGestures) return;
    final bool isClosed = _controller.value == 0.0;
    if (isClosed) {
      if (details.globalPosition.dx < widget.edgeDragWidth) {
        setState(() {
          _isDragging = true;
        });
      }
    } else {
      setState(() {
        _isDragging = true;
      });
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final double width = MediaQuery.of(context).size.width;
    if (width <= 0) return;
    final double delta = details.primaryDelta ?? 0.0;
    _controller.value = (_controller.value + delta / width).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    setState(() {
      _isDragging = false;
    });

    final double width = MediaQuery.of(context).size.width;
    if (width <= 0) return;

    final double velocity = details.primaryVelocity ?? 0.0;
    if (velocity.abs() > 365.0) {
      if (velocity > 0) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      return;
    }

    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleItemTap(int index) {
    if (_tappedIndex != null) return; // Prevent double taps during animation

    setState(() {
      _tappedIndex = index;
    });

    final bool isSwapAnim =
        widget.selectAnimationType ==
        FluidMenuSelectAnimationType.iconSlideSwap;
    final int delayMs = isSwapAnim ? 320 : 180;

    // Play feedback animation, then close menu and trigger developer callback
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _activePageIndex = index;
        });
        close();
        widget.onItemTapped?.call(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.enableSwipeGestures ? _handleDragStart : null,
      onHorizontalDragUpdate: widget.enableSwipeGestures ? _handleDragUpdate : null,
      onHorizontalDragEnd: widget.enableSwipeGestures ? _handleDragEnd : null,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
        // 1. Content layer (wrapped in RepaintBoundary for 60/120fps performance)
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              if (widget.contentBuilder != null) {
                return widget.contentBuilder!(context, _animation);
              }

              // Selected page widget
              final Widget activePage =
                  widget.child ?? widget.menuItems[_activePageIndex].page;

              // Built-in exit/entry animation for content:
              // Fade out (1.0 -> 0.0) and slide left (0.0 -> -0.1) over [0.0, 0.4] interval.
              final Animation<double> textFade =
                  Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _animation,
                      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
                    ),
                  );

              final Animation<Offset> textSlide =
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(-0.1, 0.0),
                  ).animate(
                    CurvedAnimation(
                      parent: _animation,
                      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
                    ),
                  );

              return FadeTransition(
                opacity: textFade,
                child: SlideTransition(position: textSlide, child: activePage),
              );
            },
          ),
        ),

        // 2. Custom Painter Layer (fluid transition)
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: FluidMenuPainter(
                      progress: _animation.value,
                      fluidColor: widget.fluidColor,
                      fluidGradient: widget.fluidGradient,
                      buttonRadius: widget.buttonRadius,
                      animationCurve: widget.animationCurve,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 3. Menu overlay layer
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_isMenuInteractable,
            child: RepaintBoundary(child: _buildMenuContent()),
          ),
        ),

        // 4. Built-in toggle buttons
        if (widget.showBuiltInButtons) ...[
          // Menu button (visible only when transition has not started)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (_controller.value > 0.0) return const SizedBox.shrink();
              return Positioned(
                top: 40.0,
                left: 20.0,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 2.0,
                  shape: const CircleBorder(),
                  onPressed: open,
                  child: widget.menuIcon ?? const Icon(Icons.menu),
                ),
              );
            },
          ),

          // Close button (rotates and fades in during expansion, synced with fluid front)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double val = _animation.value;
              if (val <= 0.4) return const SizedBox.shrink();

              // Map 0.4 -> 0.8 progress to 0.0 -> 1.0 visual opacity & rotation
              final double closeProgress = ((val - 0.4) / 0.45).clamp(0.0, 1.0);
              final double opacity = closeProgress;
              final double curveVal = Curves.easeOutBack.transform(
                closeProgress,
              );
              final double rotation = (1.0 - curveVal) * math.pi / 2;

              return Positioned(
                top: 40.0,
                right: 20.0,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: rotation,
                    child: IconButton(
                      icon:
                          widget.closeIcon ??
                          const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                      onPressed: close,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    ),
  );
}

  Widget _buildMenuContent() {
    final hasHeader = widget.menuHeader != null;
    final hasFooter = widget.menuFooter != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Optional Header (Index 0)
          if (hasHeader) ...[
            FluidStaggeredMenuItem(
              index: 0,
              animation: _animation,
              animationType: widget.menuAnimationType,
              child: widget.menuHeader!,
            ),
            const SizedBox(height: 32.0),
          ],

          // Staggered Menu Items
          ...List.generate(widget.menuItems.length, (idx) {
            final item = widget.menuItems[idx];
            final itemIndex = idx + (hasHeader ? 1 : 0);
            final isSelected = _tappedIndex == idx;
            final isAnySelected = _tappedIndex != null;

            // Resolve custom colors for this item
            final Color resolvedIconColor =
                item.iconColor ?? widget.menuItemIconColor ?? Colors.white;
            final Color resolvedTextColor =
                item.textColor ?? widget.menuItemTextColor ?? Colors.white;
            final TextStyle resolvedTextStyle =
                (widget.menuItemTextStyle ??
                        const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ))
                    .copyWith(color: resolvedTextColor);

            // Subtle feedback physics based on selected animation type
            double itemScale = 1.0;
            double itemOpacity = 1.0;
            Offset itemSlideOffset = Offset.zero;

            // Local animations for icon swap
            double labelOpacity = 1.0;
            Offset labelSlideOffset = Offset.zero;
            Offset iconSlideOffset = Offset.zero;

            if (isAnySelected) {
              switch (widget.selectAnimationType) {
                case FluidMenuSelectAnimationType.scalePulse:
                  itemScale = isSelected ? 1.08 : 1.0;
                  itemOpacity = isSelected ? 1.0 : 0.35;
                  break;
                case FluidMenuSelectAnimationType.slideRight:
                  itemSlideOffset = isSelected
                      ? const Offset(0.08, 0.0)
                      : Offset.zero;
                  itemOpacity = isSelected ? 1.0 : 0.35;
                  break;
                case FluidMenuSelectAnimationType.scaleDownOthers:
                  itemScale = isSelected ? 1.0 : 0.9;
                  itemOpacity = isSelected ? 1.0 : 0.35;
                  break;
                case FluidMenuSelectAnimationType.fadeOthers:
                  itemOpacity = isSelected ? 1.0 : 0.35;
                  break;
                case FluidMenuSelectAnimationType.iconSlideSwap:
                  itemOpacity = isSelected ? 1.0 : 0.25;
                  if (isSelected) {
                    labelOpacity = 0.0;
                    labelSlideOffset = const Offset(
                      0.2,
                      0.0,
                    ); // Slight right slide for text exit
                    // iconSlideOffset stays Offset.zero to let layout shrinking center the icon
                  }
                  break;
                case FluidMenuSelectAnimationType.none:
                  break;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: FluidStaggeredMenuItem(
                index: itemIndex,
                animation: _animation,
                animationType: widget.menuAnimationType,
                child: GestureDetector(
                  onTap: () => _handleItemTap(idx),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedSlide(
                    offset: itemSlideOffset,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    child: AnimatedScale(
                      scale: itemScale,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: itemOpacity,
                        duration: const Duration(milliseconds: 160),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.menuItems[idx].icon != null) ...[
                              AnimatedSlide(
                                offset: iconSlideOffset,
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeInOutCubic,
                                child: IconTheme(
                                  data: IconThemeData(
                                    color: resolvedIconColor,
                                    size: 24,
                                  ),
                                  child: item.icon!,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeInOutCubic,
                                width:
                                    isSelected &&
                                        widget.selectAnimationType ==
                                            FluidMenuSelectAnimationType
                                                .iconSlideSwap
                                    ? 0.0
                                    : widget.menuItemSpacing,
                              ),
                            ],
                            AnimatedSize(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeInOutCubic,
                              child: AnimatedOpacity(
                                opacity: labelOpacity,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOutCubic,
                                child: SizedBox(
                                  width:
                                      isSelected &&
                                          widget.selectAnimationType ==
                                              FluidMenuSelectAnimationType
                                                  .iconSlideSwap
                                      ? 0.0
                                      : null,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: AnimatedSlide(
                                      offset: labelSlideOffset,
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeInOutCubic,
                                      child: Text(
                                        item.label,
                                        maxLines: 1,
                                        style: resolvedTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Optional Footer
          if (hasFooter) ...[
            const SizedBox(height: 32.0),
            FluidStaggeredMenuItem(
              index: widget.menuItems.length + (hasHeader ? 2 : 1),
              animation: _animation,
              animationType: widget.menuAnimationType,
              child: widget.menuFooter!,
            ),
          ],
        ],
      ),
    );
  }
}
