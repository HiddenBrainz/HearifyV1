import 'package:flutter/material.dart';

/// Design system for the Hearify premium dark auth surfaces.
///
/// Exposes a small, deliberate set of tokens — colors, gradients, type,
/// spacing, radii, shadows — so every auth widget pulls from the same
/// palette instead of scattering raw values. The tokens intentionally
/// favor an iOS-inspired, health-tech aesthetic: deep navy base,
/// elevated dark surfaces, a neon blue→indigo→purple→magenta accent,
/// and muted grays for everything that isn't an action.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────
  static const Color bgPrimary = Color(0xFF020A1A);
  static const Color bgSecondary = Color(0xFF030E22);
  static const Color bgBottomFade = Color(0xFF12001F);

  // ── Surfaces ─────────────────────────────────────────────────────
  static const Color authCardBase = Color(0xFF07070B);
  static const Color authCardTop = Color(0xFF0B0B0F);
  static const Color inputBackground = Color(0xFF1B1C23);
  static const Color segmentTrack = Color(0xFF18191F);
  static const Color segmentSelected = Color(0xFF66666E);

  // ── Borders / subtle separators ──────────────────────────────────
  static const Color hairline = Color(0x14FFFFFF);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textInactive = Color(0xFFB8B8C2);
  static const Color textPlaceholder = Color(0xFF6F6F78);
  static const Color linkBlue = Color(0xFF149CFF);

  // ── Logo circle backdrop ─────────────────────────────────────────
  static const Color logoCircleCore = Color(0xFF1A2348);
  static const Color logoCircleEdge = Color(0xFF241739);

  // ── Accent gradient stops ────────────────────────────────────────
  static const Color gradientBlue = Color(0xFF2D9CDB);
  static const Color gradientIndigo = Color(0xFF5B5FEF);
  static const Color gradientViolet = Color(0xFF6C5CE7);
  static const Color gradientPurple = Color(0xFFA855F7);
  static const Color gradientMagenta = Color(0xFFB517D2);

  // ── Semantic ─────────────────────────────────────────────────────
  static const Color errorText = Color(0xFFFF6B6B);
}

/// Reusable gradients. Exposed as factory getters so each use gets a
/// fresh instance and Flutter won't try to share gradient shader caches
/// across very differently-shaped rects.
class AppGradients {
  AppGradients._();

  /// Wide horizontal neon accent — used for the primary CTA.
  static const LinearGradient primaryCta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.gradientBlue,
      AppColors.gradientIndigo,
      AppColors.gradientPurple,
      AppColors.gradientMagenta,
    ],
    stops: [0.0, 0.38, 0.72, 1.0],
  );

  /// Subtle vertical blend for the scaffold; prevents the background
  /// from looking like flat black and hints at the brand palette.
  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.bgPrimary,
      AppColors.bgSecondary,
      AppColors.bgPrimary,
      AppColors.bgBottomFade,
    ],
    stops: [0.0, 0.35, 0.75, 1.0],
  );

  /// The auth card is very close to black but has a soft vertical
  /// inflection so it reads as an elevated surface, not a hole.
  static const LinearGradient authCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.authCardTop, AppColors.authCardBase],
  );

  /// Soft indigo→violet glow behind the logo mark.
  static const RadialGradient logoCircle = RadialGradient(
    center: Alignment(-0.15, -0.2),
    radius: 0.95,
    colors: [AppColors.logoCircleCore, AppColors.logoCircleEdge],
  );

  /// Gradient used to paint the logo glyph itself.
  static const LinearGradient logoMark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientIndigo,
      AppColors.gradientPurple,
      AppColors.gradientMagenta,
    ],
  );
}

class AppRadii {
  AppRadii._();

  static const double pill = 999;
  static const double input = 14;
  static const double button = 18;
  static const double authCard = 28;
  static const double segment = 22;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> authCard = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 24),
      blurRadius: 48,
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> ctaButton = [
    BoxShadow(
      color: Color(0x4D5B5FEF),
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -6,
    ),
  ];

  static const List<BoxShadow> logoCircle = [
    BoxShadow(
      color: Color(0x665B5FEF),
      offset: Offset(0, 18),
      blurRadius: 40,
      spreadRadius: -10,
    ),
  ];
}

class AppTextStyles {
  AppTextStyles._();

  /// Single canonical font used by every text style here. Mirrored in
  /// `AppTheme.fontFamily`; every weight referenced below (w400 → w800)
  /// is declared in `pubspec.yaml` so Flutter's font resolver picks the
  /// right glyph variant at render time.
  static const String _font = 'Inter';

  static const TextStyle title = TextStyle(
    fontFamily: _font,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.1,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: _font,
    fontSize: 19,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textInactive,
    letterSpacing: 0.1,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle placeholder = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPlaceholder,
  );

  /// Matches the brand-blue example placeholder seen in the mock.
  static const TextStyle emailPlaceholder = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.linkBlue,
  );

  static const TextStyle ctaLabel = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle segmentLabelActive = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle segmentLabelInactive = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textInactive,
  );

  static const TextStyle helperLink = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.linkBlue,
    letterSpacing: 0.1,
  );

  static const TextStyle error = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.errorText,
  );
}
