import 'package:flutter/material.dart';

import 'liquid_glass_theme_data.dart';

/// Applies a [LiquidGlassThemeData] to descendant liquid glass widgets.
class LiquidGlassTheme extends InheritedTheme {
  const LiquidGlassTheme({super.key, required this.data, required super.child});

  /// The active liquid glass theme configuration.
  final LiquidGlassThemeData data;

  /// Returns the nearest [LiquidGlassThemeData] in the widget tree, or derives
  /// an appropriate default based on [Theme.of(context).brightness].
  static LiquidGlassThemeData of(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<LiquidGlassTheme>();
    if (theme != null) {
      return theme.data;
    }

    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? LiquidGlassThemeData.dark()
        : LiquidGlassThemeData.light();
  }

  /// Returns the nearest [LiquidGlassThemeData] in the widget tree, if one exists.
  static LiquidGlassThemeData? maybeOf(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<LiquidGlassTheme>();
    return theme?.data;
  }

  @override
  bool updateShouldNotify(covariant LiquidGlassTheme oldWidget) =>
      oldWidget.data != data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return LiquidGlassTheme(data: data, child: child);
  }
}
