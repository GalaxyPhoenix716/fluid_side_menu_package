import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// The custom center offset point from which the fluid wave reveal transition originates.
  final Offset? revealOrigin;

  /// Whether to enable haptic feedback at critical transitions and interactions.
  final bool enableHapticFeedback;

  /// The alignment of the menu items (left, center, or right) within the drawer.
  final FluidMenuItemAlignment itemAlignment;

  /// Callback triggered when a nested sub-item is tapped.
  final void Function(int parentIndex, int subIndex)? onSubItemTapped;

  /// Custom text style for the nested sub-menu options.
  final TextStyle? subMenuItemTextStyle;

  /// Custom icon size for the nested sub-menu options.
  final double? subMenuItemIconSize;

  /// Whether the menu items column is scrollable when content overflows the screen height.
  /// Defaults to [true] so long item lists are always reachable.
  final bool enableScroll;

  /// Scroll physics for the menu item list.
  /// If null the default platform [ClampingScrollPhysics] is used.
  final ScrollPhysics? scrollPhysics;

  /// An optional [ScrollController] for the menu item list.
  final ScrollController? scrollController;

  /// Whether nested child items should be scaled down automatically based on
  /// their depth level. When [false] every depth level uses the same text and
  /// icon size, which is useful when per-item sizes are set directly on
  /// [FluidMenuItem.textStyle] / [FluidMenuItem.iconSize].
  /// Defaults to [true].
  final bool scaleChildItemsBasedOnDepth;

  /// Vertical padding around each top-level menu item.
  /// Defaults to `EdgeInsets.symmetric(vertical: 12.0)`.
  final EdgeInsets? menuItemPadding;

  /// Vertical padding above each nested (child) menu item.
  /// Defaults to `EdgeInsets.only(top: 12.0)`.
  final EdgeInsets? subMenuItemPadding;

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
    this.revealOrigin,
    this.enableHapticFeedback = true,
    this.itemAlignment = FluidMenuItemAlignment.center,
    this.onSubItemTapped,
    this.subMenuItemTextStyle,
    this.subMenuItemIconSize,
    this.enableScroll = true,
    this.scrollPhysics,
    this.scrollController,
    this.scaleChildItemsBasedOnDepth = true,
    this.menuItemPadding,
    this.subMenuItemPadding,
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

  // Track tapped path to play selection feedback
  List<int>? _tappedItemPath;

  // Track currently active page path
  List<int> _activeItemPath = [0];

  // Track expanded dropdown parent paths
  final Set<String> _expandedPaths = {};

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
          _tappedItemPath = null;
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
  void open({bool triggerHaptic = true}) {
    if (_controller.value == 1.0 ||
        _controller.status == AnimationStatus.forward) {
      return;
    }
    _controller.forward();
    if (triggerHaptic && widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  /// Close the fluid menu programmatically
  void close({bool triggerHaptic = true}) {
    if (_controller.value == 0.0 ||
        _controller.status == AnimationStatus.reverse) {
      return;
    }
    _controller.reverse();
    if (triggerHaptic && widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
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
    if (_controller.isAnimating) return;

    final bool isClosed = _controller.value == 0.0;
    if (isClosed) {
      if (details.globalPosition.dx < widget.edgeDragWidth) {
        setState(() {
          _isDragging = true;
        });
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      }
    } else {
      if (_controller.value == 1.0) {
        setState(() {
          _isDragging = true;
        });
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      }
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
        open(triggerHaptic: false);
      } else {
        close(triggerHaptic: false);
      }
      return;
    }

    if (_controller.value > 0.5) {
      open(triggerHaptic: false);
    } else {
      close(triggerHaptic: false);
    }
  }

  void _handlePathTap(List<int> path) {
    if (_tappedItemPath != null) return; // Prevent double taps during animation

    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _tappedItemPath = path;
    });

    final bool isSwapAnim =
        widget.selectAnimationType ==
        FluidMenuSelectAnimationType.iconSlideSwap;
    final int delayMs = isSwapAnim ? 320 : 180;

    // Play feedback animation, then close menu and trigger developer callback
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _activeItemPath = List.from(path);
        });
        close(triggerHaptic: false);
        if (path.length > 1) {
          widget.onSubItemTapped?.call(path[0], path[1]);
        }
        widget.onItemTapped?.call(path[0]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.enableSwipeGestures
          ? _handleDragStart
          : null,
      onHorizontalDragUpdate: widget.enableSwipeGestures
          ? _handleDragUpdate
          : null,
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
                final Widget activePage;
                if (widget.child != null) {
                  activePage = widget.child!;
                } else {
                  FluidMenuItem resolvedItem =
                      widget.menuItems[_activeItemPath[0]];
                  for (int i = 1; i < _activeItemPath.length; i++) {
                    if (resolvedItem.subItems != null &&
                        _activeItemPath[i] < resolvedItem.subItems!.length) {
                      resolvedItem = resolvedItem.subItems![_activeItemPath[i]];
                    }
                  }
                  activePage = resolvedItem.page ?? const SizedBox.shrink();
                }

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
                  child: SlideTransition(
                    position: textSlide,
                    child: activePage,
                  ),
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
                        revealCenter:
                            widget.revealOrigin ?? const Offset(44.0, 64.0),
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
                final double closeProgress = ((val - 0.4) / 0.45).clamp(
                  0.0,
                  1.0,
                );
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

    // Determine Align properties based on widget.itemAlignment
    Alignment align;
    CrossAxisAlignment crossAxisAlignment;
    EdgeInsets padding;

    switch (widget.itemAlignment) {
      case FluidMenuItemAlignment.left:
        align = Alignment.centerLeft;
        crossAxisAlignment = CrossAxisAlignment.start;
        padding = const EdgeInsets.only(left: 64.0, right: 32.0);
        break;
      case FluidMenuItemAlignment.right:
        align = Alignment.centerRight;
        crossAxisAlignment = CrossAxisAlignment.end;
        padding = const EdgeInsets.only(left: 32.0, right: 64.0);
        break;
      case FluidMenuItemAlignment.center:
        align = Alignment.center;
        crossAxisAlignment = CrossAxisAlignment.center;
        padding = const EdgeInsets.symmetric(horizontal: 32.0);
        break;
    }

    Widget buildItemRow(
      FluidMenuItem item, {
      required List<int> path,
      required int itemIndex,
      required bool isSelected,
      required bool isAnySelected,
      required bool isParentOfSelected,
      required VoidCallback onTap,
      bool isSubItem = false,
      bool isExpanded = false,
    }) {
      final int depth = path.length - 1;

      // ----------------------------------------------------------------
      // Font size resolution (priority: per-item > widget-level > depth scaling)
      // ----------------------------------------------------------------
      double fontSize;
      if (item.textStyle?.fontSize != null) {
        // Per-item override always wins
        fontSize = item.textStyle!.fontSize!;
      } else if (isSubItem && widget.subMenuItemTextStyle?.fontSize != null) {
        final double base = widget.subMenuItemTextStyle!.fontSize!;
        fontSize = widget.scaleChildItemsBasedOnDepth
            ? base * math.pow(0.8, depth - 1)
            : base;
      } else {
        final double base = widget.menuItemTextStyle?.fontSize ?? 32;
        fontSize = widget.scaleChildItemsBasedOnDepth
            ? base * math.pow(0.72, depth)
            : base;
      }

      // ----------------------------------------------------------------
      // Icon size resolution (priority: per-item > widget-level > depth scaling)
      // ----------------------------------------------------------------
      double iconSize;
      if (item.iconSize != null) {
        // Per-item override always wins
        iconSize = item.iconSize!;
      } else if (isSubItem && widget.subMenuItemIconSize != null) {
        iconSize = widget.scaleChildItemsBasedOnDepth
            ? (widget.subMenuItemIconSize! - ((depth - 1) * 3.0)).clamp(
                10.0,
                40.0,
              )
            : widget.subMenuItemIconSize!;
      } else {
        iconSize = widget.scaleChildItemsBasedOnDepth
            ? (24.0 - (depth * 4.0)).clamp(14.0, 24.0)
            : 24.0;
      }

      final double itemSpacing = widget.menuItemSpacing * math.pow(0.75, depth);

      final Color resolvedIconColor =
          item.iconColor ?? widget.menuItemIconColor ?? Colors.white;
      final Color resolvedTextColor =
          item.textColor ?? widget.menuItemTextColor ?? Colors.white;

      // ----------------------------------------------------------------
      // Base text style resolution (priority: per-item > sub-level > top-level)
      // ----------------------------------------------------------------
      final TextStyle baseStyle =
          item.textStyle ??
          ((isSubItem && widget.subMenuItemTextStyle != null)
              ? widget.subMenuItemTextStyle!
              : (widget.menuItemTextStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    )));

      final TextStyle resolvedTextStyle = baseStyle.copyWith(
        color: resolvedTextColor,
        fontSize: fontSize,
      );

      double itemScale = 1.0;
      double itemOpacity = 1.0;
      Offset itemSlideOffset = Offset.zero;

      double labelOpacity = 1.0;
      Offset labelSlideOffset = Offset.zero;
      Offset iconSlideOffset = Offset.zero;

      if (isAnySelected) {
        if (isSelected) {
          itemOpacity = 1.0;
          itemScale =
              widget.selectAnimationType ==
                  FluidMenuSelectAnimationType.scalePulse
              ? 1.08
              : 1.0;
          itemSlideOffset =
              widget.selectAnimationType ==
                  FluidMenuSelectAnimationType.slideRight
              ? const Offset(0.08, 0.0)
              : Offset.zero;
          if (widget.selectAnimationType ==
              FluidMenuSelectAnimationType.iconSlideSwap) {
            labelOpacity = 0.0;
            labelSlideOffset = const Offset(0.2, 0.0);
          }
        } else if (isParentOfSelected) {
          itemOpacity = 0.6;
          itemScale = 1.0;
        } else {
          itemOpacity = isSubItem ? 0.35 : 0.45;
          itemScale =
              widget.selectAnimationType ==
                  FluidMenuSelectAnimationType.scaleDownOthers
              ? 0.9
              : 1.0;
        }
      }

      final double indentLeft =
          (widget.itemAlignment == FluidMenuItemAlignment.left)
          ? depth * 24.0
          : 0.0;
      final double indentRight =
          (widget.itemAlignment == FluidMenuItemAlignment.right)
          ? depth * 24.0
          : 0.0;

      return Padding(
        padding: EdgeInsets.only(left: indentLeft, right: indentRight),
        child: GestureDetector(
          onTap: onTap,
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
                    if (item.icon != null) ...[
                      AnimatedSlide(
                        offset: iconSlideOffset,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOutCubic,
                        child: IconTheme(
                          data: IconThemeData(
                            color: resolvedIconColor,
                            size: iconSize,
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
                                    FluidMenuSelectAnimationType.iconSlideSwap
                            ? 0.0
                            : itemSpacing,
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
                                      FluidMenuSelectAnimationType.iconSlideSwap
                              ? 0.0
                              : null,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: AnimatedSlide(
                              offset: labelSlideOffset,
                              duration: const Duration(milliseconds: 260),
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
                    if (item.subItems != null && item.subItems!.isNotEmpty) ...[
                      const SizedBox(width: 8.0),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Opacity(
                          opacity: 0.7,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: iconSize - 2,
                            color: resolvedIconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildMenuItemNode(
      FluidMenuItem item, {
      required List<int> path,
      required int itemIndex,
    }) {
      final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
      final pathKey = path.join(',');
      final isExpanded = _expandedPaths.contains(pathKey);
      final isAnySelected = _tappedItemPath != null;

      bool isSelected = false;
      bool isParentOfSelected = false;
      if (isAnySelected) {
        if (_tappedItemPath!.length == path.length) {
          isSelected = true;
          for (int i = 0; i < path.length; i++) {
            if (_tappedItemPath![i] != path[i]) {
              isSelected = false;
              break;
            }
          }
        } else if (_tappedItemPath!.length > path.length) {
          isParentOfSelected = true;
          for (int i = 0; i < path.length; i++) {
            if (_tappedItemPath![i] != path[i]) {
              isParentOfSelected = false;
              break;
            }
          }
        }
      }

      final Widget rowWidget = buildItemRow(
        item,
        path: path,
        itemIndex: itemIndex,
        isSelected: isSelected,
        isAnySelected: isAnySelected,
        isParentOfSelected: isParentOfSelected,
        isSubItem: path.length > 1,
        isExpanded: isExpanded,
        onTap: () {
          if (item.onTap != null) {
            item.onTap!();
          }
          if (hasSubItems) {
            setState(() {
              if (_expandedPaths.contains(pathKey)) {
                _expandedPaths.remove(pathKey);
              } else {
                _expandedPaths.add(pathKey);
              }
            });
          } else {
            _handlePathTap(path);
          }
        },
      );

      if (!hasSubItems) {
        return rowWidget;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          rowWidget,
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            child: isExpanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: crossAxisAlignment,
                    children: List.generate(item.subItems!.length, (subIdx) {
                      final subItem = item.subItems![subIdx];
                      return Padding(
                        padding:
                            widget.subMenuItemPadding ??
                            const EdgeInsets.only(top: 12.0),
                        child: buildMenuItemNode(
                          subItem,
                          path: [...path, subIdx],
                          itemIndex: itemIndex,
                        ),
                      );
                    }),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    final Widget itemsColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
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

          return Padding(
            padding:
                widget.menuItemPadding ??
                const EdgeInsets.symmetric(vertical: 12.0),
            child: FluidStaggeredMenuItem(
              index: itemIndex,
              animation: _animation,
              animationType: widget.menuAnimationType,
              child: buildMenuItemNode(item, path: [idx], itemIndex: idx),
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
    );

    return Align(
      alignment: align,
      child: Padding(
        padding: padding,
        child: widget.enableScroll
            ? SingleChildScrollView(
                controller: widget.scrollController,
                physics: widget.scrollPhysics ?? const ClampingScrollPhysics(),
                child: itemsColumn,
              )
            : itemsColumn,
      ),
    );
  }
}
