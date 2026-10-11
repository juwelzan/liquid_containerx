import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'liquid_glass_container.dart';

/// An Apple iOS Control Center-style glass panel widget providing optical
/// depth, edge lensing, and modular header/content/footer layouts.
class LiquidGlassPanel extends StatelessWidget {
  const LiquidGlassPanel({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.content,
    this.footer,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 28.0,
    this.shape,
    this.settings,
    this.tintColor,
    this.interactive = true,
    this.enableStretch = false,
    this.onTap,
    this.fake = false,
  });

  /// Primary title widget.
  final Widget? title;

  /// Subtitle or status descriptor widget.
  final Widget? subtitle;

  /// Leading icon or badge widget.
  final Widget? leading;

  /// Trailing control or status indicator (e.g. switch or chevron).
  final Widget? trailing;

  /// Main panel content body.
  final Widget? content;

  /// Optional bottom action bar or footer widget.
  final Widget? footer;

  /// Inset space inside the panel.
  final EdgeInsetsGeometry padding;

  /// Empty space surrounding the panel.
  final EdgeInsetsGeometry? margin;

  /// Explicit panel width in logical pixels.
  final double? width;

  /// Explicit panel height in logical pixels.
  final double? height;

  /// Corner radius for the default squircle shape.
  final double borderRadius;

  /// Custom geometric shape override.
  final LiquidShape? shape;

  /// Optical shader configuration.
  final LiquidGlassSettings? settings;

  /// Glass tint color override.
  final Color? tintColor;

  /// Whether pointer touches activate localized specular highlights.
  final bool interactive;

  /// Whether dragging engages elastic squash-and-stretch dynamics.
  final bool enableStretch;

  /// Callback when the entire panel surface is tapped.
  final VoidCallback? onTap;

  /// Whether to force the lightweight [FakeGlass] fallback.
  final bool fake;

  @override
  Widget build(BuildContext context) {
    final effectiveSettings = settings ?? LiquidGlassStyles.controlCenter;

    final hasHeader =
        title != null || subtitle != null || leading != null || trailing != null;

    final panelBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasHeader) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        child: title!,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: const TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          if (content != null || footer != null) const SizedBox(height: 16),
        ],
        ?content,
        if (footer != null) ...[
          const SizedBox(height: 16),
          footer!,
        ],
      ],
    );

    Widget panel = LiquidGlassContainer(
      shape: shape,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      settings: effectiveSettings,
      tintColor: tintColor,
      interactive: interactive,
      enableStretch: enableStretch,
      fake: fake,
      child: panelBody,
    );

    if (onTap != null) {
      panel = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: panel,
      );
    }

    return panel;
  }
}
