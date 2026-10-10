import 'dart:ui';
import 'package:flutter/foundation.dart';

class ShaderManager {
  static FragmentProgram? _liquidGlassProgram;
  static bool _isLoading = false;
  static bool _hasError = false;

  /// Loads the liquid glass shader if not already loaded.
  /// Safe to call multiple times.
  static Future<void> loadLiquidGlassShader() async {
    if (_liquidGlassProgram != null || _isLoading || _hasError) return;

    _isLoading = true;
    try {
      _liquidGlassProgram = await FragmentProgram.fromAsset('shaders/liquid_glass.frag');
    } catch (e) {
      debugPrint('Failed to load liquid_glass.frag: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
    }
  }

  /// Returns a new FragmentShader instance if the program is loaded, else null.
  static FragmentShader? createLiquidGlassShader() {
    return _liquidGlassProgram?.fragmentShader();
  }
}
