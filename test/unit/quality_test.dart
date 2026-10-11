import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassQuality', () {
    test('resolve maps auto properly based on parameters', () {
      expect(
        LiquidGlassQuality.auto.resolve(reduceTransparency: true),
        equals(LiquidGlassQuality.low),
      );
      expect(
        LiquidGlassQuality.auto.resolve(isLowPower: true),
        equals(LiquidGlassQuality.low),
      );
      expect(
        LiquidGlassQuality.auto.resolve(),
        equals(LiquidGlassQuality.high),
      );
    });

    test(
      'supportsChromaticAberration and supportsNoiseDithering behave correctly',
      () {
        expect(LiquidGlassQuality.high.supportsChromaticAberration, isTrue);
        expect(LiquidGlassQuality.low.supportsChromaticAberration, isFalse);
        expect(LiquidGlassQuality.medium.supportsChromaticAberration, isFalse);

        expect(LiquidGlassQuality.high.supportsNoiseDithering, isTrue);
        expect(LiquidGlassQuality.medium.supportsNoiseDithering, isTrue);
        expect(LiquidGlassQuality.low.supportsNoiseDithering, isFalse);
      },
    );

    test('shaderUniformValue matches expected enum indices', () {
      expect(LiquidGlassQuality.low.shaderUniformValue, equals(0.0));
      expect(LiquidGlassQuality.medium.shaderUniformValue, equals(1.0));
      expect(LiquidGlassQuality.high.shaderUniformValue, equals(2.0));
    });
  });
}
