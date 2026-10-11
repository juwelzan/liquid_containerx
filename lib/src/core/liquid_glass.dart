import 'dart:async';

import '../shaders/shader_manager.dart';

/// The central entry point and lifecycle manager for the Liquid Glass engine.
///
/// Provides application-wide initialization, shader preloading, caching,
/// and environment diagnostic checks.
abstract final class LiquidGlass {
  /// Whether the Liquid Glass shader system has finished initializing.
  static bool get isInitialized => LiquidShaderManager.instance.isInitialized;

  /// Whether hardware-accelerated shaders are successfully loaded and available.
  static bool get hasShaderSupport =>
      LiquidShaderManager.instance.hasCompiledShaders;

  /// Initializes the Liquid Glass runtime and compiles GLSL fragment shaders.
  ///
  /// This should be called during app initialization (e.g., in `main()` before
  /// `runApp()`) to avoid frame stalls upon first rendering glass components.
  ///
  /// Safe to call concurrently or multiple times.
  static Future<void> initialize() => LiquidShaderManager.instance.initialize();

  /// Alias for [initialize]. Preloads shader programs into memory.
  static Future<void> preload() => initialize();

  /// Clears the global shader cache and resets engine state.
  ///
  /// Should only be called when tearing down the app or in specialized test suites.
  static void disposeCache() => LiquidShaderManager.instance.disposeCache();
}
