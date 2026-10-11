import 'package:flutter/material.dart';

import 'liquid_glass_settings.dart';

/// A controller to programmatically inspect and manipulate a liquid glass surface.
///
/// Allows external code to trigger light flashes, ripple waves, adjust
/// simulated light angles, or dynamically override glass settings.
class LiquidGlassController extends ChangeNotifier {
  /// Creates a [LiquidGlassController] with optional initial settings.
  LiquidGlassController({LiquidGlassSettings? initialSettings})
    : _settings = initialSettings;

  LiquidGlassSettings? _settings;
  Offset _touchPosition = Offset.zero;
  double _touchIntensity = 0.0;
  double _lightAngleOffset = 0.0;
  bool _isDisposed = false;

  /// The active settings override, if any.
  LiquidGlassSettings? get settings => _settings;

  /// The normalized touch coordinate [0..1] on the surface.
  Offset get touchPosition => _touchPosition;

  /// The current interaction intensity [0..1].
  double get touchIntensity => _touchIntensity;

  /// An angle offset in radians added to the simulated light direction.
  double get lightAngleOffset => _lightAngleOffset;

  /// Updates the glass settings dynamically.
  void updateSettings(LiquidGlassSettings newSettings) {
    if (_isDisposed) return;
    _settings = newSettings;
    notifyListeners();
  }

  /// Manually simulates a touch interaction at [position] with [intensity].
  void setTouch(Offset position, double intensity) {
    if (_isDisposed) return;
    _touchPosition = position;
    _touchIntensity = intensity.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Sets an angular offset for the incident light in radians.
  void setLightAngleOffset(double radians) {
    if (_isDisposed) return;
    _lightAngleOffset = radians;
    notifyListeners();
  }

  /// Resets simulated touch interactions.
  void clearTouch() {
    if (_isDisposed) return;
    _touchIntensity = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
