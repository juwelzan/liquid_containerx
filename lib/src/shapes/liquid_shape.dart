import 'package:flutter/painting.dart';

/// Defines the shape of a LiquidContainer.
enum LiquidShapeType {
  rectangle,
  roundedRectangle,
  circle,
  pill,
  squircle,
  blob,
  custom,
}

/// Configuration for a liquid shape.
class LiquidShape {
  final LiquidShapeType type;
  final BorderRadiusGeometry? borderRadius;
  final Path Function(Size size)? customPathBuilder;

  const LiquidShape({
    required this.type,
    this.borderRadius,
    this.customPathBuilder,
  });

  /// A standard rectangle.
  static const LiquidShape rectangle = LiquidShape(type: LiquidShapeType.rectangle);

  /// A rounded rectangle.
  static LiquidShape roundedRectangle(BorderRadiusGeometry radius) => LiquidShape(
        type: LiquidShapeType.roundedRectangle,
        borderRadius: radius,
      );

  /// A perfect circle.
  static const LiquidShape circle = LiquidShape(type: LiquidShapeType.circle);

  /// A pill shape (stadium).
  static const LiquidShape pill = LiquidShape(type: LiquidShapeType.pill);

  /// A squircle (smooth rounded rectangle).
  static LiquidShape squircle([BorderRadiusGeometry? radius]) => LiquidShape(
        type: LiquidShapeType.squircle,
        borderRadius: radius,
      );

  /// An organic blob.
  static const LiquidShape blob = LiquidShape(type: LiquidShapeType.blob);

  /// A custom path shape.
  static LiquidShape custom(Path Function(Size size) builder) => LiquidShape(
        type: LiquidShapeType.custom,
        customPathBuilder: builder,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidShape &&
        other.type == type &&
        other.borderRadius == borderRadius &&
        other.customPathBuilder == customPathBuilder;
  }

  @override
  int get hashCode => Object.hash(type, borderRadius, customPathBuilder);
}
