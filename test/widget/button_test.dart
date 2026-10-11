import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassButton Widget', () {
    testWidgets('Triggers onPressed callback when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassButton(
              onPressed: () => pressed = true,
              child: const Text('Action Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Action Button'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('Disabled button ignores taps', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassButton(
              isEnabled: false,
              onPressed: () => pressed = true,
              child: const Text('Disabled Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'));
      await tester.pumpAndSettle();
      expect(pressed, isFalse);
    });

    testWidgets('Loading button displays CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassButton(
              isLoading: true,
              onPressed: () {},
              child: const Text('Hidden Text'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Hidden Text'), findsNothing);
    });
  });
}
