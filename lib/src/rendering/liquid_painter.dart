import 'package:flutter/widgets.dart';
import '../shapes/liquid_shape.dart';
import '../animation/shape_morpher.dart';
import '../core/liquid_theme.dart';

class LiquidPainter extends CustomPainter {
  final LiquidShape shapeA;
  final LiquidShape shapeB;
  final double t;
  final LiquidGlass glass;
  final Offset dragOffset;

  LiquidPainter({
    required this.shapeA,
    required this.shapeB,
    required this.t,
    required this.glass,
    required this.dragOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = ShapeMorpher.morph(shapeA, shapeB, t, size, dragOffset);
    
    // Draw base glass tint
    final paint = Paint()
      ..color = glass.tintColor.withValues(alpha: glass.opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    return shapeA != oldDelegate.shapeA ||
           shapeB != oldDelegate.shapeB ||
           t != oldDelegate.t ||
           glass != oldDelegate.glass ||
           dragOffset != oldDelegate.dragOffset;
  }
}
