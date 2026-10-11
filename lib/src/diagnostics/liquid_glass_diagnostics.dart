import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/liquid_glass.dart';
import '../core/liquid_glass_quality.dart';

/// Lightweight performance diagnostic tracker collecting real frame timings.
class LiquidGlassPerformanceTracker extends ChangeNotifier {
  LiquidGlassPerformanceTracker._();

  static final LiquidGlassPerformanceTracker instance =
      LiquidGlassPerformanceTracker._();

  bool _isTracking = false;
  int _totalFrames = 0;
  int _slowFrames = 0;
  double _totalDurationMs = 0.0;
  double _worstDurationMs = 0.0;
  double _lastDurationMs = 0.0;
  bool _target120Hz = false;

  /// Whether diagnostic tracking is actively recording frame timings.
  bool get isTracking => _isTracking;

  /// Total number of observed frames.
  int get totalFrames => _totalFrames;

  /// Frames that exceeded the target frame budget.
  int get slowFrames => _slowFrames;

  /// Average frame raster duration in milliseconds.
  double get averageDurationMs =>
      _totalFrames > 0 ? _totalDurationMs / _totalFrames : 0.0;

  /// Maximum observed frame duration in milliseconds.
  double get worstDurationMs => _worstDurationMs;

  /// Last observed frame duration in milliseconds.
  double get lastDurationMs => _lastDurationMs;

  /// Target budget: 8.33 ms for 120 Hz, 16.67 ms for 60 Hz.
  double get frameBudgetMs => _target120Hz ? 8.33 : 16.67;

  /// Starts frame timing recording via [WidgetsBinding.instance.addTimingsCallback].
  void start() {
    if (_isTracking || kReleaseMode) return;
    _isTracking = true;
    WidgetsBinding.instance.addTimingsCallback(_onTimings);
    notifyListeners();
  }

  /// Stops frame timing recording.
  void stop() {
    if (!_isTracking) return;
    _isTracking = false;
    WidgetsBinding.instance.removeTimingsCallback(_onTimings);
    notifyListeners();
  }

  /// Resets recorded performance metrics.
  void reset() {
    _totalFrames = 0;
    _slowFrames = 0;
    _totalDurationMs = 0.0;
    _worstDurationMs = 0.0;
    _lastDurationMs = 0.0;
    notifyListeners();
  }

  /// Sets whether the frame budget target is 120 Hz (8.33 ms) or 60 Hz (16.67 ms).
  void setTarget120Hz(bool enable) {
    _target120Hz = enable;
    notifyListeners();
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final durationMs = timing.totalSpan.inMicroseconds / 1000.0;
      _totalFrames++;
      _totalDurationMs += durationMs;
      _lastDurationMs = durationMs;

      if (durationMs > _worstDurationMs) {
        _worstDurationMs = durationMs;
      }
      if (durationMs > frameBudgetMs) {
        _slowFrames++;
      }
    }
    notifyListeners();
  }
}

/// A debug diagnostic overlay displaying live frame rates, shader status,
/// and rendering quality.
class LiquidGlassDiagnosticsOverlay extends StatelessWidget {
  const LiquidGlassDiagnosticsOverlay({
    super.key,
    this.quality = LiquidGlassQuality.auto,
    this.alignment = Alignment.topRight,
  });

  final LiquidGlassQuality quality;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return const SizedBox.shrink();
    }

    final tracker = LiquidGlassPerformanceTracker.instance;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: tracker,
          builder: (context, _) {
            final avg = tracker.averageDurationMs.toStringAsFixed(1);
            final worst = tracker.worstDurationMs.toStringAsFixed(1);
            final last = tracker.lastDurationMs.toStringAsFixed(1);
            final slow = tracker.slowFrames;
            final total = tracker.totalFrames;
            final isShaderReady = LiquidGlass.hasShaderSupport;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isShaderReady
                              ? Icons.check_circle
                              : Icons.warning_amber,
                          size: 13,
                          color: isShaderReady
                              ? Colors.greenAccent
                              : Colors.amberAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Shader: ${isShaderReady ? "GLSL HW" : "Canvas Fallback"}',
                          style: TextStyle(
                            color: isShaderReady
                                ? Colors.greenAccent
                                : Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Quality: ${quality.name}'),
                    Text('Frame: ${last}ms (avg: ${avg}ms, max: ${worst}ms)'),
                    Text(
                      'Budget: ${tracker.frameBudgetMs.toStringAsFixed(1)}ms | Slow: $slow/$total',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
