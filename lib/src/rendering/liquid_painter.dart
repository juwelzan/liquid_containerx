import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../shapes/liquid_shape.dart';
import '../core/liquid_theme.dart';

class LiquidPainter extends CustomPainter {
  final LiquidShape shape;
  final LiquidGlass glass;
  final Offset dragOffset;

  LiquidPainter({
    required this.shape,
    required this.glass,
    required this.dragOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = _buildPath(size);
    
    // Draw base glass tint
    final paint = Paint()
      ..color = glass.tintColor.withOpacity(glass.opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawPath(path, borderPaint);
  }

  Path _buildPath(Size size) {
    if (shape.type == LiquidShapeType.custom && shape.customPathBuilder != null) {
      return shape.customPathBuilder!(size);
    }

    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndCorners(
      rect,
      topLeft: _getRadius(shape, size),
      topRight: _getRadius(shape, size),
      bottomLeft: _getRadius(shape, size),
      bottomRight: _getRadius(shape, size),
    );

    switch (shape.type) {
      case LiquidShapeType.rectangle:
        return Path()..addRect(rect);
      case LiquidShapeType.roundedRectangle:
        return Path()..addRRect(rRect);
      case LiquidShapeType.circle:
        return Path()..addOval(rect);
      case LiquidShapeType.pill:
        return Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)));
      case LiquidShapeType.squircle:
        // Approximating squircle for now
        return Path()..addRRect(rRect);
      case LiquidShapeType.blob:
        // Approximating a blob
        final path = Path();
        path.moveTo(size.width * 0.5, 0);
        path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.5);
        path.quadraticBezierTo(size.width, size.height, size.width * 0.5, size.height);
        path.quadraticBezierTo(0, size.height, 0, size.height * 0.5);
        path.quadraticBezierTo(0, 0, size.width * 0.5, 0);
        return path;
      default:
        return Path()..addRect(rect);
    }
  }

  Radius _getRadius(LiquidShape shape, Size size) {
    if (shape.borderRadius != null) {
      return shape.borderRadius!.resolve(TextDirection.ltr).topLeft;
    }
    return const Radius.circular(0);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    return shape != oldDelegate.shape ||
           glass != oldDelegate.glass ||
           dragOffset != oldDelegate.dragOffset;
  }
}
