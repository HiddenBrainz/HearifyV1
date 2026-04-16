import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Port of HearifyV1/Views/WaveformView.swift — visualizes an audio-levels
/// series as bars. Caps at 50 bars to match the Swift implementation.
class WaveformView extends StatelessWidget {
  const WaveformView({
    super.key,
    required this.audioLevels,
    this.color,
    this.maxBars = 50,
  });

  final List<double> audioLevels;
  final Color? color;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final resolved = color ?? AppTheme.primaryBlue(b);
    return LayoutBuilder(
      builder: (_, c) {
        final count = math.min(audioLevels.length, maxBars);
        if (count == 0) return const SizedBox.expand();
        final barWidth = math.max(2.0, c.maxWidth / count);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(count, (i) {
            final level = audioLevels[i];
            final h = math.max(4.0, level * c.maxHeight * 0.8);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: barWidth - 2,
                height: h,
                decoration: BoxDecoration(
                  color: resolved,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Compact inline version used in history rows.
class MiniWaveformView extends StatelessWidget {
  const MiniWaveformView({
    super.key,
    required this.audioLevels,
    required this.color,
  });

  final List<double> audioLevels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final count = math.min(audioLevels.length, 30);
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(count, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: Container(
              width: 2,
              height: audioLevels[i] * 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Helper to generate a plausible target-waveform shape from a target string
/// (matches the Swift `generateIdealWaveform(for:)` behavior).
List<double> generateIdealWaveform(String text) {
  final rand = math.Random();
  final syllables = text.split(' ').length + text.length ~/ 3;
  return List<double>.generate(50, (i) {
    final pos = i / 50.0;
    final phase =
        math.sin(pos * syllables * math.pi * 2) * 0.3;
    final baseline = 0.2;
    final variation = (rand.nextDouble() - 0.5) * 0.2;
    final level = baseline + phase + variation;
    return math.max(0.05, math.min(1.0, level));
  });
}
