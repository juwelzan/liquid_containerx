import 'package:flutter/widgets.dart';

/// Configuration for the glass appearance of a LiquidContainer.
class LiquidGlass {
  final double opacity;
  final double blur;
  final Color tintColor;
  final bool enableShaders;
  final double distortionStrength;
  final double highlightIntensity;

  const LiquidGlass({
    this.opacity = 0.2,
    this.blur = 10.0,
    this.tintColor = const Color(0x33FFFFFF),
    this.enableShaders = true,
    this.distortionStrength = 0.05,
    this.highlightIntensity = 0.3,
  })  : assert(opacity >= 0.0 && opacity <= 1.0),
        assert(blur >= 0.0),
        assert(distortionStrength >= 0.0 && distortionStrength <= 1.0),
        assert(highlightIntensity >= 0.0 && highlightIntensity <= 1.0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlass &&
        other.opacity == opacity &&
        other.blur == blur &&
        other.tintColor == tintColor &&
        other.enableShaders == enableShaders &&
        other.distortionStrength == distortionStrength &&
        other.highlightIntensity == highlightIntensity;
  }

  @override
  int get hashCode => Object.hash(
      opacity, blur, tintColor, enableShaders, distortionStrength, highlightIntensity);
}

/// Global theme for liquid widgets.
class LiquidTheme extends InheritedWidget {
  final LiquidGlass defaultGlass;
  final bool reduceMotion;

  const LiquidTheme({
    super.key,
    required super.child,
    this.defaultGlass = const LiquidGlass(),
    this.reduceMotion = false,
  });

  static LiquidTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LiquidTheme>();
  }

  @override
  bool updateShouldNotify(LiquidTheme oldWidget) {
    return defaultGlass != oldWidget.defaultGlass || reduceMotion != oldWidget.reduceMotion;
  }
}
