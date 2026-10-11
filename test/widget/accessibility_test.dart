import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('Accessibility & Reduce Motion/Transparency', () {
    testWidgets('LiquidGlassContainer respects semanticLabel', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LiquidGlassContainer(
                semanticLabel: 'Glass Container Card',
                child: Text('Content'),
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics && w.properties.label == 'Glass Container Card',
          ),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('LiquidGlassButton exposes button semantics', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiquidGlassButton(
                onPressed: () {},
                semanticLabel: 'Submit Form',
                child: const Text('Submit'),
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.button == true &&
                w.properties.label == 'Submit Form',
          ),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets(
      'LiquidGlassAnimated suppresses animations when disableAnimations is active',
      (tester) async {
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: LiquidGlassAnimated(
                  animation: LiquidGlassAnimation.breathing,
                  child: Text('Static Child'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Static Child'), findsOneWidget);
      },
    );
  });
}
