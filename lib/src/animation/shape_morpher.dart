import 'dart:ui';
import '../shapes/liquid_shape.dart';
import '../shapes/liquid_path_builder.dart';

class ShapeMorpher {
  /// Safely interpolate between two LiquidShapes if they are compatible.
  /// If incompatible, crossfades or falls back.
  static Path morph(LiquidShape a, LiquidShape b, double t, Size size, Offset dragOffset) {
    if (a.type == LiquidShapeType.custom || b.type == LiquidShapeType.custom ||
        a.type == LiquidShapeType.blob || b.type == LiquidShapeType.blob) {
      // Incompatible topologies (blob vs rounded rect, custom vs anything).
      // Fallback: just return 'a' until halfway, then 'b'. Real crossfade is better done via widgets or canvas opacity, 
      // but for path morph we just step.
      return t < 0.5 ? LiquidPathBuilder.buildPath(a, size, dragOffset) 
                     : LiquidPathBuilder.buildPath(b, size, dragOffset);
    }
    
    // For standard rounded rectangles/circles/pills/squircles, we can interpolate their bounding boxes and radii.
    final rect = Offset.zero & size;
    final shiftedRect = rect.shift(dragOffset * 0.2);

    final radiusA = _getRadiusForInterpolation(a, size);
    final radiusB = _getRadiusForInterpolation(b, size);

    final interpolatedRadius = Radius.lerp(radiusA, radiusB, t) ?? Radius.zero;
    
    final rRect = RRect.fromRectAndCorners(
      shiftedRect,
      topLeft: interpolatedRadius,
      topRight: interpolatedRadius,
      bottomLeft: interpolatedRadius,
      bottomRight: interpolatedRadius,
    );

    return Path()..addRRect(rRect);
  }

  static Radius _getRadiusForInterpolation(LiquidShape shape, Size size) {
    switch (shape.type) {
      case LiquidShapeType.rectangle:
        return Radius.zero;
      case LiquidShapeType.circle:
        return Radius.circular(size.width / 2);
      case LiquidShapeType.pill:
        return Radius.circular(size.height / 2);
      case LiquidShapeType.roundedRectangle:
      case LiquidShapeType.squircle:
        if (shape.borderRadius != null) {
          return shape.borderRadius!.resolve(TextDirection.ltr).topLeft;
        }
        return Radius.zero;
      default:
        return Radius.zero;
    }
  }
}
