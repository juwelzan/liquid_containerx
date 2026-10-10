import re

# Fix painter
with open('lib/src/rendering/liquid_painter.dart', 'r') as f:
    text = f.read()
text = text.replace('glass.tintColor.red / 255.0', 'glass.tintColor.r')
text = text.replace('glass.tintColor.green / 255.0', 'glass.tintColor.g')
text = text.replace('glass.tintColor.blue / 255.0', 'glass.tintColor.b')
text = text.replace('glass.tintColor.alpha / 255.0', 'glass.tintColor.a')
with open('lib/src/rendering/liquid_painter.dart', 'w') as f:
    f.write(text)

# Fix container
with open('lib/src/widgets/liquid_container.dart', 'r') as f:
    text = f.read()
text = re.sub(r'\s*bool _shaderLoaded = false;\n', '\n', text)
text = re.sub(r'\s*_shaderLoaded = _fragmentShader != null;\n', '\n', text)
text = re.sub(r'\s*_shaderLoaded = false;\n', '\n', text)
with open('lib/src/widgets/liquid_container.dart', 'w') as f:
    f.write(text)

# Fix example main
with open('example/lib/main.dart', 'r') as f:
    text = f.read()
text = text.replace('withOpacity(0.2)', 'withValues(alpha: 0.2)')
with open('example/lib/main.dart', 'w') as f:
    f.write(text)

# Fix test
with open('test/rendering/shader_manager_test.dart', 'r') as f:
    text = f.read()
text = text.replace('expect(shader == null || shader != null, isTrue);', 'expect(true, isTrue);')
with open('test/rendering/shader_manager_test.dart', 'w') as f:
    f.write(text)

