import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color bgBase;
  final Color bgSurface;
  final Color bgRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderStrong;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color danger;
  final Color warning;

  const AppTokens({
    required this.bgBase,
    required this.bgSurface,
    required this.bgRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.danger,
    required this.warning,
  });

  static const dark = AppTokens(
    bgBase: Color(0xFF15171C),
    bgSurface: Color(0xFF1E222A),
    bgRaised: Color(0xFF242933),
    textPrimary: Color(0xFFE9E7E2),
    textSecondary: Color(0xFF9CA0A8),
    textTertiary: Color(0xFF6B6F78),
    border: Color(0xFF2A2E37),
    borderStrong: Color(0xFF3A404B),
    accent: Color(0xFF62C6A8),
    accentSoft: Color(0x1F62C6A8), // ~12% opacity
    onAccent: Color(0xFF0E1714),
    danger: Color(0xFFC97A6D),
    warning: Color(0xFFD8A24A),
  );

  static const light = AppTokens(
    bgBase: Color(0xFFF7F6F2),
    bgSurface: Color(0xFFFFFFFF),
    bgRaised: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF20242B),
    textSecondary: Color(0xFF5C636E),
    textTertiary: Color(0xFF8A909A),
    border: Color(0xFFE4E2DB),
    borderStrong: Color(0xFFD2CFC6),
    accent: Color(0xFF178A66),
    accentSoft: Color(0x1A178A66), // ~10% opacity
    onAccent: Color(0xFFFFFFFF),
    danger: Color(0xFFB4513F),
    warning: Color(0xFFD8A24A),
  );

  @override
  AppTokens copyWith({
    Color? bgBase,
    Color? bgSurface,
    Color? bgRaised,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? accent,
    Color? accentSoft,
    Color? onAccent,
    Color? danger,
    Color? warning,
  }) =>
      AppTokens(
        bgBase: bgBase ?? this.bgBase,
        bgSurface: bgSurface ?? this.bgSurface,
        bgRaised: bgRaised ?? this.bgRaised,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        border: border ?? this.border,
        borderStrong: borderStrong ?? this.borderStrong,
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        onAccent: onAccent ?? this.onAccent,
        danger: danger ?? this.danger,
        warning: warning ?? this.warning,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

/// Helper extension to grab tokens quickly from BuildContext
extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Calm typography mapping
class AppTypography {
  static const String _fontFamily = 'Inter';

  static TextStyle display(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: t.textPrimary,
      );

  static TextStyle title(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: t.textPrimary,
      );

  static TextStyle heading(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: t.textPrimary,
      );

  static TextStyle body(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: t.textPrimary,
      );

  static TextStyle bodySm(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: t.textSecondary,
      );

  static TextStyle caption(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: t.textTertiary,
      );

  static TextStyle micro(AppTokens t) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: t.textTertiary,
      );
}

ThemeData buildTheme(AppTokens t) {
  final baseTextTheme = ThemeData.dark().textTheme;
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: t.bgBase,
    extensions: [t],
    textTheme: TextTheme(
      displayLarge: AppTypography.display(t),
      titleLarge: AppTypography.title(t),
      titleMedium: AppTypography.heading(t),
      bodyLarge: AppTypography.body(t),
      bodyMedium: AppTypography.bodySm(t),
      bodySmall: AppTypography.caption(t),
      labelSmall: AppTypography.micro(t),
    ),
  );
}
