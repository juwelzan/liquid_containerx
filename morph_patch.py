import re
with open('lib/src/widgets/liquid_container.dart', 'r') as f:
    contents = f.read()

# Add animation controller for shape morph
init_state_replacement = '''  late AnimationController _morphController;
  LiquidShape? _previousShape;
  LiquidShape? _currentShape;
  
  @override
  void initState() {
    super.initState();
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

  @override
  void didUpdateWidget(LiquidContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape != widget.shape) {
      _previousShape = _currentShape;
      _currentShape = widget.shape;
      _morphController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _animationController.dispose();
    super.dispose();
  }
'''

contents = re.sub(
    r'@override\s+void initState\(\)\s*\{.*?super\.dispose\(\);\s*\}',
    init_state_replacement,
    contents,
    flags=re.DOTALL
)

# Update _LiquidClipper to accept two shapes and a 't'
# Also update LiquidPainter
contents = contents.replace(
    'class _LiquidClipper extends CustomClipper<Path> {',
    '''class _LiquidClipper extends CustomClipper<Path> {
  final LiquidShape shapeA;
  final LiquidShape shapeB;
  final double t;'''
)

contents = contents.replace(
    'final LiquidShape shape;',
    ''
)

contents = contents.replace(
    '_LiquidClipper(this.shape, this.dragOffset);',
    '_LiquidClipper(this.shapeA, this.shapeB, this.t, this.dragOffset);'
)

# Use morph inside clipper
contents = contents.replace(
    'return LiquidPathBuilder.buildPath(shape, size, dragOffset);',
    'return ShapeMorpher.morph(shapeA, shapeB, t, size, dragOffset);'
)

# Update painter to use morph too
# Well, wait, I need to pass the morphed path to the painter, or pass shapes to the painter.
# Let's write the file manually using python to ensure safety.

