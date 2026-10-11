import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'liquid_glass_quality.dart';

/// An immutable configuration defining the optical and physical appearance
/// of a liquid glass surface.
///
/// Encapsulates blur, refractive distortion, rim lighting, specular shine,
/// tinting, borders, and depth shadows.
@immutable
class LiquidGlassSettings {
  /// Creates a [LiquidGlassSettings] configuration with verified numeric ranges.
  const LiquidGlassSettings({
    this.blur = 20.0,
    this.refractionStrength = 0.3,
    this.thickness = 12.0,
    this.lightAngle = 0.785398, // 45 degrees in radians
    this.specularIntensity = 0.45,
    this.saturation = 1.2,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.15,
    this.borderWidth = 1.0,
    this.borderGradient,
    this.innerGlow = 0.25,
    this.shadowBlur = 16.0,
    this.shadowColor = const Color(0x33000000),
    this.cornerSmoothing = 0.7,
    this.chromaticAberration = 0.05,
    this.backgroundOpacity = 0.0,
    this.quality = LiquidGlassQuality.auto,
  }) : assert(blur >= 0.0, 'blur must be non-negative'),
       assert(
         refractionStrength >= 0.0 && refractionStrength <= 1.0,
         'refractionStrength must be between 0.0 and 1.0',
       ),
       assert(thickness >= 0.0, 'thickness must be non-negative'),
       assert(
         specularIntensity >= 0.0 && specularIntensity <= 1.0,
         'specularIntensity must be between 0.0 and 1.0',
       ),
       assert(saturation >= 0.0, 'saturation must be non-negative'),
       assert(
         tintOpacity >= 0.0 && tintOpacity <= 1.0,
         'tintOpacity must be between 0.0 and 1.0',
       ),
       assert(borderWidth >= 0.0, 'borderWidth must be non-negative'),
       assert(
         innerGlow >= 0.0 && innerGlow <= 1.0,
         'innerGlow must be between 0.0 and 1.0',
       ),
       assert(shadowBlur >= 0.0, 'shadowBlur must be non-negative'),
       assert(
         cornerSmoothing >= 0.0 && cornerSmoothing <= 1.0,
         'cornerSmoothing must be between 0.0 and 1.0',
       ),
       assert(
         chromaticAberration >= 0.0 && chromaticAberration <= 1.0,
         'chromaticAberration must be between 0.0 and 1.0',
       ),
       assert(
         backgroundOpacity >= 0.0 && backgroundOpacity <= 1.0,
         'backgroundOpacity must be between 0.0 and 1.0',
       );

  /// Standard baseline settings for iOS-inspired glass cards and containers.
  static const LiquidGlassSettings standard = LiquidGlassSettings();

  /// High-transparency clear glass configuration.
  static const LiquidGlassSettings clear = LiquidGlassSettings(
    blur: 16.0,
    refractionStrength: 0.4,
    thickness: 10.0,
    specularIntensity: 0.6,
    tintOpacity: 0.08,
    borderWidth: 1.0,
    innerGlow: 0.35,
    chromaticAberration: 0.08,
  );

  /// Highly diffused frosted white surface.
  static const LiquidGlassSettings frosted = LiquidGlassSettings(
    blur: 30.0,
    refractionStrength: 0.15,
    thickness: 16.0,
    specularIntensity: 0.3,
    tintOpacity: 0.28,
    borderWidth: 1.2,
    innerGlow: 0.2,
    shadowBlur: 20.0,
  );

  /// Background blur radius in logical pixels.
  final double blur;

  /// Simulated optical refractive strength (0.0 to 1.0).
  final double refractionStrength;

  /// Apparent glass lens thickness.
  final double thickness;

  /// Incident light angle in radians (e.g., `0.785` for top-left light source).
  final double lightAngle;

  /// Directional specular highlight brightness (0.0 to 1.0).
  final double specularIntensity;

  /// Saturation boost multiplier applied to background colors.
  final double saturation;

  /// Surface tint color.
  final Color tintColor;

  /// Opacity multiplier for the tint color (0.0 to 1.0).
  final double tintOpacity;

  /// Perimeter border stroke thickness in logical pixels.
  final double borderWidth;

  /// Optional gradient for the outer glass rim border.
  final Gradient? borderGradient;

  /// Fresnel rim inner glow intensity (0.0 to 1.0).
  final double innerGlow;

  /// Ambient shadow diffusion blur.
  final double shadowBlur;

  /// Ambient drop shadow color.
  final Color shadowColor;

  /// Squircle corner curvature continuous smoothing (0.0 = classic arc, 1.0 = superellipse).
  final double cornerSmoothing;

  /// Optical dispersion splitting red and blue highlights (0.0 to 1.0).
  final double chromaticAberration;

  /// Additional opaque backing layer opacity (0.0 = fully translucent).
  final double backgroundOpacity;

  /// The rendering quality level for this container.
  final LiquidGlassQuality quality;

  /// Effective tint color combined with its tint opacity.
  Color get effectiveTintColor =>
      tintColor.withValues(alpha: tintColor.a * tintOpacity);

  /// Returns a copy of these settings with specified fields replaced.
  LiquidGlassSettings copyWith({
    double? blur,
    double? refractionStrength,
    double? thickness,
    double? lightAngle,
    double? specularIntensity,
    double? saturation,
    Color? tintColor,
    double? tintOpacity,
    double? borderWidth,
    Gradient? borderGradient,
    double? innerGlow,
    double? shadowBlur,
    Color? shadowColor,
    double? cornerSmoothing,
    double? chromaticAberration,
    double? backgroundOpacity,
    LiquidGlassQuality? quality,
  }) {
    return LiquidGlassSettings(
      blur: blur ?? this.blur,
      refractionStrength: refractionStrength ?? this.refractionStrength,
      thickness: thickness ?? this.thickness,
      lightAngle: lightAngle ?? this.lightAngle,
      specularIntensity: specularIntensity ?? this.specularIntensity,
      saturation: saturation ?? this.saturation,
      tintColor: tintColor ?? this.tintColor,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      borderWidth: borderWidth ?? this.borderWidth,
      borderGradient: borderGradient ?? this.borderGradient,
      innerGlow: innerGlow ?? this.innerGlow,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowColor: shadowColor ?? this.shadowColor,
      cornerSmoothing: cornerSmoothing ?? this.cornerSmoothing,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      quality: quality ?? this.quality,
    );
  }

  /// Linearly interpolates between two [LiquidGlassSettings] objects.
  static LiquidGlassSettings lerp(
    LiquidGlassSettings? a,
    LiquidGlassSettings? b,
    double t,
  ) {
    if (identical(a, b) && a != null) return a;
    final fallback = const LiquidGlassSettings();
    final start = a ?? fallback;
    final end = b ?? fallback;

    return LiquidGlassSettings(
      blur: lerpDouble(start.blur, end.blur, t) ?? start.blur,
      refractionStrength:
          lerpDouble(start.refractionStrength, end.refractionStrength, t) ??
          start.refractionStrength,
      thickness:
          lerpDouble(start.thickness, end.thickness, t) ?? start.thickness,
      lightAngle:
          lerpDouble(start.lightAngle, end.lightAngle, t) ?? start.lightAngle,
      specularIntensity:
          lerpDouble(start.specularIntensity, end.specularIntensity, t) ??
          start.specularIntensity,
      saturation:
          lerpDouble(start.saturation, end.saturation, t) ?? start.saturation,
      tintColor:
          Color.lerp(start.tintColor, end.tintColor, t) ?? start.tintColor,
      tintOpacity:
          lerpDouble(start.tintOpacity, end.tintOpacity, t) ??
          start.tintOpacity,
      borderWidth:
          lerpDouble(start.borderWidth, end.borderWidth, t) ??
          start.borderWidth,
      borderGradient: Gradient.lerp(
        start.borderGradient,
        end.borderGradient,
        t,
      ),
      innerGlow:
          lerpDouble(start.innerGlow, end.innerGlow, t) ?? start.innerGlow,
      shadowBlur:
          lerpDouble(start.shadowBlur, end.shadowBlur, t) ?? start.shadowBlur,
      shadowColor:
          Color.lerp(start.shadowColor, end.shadowColor, t) ??
          start.shadowColor,
      cornerSmoothing:
          lerpDouble(start.cornerSmoothing, end.cornerSmoothing, t) ??
          start.cornerSmoothing,
      chromaticAberration:
          lerpDouble(start.chromaticAberration, end.chromaticAberration, t) ??
          start.chromaticAberration,
      backgroundOpacity:
          lerpDouble(start.backgroundOpacity, end.backgroundOpacity, t) ??
          start.backgroundOpacity,
      quality: t < 0.5 ? start.quality : end.quality,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidGlassSettings &&
          runtimeType == other.runtimeType &&
          blur == other.blur &&
          refractionStrength == other.refractionStrength &&
          thickness == other.thickness &&
          lightAngle == other.lightAngle &&
          specularIntensity == other.specularIntensity &&
          saturation == other.saturation &&
          tintColor == other.tintColor &&
          tintOpacity == other.tintOpacity &&
          borderWidth == other.borderWidth &&
          borderGradient == other.borderGradient &&
          innerGlow == other.innerGlow &&
          shadowBlur == other.shadowBlur &&
          shadowColor == other.shadowColor &&
          cornerSmoothing == other.cornerSmoothing &&
          chromaticAberration == other.chromaticAberration &&
          backgroundOpacity == other.backgroundOpacity &&
          quality == other.quality;

  @override
  int get hashCode => Object.hash(
    blur,
    refractionStrength,
    thickness,
    lightAngle,
    specularIntensity,
    saturation,
    tintColor,
    tintOpacity,
    borderWidth,
    borderGradient,
    innerGlow,
    shadowBlur,
    shadowColor,
    cornerSmoothing,
    chromaticAberration,
    backgroundOpacity,
    quality,
  );

  @override
  String toString() =>
      'LiquidGlassSettings(blur: $blur, refractionStrength: $refractionStrength, '
      'thickness: $thickness, specular: $specularIntensity, quality: $quality)';
}
