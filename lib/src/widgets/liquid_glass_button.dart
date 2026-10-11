import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/liquid_glass_settings.dart';
import '../physics/liquid_glass_physics.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// An interactive liquid glass button with tactile haptic response,
/// focus highlight rings, loading state, and accessible semantics.
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.settings,
    this.shape = const LiquidGlassShape.squircle(cornerRadius: 16),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.isLoading = false,
    this.isEnabled = true,
    this.hapticFeedback = LiquidGlassHapticFeedback.light,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    required this.child,
  });

  /// Called when the button is tapped. If null or [isEnabled] is false, the button is disabled.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Optical settings for this button. Defaults to [LiquidGlassPresets.minimalPill].
  final LiquidGlassSettings? settings;

  /// Boundary shape of the button.
  final LiquidGlassShape shape;

  /// Padding inscribed inside the button.
  final EdgeInsetsGeometry padding;

  /// Shows a circular loading spinner instead of the child content.
  final bool isLoading;

  /// Whether the button is enabled for user interaction.
  final bool isEnabled;

  /// Tactile feedback triggered on tap.
  final LiquidGlassHapticFeedback hapticFeedback;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether this button receives focus on initial mount.
  final bool autofocus;

  /// Accessibility semantic label.
  final String? semanticLabel;

  /// The button label or icon widget.
  final Widget child;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  bool _isFocused = false;

  bool get _effectiveEnabled =>
      widget.isEnabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveSettings =
        (widget.settings ?? LiquidGlassPresets.minimalPill).copyWith(
          tintOpacity: _effectiveEnabled ? null : 0.08,
          borderWidth: _isFocused ? 2.0 : null,
          borderGradient: _isFocused
              ? const LinearGradient(colors: [Colors.white, Colors.cyanAccent])
              : null,
        );

    Widget content = widget.isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : widget.child;

    return Semantics(
      button: true,
      enabled: _effectiveEnabled,
      label: widget.semanticLabel,
      child: Focus(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (!_effectiveEnabled) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.hapticFeedback.trigger();
            widget.onPressed?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Opacity(
            opacity: _effectiveEnabled ? 1.0 : 0.5,
            child: LiquidGlassContainer(
              settings: effectiveSettings,
              shape: widget.shape,
              interactive: _effectiveEnabled,
              hapticFeedback: widget.hapticFeedback,
              padding: widget.padding,
              onTap: _effectiveEnabled ? widget.onPressed : null,
              onLongPress: _effectiveEnabled ? widget.onLongPress : null,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
