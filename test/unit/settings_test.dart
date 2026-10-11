import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassSettings', () {
    test('Default values are valid and non-null', () {
      const settings = LiquidGlassSettings();
      expect(settings.blur, equals(20.0));
      expect(settings.refractionStrength, equals(0.3));
      expect(settings.thickness, equals(12.0));
      expect(settings.specularIntensity, equals(0.45));
      expect(settings.tintColor, equals(Colors.white));
      expect(settings.tintOpacity, equals(0.15));
      expect(settings.quality, equals(LiquidGlassQuality.auto));
    });

    test('Assertions prevent invalid negative or out-of-bound values', () {
      expect(() => LiquidGlassSettings(blur: -1.0), throwsAssertionError);
      expect(
        () => LiquidGlassSettings(refractionStrength: 1.5),
        throwsAssertionError,
      );
      expect(
        () => LiquidGlassSettings(refractionStrength: -0.1),
        throwsAssertionError,
      );
      expect(() => LiquidGlassSettings(tintOpacity: 1.2), throwsAssertionError);
      expect(
        () => LiquidGlassSettings(specularIntensity: 2.0),
        throwsAssertionError,
      );
    });

    test('copyWith replaces specific fields and retains others', () {
      const original = LiquidGlassSettings(blur: 15.0, refractionStrength: 0.2);
      final updated = original.copyWith(blur: 35.0, tintColor: Colors.blue);

      expect(updated.blur, equals(35.0));
      expect(updated.refractionStrength, equals(0.2));
      expect(updated.tintColor, equals(Colors.blue));
      expect(updated.thickness, equals(original.thickness));
    });

    test('lerp correctly interpolates between two settings', () {
      const a = LiquidGlassSettings(blur: 10.0, refractionStrength: 0.2);
      const b = LiquidGlassSettings(blur: 30.0, refractionStrength: 0.6);

      final half = LiquidGlassSettings.lerp(a, b, 0.5);
      expect(half.blur, closeTo(20.0, 0.001));
      expect(half.refractionStrength, closeTo(0.4, 0.001));

      final atZero = LiquidGlassSettings.lerp(a, b, 0.0);
      expect(atZero.blur, equals(10.0));

      final atOne = LiquidGlassSettings.lerp(a, b, 1.0);
      expect(atOne.blur, equals(30.0));
    });

    test('effectiveTintColor computes correct blended alpha', () {
      const settings = LiquidGlassSettings(
        tintColor: Colors.white,
        tintOpacity: 0.25,
      );
      expect(settings.effectiveTintColor.a, closeTo(0.25, 0.01));
    });

    test('Equality and hashCode match for identical configurations', () {
      const s1 = LiquidGlassSettings(blur: 25.0);
      const s2 = LiquidGlassSettings(blur: 25.0);
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
    });
  });
}
