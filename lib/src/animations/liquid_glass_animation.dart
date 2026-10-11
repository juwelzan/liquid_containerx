import 'package:flutter/material.dart';

/// Preset animation styles for entrance, exit, and idle liquid glass effects.
enum LiquidGlassAnimationType {
  // Entrance
  fadeScale,
  liquidDrop,
  morphIn,
  bounceIn,

  // Exit
  fadeOut,
  collapseOut,

  // Idle
  breathing,
  floating,
  shimmerSweep,
  rotatingLight,
  ripple,

  // Interaction
  pressSquash,
  wobble,
  stretch,
  pulse,
  magneticFollow,
}

/// Immutable configuration for liquid glass animations.
@immutable
class LiquidGlassAnimation {
  const LiquidGlassAnimation({
    this.type = LiquidGlassAnimationType.fadeScale,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
    this.repeat = false,
    this.reverse = false,
    this.onCompleted,
  });

  /// The animation effect type.
  final LiquidGlassAnimationType type;

  /// Duration of one animation cycle.
  final Duration duration;

  /// Easing interpolation curve.
  final Curve curve;

  /// Optional initial delay before triggering.
  final Duration delay;

  /// Whether the animation loops continuously.
  final bool repeat;

  /// Whether each alternating cycle runs in reverse.
  final bool reverse;

  /// Optional callback invoked upon animation completion.
  final VoidCallback? onCompleted;

  /// Idle breathing preset.
  static const LiquidGlassAnimation breathing = LiquidGlassAnimation(
    type: LiquidGlassAnimationType.breathing,
    duration: Duration(milliseconds: 2400),
    curve: Curves.easeInOutSine,
    repeat: true,
    reverse: true,
  );

  /// Floating vertical translation preset.
  static const LiquidGlassAnimation floating = LiquidGlassAnimation(
    type: LiquidGlassAnimationType.floating,
    duration: Duration(milliseconds: 3000),
    curve: Curves.easeInOutSine,
    repeat: true,
    reverse: true,
  );

  /// Dynamic rotating incident light preset.
  static const LiquidGlassAnimation rotatingLight = LiquidGlassAnimation(
    type: LiquidGlassAnimationType.rotatingLight,
    duration: Duration(milliseconds: 4000),
    curve: Curves.linear,
    repeat: true,
  );

  /// Shimmer highlight sweep preset.
  static const LiquidGlassAnimation shimmer = LiquidGlassAnimation(
    type: LiquidGlassAnimationType.shimmerSweep,
    duration: Duration(milliseconds: 2000),
    curve: Curves.easeInOut,
    repeat: true,
  );

  /// Fluid drop bounce entrance preset.
  static const LiquidGlassAnimation dropIn = LiquidGlassAnimation(
    type: LiquidGlassAnimationType.liquidDrop,
    duration: Duration(milliseconds: 750),
    curve: Curves.elasticOut,
  );
}

/// Widget that applies a [LiquidGlassAnimation] to its child.
class LiquidGlassAnimated extends StatefulWidget {
  const LiquidGlassAnimated({
    super.key,
    required this.animation,
    required this.child,
  });

  final LiquidGlassAnimation animation;
  final Widget child;

  @override
  State<LiquidGlassAnimated> createState() => _LiquidGlassAnimatedState();
}

class _LiquidGlassAnimatedState extends State<LiquidGlassAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animation.duration,
    );

    _curved = CurvedAnimation(
      parent: _controller,
      curve: widget.animation.curve,
    );

    if (widget.animation.repeat) {
      if (widget.animation.reverse) {
        _controller.repeat(reverse: true);
      } else {
        _controller.repeat();
      }
    } else {
      if (widget.animation.delay > Duration.zero) {
        Future.delayed(widget.animation.delay, () {
          if (mounted) {
            _controller.forward().then((_) {
              widget.animation.onCompleted?.call();
            });
          }
        });
      } else {
        _controller.forward().then((_) {
          widget.animation.onCompleted?.call();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;

    if (reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final v = _curved.value;
        switch (widget.animation.type) {
          case LiquidGlassAnimationType.fadeScale:
            return Opacity(
              opacity: v.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.8 + 0.2 * v, child: child),
            );

          case LiquidGlassAnimationType.liquidDrop:
            final translateY = (1.0 - v) * -40.0;
            return Opacity(
              opacity: v.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: child,
              ),
            );

          case LiquidGlassAnimationType.bounceIn:
            return Transform.scale(scale: v, child: child);

          case LiquidGlassAnimationType.fadeOut:
            return Opacity(opacity: (1.0 - v).clamp(0.0, 1.0), child: child);

          case LiquidGlassAnimationType.collapseOut:
            return Opacity(
              opacity: (1.0 - v).clamp(0.0, 1.0),
              child: Transform.scale(scale: 1.0 - 0.2 * v, child: child),
            );

          case LiquidGlassAnimationType.breathing:
            return Transform.scale(scale: 1.0 + 0.03 * v, child: child);

          case LiquidGlassAnimationType.floating:
            return Transform.translate(
              offset: Offset(0, -8.0 * v),
              child: child,
            );

          case LiquidGlassAnimationType.pulse:
            return Transform.scale(scale: 1.0 + 0.05 * v, child: child);

          case LiquidGlassAnimationType.wobble:
            final angle = (v - 0.5) * 0.06;
            return Transform.rotate(angle: angle, child: child);

          case LiquidGlassAnimationType.morphIn:
          case LiquidGlassAnimationType.shimmerSweep:
          case LiquidGlassAnimationType.rotatingLight:
          case LiquidGlassAnimationType.ripple:
          case LiquidGlassAnimationType.pressSquash:
          case LiquidGlassAnimationType.stretch:
          case LiquidGlassAnimationType.magneticFollow:
            return child!;
        }
      },
      child: widget.child,
    );
  }
}
