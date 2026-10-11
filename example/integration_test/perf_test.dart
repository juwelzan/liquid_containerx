import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Performance test for baseline vs shader', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Trace the dragging interaction
    await binding.traceAction(() async {
      // Find the first LiquidContainer
      final container = find.byType(GestureDetector).first;

      // Perform a drag
      final gesture = await tester.startGesture(tester.getCenter(container));
      for (int i = 0; i < 20; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      // Let spring settle
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }, reportKey: 'liquid_drag_timeline');
  });
}
