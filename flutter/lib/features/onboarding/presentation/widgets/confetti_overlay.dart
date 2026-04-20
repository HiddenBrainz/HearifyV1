import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/auth_design_system.dart';

/// Full-screen celebratory particle layer. Paints ~40 colored shapes
/// falling from the top with rotation, horizontal drift, and a fade at
/// the tail. Sits under `IgnorePointer` so it never intercepts taps.
///
/// Colors are sampled from the brand palette so the burst reads as
/// on-theme — the blue / indigo / purple / magenta from the auth CTA
/// gradient plus the orange + success green from `AppTheme`.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 40,
  });

  final Duration duration;
  final int particleCount;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _particles = List.generate(widget.particleCount, (_) => _makeParticle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _Particle _makeParticle() {
    return _Particle(
      startX: _rand.nextDouble(),
      drift: (_rand.nextDouble() - 0.5) * 0.3,
      size: 6 + _rand.nextDouble() * 6,
      rotationVel: (_rand.nextDouble() - 0.5) * 8 * math.pi,
      initialRotation: _rand.nextDouble() * 2 * math.pi,
      startDelay: _rand.nextDouble() * 0.45,
      fallDuration: 0.55 + _rand.nextDouble() * 0.4,
      isSquare: _rand.nextBool(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final palette = <Color>[
      AppTheme.primaryBlue(b),
      AppColors.gradientIndigo,
      AppTheme.accentPurple(b),
      AppColors.gradientMagenta,
      AppTheme.accentOrange(b),
      AppTheme.success(b),
    ];
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
              palette: palette,
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.startX,
    required this.drift,
    required this.size,
    required this.rotationVel,
    required this.initialRotation,
    required this.startDelay,
    required this.fallDuration,
    required this.isSquare,
  });

  final double startX; // 0..1, fraction of width
  final double drift; // horizontal movement fraction over lifetime
  final double size; // diameter / side length in px
  final double rotationVel; // radians per lifetime
  final double initialRotation;
  final double startDelay; // 0..1, delay before particle starts falling
  final double fallDuration; // 0..1, length of fall relative to overall anim
  final bool isSquare;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.palette,
  });

  final List<_Particle> particles;
  final double progress;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final local = _localProgress(p);
      if (local <= 0) continue;
      final eased = Curves.easeInOutCubic.transform(local.clamp(0.0, 1.0));
      final x = (p.startX + p.drift * local) * size.width;
      // Start just above the top edge, end just below the bottom.
      final y = -p.size + (size.height + 2 * p.size) * eased;
      final rotation = p.initialRotation + p.rotationVel * local;

      // Fade in the last 15% of the particle's life.
      final fade = local > 0.85 ? 1 - ((local - 0.85) / 0.15) : 1.0;
      final color = palette[i % palette.length]
          .withValues(alpha: fade.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      final paint = Paint()..color = color;
      if (p.isSquare) {
        final half = p.size / 2;
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(-half, -half, p.size, p.size),
          Radius.circular(p.size * 0.18),
        );
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  double _localProgress(_Particle p) {
    if (progress <= p.startDelay) return 0;
    final t = (progress - p.startDelay) / p.fallDuration;
    return t.clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress || old.particles != particles;
}
