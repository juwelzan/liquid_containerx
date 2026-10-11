import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// Haptic feedback intensity triggered during liquid glass touch interactions.
enum LiquidGlassHapticFeedback {
  /// No haptic feedback.
  none,

  /// Gentle tactile feedback on touch down or selection.
  light,

  /// Noticeable tactile pop on spring snapping or activation.
  medium,

  /// Fine tick feedback on sliders or tab changes.
  selection,
}

/// Extension to trigger haptic feedback safely across all platforms.
extension LiquidGlassHapticFeedbackExtension on LiquidGlassHapticFeedback {
  /// Triggers the configured haptic vibration. Gracefully ignores platform errors.
  Future<void> trigger() async {
    try {
      switch (this) {
        case LiquidGlassHapticFeedback.none:
          break;
        case LiquidGlassHapticFeedback.light:
          await HapticFeedback.lightImpact();
          break;
        case LiquidGlassHapticFeedback.medium:
          await HapticFeedback.mediumImpact();
          break;
        case LiquidGlassHapticFeedback.selection:
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (_) {
      // Graceful fallback on desktop, web, or devices without vibration motors
    }
  }
}

/// Spring parameters for liquid elastic rebound.
class LiquidGlassSpring {
  const LiquidGlassSpring({
    this.mass = 1.0,
    this.stiffness = 300.0,
    this.damping = 22.0,
  });

  final double mass;
  final double stiffness;
  final double damping;

  /// Creates a [SpringDescription] for Flutter physics simulations.
  SpringDescription get description =>
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping);

  /// Computes a standard iOS rubber-band elastic displacement for [rawDisplacement]
  /// bounded by [maxDisplacement] with resistance coefficient [coefficient].
  static double rubberBandDistance(
    double rawDisplacement, {
    double maxDisplacement = 60.0,
    double coefficient = 0.55,
  }) {
    if (rawDisplacement.abs() < 0.001) return 0.0;
    final sign = rawDisplacement.sign;
    final absDist = rawDisplacement.abs();
    final resisted =
        (1.0 - (1.0 / ((absDist * coefficient / maxDisplacement) + 1.0))) *
        maxDisplacement;
    return sign * resisted;
  }

  /// Calculates 2D rubber-band displacement offset.
  static Offset rubberBandOffset(
    Offset rawOffset, {
    double maxDisplacement = 60.0,
    double coefficient = 0.55,
  }) {
    final distance = rawOffset.distance;
    if (distance <= 0.0) return Offset.zero;
    final resistedDist = rubberBandDistance(
      distance,
      maxDisplacement: maxDisplacement,
      coefficient: coefficient,
    );
    return rawOffset * (resistedDist / distance);
  }
}

/// Configuration for liquid merge / metaball blending between nearby glass elements.
class LiquidMergeConfig {
  const LiquidMergeConfig({
    this.proximityThreshold = 40.0,
    this.blendStrength = 0.5,
    this.enabled = false,
  });

  /// The pixel distance within which sibling glass elements begin to coalesce.
  final double proximityThreshold;

  /// Viscosity / blend curve strength (0.0 to 1.0).
  final double blendStrength;

  /// Whether proximity merging is active.
  final bool enabled;
}
