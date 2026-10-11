import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_physics.dart';

/// Interactive wrapper that binds touch, drag, spring physics, and cursor tracking
/// to liquid glass elements.
class LiquidGlassInteractive extends StatefulWidget {
  const LiquidGlassInteractive({
    super.key,
    required this.shape,
    this.enableTouchSquash = true,
    this.enableDrag = false,
    this.maxDisplacement = 60.0,
    this.squashFactor = 0.96,
    this.hapticFeedback = LiquidGlassHapticFeedback.light,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onDragStart,
    this.onDragEnd,
    required this.builder,
  });

  final LiquidGlassShape shape;
  final bool enableTouchSquash;
  final bool enableDrag;
  final double maxDisplacement;
  final double squashFactor;
  final LiquidGlassHapticFeedback hapticFeedback;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  /// Builder receiving active translation offset, touch coordinate [0..1],
  /// touch intensity [0..1], and scale factor.
  final Widget Function(
    BuildContext context,
    Offset offset,
    Offset touchNormalized,
    double touchIntensity,
    double scale,
  )
  builder;

  @override
  State<LiquidGlassInteractive> createState() => _LiquidGlassInteractiveState();
}

class _LiquidGlassInteractiveState extends State<LiquidGlassInteractive>
    with TickerProviderStateMixin {
  late final AnimationController _springController;
  late final AnimationController _squashController;

  Offset _dragOffset = Offset.zero;
  Offset _dragStartPoint = Offset.zero;
  Offset _touchNormalized = const Offset(0.5, 0.5);
  double _touchIntensity = 0.0;
  bool _isDragging = false;
  int? _activePointer;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(_onSpringUpdate);

    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _squashController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _onSpringUpdate() {
    if (mounted) {
      setState(() {
        final t = _springController.value.clamp(0.0, 1.0);
        _dragOffset = Offset.lerp(_dragOffset, Offset.zero, t) ?? Offset.zero;
        if (_dragOffset.distance < 0.5) {
          _dragOffset = Offset.zero;
          _springController.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _springController.removeListener(_onSpringUpdate);
    _springController.dispose();
    _squashController.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event, BoxConstraints constraints) {
    if (_activePointer != null) return;
    _activePointer = event.pointer;

    final local = event.localPosition;
    final w = constraints.maxWidth > 0 ? constraints.maxWidth : 1.0;
    final h = constraints.maxHeight > 0 ? constraints.maxHeight : 1.0;

    _touchNormalized = Offset(
      (local.dx / w).clamp(0.0, 1.0),
      (local.dy / h).clamp(0.0, 1.0),
    );
    _touchIntensity = 1.0;
    _dragStartPoint = local;

    widget.hapticFeedback.trigger();

    if (widget.enableTouchSquash) {
      _squashController.forward();
    }
    setState(() {});
  }

  void _handlePointerMove(PointerMoveEvent event, BoxConstraints constraints) {
    if (event.pointer != _activePointer) return;

    final local = event.localPosition;
    final w = constraints.maxWidth > 0 ? constraints.maxWidth : 1.0;
    final h = constraints.maxHeight > 0 ? constraints.maxHeight : 1.0;

    _touchNormalized = Offset(
      (local.dx / w).clamp(0.0, 1.0),
      (local.dy / h).clamp(0.0, 1.0),
    );

    if (widget.enableDrag) {
      final delta = local - _dragStartPoint;
      if (!_isDragging && delta.distance > 8.0) {
        _isDragging = true;
        widget.onDragStart?.call();
      }

      if (_isDragging) {
        _springController.stop();
        _dragOffset = LiquidGlassSpring.rubberBandOffset(
          delta,
          maxDisplacement: widget.maxDisplacement,
        );
      }
    }

    setState(() {});
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;
    _finishInteraction();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _finishInteraction();
  }

  void _finishInteraction() {
    _activePointer = null;
    _touchIntensity = 0.0;
    _squashController.reverse();

    if (_isDragging) {
      _isDragging = false;
      widget.onDragEnd?.call();

      final simulation = SpringSimulation(
        const LiquidGlassSpring().description,
        0.0,
        1.0,
        0.0,
      );
      _springController.animateWith(simulation);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;

    final scale = reduceMotion
        ? 1.0
        : (1.0 - (1.0 - widget.squashFactor) * _squashController.value);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          onPointerDown: (e) => _handlePointerDown(e, constraints),
          onPointerMove: (e) => _handlePointerMove(e, constraints),
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerCancel,
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onLongPress: widget.onLongPress,
            behavior: HitTestBehavior.translucent,
            child: Transform.translate(
              offset: reduceMotion ? Offset.zero : _dragOffset,
              child: Transform.scale(
                scale: scale,
                child: widget.builder(
                  context,
                  _dragOffset,
                  _touchNormalized,
                  _touchIntensity,
                  scale,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
