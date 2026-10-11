import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassAppBar and LiquidGlassBottomSheet Widgets', () {
    testWidgets('LiquidGlassAppBar renders title and actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: LiquidGlassAppBar(
              title: const Text('Glass Title'),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
              ],
            ),
            body: const Center(child: Text('Body')),
          ),
        ),
      );

      expect(find.text('Glass Title'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets(
      'LiquidGlassBottomSheet renders with drag handle and child content',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiquidGlassBottomSheet(
                showDragHandle: true,
                builder: (context, scroll) {
                  return ListView(
                    controller: scroll,
                    children: const [
                      Text('Sheet Content Item 1'),
                      Text('Sheet Content Item 2'),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Sheet Content Item 1'), findsOneWidget);
      },
    );
  });
}
