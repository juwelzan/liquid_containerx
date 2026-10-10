import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/physics.dart';
import '../shapes/liquid_shape.dart';
import '../core/liquid_theme.dart';
import '../physics/liquid_physics.dart';
import '../core/liquid_controller.dart';
import '../rendering/liquid_painter.dart';
import '../rendering/shader_manager.dart';
import '../animation/shape_morpher.dart';

/// A container that renders with a liquid glass aesthetic and physics-based interaction.
class LiquidContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final LiquidShape shape;
  final LiquidGlass? glass;
  final LiquidPhysics physics;
  final LiquidController? controller;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  const LiquidContainer({
    Key? key,
    this.width,
    this.height,
    this.constraints,
    this.shape = LiquidShape.rectangle,
    this.glass,
    this.physics = const LiquidPhysics(),
    this.controller,
    this.child,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  State<LiquidContainer> createState() => _LiquidContainerState();
}

class _LiquidContainerState extends State<LiquidContainer> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _morphController;
  
  LiquidShape? _previousShape;
  LiquidShape? _currentShape;
  
  Offset _dragOffset = Offset.zero;
  SpringSimulation? _springSimulationX;
  SpringSimulation? _springSimulationY;

  FragmentShader? _fragmentShader;

  @override
  void initState() {
    super.initState();

    _initShader();
    _currentShape = widget.shape;
    _previousShape = widget.shape;
    
    _morphController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _morphController.addListener(() {
      setState(() {});
    });
    
    _animationController = AnimationController(vsync: this);
    _animationController.addListener(() {
      if (_springSimulationX != null && _springSimulationY != null) {
        setState(() {
          _dragOffset = Offset(
            _springSimulationX!.x(_animationController.value),
            _springSimulationY!.x(_animationController.value),
          );
        });
      }
    });
  }

  
  Future<void> _initShader() async {
    final glass = widget.glass ?? const LiquidGlass();
    if (!glass.enableShaders) return;

    await ShaderManager.loadLiquidGlassShader();
    
    if (mounted) {
      setState(() {
        _fragmentShader = ShaderManager.createLiquidGlassShader();
      });
    }
  }

  @override
  void didUpdateWidget(LiquidContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.glass?.enableShaders != oldWidget.glass?.enableShaders) {
      if (widget.glass?.enableShaders == true) {
        _initShader();
      } else {
        _fragmentShader?.dispose();
        _fragmentShader = null;
      }
    }
    if (oldWidget.shape != widget.shape) {
      _previousShape = _currentShape;
      _currentShape = widget.shape;
      _morphController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();

    _fragmentShader?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.physics.enabled) return;
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.physics.enabled) return;
    setState(() {
      _dragOffset += details.delta * widget.physics.viscosity;
      
      // Limit deformation
      double maxDef = widget.physics.maxDeformation * 100.0;
      if (_dragOffset.distance > maxDef) {
        _dragOffset = Offset.fromDirection(_dragOffset.direction, maxDef);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.physics.enabled) return;
    
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: widget.physics.elasticity * 500,
      damping: widget.physics.damping * 20,
    );

    _springSimulationX = SpringSimulation(spring, _dragOffset.dx, 0, details.velocity.pixelsPerSecond.dx);
    _springSimulationY = SpringSimulation(spring, _dragOffset.dy, 0, details.velocity.pixelsPerSecond.dy);

    _animationController.animateWith(
      _CombinedSimulation(_springSimulationX!, _springSimulationY!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LiquidTheme.of(context);
    final effectiveGlass = widget.glass ?? theme?.defaultGlass ?? const LiquidGlass();
    final bool reduceMotion = theme?.reduceMotion ?? false;

    Widget content = widget.child ?? const SizedBox.shrink();
    
    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }
    
    if (widget.alignment != null) {
      content = Align(alignment: widget.alignment!, child: content);
    }

    final shapeA = _previousShape ?? _currentShape!;
    final shapeB = _currentShape!;
    final t = reduceMotion ? 1.0 : _morphController.value;
    final dragOffset = reduceMotion ? Offset.zero : _dragOffset;

    Widget container = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (effectiveGlass.blur > 0)
            ClipPath(
              clipper: _LiquidClipper(shapeA, shapeB, t, dragOffset),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: effectiveGlass.blur, sigmaY: effectiveGlass.blur),
                child: const SizedBox.expand(),
              ),
            ),
          CustomPaint(
            painter: LiquidPainter(
              shapeA: shapeA,
              shapeB: shapeB,
              t: t,
              glass: effectiveGlass,
              dragOffset: dragOffset,
              shader: _fragmentShader,
            ),
            child: Transform.translate(
              offset: dragOffset * 0.5,
              child: content,
            ),
          ),
        ],
      ),
    );

    if (widget.constraints != null) {
      container = ConstrainedBox(constraints: widget.constraints!, child: container);
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: container,
    );
  }
}

class _LiquidClipper extends CustomClipper<Path> {
  final LiquidShape shapeA;
  final LiquidShape shapeB;
  final double t;
  final Offset dragOffset;

  _LiquidClipper(this.shapeA, this.shapeB, this.t, this.dragOffset);

  @override
  Path getClip(Size size) {
    return ShapeMorpher.morph(shapeA, shapeB, t, size, dragOffset);
  }

  @override
  bool shouldReclip(covariant _LiquidClipper oldClipper) => 
      shapeA != oldClipper.shapeA || 
      shapeB != oldClipper.shapeB || 
      t != oldClipper.t || 
      dragOffset != oldClipper.dragOffset;
}

class _CombinedSimulation extends Simulation {
  final SpringSimulation simX;
  final SpringSimulation simY;
  
  _CombinedSimulation(this.simX, this.simY);

  @override
  double x(double time) => time; // time drives the animation

  @override
  double dx(double time) => 1;

  @override
  bool isDone(double time) => simX.isDone(time) && simY.isDone(time);
}
