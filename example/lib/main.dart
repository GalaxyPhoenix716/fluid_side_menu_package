import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluid_side_menu/fluid_side_menu.dart';

/// Entry point of the Fluid Side Menu example application.
void main() {
  runApp(const MyApp());
}

/// Root widget for the demo application.
///
/// Applies a light Material3 theme with the Outfit Google Font and launches
/// [DemoScreen] as the home route.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluid Side Menu Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

/// The main demo screen that hosts [FluidSideMenu].
///
/// Holds all interactive configurator state (animation type, curve, alignment,
/// swipe gestures, haptics, gradient toggle, and wave origin) and rebuilds the
/// [FluidSideMenu] whenever the user changes a setting via the controls panel.
class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  // ---------------------------------------------------------------------------
  // Configurator state
  // Each field maps to one control in the "TRANSITION CONFIGURATOR" panel and
  // is passed directly to the [FluidSideMenu] widget on every rebuild.
  // ---------------------------------------------------------------------------

  /// Currently selected menu item entrance animation.
  FluidMenuAnimationType _entryAnimation = FluidMenuAnimationType.slide;

  /// Currently selected item tap selection feedback animation.
  FluidMenuSelectAnimationType _selectAnimation =
      FluidMenuSelectAnimationType.scalePulse;

  /// Whether the drawer background should use a gradient (`true`) or a solid color.
  bool _useGradient = true;
  Curve _animationCurve = Curves.easeInOutCubic;
  bool _enableSwipe = true;
  String _originType = 'TOP LEFT';
  bool _enableHaptic = true;
  FluidMenuItemAlignment _itemAlignment = FluidMenuItemAlignment.center;

  @override
  Widget build(BuildContext context) {
    // Define the menu items containing label, page widget, and optional colors/icons
    final List<FluidMenuItem> items = [
      FluidMenuItem(
        label: 'Home',
        page: HomeScreen(configuratorPanel: _buildControlsPanel()),
        icon: const Icon(Icons.home),
      ),
      FluidMenuItem(
        label: 'Categories',
        icon: const Icon(Icons.category),
        subItems: [
          FluidMenuItem(
            label: 'Baskets',
            icon: const Icon(Icons.shopping_basket),
            subItems: [
              FluidMenuItem(
                label: 'Woven Baskets',
                page: const BasketsScreen(),
                icon: const Icon(Icons.shopping_bag),
              ),
              FluidMenuItem(
                label: 'Plastic Baskets',
                page: const BasketsScreen(),
                icon: const Icon(Icons.shopping_basket),
                // Per-item size override: slightly larger than the sibling above
                textStyle: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                iconSize: 20.0,
              ),
            ],
          ),
          FluidMenuItem(
            label: 'Gifts',
            icon: const Icon(Icons.card_giftcard),
            subItems: [
              FluidMenuItem(
                label: 'Birthday Gifts',
                page: const GiftsScreen(),
                icon: const Icon(Icons.cake),
              ),
              FluidMenuItem(
                label: 'Anniversary Gifts',
                page: const GiftsScreen(),
                icon: const Icon(Icons.favorite),
              ),
              FluidMenuItem(
                label: 'Holiday Gifts',
                page: const GiftsScreen(),
                icon: const Icon(Icons.celebration),
              ),
            ],
          ),
          FluidMenuItem(
            label: 'Furniture',
            icon: const Icon(Icons.chair),
            subItems: [
              FluidMenuItem(
                label: 'Chairs',
                page: const FurnitureScreen(),
                icon: const Icon(Icons.chair_alt),
              ),
              FluidMenuItem(
                label: 'Tables',
                page: const FurnitureScreen(),
                icon: const Icon(Icons.table_restaurant),
              ),
            ],
          ),
        ],
      ),
      FluidMenuItem(
        label: 'About',
        page: const AboutScreen(),
        icon: const Icon(Icons.info),
      ),
      FluidMenuItem(
        label: 'Admin (Disabled)',
        icon: const Icon(Icons.lock_outline),
        isEnabled: false,
      ),
      FluidMenuItem(
        label: 'Contact us',
        page: const ContactScreen(),
        icon: const Icon(Icons.mail),
        textColor: Colors.purpleAccent,
        iconColor: Colors.purpleAccent,
      ),
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    Offset? revealOrigin;
    if (_originType == 'BOTTOM CENTER') {
      revealOrigin = Offset(screenWidth / 2, screenHeight - 40.0);
    } else if (_originType == 'CENTER') {
      revealOrigin = Offset(screenWidth / 2, screenHeight / 2);
    }

    return Scaffold(
      body: FluidSideMenu(
        fluidColor: Colors.black,
        fluidGradient: _useGradient
            ? const LinearGradient(
                colors: [
                  Color(0xFF0F0C20), // Dark indigo-black
                  Color(0xFF15102A), // Dark violet
                  Color(0xFF06040A), // Deep black
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        duration: const Duration(milliseconds: 800), // Smooth, slow liquid feel
        showBuiltInButtons: true,
        menuAnimationType: _entryAnimation,
        selectAnimationType: _selectAnimation,
        animationCurve: _animationCurve,
        enableSwipeGestures: _enableSwipe,
        revealOrigin: revealOrigin,
        enableHapticFeedback: _enableHaptic,
        itemAlignment: _itemAlignment,
        menuIcon: const Icon(Icons.menu_open, size: 22),
        menuItemSpacing: 16.0,
        menuItemTextStyle: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        subMenuItemTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        subMenuItemIconSize: 18.0,
        menuItemTextColor: Colors.white70,
        menuItemIconColor: Colors.white70,
        // Scroll is enabled by default; all items will be reachable even on
        // small screens with many nested items open simultaneously.
        enableScroll: true,
        // Reduce vertical padding slightly so more items fit before scrolling
        menuItemPadding: const EdgeInsets.symmetric(vertical: 9.0),
        subMenuItemPadding: const EdgeInsets.only(top: 10.0),
        menuItems: items,
      ),
    );
  }

  Widget _buildControlsPanel() {
    final bool isWide = MediaQuery.of(context).size.width > 540;

    final Widget entryAnimationCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrance animation',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<FluidMenuAnimationType>(
          initialValue: _entryAnimation,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          items: FluidMenuAnimationType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _entryAnimation = val;
              });
            }
          },
        ),
      ],
    );

    final Widget selectAnimationCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selection feedback',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<FluidMenuSelectAnimationType>(
          initialValue: _selectAnimation,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          items: FluidMenuSelectAnimationType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getSelectAnimationLabel(type)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectAnimation = val;
              });
            }
          },
        ),
      ],
    );

    final Widget curveCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transition curve',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<Curve>(
          initialValue: _animationCurve,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          items: const [
            DropdownMenuItem(
              value: Curves.easeInOutCubic,
              child: Text('EASE IN OUT CUBIC'),
            ),
            DropdownMenuItem(
              value: Curves.decelerate,
              child: Text('DECELERATE'),
            ),
            DropdownMenuItem(
              value: Curves.bounceOut,
              child: Text('BOUNCE OUT'),
            ),
            DropdownMenuItem(
              value: Curves.elasticOut,
              child: Text('ELASTIC OUT'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _animationCurve = val;
              });
            }
          },
        ),
      ],
    );

    final Widget backgroundStyleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background style',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _useGradient = false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: !_useGradient ? Colors.black : Colors.white,
                  foregroundColor: !_useGradient ? Colors.white : Colors.black,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'SOLID BLACK',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _useGradient = true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _useGradient ? Colors.black : Colors.white,
                  foregroundColor: _useGradient ? Colors.white : Colors.black,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'GRADIENT',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final Widget swipeGestureCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Swipe gestures',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _enableSwipe = true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _enableSwipe ? Colors.black : Colors.white,
                  foregroundColor: _enableSwipe ? Colors.white : Colors.black,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'ENABLED',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _enableSwipe = false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: !_enableSwipe ? Colors.black : Colors.white,
                  foregroundColor: !_enableSwipe ? Colors.white : Colors.black,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'DISABLED',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final Widget originCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wave origin',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<String>(
          initialValue: _originType,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          items: const [
            DropdownMenuItem(
              value: 'TOP LEFT',
              child: Text('TOP LEFT (DEFAULT)'),
            ),
            DropdownMenuItem(value: 'CENTER', child: Text('CENTER')),
            DropdownMenuItem(
              value: 'BOTTOM CENTER',
              child: Text('BOTTOM CENTER'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _originType = val;
              });
            }
          },
        ),
      ],
    );

    final Widget hapticCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Haptic feedback',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _enableHaptic = true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _enableHaptic ? Colors.black : Colors.white,
                  foregroundColor: _enableHaptic ? Colors.white : Colors.black,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'ENABLED',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _enableHaptic = false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: !_enableHaptic ? Colors.black : Colors.white,
                  foregroundColor: !_enableHaptic ? Colors.white : Colors.black,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'DISABLED',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final Widget alignmentCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item alignment',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<FluidMenuItemAlignment>(
          initialValue: _itemAlignment,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          items: FluidMenuItemAlignment.values.map((align) {
            return DropdownMenuItem(
              value: align,
              child: Text(align.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _itemAlignment = val;
              });
            }
          },
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'TRANSITION CONFIGURATOR',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (isWide) ...[
            Row(
              children: [
                Expanded(child: entryAnimationCol),
                const SizedBox(width: 14.0),
                Expanded(child: selectAnimationCol),
                const SizedBox(width: 14.0),
                Expanded(child: curveCol),
              ],
            ),
            const SizedBox(height: 14.0),
            Row(
              children: [
                Expanded(child: backgroundStyleCol),
                const SizedBox(width: 14.0),
                Expanded(child: swipeGestureCol),
                const SizedBox(width: 14.0),
                Expanded(child: originCol),
              ],
            ),
            const SizedBox(height: 14.0),
            Row(
              children: [
                Expanded(child: alignmentCol),
                const SizedBox(width: 14.0),
                Expanded(child: hapticCol),
              ],
            ),
          ] else ...[
            entryAnimationCol,
            const SizedBox(height: 14.0),
            selectAnimationCol,
            const SizedBox(height: 14.0),
            curveCol,
            const SizedBox(height: 14.0),
            backgroundStyleCol,
            const SizedBox(height: 14.0),
            swipeGestureCol,
            const SizedBox(height: 14.0),
            originCol,
            const SizedBox(height: 14.0),
            alignmentCol,
            const SizedBox(height: 14.0),
            hapticCol,
          ],
        ],
      ),
    );
  }

  String _getSelectAnimationLabel(FluidMenuSelectAnimationType type) {
    switch (type) {
      case FluidMenuSelectAnimationType.scalePulse:
        return 'SCALE PULSE';
      case FluidMenuSelectAnimationType.slideRight:
        return 'SLIDE RIGHT';
      case FluidMenuSelectAnimationType.scaleDownOthers:
        return 'SCALE DOWN OTHERS';
      case FluidMenuSelectAnimationType.fadeOthers:
        return 'FADE OTHERS';
      case FluidMenuSelectAnimationType.none:
        return 'NONE';
      case FluidMenuSelectAnimationType.iconSlideSwap:
        return 'ICON SLIDE SWAP';
    }
  }
}

// =========================================================================
// PROPER STATELESS WIDGETS FOR REAL-WORLD SCREEN DEMONSTRATION
// =========================================================================

class HomeScreen extends StatefulWidget {
  final Widget configuratorPanel;

  const HomeScreen({super.key, required this.configuratorPanel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _contactUsEnabled = true;
  bool _birthdayGiftsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HOME',
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Active Navigation Screen',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enable 'Contact us' item:",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Switch.adaptive(
                        value: _contactUsEnabled,
                        activeTrackColor: Colors.purpleAccent,
                        onChanged: (val) {
                          setState(() {
                            _contactUsEnabled = val;
                          });
                          // Path: [4] -> Contact us is the 5th item (index 4)
                          FluidSideMenu.of(context)?.setItemEnabled([4], val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enable 'Birthday Gifts' sub-item:",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Switch.adaptive(
                        value: _birthdayGiftsEnabled,
                        activeTrackColor: Colors.purpleAccent,
                        onChanged: (val) {
                          setState(() {
                            _birthdayGiftsEnabled = val;
                          });
                          // Path: [1, 1, 0] -> Categories (1) -> Gifts (1) -> Birthday Gifts (0)
                          FluidSideMenu.of(
                            context,
                          )?.setItemEnabled([1, 1, 0], val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24.0,
            right: 24.0,
            bottom: 40.0,
            child: widget.configuratorPanel,
          ),
        ],
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CATEGORIES',
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Explore categorized items here',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ABOUT',
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Fluid Side Menu Package - Version 1.2.0',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CONTACT US',
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Reach out to me at \ngalaxyphoenix716@gmai.com',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BasketsScreen extends StatelessWidget {
  const BasketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'BASKETS CATEGORY',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'GIFTS CATEGORY',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class FurnitureScreen extends StatelessWidget {
  const FurnitureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'FURNITURE',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'SHOP',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'ORDERS',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'WISHLIST',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'SETTINGS',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
