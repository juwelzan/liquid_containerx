import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// A draggable liquid glass bottom sheet with snap detents, grab handle,
/// and keyboard insets avoidance.
class LiquidGlassBottomSheet extends StatelessWidget {
  const LiquidGlassBottomSheet({
    super.key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.92,
    this.snap = true,
    this.snapSizes = const [0.25, 0.5, 0.92],
    this.settings,
    this.shape = const LiquidGlassShape.squircle(cornerRadius: 32),
    this.showDragHandle = true,
    required this.builder,
  });

  /// The initial fractional height of the sheet [0.0..1.0].
  final double initialChildSize;

  /// The minimum fractional height of the sheet [0.0..1.0].
  final double minChildSize;

  /// The maximum fractional height of the sheet [0.0..1.0].
  final double maxChildSize;

  /// Whether the sheet snaps to closest detents when released.
  final bool snap;

  /// List of fractional height detents the sheet snaps to.
  final List<double> snapSizes;

  /// Optical settings for the sheet glass. Defaults to [LiquidGlassPresets.iosMaps].
  final LiquidGlassSettings? settings;

  /// Boundary shape for the top edges of the sheet.
  final LiquidGlassShape shape;

  /// Whether to display an iOS pill grab handle at the top.
  final bool showDragHandle;

  /// Builder providing the scroll controller for coordinated scrolling.
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  /// Helper to display this bottom sheet as a modal overlay with blur backdrop.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(
      BuildContext context,
      ScrollController scrollController,
    )
    builder,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.92,
    List<double> snapSizes = const [0.25, 0.5, 0.92],
    LiquidGlassSettings? settings,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: isDismissible,
      builder: (modalContext) {
        return LiquidGlassBottomSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          snapSizes: snapSizes,
          settings: settings,
          builder: builder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: snap,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: LiquidGlassContainer(
            settings: settings ?? LiquidGlassPresets.iosMaps,
            shape: shape,
            child: Column(
              children: [
                if (showDragHandle) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Expanded(child: builder(context, scrollController)),
              ],
            ),
          ),
        );
      },
    );
  }
}
