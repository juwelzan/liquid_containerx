# LiquidContainerx

A reusable Flutter package for creating liquid glass-style translucent surfaces with shape morphing and physics-based interactions.

## Features

- Configurable Liquid Glass appearance.
- Built-in shapes (rectangle, roundedRectangle, circle, pill, squircle, blob).
- Physics-based interactive drag and spring-back.
- Highly optimized rendering with graceful fallbacks.
- Cross-platform support for iOS, Android, macOS, and Windows.

## Getting Started

```dart
import 'package:liquid_containerx/liquid_containerx.dart';

LiquidContainer(
  width: 280,
  height: 180,
  shape: LiquidShape.squircle(),
  glass: LiquidGlass(
    opacity: 0.16,
    blur: 12.0,
  ),
  physics: LiquidPhysics(
    enabled: true,
  ),
  child: Center(child: Text("Liquid Container")),
)
```

The concise API aliases are available as `LiquidContainerx`,
`LiquidGlassSettings`, and `LiquidGlassLayer`. Choose a preset with
`LiquidGlassSettings.frosted`, or wrap a section of the app in
`LiquidGlassLayer(settings: LiquidGlassSettings.vivid, child: ...)` to share
settings. `LiquidShape.rounded()`, `.circle()`, `.blob()`, and `.capsule()` map
to the built-in shape engine. Pass a `LiquidGlassController` to
`LiquidContainerx.glassController` to observe tap ripple events.
