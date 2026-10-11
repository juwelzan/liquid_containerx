import 'package:flutter/material.dart';

import 'package:liquid_containerx/liquid_containerx.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  runApp(const LiquidDemoApp());
}

class LiquidDemoApp extends StatelessWidget {
  const LiquidDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Containerx Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  bool _enableShaders = true;
  double _distortion = 0.05;
  double _highlight = 0.3;

  late YoutubePlayerController _youtubeController;
  bool _isVideoLoading = true;
  bool _isVideoError = false;
  final LiquidGlassController _glassController = LiquidGlassController();

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (mounted) {
      setState(() {
        _isVideoLoading = true;
        _isVideoError = false;
      });
    }

    _youtubeController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        loop: true,
        mute: true,
        strictRelatedVideos: true,
        playsInline: true,
      ),
    );

    try {
      // Use a nice scenic video or abstract animation for the background
      await _youtubeController.loadVideoById(videoId: "dQw4w9WgXcQ");
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      debugPrint("YouTube player initialization failed: $e");
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _youtubeController.close();
    _glassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiquidContainerx - Demo')),
      body: LiquidGlassLayer(
        settings: LiquidGlassSettings.standard,
        child: Stack(
          children: [
            // Fallback Background
            Positioned.fill(
              child: GridPaper(
                color: Colors.blueAccent.withValues(alpha: 0.2),
                divisions: 2,
                subdivisions: 2,
              ),
            ),

            // YouTube Background (Fitted to cover)
            if (!_isVideoError)
              Positioned.fill(
                child: IgnorePointer(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          // Use a standard 16:9 ratio for the base size
                          width: constraints.maxWidth,
                          height: constraints.maxWidth / (16 / 9),
                          child: _isVideoLoading
                              ? const Center(child: CircularProgressIndicator())
                              : YoutubePlayer(
                                  controller: _youtubeController,
                                  aspectRatio: 16 / 9,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (_isVideoError)
              Positioned(
                top: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: _initVideo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Background Video'),
                ),
              ),

            // Foreground UI
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Baseline
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Baseline (No Shader)'),
                            const SizedBox(height: 16),
                            LiquidContainer(
                              width: 150,
                              height: 150,
                              shape: LiquidShape.blob,
                              glass: LiquidGlass(
                                tintColor: Colors.black.withValues(alpha: 0.0),
                                opacity: 0.0,
                                blur: 12,
                              ),
                            ),
                          ],
                        ),
                        // Shader
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shader: ${_enableShaders ? "ON" : "OFF Fallback"}',
                            ),
                            const SizedBox(height: 16),
                            LiquidContainer(
                              width: 150,
                              height: 150,
                              shape: LiquidShape.pill,
                              glass: LiquidGlass(
                                enableShaders: _enableShaders,
                                distortionStrength: _distortion,
                                highlightIntensity: _highlight,
                                opacity: 0.16,
                                blur: 12,
                                tintColor: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Controls
                Material(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Shaders'),
                          value: _enableShaders,
                          onChanged: (v) => setState(() => _enableShaders = v),
                        ),
                        Row(
                          children: [
                            const Text('Distortion: '),
                            Expanded(
                              child: Slider(
                                value: _distortion,
                                max: 1.0,
                                onChanged: (v) =>
                                    setState(() => _distortion = v),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Highlight: '),
                            Expanded(
                              child: Slider(
                                value: _highlight,
                                max: 1.0,
                                onChanged: (v) =>
                                    setState(() => _highlight = v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
