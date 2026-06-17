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

  // Hover styling configuration state variables
  bool _enableHover = true;
  double _hoverScale = 1.05;
  double _hoverSlide = 0.05;
  String _hoverBgPreset = 'WHITE'; // 'NONE', 'WHITE', 'PURPLE'
  String _hoverColorPreset = 'WHITE'; // 'ORIGINAL', 'WHITE', 'AMBER'
  int _activeConfigTab = 0;

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

    Color? hoverColor;
    if (_enableHover) {
      if (_hoverColorPreset == 'WHITE') {
        hoverColor = Colors.white;
      } else if (_hoverColorPreset == 'AMBER') {
        hoverColor = Colors.amberAccent;
      }
    }

    Color? hoverBackgroundColor;
    if (_enableHover) {
      if (_hoverBgPreset == 'WHITE') {
        hoverBackgroundColor = Colors.white.withValues(alpha: 0.12);
      } else if (_hoverBgPreset == 'PURPLE') {
        hoverBackgroundColor = Colors.purple.withValues(alpha: 0.25);
      }
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
        hoverColor: hoverColor,
        hoverBackgroundColor: hoverBackgroundColor,
        hoverScale: _enableHover ? _hoverScale : 1.0,
        hoverOffset: _enableHover ? Offset(_hoverSlide, 0.0) : Offset.zero,
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

    final Widget hoverToggleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hover styling',
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
                onPressed: () => setState(() => _enableHover = true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _enableHover ? Colors.black : Colors.white,
                  foregroundColor: _enableHover ? Colors.white : Colors.black,
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
                onPressed: () => setState(() => _enableHover = false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: !_enableHover ? Colors.black : Colors.white,
                  foregroundColor: !_enableHover ? Colors.white : Colors.black,
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

    final Widget hoverScaleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hover scale',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_hoverScale.toStringAsFixed(2)}x',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.0,
            activeTrackColor: Colors.black,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: Colors.black,
            overlayColor: Colors.black.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: _hoverScale,
            min: 1.0,
            max: 1.15,
            onChanged: _enableHover
                ? (val) => setState(() => _hoverScale = val)
                : null,
          ),
        ),
      ],
    );

    final Widget hoverSlideCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hover slide',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _hoverSlide.toStringAsFixed(2),
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.0,
            activeTrackColor: Colors.black,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: Colors.black,
            overlayColor: Colors.black.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: _hoverSlide,
            min: 0.0,
            max: 0.15,
            onChanged: _enableHover
                ? (val) => setState(() => _hoverSlide = val)
                : null,
          ),
        ),
      ],
    );

    final Widget hoverBgPresetCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hover background',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<String>(
          initialValue: _hoverBgPreset,
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
            DropdownMenuItem(value: 'NONE', child: Text('NONE')),
            DropdownMenuItem(value: 'WHITE', child: Text('TRANSLUCENT WHITE')),
            DropdownMenuItem(
              value: 'PURPLE',
              child: Text('TRANSLUCENT VIOLET'),
            ),
          ],
          onChanged: _enableHover
              ? (val) {
                  if (val != null) {
                    setState(() {
                      _hoverBgPreset = val;
                    });
                  }
                }
              : null,
        ),
      ],
    );

    final Widget hoverColorPresetCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hover text/icon color',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<String>(
          initialValue: _hoverColorPreset,
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
            DropdownMenuItem(value: 'ORIGINAL', child: Text('ORIGINAL')),
            DropdownMenuItem(value: 'WHITE', child: Text('BRIGHT WHITE')),
            DropdownMenuItem(value: 'AMBER', child: Text('NEON AMBER')),
          ],
          onChanged: _enableHover
              ? (val) {
                  if (val != null) {
                    setState(() {
                      _hoverColorPreset = val;
                    });
                  }
                }
              : null,
        ),
      ],
    );

    final List<String> tabLabels = [
      'TRANSITIONS',
      'LAYOUT & GESTURES',
      'HOVER AESTHETICS',
    ];

    final Widget tabHeader = Container(
      height: 38,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: List.generate(tabLabels.length, (idx) {
          final isSelected = _activeConfigTab == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeConfigTab = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9.0),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabLabels[idx],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.black : Colors.black45,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

    Widget buildTabContent() {
      if (_activeConfigTab == 0) {
        if (isWide) {
          return Row(
            children: [
              Expanded(child: entryAnimationCol),
              const SizedBox(width: 14.0),
              Expanded(child: selectAnimationCol),
              const SizedBox(width: 14.0),
              Expanded(child: curveCol),
            ],
          );
        } else {
          return Column(
            children: [
              entryAnimationCol,
              const SizedBox(height: 14.0),
              selectAnimationCol,
              const SizedBox(height: 14.0),
              curveCol,
            ],
          );
        }
      } else if (_activeConfigTab == 1) {
        if (isWide) {
          return Column(
            children: [
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
            ],
          );
        } else {
          return Column(
            children: [
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
          );
        }
      } else {
        if (isWide) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: hoverToggleCol),
                  const SizedBox(width: 14.0),
                  Expanded(child: hoverScaleCol),
                  const SizedBox(width: 14.0),
                  Expanded(child: hoverSlideCol),
                ],
              ),
              const SizedBox(height: 14.0),
              Row(
                children: [
                  Expanded(child: hoverBgPresetCol),
                  const SizedBox(width: 14.0),
                  Expanded(child: hoverColorPresetCol),
                  const SizedBox(width: 14.0),
                  const Spacer(),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              hoverToggleCol,
              const SizedBox(height: 14.0),
              hoverScaleCol,
              const SizedBox(height: 14.0),
              hoverSlideCol,
              const SizedBox(height: 14.0),
              hoverBgPresetCol,
              const SizedBox(height: 14.0),
              hoverColorPresetCol,
            ],
          );
        }
      }
    }

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
                'FLUID SIDE MENU CONFIGURATOR',
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
          tabHeader,
          const SizedBox(height: 20.0),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            child: buildTabContent(),
          ),
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

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.black38),
            ),
          ],
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: Colors.purpleAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
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
                  const SizedBox(height: 4.0),
                  Text(
                    'Active Navigation Screen',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.black38,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DYNAMIC ITEM CONTROLS',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            _buildSwitchRow(
                              title: "Enable 'Contact us' item",
                              subtitle:
                                  "Toggles item interactability dynamically",
                              value: _contactUsEnabled,
                              onChanged: (val) {
                                setState(() {
                                  _contactUsEnabled = val;
                                });
                                FluidSideMenu.of(
                                  context,
                                )?.setItemEnabled([4], val);
                              },
                            ),
                            const Divider(height: 24.0, color: Colors.black12),
                            _buildSwitchRow(
                              title: "Enable 'Birthday Gifts' sub-item",
                              subtitle: "Toggles sub-menu item dynamically",
                              value: _birthdayGiftsEnabled,
                              onChanged: (val) {
                                setState(() {
                                  _birthdayGiftsEnabled = val;
                                });
                                FluidSideMenu.of(
                                  context,
                                )?.setItemEnabled([1, 1, 0], val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  widget.configuratorPanel,
                ],
              ),
            ),
          ),
        ),
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
