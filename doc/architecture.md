# Architecture

The package is split into:
- Core configuration: `LiquidTheme`, `LiquidGlass`, `LiquidPhysics`
- Shapes: `LiquidShape` providing geometry definitions
- Rendering: Custom painters doing shape clipping and glass effects.
- Interaction: Gesture detectors linked with `SpringSimulation` for liquid dragging.
