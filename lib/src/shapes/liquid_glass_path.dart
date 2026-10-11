import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Low-level geometric generator for liquid glass paths.
class LiquidGlassPathBuilder {
  const LiquidGlassPathBuilder._();

  /// Builds a rounded rectangle path.
  static Path buildRoundedRectangle(Size size, BorderRadius borderRadius) {
    final path = Path();
    path.addRRect(borderRadius.toRRect(Offset.zero & size));
    return path;
  }

  /// Builds an iOS-style continuous corner squircle path.
  ///
  /// [cornerSmoothing] controls the transition smoothness (0.0 = classic arc,
  /// 0.6 = standard iOS, 1.0 = deep superellipse).
  static Path buildSquircle(
    Size size, {
    double cornerRadius = 24.0,
    double cornerSmoothing = 0.72,
  }) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    final maxRadius = math.min(width, height) / 2.0;
    final r = cornerRadius.clamp(0.0, maxRadius);
    if (r == 0.0) {
      path.addRect(Offset.zero & size);
      return path;
    }

    final p = (r * (1.0 + cornerSmoothing * 0.5)).clamp(r, maxRadius);
    final c = r * 0.551915024494 * (1.0 - cornerSmoothing * 0.2);

    path.moveTo(p, 0);

    // Top edge & Top-Right corner
    path.lineTo(width - p, 0);
    path.cubicTo(width - p + c, 0, width, p - c, width, p);

    // Right edge & Bottom-Right corner
    path.lineTo(width, height - p);
    path.cubicTo(
      width,
      height - p + c,
      width - p + c,
      height,
      width - p,
      height,
    );

    // Bottom edge & Bottom-Left corner
    path.lineTo(p, height);
    path.cubicTo(p - c, height, 0, height - p + c, 0, height - p);

    // Left edge & Top-Left corner
    path.lineTo(0, p);
    path.cubicTo(0, p - c, p - c, 0, p, 0);

    path.close();
    return path;
  }

  /// Builds a circle path centered within the bounds.
  static Path buildCircle(Size size) {
    final path = Path();
    final diameter = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: diameter,
      height: diameter,
    );
    path.addOval(rect);
    return path;
  }

  /// Builds a capsule / pill path.
  static Path buildCapsule(Size size) {
    final path = Path();
    final radius = math.min(size.width, size.height) / 2.0;
    path.addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );
    return path;
  }

  /// Builds an oval / ellipse path fitting the full bounding box.
  static Path buildOval(Size size) {
    final path = Path();
    path.addOval(Offset.zero & size);
    return path;
  }

  /// Builds an n-pointed star path.
  static Path buildStar(
    Size size, {
    int points = 5,
    double innerRadiusRatio = 0.48,
  }) {
    final path = Path();
    final count = math.max(3, points);
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2.0;
    final innerRadius = outerRadius * innerRadiusRatio.clamp(0.1, 0.9);

    final angleStep = math.pi / count;
    var currentAngle = -math.pi / 2;

    for (var i = 0; i < count * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(currentAngle);
      final y = center.dy + r * math.sin(currentAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      currentAngle += angleStep;
    }
    path.close();
    return path;
  }

  /// Builds a smooth mathematical heart path.
  static Path buildHeart(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.85);

    // Left lobe
    path.cubicTo(
      width * 0.05,
      height * 0.6,
      0,
      height * 0.3,
      width * 0.25,
      height * 0.15,
    );
    path.cubicTo(
      width * 0.4,
      height * 0.05,
      width / 2,
      height * 0.25,
      width / 2,
      height * 0.35,
    );

    // Right lobe
    path.cubicTo(
      width / 2,
      height * 0.25,
      width * 0.6,
      height * 0.05,
      width * 0.75,
      height * 0.15,
    );
    path.cubicTo(
      width,
      height * 0.3,
      width * 0.95,
      height * 0.6,
      width / 2,
      height * 0.85,
    );

    path.close();
    return path;
  }

  /// Builds a regular hexagon path.
  static Path buildHexagon(Size size, {double cornerRadius = 0.0}) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.0;

    final vertices = <Offset>[];
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60.0 - 30.0) * math.pi / 180.0;
      vertices.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }

    if (cornerRadius <= 0.0) {
      path.moveTo(vertices[0].dx, vertices[0].dy);
      for (var i = 1; i < vertices.length; i++) {
        path.lineTo(vertices[i].dx, vertices[i].dy);
      }
      path.close();
      return path;
    }

    // Rounded vertices
    final r = cornerRadius.clamp(0.0, radius * 0.3);
    for (var i = 0; i < 6; i++) {
      final prev = vertices[(i - 1 + 6) % 6];
      final curr = vertices[i];
      final next = vertices[(i + 1) % 6];

      final v1 = (prev - curr) / (prev - curr).distance;
      final v2 = (next - curr) / (next - curr).distance;

      final p1 = curr + v1 * r;
      final p2 = curr + v2 * r;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  /// Builds an organic liquid blob path with sinusoidal harmonics.
  static Path buildBlob(
    Size size, {
    int points = 8,
    double wobble = 0.12,
    double phase = 0.0,
  }) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2.0 * 0.88;
    final count = math.max(4, points);
    final angleStep = (math.pi * 2) / count;

    final nodes = <Offset>[];
    for (var i = 0; i < count; i++) {
      final angle = i * angleStep;
      final variation =
          math.sin(angle * 3.0 + phase) * wobble +
          math.cos(angle * 2.0 - phase * 0.7) * (wobble * 0.6);
      final r = baseRadius * (1.0 + variation);
      nodes.add(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
      );
    }

    path.moveTo(
      (nodes[0].dx + nodes[count - 1].dx) / 2,
      (nodes[0].dy + nodes[count - 1].dy) / 2,
    );

    for (var i = 0; i < count; i++) {
      final next = nodes[(i + 1) % count];
      final mid = Offset(
        (nodes[i].dx + next.dx) / 2,
        (nodes[i].dy + next.dy) / 2,
      );
      path.quadraticBezierTo(nodes[i].dx, nodes[i].dy, mid.dx, mid.dy);
    }

    path.close();
    return path;
  }
}
