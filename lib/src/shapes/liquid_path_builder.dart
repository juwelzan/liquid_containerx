import 'dart:ui';
import 'package:flutter/painting.dart';
import 'liquid_shape.dart';

class LiquidPathBuilder {
  static Path buildPath(LiquidShape shape, Size size, Offset dragOffset) {
    if (shape.type == LiquidShapeType.custom && shape.customPathBuilder != null) {
      final path = shape.customPathBuilder!(size);
      if (dragOffset != Offset.zero) {
        return path.shift(dragOffset * 0.2); // slight shift based on drag
      }
      return path;
    }

    final rect = Offset.zero & size;
    final shiftedRect = rect.shift(dragOffset * 0.2);

    final radius = _getRadius(shape, size);
    final rRect = RRect.fromRectAndCorners(
      shiftedRect,
      topLeft: radius,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
    );

    switch (shape.type) {
      case LiquidShapeType.rectangle:
        return Path()..addRect(shiftedRect);
      case LiquidShapeType.roundedRectangle:
        return Path()..addRRect(rRect);
      case LiquidShapeType.circle:
        return Path()..addOval(shiftedRect);
      case LiquidShapeType.pill:
        return Path()..addRRect(RRect.fromRectAndRadius(shiftedRect, Radius.circular(size.height / 2)));
      case LiquidShapeType.squircle:
        // Approximating squircle
        return Path()..addRRect(rRect);
      case LiquidShapeType.blob:
        // Approximating a blob with shift
        final path = Path();
        final center = shiftedRect.center;
                path.moveTo(center.dx, shiftedRect.top);
        path.quadraticBezierTo(shiftedRect.right, shiftedRect.top, shiftedRect.right, center.dy);
        path.quadraticBezierTo(shiftedRect.right, shiftedRect.bottom, center.dx, shiftedRect.bottom);
        path.quadraticBezierTo(shiftedRect.left, shiftedRect.bottom, shiftedRect.left, center.dy);
        path.quadraticBezierTo(shiftedRect.left, shiftedRect.top, center.dx, shiftedRect.top);
        return path;
      default:
        return Path()..addRect(shiftedRect);
    }
  }

  static Radius _getRadius(LiquidShape shape, Size size) {
    if (shape.borderRadius != null) {
      return shape.borderRadius!.resolve(TextDirection.ltr).topLeft;
    }
    return const Radius.circular(0);
  }
}
