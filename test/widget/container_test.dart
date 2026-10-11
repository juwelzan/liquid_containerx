import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassContainer Widget', () {
    testWidgets('Renders child widget and respects sizing constraints', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              width: 150,
              height: 100,
              padding: EdgeInsets.all(12),
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      final size = tester.getSize(find.byType(LiquidGlassContainer));
      expect(size.width, equals(150.0));
      expect(size.height, equals(100.0));
    });

    testWidgets('Taps trigger onTap callback when interactive', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              interactive: true,
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('Controller dynamically updates settings without errors', (
      tester,
    ) async {
      final controller = LiquidGlassController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              controller: controller,
              child: const Text('Dynamic Glass'),
            ),
          ),
        ),
      );

      controller.updateSettings(LiquidGlassPresets.crystal);
      await tester.pump();
      expect(find.text('Dynamic Glass'), findsOneWidget);

      controller.setTouch(const Offset(0.4, 0.4), 0.8);
      await tester.pump();
      controller.dispose();
    });
  });
}
