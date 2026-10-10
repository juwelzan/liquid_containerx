import 'package:flutter/material.dart';
import 'package:liquid_containerx/liquid_containerx.dart';

void main() {
  runApp(const LiquidDemoApp());
}

class LiquidDemoApp extends StatelessWidget {
  const LiquidDemoApp({Key? key}) : super(key: key);

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
  const DemoHome({Key? key}) : super(key: key);

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  bool _enableShaders = true;
  double _distortion = 0.05;
  double _highlight = 0.3;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiquidContainerx - Phase 3')),
      body: Stack(
        children: [
          // Background pattern to inspect distortion (though our fake distortion won't refract this without full offscreen buffer, it shows contrast)
          Positioned.fill(
            child: GridPaper(
              color: Colors.blueAccent.withValues(alpha: 0.2),
              divisions: 2,
              subdivisions: 2,
            ),
          ),
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
                            shape: LiquidShape.squircle(),
                            glass: const LiquidGlass(
                              enableShaders: false,
                              opacity: 0.16,
                              blur: 12,
                            ),
                          ),
                        ],
                      ),
                      // Shader
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Shader: ${_enableShaders ? "ON" : "OFF Fallback"}'),
                          const SizedBox(height: 16),
                          LiquidContainer(
                            width: 150,
                            height: 150,
                            shape: LiquidShape.squircle(),
                            glass: LiquidGlass(
                              enableShaders: _enableShaders,
                              distortionStrength: _distortion,
                              highlightIntensity: _highlight,
                              opacity: 0.16,
                              blur: 12,
                              tintColor: const Color(0x3300FFFF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Controls
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
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
                            onChanged: (v) => setState(() => _distortion = v),
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
                            onChanged: (v) => setState(() => _highlight = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
