import re

# Fix liquid_painter.dart
with open('lib/src/rendering/liquid_painter.dart', 'r') as f:
    text = f.read()
text = re.sub(r"import 'dart:ui';\n", "", text)
text = re.sub(r"import '../shapes/liquid_path_builder.dart';\n", "", text)
text = text.replace('withOpacity(glass.opacity)', 'withValues(alpha: glass.opacity)')
with open('lib/src/rendering/liquid_painter.dart', 'w') as f:
    f.write(text)

# Fix liquid_container.dart
with open('lib/src/widgets/liquid_container.dart', 'r') as f:
    text = f.read()
text = re.sub(r"import '../shapes/liquid_path_builder.dart';\n", "", text)
with open('lib/src/widgets/liquid_container.dart', 'w') as f:
    f.write(text)

# Fix liquid_path_builder.dart
with open('lib/src/shapes/liquid_path_builder.dart', 'r') as f:
    text = f.read()
text = re.sub(r"final w = shiftedRect\.width;\n\s*final h = shiftedRect\.height;\n", "", text)
with open('lib/src/shapes/liquid_path_builder.dart', 'w') as f:
    f.write(text)
