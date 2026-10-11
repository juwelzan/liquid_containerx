import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A pure-Dart parser for SVG path data (`d` attribute string) into Flutter [Path] instances.
///
/// Supports standard SVG commands:
/// - Move: `M`, `m`
/// - Line: `L`, `l`, `H`, `h`, `V`, `v`
/// - Cubic Bézier: `C`, `c`, `S`, `s`
/// - Quadratic Bézier: `Q`, `q`, `T`, `t`
/// - Elliptical Arc: `A`, `a`
/// - Close Path: `Z`, `z`
///
/// Designed with resilient error handling: malformed tokens or trailing characters
/// will not crash the runtime, but gracefully produce a valid clamped path.
class SvgPathParser {
  /// Parses an SVG path data string into a Flutter [Path].
  ///
  /// If [fitSize] is provided, the resulting path will be scaled and centered
  /// to fit within the specified bounds while preserving aspect ratio.
  static Path parse(String svgPathData, {Size? fitSize}) {
    final path = Path();
    if (svgPathData.trim().isEmpty) return path;

    try {
      final tokens = _tokenize(svgPathData);
      var index = 0;

      double currentX = 0.0;
      double currentY = 0.0;
      double startX = 0.0;
      double startY = 0.0;
      double lastControlX = 0.0;
      double lastControlY = 0.0;
      String lastCommand = '';

      while (index < tokens.length) {
        final loopStart = index;
        final token = tokens[index];
        final isCmd = _isCommand(token);

        String cmd;
        if (isCmd) {
          cmd = token;
          index++;
        } else if (lastCommand.isNotEmpty) {
          // In SVG, omitting command repeats the last command (M becomes L, m becomes l)
          if (lastCommand == 'M') {
            cmd = 'L';
          } else if (lastCommand == 'm') {
            cmd = 'l';
          } else {
            cmd = lastCommand;
          }
        } else {
          index++;
          continue;
        }

        switch (cmd) {
          case 'M':
          case 'm':
            final isRel = cmd == 'm';
            if (index + 1 < tokens.length) {
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;
              currentX = isRel ? currentX + x : x;
              currentY = isRel ? currentY + y : y;
              startX = currentX;
              startY = currentY;
              path.moveTo(currentX, currentY);
              lastControlX = currentX;
              lastControlY = currentY;
            }
            break;

          case 'L':
          case 'l':
            final isRel = cmd == 'l';
            if (index + 1 < tokens.length) {
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;
              currentX = isRel ? currentX + x : x;
              currentY = isRel ? currentY + y : y;
              path.lineTo(currentX, currentY);
              lastControlX = currentX;
              lastControlY = currentY;
            }
            break;

          case 'H':
          case 'h':
            final isRel = cmd == 'h';
            if (index < tokens.length) {
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              currentX = isRel ? currentX + x : x;
              path.lineTo(currentX, currentY);
              lastControlX = currentX;
              lastControlY = currentY;
            }
            break;

          case 'V':
          case 'v':
            final isRel = cmd == 'v';
            if (index < tokens.length) {
              final y = double.tryParse(tokens[index++]) ?? 0.0;
              currentY = isRel ? currentY + y : y;
              path.lineTo(currentX, currentY);
              lastControlX = currentX;
              lastControlY = currentY;
            }
            break;

          case 'C':
          case 'c':
            final isRel = cmd == 'c';
            if (index + 5 < tokens.length) {
              final x1 = double.tryParse(tokens[index++]) ?? 0.0;
              final y1 = double.tryParse(tokens[index++]) ?? 0.0;
              final x2 = double.tryParse(tokens[index++]) ?? 0.0;
              final y2 = double.tryParse(tokens[index++]) ?? 0.0;
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;

              final c1X = isRel ? currentX + x1 : x1;
              final c1Y = isRel ? currentY + y1 : y1;
              final c2X = isRel ? currentX + x2 : x2;
              final c2Y = isRel ? currentY + y2 : y2;
              currentX = isRel ? currentX + x : x;
              currentY = isRel ? currentY + y : y;

              path.cubicTo(c1X, c1Y, c2X, c2Y, currentX, currentY);
              lastControlX = c2X;
              lastControlY = c2Y;
            }
            break;

          case 'S':
          case 's':
            final isRel = cmd == 's';
            if (index + 3 < tokens.length) {
              final x2 = double.tryParse(tokens[index++]) ?? 0.0;
              final y2 = double.tryParse(tokens[index++]) ?? 0.0;
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;

              // Reflection of previous control point
              final c1X =
                  (lastCommand.toLowerCase() == 'c' ||
                      lastCommand.toLowerCase() == 's')
                  ? 2 * currentX - lastControlX
                  : currentX;
              final c1Y =
                  (lastCommand.toLowerCase() == 'c' ||
                      lastCommand.toLowerCase() == 's')
                  ? 2 * currentY - lastControlY
                  : currentY;

              final c2X = isRel ? currentX + x2 : x2;
              final c2Y = isRel ? currentY + y2 : y2;
              currentX = isRel ? currentX + x : x;
              currentY = isRel ? currentY + y : y;

              path.cubicTo(c1X, c1Y, c2X, c2Y, currentX, currentY);
              lastControlX = c2X;
              lastControlY = c2Y;
            }
            break;

          case 'Q':
          case 'q':
            final isRel = cmd == 'q';
            if (index + 3 < tokens.length) {
              final x1 = double.tryParse(tokens[index++]) ?? 0.0;
              final y1 = double.tryParse(tokens[index++]) ?? 0.0;
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;

              final cX = isRel ? currentX + x1 : x1;
              final cY = isRel ? currentY + y1 : y1;
              currentX = isRel ? currentX + x : x;
              currentY = isRel ? currentY + y : y;

              path.quadraticBezierTo(cX, cY, currentX, currentY);
              lastControlX = cX;
              lastControlY = cY;
            }
            break;

          case 'T':
          case 't':
            final isRel = cmd == 't';
            if (index + 1 < tokens.length) {
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;

              final cX =
                  (lastCommand.toLowerCase() == 'q' ||
                      lastCommand.toLowerCase() == 't')
                  ? 2 * currentX - lastControlX
                  : currentX;
              final cY =
                  (lastCommand.toLowerCase() == 'q' ||
                      lastCommand.toLowerCase() == 't')
                  ? 2 * currentY - lastControlY
                  : currentY;

              currentX = isRel ? currentX + x : x;
              currentY = isRel ? currentY + y : y;

              path.quadraticBezierTo(cX, cY, currentX, currentY);
              lastControlX = cX;
              lastControlY = cY;
            }
            break;

          case 'A':
          case 'a':
            final isRel = cmd == 'a';
            if (index + 6 < tokens.length) {
              final rx = (double.tryParse(tokens[index++]) ?? 0.0).abs();
              final ry = (double.tryParse(tokens[index++]) ?? 0.0).abs();
              final xAxisRotation = double.tryParse(tokens[index++]) ?? 0.0;
              final largeArcFlag =
                  (double.tryParse(tokens[index++]) ?? 0.0) != 0;
              final sweepFlag = (double.tryParse(tokens[index++]) ?? 0.0) != 0;
              final x = double.tryParse(tokens[index++]) ?? 0.0;
              final y = double.tryParse(tokens[index++]) ?? 0.0;

              final targetX = isRel ? currentX + x : x;
              final targetY = isRel ? currentY + y : y;

              _arcTo(
                path,
                currentX,
                currentY,
                targetX,
                targetY,
                rx,
                ry,
                xAxisRotation,
                largeArcFlag,
                sweepFlag,
              );

              currentX = targetX;
              currentY = targetY;
              lastControlX = currentX;
              lastControlY = currentY;
            }
            break;

          case 'Z':
          case 'z':
            path.close();
            currentX = startX;
            currentY = startY;
            lastControlX = currentX;
            lastControlY = currentY;
            break;

          default:
            break;
        }

        lastCommand = cmd;
        if (index <= loopStart) {
          index++;
        }
      }
    } catch (_) {
      // Return gracefully even if parser encounters irregular syntax
    }

    if (fitSize != null && fitSize.width > 0 && fitSize.height > 0) {
      return _scaleAndFit(path, fitSize);
    }

    return path;
  }

  static bool _isCommand(String token) {
    if (token.length != 1) return false;
    const commands = 'MmLlHhVvCcSsQqTtAaZz';
    return commands.contains(token);
  }

  static List<String> _tokenize(String d) {
    final tokens = <String>[];
    final regex = RegExp(
      r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?',
    );
    for (final match in regex.allMatches(d)) {
      tokens.add(match.group(0)!);
    }
    return tokens;
  }

  static Path _scaleAndFit(Path sourcePath, Size targetSize) {
    final bounds = sourcePath.getBounds();
    if (bounds.isEmpty || bounds.width == 0 || bounds.height == 0) {
      return sourcePath;
    }

    final scaleX = targetSize.width / bounds.width;
    final scaleY = targetSize.height / bounds.height;
    final scale = math.min(scaleX, scaleY);

    final dx =
        (targetSize.width - bounds.width * scale) / 2 - bounds.left * scale;
    final dy =
        (targetSize.height - bounds.height * scale) / 2 - bounds.top * scale;

    final matrix = Matrix4.diagonal3Values(scale, scale, 1.0)
      ..setTranslationRaw(dx, dy, 0.0);

    return sourcePath.transform(matrix.storage);
  }

  static void _arcTo(
    Path path,
    double x1,
    double y1,
    double x2,
    double y2,
    double rx,
    double ry,
    double phi,
    bool largeArc,
    bool sweep,
  ) {
    if (rx == 0 || ry == 0) {
      path.lineTo(x2, y2);
      return;
    }

    final rad = phi * math.pi / 180.0;
    final cosPhi = math.cos(rad);
    final sinPhi = math.sin(rad);

    final dx = (x1 - x2) / 2.0;
    final dy = (y1 - y2) / 2.0;
    final x1p = cosPhi * dx + sinPhi * dy;
    final y1p = -sinPhi * dx + cosPhi * dy;

    var rxSq = rx * rx;
    var rySq = ry * ry;
    final x1pSq = x1p * x1p;
    final y1pSq = y1p * y1p;

    final radiiCheck = x1pSq / rxSq + y1pSq / rySq;
    if (radiiCheck > 1.0) {
      final s = math.sqrt(radiiCheck);
      rx *= s;
      ry *= s;
      rxSq = rx * rx;
      rySq = ry * ry;
    }

    var sign = (largeArc == sweep) ? -1.0 : 1.0;
    final numerator = rxSq * rySq - rxSq * y1pSq - rySq * x1pSq;
    final denom = rxSq * y1pSq + rySq * x1pSq;
    final coef = sign * math.sqrt(math.max(0.0, numerator / denom));

    final cxp = coef * (rx * y1p / ry);
    final cyp = coef * -(ry * x1p / rx);

    final cx = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2.0;
    final cy = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2.0;

    final theta1 = math.atan2((y1p - cyp) / ry, (x1p - cxp) / rx);
    var dTheta = math.atan2((-y1p - cyp) / ry, (-x1p - cxp) / rx) - theta1;

    if (sweep && dTheta < 0) {
      dTheta += 2 * math.pi;
    } else if (!sweep && dTheta > 0) {
      dTheta -= 2 * math.pi;
    }

    final segments = (dTheta.abs() / (math.pi / 2)).ceil();
    final delta = dTheta / segments;
    final t =
        8.0 /
        3.0 *
        math.sin(delta / 4) *
        math.sin(delta / 4) /
        math.sin(delta / 2);

    var startAngle = theta1;
    for (var i = 0; i < segments; i++) {
      final endAngle = startAngle + delta;
      final cosStart = math.cos(startAngle);
      final sinStart = math.sin(startAngle);
      final cosEnd = math.cos(endAngle);
      final sinEnd = math.sin(endAngle);

      final p1x = cx + rx * (cosStart - t * sinStart);
      final p1y = cy + ry * (sinStart + t * cosStart);
      final p2x = cx + rx * (cosEnd + t * sinEnd);
      final p2y = cy + ry * (sinEnd - t * cosEnd);
      final endX = cx + rx * cosEnd;
      final endY = cy + ry * sinEnd;

      path.cubicTo(p1x, p1y, p2x, p2y, endX, endY);
      startAngle = endAngle;
    }
  }
}
