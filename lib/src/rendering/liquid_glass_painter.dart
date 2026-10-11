import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/liquid_glass_quality.dart';
import '../core/liquid_glass_settings.dart';
import '../shaders/shader_manager.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_fallback.dart';

/// The primary custom painter for liquid glass surfaces.
///
/// Binds optical uniforms to the compiled GLSL [FragmentShader] for hardware-accelerated
/// refraction, specular highlights, and chromatic dispersion. Falls back cleanly to
/// [LiquidGlassFallbackPainter] when shaders are unavailable or running in reduced fidelity.
class LiquidGlassPainter extends CustomPainter {
  const LiquidGlassPainter({
    required this.settings,
    required this.shape,
    this.touchPosition = Offset.zero,
    this.touchIntensity = 0.0,
    this.time = 0.0,
    this.morphedPath,
  });

  final LiquidGlassSettings settings;
  final LiquidGlassShape shape;
  final Offset touchPosition;
  final double touchIntensity;
  final double time;
  final Path? morphedPath;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final path = morphedPath ?? shape.buildPath(size);
    final program = LiquidShaderManager.instance.glassProgram;

    // Delegate to fallback if shaders are unavailable or low-quality is enforced
    if (program == null || settings.quality == LiquidGlassQuality.low) {
      final fallback = LiquidGlassFallbackPainter(
        settings: settings,
        shape: shape,
        touchPosition: touchPosition,
        touchIntensity: touchIntensity,
        morphedPath: morphedPath,
      );
      fallback.paint(canvas, size);
      return;
    }

    // 1. Ambient drop shadow
    if (settings.shadowBlur > 0 && settings.shadowColor.a > 0) {
      final shadowPaint = Paint()
        ..color = settings.shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, settings.shadowBlur);
      canvas.drawPath(path, shadowPaint);
    }

    // 2. Hardware fragment shader pass
    final shader = program.fragmentShader();

    // Uniform 0, 1: uResolution
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // Uniform 2: uTime
    shader.setFloat(2, time);

    // Uniform 3, 4: uTouchPos
    shader.setFloat(3, touchPosition.dx.clamp(0.0, 1.0));
    shader.setFloat(4, touchPosition.dy.clamp(0.0, 1.0));

    // Uniform 5: uTouchIntensity
    shader.setFloat(5, touchIntensity.clamp(0.0, 1.0));

    // Uniform 6: uRefractionStrength
    shader.setFloat(6, settings.refractionStrength.clamp(0.0, 1.0));

    // Uniform 7: uThickness
    shader.setFloat(7, (settings.thickness / 50.0).clamp(0.0, 1.0));

    // Uniform 8: uLightAngle
    shader.setFloat(8, settings.lightAngle);

    // Uniform 9: uSpecularIntensity
    shader.setFloat(9, settings.specularIntensity.clamp(0.0, 1.0));

    // Uniform 10: uChromaticAberration
    final chromatic = settings.quality.supportsChromaticAberration
        ? settings.chromaticAberration
        : 0.0;
    shader.setFloat(10, chromatic.clamp(0.0, 1.0));

    // Uniform 11: uInnerGlow
    shader.setFloat(11, settings.innerGlow.clamp(0.0, 1.0));

    // Uniform 12, 13, 14, 15: uTintColor (unmultiplied R, G, B, A)
    final tint = settings.tintColor;
    shader.setFloat(12, tint.r);
    shader.setFloat(13, tint.g);
    shader.setFloat(14, tint.b);
    shader.setFloat(15, (tint.a * settings.tintOpacity).clamp(0.0, 1.0));

    // Uniform 16: uCornerSmoothing
    shader.setFloat(16, settings.cornerSmoothing.clamp(0.0, 1.0));

    // Uniform 17: uNoiseIntensity
    final noise = settings.quality.supportsNoiseDithering ? 0.03 : 0.0;
    shader.setFloat(17, noise);

    // Uniform 18: uShapeType
    shader.setFloat(18, shape.shaderShapeType);

    // Uniform 19: uQuality
    shader.setFloat(19, settings.quality.shaderUniformValue);

    final shaderPaint = Paint()..shader = shader;
    canvas.drawPath(path, shaderPaint);

    // 3. Crisp perimeter border overlay
    if (settings.borderWidth > 0.0) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = settings.borderWidth;

      if (settings.borderGradient != null) {
        borderPaint.shader = settings.borderGradient!.createShader(
          Offset.zero & size,
        );
      } else {
        borderPaint.shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.3),
          ],
          const [0.0, 0.5, 1.0],
        );
      }
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LiquidGlassPainter oldDelegate) =>
      oldDelegate.settings != settings ||
      oldDelegate.shape != shape ||
      oldDelegate.touchPosition != touchPosition ||
      oldDelegate.touchIntensity != touchIntensity ||
      oldDelegate.time != time ||
      oldDelegate.morphedPath != morphedPath;
}
