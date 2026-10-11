import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../physics/liquid_glass_physics.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// Item specification for a tab within [LiquidGlassTabBar].
class LiquidGlassTabItem {
  const LiquidGlassTabItem({required this.label, this.icon, this.badgeCount});

  final String label;
  final IconData? icon;
  final int? badgeCount;
}

/// A floating liquid glass tab bar with an animated glass sliding indicator.
class LiquidGlassTabBar extends StatelessWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.settings,
    this.indicatorSettings,
    this.shape = const LiquidGlassShape.capsule(),
    this.hapticFeedback = LiquidGlassHapticFeedback.selection,
  });

  /// The list of tab items to display.
  final List<LiquidGlassTabItem> tabs;

  /// Index of the currently active tab.
  final int selectedIndex;

  /// Callback when a tab is tapped or activated.
  final ValueChanged<int> onTabSelected;

  /// Optical settings for the base glass container.
  final LiquidGlassSettings? settings;

  /// Optical settings for the sliding glass indicator.
  final LiquidGlassSettings? indicatorSettings;

  /// Overall boundary shape for the tab bar.
  final LiquidGlassShape shape;

  /// Tactile feedback triggered on selection changes.
  final LiquidGlassHapticFeedback hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;

    return FocusTraversalGroup(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: LiquidGlassContainer(
          settings: settings ?? LiquidGlassPresets.controlCenter,
          shape: shape,
          padding: const EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabCount = tabs.length;
              if (tabCount == 0) return const SizedBox.shrink();

              final tabWidth = constraints.maxWidth / tabCount;
              final indicatorLeft = tabWidth * selectedIndex;

              return Stack(
                children: [
                  // Animated sliding selection pill
                  AnimatedPositioned(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: indicatorLeft,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: LiquidGlassContainer(
                      settings:
                          indicatorSettings ?? LiquidGlassPresets.clearGlass,
                      shape: const LiquidGlassShape.capsule(),
                    ),
                  ),

                  // Tab items row
                  Row(
                    children: List.generate(tabCount, (index) {
                      final tab = tabs[index];
                      final isSelected = index == selectedIndex;

                      return Expanded(
                        child: Semantics(
                          selected: isSelected,
                          button: true,
                          label: tab.label,
                          child: InkWell(
                            onTap: () {
                              if (index != selectedIndex) {
                                hapticFeedback.trigger();
                                onTabSelected(index);
                              }
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (tab.icon != null) ...[
                                    Icon(
                                      tab.icon,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white60,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    tab.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                  if (tab.badgeCount != null &&
                                      tab.badgeCount! > 0) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${tab.badgeCount}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
