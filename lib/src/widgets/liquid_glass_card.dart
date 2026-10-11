import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../physics/liquid_glass_physics.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// A structured liquid glass card widget supporting header, content, and action sections.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.content,
    this.actions,
    this.settings,
    this.shape = const LiquidGlassShape.squircle(cornerRadius: 24),
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.interactive = false,
    this.onTap,
    this.onLongPress,
    this.hapticFeedback = LiquidGlassHapticFeedback.light,
  });

  /// Widget placed before the title in the header row.
  final Widget? leading;

  /// Primary card header title.
  final Widget? title;

  /// Secondary subtitle underneath the title.
  final Widget? subtitle;

  /// Widget trailing at the end of the header row (e.g. menu button or status badge).
  final Widget? trailing;

  /// Main body content of the card.
  final Widget? content;

  /// Action buttons aligned at the bottom.
  final List<Widget>? actions;

  /// Optical settings for the card. Defaults to [LiquidGlassPresets.iosMaps].
  final LiquidGlassSettings? settings;

  /// Boundary shape of the card.
  final LiquidGlassShape shape;

  /// Interior padding.
  final EdgeInsetsGeometry padding;

  /// Exterior margin.
  final EdgeInsetsGeometry? margin;

  /// Whether the card squashes on touch.
  final bool interactive;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Tactile feedback on tap.
  final LiquidGlassHapticFeedback hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final hasHeader =
        leading != null ||
        title != null ||
        subtitle != null ||
        trailing != null;

    return LiquidGlassContainer(
      settings: settings ?? LiquidGlassPresets.iosMaps,
      shape: shape,
      margin: margin,
      padding: padding,
      interactive: interactive,
      onTap: onTap,
      onLongPress: onLongPress,
      hapticFeedback: hapticFeedback,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader) ...[
            Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          child: title!,
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            if (content != null || (actions != null && actions!.isNotEmpty))
              const SizedBox(height: 14),
          ],
          if (content != null) ...[
            DefaultTextStyle(
              style: const TextStyle(fontSize: 14, color: Colors.white),
              child: content!,
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
          ],
        ],
      ),
    );
  }
}
