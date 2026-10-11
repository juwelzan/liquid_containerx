import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// A modal dialog surfaced in a floating liquid glass squircle with blur barrier.
class LiquidGlassDialog extends StatelessWidget {
  const LiquidGlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.settings,
    this.shape = const LiquidGlassShape.squircle(cornerRadius: 28),
    this.padding = const EdgeInsets.all(24),
  });

  /// The title widget of the dialog.
  final Widget? title;

  /// The main content widget.
  final Widget? content;

  /// Optional action buttons (e.g. Cancel, Confirm).
  final List<Widget>? actions;

  /// Optical settings for the dialog container. Defaults to [LiquidGlassPresets.iosMaps].
  final LiquidGlassSettings? settings;

  /// Boundary shape for the dialog.
  final LiquidGlassShape shape;

  /// Padding around the dialog contents.
  final EdgeInsetsGeometry padding;

  /// Displays this dialog modally with a blurred background barrier.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    LiquidGlassSettings? settings,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black45,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: LiquidGlassDialog(
            title: title,
            content: content,
            actions: actions,
            settings: settings,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        child: Material(
          color: Colors.transparent,
          child: LiquidGlassContainer(
            settings: settings ?? LiquidGlassPresets.iosMaps,
            shape: shape,
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  DefaultTextStyle(
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ) ??
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                    child: title!,
                  ),
                  const SizedBox(height: 14),
                ],
                if (content != null) ...[
                  DefaultTextStyle(
                    style:
                        Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70) ??
                        const TextStyle(fontSize: 14, color: Colors.white70),
                    child: content!,
                  ),
                  const SizedBox(height: 20),
                ],
                if (actions != null && actions!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
