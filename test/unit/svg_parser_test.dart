import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  group('SvgPathParser', () {
    test('Parses standard Move, Line, and Close commands', () {
      const svg = 'M 10 10 L 90 10 L 90 90 L 10 90 Z';
      final path = SvgPathParser.parse(svg);
      expect(path.getBounds().isEmpty, isFalse);
      expect(path.getBounds().width, closeTo(80.0, 0.01));
      expect(path.getBounds().height, closeTo(80.0, 0.01));
    });

    test('Parses Cubic bezier commands (C and c)', () {
      const svg = 'M 0 0 C 10 20, 30 40, 50 50 c 10 10, 20 20, 30 30';
      final path = SvgPathParser.parse(svg);
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('Scales and fits into requested bounds', () {
      const svg = 'M 0 0 L 10 0 L 10 10 L 0 10 Z';
      const targetSize = Size(100, 100);
      final path = SvgPathParser.parse(svg, fitSize: targetSize);
      expect(path.getBounds().width, closeTo(100.0, 0.01));
      expect(path.getBounds().height, closeTo(100.0, 0.01));
    });

    test(
      'Handles malformed or corrupted SVG strings gracefully without crashing',
      () {
        expect(
          () => SvgPathParser.parse('INVALID STRING 123 %%%'),
          returnsNormally,
        );
        expect(() => SvgPathParser.parse(''), returnsNormally);
        expect(() => SvgPathParser.parse('M 10'), returnsNormally);
        expect(() => SvgPathParser.parse('C 10 20 30'), returnsNormally);
      },
    );
  });
}
