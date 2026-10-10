import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_containerx/liquid_containerx.dart';

void main() {
  testWidgets('LiquidContainer mounts and unmounts with shaders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidContainer(
            glass: const LiquidGlass(enableShaders: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Unmount
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    
    expect(find.byType(LiquidContainer), findsNothing);
  });

  testWidgets('LiquidContainer falls back to baseline when shaders disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidContainer(
            glass: const LiquidGlass(enableShaders: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    expect(find.byType(LiquidContainer), findsOneWidget);
  });
}
