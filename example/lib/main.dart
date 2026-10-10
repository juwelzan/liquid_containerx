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

class DemoHome extends StatelessWidget {
  const DemoHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiquidContainerx')),
      body: Center(
        child: LiquidContainer(
          width: 280,
          height: 180,
          shape: LiquidShape.squircle(),
          glass: const LiquidGlass(
            opacity: 0.16,
            blur: 12,
          ),
          physics: const LiquidPhysics(
            enabled: true,
            elasticity: 0.75,
            viscosity: 0.65,
          ),
          child: const Center(
            child: Text('LiquidContainerx'),
          ),
        ),
      ),
    );
  }
}
