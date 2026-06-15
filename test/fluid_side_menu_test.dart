import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluid_side_menu/fluid_side_menu.dart';

void main() {
  test('verify FluidMenuAnimationType values', () {
    expect(FluidMenuAnimationType.values.length, 3);
    expect(
      FluidMenuAnimationType.fade.toString(),
      'FluidMenuAnimationType.fade',
    );
    expect(
      FluidMenuAnimationType.scale.toString(),
      'FluidMenuAnimationType.scale',
    );
    expect(
      FluidMenuAnimationType.slide.toString(),
      'FluidMenuAnimationType.slide',
    );
  });

  testWidgets('FluidSideMenu honors static isEnabled property', (
    WidgetTester tester,
  ) async {
    bool homeTapped = false;
    bool disabledTapped = false;

    final items = [
      FluidMenuItem(label: 'Home', onTap: () => homeTapped = true),
      FluidMenuItem(
        label: 'Disabled Item',
        isEnabled: false,
        onTap: () => disabledTapped = true,
      ),
    ];

    final key = GlobalKey<FluidSideMenuState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FluidSideMenu(
            key: key,
            menuItems: items,
            showBuiltInButtons: false,
          ),
        ),
      ),
    );

    // Open the menu programmatically so it is interactive
    key.currentState?.open(triggerHaptic: false);
    await tester.pumpAndSettle();

    // Verify both items are rendered
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Disabled Item'), findsOneWidget);

    // Try tapping the active Home item
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(homeTapped, isTrue);

    // Try tapping the disabled item
    await tester.tap(find.text('Disabled Item'));
    await tester.pumpAndSettle();
    expect(disabledTapped, isFalse);
  });

  testWidgets('FluidSideMenu honors dynamic setItemEnabled overrides', (
    WidgetTester tester,
  ) async {
    bool itemTapped = false;

    final items = [
      FluidMenuItem(label: 'Dynamic Item', onTap: () => itemTapped = true),
    ];

    final key = GlobalKey<FluidSideMenuState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FluidSideMenu(
            key: key,
            menuItems: items,
            showBuiltInButtons: false,
          ),
        ),
      ),
    );

    // Open the menu programmatically so it is interactive
    key.currentState?.open(triggerHaptic: false);
    await tester.pumpAndSettle();

    // Verify it is enabled initially
    expect(key.currentState?.isItemEnabled([0]), isTrue);

    // Try tapping the item (should fire callback)
    await tester.tap(find.text('Dynamic Item'));
    await tester.pumpAndSettle();
    expect(itemTapped, isTrue);

    // Reopen the menu since the tap closed it
    key.currentState?.open(triggerHaptic: false);
    await tester.pumpAndSettle();

    // Reset tap flag
    itemTapped = false;

    // Dynamically disable the item
    key.currentState?.setItemEnabled([0], false);
    await tester.pumpAndSettle();

    // Verify it is disabled in state
    expect(key.currentState?.isItemEnabled([0]), isFalse);

    // Try tapping the item again (should NOT fire callback)
    await tester.tap(find.text('Dynamic Item'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(itemTapped, isFalse);

    // Dynamically enable the item back
    key.currentState?.setItemEnabled([0], true);
    await tester.pumpAndSettle();

    // Verify it is enabled again
    expect(key.currentState?.isItemEnabled([0]), isTrue);

    // Try tapping the item again (should fire callback)
    await tester.tap(find.text('Dynamic Item'));
    await tester.pumpAndSettle();
    expect(itemTapped, isTrue);
  });

  testWidgets('FluidSideMenu hover updates scale, offset, and color', (
    WidgetTester tester,
  ) async {
    final items = [
      FluidMenuItem(label: 'Home'),
      FluidMenuItem(label: 'Settings'),
    ];

    final key = GlobalKey<FluidSideMenuState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FluidSideMenu(
            key: key,
            menuItems: items,
            showBuiltInButtons: false,
            hoverColor: Colors.amber,
            hoverBackgroundColor: Colors.red,
            hoverScale: 1.12,
            hoverOffset: const Offset(0.08, 0.0),
          ),
        ),
      ),
    );

    key.currentState?.open(triggerHaptic: false);
    await tester.pumpAndSettle();

    final homeFinder = find.text('Home');
    final homeMouseRegionFinder = find.ancestor(
      of: homeFinder,
      matching: find.byType(MouseRegion),
    ).first;

    // Initially not hovered, check defaults
    final initialScale = tester.widget<AnimatedScale>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedScale)).first,
    );
    expect(initialScale.scale, 1.0);

    final initialSlide = tester.widget<AnimatedSlide>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedSlide)).first,
    );
    expect(initialSlide.offset, Offset.zero);

    // Hover mouse over Home
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(homeFinder));
    await tester.pumpAndSettle();

    // Check hovered values
    final hoveredScale = tester.widget<AnimatedScale>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedScale)).first,
    );
    expect(hoveredScale.scale, 1.12);

    final hoveredSlide = tester.widget<AnimatedSlide>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedSlide)).first,
    );
    expect(hoveredSlide.offset, const Offset(0.08, 0.0));

    final hoveredText = tester.widget<AnimatedDefaultTextStyle>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedDefaultTextStyle)).first,
    );
    expect(hoveredText.style.color, Colors.amber);

    final hoveredContainer = tester.widget<AnimatedContainer>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedContainer)).first,
    );
    final hoveredDecoration = hoveredContainer.decoration as BoxDecoration;
    expect(hoveredDecoration.color, Colors.red);

    // Move mouse away (unhover)
    await gesture.moveTo(Offset.zero);
    await tester.pumpAndSettle();

    // Verify values reverted
    final unhoveredScale = tester.widget<AnimatedScale>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedScale)).first,
    );
    expect(unhoveredScale.scale, 1.0);

    final unhoveredSlide = tester.widget<AnimatedSlide>(
      find.descendant(of: homeMouseRegionFinder, matching: find.byType(AnimatedSlide)).first,
    );
    expect(unhoveredSlide.offset, Offset.zero);

    await gesture.removePointer();
  });

  testWidgets('FluidSideMenu disabled item ignores hover styling', (
    WidgetTester tester,
  ) async {
    final items = [
      FluidMenuItem(label: 'Disabled Item', isEnabled: false),
    ];

    final key = GlobalKey<FluidSideMenuState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FluidSideMenu(
            key: key,
            menuItems: items,
            showBuiltInButtons: false,
            hoverColor: Colors.amber,
            hoverBackgroundColor: Colors.red,
            hoverScale: 1.12,
            hoverOffset: const Offset(0.08, 0.0),
          ),
        ),
      ),
    );

    key.currentState?.open(triggerHaptic: false);
    await tester.pumpAndSettle();

    final itemFinder = find.text('Disabled Item');
    final mouseRegionFinder = find.ancestor(
      of: itemFinder,
      matching: find.byType(MouseRegion),
    ).first;

    // Initial scale check
    final initialScale = tester.widget<AnimatedScale>(
      find.descendant(of: mouseRegionFinder, matching: find.byType(AnimatedScale)).first,
    );
    expect(initialScale.scale, 1.0);

    // Hover mouse over Disabled Item
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(itemFinder));
    await tester.pumpAndSettle();

    // Check scale remains 1.0 (ignored hover)
    final hoveredScale = tester.widget<AnimatedScale>(
      find.descendant(of: mouseRegionFinder, matching: find.byType(AnimatedScale)).first,
    );
    expect(hoveredScale.scale, 1.0);

    final hoveredSlide = tester.widget<AnimatedSlide>(
      find.descendant(of: mouseRegionFinder, matching: find.byType(AnimatedSlide)).first,
    );
    expect(hoveredSlide.offset, Offset.zero);

    await gesture.removePointer();
  });
}
