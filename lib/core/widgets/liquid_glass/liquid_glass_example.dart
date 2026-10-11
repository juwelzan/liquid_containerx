import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'liquid_glass_button.dart';
import 'liquid_glass_container.dart';
import 'liquid_glass_navigation_bar.dart';
import 'liquid_glass_panel.dart';

/// The 5 visual testing background modes required for rigorous optical evaluation.
enum GlassTestBackground {
  colorfulGradient,
  photographic,
  dark,
  light,
  animatedMotion,
}

/// Comprehensive showcase screen demonstrating the Apple iOS-inspired Liquid Glass
/// system powered by `liquid_glass_renderer: ^0.2.0-dev.4`.
class LiquidGlassExample extends StatefulWidget {
  const LiquidGlassExample({super.key});

  @override
  State<LiquidGlassExample> createState() => _LiquidGlassExampleState();
}

class _LiquidGlassExampleState extends State<LiquidGlassExample>
    with TickerProviderStateMixin {
  // Active visual background
  GlassTestBackground _activeBackground = GlassTestBackground.colorfulGradient;

  // Active navigation tab
  int _navIndex = 0;

  // Global tuning parameters
  double _thickness = 18.0;
  double _blur = 16.0;
  double _lightIntensity = 0.65;
  double _saturation = 1.35;
  bool _useFakeGlass = false;
  bool _enableStretch = false;
  bool _enableGlow = true;

  // Control Center mock states
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = true;
  bool _airplaneEnabled = false;
  bool _airDropEnabled = true;
  double _brightness = 0.75;
  double _volume = 0.60;
  bool _isPlaying = true;

  // Animation controller for moving background
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  LiquidGlassSettings get _currentSettings => LiquidGlassSettings(
        thickness: _thickness,
        blur: _blur,
        glassColor: const Color(0x2BFFFFFF),
        refractiveIndex: 1.25,
        lightAngle: 0.75 * math.pi,
        lightIntensity: _lightIntensity,
        ambientStrength: 0.12,
        saturation: _saturation,
        chromaticAberration: 0.02,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Underlying dynamic test background (evaluated against glass optics)
          Positioned.fill(
            child: _buildTestBackground(),
          ),

          // 2. Scrollable Showcase Content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Liquid Glass',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.8,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'iOS Optical Shader System',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        // Quick settings dialog button
                        LiquidGlassButton(
                          height: 40,
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          onPressed: _showTuningSheet,
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Tune'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Background Selector Pills
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: GlassTestBackground.values.map((bg) {
                        final isSelected = bg == _activeBackground;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_getBackgroundName(bg)),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _activeBackground = bg),
                            backgroundColor: Colors.black26,
                            selectedColor: Colors.white.withValues(alpha: 0.3),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            side: BorderSide(
                              color: isSelected ? Colors.cyanAccent : Colors.white24,
                              width: 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Section 1: iOS Control Center Panels
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: _buildControlCenterSection(),
                  ),
                ),

                // Section 2: Media Player Glass Panel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _buildMediaPlayerPanel(),
                  ),
                ),

                // Section 3: Glass Buttons Showcase
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _buildButtonsShowcase(),
                  ),
                ),

                // Section 4: Glass Geometric Shapes Showcase
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: _buildShapesShowcase(),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating iOS-style Glass Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidGlassNavigationBar(
              currentIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
              settings: _currentSettings,
              fake: _useFakeGlass,
              items: const [
                LiquidGlassNavItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Controls',
                ),
                LiquidGlassNavItem(
                  icon: Icon(Icons.music_note_outlined),
                  activeIcon: Icon(Icons.music_note),
                  label: 'Media',
                  badgeCount: 2,
                ),
                LiquidGlassNavItem(
                  icon: Icon(Icons.widgets_outlined),
                  activeIcon: Icon(Icons.widgets),
                  label: 'Buttons',
                ),
                LiquidGlassNavItem(
                  icon: Icon(Icons.tune_outlined),
                  activeIcon: Icon(Icons.tune),
                  label: 'Tuning',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Background Builders ---

  String _getBackgroundName(GlassTestBackground bg) {
    switch (bg) {
      case GlassTestBackground.colorfulGradient:
        return 'Gradient Mesh';
      case GlassTestBackground.photographic:
        return 'Scenic Wallpaper';
      case GlassTestBackground.dark:
        return 'Dark Mode';
      case GlassTestBackground.light:
        return 'Light High-Key';
      case GlassTestBackground.animatedMotion:
        return 'Motion Lasers';
    }
  }

  Widget _buildTestBackground() {
    switch (_activeBackground) {
      case GlassTestBackground.colorfulGradient:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E0854),
                Color(0xFF6A0DAD),
                Color(0xFFE91E63),
                Color(0xFFFF9800),
              ],
            ),
          ),
          child: CustomPaint(painter: _PatternGridPainter()),
        );

      case GlassTestBackground.photographic:
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.2, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF1B3B6F),
                Color(0xFF065A82),
                Color(0xFF21295C),
                Color(0xFF000505),
              ],
            ),
          ),
          child: CustomPaint(painter: _ScenicLightsPainter()),
        );

      case GlassTestBackground.dark:
        return Container(
          color: const Color(0xFF090A10),
          child: CustomPaint(painter: _SubtleStarsPainter()),
        );

      case GlassTestBackground.light:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF0F4F8),
                Color(0xFFD9E2EC),
                Color(0xFFBCCCDC),
              ],
            ),
          ),
          child: CustomPaint(painter: _LightStripesPainter()),
        );

      case GlassTestBackground.animatedMotion:
        return AnimatedBuilder(
          animation: _motionController,
          builder: (context, _) => CustomPaint(
            painter: _MotionLaserPainter(progress: _motionController.value),
          ),
        );
    }
  }

  // --- Section 1: iOS Control Center ---

  Widget _buildControlCenterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'CONTROL CENTER MODULES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left 2x2 Connectivity Matrix
            Expanded(
              flex: 5,
              child: LiquidGlassPanel(
                borderRadius: 28,
                settings: _currentSettings,
                fake: _useFakeGlass,
                interactive: true,
                enableStretch: _enableStretch,
                padding: const EdgeInsets.all(14),
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildConnectToggle(
                            icon: Icons.wifi,
                            label: 'Wi-Fi',
                            active: _wifiEnabled,
                            onTap: () => setState(() => _wifiEnabled = !_wifiEnabled),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildConnectToggle(
                            icon: Icons.bluetooth,
                            label: 'Bluetooth',
                            active: _bluetoothEnabled,
                            onTap: () => setState(() => _bluetoothEnabled = !_bluetoothEnabled),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildConnectToggle(
                            icon: Icons.airplanemode_active,
                            label: 'Airplane',
                            active: _airplaneEnabled,
                            onTap: () => setState(() => _airplaneEnabled = !_airplaneEnabled),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildConnectToggle(
                            icon: Icons.podcasts,
                            label: 'AirDrop',
                            active: _airDropEnabled,
                            onTap: () => setState(() => _airDropEnabled = !_airDropEnabled),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Right Vertical Sliders (Brightness & Volume)
            Expanded(
              flex: 2,
              child: _buildVerticalSlider(
                icon: Icons.brightness_medium,
                value: _brightness,
                onChanged: (v) => setState(() => _brightness = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildVerticalSlider(
                icon: Icons.volume_up,
                value: _volume,
                onChanged: (v) => setState(() => _volume = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectToggle({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF007AFF) : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalSlider({
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final delta = -details.primaryDelta! / 140.0;
        final next = (value + delta).clamp(0.0, 1.0);
        onChanged(next);
      },
      child: SizedBox(
        height: 160,
        child: LiquidGlassContainer(
          borderRadius: 28,
          settings: _currentSettings,
          fake: _useFakeGlass,
          interactive: true,
          padding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              FractionallySizedBox(
                heightFactor: value,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                child: Icon(
                  icon,
                  size: 20,
                  color: value > 0.2 ? Colors.black87 : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Section 2: Media Player Panel ---

  Widget _buildMediaPlayerPanel() {
    return LiquidGlassPanel(
      borderRadius: 26,
      settings: _currentSettings,
      fake: _useFakeGlass,
      interactive: true,
      enableStretch: _enableStretch,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF2D55), Color(0xFFFF9500)],
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white, size: 26),
      ),
      title: const Text('Midnight City'),
      subtitle: const Text('M83 — Hurry Up, We\'re Dreaming'),
      trailing: IconButton(
        icon: Icon(
          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          size: 38,
          color: Colors.white,
        ),
        onPressed: () => setState(() => _isPlaying = !_isPlaying),
      ),
      content: Column(
        children: [
          // Scrub bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2:24', style: TextStyle(fontSize: 10, color: Colors.white60)),
              Text('-1:40', style: TextStyle(fontSize: 10, color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 3: Buttons Showcase ---

  Widget _buildButtonsShowcase() {
    return LiquidGlassPanel(
      borderRadius: 26,
      settings: _currentSettings,
      fake: _useFakeGlass,
      interactive: false,
      title: const Text('ROUNDED GLASS BUTTONS'),
      subtitle: const Text('Tactile response with edge specular highlights'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          LiquidGlassButton(
            onPressed: () {},
            icon: const Icon(Icons.bolt, color: Colors.amberAccent),
            label: const Text('Quick Action'),
            enableStretch: _enableStretch,
            enableGlow: _enableGlow,
            fake: _useFakeGlass,
          ),
          LiquidGlassButton(
            onPressed: () {},
            label: const Text('Dismiss'),
            tintColor: const Color(0x20FFFFFF),
            enableStretch: _enableStretch,
            enableGlow: _enableGlow,
            fake: _useFakeGlass,
          ),
          LiquidGlassButton(
            width: 48,
            height: 48,
            borderRadius: 24,
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: const Icon(Icons.share, size: 20),
            enableStretch: _enableStretch,
            enableGlow: _enableGlow,
            fake: _useFakeGlass,
          ),
          LiquidGlassButton(
            isLoading: true,
            onPressed: () {},
            label: const Text('Syncing'),
            fake: _useFakeGlass,
          ),
          const LiquidGlassButton(
            enabled: false,
            onPressed: null,
            label: Text('Disabled'),
          ),
        ],
      ),
    );
  }

  // --- Section 4: Shapes Showcase ---

  Widget _buildShapesShowcase() {
    return LiquidGlassPanel(
      borderRadius: 26,
      settings: _currentSettings,
      fake: _useFakeGlass,
      interactive: false,
      title: const Text('GLASS GEOMETRIC SHAPES'),
      subtitle: const Text('Superellipse Squircle, Oval & Rounded Rectangle'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Superellipse Squircle
          Column(
            children: [
              SizedBox.square(
                dimension: 80,
                child: LiquidGlassContainer(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                  settings: _currentSettings,
                  interactive: true,
                  enableGlow: _enableGlow,
                  fake: _useFakeGlass,
                  child: const Center(
                    child: Icon(Icons.crop_square_rounded, color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Squircle', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),

          // 2. Oval / Circle
          Column(
            children: [
              SizedBox.square(
                dimension: 80,
                child: LiquidGlassContainer(
                  shape: const LiquidOval(),
                  settings: _currentSettings,
                  interactive: true,
                  enableGlow: _enableGlow,
                  fake: _useFakeGlass,
                  child: const Center(
                    child: Icon(Icons.circle_outlined, color: Colors.pinkAccent),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Oval', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),

          // 3. Rounded Rectangle
          Column(
            children: [
              SizedBox.square(
                dimension: 80,
                child: LiquidGlassContainer(
                  shape: const LiquidRoundedRectangle(borderRadius: 16),
                  settings: _currentSettings,
                  interactive: true,
                  enableGlow: _enableGlow,
                  fake: _useFakeGlass,
                  child: const Center(
                    child: Icon(Icons.rounded_corner, color: Colors.amberAccent),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Rounded Rect', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Tuning Bottom Sheet ---

  void _showTuningSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xF012141F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Liquid Glass Pipeline Tuning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Thickness slider
              _buildSliderTile(
                'Thickness (Refraction Depth)',
                _thickness,
                0,
                40,
                (v) {
                  setSheetState(() => _thickness = v);
                  setState(() => _thickness = v);
                },
              ),

              // Blur slider
              _buildSliderTile(
                'Blur (Frost Radius)',
                _blur,
                0,
                30,
                (v) {
                  setSheetState(() => _blur = v);
                  setState(() => _blur = v);
                },
              ),

              // Light Intensity
              _buildSliderTile(
                'Specular Light Intensity',
                _lightIntensity,
                0,
                1.5,
                (v) {
                  setSheetState(() => _lightIntensity = v);
                  setState(() => _lightIntensity = v);
                },
              ),

              // Saturation
              _buildSliderTile(
                'Background Saturation Boost',
                _saturation,
                0.5,
                2.0,
                (v) {
                  setSheetState(() => _saturation = v);
                  setState(() => _saturation = v);
                },
              ),

              const Divider(color: Colors.white24, height: 24),

              // Fallback & Physics Toggles
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Force FakeGlass Fallback', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Uses BackdropFilter instead of GLSL shaders', style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: _useFakeGlass,
                onChanged: (v) {
                  setSheetState(() => _useFakeGlass = v);
                  setState(() => _useFakeGlass = v);
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('LiquidStretch Dynamics', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Organic squash-and-stretch on interaction', style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: _enableStretch,
                onChanged: (v) {
                  setSheetState(() => _enableStretch = v);
                  setState(() => _enableStretch = v);
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('GlassGlow Touch Glint', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Pointer-tracking specular glow effect', style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: _enableGlow,
                onChanged: (v) {
                  setSheetState(() => _enableGlow = v);
                  setState(() => _enableGlow = v);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 13, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// --- Custom Background Painters ---

class _PatternGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final circlePaint = Paint()
      ..color = const Color(0xFFFF007F).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), 90, circlePaint);

    final circlePaint2 = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 110, circlePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScenicLightsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintA = Paint()
      ..color = const Color(0xFF48CAE4).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.25), 120, paintA);

    final paintB = Paint()
      ..color = const Color(0xFF90E0EF).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 160, paintB);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SubtleStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final random = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = random.nextDouble() * 2.0 + 0.5;
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LightStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF007AFF).withValues(alpha: 0.12)
      ..strokeWidth = 24.0;
    for (int i = -4; i < 12; i++) {
      canvas.drawLine(
        Offset(i * 90.0, 0),
        Offset(i * 90.0 - 200, size.height),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MotionLaserPainter extends CustomPainter {
  const _MotionLaserPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Deep neon base
    final bg = Paint()..color = const Color(0xFF070B18);
    canvas.drawRect(Offset.zero & size, bg);

    // Dynamic lasers that pass behind the glass
    final laserPaint = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.4)
      ..strokeWidth = 8.0;

    for (int i = 0; i < 8; i++) {
      final y = ((i * 140.0 + progress * size.height) % size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 40), laserPaint);
    }

    final ballPaint = Paint()
      ..color = const Color(0xFFFF007F)
      ..style = PaintingStyle.fill;
    final bx = size.width * (0.5 + 0.35 * math.sin(progress * 2 * math.pi));
    final by = size.height * (0.5 + 0.25 * math.cos(progress * 2 * math.pi));
    canvas.drawCircle(Offset(bx, by), 70, ballPaint);
  }

  @override
  bool shouldRepaint(covariant _MotionLaserPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

