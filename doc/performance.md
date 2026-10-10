# Performance

- Rebuilds are minimized via `CustomPainter` with strict `shouldRepaint` checks.
- BackdropFilter is isolated.
- The `SpringSimulation` drives rendering without allocating new heavy objects on every frame.
- Recommended to use `LiquidQuality.balanced` when animations get complex.
