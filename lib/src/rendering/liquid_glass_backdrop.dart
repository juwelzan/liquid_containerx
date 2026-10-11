import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_container/src/core/liquid_glass_quality.dart';

import '../core/liquid_glass_settings.dart';
import '../shapes/liquid_glass_shape.dart';

/// Custom clipper that derives its clipping path from a [LiquidGlassShape] or a morphed [Path].
class LiquidGlassClipper extends CustomClipper<Path> {
  const LiquidGlassClipper({required this.shape, this.morphedPath});

  final LiquidGlassShape shape;
  final Path? morphedPath;

  @override
  Path getClip(Size size) {
    if (morphedPath != null) {
      return morphedPath!;
    }
    return shape.buildPath(size);
  }

  @override
  bool shouldReclip(covariant LiquidGlassClipper oldClipper) =>
      oldClipper.shape != shape || oldClipper.morphedPath != morphedPath;
}

/// Renders the hardware-accelerated background blur filter and base translucent backing.
class LiquidGlassBackdrop extends StatelessWidget {
  const LiquidGlassBackdrop({
    super.key,
    required this.settings,
    required this.shape,
    this.morphedPath,
    this.child,
  });

  final LiquidGlassSettings settings;
  final LiquidGlassShape shape;
  final Path? morphedPath;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceTransparency =
        mediaQuery?.accessibleNavigation == true ||
        mediaQuery?.boldText == true ||
        settings.quality.supportsNoiseDithering == false &&
            settings.backgroundOpacity > 0.4;

    final effectiveBlur = reduceTransparency ? 0.0 : settings.blur;
    final effectiveBackingOpacity = reduceTransparency
        ? (settings.backgroundOpacity < 0.85
              ? 0.85
              : settings.backgroundOpacity)
        : settings.backgroundOpacity;

    Widget current = ClipPath(
      clipper: LiquidGlassClipper(shape: shape, morphedPath: morphedPath),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Background blur pass
          if (effectiveBlur > 0.0)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlur,
                sigmaY: effectiveBlur,
              ),
              child: const SizedBox.expand(),
            ),

          // Translucent or accessibility-opaque backing
          if (effectiveBackingOpacity > 0.0)
            ColoredBox(
              color: settings.tintColor.withValues(
                alpha: effectiveBackingOpacity,
              ),
              child: const SizedBox.expand(),
            ),

          ?child,
        ],
      ),
    );

    return current;
  }
}
