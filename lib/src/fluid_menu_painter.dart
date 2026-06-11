import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom painter that draws a premium organic gooey liquid transition.
///
/// It generates multi-frequency wave shapes across five distance-staggered
/// expansion centers based on distance from the top-left menu toggle button.
class FluidMenuPainter extends CustomPainter {
  /// The linear progress of the transition animation (from 0.0 to 1.0).
  final double progress;

  /// The background color used when rendering solid transition backgrounds.
  final Color fluidColor;

  /// The optional background gradient used when rendering gradient transition backgrounds.
  final Gradient? fluidGradient;

  /// The button radius for the initial top-left menu trigger button.
  final double buttonRadius;

  /// The easing curve used to transform the progress coordinates.
  final Curve animationCurve;

  /// Creates a [FluidMenuPainter] with transition configurations.
  FluidMenuPainter({
    required this.progress,
    required this.fluidColor,
    this.fluidGradient,
    required this.buttonRadius,
    required this.animationCurve,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    // The reveal center is hardcoded to the top-left menu button center (X: 44.0, Y: 64.0)
    final Offset revealCenter = const Offset(44.0, 64.0);

    // Setup paint with gradient/color
    final Rect bounds = Offset.zero & size;
    final Paint shapePaint = Paint();
    if (fluidGradient != null) {
      shapePaint.shader = fluidGradient!.createShader(bounds);
    } else {
      shapePaint.color = fluidColor;
    }
    shapePaint.style = PaintingStyle.fill;
    shapePaint.isAntiAlias = true;

    // Define all 5 expansion centers: 4 corners + center of the screen
    final List<Offset> centers = [
      const Offset(44.0, 64.0), // Top Left
      Offset(size.width - 44.0, 64.0), // Top Right
      Offset(44.0, size.height - 64.0), // Bottom Left
      Offset(size.width - 44.0, size.height - 64.0), // Bottom Right
      Offset(size.width / 2, size.height / 2), // Center
    ];

    // Screen diagonal serves as the maximum distance for delay calculations
    final double screenDiagonal = math.sqrt(size.width * size.width + size.height * size.height);

    for (final center in centers) {
      // Calculate delay based on distance from the top-left origin
      final double distance = (center - revealCenter).distance;
      
      // Proportional delay: furthest point starts after 32% of progress has elapsed
      final double delay = (distance / screenDiagonal) * 0.32;

      double localProgress = 0.0;
      if (progress > delay) {
        localProgress = (progress - delay) / (1.0 - delay);
        localProgress = localProgress.clamp(0.0, 1.0);
      }

      if (localProgress > 0.0) {
        final double maxRadius = _getMaxRadius(size, center) + 120.0;
        final bool isRevealOrigin = (center - revealCenter).distance < 2.0;
        final double startRadius = isRevealOrigin ? buttonRadius : 0.0;

        _drawWavyCircle(canvas, center, startRadius, maxRadius, localProgress, shapePaint);
      } else if (progress == 0.0 && (center - revealCenter).distance < 2.0) {
        canvas.drawCircle(center, buttonRadius, shapePaint);
      }
    }
  }

  /// Draws a circle with animated waves/ripples along its contour
  void _drawWavyCircle(
    Canvas canvas,
    Offset center,
    double startRadius,
    double maxRadius,
    double localProgress,
    Paint paint,
  ) {
    if (localProgress <= 0.0) return;
    if (localProgress >= 1.0) {
      canvas.drawCircle(center, maxRadius, paint);
      return;
    }

    final double curveVal = animationCurve.transform(localProgress);
    final double baseRadius = startRadius + (maxRadius - startRadius) * curveVal;

    final double amplitude = (baseRadius * 0.16).clamp(12.0, 50.0) * math.sin(localProgress * math.pi);
    
    final Path path = Path();
    const int pointsCount = 96;
    
    for (int i = 0; i <= pointsCount; i++) {
      final double theta = (i / pointsCount) * 2 * math.pi;
      
      final double wave1 = math.sin(4 * theta + localProgress * 2.5 * math.pi);
      final double wave2 = math.cos(2 * theta - localProgress * 1.8 * math.pi);
      final double wave3 = math.sin(6 * theta + localProgress * 1.2 * math.pi);
      
      final double r = baseRadius + amplitude * (wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2);
      
      final double x = center.dx + r * math.cos(theta);
      final double y = center.dy + r * math.sin(theta);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _getMaxRadius(Size size, Offset center) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    double maxDist = 0.0;
    for (final corner in corners) {
      final dist = (corner - center).distance;
      if (dist > maxDist) maxDist = dist;
    }
    return maxDist;
  }

  @override
  bool shouldRepaint(covariant FluidMenuPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fluidColor != fluidColor ||
        oldDelegate.fluidGradient != fluidGradient ||
        oldDelegate.buttonRadius != buttonRadius ||
        oldDelegate.animationCurve != animationCurve;
  }
}
