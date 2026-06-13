# Fluid Side Menu

[![Pub Version](https://img.shields.io/pub/v/fluid_side_menu)](https://pub.dev/packages/fluid_side_menu)
[![Pub Likes](https://img.shields.io/pub/likes/fluid_side_menu)](https://pub.dev/packages/fluid_side_menu/likers)
[![Platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev)
[![License: BSD 3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A premium, highly-customizable fluid side navigation drawer for Flutter. It features an organic, gooey liquid-reveal transition (using high-performance custom vector splines), staggered menu option entrance animations, and rich selection feedback behaviors.

---

## Table of Contents

- [Why Fluid Side Menu?](#why-fluid-side-menu)
- [Features](#features)
- [Getting started](#getting-started)
- [Usage](#usage)
  - [Standard Setup](#standard-setup)
  - [Programmatic Control](#programmatic-control)
  - [Customizing the Reveal Background](#customizing-the-reveal-background)
- [API Reference](#api-reference)
  - [FluidSideMenu Options](#fluidsidemenu-options)
  - [FluidMenuItem Options](#fluidmenuitem-options)
  - [Selection Feedback Animations](#selection-feedback-animations)
- [Additional information](#additional-information)
  - [Source Code and Contributions](#source-code-and-contributions)
  - [Reporting Issues](#reporting-issues)
  - [License](#license)

---

## Why Fluid Side Menu?

While standard side drawers transition rigidly across the screen, Fluid Side Menu uses organic motion curves and wavy vector splines to deliver a fluid, high-fidelity navigational experience.

Key benefits include:

- **No Edge Pixelation:** The custom waves are drawn dynamically as sharp vector paths, avoiding the pixelation or fuzzy edges common with raster masks.
- **Optimized Performance:** Leverages isolated RepaintBoundary nodes and linear animation inputs to run smoothly at 60fps/120fps even on lower-end devices.
- **Custom Easing Curves:** The fluid wave transition supports custom animation curves, allowing you to tailor the physics of the goo transition (e.g. springy elastic waves, snappy deceleration, or bounce reveals).

---

## Features

- **Organic Liquid Transition:** High-performance transition using custom vector wave splines that merge and expand across the screen.
- **Staggered Option Animations:** Smooth, delayed entrance animations for menu items (including fade, scale, or springy slide-up) to establish visual hierarchy.
- **Rich Selection Feedback:** A collection of interactive tap animations, including the Icon Slide Swap (where the text fades out and collapses, sliding the selected icon directly into the horizontal center).
- **Item-Level Customization:** Control background colors, gradients, text styles, spacings, and override individual menu item colors (text and icons) independently.

---

## Getting started

Add `fluid_side_menu` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  fluid_side_menu: ^1.0.0
```

Then, import the package in your Dart code:

```dart
import 'package:fluid_side_menu/fluid_side_menu.dart';
```

---

## Usage

### Standard Setup

Here is how you can implement `FluidSideMenu` in a standard Flutter application using stateless widgets for pages:

```dart
import 'package:flutter/material.dart';
import 'package:fluid_side_menu/fluid_side_menu.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluid Side Menu Demo',
      theme: ThemeData(useMaterial3: true),
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
  @override
  Widget build(BuildContext context) {
    // Define the menu items pointing to actual widget screens
    final List<FluidMenuItem> items = [
      FluidMenuItem(
        label: 'Home',
        page: const HomeScreen(),
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
        // Item-level color customizations override the global defaults
        textColor: Colors.orangeAccent,
        iconColor: Colors.orangeAccent,
      ),
    ];

    return Scaffold(
      body: FluidSideMenu(
        fluidColor: Colors.black, // Background color of the reveal drawer
        duration: const Duration(milliseconds: 700), // Speed of wave
        showBuiltInButtons: true, // Auto-renders menu and close buttons
        menuAnimationType: FluidMenuAnimationType.slide,
        selectAnimationType: FluidMenuSelectAnimationType.iconSlideSwap,
        menuItems: items,
      ),
    );
  }
}

// Simple StatelessWidgets representing target screens:
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home Page')));
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Categories Page')));
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('About Page')));
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Contact Page')));
}
```

### Programmatic Control

To open, close, or toggle the drawer programmatically from any screen widget placed inside the side menu, use the static `FluidSideMenu.of(context)` helper:

```dart
// Open the side menu
FluidSideMenu.of(context)?.open();

// Close the side menu
FluidSideMenu.of(context)?.close();

// Toggle the side menu
FluidSideMenu.of(context)?.toggle();
```

Alternatively, you can assign a `GlobalKey<FluidSideMenuState>` to the `FluidSideMenu` widget and call `key.currentState?.open()`.

### Customizing the Reveal Background

Instead of a solid color, you can pass a `LinearGradient` or `RadialGradient` to create a custom gradient appearance for the gooey wave:

```dart
FluidSideMenu(
  menuItems: items,
  fluidGradient: const LinearGradient(
    colors: [
      Color(0xFF0F0C20), // Dark indigo-black
      Color(0xFF15102A), // Dark violet
      Color(0xFF06040A), // Deep black
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  // ... other parameters
)
```

---

## API Reference

### FluidSideMenu Options

| Parameter             | Type                           | Default                                   | Description                                                                           |
| :-------------------- | :----------------------------- | :---------------------------------------- | :------------------------------------------------------------------------------------ |
| `menuItems`           | `List<FluidMenuItem>`          | Required                                  | The navigation screens, labels, and icons.                                            |
| `child`               | `Widget?`                      | `null`                                    | Optional static override for the main screen (if not relying on the menu item pages). |
| `fluidColor`          | `Color`                        | `Colors.black`                            | The background color of the reveal wave drawer.                                       |
| `fluidGradient`       | `Gradient?`                    | `null`                                    | Gradient override for the reveal wave background.                                     |
| `duration`            | `Duration`                     | `Duration(milliseconds: 650)`             | Length of the opening and closing transitions.                                        |
| `animationCurve`      | `Curve`                        | `Curves.easeInOutCubic`                   | Easing curve for the fluid transition.                                                |
| `showBuiltInButtons`  | `bool`                         | `true`                                    | Auto-renders the top-left menu open button and top-right close toggle button.         |
| `menuIcon`            | `Widget?`                      | `null`                                    | Custom icon widget for the main menu open toggle button.                              |
| `closeIcon`           | `Widget?`                      | `null`                                    | Custom icon widget for the close toggle button.                                       |
| `buttonRadius`        | `double`                       | `20.0`                                    | Initial circle radius of the menu toggle button.                                      |
| `menuAnimationType`   | `FluidMenuAnimationType`       | `FluidMenuAnimationType.slide`            | Entry transition type for options (`fade`, `scale`, `slide`).                         |
| `selectAnimationType` | `FluidMenuSelectAnimationType` | `FluidMenuSelectAnimationType.scalePulse` | Tapped selection feedback style (`iconSlideSwap`, `scalePulse`, etc.).                |
| `menuItemTextStyle`   | `TextStyle?`                   | `null`                                    | Text styling of option labels.                                                        |
| `menuItemTextColor`   | `Color?`                       | `null`                                    | Default text color fallback for all items (if not set in `FluidMenuItem`).            |
| `menuItemIconColor`   | `Color?`                       | `null`                                    | Default icon color fallback for all items (if not set in `FluidMenuItem`).            |
| `menuItemSpacing`     | `double`                       | `12.0`                                    | Spacing between option icons and text labels.                                         |
| `enableSwipeGestures`  | `bool`                         | `true`                                    | Whether swipe gestures can be used to pull open or slide close the menu.               |
| `edgeDragWidth`        | `double`                       | `30.0`                                    | The width of the drag zone at the left edge of the screen when the menu is closed.     |
| `revealOrigin`         | `Offset?`                      | `null`                                    | Custom offset coordinates from which the gooey reveal wave originates (defaults to menu button). |
| `enableHapticFeedback` | `bool`                         | `true`                                    | Whether to trigger haptic feedback at critical transitions and option taps.           |

### FluidMenuItem Options

| Parameter   | Type      | Default  | Description                                           |
| :---------- | :-------- | :------- | :---------------------------------------------------- |
| `label`     | `String`  | Required | Label text displayed for the option.                  |
| `page`      | `Widget`  | Required | Target page screen widget to show when tapped.        |
| `icon`      | `Widget?` | `null`   | Prefix icon widget.                                   |
| `textColor` | `Color?`  | `null`   | Individual custom override for the label text color.  |
| `iconColor` | `Color?`  | `null`   | Individual custom override for the prefix icon color. |

### Selection Feedback Animations

| Value             | Behavior                                                                                                                    |
| :---------------- | :-------------------------------------------------------------------------------------------------------------------------- |
| `iconSlideSwap`   | Selected item's label fades/slides out, collapsing size to let the icon center horizontally. Others fade to `0.25` opacity. |
| `scalePulse`      | Selected item scales up to `1.08`, others dim to `0.35` opacity.                                                            |
| `slideRight`      | Selected item slides right, others dim to `0.35` opacity.                                                                   |
| `scaleDownOthers` | Selected item stays stable, others scale down to `0.9` and dim.                                                             |
| `fadeOthers`      | Selected item stays stable, others dim.                                                                                     |
| `none`            | Immediate nav execution without feedback animation.                                                                         |

---

## Additional information

### Source Code and Contributions

The source code and examples are hosted on GitHub. If you wish to contribute, report bugs, or request features, please open an issue or pull request in the repository.

### Reporting Issues

Please use the repository's GitHub Issues page to report bugs, request documentation updates, or propose new design features.

### License

This project is licensed under the BSD 3-Clause License - see the LICENSE file for details.
