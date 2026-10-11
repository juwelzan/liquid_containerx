import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassSlider and LiquidGlassSwitch Widgets', () {
    testWidgets('LiquidGlassSwitch toggles state on tap', (tester) async {
      var switchedValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LiquidGlassSwitch(
                  value: switchedValue,
                  onChanged: (v) => setState(() => switchedValue = v),
                );
              },
            ),
          ),
        ),
      );

      expect(switchedValue, isFalse);
      await tester.tap(find.byType(LiquidGlassSwitch));
      await tester.pumpAndSettle();
      expect(switchedValue, isTrue);
    });

    testWidgets('LiquidGlassSlider responds to drag gestures', (tester) async {
      var sliderValue = 0.2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return LiquidGlassSlider(
                      value: sliderValue,
                      onChanged: (v) => setState(() => sliderValue = v),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final sliderFinder = find.byType(LiquidGlassSlider);
      await tester.drag(sliderFinder, const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(sliderValue, greaterThan(0.2));
    });
  });
}

