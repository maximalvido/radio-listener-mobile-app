import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:radio_player/core/theme/app_theme.dart';

class AnimatedWaveChart extends StatefulWidget {
  const AnimatedWaveChart({
    super.key,
    this.isPlaying = false,
    this.isLoading = false,
    this.height = 44,
    this.particleCount = 48,
    this.color,
    this.bitrate,
  });

  final bool isPlaying;
  final bool isLoading;
  final double height;
  final int particleCount;
  final Color? color;
  final int? bitrate;

  static const int _baselineBps = 128000;

  double get _speedFactor {
    final bps = bitrate ?? _baselineBps;
    final factor = bps / _baselineBps;
    return factor.clamp(0.5, 2.0);
  }

  @override
  State<AnimatedWaveChart> createState() => _AnimatedWaveChartState();
}

class _AnimatedWaveChartState extends State<AnimatedWaveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (widget.isPlaying || widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(AnimatedWaveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate = widget.isPlaying || widget.isLoading;
    final wasAnimating = oldWidget.isPlaying || oldWidget.isLoading;
    if (shouldAnimate != wasAnimating ||
        widget.isLoading != oldWidget.isLoading) {
      if (shouldAnimate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryPurple;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticleFieldPainter(
              progress: _controller.value,
              speedFactor: widget._speedFactor,
              isPlaying: widget.isPlaying,
              isLoading: widget.isLoading,
              particleCount: widget.particleCount,
              color: color,
              height: widget.height,
            ),
          );
        },
      ),
    );
  }
}

class _ParticleFieldPainter extends CustomPainter {
  _ParticleFieldPainter({
    required this.progress,
    required this.speedFactor,
    required this.isPlaying,
    required this.isLoading,
    required this.particleCount,
    required this.color,
    required this.height,
  });

  final double progress;
  final double speedFactor;
  final bool isPlaying;
  final bool isLoading;
  final int particleCount;
  final Color color;
  final double height;

  double _hash(int i, double seed) =>
      ((i * 1.73 + seed * 31.7) * 43758.5453) % 1.0;

  double _wave(double t, int i, int harmonics, double baseFreq) {
    var v = 0.0;
    for (var h = 0; h < harmonics; h++) {
      final freq = baseFreq * (1.2 + _hash(i, h * 0.7));
      final amp = 0.4 / (h + 1) * (0.6 + _hash(i, h * 0.3 + 1));
      final phase = _hash(i, h * 0.5 + 2) * 2 * math.pi;
      v += amp * math.sin(t * 2 * math.pi * freq + phase);
    }
    return v;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.5;
    final spanX = size.width * 0.9;
    final centerX = size.width * 0.5;
    final effectiveProgress = (progress * speedFactor) % 1.0;

    for (var i = 0; i < particleCount; i++) {
      final phase = _hash(i, 0) * 2 * math.pi;
      final t = (effectiveProgress + _hash(i, 17) * 0.5) % 1.0;

      final xNorm = (i / (particleCount - 1).clamp(1, particleCount));
      final xDrift = _wave(effectiveProgress, i, 3, 0.8) * 0.12 * size.width;
      final x = centerX - spanX / 2 + xNorm * spanX + xDrift;

      double y;
      double radius;
      double alpha;

      if (isLoading) {
        final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi + phase);
        y = centerY;
        radius = 1.5 + 0.8 * pulse;
        alpha = 0.3 + 0.4 * pulse;
      } else if (isPlaying) {
        final yWave = _wave(t, i, 4, 1.0) * height * 0.45;
        y = centerY + yWave;
        final rWave = _wave(t, i, 2, 1.5);
        radius = 2.0 + 1.2 * (0.5 + 0.5 * rWave).clamp(0.0, 1.0);
        final aWave = _wave(t, i, 2, 2.0);
        alpha = 0.5 + 0.4 * (0.5 + 0.5 * aWave).clamp(0.0, 1.0);
      } else {
        y = centerY;
        radius = 1.5;
        alpha = 0.25;
      }

      final paint = Paint()
        ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius.clamp(1.0, 4.0), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticleFieldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.speedFactor != speedFactor ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.particleCount != particleCount ||
        oldDelegate.color != color ||
        oldDelegate.height != height;
  }
}
