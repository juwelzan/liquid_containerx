import re

with open('lib/src/widgets/liquid_container.dart', 'r') as f:
    text = f.read()

# Add imports
if 'import \'../rendering/shader_manager.dart\';' not in text:
    text = text.replace('import \'../rendering/liquid_painter.dart\';', 
                        'import \'../rendering/liquid_painter.dart\';\nimport \'../rendering/shader_manager.dart\';')

# Add state variables
state_vars = """
  FragmentShader? _fragmentShader;
  bool _shaderLoaded = false;
"""
text = re.sub(r'SpringSimulation\? _springSimulationY;\n', 'SpringSimulation? _springSimulationY;\n' + state_vars, text)

# Add init logic for shader
init_shader = """
    _initShader();
"""
text = re.sub(r'super\.initState\(\);\n', 'super.initState();\n' + init_shader, text)

# Method for init
init_method = """
  Future<void> _initShader() async {
    final glass = widget.glass ?? const LiquidGlass();
    if (!glass.enableShaders) return;

    await ShaderManager.loadLiquidGlassShader();
    
    if (mounted) {
      setState(() {
        _fragmentShader = ShaderManager.createLiquidGlassShader();
        _shaderLoaded = _fragmentShader != null;
      });
    }
  }
"""
text = re.sub(r'@override\s+void didUpdateWidget', init_method + '\n  @override\n  void didUpdateWidget', text)

# Handle didUpdateWidget for shaders
did_update = """
    if (widget.glass?.enableShaders != oldWidget.glass?.enableShaders) {
      if (widget.glass?.enableShaders == true) {
        _initShader();
      } else {
        _fragmentShader?.dispose();
        _fragmentShader = null;
        _shaderLoaded = false;
      }
    }
"""
text = re.sub(r'super\.didUpdateWidget\(oldWidget\);\n', 'super.didUpdateWidget(oldWidget);\n' + did_update, text)

# Handle dispose for shaders
dispose = """
    _fragmentShader?.dispose();
"""
text = re.sub(r'_morphController\.dispose\(\);\n', '_morphController.dispose();\n' + dispose, text)

# Pass shader to painter
text = text.replace(
    'dragOffset: dragOffset,',
    'dragOffset: dragOffset,\n              shader: _fragmentShader,'
)

with open('lib/src/widgets/liquid_container.dart', 'w') as f:
    f.write(text)
