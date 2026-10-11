import 'package:flutter/material.dart';

import 'liquid_glass_path.dart';
import 'svg_path_parser.dart';

/// The shape category used by shaders and renderers.
enum LiquidShapeKind {
  roundedRectangle,
  squircle,
  circle,
  capsule,
  oval,
  star,
  heart,
  hexagon,
  blob,
  custom,
  svgPath,
}

/// An immutable definition of a geometric shape for liquid glass containers.
///
/// Encapsulates path generation, shape clipping, accurate point hit testing,
/// and shader shape uniforms.
@immutable
class LiquidGlassShape {
  const LiquidGlassShape._({
    required this.kind,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.cornerRadius = 28.0,
    this.cornerSmoothing = 0.72,
    this.points = 5,
    this.innerRadiusRatio = 0.48,
    this.wobble = 0.12,
    this.phase = 0.0,
    this.svgPathData,
    this.customPathBuilder,
  });

  /// A standard rounded rectangle with configurable [borderRadius].
  const LiquidGlassShape.roundedRectangle({
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(24)),
  }) : this._(
         kind: LiquidShapeKind.roundedRectangle,
         borderRadius: borderRadius,
       );

  /// An iOS-inspired squircle with continuous curvature smoothing.
  const LiquidGlassShape.squircle({
    double cornerRadius = 28.0,
    double cornerSmoothing = 0.72,
  }) : this._(
         kind: LiquidShapeKind.squircle,
         cornerRadius: cornerRadius,
         cornerSmoothing: cornerSmoothing,
       );

  /// A circle centered within the bounds.
  const LiquidGlassShape.circle() : this._(kind: LiquidShapeKind.circle);

  /// A pill / capsule with rounded semicircular ends.
  const LiquidGlassShape.capsule() : this._(kind: LiquidShapeKind.capsule);

  /// Alias for [capsule].
  const LiquidGlassShape.pill() : this.capsule();

  /// An ellipse fitting the width and height.
  const LiquidGlassShape.oval() : this._(kind: LiquidShapeKind.oval);

  /// An n-pointed star.
  const LiquidGlassShape.star({int points = 5, double innerRadiusRatio = 0.48})
    : this._(
        kind: LiquidShapeKind.star,
        points: points,
        innerRadiusRatio: innerRadiusRatio,
      );

  /// A smooth mathematical heart.
  const LiquidGlassShape.heart() : this._(kind: LiquidShapeKind.heart);

  /// A regular hexagon with optional rounded corners.
  const LiquidGlassShape.hexagon({double cornerRadius = 6.0})
    : this._(kind: LiquidShapeKind.hexagon, cornerRadius: cornerRadius);

  /// An organic liquid blob with sinusoidal wobble.
  const LiquidGlassShape.blob({
    int points = 8,
    double wobble = 0.12,
    double phase = 0.0,
  }) : this._(
         kind: LiquidShapeKind.blob,
         points: points,
         wobble: wobble,
         phase: phase,
       );

  /// A custom shape evaluated via a user-supplied [pathBuilder].
  const LiquidGlassShape.custom({required Path Function(Size size) pathBuilder})
    : this._(kind: LiquidShapeKind.custom, customPathBuilder: pathBuilder);

  /// A shape parsed from an SVG path data string (`d` attribute).
  const LiquidGlassShape.svgPath(String svgPathData)
    : this._(kind: LiquidShapeKind.svgPath, svgPathData: svgPathData);

  /// The category classification of this shape.
  final LiquidShapeKind kind;

  /// Corner radii when [kind] is [LiquidShapeKind.roundedRectangle].
  final BorderRadius borderRadius;

  /// Corner radius when [kind] is [LiquidShapeKind.squircle] or [LiquidShapeKind.hexagon].
  final double cornerRadius;

  /// Superellipse smoothing factor (0.0 to 1.0).
  final double cornerSmoothing;

  /// Number of vertices or control points for stars and blobs.
  final int points;

  /// Ratio of inner vertex radius to outer vertex radius for stars.
  final double innerRadiusRatio;

  /// Amplitude of wave distortion for blobs.
  final double wobble;

  /// Phase shift for blob wave animations in radians.
  final double phase;

  /// Raw SVG path string when [kind] is [LiquidShapeKind.svgPath].
  final String? svgPathData;

  /// User-provided path callback when [kind] is [LiquidShapeKind.custom].
  final Path Function(Size size)? customPathBuilder;

  /// Generates the geometric [Path] matching this shape for the given [size].
  Path buildPath(Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return Path();
    }

    switch (kind) {
      case LiquidShapeKind.roundedRectangle:
        return LiquidGlassPathBuilder.buildRoundedRectangle(size, borderRadius);
      case LiquidShapeKind.squircle:
        return LiquidGlassPathBuilder.buildSquircle(
          size,
          cornerRadius: cornerRadius,
          cornerSmoothing: cornerSmoothing,
        );
      case LiquidShapeKind.circle:
        return LiquidGlassPathBuilder.buildCircle(size);
      case LiquidShapeKind.capsule:
        return LiquidGlassPathBuilder.buildCapsule(size);
      case LiquidShapeKind.oval:
        return LiquidGlassPathBuilder.buildOval(size);
      case LiquidShapeKind.star:
        return LiquidGlassPathBuilder.buildStar(
          size,
          points: points,
          innerRadiusRatio: innerRadiusRatio,
        );
      case LiquidShapeKind.heart:
        return LiquidGlassPathBuilder.buildHeart(size);
      case LiquidShapeKind.hexagon:
        return LiquidGlassPathBuilder.buildHexagon(
          size,
          cornerRadius: cornerRadius,
        );
      case LiquidShapeKind.blob:
        return LiquidGlassPathBuilder.buildBlob(
          size,
          points: points,
          wobble: wobble,
          phase: phase,
        );
      case LiquidShapeKind.custom:
        if (customPathBuilder != null) {
          return customPathBuilder!(size);
        }
        return Path()..addRect(Offset.zero & size);
      case LiquidShapeKind.svgPath:
        if (svgPathData != null && svgPathData!.isNotEmpty) {
          return SvgPathParser.parse(svgPathData!, fitSize: size);
        }
        return Path()..addRect(Offset.zero & size);
    }
  }

  /// Determines whether [point] lies inside this shape at [size].
  bool contains(Offset point, Size size) {
    if (point.dx < 0 ||
        point.dy < 0 ||
        point.dx > size.width ||
        point.dy > size.height) {
      return false;
    }
    final path = buildPath(size);
    return path.contains(point);
  }

  /// The shape category encoded as a shader uniform float.
  double get shaderShapeType {
    switch (kind) {
      case LiquidShapeKind.roundedRectangle:
      case LiquidShapeKind.squircle:
        return 0.0;
      case LiquidShapeKind.circle:
      case LiquidShapeKind.capsule:
      case LiquidShapeKind.oval:
        return 1.0;
      case LiquidShapeKind.star:
      case LiquidShapeKind.heart:
      case LiquidShapeKind.hexagon:
      case LiquidShapeKind.blob:
      case LiquidShapeKind.custom:
      case LiquidShapeKind.svgPath:
        return 2.0;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidGlassShape &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          borderRadius == other.borderRadius &&
          cornerRadius == other.cornerRadius &&
          cornerSmoothing == other.cornerSmoothing &&
          points == other.points &&
          innerRadiusRatio == other.innerRadiusRatio &&
          wobble == other.wobble &&
          phase == other.phase &&
          svgPathData == other.svgPathData;

  @override
  int get hashCode => Object.hash(
    kind,
    borderRadius,
    cornerRadius,
    cornerSmoothing,
    points,
    innerRadiusRatio,
    wobble,
    phase,
    svgPathData,
  );
}
