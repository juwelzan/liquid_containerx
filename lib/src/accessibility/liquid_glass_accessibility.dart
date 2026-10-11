import 'package:flutter/material.dart';

/// Utilities for accessibility, luminance calculation, dynamic contrast,
/// and adaptive foreground tinting.
abstract final class LiquidGlassAccessibility {
  /// Computes the relative luminance of a [Color] following WCAG 2.1 specs.
  static double computeLuminance(Color color) {
    return color.computeLuminance();
  }

  /// Determines whether foreground text and icons should be dark or light
  /// when placed over a glass surface with [backgroundColor] and [tintColor].
  static Color getContrastingForeground({
    Color? backgroundColor,
    required Color tintColor,
    double tintOpacity = 0.2,
  }) {
    final effectiveBg = backgroundColor ?? Colors.black;
    final blendedR =
        effectiveBg.r * (1.0 - tintOpacity) + tintColor.r * tintOpacity;
    final blendedG =
        effectiveBg.g * (1.0 - tintOpacity) + tintColor.g * tintOpacity;
    final blendedB =
        effectiveBg.b * (1.0 - tintOpacity) + tintColor.b * tintOpacity;
    final blended = Color.from(
      alpha: 1.0,
      red: blendedR,
      green: blendedG,
      blue: blendedB,
    );

    final luminance = blended.computeLuminance();
    return luminance > 0.45 ? Colors.black87 : Colors.white;
  }

  /// Evaluates whether the active environment requests reduced transparency.
  static bool shouldReduceTransparency(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return false;
    return mediaQuery.accessibleNavigation || mediaQuery.boldText;
  }

  /// Evaluates whether animations should be suppressed or settled instantly.
  static bool shouldReduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations ?? false;
  }
}
