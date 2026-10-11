import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_backdrop.dart';
import 'liquid_glass_painter.dart';

/// The core compositing renderer widget that layers the background blur,
/// hardware shader passes, rim lighting, and child clipping.
class LiquidGlassRenderer extends StatelessWidget {
  const LiquidGlassRenderer({
    super.key,
    required this.settings,
    required this.shape,
    this.touchPosition = Offset.zero,
    this.touchIntensity = 0.0,
    this.time = 0.0,
    this.morphedPath,
    this.child,
  });

  final LiquidGlassSettings settings;
  final LiquidGlassShape shape;
  final Offset touchPosition;
  final double touchIntensity;
  final double time;
  final Path? morphedPath;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // 1. Hardware backdrop blur & translucent backing
          Positioned.fill(
            child: LiquidGlassBackdrop(
              settings: settings,
              shape: shape,
              morphedPath: morphedPath,
            ),
          ),

          // 2. Fragment shader / Fallback lighting pass
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: LiquidGlassPainter(
                  settings: settings,
                  shape: shape,
                  touchPosition: touchPosition,
                  touchIntensity: touchIntensity,
                  time: time,
                  morphedPath: morphedPath,
                ),
              ),
            ),
          ),

          // 3. Clipped child content
          if (child != null)
            ClipPath(
              clipper: LiquidGlassClipper(
                shape: shape,
                morphedPath: morphedPath,
              ),
              child: child!,
            ),
        ],
      ),
    );
  }
}

