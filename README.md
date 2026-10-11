# liquid_glass_container

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue.svg)](https://pub.dev/packages/liquid_glass_container)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.49%2B-02569B.svg)](https://flutter.dev)

A production-grade, extensible, performance-conscious Flutter glass UI library inspired by Apple's iOS Liquid Glass design language. Delivers hardware-accelerated GLSL fragment shader refraction, curvature-based edge lensing, Blinn-Phong specular glints, squircle continuous curvature, spring physics, and platform-aware Canvas fallbacks.

> **Honest Architectural Notice:** This package does **not** use private Apple APIs or proprietary iOS rendering binaries, nor does it claim pixel-for-pixel identity with native iOS compositor algorithms. It leverages Flutter's official graphics pipeline (Impeller & Skia), combining GPU `BackdropFilter` passes with custom GLSL fragment shaders (`FragmentProgram`) and pure Canvas fallbacks to deliver an equivalent premium optical glass experience across mobile, tablet, desktop, and web.

---

## Table of Contents

1. [Features](#features)
2. [Platform Compatibility Matrix](#platform-compatibility-matrix)
3. [Installation](#installation)
4. [Engine Initialization](#engine-initialization)
5. [Quick Start](#quick-start)
6. [The 16 Built-in Presets](#the-16-built-in-presets)
7. [Customizing Optical Settings](#customizing-optical-settings)
8. [Shape System & Squircles](#shape-system--squircles)
9. [SVG Path Parsing](#svg-path-parsing)
10. [Shape Morphing](#shape-morphing)
11. [Liquid Touch & Spring Physics](#liquid-touch--spring-physics)
12. [Animation Library](#animation-library)
13. [Theme Integration](#theme-integration)
14. [Shared Backdrop Coordination](#shared-backdrop-coordination)
15. [Ready-Made Glass Widgets](#ready-made-glass-widgets)
16. [Performance Engineering & Frame Budgets](#performance-engineering--frame-budgets)
17. [Accessibility & Reduced Transparency](#accessibility--reduced-transparency)
18. [Honest Fallback Architecture](#honest-fallback-architecture)
19. [Troubleshooting & FAQ](#troubleshooting--faq)
20. [Known Limitations](#known-limitations)
21. [Example App](#example-app)
22. [Testing & Verification](#testing--verification)
23. [License](#license)

---

## Features

- **GLSL Fragment Shader Engine:** Directional Blinn-Phong specular highlights, Fresnel rim lighting, chromatic dispersion, squircle distance fields, and localized touch glints.
- **Continuous Squircle Geometry:** Gielis superellipse and cubic Bézier corner curvature avoiding sharp curvature discontinuities.
- **16 Curated Presets:** Including `iosMaps`, `controlCenter`, `clearGlass`, `frostedWhite`, `darkGlass`, `aurora`, `crystal`, `neonEdge`, and more.
- **Shape System:** Rounded rectangles, iOS squircles, circles, capsules, ovals, stars, hearts, hexagons, blobs, custom path builders, and pure-Dart SVG path parsing.
- **Continuous Shape Morphing:** Normalized arc-length spline resampling between arbitrary shapes.
- **Spring Physics & Elastic Drag:** iOS-style rubber-band resistance with `SpringSimulation` recoil on release.
- **10 Ready-Made Components:** `LiquidGlassContainer`, `LiquidGlassButton`, `LiquidGlassAppBar`, `LiquidGlassBottomSheet`, `LiquidGlassTabBar`, `LiquidGlassSlider`, `LiquidGlassSwitch`, `LiquidGlassDialog`, `LiquidGlassSearchBar`, and `LiquidGlassCard`.
- **Accessibility & Contrast:** Native support for `disableAnimations` (Reduce Motion), `accessibleNavigation` (Reduce Transparency), and WCAG 2.1 luminance calculation.
- **Deterministic Fallback:** Seamless fallback to multi-stop Canvas gradients and inner shadows when shaders are disabled or unsupported.

---

## Platform Compatibility Matrix

| Target Platform | Impeller Support | Skia Support | Shader Acceleration | Backdrop Blur | Spring Physics & Gestures | Fallback Mode |
|---|---|---|---|---|---|---|
| **iOS** | Native (Default) | Supported | GLSL Runtime Effect | Hardware `BackdropFilter` | Full | Auto |
| **Android** | Supported (Vulkan) | Supported (OpenGL) | GLSL Runtime Effect | Hardware `BackdropFilter` | Full | Auto |
| **macOS** | Native (Metal) | Supported | GLSL Runtime Effect | Hardware `BackdropFilter` | Full | Auto |
| **Windows** | Planned | Supported (DirectX) | GLSL Runtime Effect | Hardware `BackdropFilter` | Full | Auto |
| **Linux** | Supported | Supported (OpenGL) | GLSL Runtime Effect | Hardware `BackdropFilter` | Full | Auto |
| **Web (Wasm)** | Experimental | Supported (CanvasKit) | GLSL Runtime Effect | Hardware `BackdropFilter` | Full | Auto |
| **Web (HTML)** | N/A | N/A | Unsupported | CSS/Canvas Filter | Full | Pure Canvas Fallback |

---

## Installation

Add `liquid_glass_container` to your `pubspec.yaml`:

```yaml
dependencies:
  liquid_glass_container: ^1.0.0
```

Ensure your `pubspec.yaml` registers the included fragment shaders:

```yaml
flutter:
  shaders:
    - packages/liquid_glass_container/shaders/liquid_glass.frag
    - packages/liquid_glass_container/shaders/liquid_blob.frag
```

Then fetch packages:

```bash
flutter pub get
```

---

## Engine Initialization

Preloading fragment shaders during app startup avoids raster compilation hitches on the first glass frame:

```dart
import 'package:flutter/material.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Compiles and caches GLSL fragment shaders asynchronously
  await LiquidGlass.initialize();

  runApp(const MyApp());
}
```

---

## Quick Start

Wrap any child widget in a `LiquidGlassContainer`:

```dart
import 'package:flutter/material.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

class MyGlassCard extends StatelessWidget {
  const MyGlassCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      settings: LiquidGlassPresets.iosMaps,
      shape: const LiquidGlassShape.squircle(cornerRadius: 28),
      padding: const EdgeInsets.all(20),
      interactive: true,
      child: const Text(
        'Hello Liquid Glass!',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
```

---

## The 16 Built-in Presets

Access all presets through the `LiquidGlassPresets` class or customize them via `copyWith()`:

| Preset Name | Description | Key Optical Attributes |
|---|---|---|
| `iosMaps` | Iconic iOS Maps floating search bar and card | Blur: 24, Refraction: 0.28, White Tint: 16%, Thin Rim |
| `controlCenter` | Dark, saturated Control Center tile glass | Blur: 32, Saturation: 1.45, Dark Tint: 48% |
| `clearGlass` | Ultra-transparent, high-refraction optical lens | Blur: 14, Refraction: 0.55, Tint: 6%, Chromatic Dispersion |
| `frostedWhite` | Milky, highly diffused white translucent glass | Blur: 38, Refraction: 0.18, White Tint: 34% |
| `darkGlass` | Smoky obsidian translucent glass | Blur: 22, Refraction: 0.30, Dark Tint: 55%, Ambient Shadow |
| `tintedBlue` | Electric azure blue tinted glass | Blur: 20, Refraction: 0.35, Azure Tint: 22% |
| `tintedPink` | Rosy neon pink glass with vibrant specular glints | Blur: 20, Refraction: 0.35, Pink Tint: 22% |
| `aurora` | Iridescent northern lights with chromatic dispersion | Blur: 24, Refraction: 0.45, Chromatic Aberration: 0.22 |
| `crystal` | Crystalline prism with maximum refractive index | Blur: 12, Refraction: 0.68, Specular: 0.85, Thickness: 22 |
| `neonEdge` | Deep obsidian core with glowing cyan rim | Blur: 18, Inner Glow: 0.75, Border: 1.8 |
| `soapBubble` | Delicate rainbow thin-film iridescent sheen | Blur: 8, Refraction: 0.50, Chromatic: 0.35, Tint: 10% |
| `minimalPill` | Clean, lightweight pill for badges and chips | Blur: 16, Refraction: 0.20, Border: 0.7, Thickness: 8 |
| `frostedDark` | Deep matte frosted obsidian for dark themes | Blur: 40, Refraction: 0.12, Dark Tint: 72% |
| `softSilver` | Platinum sheen with brilliant cold highlights | Blur: 20, Refraction: 0.32, Silver Tint: 28% |
| `warmAmber` | Golden honey translucent warmth | Blur: 22, Refraction: 0.34, Amber Tint: 24% |
| `liquidChrome` | Mirror-like liquid mercury chrome finish | Blur: 16, Refraction: 0.62, Specular: 0.90 |

```dart
// Customizing a preset
final myCustomGlass = LiquidGlassPresets.iosMaps.copyWith(
  blur: 30.0,
  tintColor: Colors.deepPurple,
  tintOpacity: 0.25,
);
```

---

## Customizing Optical Settings

Create custom optical profiles using the immutable `LiquidGlassSettings`:

```dart
const settings = LiquidGlassSettings(
  blur: 24.0,                   // Background blur radius in logical pixels
  refractionStrength: 0.35,     // Lens curvature distortion (0.0 to 1.0)
  thickness: 16.0,              // Optical thickness depth (0.0 to 50.0)
  lightAngle: 0.785,            // Incident light angle in radians (~45 deg)
  specularIntensity: 0.55,      // Blinn-Phong highlight brightness (0.0 to 1.0)
  saturation: 1.25,             // Background saturation boost multiplier
  tintColor: Colors.white,      // Translucent tint color
  tintOpacity: 0.18,            // Tint opacity multiplier (0.0 to 1.0)
  borderWidth: 1.0,             // Perimeter rim stroke thickness
  innerGlow: 0.30,              // Fresnel edge glow intensity (0.0 to 1.0)
  shadowBlur: 18.0,             // Ambient drop shadow blur
  shadowColor: Color(0x33000000),// Ambient drop shadow color
  cornerSmoothing: 0.75,        // Squircle exponent (0.0 = arc, 1.0 = superellipse)
  chromaticAberration: 0.08,    // R/B dispersion split (0.0 to 1.0)
  quality: LiquidGlassQuality.auto,
);
```

---

## Shape System & Squircles

`LiquidGlassShape` provides built-in shapes, custom path builders, and SVG data support:

```dart
// 1. iOS Continuous Curvature Squircle
LiquidGlassShape.squircle(cornerRadius: 28, cornerSmoothing: 0.8)

// 2. Standard Rounded Rectangle
LiquidGlassShape.roundedRectangle(borderRadius: BorderRadius.circular(20))

// 3. Circle
LiquidGlassShape.circle()

// 4. Capsule / Pill
LiquidGlassShape.capsule()

// 5. Oval
LiquidGlassShape.oval()

// 6. N-Pointed Star
LiquidGlassShape.star(points: 5, innerRadiusRatio: 0.48)

// 7. Mathematical Heart
LiquidGlassShape.heart()

// 8. Hexagon with rounded corners
LiquidGlassShape.hexagon(cornerRadius: 6)

// 9. Organic Blob
LiquidGlassShape.blob(points: 8, wobble: 0.15)

// 10. Custom Path Builder
LiquidGlassShape.custom(pathBuilder: (Size size) {
  return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
})
```

---

## SVG Path Parsing

Load arbitrary geometric boundaries directly from SVG path `d` strings:

```dart
const shape = LiquidGlassShape.svgPath(
  'M 10 80 C 40 10, 65 10, 95 80 S 150 150, 180 80 Z',
);
```

The pure-Dart parser supports `M/m`, `L/l`, `H/h`, `V/v`, `C/c`, `S/s`, `Q/q`, `T/t`, `A/a`, and `Z/z`, automatically scaling and centering paths into container boundaries without external native dependencies.

---

## Shape Morphing

Morph smoothly between any two shapes using `LiquidGlassShapeTransition`:

```dart
LiquidGlassShapeTransition(
  shapeA: const LiquidGlassShape.squircle(cornerRadius: 28),
  shapeB: const LiquidGlassShape.star(),
  progress: myAnimationController,
  builder: (context, morphedPath) {
    return LiquidGlassContainer(
      settings: LiquidGlassPresets.crystal,
      morphedPath: morphedPath,
      child: const Center(child: Text('Morphing Glass')),
    );
  },
)
```

---

## Liquid Touch & Spring Physics

Enable responsive touch squashing and rubber-band dragging with spring recovery:

```dart
LiquidGlassContainer(
  settings: LiquidGlassPresets.soapBubble,
  interactive: true,             // Press squash & localized specular glint
  enableDrag: true,              // Elastic drag with iOS rubber-band resistance
  hapticFeedback: LiquidGlassHapticFeedback.light,
  onTap: () => print('Tapped!'),
  child: const Center(child: Text('Drag Me')),
)
```

---

## Ready-Made Glass Widgets

### 1. `LiquidGlassButton`
Interactive button with tactile haptic response, focus rings, loading state, and accessible semantics.

```dart
LiquidGlassButton(
  onPressed: () => handleAction(),
  isLoading: isSubmitting,
  child: const Text('Confirm Order'),
)
```

### 2. `LiquidGlassAppBar`
PreferredSizeWidget-compatible navigation bar with safe-area blurring and bottom rim dividers.

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: LiquidGlassAppBar(
    title: const Text('Navigation Bar'),
    actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
  ),
  body: ListView(...),
)
```

### 3. `LiquidGlassBottomSheet`
Draggable bottom sheet supporting snap detents, grab handle, and modal overlay helper.

```dart
LiquidGlassBottomSheet.show(
  context: context,
  snapSizes: const [0.25, 0.5, 0.92],
  builder: (context, scrollController) {
    return ListView(controller: scrollController, ...);
  },
);
```

### 4. `LiquidGlassTabBar`
Floating glass tab bar with an animated sliding glass indicator pill.

```dart
LiquidGlassTabBar(
  selectedIndex: activeIndex,
  onTabSelected: (index) => setState(() => activeIndex = index),
  tabs: const [
    LiquidGlassTabItem(label: 'Home', icon: Icons.home),
    LiquidGlassTabItem(label: 'Explore', icon: Icons.explore),
  ],
)
```

### 5. `LiquidGlassSlider` & `LiquidGlassSwitch`
Form controls conforming to Flutter Accessibility semantics and keyboard navigation.

```dart
LiquidGlassSlider(
  value: sliderValue,
  onChanged: (v) => setState(() => sliderValue = v),
)

LiquidGlassSwitch(
  value: switchValue,
  onChanged: (v) => setState(() => switchValue = v),
)
```

### 6. `LiquidGlassDialog`
Modal alert dialog floating in a squircle glass card with barrier blur.

```dart
LiquidGlassDialog.show(
  context: context,
  title: const Text('Alert'),
  content: const Text('Changes have been saved.'),
);
```

### 7. `LiquidGlassSearchBar` & `LiquidGlassCard`
Pre-built structured card and search input field with clear buttons and focus highlights.

---

## Performance Engineering & Frame Budgets

Optical glass effects must respect display frame budgets:
- **60 Hz Displays:** 16.67 ms per frame
- **120 Hz Displays (ProMotion):** 8.33 ms per frame

To guarantee optimal performance:
1. **Shader Preloading:** Call `await LiquidGlass.initialize()` in `main()`.
2. **Repaint Boundaries:** Every `LiquidGlassRenderer` isolates repaints with a dedicated `RepaintBoundary`.
3. **Shared Backdrop Coordination:** Wrap multiple sibling glass widgets in a `LiquidGlassLayer` to eliminate redundant raster invalidations.
4. **Diagnostics Telemetry:** Monitor frame metrics in debug mode using `LiquidGlassDiagnosticsOverlay`.

```dart
// Turn on live frame timing telemetry HUD
LiquidGlassPerformanceTracker.instance.start();
```

---

## Accessibility & Reduced Transparency

`liquid_glass_container` adheres to platform accessibility preferences:
- **Reduce Motion:** When `MediaQuery.disableAnimations` is true, idle animations and elastic bounces are automatically suppressed.
- **Reduce Transparency:** When `accessibleNavigation` or `boldText` is active, blur passes are disabled and background opacity increases to a readable, high-contrast surface.
- **Dynamic Contrast:** `LiquidGlassAccessibility.getContrastingForeground(...)` determines whether foreground text should be dark or light according to WCAG 2.1 luminance standards.

---

## Honest Fallback Architecture

Flutter's standard `FragmentShader` cannot sample arbitrary screen framebuffers beneath a widget without passing a rasterized texture input. Continually capturing screen regions via `RenderRepaintBoundary.toImage()` causes costly GPU-CPU roundtrips that drop frames.

**Our Architecture Solution:**
1. A hardware-composited `BackdropFilter` applies zero-copy GPU blur to underlying pixels.
2. A custom GLSL FragmentShader overlays optical thickness lens normal curves, Fresnel rim lighting, specular glints, and touch glints.
3. On platforms without shader support (e.g. HTML Web), the renderer falls back to multi-stop Canvas gradients without throwing errors or breaking widget layouts.

---

## Testing & Verification

Run the full automated test suite:

```bash
flutter test
```

Inspect code quality and static analysis:

```bash
flutter analyze
dart format --set-exit-if-changed .
```

---

## License

This package is licensed under the [MIT License](LICENSE).
