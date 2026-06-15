import 'package:flutter/material.dart';
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
    debugPrint('Is menu open before open(): ${key.currentState?.isMenuOpen}');
    debugPrint(
      'Is menu interactable before open(): ${key.currentState?.isMenuInteractable}',
    );
    debugPrint(
      'Controller value before open(): ${key.currentState?.controllerValue}',
    );
    key.currentState?.open(triggerHaptic: false);
    await tester.pumpAndSettle();
    debugPrint('Is menu open after open(): ${key.currentState?.isMenuOpen}');
    debugPrint(
      'Is menu interactable after open(): ${key.currentState?.isMenuInteractable}',
    );
    debugPrint(
      'Controller value after open(): ${key.currentState?.controllerValue}',
    );
    debugPrint('Rect of Home: ${tester.getRect(find.text('Home'))}');

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

    // Reset tap flag
    itemTapped = false;

    // Dynamically disable the item
    key.currentState?.setItemEnabled([0], false);
    await tester.pumpAndSettle();

    // Verify it is disabled in state
    expect(key.currentState?.isItemEnabled([0]), isFalse);

    // Try tapping the item again (should NOT fire callback)
    await tester.tap(find.text('Dynamic Item'));
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
}
