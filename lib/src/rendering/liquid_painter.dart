import 'package:flutter/widgets.dart';
import 'dart:ui';
import '../shapes/liquid_shape.dart';
import '../animation/shape_morpher.dart';
import '../core/liquid_theme.dart';

class LiquidPainter extends CustomPainter {
  final LiquidShape shapeA;
  final LiquidShape shapeB;
  final double t;
  final LiquidGlass glass;
  final Offset dragOffset;
  final FragmentShader? shader;

  LiquidPainter({
    required this.shapeA,
    required this.shapeB,
    required this.t,
    required this.glass,
    required this.dragOffset,
    this.shader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = ShapeMorpher.morph(shapeA, shapeB, t, size, dragOffset);
    
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    if (shader != null && glass.enableShaders) {
      // Set uniforms for our liquid_glass.frag
      shader!.setFloat(0, size.width);
      shader!.setFloat(1, size.height);
      shader!.setFloat(2, glass.distortionStrength);
      shader!.setFloat(3, glass.highlightIntensity);
      shader!.setFloat(4, glass.tintColor.r);
      shader!.setFloat(5, glass.tintColor.g);
      shader!.setFloat(6, glass.tintColor.b);
      shader!.setFloat(7, glass.tintColor.a);
      
      paint.shader = shader;
    } else {
      paint.color = glass.tintColor.withValues(alpha: glass.opacity);
    }
    
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
           dragOffset != oldDelegate.dragOffset ||
           shader != oldDelegate.shader;
  }
}
