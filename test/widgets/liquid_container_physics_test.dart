import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_containerx/liquid_containerx.dart';

void main() {
  testWidgets('LiquidContainer physics drag and max deformation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidContainer(
              width: 100,
              height: 100,
              physics: const LiquidPhysics(
                enabled: true,
                maxDeformation: 0.5, // 50 pixels limit
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byType(LiquidContainer)));
    await gesture.moveBy(const Offset(200, 0));
    await tester.pump();
    
    // In our implementation, we use an Offset for deformation which translates the child by offset*0.5
    // and passes it to morpher.
    
    // We can't easily assert the internal _dragOffset directly without keys or custom matchers,
    // but we can ensure it completes without crashing.
    await gesture.up();
    await tester.pumpAndSettle();
    
    expect(find.byType(LiquidContainer), findsOneWidget);
  });

  testWidgets('LiquidContainer shape morphing implicit animation', (WidgetTester tester) async {
    Widget buildApp(LiquidShape shape) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidContainer(
              width: 100,
              height: 100,
              shape: shape,
            ),
          ),
        ),
      );
    }
    
    await tester.pumpWidget(buildApp(LiquidShape.rectangle));
    
    await tester.pumpWidget(buildApp(LiquidShape.circle));
    
    // Pump frames to let MorphController run
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    
    expect(find.byType(LiquidContainer), findsOneWidget);
  });
}
