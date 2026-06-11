import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluid_side_menu/fluid_side_menu.dart';

void main() {
  runApp(const MyApp());
}

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

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  // Key to control the menu state (open/close)
  final GlobalKey<FluidSideMenuState> _menuKey =
      GlobalKey<FluidSideMenuState>();

  // State variables for animation configuration
  FluidMenuAnimationType _entryAnimation = FluidMenuAnimationType.slide;
  FluidMenuSelectAnimationType _selectAnimation =
      FluidMenuSelectAnimationType.scalePulse;
  bool _useGradient = true;

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
        page: const CategoriesScreen(),
        icon: const Icon(Icons.category),
      ),
      FluidMenuItem(
        label: 'About',
        page: const AboutScreen(),
        icon: const Icon(Icons.info),
      ),
      FluidMenuItem(
        label: 'Contact us',
        page: const ContactScreen(),
        icon: const Icon(Icons.mail),
        textColor: Colors.orangeAccent, // Custom text color for this item
        iconColor: Colors.orangeAccent, // Custom icon color for this item
      ),
    ];

    return Scaffold(
      body: FluidSideMenu(
        key: _menuKey,
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
        menuIcon: const Icon(Icons.menu_open, size: 22),
        menuItemSpacing: 16.0,
        menuItemTextStyle: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        menuItemTextColor:
            Colors.white70, // Package-level default item text color
        menuItemIconColor:
            Colors.white70, // Package-level default item icon color
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
              ],
            ),
            const SizedBox(height: 14.0),
            backgroundStyleCol,
          ] else ...[
            entryAnimationCol,
            const SizedBox(height: 14.0),
            selectAnimationCol,
            const SizedBox(height: 14.0),
            backgroundStyleCol,
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

class HomeScreen extends StatelessWidget {
  final Widget configuratorPanel;

  const HomeScreen({super.key, required this.configuratorPanel});

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
              ],
            ),
          ),
          Positioned(
            left: 24.0,
            right: 24.0,
            bottom: 40.0,
            child: configuratorPanel,
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
              'Fluid Side Menu Package - Version 1.0.0',
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
              'Reach out to me at galaxyphoenix716@gmai.com',
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
