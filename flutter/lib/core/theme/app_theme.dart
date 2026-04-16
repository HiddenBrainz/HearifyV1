import 'package:flutter/material.dart';

/// Port of HearifyV1/Theme/AppTheme.swift.
/// Semantic colors adaptive to light/dark mode; spacing + radius tokens match
/// the Swift source so ported screens retain identical proportions.
class AppTheme {
  AppTheme._();

  // ── Primary
  static const primaryBlueLight = Color.fromRGBO(26, 102, 204, 1);
  static const primaryBlueDark = Color.fromRGBO(77, 153, 255, 1);
  static const primaryCyanLight = Color.fromRGBO(51, 179, 230, 1);
  static const primaryCyanDark = Color.fromRGBO(102, 204, 255, 1);

  // ── Accent
  static const accentOrangeLight = Color.fromRGBO(255, 153, 51, 1);
  static const accentOrangeDark = Color.fromRGBO(255, 179, 77, 1);
  static const accentPurpleLight = Color.fromRGBO(153, 77, 230, 1);
  static const accentPurpleDark = Color.fromRGBO(179, 128, 255, 1);

  // ── Semantic
  static const successLight = Color.fromRGBO(51, 204, 102, 1);
  static const successDark = Color.fromRGBO(77, 230, 128, 1);
  static const warningLight = Color.fromRGBO(255, 179, 0, 1);
  static const warningDark = Color.fromRGBO(255, 204, 51, 1);
  static const errorLight = Color.fromRGBO(230, 77, 77, 1);
  static const errorDark = Color.fromRGBO(255, 102, 102, 1);
  static const infoLight = Color.fromRGBO(77, 153, 255, 1);
  static const infoDark = Color.fromRGBO(102, 179, 255, 1);

  // ── Backgrounds
  static const backgroundPrimaryLight = Color.fromRGBO(240, 240, 245, 1);
  static const backgroundPrimaryDark = Color.fromRGBO(0, 0, 0, 1);
  static const backgroundSecondaryLight = Color.fromRGBO(245, 245, 250, 1);
  static const backgroundSecondaryDark = Color.fromRGBO(26, 26, 26, 1);
  static const cardBackgroundLight = Colors.white;
  static const cardBackgroundDark = Color.fromRGBO(38, 38, 38, 1);

  // ── Text
  static const textPrimaryLight = Color.fromRGBO(38, 38, 51, 1);
  static const textPrimaryDark = Color.fromRGBO(242, 242, 255, 1);
  static const textSecondaryLight = Color.fromRGBO(128, 128, 153, 1);
  static const textSecondaryDark = Color.fromRGBO(179, 179, 191, 1);
  static const textTertiaryLight = Color.fromRGBO(179, 179, 191, 1);
  static const textTertiaryDark = Color.fromRGBO(128, 128, 140, 1);

  // ── Radius tokens
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;

  // ── Spacing tokens
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // ── Gradients
  static LinearGradient primaryGradient(Brightness b) => LinearGradient(
        colors: [primaryBlue(b), primaryCyan(b)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient accentGradient(Brightness b) => LinearGradient(
        colors: [accentOrange(b), const Color.fromRGBO(255, 102, 153, 1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ── Resolvers
  static Color primaryBlue(Brightness b) =>
      b == Brightness.dark ? primaryBlueDark : primaryBlueLight;
  static Color primaryCyan(Brightness b) =>
      b == Brightness.dark ? primaryCyanDark : primaryCyanLight;
  static Color accentOrange(Brightness b) =>
      b == Brightness.dark ? accentOrangeDark : accentOrangeLight;
  static Color accentPurple(Brightness b) =>
      b == Brightness.dark ? accentPurpleDark : accentPurpleLight;
  static Color success(Brightness b) =>
      b == Brightness.dark ? successDark : successLight;
  static Color warning(Brightness b) =>
      b == Brightness.dark ? warningDark : warningLight;
  static Color error(Brightness b) =>
      b == Brightness.dark ? errorDark : errorLight;
  static Color info(Brightness b) =>
      b == Brightness.dark ? infoDark : infoLight;
  static Color backgroundPrimary(Brightness b) =>
      b == Brightness.dark ? backgroundPrimaryDark : backgroundPrimaryLight;
  static Color backgroundSecondary(Brightness b) =>
      b == Brightness.dark ? backgroundSecondaryDark : backgroundSecondaryLight;
  static Color cardBackground(Brightness b) =>
      b == Brightness.dark ? cardBackgroundDark : cardBackgroundLight;
  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(Brightness b) =>
      b == Brightness.dark ? textTertiaryDark : textTertiaryLight;

  static ThemeData light() => _buildTheme(Brightness.light);
  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryBlue(b),
      brightness: b,
      primary: primaryBlue(b),
      secondary: primaryCyan(b),
      tertiary: accentOrange(b),
      error: error(b),
      surface: cardBackground(b),
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundPrimary(b),
      cardTheme: CardThemeData(
        color: cardBackground(b),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      textTheme: ThemeData(brightness: b).textTheme.apply(
            bodyColor: textPrimary(b),
            displayColor: textPrimary(b),
          ),
    );
  }
}

extension AppThemeContext on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
}
