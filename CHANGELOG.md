## 1.0.0

* Initial production-ready release of `liquid_glass_container`.
* GLSL runtime fragment shader (`liquid_glass.frag`) with directional Blinn-Phong highlights, Fresnel rim lighting, chromatic dispersion, squircle distance fields, and localized touch glints.
* 16 curated presets: `iosMaps`, `controlCenter`, `clearGlass`, `frostedWhite`, `darkGlass`, `tintedBlue`, `tintedPink`, `aurora`, `crystal`, `neonEdge`, `soapBubble`, `minimalPill`, `frostedDark`, `softSilver`, `warmAmber`, `liquidChrome`.
* Built-in shape system: rounded rectangle, squircle (continuous curvature), circle, capsule/pill, oval, star, heart, hexagon, blob, custom path builder, and pure-Dart SVG path parser.
* Continuous shape morphing with normalized arc-length spline sampling (`LiquidShapeMorph`).
* Liquid touch interaction engine with press squash, rubber-band dragging, and spring recoil physics (`SpringSimulation`).
* 10 ready-made components: `LiquidGlassContainer`, `LiquidGlassButton`, `LiquidGlassAppBar`, `LiquidGlassBottomSheet`, `LiquidGlassTabBar`, `LiquidGlassSlider`, `LiquidGlassSwitch`, `LiquidGlassDialog`, `LiquidGlassSearchBar`, `LiquidGlassCard`.
* Accessibility support for Reduce Motion (`disableAnimations`), Reduce Transparency (`accessibleNavigation`), and WCAG 2.1 luminance contrast calculation.
* Deterministic multi-pass Canvas fallback when runtime shaders are unavailable or in low quality mode.
* Diagnostics HUD overlay and frame timing telemetry tracker.
