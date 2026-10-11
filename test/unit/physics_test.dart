import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassPhysics', () {
    test('rubberBandDistance dampens displacement smoothly', () {
      final zero = LiquidGlassSpring.rubberBandDistance(0.0);
      expect(zero, equals(0.0));

      final resisted50 = LiquidGlassSpring.rubberBandDistance(
        50.0,
        maxDisplacement: 60.0,
      );
      expect(resisted50, lessThan(50.0));
      expect(resisted50, greaterThan(0.0));

      final resistedLarge = LiquidGlassSpring.rubberBandDistance(
        500.0,
        maxDisplacement: 60.0,
      );
      expect(resistedLarge, lessThan(60.0));
    });

    test('rubberBandOffset preserves direction with resisted magnitude', () {
      const raw = Offset(100.0, 100.0);
      final resisted = LiquidGlassSpring.rubberBandOffset(
        raw,
        maxDisplacement: 60.0,
      );

      expect(resisted.dx, greaterThan(0.0));
      expect(resisted.dy, greaterThan(0.0));
      expect(resisted.dx, equals(resisted.dy));
      expect(resisted.distance, lessThan(60.0));
    });

    test(
      'LiquidGlassHapticFeedback trigger executes without uncaught exceptions',
      () async {
        await expectLater(LiquidGlassHapticFeedback.none.trigger(), completes);
        await expectLater(LiquidGlassHapticFeedback.light.trigger(), completes);
        await expectLater(
          LiquidGlassHapticFeedback.medium.trigger(),
          completes,
        );
        await expectLater(
          LiquidGlassHapticFeedback.selection.trigger(),
          completes,
        );
      },
    );
  });
}
