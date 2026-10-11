import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../shapes/liquid_glass_shape.dart';

/// A pure Canvas-based fallback painter for platforms and environments where
/// custom GLSL runtime shaders are unavailable or disabled.
///
/// Simulates specular directional lighting, Fresnel rim glows, and glass translucency
/// using layered gradient strokes, highlights, and radial glints.
class LiquidGlassFallbackPainter extends CustomPainter {
  const LiquidGlassFallbackPainter({
    required this.settings,
    required this.shape,
    this.touchPosition = Offset.zero,
    this.touchIntensity = 0.0,
    this.morphedPath,
  });

  final LiquidGlassSettings settings;
  final LiquidGlassShape shape;
  final Offset touchPosition;
  final double touchIntensity;
  final Path? morphedPath;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final path = morphedPath ?? shape.buildPath(size);

    // 1. Ambient drop shadow
    if (settings.shadowBlur > 0 && settings.shadowColor.a > 0) {
      final shadowPaint = Paint()
        ..color = settings.shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, settings.shadowBlur);
      canvas.drawPath(path, shadowPaint);
    }

    // 2. Base tint fill
    final tintPaint = Paint()
      ..color = settings.effectiveTintColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, tintPaint);

    // 3. Directional specular lighting gradient
    final angle = settings.lightAngle;
    final halfW = size.width / 2;
    final halfH = size.height / 2;
    final length = math.max(size.width, size.height);
    final lightOffset = Offset(
      halfW - math.cos(angle) * length * 0.5,
      halfH - math.sin(angle) * length * 0.5,
    );
    final oppositeOffset = Offset(
      halfW + math.cos(angle) * length * 0.5,
      halfH + math.sin(angle) * length * 0.5,
    );

    final highlightAlpha = (settings.specularIntensity * 0.35).clamp(0.0, 1.0);
    final specularGradient = LinearGradient(
      begin: Alignment(
        (lightOffset.dx - halfW) / halfW,
        (lightOffset.dy - halfH) / halfH,
      ),
      end: Alignment(
        (oppositeOffset.dx - halfW) / halfW,
        (oppositeOffset.dy - halfH) / halfH,
      ),
      colors: [
        Colors.white.withValues(alpha: highlightAlpha),
        Colors.white.withValues(alpha: highlightAlpha * 0.25),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final specularPaint = Paint()
      ..shader = specularGradient.createShader(Offset.zero & size)
      ..blendMode = BlendMode.screen;
    canvas.drawPath(path, specularPaint);

    // 4. Inner Fresnel rim glow
    if (settings.innerGlow > 0.0) {
      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, settings.borderWidth * 1.5)
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: settings.innerGlow * 0.6),
            Colors.white.withValues(alpha: settings.innerGlow * 0.15),
            Colors.white.withValues(alpha: settings.innerGlow * 0.45),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Offset.zero & size);
      canvas.drawPath(path, rimPaint);
    }

    // 5. Touch glint interaction
    if (touchIntensity > 0.01) {
      final touchPixel = Offset(
        touchPosition.dx * size.width,
        touchPosition.dy * size.height,
      );
      final touchPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (touchPixel.dx - halfW) / halfW,
            (touchPixel.dy - halfH) / halfH,
          ),
          radius: 0.45,
          colors: [
            Colors.white.withValues(alpha: touchIntensity * 0.45),
            Colors.white.withValues(alpha: touchIntensity * 0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Offset.zero & size)
        ..blendMode = BlendMode.screen;
      canvas.drawPath(path, touchPaint);
    }

    // 6. Perimeter border stroke
    if (settings.borderWidth > 0.0) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = settings.borderWidth;

      if (settings.borderGradient != null) {
        borderPaint.shader = settings.borderGradient!.createShader(
          Offset.zero & size,
        );
      } else {
        borderPaint.shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.25),
          ],
        ).createShader(Offset.zero & size);
      }
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LiquidGlassFallbackPainter oldDelegate) =>
      oldDelegate.settings != settings ||
      oldDelegate.shape != shape ||
      oldDelegate.touchPosition != touchPosition ||
      oldDelegate.touchIntensity != touchIntensity ||
      oldDelegate.morphedPath != morphedPath;
}
