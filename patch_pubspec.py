with open('pubspec.yaml', 'r') as f:
    text = f.read()

if 'shaders:' not in text:
    text += """
  shaders:
    - shaders/liquid_glass.frag
"""
    with open('pubspec.yaml', 'w') as f:
        f.write(text)
