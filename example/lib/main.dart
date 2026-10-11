import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_container/core/widgets/liquid_glass/liquid_glass_example.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preload and compile GLSL fragment shaders before first frame
  await LiquidGlass.initialize();
  // Start frame timing and drop diagnostic monitor
  LiquidGlassPerformanceTracker.instance.start();

  runApp(const LiquidGlassShowcaseApp());
}

/// The root showcase application demonstrating the [liquid_glass_container] package.
class LiquidGlassShowcaseApp extends StatefulWidget {
  const LiquidGlassShowcaseApp({super.key});

  @override
  State<LiquidGlassShowcaseApp> createState() => _LiquidGlassShowcaseAppState();
}

class _LiquidGlassShowcaseAppState extends State<LiquidGlassShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  LiquidGlassQuality _quality = LiquidGlassQuality.auto;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  void _setQuality(LiquidGlassQuality q) {
    setState(() {
      _quality = q;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassTheme(
      data: _themeMode == ThemeMode.dark
          ? LiquidGlassThemeData.dark().copyWith(quality: _quality)
          : LiquidGlassThemeData.light().copyWith(quality: _quality),
      child: MaterialApp(
        title: 'Liquid Glass Studio',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFE5E5EA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF090A0F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: ShowcaseHomeScreen(
          onToggleTheme: _toggleTheme,
          themeMode: _themeMode,
          quality: _quality,
          onQualityChanged: _setQuality,
        ),
      ),
    );
  }
}

enum _BackgroundMode {
  neonGrid,
  checkerboard,
  vibrantBlobs,
}

class ShowcaseHomeScreen extends StatefulWidget {
  const ShowcaseHomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.quality,
    required this.onQualityChanged,
  });

  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final LiquidGlassQuality quality;
  final ValueChanged<LiquidGlassQuality> onQualityChanged;

  @override
  State<ShowcaseHomeScreen> createState() => _ShowcaseHomeScreenState();
}

class _ShowcaseHomeScreenState extends State<ShowcaseHomeScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int _activeTabIndex = 0;
  bool _showDiagnostics = true;
  _BackgroundMode _bgMode = _BackgroundMode.neonGrid;

  // Live shader parameter controls
  double _blur = 24.0;
  double _refraction = 0.40;
  double _thickness = 18.0;
  double _lightAngle = 0.785;
  double _specular = 0.65;
  double _innerGlow = 0.35;
  double _tintOpacity = 0.16;
  double _borderWidth = 1.0;
  double _chromaticAberration = 0.08;
  final Color _tintColor = Colors.white;

  // Shape morph demo controller
  late final AnimationController _morphController;
  bool _isMorphPlaying = true;
  double _morphSpeed = 1.0;

  final LiquidGlassShape _morphShapeA = const LiquidGlassShape.squircle(
    cornerRadius: 32,
    cornerSmoothing: 0.85,
  );
  final LiquidGlassShape _morphShapeB = const LiquidGlassShape.star(
    points: 5,
    innerRadiusRatio: 0.45,
  );

  // Components demo states
  double _sliderValue = 0.65;
  bool _switchValue = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _activeTabIndex = _tabController.index);
      }
    });

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _cycleBackground() {
    setState(() {
      switch (_bgMode) {
        case _BackgroundMode.neonGrid:
          _bgMode = _BackgroundMode.checkerboard;
          break;
        case _BackgroundMode.checkerboard:
          _bgMode = _BackgroundMode.vibrantBlobs;
          break;
        case _BackgroundMode.vibrantBlobs:
          _bgMode = _BackgroundMode.neonGrid;
          break;
      }
    });
  }

  LiquidGlassSettings get _liveSettings => LiquidGlassSettings(
        blur: _blur,
        refractionStrength: _refraction,
        thickness: _thickness,
        lightAngle: _lightAngle,
        specularIntensity: _specular,
        innerGlow: _innerGlow,
        tintColor: _tintColor,
        tintOpacity: _tintOpacity,
        borderWidth: _borderWidth,
        chromaticAberration: _chromaticAberration,
        quality: widget.quality,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidGlassAppBar(
        title: const Text('Liquid Glass Studio'),
        settings: LiquidGlassPresets.iosMaps,
        actions: [
          IconButton(
            tooltip: 'Switch Background Pattern (${_bgMode.name})',
            icon: const Icon(Icons.wallpaper, color: Colors.amberAccent),
            onPressed: _cycleBackground,
          ),
          IconButton(
            tooltip: 'Toggle Performance HUD',
            icon: Icon(
              _showDiagnostics ? Icons.speed : Icons.speed_outlined,
              color: _showDiagnostics ? Colors.cyanAccent : Colors.white70,
            ),
            onPressed: () =>
                setState(() => _showDiagnostics = !_showDiagnostics),
          ),
          IconButton(
            tooltip: 'Open iOS Control Center Showcase',
            icon: const Icon(Icons.apple, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LiquidGlassExample()),
            ),
          ),
          IconButton(
            tooltip: 'Toggle Light/Dark Theme',
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Dynamic high-contrast background with sharp patterns for optics/refraction
          Positioned.fill(
            child: _DynamicOpticsBackground(mode: _bgMode),
          ),

          // 2. Main Tabbed Content Area inside LiquidGlassLayer
          LiquidGlassLayer(
            child: SafeArea(
              child: Column(
                children: [
                  // Floating glass navigation bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: LiquidGlassTabBar(
                      selectedIndex: _activeTabIndex,
                      onTabSelected: (index) {
                        setState(() => _activeTabIndex = index);
                        _tabController.animateTo(index);
                      },
                      tabs: const [
                        LiquidGlassTabItem(
                          label: 'Overview',
                          icon: Icons.auto_awesome,
                        ),
                        LiquidGlassTabItem(
                          label: 'Presets',
                          icon: Icons.palette_outlined,
                        ),
                        LiquidGlassTabItem(
                          label: 'Shapes',
                          icon: Icons.category_outlined,
                        ),
                        LiquidGlassTabItem(
                          label: 'Playground',
                          icon: Icons.tune,
                        ),
                        LiquidGlassTabItem(
                          label: 'Widgets',
                          icon: Icons.widgets_outlined,
                        ),
                        LiquidGlassTabItem(
                          label: 'Physics',
                          icon: Icons.touch_app,
                        ),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildPresetsTab(),
                        _buildShapesTab(),
                        _buildLiveControlsTab(),
                        _buildWidgetsTab(),
                        _buildPhysicsAndMorphTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Diagnostics Overlay
          if (_showDiagnostics)
            LiquidGlassDiagnosticsOverlay(
              quality: widget.quality,
              alignment: Alignment.bottomRight,
            ),
        ],
      ),
    );
  }

  // TAB 1: OVERVIEW
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Hero Explanatory Card
        LiquidGlassCard(
          title: const Text('Apple-Inspired Liquid Glass System'),
          subtitle: const Text('Production-Grade Flutter Graphics Pipeline'),
          leading: const Icon(
            Icons.auto_awesome,
            color: Colors.cyanAccent,
            size: 28,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unlike standard BackdropFilter widgets, this engine combines real-time GLSL '
                'fragment refraction, Blinn-Phong specular glints, Fresnel rim lighting, '
                'and Gielis continuous squircle curvature for true physical glass depth.',
                style: TextStyle(height: 1.4, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPillTag('GLSL Refraction', Colors.cyanAccent),
                  _buildPillTag('Impeller & Skia', Colors.greenAccent),
                  _buildPillTag('Gielis Squircle', Colors.purpleAccent),
                  _buildPillTag('Spring Physics', Colors.amberAccent),
                ],
              ),
            ],
          ),
          actions: [
            LiquidGlassButton(
              onPressed: () => _tabController.animateTo(3),
              child: const Text('Open Shader Playground'),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Side-by-Side Comparison: Flat vs Simple Blur vs Liquid Glass
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'VISUAL COMPARISON (LOOK AT THE PATTERN UNDERNEATH)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            // 1. Raw Flat Backdrop
            Expanded(
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                padding: const EdgeInsets.all(12),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.crop_square, size: 28, color: Colors.white60),
                    SizedBox(height: 6),
                    Text(
                      'Flat Layer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No optics\nNo blur',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Standard Blur
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 130,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: LiquidGlassContainer(
                          settings: const LiquidGlassSettings(
                            blur: 16,
                            refractionStrength: 0,
                            specularIntensity: 0,
                            innerGlow: 0,
                            tintOpacity: 0.1,
                            borderWidth: 0.5,
                          ),
                          shape: const LiquidGlassShape.roundedRectangle(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.blur_on, size: 28, color: Colors.white70),
                            SizedBox(height: 6),
                            Text(
                              'Simple Blur',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Standard\nBackdropFilter',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 3. Apple-Inspired Liquid Glass
            Expanded(
              child: SizedBox(
                height: 130,
                child: LiquidGlassContainer(
                  settings: LiquidGlassPresets.crystal,
                  shape: const LiquidGlassShape.squircle(cornerRadius: 20),
                  interactive: true,
                  padding: const EdgeInsets.all(10),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.diamond, size: 28, color: Colors.cyanAccent),
                        SizedBox(height: 6),
                        Text(
                          'Liquid Glass',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Refraction +\nEdge Lensing',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.cyanAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Interactive Highlight Demonstration Banner
        LiquidGlassContainer(
          settings: LiquidGlassPresets.controlCenter,
          shape: const LiquidGlassShape.squircle(cornerRadius: 24),
          interactive: true,
          enableDrag: true,
          padding: const EdgeInsets.all(18),
          child: const Row(
            children: [
              Icon(Icons.touch_app, size: 36, color: Colors.amberAccent),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Specular Lighting',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Touch and drag this card! Notice the localized Blinn-Phong light glint moves under your touch and springs back.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Engine Status & Capability Card
        LiquidGlassCard(
          title: const Text('Graphics Pipeline Diagnostics'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow(
                'Hardware Acceleration',
                LiquidGlass.hasShaderSupport
                    ? 'Active (GLSL Shaders Loaded)'
                    : 'Fallback (Canvas Path)',
                Colors.greenAccent,
              ),
              _buildStatusRow(
                'Rendering Target Budget',
                '60 FPS (16.6ms) / 120 FPS (8.3ms)',
                Colors.cyanAccent,
              ),
              _buildStatusRow(
                'Active Quality Tier',
                widget.quality.name.toUpperCase(),
                Colors.amberAccent,
              ),
              _buildStatusRow(
                'Active Background Mode',
                _bgMode.name.toUpperCase(),
                Colors.purpleAccent,
              ),
              _buildStatusRow(
                'Squircle Formula',
                'Gielis Superellipse (Continuous curvature)',
                Colors.tealAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: ALL 16 PRESETS
  Widget _buildPresetsTab() {
    final presetEntries = LiquidGlassPresets.values.entries.toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          alignment: Alignment.centerLeft,
          child: const Text(
            '16 Curated iOS Presets — Tap any card to test touch lighting:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: presetEntries.length,
            itemBuilder: (context, index) {
              final entry = presetEntries[index];
              return LiquidGlassContainer(
                settings: entry.value,
                shape: const LiquidGlassShape.squircle(cornerRadius: 22),
                interactive: true,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Blur: ${entry.value.blur.toInt()} | Ref: ${entry.value.refractionStrength.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Spec: ${entry.value.specularIntensity.toStringAsFixed(2)} | Glow: ${entry.value.innerGlow.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 3: SHAPES
  Widget _buildShapesTab() {
    final shapes = [
      (
        'Squircle',
        Icons.crop_square_rounded,
        const LiquidGlassShape.squircle(cornerRadius: 30, cornerSmoothing: 0.8),
      ),
      (
        'Rounded Rect',
        Icons.rounded_corner,
        const LiquidGlassShape.roundedRectangle(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      ('Circle', Icons.circle, const LiquidGlassShape.circle()),
      ('Capsule Pill', Icons.stadium, const LiquidGlassShape.capsule()),
      ('Oval', Icons.egg, const LiquidGlassShape.oval()),
      ('5-Point Star', Icons.star, const LiquidGlassShape.star(points: 5)),
      ('Heart', Icons.favorite, const LiquidGlassShape.heart()),
      ('Hexagon', Icons.hexagon, const LiquidGlassShape.hexagon(cornerRadius: 8)),
      (
        'Organic Blob',
        Icons.bubble_chart,
        const LiquidGlassShape.blob(points: 7, wobble: 0.16),
      ),
      (
        'SVG Path',
        Icons.gesture,
        const LiquidGlassShape.svgPath(
          'M 10 80 C 40 10, 65 10, 95 80 S 150 150, 180 80',
        ),
      ),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          alignment: Alignment.centerLeft,
          child: const Text(
            '10 Built-In Geometric & Continuous Curvature Shapes:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: shapes.length,
            itemBuilder: (context, index) {
              final shapeItem = shapes[index];
              return LiquidGlassContainer(
                settings: _liveSettings,
                shape: shapeItem.$3,
                interactive: true,
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(shapeItem.$2, size: 30, color: Colors.cyanAccent),
                      const SizedBox(height: 8),
                      Text(
                        shapeItem.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 4: LIVE SHADER CONTROLS (PLAYGROUND)
  Widget _buildLiveControlsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Interactive Target Container
        Center(
          child: SizedBox(
            width: 240,
            height: 150,
            child: LiquidGlassContainer(
              settings: _liveSettings,
              shape: const LiquidGlassShape.squircle(cornerRadius: 28),
              interactive: true,
              enableDrag: true,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 28, color: Colors.cyanAccent),
                    SizedBox(height: 6),
                    Text(
                      'Live Glass Surface',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Drag me to test spring physics',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Uniforms Card
        LiquidGlassCard(
          title: const Text('Real-Time Shader Uniforms'),
          subtitle: const Text('Tune optical refraction & physical parameters'),
          content: Column(
            children: [
              _buildSliderRow(
                'Blur Radius',
                _blur,
                0,
                60,
                (v) => setState(() => _blur = v),
              ),
              _buildSliderRow(
                'Refraction Strength',
                _refraction,
                0,
                1,
                (v) => setState(() => _refraction = v),
              ),
              _buildSliderRow(
                'Optical Thickness',
                _thickness,
                0,
                40,
                (v) => setState(() => _thickness = v),
              ),
              _buildSliderRow(
                'Light Angle',
                _lightAngle,
                0,
                math.pi * 2,
                (v) => setState(() => _lightAngle = v),
              ),
              _buildSliderRow(
                'Specular Brightness',
                _specular,
                0,
                1,
                (v) => setState(() => _specular = v),
              ),
              _buildSliderRow(
                'Fresnel Rim Glow',
                _innerGlow,
                0,
                1,
                (v) => setState(() => _innerGlow = v),
              ),
              _buildSliderRow(
                'Tint Opacity',
                _tintOpacity,
                0,
                1,
                (v) => setState(() => _tintOpacity = v),
              ),
              _buildSliderRow(
                'Border Thickness',
                _borderWidth,
                0,
                5,
                (v) => setState(() => _borderWidth = v),
              ),
              _buildSliderRow(
                'Chromatic Aberration',
                _chromaticAberration,
                0,
                0.3,
                (v) => setState(() => _chromaticAberration = v),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quality Level',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SegmentedButton<LiquidGlassQuality>(
                    segments: const [
                      ButtonSegment(
                        value: LiquidGlassQuality.low,
                        label: Text('Low'),
                      ),
                      ButtonSegment(
                        value: LiquidGlassQuality.medium,
                        label: Text('Med'),
                      ),
                      ButtonSegment(
                        value: LiquidGlassQuality.high,
                        label: Text('High'),
                      ),
                      ButtonSegment(
                        value: LiquidGlassQuality.auto,
                        label: Text('Auto'),
                      ),
                    ],
                    selected: {widget.quality},
                    onSelectionChanged: (set) =>
                        widget.onQualityChanged(set.first),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 135,
            child: Text(
              '$label: ${value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 5: READY-MADE WIDGETS
  Widget _buildWidgetsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Search Bar
        LiquidGlassSearchBar(
          hintText: 'Search liquid glass surfaces...',
          onChanged: (q) {},
        ),
        const SizedBox(height: 16),

        // 2. Interactive Controls Card
        LiquidGlassCard(
          title: const Text('Interactive Glass Components'),
          subtitle: const Text('Seamless switches and sliders'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LiquidGlassSwitch',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  LiquidGlassSwitch(
                    value: _switchValue,
                    onChanged: (v) => setState(() => _switchValue = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'LiquidGlassSlider',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              LiquidGlassSlider(
                value: _sliderValue,
                onChanged: (v) => setState(() => _sliderValue = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Buttons & Modals
        Row(
          children: [
            Expanded(
              child: LiquidGlassButton(
                onPressed: () {
                  LiquidGlassDialog.show(
                    context: context,
                    title: const Text('Liquid Glass Dialog'),
                    content: const Text(
                      'Modal dialog rendered inside an optical squircle with hardware blur barrier.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LiquidGlassButton(
                onPressed: () {
                  LiquidGlassBottomSheet.show(
                    context: context,
                    builder: (ctx, scroll) {
                      return ListView(
                        controller: scroll,
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Center(
                            child: Text(
                              'Draggable Glass Bottom Sheet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Snaps smoothly between 25%, 50%, and 92% screen height detents. Drag the grab handle or scroll content.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(
                            8,
                            (i) => ListTile(
                              leading: const Icon(
                                Icons.lens_blur,
                                color: Colors.cyanAccent,
                              ),
                              title: Text(
                                'Glass Item #$i',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. Button Variants (Normal, Disabled, Loading)
        Row(
          children: [
            Expanded(
              child: LiquidGlassButton(
                onPressed: () {},
                child: const Text('Normal'),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: LiquidGlassButton(
                onPressed: null,
                child: Text('Disabled'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LiquidGlassButton(
                isLoading: true,
                onPressed: () {},
                child: const Text('Loading'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // TAB 6: PHYSICS & MORPHING
  Widget _buildPhysicsAndMorphTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Spring Drag Box
        LiquidGlassCard(
          title: const Text('Rubber-Band Drag & Spring Recoil'),
          subtitle: const Text(
            'Pan this card to feel elastic resistance and spring oscillation',
          ),
          content: Center(
            child: SizedBox(
              width: 220,
              height: 140,
              child: LiquidGlassContainer(
                settings: LiquidGlassPresets.soapBubble,
                shape: const LiquidGlassShape.squircle(cornerRadius: 32),
                interactive: true,
                enableDrag: true,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 30, color: Colors.pinkAccent),
                      SizedBox(height: 6),
                      Text(
                        'Drag & Release',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Spring Dynamics',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Continuous Shape Morphing
        LiquidGlassCard(
          title: const Text('Continuous Shape Morphing'),
          subtitle: const Text(
            'Normalized arc-length vertex sampling between Squircle & Star',
          ),
          content: Column(
            children: [
              SizedBox(
                width: 190,
                height: 190,
                child: LiquidGlassShapeTransition(
                  shapeA: _morphShapeA,
                  shapeB: _morphShapeB,
                  progress: _morphController,
                  builder: (context, morphedPath) {
                    return LiquidGlassContainer(
                      settings: LiquidGlassPresets.crystal,
                      shape: _morphShapeA,
                      morphedPath: morphedPath,
                      child: const Center(
                        child: Text(
                          'Morphed Glass',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Morph Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isMorphPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 32,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isMorphPlaying) {
                          _morphController.stop();
                        } else {
                          _morphController.repeat(reverse: true);
                        }
                        _isMorphPlaying = !_isMorphPlaying;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<double>(
                    segments: const [
                      ButtonSegment(value: 0.5, label: Text('0.5x')),
                      ButtonSegment(value: 1.0, label: Text('1x')),
                      ButtonSegment(value: 2.0, label: Text('2x')),
                    ],
                    selected: {_morphSpeed},
                    onSelectionChanged: (set) {
                      setState(() {
                        _morphSpeed = set.first;
                        _morphController.duration = Duration(
                          milliseconds: (1400 / _morphSpeed).round(),
                        );
                        if (_isMorphPlaying) {
                          _morphController.repeat(reverse: true);
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dynamic, high-contrast animated background with sharp lines, grids, and shapes
/// that explicitly reveal real-time optical refraction, lens distortion, and blur.
class _DynamicOpticsBackground extends StatefulWidget {
  const _DynamicOpticsBackground({required this.mode});

  final _BackgroundMode mode;

  @override
  State<_DynamicOpticsBackground> createState() =>
      _DynamicOpticsBackgroundState();
}

class _DynamicOpticsBackgroundState extends State<_DynamicOpticsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return CustomPaint(
          painter: _OpticsBackgroundPainter(
            progress: t,
            mode: widget.mode,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _OpticsBackgroundPainter extends CustomPainter {
  const _OpticsBackgroundPainter({
    required this.progress,
    required this.mode,
  });

  final double progress;
  final _BackgroundMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    switch (mode) {
      case _BackgroundMode.neonGrid:
        _paintNeonGrid(canvas, size);
        break;
      case _BackgroundMode.checkerboard:
        _paintCheckerboard(canvas, size);
        break;
      case _BackgroundMode.vibrantBlobs:
        _paintVibrantArt(canvas, size);
        break;
    }
  }

  void _paintNeonGrid(Canvas canvas, Size size) {
    // 1. Deep space gradient base
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF070B19),
          Color(0xFF140F2D),
          Color(0xFF1E0A24),
          Color(0xFF091726),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. High-contrast isometric perspective grid lines (shows refraction warp!)
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const gridSize = 42.0;
    final shiftX = (progress * gridSize) % gridSize;
    final shiftY = (progress * gridSize) % gridSize;

    for (double x = -gridSize; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x + shiftX, 0),
        Offset(x + shiftX, size.height),
        gridPaint,
      );
    }
    for (double y = -gridSize; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y + shiftY),
        Offset(size.width, y + shiftY),
        gridPaint,
      );
    }

    // 3. Floating sharp colorful geometric circles & badges
    final circlePaintA = Paint()
      ..color = const Color(0xFFFF007F)
      ..style = PaintingStyle.fill;
    final posA = Offset(
      size.width * (0.25 + 0.25 * math.sin(progress * 2 * math.pi)),
      size.height * (0.35 + 0.15 * math.cos(progress * 2 * math.pi)),
    );
    canvas.drawCircle(posA, 70, circlePaintA);

    final circlePaintB = Paint()
      ..color = const Color(0xFF00FFCC)
      ..style = PaintingStyle.fill;
    final posB = Offset(
      size.width * (0.75 - 0.20 * math.cos(progress * 2 * math.pi)),
      size.height * (0.65 + 0.18 * math.sin(progress * 2 * math.pi)),
    );
    canvas.drawCircle(posB, 85, circlePaintB);

    final circlePaintC = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;
    final posC = Offset(
      size.width * (0.50 + 0.30 * math.sin(progress * 2 * math.pi + 1)),
      size.height * (0.80 - 0.15 * math.cos(progress * 2 * math.pi)),
    );
    canvas.drawCircle(posC, 60, circlePaintC);

    // 4. Sharp high-contrast diagonal laser stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.35)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    for (int i = -4; i < 12; i++) {
      final offset = (i * 120.0 + progress * 240.0) % (size.width + size.height);
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset - 250, size.height),
        stripePaint,
      );
    }
  }

  void _paintCheckerboard(Canvas canvas, Size size) {
    // Classic optical benchmark pattern
    final bgPaint = Paint()..color = const Color(0xFF10121A);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final tilePaintA = Paint()..color = const Color(0xFF221538);
    final tilePaintB = Paint()..color = const Color(0xFF0A3C4A);

    const tileSize = 48.0;
    final cols = (size.width / tileSize).ceil() + 1;
    final rows = (size.height / tileSize).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((r + c) % 2 == 0) {
          final rect = Rect.fromLTWH(
            c * tileSize,
            r * tileSize,
            tileSize,
            tileSize,
          );
          canvas.drawRect(rect, (c % 3 == 0) ? tilePaintA : tilePaintB);
        }
      }
    }

    // Moving sharp glowing rings
    final ringPaint = Paint()
      ..color = const Color(0xFFFF0055)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final center = Offset(
      size.width * (0.5 + 0.3 * math.sin(progress * 2 * math.pi)),
      size.height * (0.5 + 0.25 * math.cos(progress * 2 * math.pi)),
    );
    canvas.drawCircle(center, 90, ringPaint);
  }

  void _paintVibrantArt(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2E0854),
          Color(0xFF880E4F),
          Color(0xFFE65100),
          Color(0xFF004D40),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Floating bold colored discs
    final p1 = Paint()..color = const Color(0xFF00E676);
    final p2 = Paint()..color = const Color(0xFFFFD600);
    final p3 = Paint()..color = const Color(0xFF00B0FF);

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * (0.2 + 0.1 * math.sin(progress * 2 * math.pi))),
      80,
      p1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * (0.5 + 0.15 * math.cos(progress * 2 * math.pi))),
      100,
      p2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * (0.8 - 0.1 * math.sin(progress * 2 * math.pi))),
      90,
      p3,
    );
  }

  @override
  bool shouldRepaint(covariant _OpticsBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.mode != mode;
}
