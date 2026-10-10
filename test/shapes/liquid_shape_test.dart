import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_containerx/liquid_containerx.dart';

void main() {
  test('LiquidShape constructors', () {
    expect(LiquidShape.rectangle.type, equals(LiquidShapeType.rectangle));
    expect(LiquidShape.circle.type, equals(LiquidShapeType.circle));
  });
}
