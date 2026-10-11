import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'liquid_glass_container.dart';

/// Specification for a single item in [LiquidGlassNavigationBar].
class LiquidGlassNavItem {
  const LiquidGlassNavItem({
    required this.icon,
    this.label,
    this.activeIcon,
    this.badgeCount,
    this.tooltip,
  });

  /// The icon displayed for the item.
  final Widget icon;

  /// Optional active icon displayed when selected.
  final Widget? activeIcon;

  /// Optional text label under or beside the icon.
  final String? label;

  /// Optional notification badge count.
  final int? badgeCount;

  /// Tooltip message for desktop and screen readers.
  final String? tooltip;
}

/// An Apple iOS-inspired floating liquid glass navigation bar with a smooth
/// sliding glass selection pill and haptic feedback.
class LiquidGlassNavigationBar extends StatelessWidget {
  const LiquidGlassNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.settings,
    this.indicatorSettings,
    this.height = 64.0,
    this.borderRadius = 32.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.padding = const EdgeInsets.all(6),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0xB3FFFFFF),
    this.fake = false,
  }) : assert(items.length >= 2, 'Must provide at least 2 items.');

  /// The list of items displayed in the navigation bar.
  final List<LiquidGlassNavItem> items;

  /// The index of the currently active item.
  final int currentIndex;

  /// Callback when an item is tapped.
  final ValueChanged<int> onTap;

  /// Optical settings for the parent glass container.
  final LiquidGlassSettings? settings;

  /// Optical settings for the active selection pill.
  final LiquidGlassSettings? indicatorSettings;

  /// Height of the floating navigation bar.
  final double height;

  /// Corner radius for the continuous squircle pill boundary.
  final double borderRadius;

  /// Empty space surrounding the navigation bar.
  final EdgeInsetsGeometry margin;

  /// Inset space inside the navigation bar.
  final EdgeInsetsGeometry padding;

  /// Color of the active icon and label.
  final Color activeColor;

  /// Color of inactive icons and labels.
  final Color inactiveColor;

  /// Whether to force the lightweight [FakeGlass] fallback.
  final bool fake;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;

    final effectiveSettings = settings ?? LiquidGlassStyles.navigationPill;
    final effectiveIndicatorSettings = indicatorSettings ??
        effectiveSettings.copyWith(
          glassColor: const Color(0x4DFFFFFF),
          lightIntensity: 0.95,
          thickness: 10,
        );

    final navContent = Padding(
      padding: margin,
      child: FocusTraversalGroup(
        child: SizedBox(
          height: height,
          child: LiquidGlassContainer(
            borderRadius: borderRadius,
            settings: effectiveSettings,
            padding: padding,
            fake: fake,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemCount = items.length;
                final itemWidth = constraints.maxWidth / itemCount;
                final indicatorLeft = itemWidth * currentIndex;

                return SizedBox(
                  height: height - 12,
                  child: Stack(
                    children: [
                      // Animated sliding active glass pill
                      AnimatedPositioned(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: indicatorLeft,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: LiquidGlassContainer(
                          borderRadius: borderRadius - 6,
                          settings: effectiveIndicatorSettings,
                          fake: fake,
                          child: const SizedBox.expand(),
                        ),
                      ),

                      // Navigation Items Row
                      Row(
                        children: List.generate(itemCount, (index) {
                          final item = items[index];
                          final isSelected = index == currentIndex;

                          return SizedBox(
                            width: itemWidth,
                            height: height - 12,
                            child: Semantics(
                              selected: isSelected,
                              button: true,
                              label: item.label ?? 'Tab ${index + 1}',
                              child: InkWell(
                                onTap: () {
                                  if (index != currentIndex) {
                                    HapticFeedback.selectionClick();
                                    onTap(index);
                                  }
                                },
                                borderRadius: BorderRadius.circular(borderRadius),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          IconTheme.merge(
                                            data: IconThemeData(
                                              color: isSelected
                                                  ? activeColor
                                                  : inactiveColor,
                                              size: 22,
                                            ),
                                            child: isSelected &&
                                                    item.activeIcon != null
                                                ? item.activeIcon!
                                                : item.icon,
                                          ),
                                          if (item.badgeCount != null &&
                                              item.badgeCount! > 0)
                                            Positioned(
                                              right: -8,
                                              top: -4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${item.badgeCount}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (item.label != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          item.label!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? activeColor
                                                : inactiveColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    return navContent;
  }
}

