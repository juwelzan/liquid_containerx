import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/liquid_glass_settings.dart';
import '../physics/liquid_glass_physics.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// A liquid glass slider conforming to Flutter control semantics and keyboard accessibility.
class LiquidGlassSlider extends StatefulWidget {
  const LiquidGlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.settings,
    this.thumbSettings,
    this.activeColor = Colors.white,
    this.hapticFeedback = LiquidGlassHapticFeedback.selection,
    this.enabled = true,
  });

  /// The currently selected value [min..max].
  final double value;

  /// Called during dragging or arrow key manipulation.
  final ValueChanged<double>? onChanged;

  /// Minimum slider value.
  final double min;

  /// Maximum slider value.
  final double max;

  /// Optional discrete step divisions.
  final int? divisions;

  /// Optical settings for the slider track.
  final LiquidGlassSettings? settings;

  /// Optical settings for the sliding thumb.
  final LiquidGlassSettings? thumbSettings;

  /// Active filled track accent color.
  final Color activeColor;

  /// Tactile feedback triggered on value changes.
  final LiquidGlassHapticFeedback hapticFeedback;

  /// Whether the slider is interactive.
  final bool enabled;

  @override
  State<LiquidGlassSlider> createState() => _LiquidGlassSliderState();
}

class _LiquidGlassSliderState extends State<LiquidGlassSlider> {
  bool _isFocused = false;

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  void _updateFromDx(double dx, double width) {
    if (!widget.enabled || widget.onChanged == null || width <= 0) return;
    var fraction = (dx / width).clamp(0.0, 1.0);

    if (widget.divisions != null && widget.divisions! > 0) {
      fraction = (fraction * widget.divisions!).round() / widget.divisions!;
    }

    final newValue = widget.min + fraction * (widget.max - widget.min);
    if ((newValue - widget.value).abs() > 0.001) {
      widget.hapticFeedback.trigger();
      widget.onChanged!(newValue);
    }
  }

  void _step(double delta) {
    if (!widget.enabled || widget.onChanged == null) return;
    final stepSize = widget.divisions != null && widget.divisions! > 0
        ? (widget.max - widget.min) / widget.divisions!
        : (widget.max - widget.min) * 0.05;
    final newValue = (widget.value + delta * stepSize).clamp(
      widget.min,
      widget.max,
    );
    if ((newValue - widget.value).abs() > 0.001) {
      widget.hapticFeedback.trigger();
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    const trackHeight = 28.0;
    const thumbWidth = 28.0;

    return Semantics(
      slider: true,
      enabled: widget.enabled,
      value: widget.value.toStringAsFixed(2),
      increasedValue: (widget.value + 0.1)
          .clamp(widget.min, widget.max)
          .toStringAsFixed(2),
      decreasedValue: (widget.value - 0.1)
          .clamp(widget.min, widget.max)
          .toStringAsFixed(2),
      onIncrease: widget.enabled ? () => _step(1) : null,
      onDecrease: widget.enabled ? () => _step(-1) : null,
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (!widget.enabled) return KeyEventResult.ignored;
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _step(1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _step(-1);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final availableTravel = trackWidth - thumbWidth;
            final thumbLeft = (availableTravel * _fraction).clamp(
              0.0,
              availableTravel,
            );

            return GestureDetector(
              onHorizontalDragStart: (details) =>
                  _updateFromDx(details.localPosition.dx, trackWidth),
              onHorizontalDragUpdate: (details) =>
                  _updateFromDx(details.localPosition.dx, trackWidth),
              onTapDown: (details) =>
                  _updateFromDx(details.localPosition.dx, trackWidth),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 48, // Minimum accessible touch target
                child: Center(
                  child: SizedBox(
                    height: trackHeight,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Track background
                        Positioned.fill(
                          child: LiquidGlassContainer(
                            settings:
                                (widget.settings ??
                                        LiquidGlassPresets.controlCenter)
                                    .copyWith(
                                      borderWidth: _isFocused ? 1.5 : null,
                                    ),
                            shape: const LiquidGlassShape.capsule(),
                          ),
                        ),

                        // Active progress fill
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: thumbLeft + thumbWidth / 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              trackHeight / 2,
                            ),
                            child: ColoredBox(
                              color: widget.activeColor.withValues(alpha: 0.28),
                            ),
                          ),
                        ),

                        // Draggable thumb
                        Positioned(
                          left: thumbLeft,
                          top: 0,
                          bottom: 0,
                          width: thumbWidth,
                          child: LiquidGlassContainer(
                            settings:
                                widget.thumbSettings ??
                                LiquidGlassPresets.crystal.copyWith(
                                  thickness: 16.0,
                                  specularIntensity: 0.8,
                                ),
                            shape: const LiquidGlassShape.circle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
