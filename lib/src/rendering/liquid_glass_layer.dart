import 'package:flutter/material.dart';

import '../core/liquid_glass_quality.dart';
import '../core/liquid_glass_settings.dart';

/// Scope provided by [LiquidGlassLayer] to descendant glass widgets.
class LiquidGlassLayerScope extends InheritedWidget {
  const LiquidGlassLayerScope({
    super.key,
    required this.settings,
    required this.quality,
    required this.enableSharedBackdrop,
    required super.child,
  });

  /// Default glass settings shared across all children in this layer.
  final LiquidGlassSettings? settings;

  /// Default quality level enforced within this layer.
  final LiquidGlassQuality? quality;

  /// Whether shared backdrop optimization is active for this subtree.
  final bool enableSharedBackdrop;

  /// Accesses the nearest [LiquidGlassLayerScope] ancestor, if present.
  static LiquidGlassLayerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LiquidGlassLayerScope>();
  }

  @override
  bool updateShouldNotify(covariant LiquidGlassLayerScope oldWidget) =>
      oldWidget.settings != settings ||
      oldWidget.quality != quality ||
      oldWidget.enableSharedBackdrop != enableSharedBackdrop;
}

/// A grouping widget that coordinates multiple liquid glass elements within the same region.
///
/// Wraps its subtree with a isolated [RepaintBoundary], synchronizes backdrop blur passes,
/// and propagates shared quality settings to prevent redundant screen re-captures.
class LiquidGlassLayer extends StatelessWidget {
  const LiquidGlassLayer({
    super.key,
    this.settings,
    this.quality,
    this.enableSharedBackdrop = true,
    required this.child,
  });

  /// Optional shared default settings for all glass containers in this layer.
  final LiquidGlassSettings? settings;

  /// Optional quality override for all children within this layer.
  final LiquidGlassQuality? quality;

  /// Whether to coordinate backdrop invalidations across sibling glass widgets.
  final bool enableSharedBackdrop;

  /// The widget subtree containing one or more liquid glass containers.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LiquidGlassLayerScope(
        settings: settings,
        quality: quality,
        enableSharedBackdrop: enableSharedBackdrop,
        child: child,
      ),
    );
  }
}

