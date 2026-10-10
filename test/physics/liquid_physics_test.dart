import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_containerx/liquid_containerx.dart';

void main() {
  test('LiquidPhysics equality', () {
    const p1 = LiquidPhysics(enabled: true, elasticity: 0.5);
    const p2 = LiquidPhysics(enabled: true, elasticity: 0.5);
    const p3 = LiquidPhysics(enabled: false);

    expect(p1, equals(p2));
    expect(p1, isNot(equals(p3)));
  });
}
