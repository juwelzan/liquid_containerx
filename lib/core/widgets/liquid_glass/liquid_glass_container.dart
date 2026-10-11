import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Preset configurations calibrated to closely replicate Apple iOS Liquid Glass aesthetics.
class LiquidGlassStyles {
  const LiquidGlassStyles._();

  /// iOS Control Center panel aesthetic: moderate refraction with high clarity and subtle frost.
  static const LiquidGlassSettings controlCenter = LiquidGlassSettings(
    thickness: 18.0,
    blur: 16.0,
    glassColor: Color(0x28FFFFFF),
    refractiveIndex: 1.25,
    lightAngle: 0.75 * 3.141592653589793,
    lightIntensity: 0.65,
    ambientStrength: 0.12,
    saturation: 1.35,
    chromaticAberration: 0.02,
  );

  /// iOS Floating Navigation Bar / Pill aesthetic: delicate edge lensing with transparent body.
  static const LiquidGlassSettings navigationPill = LiquidGlassSettings(
    thickness: 14.0,
    blur: 20.0,
    glassColor: Color(0x30FFFFFF),
    refractiveIndex: 1.20,
    lightAngle: 0.5 * 3.141592653589793,
    lightIntensity: 0.70,
    ambientStrength: 0.15,
    saturation: 1.30,
    chromaticAberration: 0.015,
  );

  /// iOS Glass Button aesthetic: pronounced rim highlight and reactive specular depth.
  static const LiquidGlassSettings button = LiquidGlassSettings(
    thickness: 16.0,
    blur: 12.0,
    glassColor: Color(0x33FFFFFF),
    refractiveIndex: 1.22,
    lightAngle: 0.65 * 3.141592653589793,
    lightIntensity: 0.85,
    ambientStrength: 0.18,
    saturation: 1.25,
    chromaticAberration: 0.01,
  );

  /// Heavy crystal refraction for prominent hero focal elements.
  static const LiquidGlassSettings crystal = LiquidGlassSettings(
    thickness: 32.0,
    blur: 8.0,
    glassColor: Color(0x20FFFFFF),
    refractiveIndex: 1.45,
    lightAngle: 0.8 * 3.141592653589793,
    lightIntensity: 0.90,
    ambientStrength: 0.10,
    saturation: 1.50,
    chromaticAberration: 0.04,
  );

  /// Dark mode glass aesthetic with balanced luminance and subtle specular rim.
  static const LiquidGlassSettings darkGlass = LiquidGlassSettings(
    thickness: 20.0,
    blur: 24.0,
    glassColor: Color(0x3310141E),
    refractiveIndex: 1.25,
    lightAngle: 0.75 * 3.141592653589793,
    lightIntensity: 0.55,
    ambientStrength: 0.08,
    saturation: 1.20,
    chromaticAberration: 0.015,
  );
}

/// A versatile, production-ready container widget delivering Apple iOS-inspired
/// Liquid Glass effects using the official `liquid_glass_renderer` engine.
///
/// Handles hardware shader refraction, edge highlights, continuous superellipse
/// curvature, touch-responsive specular glow (`GlassGlow`), elastic rubber-band
/// physics (`LiquidStretch`), and platform-aware accessibility fallbacks (`FakeGlass`).
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.shape,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.alignment,
    this.width,
    this.height,
    this.settings,
    this.tintColor,
    this.blur,
    this.thickness,
    this.refractiveIndex,
    this.saturation,
    this.interactive = false,
    this.enableGlow = true,
    this.enableStretch = false,
    this.stretch = 0.35,
    this.resistance = 0.08,
    this.glowColor = const Color(0x33FFFFFF),
    this.glowRadius = 1.0,
    this.fake = false,
    this.glassContainsChild = false,
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
  });

  /// The widget content rendered inside or over the glass surface.
  final Widget child;

  /// Custom geometric shape conforming to `liquid_glass_renderer`'s [LiquidShape].
  /// If null, defaults to [LiquidRoundedSuperellipse] with [borderRadius].
  final LiquidShape? shape;

  /// Corner radius in logical pixels for the default [LiquidRoundedSuperellipse] shape.
  final double borderRadius;

  /// Inset space around the [child] inside the glass boundary.
  final EdgeInsetsGeometry? padding;

  /// Outset space surrounding the outer glass boundary.
  final EdgeInsetsGeometry? margin;

  /// Alignment of the [child] within the container bounds.
  final AlignmentGeometry? alignment;

  /// Explicit width in logical pixels.
  final double? width;

  /// Explicit height in logical pixels.
  final double? height;

  /// Optical configuration for the shader pipeline.
  /// If null, derives defaults from [LiquidGlassStyles.controlCenter].
  final LiquidGlassSettings? settings;

  /// Optional override for the glass tint color.
  final Color? tintColor;

  /// Optional override for the background blur radius.
  final double? blur;

  /// Optional override for the optical thickness (refraction depth).
  final double? thickness;

  /// Optional override for the refractive index (1.0 = none, ~1.25 = realistic).
  final double? refractiveIndex;

  /// Optional override for color saturation behind the glass.
  final double? saturation;

  /// Whether to enable interactive pointer responses (glow and/or stretch).
  final bool interactive;

  /// Whether to enable pointer-tracking specular glow ([GlassGlow]).
  final bool enableGlow;

  /// Whether to enable elastic squash-and-stretch physics ([LiquidStretch]).
  final bool enableStretch;

  /// Stretch displacement multiplier for [LiquidStretch].
  final double stretch;

  /// Drag resistance factor for [LiquidStretch].
  final double resistance;

  /// Color of the localized specular touch glow.
  final Color glowColor;

  /// Relative radius of the specular glow relative to container dimension.
  final double glowRadius;

  /// Whether to force the lightweight [FakeGlass] fallback instead of GPU shaders.
  final bool fake;

  /// Whether the child is rendered inside the glass shader pass or atop it.
  final bool glassContainsChild;

  /// Clipping behavior for the glass shape boundary.
  final Clip clipBehavior;

  /// Accessibility semantic label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // 1. Accessibility & reduced motion evaluation
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceTransparency = mediaQuery?.accessibleNavigation == true ||
        mediaQuery?.boldText == true;
    final reduceMotion = mediaQuery?.disableAnimations ?? false;

    // 2. Resolve effective settings
    final baseSettings = settings ?? LiquidGlassStyles.controlCenter;
    final effectiveSettings = baseSettings.copyWith(
      glassColor: tintColor ?? baseSettings.glassColor,
      blur: blur ?? baseSettings.blur,
      thickness: thickness ?? baseSettings.thickness,
      refractiveIndex: refractiveIndex ?? baseSettings.refractiveIndex,
      saturation: saturation ?? baseSettings.saturation,
    );

    // 3. Resolve effective shape (Apple squircle by default)
    final effectiveShape = shape ??
        LiquidRoundedSuperellipse(
          borderRadius: borderRadius,
        );

    // 4. Construct content tree
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (alignment != null) {
      content = Align(alignment: alignment!, child: content);
    }

    // 5. Wrap with GlassGlow if interactive
    if (interactive && enableGlow && !reduceMotion) {
      content = GlassGlow(
        glowColor: glowColor,
        glowRadius: glowRadius,
        child: content,
      );
    }

    // 6. Build glass surface (Shader vs FakeGlass fallback)
    final shouldUseFake = fake || reduceTransparency;

    Widget glassWidget;
    if (shouldUseFake) {
      glassWidget = FakeGlass(
        shape: effectiveShape,
        settings: effectiveSettings,
        child: content,
      );
    } else {
      glassWidget = LiquidGlass.withOwnLayer(
        shape: effectiveShape,
        settings: effectiveSettings,
        glassContainsChild: glassContainsChild,
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    // 7. Apply elastic rubber-band stretch if requested
    if (interactive && enableStretch && !reduceMotion) {
      glassWidget = LiquidStretch(
        stretch: stretch,
        resistance: resistance,
        child: glassWidget,
      );
    }

    // 8. Apply dimension bounds
    if (width != null || height != null) {
      glassWidget = SizedBox(
        width: width,
        height: height,
        child: glassWidget,
      );
    }

    // 9. Apply outer margin
    if (margin != null) {
      glassWidget = Padding(padding: margin!, child: glassWidget);
    }

    // 10. Wrap in Semantics for accessibility
    if (semanticLabel != null) {
      glassWidget = Semantics(
        label: semanticLabel,
        container: true,
        child: glassWidget,
      );
    }

    return glassWidget;
  }
}

