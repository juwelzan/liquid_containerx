import 'package:flutter/material.dart';

import '../core/liquid_glass_controller.dart';
import '../core/liquid_glass_quality.dart';
import '../core/liquid_glass_settings.dart';
import '../physics/liquid_glass_interaction.dart';
import '../physics/liquid_glass_physics.dart';
import '../rendering/liquid_glass_layer.dart';
import '../rendering/liquid_glass_renderer.dart';
import '../shapes/liquid_glass_shape.dart';
import '../theme/liquid_glass_theme.dart';

/// The foundational liquid glass container widget.
///
/// Features hardware-accelerated background blur, GLSL fragment shader refraction,
/// specular edge rim lighting, squircle continuous curvature, and interactive spring dynamics.
class LiquidGlassContainer extends StatefulWidget {
  const LiquidGlassContainer({
    super.key,
    this.settings,
    this.shape,
    this.quality,
    this.controller,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.alignment,
    this.interactive = false,
    this.enableDrag = false,
    this.hapticFeedback = LiquidGlassHapticFeedback.light,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.morphedPath,
    this.semanticLabel,
    this.child,
  });

  /// Optical and physical parameters for this container.
  /// If null, derives from the nearest [LiquidGlassLayerScope] or [LiquidGlassTheme].
  final LiquidGlassSettings? settings;

  /// The boundary shape. If null, derives from [LiquidGlassTheme.shape].
  final LiquidGlassShape? shape;

  /// The rendering quality level.
  final LiquidGlassQuality? quality;

  /// Optional controller to programmatically manipulate touch coordinates and settings.
  final LiquidGlassController? controller;

  /// Explicit container width in logical pixels.
  final double? width;

  /// Explicit container height in logical pixels.
  final double? height;

  /// Empty space to inscribe inside the glass boundary.
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the outside of the container.
  final EdgeInsetsGeometry? margin;

  /// Align the child within the container.
  final AlignmentGeometry? alignment;

  /// Whether to enable touch squash, scale, and localized specular highlights.
  final bool interactive;

  /// Whether dragging this container engages elastic rubber-band springs.
  final bool enableDrag;

  /// Haptic feedback triggered on pointer down.
  final LiquidGlassHapticFeedback hapticFeedback;

  /// Callback when the container is tapped.
  final VoidCallback? onTap;

  /// Callback when the container is double-tapped.
  final VoidCallback? onDoubleTap;

  /// Callback when the container is long-pressed.
  final VoidCallback? onLongPress;

  /// Optional pre-computed morph path override.
  final Path? morphedPath;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  /// The widget content rendered inside the glass container.
  final Widget? child;

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  AnimationController? _idleController;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerUpdate);
      widget.controller?.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    _idleController?.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final layerScope = LiquidGlassLayerScope.maybeOf(context);

    final effectiveQuality =
        widget.quality ?? layerScope?.quality ?? theme.quality;

    var effectiveSettings =
        widget.controller?.settings ??
        widget.settings ??
        layerScope?.settings ??
        theme.settings;

    effectiveSettings = effectiveSettings.copyWith(quality: effectiveQuality);

    final effectiveShape = widget.shape ?? theme.shape;

    Widget content = widget.child ?? const SizedBox.shrink();

    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }

    if (widget.alignment != null) {
      content = Align(alignment: widget.alignment!, child: content);
    }

    Widget glassSurface({
      Offset touchPos = const Offset(0.5, 0.5),
      double touchIntensity = 0.0,
    }) {
      final ctrlTouch = widget.controller?.touchPosition;
      final ctrlIntensity = widget.controller?.touchIntensity ?? 0.0;
      final activeTouch = ctrlIntensity > touchIntensity
          ? (ctrlTouch ?? touchPos)
          : touchPos;
      final activeIntensity = ctrlIntensity > touchIntensity
          ? ctrlIntensity
          : touchIntensity;

      return LiquidGlassRenderer(
        settings: effectiveSettings,
        shape: effectiveShape,
        touchPosition: activeTouch,
        touchIntensity: activeIntensity,
        morphedPath: widget.morphedPath,
        child: content,
      );
    }

    Widget result;
    if (widget.interactive || widget.enableDrag || widget.onTap != null) {
      result = LiquidGlassInteractive(
        shape: effectiveShape,
        enableTouchSquash: widget.interactive,
        enableDrag: widget.enableDrag,
        hapticFeedback: widget.hapticFeedback,
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        builder: (context, offset, touchNormalized, touchIntensity, scale) {
          return glassSurface(
            touchPos: touchNormalized,
            touchIntensity: touchIntensity,
          );
        },
      );
    } else {
      result = glassSurface();
    }

    if (widget.width != null || widget.height != null) {
      result = SizedBox(
        width: widget.width,
        height: widget.height,
        child: result,
      );
    }

    if (widget.margin != null) {
      result = Padding(padding: widget.margin!, child: result);
    }

    if (widget.semanticLabel != null) {
      result = Semantics(
        label: widget.semanticLabel,
        container: true,
        child: result,
      );
    }

    return result;
  }
}
