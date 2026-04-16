import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Port of HearifyV1/Models/CommonModels.swift `BackgroundNoiseType`.
enum BackgroundNoiseType {
  none('None'),
  cafe('Café'),
  traffic('Traffic'),
  crowd('Crowd'),
  office('Office'),
  nature('Nature');

  const BackgroundNoiseType(this.displayName);
  final String displayName;
}

/// Port of HearifyV1/Models/CommonModels.swift `DifficultyLevel`.
enum DifficultyLevel {
  easy('Easy', 0.8, 'Slower speed (0.8×) — best for beginners'),
  medium('Medium', 1.0, 'Normal speed (1.0×) — standard practice'),
  hard('Hard', 1.3, 'Faster speed (1.3×) — advanced challenge');

  const DifficultyLevel(this.displayName, this.playbackSpeed, this.description);
  final String displayName;
  final double playbackSpeed;
  final String description;

  Color color(Brightness b) => switch (this) {
        DifficultyLevel.easy => AppTheme.success(b),
        DifficultyLevel.medium => AppTheme.warning(b),
        DifficultyLevel.hard => AppTheme.error(b),
      };
}
