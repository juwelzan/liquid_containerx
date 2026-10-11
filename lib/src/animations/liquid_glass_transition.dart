import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../shapes/liquid_glass_shape.dart';
import '../shapes/shape_morph.dart';

/// Animated transition between two liquid glass shapes using continuous path morphing.
class LiquidGlassShapeTransition extends StatelessWidget {
  const LiquidGlassShapeTransition({
    super.key,
    required this.shapeA,
    required this.shapeB,
    required this.progress,
    required this.builder,
  });

  final LiquidGlassShape shapeA;
  final LiquidGlassShape shapeB;
  final Animation<double> progress;
  final Widget Function(BuildContext context, Path morphedPath) builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final morphedPath = LiquidShapeMorph.morphShapes(
              shapeA,
              shapeB,
              size,
              progress.value,
            );
            return builder(context, morphedPath);
          },
        );
      },
    );
  }
}

/// Animated transition between two [LiquidGlassSettings] profiles.
class LiquidGlassSettingsTransition extends StatelessWidget {
  const LiquidGlassSettingsTransition({
    super.key,
    required this.settingsA,
    required this.settingsB,
    required this.progress,
    required this.builder,
  });

  final LiquidGlassSettings settingsA;
  final LiquidGlassSettings settingsB;
  final Animation<double> progress;
  final Widget Function(BuildContext context, LiquidGlassSettings settings)
  builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final current = LiquidGlassSettings.lerp(
          settingsA,
          settingsB,
          progress.value,
        );
        return builder(context, current);
      },
    );
  }
}
