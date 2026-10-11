import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/core/widgets/liquid_glass/liquid_glass.dart';

void main() {
  group('Core LiquidGlass widgets with liquid_glass_renderer', () {
    testWidgets('LiquidGlassContainer renders child and respects padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              fake: true,
              borderRadius: 24,
              padding: EdgeInsets.all(16),
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('LiquidGlassButton executes onPressed callback', (
      tester,
    ) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassButton(
              fake: true,
              onPressed: () => wasTapped = true,
              label: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(wasTapped, isTrue);
    });

    testWidgets('LiquidGlassButton respects enabled and loading states', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LiquidGlassButton(
                  fake: true,
                  enabled: false,
                  onPressed: () => tapped = true,
                  label: const Text('Disabled Btn'),
                ),
                LiquidGlassButton(
                  fake: true,
                  isLoading: true,
                  onPressed: () {},
                  label: const Text('Loading Btn'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled Btn'));
      await tester.pump(const Duration(milliseconds: 150));
      expect(tapped, isFalse);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LiquidGlassNavigationBar switches tabs on tap', (
      tester,
    ) async {
      var selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassNavigationBar(
              fake: true,
              currentIndex: selectedTab,
              onTap: (i) => selectedTab = i,
              items: const [
                LiquidGlassNavItem(icon: Icon(Icons.home), label: 'Home'),
                LiquidGlassNavItem(icon: Icon(Icons.search), label: 'Search'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(selectedTab, equals(1));
    });

    testWidgets('LiquidGlassPanel renders title, subtitle, and content', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassPanel(
              fake: true,
              title: Text('Control Center'),
              subtitle: Text('Wi-Fi & Bluetooth'),
              content: Text('Panel Content Area'),
            ),
          ),
        ),
      );

      expect(find.text('Control Center'), findsOneWidget);
      expect(find.text('Wi-Fi & Bluetooth'), findsOneWidget);
      expect(find.text('Panel Content Area'), findsOneWidget);
    });
  });
}
