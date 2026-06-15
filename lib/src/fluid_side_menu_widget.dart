import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fluid_side_menu.dart';
import 'fluid_menu_painter.dart';
import 'fluid_menu_item.dart';

/// A premium, highly-customizable fluid side navigation drawer widget.
///
/// [FluidSideMenu] renders an organic, gooey liquid-reveal background transition
/// across five distance-staggered expansion centers using [FluidMenuPainter],
/// reveals menu options via staggered entry animations, supports arbitrarily
/// nested dropdown navigation, scrolls automatically when item lists overflow,
/// and provides rich interactive selection feedback.
///
/// ## Basic usage
/// ```dart
/// FluidSideMenu(
///   fluidColor: Colors.black,
///   menuItems: [
///     FluidMenuItem(label: 'Home', page: const HomeScreen(), icon: const Icon(Icons.home)),
///     FluidMenuItem(label: 'About', page: const AboutScreen(), icon: const Icon(Icons.info)),
///   ],
/// )
/// ```
///
/// ## Programmatic control
/// Use [FluidSideMenu.of] to locate the nearest [FluidSideMenuState] and call
/// [FluidSideMenuState.open], [FluidSideMenuState.close], or
/// [FluidSideMenuState.toggle] from any descendant widget.
///
/// ## Nested navigation
/// Supply [FluidMenuItem.subItems] to create collapsible dropdown groups.
/// Groups can be nested to arbitrary depth; each level is tracked via an
/// integer path list.
class FluidSideMenu extends StatefulWidget {
  /// An optional static main-screen widget override.
  ///
  /// When provided, this widget is always shown as the main content regardless
  /// of which menu item is currently active. Use this when you manage page
  /// routing yourself (e.g. with a `Navigator`) instead of relying on the
  /// automatic [FluidMenuItem.page] resolution.
  final Widget? child;

  /// An optional fully custom content builder.
  ///
  /// Receives the [BuildContext] and the raw `Animation<double>` progress
  /// value (0.0 = closed, 1.0 = open). When provided, supersedes both [child]
  /// and the built-in [FluidMenuItem.page] routing.
  final Widget Function(BuildContext context, Animation<double> animation)?
  contentBuilder;

  /// Locates the nearest [FluidSideMenuState] ancestor in the widget tree.
  ///
  /// Returns `null` if no ancestor [FluidSideMenu] is found. Use the returned
  /// state to call [FluidSideMenuState.open], [FluidSideMenuState.close], or
  /// [FluidSideMenuState.toggle] programmatically.
  ///
  /// ```dart
  /// FluidSideMenu.of(context)?.open();
  /// ```
  static FluidSideMenuState? of(BuildContext context) {
    return context.findAncestorStateOfType<FluidSideMenuState>();
  }

  /// The ordered list of [FluidMenuItem]s to display inside the drawer.
  ///
  /// Each item can optionally define [FluidMenuItem.subItems] to produce
  /// collapsible dropdown groups. Items without a [FluidMenuItem.page] are
  /// treated as group headers that only expand/collapse their children.
  final List<FluidMenuItem> menuItems;

  /// Called with the top-level item index when any item (or any of its
  /// descendant leaf items) is tapped and navigation is triggered.
  ///
  /// The menu automatically closes and updates the active page before calling
  /// this callback. For nested item callbacks, also see [onSubItemTapped].
  final ValueChanged<int>? onItemTapped;

  /// An optional widget displayed at the very top of the menu, above all items.
  ///
  /// Wrapped in a [FluidStaggeredMenuItem] so it participates in the same
  /// staggered entry animation as the item list.
  final Widget? menuHeader;

  /// An optional widget displayed at the very bottom of the menu, below all items.
  ///
  /// Wrapped in a [FluidStaggeredMenuItem] so it participates in the staggered
  /// entry animation.
  final Widget? menuFooter;

  /// The entry animation style applied to all menu items as the drawer opens.
  ///
  /// Defaults to [FluidMenuAnimationType.slide]. See [FluidMenuAnimationType]
  /// for all available options.
  final FluidMenuAnimationType menuAnimationType;

  /// The solid fill color of the liquid-reveal wave background.
  ///
  /// Defaults to `Colors.black`. Superseded by [fluidGradient] when provided.
  final Color fluidColor;

  /// An optional gradient fill for the liquid-reveal wave background.
  ///
  /// When non-null, supersedes [fluidColor] as the wave fill. Supports any
  /// [Gradient] subtype (e.g. `LinearGradient`, `RadialGradient`).
  final Gradient? fluidGradient;

  /// The total duration of the open and close wave transitions.
  ///
  /// Defaults to `Duration(milliseconds: 650)`. Larger values produce a
  /// slower, more dramatic gooey expansion.
  final Duration duration;

  /// Whether the built-in open and close toggle buttons are rendered.
  ///
  /// When `true` (default), a circular open button appears at the top-left
  /// of the screen when the menu is closed, and a close button fades in at
  /// the top-right as the menu opens. Set `false` to manage toggle buttons
  /// entirely yourself.
  final bool showBuiltInButtons;

  /// A custom widget for the built-in open toggle button.
  ///
  /// When `null`, defaults to `Icon(Icons.menu)`. Only used when
  /// [showBuiltInButtons] is `true`.
  final Widget? menuIcon;

  /// A custom widget for the built-in close toggle button.
  ///
  /// When `null`, defaults to `Icon(Icons.close, color: Colors.white, size: 30)`.
  /// Only used when [showBuiltInButtons] is `true`.
  final Widget? closeIcon;

  /// The corner radius of the circular menu open toggle button in logical pixels.
  ///
  /// Defaults to `20.0`. Also controls the starting radius of the wave reveal
  /// so the transition looks seamless from the button.
  final double buttonRadius;

  /// The tap selection feedback animation style.
  ///
  /// Applied to items immediately after they are tapped. Defaults to
  /// [FluidMenuSelectAnimationType.scalePulse]. See
  /// [FluidMenuSelectAnimationType] for all available options.
  final FluidMenuSelectAnimationType selectAnimationType;

  /// The default text style applied to top-level menu item labels.
  ///
  /// The `color` component of this style is overridden by [menuItemTextColor]
  /// or [FluidMenuItem.textColor] during rendering.
  final TextStyle? menuItemTextStyle;

  /// The default label text color applied to all menu items.
  ///
  /// Superseded by [FluidMenuItem.textColor] on a per-item basis.
  /// Defaults to `Colors.white` when both this and `textColor` are `null`.
  final Color? menuItemTextColor;

  /// The default icon color applied to all menu item icons.
  ///
  /// Superseded by [FluidMenuItem.iconColor] on a per-item basis.
  /// Defaults to `Colors.white` when both this and `iconColor` are `null`.
  final Color? menuItemIconColor;

  /// The horizontal spacing between an item's [FluidMenuItem.icon] and its label.
  ///
  /// Defaults to `12.0` logical pixels. This value is proportionally reduced
  /// at deeper nesting levels.
  final double menuItemSpacing;

  /// The easing curve applied to the fluid wave transition.
  ///
  /// Defaults to `Curves.easeInOutCubic`. Applied once inside [FluidMenuPainter]
  /// per expansion circle, keeping the `AnimationController` itself linear to
  /// avoid double-curving.
  final Curve animationCurve;

  /// Whether horizontal swipe gestures can open or close the drawer.
  ///
  /// When `true` (default), dragging right from within [edgeDragWidth] pixels
  /// of the left edge opens the drawer. Dragging left anywhere on screen when
  /// the drawer is fully open closes it.
  final bool enableSwipeGestures;

  /// The width of the left-edge drag detection zone in logical pixels.
  ///
  /// Only relevant when [enableSwipeGestures] is `true` and the drawer is
  /// closed. Defaults to `30.0`.
  final double edgeDragWidth;

  /// Custom screen-space origin point for the gooey wave reveal.
  ///
  /// When `null`, defaults to `Offset(44.0, 64.0)` — the approximate position
  /// of the built-in open toggle button. Changing this moves the visual
  /// "source" of the liquid expansion to any point on screen.
  final Offset? revealOrigin;

  /// Whether haptic feedback is triggered at critical transitions.
  ///
  /// When `true` (default):
  /// - [HapticFeedback.lightImpact] fires when the drawer starts opening or
  ///   closing (button press or swipe start).
  /// - [HapticFeedback.selectionClick] fires when a menu item is tapped.
  ///
  /// Set `false` to silence all haptics globally.
  final bool enableHapticFeedback;

  /// The horizontal alignment of all menu items within the drawer.
  ///
  /// Defaults to [FluidMenuItemAlignment.center]. When set to `left` or
  /// `right`, nested child items are additionally indented proportional to
  /// their depth, visually conveying hierarchy.
  final FluidMenuItemAlignment itemAlignment;

  /// Called when a nested sub-item is tapped and navigation is triggered.
  ///
  /// Receives the top-level parent index and the immediate child index of the
  /// selected item. For deeper nesting levels only the first two path indices
  /// are exposed here; use [onItemTapped] alongside your own state to track
  /// the full selection path if needed.
  final void Function(int parentIndex, int subIndex)? onSubItemTapped;

  /// The default text style applied to all nested child menu items.
  ///
  /// Applied to items at depth >= 1 (i.e. any item inside a [FluidMenuItem.subItems]
  /// list). Superseded by [FluidMenuItem.textStyle] on a per-item basis.
  /// When [scaleChildItemsBasedOnDepth] is `true`, the font size of this style
  /// is further scaled down per depth level.
  final TextStyle? subMenuItemTextStyle;

  /// The default icon size applied to all nested child menu items, in logical pixels.
  ///
  /// Applied to items at depth >= 1. Superseded by [FluidMenuItem.iconSize] on
  /// a per-item basis. When [scaleChildItemsBasedOnDepth] is `true`, this
  /// value is further reduced per depth level.
  final double? subMenuItemIconSize;

  /// Whether the menu item column is wrapped in a [SingleChildScrollView].
  ///
  /// Defaults to `true`. When `true`, users can scroll the item list to reach
  /// items below the visible area — especially useful when multiple nested
  /// groups are expanded simultaneously on small screens.
  ///
  /// Set `false` for a fixed-height, non-scrollable menu.
  final bool enableScroll;

  /// The scroll physics used by the menu's [SingleChildScrollView].
  ///
  /// Only relevant when [enableScroll] is `true`. Defaults to
  /// [ClampingScrollPhysics]. Supply [BouncingScrollPhysics] for an iOS-style
  /// feel or [NeverScrollableScrollPhysics] to suppress scrolling programmatically.
  final ScrollPhysics? scrollPhysics;

  /// An optional [ScrollController] for the menu's [SingleChildScrollView].
  ///
  /// Only relevant when [enableScroll] is `true`. Allows programmatic control
  /// of the scroll position (e.g. to scroll to a specific item on open).
  final ScrollController? scrollController;

  /// Whether nested child items are automatically scaled down per nesting level.
  ///
  /// When `true` (default), font size and icon size of each item are reduced
  /// by a fixed factor for every additional depth level. This ensures deeply
  /// nested items don't overwhelm the layout.
  ///
  /// Set `false` when you are using [FluidMenuItem.textStyle] and
  /// [FluidMenuItem.iconSize] to manage sizes explicitly, and automatic
  /// reduction would conflict with your intent.
  final bool scaleChildItemsBasedOnDepth;

  /// Vertical padding surrounding each top-level menu item row.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: 12.0)`. Reducing this value
  /// lets more items fit on screen before scrolling is required.
  final EdgeInsets? menuItemPadding;

  /// Vertical padding above each nested child item row.
  ///
  /// Defaults to `EdgeInsets.only(top: 12.0)`. Controls the visual spacing
  /// between sibling child items inside an expanded dropdown group.
  final EdgeInsets? subMenuItemPadding;

  /// The color of the item label text and icon when hovered.
  ///
  /// Defaults to `null`, which leaves the color unchanged when hovered.
  final Color? hoverColor;

  /// The background color of a rounded pill shape behind the menu item when hovered.
  ///
  /// Defaults to `null`, meaning no background highlight pill is drawn.
  final Color? hoverBackgroundColor;

  /// The scale factor applied to the item when hovered.
  ///
  /// Defaults to `1.04`. Set to `1.0` to disable scale-on-hover.
  final double hoverScale;

  /// The translation offset applied to the item when hovered.
  ///
  /// Defaults to `Offset(0.04, 0.0)` (slides slightly to the right).
  /// Set to `Offset.zero` to disable slide-on-hover.
  final Offset hoverOffset;

  /// Creates a [FluidSideMenu] navigation drawer.
  ///
  /// Only [menuItems] is required. All other parameters have sensible defaults
  /// that produce a polished out-of-the-box experience.
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
    this.hoverColor,
    this.hoverBackgroundColor,
    this.hoverScale = 1.04,
    this.hoverOffset = const Offset(0.04, 0.0),
  });

  @override
  State<FluidSideMenu> createState() => FluidSideMenuState();
}

/// Mutable state for a [FluidSideMenu] widget.
///
/// Owns the [AnimationController] that drives the open/close wave transition
/// and manages all ephemeral UI state: drag tracking, item path selection,
/// expanded dropdown paths, and menu interactability.
///
/// Access this state from anywhere in the subtree via [FluidSideMenu.of]:
/// ```dart
/// FluidSideMenu.of(context)?.open();
/// ```
class FluidSideMenuState extends State<FluidSideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// The raw linear animation output of [_controller].
  ///
  /// Kept linear to avoid double-curving; the easing curve is applied
  /// independently inside [FluidMenuPainter].
  late Animation<double> _animation;

  /// Whether the menu overlay is currently accepting pointer events.
  ///
  /// Becomes `true` once the controller value exceeds `0.55` during opening
  /// (the fluid background is visually far enough along to be interactive)
  /// and returns to `false` immediately when closing begins.
  bool _isMenuInteractable = false;

  /// The path of the most recently tapped item, used to drive selection
  /// feedback animations (scale, slide, fade) during the brief window between
  /// the tap and the menu closing.
  ///
  /// `null` when no tap is in progress. Reset to `null` after the menu fully
  /// closes via the [AnimationStatus.dismissed] listener.
  List<int>? _tappedItemPath;

  /// The path of the currently active (navigated-to) item.
  ///
  /// A path of `[0]` means the first top-level item is active. A path of
  /// `[1, 2]` means the third child of the second top-level item is active.
  /// Used to resolve the [FluidMenuItem.page] to display and to render the
  /// item list without any dimming/scaling when the menu is closed.
  List<int> _activeItemPath = [0];

  /// Serialized paths of all currently expanded dropdown parent items.
  ///
  /// Keys are path indices joined by commas (e.g. `"1"`, `"1,0"`). Using a
  /// [Set<String>] allows O(1) expand/collapse toggling and membership tests.
  final Set<String> _expandedPaths = {};

  /// Serialized paths of all items whose enabled state is dynamically overridden.
  ///
  /// Keys are path indices joined by commas (e.g. `"1"`, `"1,0"`). Overrides in
  /// this map take precedence over the static [FluidMenuItem.isEnabled] property.
  final Map<String, bool> _enabledOverrides = {};

  /// The path of the currently hovered menu item.
  ///
  /// `null` when no menu item is hovered.
  List<int>? _hoveredItemPath;

  /// Helper to compare two item paths for equality.
  bool _pathEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Whether a horizontal drag gesture is currently being tracked.
  bool _isDragging = false;

  /// Whether the drawer is currently past its midpoint in the open direction.
  ///
  /// Returns `true` when `_controller.value > 0.5`.
  bool get isMenuOpen => _controller.value > 0.5;

  /// Whether the menu is currently accepting tap and pointer interactions.
  bool get isMenuInteractable => _isMenuInteractable;

  /// The current progress value of the menu transition animation.
  double get controllerValue => _controller.value;

  /// The animation that drives the wave reveal and menu item entry transitions.
  ///
  /// Expose this to `contentBuilder` so custom content layers can animate
  /// in sync with the fluid transition.
  Animation<double> get animation => _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Keep the animation linear — the easing curve is applied inside the painter.
    _animation = _controller;

    // Flip interactability when the wave has visually covered enough of the screen.
    _controller.addListener(() {
      final interactable = _controller.value > 0.55;
      if (interactable != _isMenuInteractable) {
        setState(() {
          _isMenuInteractable = interactable;
        });
      }
    });

    // Clear the tapped path state once the drawer has fully closed, so that
    // selection feedback is not visible on the next open.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _tappedItemPath = null;
          _hoveredItemPath = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant FluidSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync the controller duration if the widget is rebuilt with a new value.
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Opens the drawer programmatically.
  ///
  /// A no-op if the drawer is already fully open or currently animating open.
  /// When [triggerHaptic] is `true` (default) and [FluidSideMenu.enableHapticFeedback]
  /// is `true`, fires [HapticFeedback.lightImpact].
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

  /// Closes the drawer programmatically.
  ///
  /// A no-op if the drawer is already fully closed or currently animating closed.
  /// When [triggerHaptic] is `true` (default) and [FluidSideMenu.enableHapticFeedback]
  /// is `true`, fires [HapticFeedback.lightImpact].
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

  /// Toggles the drawer open if it is past the midpoint closed, and closed
  /// if it is past the midpoint open.
  void toggle() {
    if (_controller.value > 0.5) {
      close();
    } else {
      open();
    }
  }

  /// Programmatically enables or disables a menu item at the given [path].
  ///
  /// The [path] represents the hierarchy of the item (e.g., `[0]` for the
  /// first top-level item, or `[1, 2]` for the third child of the second
  /// top-level item).
  ///
  /// Runtime overrides set by this method take precedence over the static
  /// [FluidMenuItem.isEnabled] property.
  void setItemEnabled(List<int> path, bool enabled) {
    if (!mounted) return;
    setState(() {
      _enabledOverrides[path.join(',')] = enabled;
    });
  }

  /// Returns whether the item at the given [path] is currently enabled.
  ///
  /// This checks any dynamic runtime overrides first, falling back to the
  /// item's static [FluidMenuItem.isEnabled] property.
  bool isItemEnabled(List<int> path) {
    final String pathKey = path.join(',');
    if (_enabledOverrides.containsKey(pathKey)) {
      return _enabledOverrides[pathKey]!;
    }

    if (path.isEmpty || path[0] < 0 || path[0] >= widget.menuItems.length) {
      return false;
    }

    FluidMenuItem currentItem = widget.menuItems[path[0]];
    for (int i = 1; i < path.length; i++) {
      final subItems = currentItem.subItems;
      if (subItems == null || path[i] < 0 || path[i] >= subItems.length) {
        return false;
      }
      currentItem = subItems[path[i]];
    }

    return currentItem.isEnabled;
  }

  /// Handles the beginning of a horizontal drag gesture.
  ///
  /// Opens a drag session when:
  /// - The drawer is fully closed and the drag starts within [FluidSideMenu.edgeDragWidth]
  ///   pixels of the left edge.
  /// - The drawer is fully open (regardless of horizontal position).
  ///
  /// Fires a haptic pulse exactly once at the start of each valid drag session
  /// to avoid the double-haptic issue that would occur if haptics were also
  /// fired on the snap-to-open/close at [_handleDragEnd].
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

  /// Translates drag delta into controller progress while a session is active.
  ///
  /// The delta is normalized by screen width so the drag distance maps
  /// linearly to the `[0.0, 1.0]` animation range.
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final double width = MediaQuery.of(context).size.width;
    if (width <= 0) return;
    final double delta = details.primaryDelta ?? 0.0;
    _controller.value = (_controller.value + delta / width).clamp(0.0, 1.0);
  }

  /// Finalizes a drag session by snapping the drawer open or closed.
  ///
  /// If the release velocity exceeds `365 px/s`, the drawer is flung in the
  /// velocity direction. Otherwise it snaps to open or closed based on whether
  /// the controller value is above or below `0.5`.
  ///
  /// Haptics are suppressed on the snap calls (`triggerHaptic: false`) because
  /// a single haptic was already fired at [_handleDragStart].
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

  /// Handles a confirmed tap on a leaf (non-parent) menu item identified by [path].
  ///
  /// Fires [HapticFeedback.selectionClick] once, records [path] as the
  /// [_tappedItemPath] to start the selection feedback animation, and after a
  /// short delay (dependent on [FluidSideMenu.selectAnimationType]) updates the
  /// [_activeItemPath], closes the drawer, and invokes [FluidSideMenu.onItemTapped]
  /// and [FluidSideMenu.onSubItemTapped].
  ///
  /// Re-entrancy is blocked by checking [_tappedItemPath] != null so that
  /// rapid consecutive taps do not produce double feedback or double haptics.
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
        fit: StackFit.expand,
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

  /// Builds the animated overlay that displays all menu items.
  ///
  /// Computes alignment and padding from [FluidSideMenu.itemAlignment], then
  /// constructs a vertical column of staggered [FluidStaggeredMenuItem] wrappers
  /// for each item in [FluidSideMenu.menuItems] via the recursive
  /// [buildMenuItemNode] function.
  ///
  /// When [FluidSideMenu.enableScroll] is `true` the column is wrapped in a
  /// [SingleChildScrollView] so that overflow content remains reachable.
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
      required VoidCallback? onTap,
      bool isSubItem = false,
      bool isExpanded = false,
      bool isDisabled = false,
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
        fontSize: fontSize,
      );

      final bool isHovered =
          !isDisabled &&
          !isAnySelected &&
          _hoveredItemPath != null &&
          _pathEquals(_hoveredItemPath!, path);

      final Color hoverIconColor = isHovered
          ? (widget.hoverColor ?? resolvedIconColor)
          : resolvedIconColor;
      final Color hoverTextColor = isHovered
          ? (widget.hoverColor ?? resolvedTextColor)
          : resolvedTextColor;

      double itemScale = 1.0;
      double itemOpacity = 1.0;
      Offset itemSlideOffset = Offset.zero;

      double labelOpacity = 1.0;
      Offset labelSlideOffset = Offset.zero;
      Offset iconSlideOffset = Offset.zero;

      if (isDisabled) {
        itemOpacity = 0.35;
        itemScale = 1.0;
        itemSlideOffset = Offset.zero;
      } else if (isAnySelected) {
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
      } else if (isHovered) {
        itemOpacity = 1.0;
        itemScale = widget.hoverScale;
        itemSlideOffset = widget.hoverOffset;
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
        child: MouseRegion(
          cursor: isDisabled
              ? SystemMouseCursors.forbidden
              : (onTap != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic),
          onEnter: (_) {
            if (!isDisabled) {
              setState(() {
                _hoveredItemPath = path;
              });
            }
          },
          onExit: (_) {
            if (!isDisabled) {
              setState(() {
                if (_hoveredItemPath != null &&
                    _pathEquals(_hoveredItemPath!, path)) {
                  _hoveredItemPath = null;
                }
              });
            }
          },
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? (widget.hoverBackgroundColor ?? Colors.transparent)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.icon != null) ...[
                          AnimatedSlide(
                            offset: iconSlideOffset,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOutCubic,
                            child: TweenAnimationBuilder<Color?>(
                              duration: const Duration(milliseconds: 200),
                              tween: ColorTween(
                                begin: resolvedIconColor,
                                end: hoverIconColor,
                              ),
                              builder: (context, color, child) {
                                return IconTheme(
                                  data: IconThemeData(
                                    color: color,
                                    size: iconSize,
                                  ),
                                  child: item.icon!,
                                );
                              },
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
                                          FluidMenuSelectAnimationType
                                              .iconSlideSwap
                                  ? 0.0
                                  : null,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                child: AnimatedSlide(
                                  offset: labelSlideOffset,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeInOutCubic,
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: resolvedTextStyle.copyWith(
                                      color: hoverTextColor,
                                    ),
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (item.subItems != null &&
                            item.subItems!.isNotEmpty) ...[
                          const SizedBox(width: 8.0),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Opacity(
                              opacity: 0.7,
                              child: TweenAnimationBuilder<Color?>(
                                duration: const Duration(milliseconds: 200),
                                tween: ColorTween(
                                  begin: resolvedIconColor,
                                  end: hoverIconColor,
                                ),
                                builder: (context, color, child) {
                                  return Icon(
                                    Icons.keyboard_arrow_down,
                                    size: iconSize - 2,
                                    color: color,
                                  );
                                },
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
      final bool isDisabled = !isItemEnabled(path);

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
        isDisabled: isDisabled,
        onTap: isDisabled
            ? null
            : () {
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
