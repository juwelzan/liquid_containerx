import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('LiquidGlassShape', () {
    const testSize = Size(100, 100);

    test('Rounded rectangle builds valid non-empty path', () {
      const shape = LiquidGlassShape.roundedRectangle(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );
      final path = shape.buildPath(testSize);
      expect(path.getBounds().isEmpty, isFalse);
      expect(shape.contains(const Offset(50, 50), testSize), isTrue);
      expect(shape.contains(const Offset(150, 50), testSize), isFalse);
    });

    test('Squircle builds continuous curve path', () {
      const shape = LiquidGlassShape.squircle(
        cornerRadius: 24,
        cornerSmoothing: 0.72,
      );
      final path = shape.buildPath(testSize);
      expect(path.getBounds().isEmpty, isFalse);
      expect(shape.contains(const Offset(50, 50), testSize), isTrue);
    });

    test('Circle builds circular bounds path', () {
      const shape = LiquidGlassShape.circle();
      final path = shape.buildPath(testSize);
      expect(path.getBounds().width, equals(100.0));
      expect(path.getBounds().height, equals(100.0));
      expect(shape.contains(const Offset(50, 50), testSize), isTrue);
      // Corner should NOT be inside circle
      expect(shape.contains(const Offset(2, 2), testSize), isFalse);
    });

    test('Capsule and pill build identical valid paths', () {
      const capsule = LiquidGlassShape.capsule();
      const pill = LiquidGlassShape.pill();
      expect(
        capsule.buildPath(testSize).getBounds(),
        equals(pill.buildPath(testSize).getBounds()),
      );
    });

    test('Star, heart, hexagon, blob build valid paths', () {
      const star = LiquidGlassShape.star(points: 5);
      const heart = LiquidGlassShape.heart();
      const hexagon = LiquidGlassShape.hexagon(cornerRadius: 4);
      const blob = LiquidGlassShape.blob(points: 6);

      expect(star.buildPath(testSize).getBounds().isEmpty, isFalse);
      expect(heart.buildPath(testSize).getBounds().isEmpty, isFalse);
      expect(hexagon.buildPath(testSize).getBounds().isEmpty, isFalse);
      expect(blob.buildPath(testSize).getBounds().isEmpty, isFalse);
    });

    test('Custom path builder generates expected path', () {
      final custom = LiquidGlassShape.custom(
        pathBuilder: (size) => Path()..addRect(Offset.zero & size),
      );
      final path = custom.buildPath(testSize);
      expect(path.getBounds(), equals(Offset.zero & testSize));
    });

    test('Empty size generates empty path gracefully', () {
      const shape = LiquidGlassShape.squircle();
      final path = shape.buildPath(Size.zero);
      expect(path.getBounds().isEmpty, isTrue);
    });

    test('shaderShapeType resolves properly', () {
      expect(const LiquidGlassShape.squircle().shaderShapeType, equals(0.0));
      expect(const LiquidGlassShape.circle().shaderShapeType, equals(1.0));
      expect(const LiquidGlassShape.star().shaderShapeType, equals(2.0));
    });
  });
}
