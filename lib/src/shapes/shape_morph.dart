import 'dart:ui';

import 'liquid_glass_shape.dart';

/// Interpolates smoothly between two shapes using normalized arc-length path sampling.
class LiquidShapeMorph {
  /// Samples [sampleCount] points along [path] and returns them.
  static List<Offset> samplePath(Path path, {int sampleCount = 80}) {
    final points = <Offset>[];
    final metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return points;
    }

    final totalLength = metrics.fold<double>(0.0, (acc, m) => acc + m.length);
    if (totalLength <= 0.0) {
      return points;
    }

    final step = totalLength / sampleCount;
    var currentDist = 0.0;
    var metricIndex = 0;
    var accumulatedPrev = 0.0;

    for (var i = 0; i < sampleCount; i++) {
      currentDist = i * step;

      while (metricIndex < metrics.length - 1 &&
          currentDist > accumulatedPrev + metrics[metricIndex].length) {
        accumulatedPrev += metrics[metricIndex].length;
        metricIndex++;
      }

      final localDist = (currentDist - accumulatedPrev).clamp(
        0.0,
        metrics[metricIndex].length,
      );
      final tangent = metrics[metricIndex].getTangentForOffset(localDist);
      if (tangent != null) {
        points.add(tangent.position);
      }
    }

    return points;
  }

  /// Builds a morphed [Path] linearly interpolating between [shapeA] and [shapeB]
  /// at animation parameter [t] (range `[0.0, 1.0]`).
  static Path morphShapes(
    LiquidGlassShape shapeA,
    LiquidGlassShape shapeB,
    Size size,
    double t, {
    int sampleCount = 80,
  }) {
    if (t <= 0.0) {
      return shapeA.buildPath(size);
    }
    if (t >= 1.0) {
      return shapeB.buildPath(size);
    }

    final pathA = shapeA.buildPath(size);
    final pathB = shapeB.buildPath(size);

    final pointsA = samplePath(pathA, sampleCount: sampleCount);
    final pointsB = samplePath(pathB, sampleCount: sampleCount);

    if (pointsA.length < 3 || pointsB.length < 3) {
      return t < 0.5 ? pathA : pathB;
    }

    final count = pointsA.length < pointsB.length
        ? pointsA.length
        : pointsB.length;
    final morphedPoints = <Offset>[];

    for (var i = 0; i < count; i++) {
      final pA = pointsA[i];
      final pB = pointsB[i];
      morphedPoints.add(
        Offset(
          lerpDouble(pA.dx, pB.dx, t) ?? pA.dx,
          lerpDouble(pA.dy, pB.dy, t) ?? pA.dy,
        ),
      );
    }

    final morphedPath = Path();
    morphedPath.moveTo(
      (morphedPoints[0].dx + morphedPoints[count - 1].dx) / 2,
      (morphedPoints[0].dy + morphedPoints[count - 1].dy) / 2,
    );

    for (var i = 0; i < count; i++) {
      final next = morphedPoints[(i + 1) % count];
      final mid = Offset(
        (morphedPoints[i].dx + next.dx) / 2,
        (morphedPoints[i].dy + next.dy) / 2,
      );
      morphedPath.quadraticBezierTo(
        morphedPoints[i].dx,
        morphedPoints[i].dy,
        mid.dx,
        mid.dy,
      );
    }

    morphedPath.close();
    return morphedPath;
  }
}
