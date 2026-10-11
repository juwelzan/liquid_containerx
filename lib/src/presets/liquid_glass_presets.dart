import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';

/// A curated collection of 16 production-grade visual presets inspired by
/// iOS Liquid Glass and modern optical materials.
abstract final class LiquidGlassPresets {
  /// Subtle, iconic iOS Maps-style floating search and card glass.
  static const LiquidGlassSettings iosMaps = LiquidGlassSettings(
    blur: 24.0,
    refractionStrength: 0.28,
    thickness: 12.0,
    lightAngle: 0.785398, // 45°
    specularIntensity: 0.42,
    saturation: 1.25,
    tintColor: Colors.white,
    tintOpacity: 0.16,
    borderWidth: 0.8,
    innerGlow: 0.22,
    shadowBlur: 18.0,
    shadowColor: Color(0x33000000),
    cornerSmoothing: 0.75,
  );

  /// Dark, saturated Control Center tile glass.
  static const LiquidGlassSettings controlCenter = LiquidGlassSettings(
    blur: 32.0,
    refractionStrength: 0.25,
    thickness: 14.0,
    specularIntensity: 0.4,
    saturation: 1.45,
    tintColor: Color(0xFF2C2C2E),
    tintOpacity: 0.48,
    borderWidth: 1.0,
    innerGlow: 0.2,
    shadowBlur: 20.0,
    shadowColor: Color(0x44000000),
    cornerSmoothing: 0.8,
  );

  /// Ultra-transparent, high-refraction optical glass lens.
  static const LiquidGlassSettings clearGlass = LiquidGlassSettings(
    blur: 14.0,
    refractionStrength: 0.55,
    thickness: 18.0,
    specularIntensity: 0.7,
    saturation: 1.15,
    tintColor: Colors.white,
    tintOpacity: 0.06,
    borderWidth: 1.0,
    innerGlow: 0.38,
    chromaticAberration: 0.12,
    shadowBlur: 14.0,
  );

  /// Milky, highly diffused white translucent glass.
  static const LiquidGlassSettings frostedWhite = LiquidGlassSettings(
    blur: 38.0,
    refractionStrength: 0.18,
    thickness: 14.0,
    specularIntensity: 0.32,
    saturation: 1.2,
    tintColor: Colors.white,
    tintOpacity: 0.34,
    borderWidth: 1.2,
    innerGlow: 0.2,
    shadowBlur: 22.0,
    shadowColor: Color(0x22000000),
  );

  /// Elegant, smoky translucent glass with cool specular reflections.
  static const LiquidGlassSettings darkGlass = LiquidGlassSettings(
    blur: 22.0,
    refractionStrength: 0.3,
    thickness: 12.0,
    specularIntensity: 0.45,
    saturation: 1.3,
    tintColor: Color(0xFF1C1C1E),
    tintOpacity: 0.55,
    borderWidth: 1.0,
    innerGlow: 0.25,
    shadowBlur: 18.0,
    shadowColor: Color(0x55000000),
  );

  /// Electric azure blue tinted glass.
  static const LiquidGlassSettings tintedBlue = LiquidGlassSettings(
    blur: 20.0,
    refractionStrength: 0.35,
    thickness: 12.0,
    specularIntensity: 0.5,
    saturation: 1.4,
    tintColor: Color(0xFF007AFF),
    tintOpacity: 0.22,
    borderWidth: 1.0,
    innerGlow: 0.3,
    shadowBlur: 16.0,
    shadowColor: Color(0x33007AFF),
  );

  /// Rosy neon pink glass with vibrant specular glints.
  static const LiquidGlassSettings tintedPink = LiquidGlassSettings(
    blur: 20.0,
    refractionStrength: 0.35,
    thickness: 12.0,
    specularIntensity: 0.52,
    saturation: 1.4,
    tintColor: Color(0xFFFF2D55),
    tintOpacity: 0.22,
    borderWidth: 1.0,
    innerGlow: 0.3,
    shadowBlur: 16.0,
    shadowColor: Color(0x33FF2D55),
  );

  /// Iridescent northern lights glass with chromatic dispersion.
  static const LiquidGlassSettings aurora = LiquidGlassSettings(
    blur: 24.0,
    refractionStrength: 0.45,
    thickness: 16.0,
    specularIntensity: 0.6,
    saturation: 1.5,
    tintColor: Color(0xFF00F5D4),
    tintOpacity: 0.18,
    borderWidth: 1.2,
    innerGlow: 0.45,
    chromaticAberration: 0.22,
    shadowBlur: 20.0,
    shadowColor: Color(0x3300F5D4),
  );

  /// Sharp, crystalline prism with maximum refractive index.
  static const LiquidGlassSettings crystal = LiquidGlassSettings(
    blur: 12.0,
    refractionStrength: 0.68,
    thickness: 22.0,
    specularIntensity: 0.85,
    saturation: 1.1,
    tintColor: Colors.white,
    tintOpacity: 0.08,
    borderWidth: 1.2,
    innerGlow: 0.5,
    chromaticAberration: 0.18,
    shadowBlur: 16.0,
  );

  /// Deep obsidian body with a high-intensity glowing neon rim.
  static const LiquidGlassSettings neonEdge = LiquidGlassSettings(
    blur: 18.0,
    refractionStrength: 0.4,
    thickness: 14.0,
    specularIntensity: 0.55,
    saturation: 1.3,
    tintColor: Color(0xFF0A0A12),
    tintOpacity: 0.65,
    borderWidth: 1.8,
    innerGlow: 0.75,
    shadowBlur: 24.0,
    shadowColor: Color(0x5500F5D4),
  );

  /// Delicate, rainbow-sheen soap bubble film.
  static const LiquidGlassSettings soapBubble = LiquidGlassSettings(
    blur: 8.0,
    refractionStrength: 0.5,
    thickness: 6.0,
    specularIntensity: 0.72,
    saturation: 1.2,
    tintColor: Color(0xFFE0F7FA),
    tintOpacity: 0.1,
    borderWidth: 0.8,
    innerGlow: 0.6,
    chromaticAberration: 0.35,
    shadowBlur: 10.0,
  );

  /// Clean, lightweight pill for badges, buttons, and chips.
  static const LiquidGlassSettings minimalPill = LiquidGlassSettings(
    blur: 16.0,
    refractionStrength: 0.2,
    thickness: 8.0,
    specularIntensity: 0.38,
    saturation: 1.2,
    tintColor: Colors.white,
    tintOpacity: 0.14,
    borderWidth: 0.7,
    innerGlow: 0.18,
    shadowBlur: 10.0,
  );

  /// Deep matte frosted glass for dark mode and midnight palettes.
  static const LiquidGlassSettings frostedDark = LiquidGlassSettings(
    blur: 40.0,
    refractionStrength: 0.12,
    thickness: 16.0,
    specularIntensity: 0.25,
    saturation: 1.3,
    tintColor: Color(0xFF121214),
    tintOpacity: 0.72,
    borderWidth: 1.0,
    innerGlow: 0.15,
    shadowBlur: 24.0,
    shadowColor: Color(0x66000000),
  );

  /// Platinum metallic sheen with brilliant silver highlights.
  static const LiquidGlassSettings softSilver = LiquidGlassSettings(
    blur: 20.0,
    refractionStrength: 0.32,
    thickness: 14.0,
    specularIntensity: 0.6,
    saturation: 1.0,
    tintColor: Color(0xFFE5E5EA),
    tintOpacity: 0.28,
    borderWidth: 1.0,
    innerGlow: 0.32,
    shadowBlur: 16.0,
  );

  /// Golden honey translucent warmth for autumnal / sunset themes.
  static const LiquidGlassSettings warmAmber = LiquidGlassSettings(
    blur: 22.0,
    refractionStrength: 0.34,
    thickness: 14.0,
    specularIntensity: 0.5,
    saturation: 1.45,
    tintColor: Color(0xFFFF9500),
    tintOpacity: 0.24,
    borderWidth: 1.0,
    innerGlow: 0.32,
    shadowBlur: 18.0,
    shadowColor: Color(0x33FF9500),
  );

  /// Mirror-like liquid mercury chrome finish.
  static const LiquidGlassSettings liquidChrome = LiquidGlassSettings(
    blur: 16.0,
    refractionStrength: 0.62,
    thickness: 20.0,
    specularIntensity: 0.9,
    saturation: 1.1,
    tintColor: Color(0xFFD1D1D6),
    tintOpacity: 0.35,
    borderWidth: 1.4,
    innerGlow: 0.55,
    chromaticAberration: 0.1,
    shadowBlur: 20.0,
    shadowColor: Color(0x44000000),
  );

  /// A map of all 16 presets keyed by their canonical identifiers.
  static const Map<String, LiquidGlassSettings> values = {
    'iosMaps': iosMaps,
    'controlCenter': controlCenter,
    'clearGlass': clearGlass,
    'frostedWhite': frostedWhite,
    'darkGlass': darkGlass,
    'tintedBlue': tintedBlue,
    'tintedPink': tintedPink,
    'aurora': aurora,
    'crystal': crystal,
    'neonEdge': neonEdge,
    'soapBubble': soapBubble,
    'minimalPill': minimalPill,
    'frostedDark': frostedDark,
    'softSilver': softSilver,
    'warmAmber': warmAmber,
    'liquidChrome': liquidChrome,
  };
}

