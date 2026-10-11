import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Manages loading, caching, and lifecycle of GLSL [FragmentProgram] instances.
///
/// Ensures fragment programs are loaded and compiled once, shared across
/// all liquid glass instances, and handles platform fallback gracefully.
class LiquidShaderManager {
  LiquidShaderManager._();

  static final LiquidShaderManager instance = LiquidShaderManager._();

  FragmentProgram? _glassProgram;
  FragmentProgram? _blobProgram;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;
  Object? _lastError;

  /// Whether the shader manager has completed initialization.
  bool get isInitialized => _isInitialized;

  /// Whether shaders are supported and compiled successfully.
  bool get hasCompiledShaders => _glassProgram != null;

  /// The last error encountered during shader loading, if any.
  Object? get lastError => _lastError;

  /// The cached [FragmentProgram] for liquid glass surfaces.
  FragmentProgram? get glassProgram => _glassProgram;

  /// The cached [FragmentProgram] for liquid blob shapes.
  FragmentProgram? get blobProgram => _blobProgram;

  /// Initializes and compiles fragment shaders. Safe to call concurrently.
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      _lastError = null;
      _glassProgram = await _loadProgram('shaders/liquid_glass.frag');
      _blobProgram = await _loadProgram('shaders/liquid_blob.frag');
      _isInitialized = true;
      _initCompleter!.complete();
    } catch (e, stack) {
      _lastError = e;
      _isInitialized = true; // Mark as resolved so we don't block
      debugPrint(
        'LiquidGlass: Shader compilation notice (fallback active): $e\n$stack',
      );
      _initCompleter!.complete();
    } finally {
      _initCompleter = null;
    }
  }

  /// Attempts to load a fragment shader program trying package asset paths first,
  /// followed by relative root asset paths.
  Future<FragmentProgram?> _loadProgram(String assetPath) async {
    final candidatePaths = [
      'packages/liquid_glass_container/$assetPath',
      assetPath,
      'packages/liquid_containerx/$assetPath',
    ];

    for (final path in candidatePaths) {
      try {
        final program = await FragmentProgram.fromAsset(path);
        return program;
      } catch (_) {
        // Try next candidate path
      }
    }
    return null;
  }

  /// Clears the cached [FragmentProgram] instances and resets initialization.
  void disposeCache() {
    _glassProgram = null;
    _blobProgram = null;
    _isInitialized = false;
    _initCompleter = null;
    _lastError = null;
  }
}
