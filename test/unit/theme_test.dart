import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassThemeData', () {
    test('light and dark factories produce valid themes', () {
      final light = LiquidGlassThemeData.light();
      final dark = LiquidGlassThemeData.dark();

      expect(light.settings, equals(LiquidGlassPresets.iosMaps));
      expect(dark.settings, equals(LiquidGlassPresets.darkGlass));
    });

    test('copyWith updates specified properties', () {
      final original = LiquidGlassThemeData.light();
      final updated = original.copyWith(
        quality: LiquidGlassQuality.low,
        enableHaptics: false,
      );

      expect(updated.quality, equals(LiquidGlassQuality.low));
      expect(updated.enableHaptics, isFalse);
      expect(updated.settings, equals(original.settings));
    });

    test('lerp smoothly interpolates theme data', () {
      final a = LiquidGlassThemeData.light();
      final b = LiquidGlassThemeData.dark();
      final half = LiquidGlassThemeData.lerp(a, b, 0.5);

      expect(
        half.settings.blur,
        closeTo((a.settings.blur + b.settings.blur) / 2, 0.01),
      );
    });

    testWidgets(
      'LiquidGlassTheme provides data to context and derives default brightness',
      (tester) async {
        late LiquidGlassThemeData retrieved;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                retrieved = LiquidGlassTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // In dark theme without explicit LiquidGlassTheme, derives dark theme
        expect(
          retrieved.settings.tintColor,
          equals(LiquidGlassPresets.darkGlass.tintColor),
        );
      },
    );
  });
}
