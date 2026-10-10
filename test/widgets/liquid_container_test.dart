import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_containerx/liquid_containerx.dart';

void main() {
  testWidgets('LiquidContainer renders and handles basic configuration', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidContainer(
            width: 100,
            height: 100,
            shape: LiquidShape.circle,
            child: const Text('Liquid'),
          ),
        ),
      ),
    );

    expect(find.text('Liquid'), findsOneWidget);
    expect(find.byType(LiquidContainer), findsOneWidget);
  });
}
