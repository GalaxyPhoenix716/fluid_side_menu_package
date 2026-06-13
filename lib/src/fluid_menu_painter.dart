import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom painter that renders the organic, gooey liquid-reveal transition
/// used by [FluidSideMenu].
///
/// The transition is constructed from five overlapping wavy circles, each
/// expanding from a different origin point derived from the [revealCenter].
/// The origins are staggered in time based on their distance from [revealCenter],
/// so nearer origins start expanding earlier and farther origins catch up,
/// producing the signature "gooey merge" visual.
///
/// ## Wave rendering
/// Each expanding circle is drawn as a closed polygon of 96 radially-sampled
/// points. The radius of each point is perturbed by three superimposed sine
/// waves with different frequencies, producing organic ripples along the edge.
/// Wave amplitude peaks at the mid-point of the expansion and falls to zero at
/// both the start and end, so the edges appear smooth when fully open or closed.
///
/// ## Performance
/// [shouldRepaint] returns `false` unless any painter property changed, keeping
/// the painter lightweight inside `AnimatedBuilder`. The caller wraps the
/// `CustomPaint` in a `RepaintBoundary` to prevent the wave from triggering
/// repaints in sibling layers.
class FluidMenuPainter extends CustomPainter {
  /// The linear progress of the transition animation in the range `[0.0, 1.0]`.
  ///
  /// This value is fed directly from the `AnimationController` value (without
  /// any curve applied) to avoid double-curving. The easing curve is applied
  /// inside [_drawWavyCircle] via [animationCurve].
  final double progress;

  /// The solid background color painted behind the menu when [fluidGradient]
  /// is `null`.
  final Color fluidColor;

  /// An optional gradient that supersedes [fluidColor] as the wave fill.
  ///
  /// A shader is created from this gradient once per paint call and assigned
  /// to the canvas `Paint` object.
  final Gradient? fluidGradient;

  /// The radius of the initial circular menu toggle button rendered before the
  /// transition starts.
  ///
  /// The wave expansion begins from a circle of this radius at [revealCenter],
  /// creating a visually seamless start from the button.
  final double buttonRadius;

  /// The easing curve applied to each individual expansion circle's local
  /// progress value.
  ///
  /// Applied once inside [_drawWavyCircle], this curve shapes the acceleration
  /// of each wavy circle without affecting the stagger timing calculation.
  final Curve animationCurve;

  /// The screen-space origin point from which the gooey reveal wave starts.
  ///
  /// Defaults to the position of the built-in menu toggle button
  /// (`Offset(44.0, 64.0)`). The four additional expansion centers are
  /// derived symmetrically from this point relative to the canvas size.
  final Offset revealCenter;

  /// Creates a [FluidMenuPainter] with the given transition properties.
  FluidMenuPainter({
    required this.progress,
    required this.fluidColor,
    this.fluidGradient,
    required this.buttonRadius,
    required this.animationCurve,
    required this.revealCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    // Setup paint with gradient/color.
    final Rect bounds = Offset.zero & size;
    final Paint shapePaint = Paint();
    if (fluidGradient != null) {
      shapePaint.shader = fluidGradient!.createShader(bounds);
    } else {
      shapePaint.color = fluidColor;
    }
    shapePaint.style = PaintingStyle.fill;
    shapePaint.isAntiAlias = true;

    // Define all 5 expansion centers dynamically mirrored relative to revealCenter.
    // This ensures the wave always fills the entire canvas regardless of where
    // revealCenter is positioned.
    final List<Offset> centers = [
      revealCenter, // Dynamic start point (near the menu toggle button)
      Offset(size.width - revealCenter.dx, revealCenter.dy),
      Offset(revealCenter.dx, size.height - revealCenter.dy),
      Offset(size.width - revealCenter.dx, size.height - revealCenter.dy),
      Offset(size.width / 2, size.height / 2),
    ];

    // The screen diagonal is used as the maximum possible distance for
    // proportional delay calculations.
    final double screenDiagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    for (final center in centers) {
      // Calculate start delay based on Euclidean distance from the origin.
      // The furthest center starts after 32% of the total animation has elapsed.
      final double distance = (center - revealCenter).distance;
      final double delay = (distance / screenDiagonal) * 0.32;

      double localProgress = 0.0;
      if (progress > delay) {
        localProgress = (progress - delay) / (1.0 - delay);
        localProgress = localProgress.clamp(0.0, 1.0);
      }

      if (localProgress > 0.0) {
        final double maxRadius = _getMaxRadius(size, center) + 120.0;
        final bool isRevealOrigin = (center - revealCenter).distance < 2.0;
        // The origin circle starts from the button radius; others start from 0.
        final double startRadius = isRevealOrigin ? buttonRadius : 0.0;

        _drawWavyCircle(
          canvas,
          center,
          startRadius,
          maxRadius,
          localProgress,
          shapePaint,
        );
      } else if (progress == 0.0 && (center - revealCenter).distance < 2.0) {
        // Draw the static menu button circle before any animation starts.
        canvas.drawCircle(center, buttonRadius, shapePaint);
      }
    }
  }

  /// Draws a single expanding wavy circle at [center].
  ///
  /// The circle grows from [startRadius] to [maxRadius] over the range
  /// `[0.0, 1.0]` of [localProgress]. Along the edge, three superimposed
  /// sine waves distort the contour to create organic gooey ripples.
  ///
  /// At full expansion ([localProgress] >= `1.0`) a plain circle is drawn
  /// for maximum efficiency.
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

    // Apply the easing curve to the local progress for smooth acceleration.
    final double curveVal = animationCurve.transform(localProgress);
    final double baseRadius =
        startRadius + (maxRadius - startRadius) * curveVal;

    // Amplitude peaks at the midpoint of the expansion (sin(pi) = 0 at both ends).
    final double amplitude =
        (baseRadius * 0.16).clamp(12.0, 50.0) *
        math.sin(localProgress * math.pi);

    final Path path = Path();
    // 96 points gives a smooth curve while keeping polygon tessellation cheap.
    const int pointsCount = 96;

    for (int i = 0; i <= pointsCount; i++) {
      final double theta = (i / pointsCount) * 2 * math.pi;

      // Three waves at different frequencies and phase offsets produce
      // an aperiodic, organic ripple pattern.
      final double wave1 = math.sin(4 * theta + localProgress * 2.5 * math.pi);
      final double wave2 = math.cos(2 * theta - localProgress * 1.8 * math.pi);
      final double wave3 = math.sin(6 * theta + localProgress * 1.2 * math.pi);

      final double r =
          baseRadius + amplitude * (wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2);

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

  /// Returns the distance from [center] to the farthest corner of [size].
  ///
  /// Used to determine the maximum expansion radius needed to guarantee the
  /// wave fully covers the canvas, regardless of where [center] is located.
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
        oldDelegate.animationCurve != animationCurve ||
        oldDelegate.revealCenter != revealCenter;
  }
}
