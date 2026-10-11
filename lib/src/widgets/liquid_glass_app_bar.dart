import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// A translucent liquid glass navigation app bar conforming to [PreferredSizeWidget].
///
/// Blurs underlying scrollable content, accommodates the status bar safe area,
/// and draws a subtle bottom rim highlight.
class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.settings,
    this.centerTitle = true,
    this.toolbarHeight = kToolbarHeight,
    this.elevation = 0,
  });

  /// The primary widget displayed in the app bar.
  final Widget? title;

  /// A widget to display before the [title].
  final Widget? leading;

  /// Widgets to display in a row after the [title] widget.
  final List<Widget>? actions;

  /// This widget appears across the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// Optical settings for the glass bar. Defaults to [LiquidGlassPresets.iosMaps].
  final LiquidGlassSettings? settings;

  /// Whether the title should be centered.
  final bool centerTitle;

  /// Height of the toolbar component.
  final double toolbarHeight;

  /// Elevation shadow intensity.
  final double elevation;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(toolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final totalHeight = preferredSize.height + topPadding;

    final effectiveSettings = (settings ?? LiquidGlassPresets.iosMaps).copyWith(
      borderWidth: 0.5,
    );

    return SizedBox(
      height: totalHeight,
      child: LiquidGlassContainer(
        settings: effectiveSettings,
        shape: const LiquidGlassShape.roundedRectangle(
          borderRadius: BorderRadius.zero,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: toolbarHeight,
                child: NavigationToolbar(
                  leading: leading,
                  middle: title != null
                      ? DefaultTextStyle(
                          style:
                              Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600) ??
                              const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                          child: title!,
                        )
                      : null,
                  trailing: actions != null
                      ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                      : null,
                  centerMiddle: centerTitle,
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}
