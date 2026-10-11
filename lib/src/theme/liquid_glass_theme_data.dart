import 'package:flutter/material.dart';

import '../core/liquid_glass_quality.dart';
import '../core/liquid_glass_settings.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';

/// Immutable theme data defining default settings, shapes, and quality across an application.
@immutable
class LiquidGlassThemeData {
  const LiquidGlassThemeData({
    this.settings = LiquidGlassPresets.iosMaps,
    this.shape = const LiquidGlassShape.squircle(),
    this.quality = LiquidGlassQuality.auto,
    this.enableHaptics = true,
  });

  /// Light theme default configuration.
  factory LiquidGlassThemeData.light() {
    return const LiquidGlassThemeData(
      settings: LiquidGlassPresets.iosMaps,
      shape: LiquidGlassShape.squircle(),
      quality: LiquidGlassQuality.auto,
    );
  }

  /// Dark theme default configuration.
  factory LiquidGlassThemeData.dark() {
    return const LiquidGlassThemeData(
      settings: LiquidGlassPresets.darkGlass,
      shape: LiquidGlassShape.squircle(),
      quality: LiquidGlassQuality.auto,
    );
  }

  /// Theme inspired by iOS Maps cards and floating overlays.
  factory LiquidGlassThemeData.iosMaps() {
    return const LiquidGlassThemeData(
      settings: LiquidGlassPresets.iosMaps,
      shape: LiquidGlassShape.squircle(cornerRadius: 28.0),
    );
  }

  /// Default glass optical settings.
  final LiquidGlassSettings settings;

  /// Default container shape.
  final LiquidGlassShape shape;

  /// Global rendering quality policy.
  final LiquidGlassQuality quality;

  /// Whether tactile haptic feedback is globally enabled.
  final bool enableHaptics;

  /// Creates a copy of this theme data with the given fields replaced.
  LiquidGlassThemeData copyWith({
    LiquidGlassSettings? settings,
    LiquidGlassShape? shape,
    LiquidGlassQuality? quality,
    bool? enableHaptics,
  }) {
    return LiquidGlassThemeData(
      settings: settings ?? this.settings,
      shape: shape ?? this.shape,
      quality: quality ?? this.quality,
      enableHaptics: enableHaptics ?? this.enableHaptics,
    );
  }

  /// Linearly interpolates between two [LiquidGlassThemeData] instances.
  static LiquidGlassThemeData lerp(
    LiquidGlassThemeData? a,
    LiquidGlassThemeData? b,
    double t,
  ) {
    if (identical(a, b) && a != null) return a;
    final fallback = LiquidGlassThemeData.light();
    final start = a ?? fallback;
    final end = b ?? fallback;

    return LiquidGlassThemeData(
      settings: LiquidGlassSettings.lerp(start.settings, end.settings, t),
      shape: t < 0.5 ? start.shape : end.shape,
      quality: t < 0.5 ? start.quality : end.quality,
      enableHaptics: t < 0.5 ? start.enableHaptics : end.enableHaptics,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidGlassThemeData &&
          runtimeType == other.runtimeType &&
          settings == other.settings &&
          shape == other.shape &&
          quality == other.quality &&
          enableHaptics == other.enableHaptics;

  @override
  int get hashCode => Object.hash(settings, shape, quality, enableHaptics);
}

