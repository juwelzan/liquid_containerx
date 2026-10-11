import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassPresets', () {
    test('Contains at least 16 unique presets in values map', () {
      expect(LiquidGlassPresets.values.length, greaterThanOrEqualTo(16));
    });

    test('All 16 specified presets exist and have valid settings', () {
      const requiredKeys = [
        'iosMaps',
        'controlCenter',
        'clearGlass',
        'frostedWhite',
        'darkGlass',
        'tintedBlue',
        'tintedPink',
        'aurora',
        'crystal',
        'neonEdge',
        'soapBubble',
        'minimalPill',
        'frostedDark',
        'softSilver',
        'warmAmber',
        'liquidChrome',
      ];

      for (final key in requiredKeys) {
        expect(
          LiquidGlassPresets.values.containsKey(key),
          isTrue,
          reason: 'Preset $key must be declared in LiquidGlassPresets.values',
        );

        final preset = LiquidGlassPresets.values[key]!;
        expect(preset.blur, greaterThanOrEqualTo(0.0));
        expect(preset.refractionStrength, inInclusiveRange(0.0, 1.0));
        expect(preset.specularIntensity, inInclusiveRange(0.0, 1.0));
        expect(preset.tintOpacity, inInclusiveRange(0.0, 1.0));
      }
    });

    test('Individual static constants match their map entries', () {
      expect(
        LiquidGlassPresets.iosMaps,
        equals(LiquidGlassPresets.values['iosMaps']),
      );
      expect(
        LiquidGlassPresets.controlCenter,
        equals(LiquidGlassPresets.values['controlCenter']),
      );
      expect(
        LiquidGlassPresets.crystal,
        equals(LiquidGlassPresets.values['crystal']),
      );
      expect(
        LiquidGlassPresets.aurora,
        equals(LiquidGlassPresets.values['aurora']),
      );
    });
  });
}
