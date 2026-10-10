import 'package:flutter/widgets.dart';

/// Configuration for the glass appearance of a LiquidContainer.
class LiquidGlass {
  final double opacity;
  final double blur;
  final Color tintColor;
  final bool enableShaders;

  const LiquidGlass({
    this.opacity = 0.2,
    this.blur = 10.0,
    this.tintColor = const Color(0x33FFFFFF),
    this.enableShaders = true,
  })  : assert(opacity >= 0.0 && opacity <= 1.0),
        assert(blur >= 0.0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlass &&
        other.opacity == opacity &&
        other.blur == blur &&
        other.tintColor == tintColor &&
        other.enableShaders == enableShaders;
  }

  @override
  int get hashCode => Object.hash(opacity, blur, tintColor, enableShaders);
}

/// Global theme for liquid widgets.
class LiquidTheme extends InheritedWidget {
  final LiquidGlass defaultGlass;
  final bool reduceMotion;

  const LiquidTheme({
    Key? key,
    required Widget child,
    this.defaultGlass = const LiquidGlass(),
    this.reduceMotion = false,
  }) : super(key: key, child: child);

  static LiquidTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LiquidTheme>();
  }

  @override
  bool updateShouldNotify(LiquidTheme oldWidget) {
    return defaultGlass != oldWidget.defaultGlass || reduceMotion != oldWidget.reduceMotion;
  }
}
