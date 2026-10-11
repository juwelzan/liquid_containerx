import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/liquid_glass_settings.dart';
import '../physics/liquid_glass_physics.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// An iOS-inspired liquid glass toggle switch with spring animation and accessibility semantics.
class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF34C759), // iOS green
    this.inactiveColor = const Color(0xFF3A3A3C),
    this.settings,
    this.thumbSettings,
    this.hapticFeedback = LiquidGlassHapticFeedback.light,
    this.enabled = true,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// Track tint color when active.
  final Color activeColor;

  /// Track tint color when inactive.
  final Color inactiveColor;

  /// Optical settings for the track.
  final LiquidGlassSettings? settings;

  /// Optical settings for the thumb.
  final LiquidGlassSettings? thumbSettings;

  /// Tactile feedback triggered on toggle.
  final LiquidGlassHapticFeedback hapticFeedback;

  /// Whether this switch is interactive.
  final bool enabled;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled || widget.onChanged == null) return;
    widget.hapticFeedback.trigger();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    const trackWidth = 54.0;
    const trackHeight = 32.0;
    const thumbSize = 26.0;
    const padding = 3.0;
    const travel = trackWidth - thumbSize - padding * 2;

    return Semantics(
      toggled: widget.value,
      enabled: widget.enabled,
      button: true,
      onTap: widget.enabled ? _toggle : null,
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (!widget.enabled) return KeyEventResult.ignored;
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.space ||
                  event.logicalKey == LogicalKeyboardKey.enter)) {
            _toggle();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 58,
            height: 48, // Accessible touch target
            child: Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  final t = _animation.value;
                  final trackTint = Color.lerp(
                    widget.inactiveColor,
                    widget.activeColor,
                    t,
                  )!;

                  final effectiveSettings =
                      (widget.settings ?? LiquidGlassPresets.controlCenter)
                          .copyWith(
                            tintColor: trackTint,
                            tintOpacity: 0.35 + t * 0.25,
                            borderWidth: _isFocused ? 1.5 : null,
                          );

                  return SizedBox(
                    width: trackWidth,
                    height: trackHeight,
                    child: Stack(
                      children: [
                        // Track
                        Positioned.fill(
                          child: LiquidGlassContainer(
                            settings: effectiveSettings,
                            shape: const LiquidGlassShape.capsule(),
                          ),
                        ),

                        // Sliding thumb
                        Positioned(
                          left: padding + travel * t,
                          top: padding,
                          width: thumbSize,
                          height: thumbSize,
                          child: LiquidGlassContainer(
                            settings:
                                widget.thumbSettings ??
                                LiquidGlassPresets.clearGlass.copyWith(
                                  thickness: 14.0,
                                  specularIntensity: 0.75,
                                  tintOpacity: 0.15,
                                ),
                            shape: const LiquidGlassShape.circle(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
