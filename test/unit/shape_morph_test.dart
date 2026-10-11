import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidShapeMorph', () {
    const size = Size(100, 100);
    const shapeA = LiquidGlassShape.squircle(cornerRadius: 24);
    const shapeB = LiquidGlassShape.circle();

    test('At t=0 returns path for shapeA', () {
      final morphed = LiquidShapeMorph.morphShapes(shapeA, shapeB, size, 0.0);
      expect(morphed.getBounds().isEmpty, isFalse);
    });

    test('At t=1 returns path for shapeB', () {
      final morphed = LiquidShapeMorph.morphShapes(shapeA, shapeB, size, 1.0);
      expect(morphed.getBounds().isEmpty, isFalse);
    });

    test('At intermediate t interpolates smoothly without throwing', () {
      for (var t = 0.1; t < 1.0; t += 0.2) {
        final morphed = LiquidShapeMorph.morphShapes(shapeA, shapeB, size, t);
        expect(morphed.getBounds().isEmpty, isFalse);
      }
    });

    test('samplePath extracts correct number of vertices', () {
      final path = shapeA.buildPath(size);
      final samples = LiquidShapeMorph.samplePath(path, sampleCount: 50);
      expect(samples.length, equals(50));
    });
  });
}

