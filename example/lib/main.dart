import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preload and initialize GLSL fragment shaders before first frame
  await LiquidGlass.initialize();
  // Start performance timing tracker
  LiquidGlassPerformanceTracker.instance.start();

  runApp(const LiquidGlassShowcaseApp());
}

class LiquidGlassShowcaseApp extends StatefulWidget {
  const LiquidGlassShowcaseApp({super.key});

  @override
  State<LiquidGlassShowcaseApp> createState() => _LiquidGlassShowcaseAppState();
}

class _LiquidGlassShowcaseAppState extends State<LiquidGlassShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.light;
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
        title: 'Liquid Glass Container Showcase',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF2F2F7),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D0D14),
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

  // Live shader parameter controls
  double _blur = 24.0;
  double _refraction = 0.35;
  double _thickness = 16.0;
  double _lightAngle = 0.785;
  double _specular = 0.55;
  double _innerGlow = 0.3;
  double _tintOpacity = 0.18;
  double _borderWidth = 1.0;
  double _chromaticAberration = 0.08;
  final Color _tintColor = Colors.white;

  // Shape morph demo controller
  late final AnimationController _morphController;
  final LiquidGlassShape _morphShapeA = const LiquidGlassShape.squircle(
    cornerRadius: 28,
  );
  final LiquidGlassShape _morphShapeB = const LiquidGlassShape.star();

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
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _morphController.dispose();
    super.dispose();
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
            tooltip: 'Toggle Performance HUD',
            icon: Icon(
              _showDiagnostics ? Icons.speed : Icons.speed_outlined,
              color: _showDiagnostics ? Colors.cyanAccent : Colors.white70,
            ),
            onPressed: () =>
                setState(() => _showDiagnostics = !_showDiagnostics),
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
          // 1. Dynamic high-contrast animated background
          const Positioned.fill(child: _ScenicVibrantBackground()),

          // 2. Main Tabbed Content Area
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
                        LiquidGlassTabItem(label: 'Controls', icon: Icons.tune),
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
      padding: const EdgeInsets.all(20),
      children: [
        LiquidGlassCard(
          title: const Text('Apple-Inspired Liquid Glass'),
          subtitle: const Text('Production-Grade Flutter Graphics System'),
          leading: const Icon(
            Icons.blur_on,
            color: Colors.cyanAccent,
            size: 28,
          ),
          content: const Text(
            'Experience shader-driven optical refraction, edge lensing, Blinn-Phong specular glints, '
            'and squircle continuous corners. Realized with Flutter 3.49 Impeller & Skia pipelines.',
          ),
          actions: [
            LiquidGlassButton(
              onPressed: () => _tabController.animateTo(3),
              child: const Text('Tune Shader Parameters'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: LiquidGlassContainer(
                settings: LiquidGlassPresets.aurora,
                shape: const LiquidGlassShape.squircle(cornerRadius: 24),
                interactive: true,
                padding: const EdgeInsets.all(18),
                child: const Column(
                  children: [
                    Icon(Icons.waves, size: 36, color: Colors.tealAccent),
                    SizedBox(height: 8),
                    Text(
                      'Aurora Sheen',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Chromatic Dispersion',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LiquidGlassContainer(
                settings: LiquidGlassPresets.crystal,
                shape: const LiquidGlassShape.squircle(cornerRadius: 24),
                interactive: true,
                padding: const EdgeInsets.all(18),
                child: const Column(
                  children: [
                    Icon(
                      Icons.diamond,
                      size: 36,
                      color: Colors.lightBlueAccent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crystal Lens',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('High Refraction', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        LiquidGlassCard(
          title: const Text('Engine Compatibility Status'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow(
                'Shader Acceleration',
                LiquidGlass.hasShaderSupport
                    ? 'Active (GLSL)'
                    : 'Fallback (Canvas)',
                Colors.greenAccent,
              ),
              _buildStatusRow(
                'Target Frame Budget',
                '60 FPS (16.6ms) / 120 FPS (8.3ms)',
                Colors.cyanAccent,
              ),
              _buildStatusRow(
                'Quality Mode',
                widget.quality.name.toUpperCase(),
                Colors.amberAccent,
              ),
              _buildStatusRow(
                'Squircle Curvature',
                'Gielis Superellipse (Continuous)',
                Colors.purpleAccent,
              ),
            ],
          ),
        ),
      ],
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

    return GridView.builder(
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
          shape: const LiquidGlassShape.squircle(cornerRadius: 20),
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
            ],
          ),
        );
      },
    );
  }

  // TAB 3: SHAPES
  Widget _buildShapesTab() {
    final shapes = [
      (
        'Squircle',
        const LiquidGlassShape.squircle(cornerRadius: 28, cornerSmoothing: 0.8),
      ),
      (
        'Rounded Rect',
        const LiquidGlassShape.roundedRectangle(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      ('Circle', const LiquidGlassShape.circle()),
      ('Capsule Pill', const LiquidGlassShape.capsule()),
      ('Oval', const LiquidGlassShape.oval()),
      ('Star (5-pt)', const LiquidGlassShape.star(points: 5)),
      ('Heart', const LiquidGlassShape.heart()),
      ('Hexagon', const LiquidGlassShape.hexagon(cornerRadius: 6)),
      ('Blob', const LiquidGlassShape.blob(points: 7, wobble: 0.15)),
      (
        'SVG Path',
        const LiquidGlassShape.svgPath(
          'M 10 80 C 40 10, 65 10, 95 80 S 150 150, 180 80',
        ),
      ),
    ];

    return GridView.builder(
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
          shape: shapeItem.$2,
          interactive: true,
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              shapeItem.$1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 4: LIVE SHADER CONTROLS
  Widget _buildLiveControlsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: SizedBox(
            width: 220,
            height: 140,
            child: LiquidGlassContainer(
              settings: _liveSettings,
              shape: const LiquidGlassShape.squircle(cornerRadius: 26),
              interactive: true,
              enableDrag: true,
              child: const Center(
                child: Text(
                  'Live Glass Target\n(Drag me)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        LiquidGlassCard(
          title: const Text('Real-Time Shader Uniforms'),
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
                'Inner Fresnel Rim',
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
                    style: TextStyle(color: Colors.white70),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
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
      padding: const EdgeInsets.all(20),
      children: [
        LiquidGlassSearchBar(
          hintText: 'Search liquid glass surfaces...',
          onChanged: (q) {},
        ),
        const SizedBox(height: 20),

        LiquidGlassCard(
          title: const Text('Interactive Glass Controls'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Liquid Glass Switch',
                    style: TextStyle(color: Colors.white),
                  ),
                  LiquidGlassSwitch(
                    value: _switchValue,
                    onChanged: (v) => setState(() => _switchValue = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Liquid Glass Slider',
                style: TextStyle(color: Colors.white),
              ),
              LiquidGlassSlider(
                value: _sliderValue,
                onChanged: (v) => setState(() => _sliderValue = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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
            const SizedBox(width: 16),
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
                          const SizedBox(height: 16),
                          const Text(
                            'Snaps smoothly between 25%, 50%, and 92% screen height detents. Drag the grab handle or scroll content.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          ...List.generate(
                            10,
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
      ],
    );
  }

  // TAB 6: PHYSICS & MORPHING
  Widget _buildPhysicsAndMorphTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LiquidGlassCard(
          title: const Text('Spring Physics & Rubber-Band Drag'),
          subtitle: const Text(
            'Pan the card to feel elastic resistance and spring recoil',
          ),
          content: Center(
            child: SizedBox(
              width: 200,
              height: 140,
              child: LiquidGlassContainer(
                settings: LiquidGlassPresets.soapBubble,
                shape: const LiquidGlassShape.squircle(cornerRadius: 32),
                interactive: true,
                enableDrag: true,
                child: const Center(
                  child: Text(
                    'Drag & Release\nSpring Physics',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        LiquidGlassCard(
          title: const Text('Continuous Shape Morphing'),
          subtitle: const Text(
            'Normalized arc-length sampling between Squircle & Star',
          ),
          content: Column(
            children: [
              SizedBox(
                width: 180,
                height: 180,
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
                          'Morphing',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LiquidGlassButton(
                    onPressed: () {
                      if (_morphController.isCompleted) {
                        _morphController.reverse();
                      } else {
                        _morphController.forward();
                      }
                    },
                    child: const Text('Animate Morph'),
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

/// Dynamic, colorful background to visually emphasize real-time refraction and blur.
class _ScenicVibrantBackground extends StatefulWidget {
  const _ScenicVibrantBackground();

  @override
  State<_ScenicVibrantBackground> createState() =>
      _ScenicVibrantBackgroundState();
}

class _ScenicVibrantBackgroundState extends State<_ScenicVibrantBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + t * 0.5, -1.0),
              end: Alignment(1.0 - t * 0.5, 1.0),
              colors: [
                Color.lerp(
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFF2C5364),
                  const Color(0xFF7F00FF),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFFE100FF),
                  const Color(0xFFFF007F),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFFFF8008),
                  const Color(0xFFFFC837),
                  t,
                )!,
              ],
            ),
          ),
          child: CustomPaint(painter: _BackgroundBlobsPainter(progress: t)),
        );
      },
    );
  }
}

class _BackgroundBlobsPainter extends CustomPainter {
  const _BackgroundBlobsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final paint2 = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final center1 = Offset(
      size.width * (0.3 + 0.4 * math.sin(progress * math.pi)),
      size.height * (0.3 + 0.3 * math.cos(progress * math.pi)),
    );
    canvas.drawCircle(center1, size.width * 0.28, paint1);

    final center2 = Offset(
      size.width * (0.7 - 0.4 * math.sin(progress * math.pi)),
      size.height * (0.7 - 0.3 * math.cos(progress * math.pi)),
    );
    canvas.drawCircle(center2, size.width * 0.32, paint2);
  }

  @override
  bool shouldRepaint(covariant _BackgroundBlobsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
