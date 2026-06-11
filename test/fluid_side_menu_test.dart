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
}
