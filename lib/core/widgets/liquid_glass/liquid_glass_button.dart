import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'liquid_glass_container.dart';

/// An Apple iOS-inspired liquid glass button with tactile touch feedback,
/// localized specular glint, and squircle edge curvature.
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.width,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = 24.0,
    this.shape,
    this.settings,
    this.tintColor,
    this.isLoading = false,
    this.enabled = true,
    this.enableStretch = false,
    this.enableGlow = true,
    this.glowColor = const Color(0x4DFFFFFF),
    this.fake = false,
    this.semanticLabel,
  }) : assert(
          child != null || icon != null || label != null,
          'Either child, icon, or label must be provided.',
        );

  /// Callback executed when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Custom widget content for the button body.
  final Widget? child;

  /// Leading icon widget.
  final Widget? icon;

  /// Text label widget.
  final Widget? label;

  /// Explicit width in logical pixels.
  final double? width;

  /// Explicit height in logical pixels. Defaults to 48.0.
  final double? height;

  /// Inset padding inside the button.
  final EdgeInsetsGeometry padding;

  /// Corner radius for the default squircle shape.
  final double borderRadius;

  /// Custom [LiquidShape] boundary override.
  final LiquidShape? shape;

  /// Custom shader configuration.
  final LiquidGlassSettings? settings;

  /// Glass tint color override.
  final Color? tintColor;

  /// Whether to display an inline circular progress indicator.
  final bool isLoading;

  /// Whether the button is interactable.
  final bool enabled;

  /// Whether dragging or tapping triggers organic squash and stretch.
  final bool enableStretch;

  /// Whether pointer touches cast a localized specular glow.
  final bool enableGlow;

  /// Color of the localized touch glow.
  final Color glowColor;

  /// Whether to force the lightweight [FakeGlass] fallback.
  final bool fake;

  /// Screen reader label for accessibility.
  final String? semanticLabel;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isInteractive => widget.enabled && widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails _) {
    if (!_isInteractive) return;
    HapticFeedback.lightImpact();
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isInteractive) return;
    _pressController.reverse();
  }

  void _handleTapCancel() {
    if (!_isInteractive) return;
    _pressController.reverse();
  }

  void _handleTap() {
    if (!_isInteractive) return;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSettings = (widget.settings ?? LiquidGlassStyles.button).copyWith(
      glassColor: widget.tintColor ??
          (_isHovered
              ? const Color(0x45FFFFFF)
              : const Color(0x30FFFFFF)),
      lightIntensity: _isHovered ? 1.0 : 0.85,
    );

    // Build inner content: Icon + Label, Child, or Spinner
    Widget innerContent;
    if (widget.isLoading) {
      innerContent = const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (widget.child != null) {
      innerContent = widget.child!;
    } else {
      innerContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            IconTheme.merge(
              data: const IconThemeData(color: Colors.white, size: 18),
              child: widget.icon!,
            ),
            if (widget.label != null) const SizedBox(width: 8),
          ],
          if (widget.label != null)
            DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              child: widget.label!,
            ),
        ],
      );
    }

    Widget button = LiquidGlassContainer(
      shape: widget.shape,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      width: widget.width,
      height: widget.height,
      settings: effectiveSettings,
      interactive: _isInteractive,
      enableGlow: widget.enableGlow,
      glowColor: widget.glowColor,
      enableStretch: widget.enableStretch,
      fake: widget.fake,
      child: Center(child: innerContent),
    );

    button = MouseRegion(
      onEnter: (_) {
        if (_isInteractive && mounted) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isInteractive && mounted) setState(() => _isHovered = false);
      },
      cursor: _isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: button,
        ),
      ),
    );

    if (!widget.enabled) {
      button = Opacity(opacity: 0.45, child: button);
    }

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: widget.semanticLabel,
      child: button,
    );
  }
}

