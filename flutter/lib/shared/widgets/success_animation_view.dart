import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Port of HearifyV1/Views/SuccessAnimationView.swift.
/// Shown when a user clears a high-accuracy threshold — glow, scale-in icon,
/// particle burst, and score readout.
class SuccessAnimationView extends StatefulWidget {
  const SuccessAnimationView({super.key, required this.score});

  /// 0.0 to 1.0.
  final double score;

  @override
  State<SuccessAnimationView> createState() => _SuccessAnimationViewState();
}

class _SuccessAnimationViewState extends State<SuccessAnimationView>
    with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _particles;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _particles = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    _particles.dispose();
    super.dispose();
  }

  (Color, IconData, String) _styleFor(Brightness b) {
    final s = widget.score;
    if (s >= 0.9) {
      return (AppTheme.success(b), Icons.star, 'Excellent!');
    }
    if (s >= 0.75) {
      return (AppTheme.primaryBlue(b), Icons.thumb_up, 'Great job!');
    }
    return (AppTheme.accentOrange(b), Icons.emoji_events, 'Nice work!');
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final (color, icon, msg) = _styleFor(b);

    return AnimatedBuilder(
      animation: Listenable.merge([_in, _particles]),
      builder: (_, __) {
        final scale = Curves.easeOutBack.transform(_in.value);
        final rot = (1 - _in.value) * 0.2;
        final particleOpacity = 1 - _particles.value;

        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Particle burst
              ...List.generate(12, (i) {
                final angle = (i / 12) * 2 * math.pi;
                final dist = 80 * _particles.value;
                return Transform.translate(
                  offset:
                      Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                  child: Opacity(
                    opacity: particleOpacity,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: [
                          AppTheme.success(b),
                          AppTheme.primaryBlue(b),
                          AppTheme.accentOrange(b),
                          AppTheme.accentPurple(b),
                        ][i % 4],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
              // Glow
              Transform.scale(
                scale: scale * 1.5,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      color.withValues(alpha: 0.6),
                      color.withValues(alpha: 0),
                    ]),
                  ),
                ),
              ),
              // Main circle
              Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rot,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    Text(msg,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                    Text('${(widget.score * 100).round()}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: color,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
