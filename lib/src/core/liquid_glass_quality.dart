import 'package:flutter/foundation.dart';

/// Defines the rendering fidelity and performance profile of liquid glass elements.
///
/// Choosing the right quality level balances visual richness (such as shader
/// refraction, chromatic dispersion, and high-sample blurs) against GPU/CPU
/// frame time budgets (16.67 ms at 60 Hz, 8.33 ms at 120 Hz).
enum LiquidGlassQuality {
  /// Minimal computational overhead.
  ///
  /// Uses reduced blur radius, disables chromatic aberration, simplifies
  /// specular reflections, and falls back to pure canvas shaders or box
  /// decorations on constrained devices.
  low,

  /// Balanced fidelity and performance.
  ///
  /// Suitable for mid-tier devices and standard scrolling views. Enables
  /// balanced blur, subtle refraction lensing, and standard highlights.
  medium,

  /// Maximum visual realism.
  ///
  /// Enables full GLSL fragment shader passes, multi-point specular highlights,
  /// chromatic aberration dispersion, dynamic touch glints, and noise dithering.
  high,

  /// Dynamically determines the optimal quality based on platform capabilities,
  /// accessibility settings (e.g., reduced transparency), and runtime environment.
  auto,
}

/// Extension providing capability queries and fallback resolution for [LiquidGlassQuality].
extension LiquidGlassQualityExtension on LiquidGlassQuality {
  /// Resolves this quality level to a concrete [LiquidGlassQuality.low],
  /// [LiquidGlassQuality.medium], or [LiquidGlassQuality.high].
  LiquidGlassQuality resolve({
    bool isLowPower = false,
    bool reduceTransparency = false,
  }) {
    if (reduceTransparency) {
      return LiquidGlassQuality.low;
    }

    if (this != LiquidGlassQuality.auto) {
      return this;
    }

    if (isLowPower) {
      return LiquidGlassQuality.low;
    }

    // Web in HTML renderer or debug mode on older hardware defaults to medium
    if (kIsWeb) {
      return LiquidGlassQuality.medium;
    }

    // Default auto policy on desktop and modern mobile devices
    return LiquidGlassQuality.high;
  }

  /// Whether chromatic aberration calculations should execute.
  bool get supportsChromaticAberration => this == LiquidGlassQuality.high;

  /// Whether procedural noise dithering should execute.
  bool get supportsNoiseDithering =>
      this == LiquidGlassQuality.high || this == LiquidGlassQuality.medium;

  /// Numeric shader quality uniform value:
  /// - `0.0` for low
  /// - `1.0` for medium
  /// - `2.0` for high
  double get shaderUniformValue {
    switch (this) {
      case LiquidGlassQuality.low:
        return 0.0;
      case LiquidGlassQuality.medium:
        return 1.0;
      case LiquidGlassQuality.high:
      case LiquidGlassQuality.auto:
        return 2.0;
    }
  }
}

