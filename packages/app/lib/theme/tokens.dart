import 'package:flutter/material.dart';

// ─── Palette constants (used by both token sets) ─────────────────────────────

const _sage       = Color(0xFFC5E1C8); // Paper I / concept card fill
const _amber      = Color(0xFFF5E472); // Paper II / example card fill
const _sky        = Color(0xFFAEDCF0); // Paper III / recap card fill
const _lavender   = Color(0xFFD4C5F0); // Paper IV card fill
const _coral      = Color(0xFFF5C4A8); // Paper V card fill (overflow)
const _lemon      = Color(0xFFF0F5A8); // Paper VI card fill (overflow)
const _ink        = Color(0xFF1A1A1A); // Pill nav bg / dark inset boxes / intro cards
const _sageAccent = Color(0xFF6BA87A); // Sage green accent (darker for text on light)

/// Ordered paper palette — index by (paperIndex % paperPalette.length)
const List<Color> paperPalette = [_sage, _amber, _sky, _lavender, _coral, _lemon];

// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Bento / editorial palette ─────────────────────────────────────────────
  final Color ink;      // Dark-fill element bg (nav bar, dark cards, inset boxes)
  final Color onInk;    // Text on ink bg
  final Color sage;     // Paper I / concept card fill
  final Color amber;    // Paper II / example card fill
  final Color sky;      // Paper III / recap card fill
  final Color lavender; // Paper IV card fill

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
    required this.ink,
    required this.onInk,
    required this.sage,
    required this.amber,
    required this.sky,
    required this.lavender,
  });

  // ── Dark (legacy — kept for tests) ───────────────────────────────────────
  static const dark = AppTokens(
    bgBase:        Color(0xFF15171C),
    bgSurface:     Color(0xFF1E222A),
    bgRaised:      Color(0xFF242933),
    textPrimary:   Color(0xFFE9E7E2),
    textSecondary: Color(0xFF9CA0A8),
    textTertiary:  Color(0xFF6B6F78),
    border:        Color(0xFF2A2E37),
    borderStrong:  Color(0xFF3A404B),
    accent:        Color(0xFF62C6A8),
    accentSoft:    Color(0x1F62C6A8),
    onAccent:      Color(0xFF0E1714),
    danger:        Color(0xFFC97A6D),
    warning:       Color(0xFFD8A24A),
    ink:           _ink,
    onInk:         Color(0xFFFFFFFF),
    sage:          _sage,
    amber:         _amber,
    sky:           _sky,
    lavender:      _lavender,
  );

  // ── Light (new default) ──────────────────────────────────────────────────
  static const light = AppTokens(
    bgBase:        Color(0xFFF7F6F2),
    bgSurface:     Color(0xFFFFFFFF),
    bgRaised:      Color(0xFFFFFFFF),
    textPrimary:   Color(0xFF1A1A1A),
    textSecondary: Color(0xFF5C5C5C),
    textTertiary:  Color(0xFF9A9A9A),
    border:        Color(0xFFE8E6E1),
    borderStrong:  Color(0xFFD0CEC8),
    accent:        _sageAccent,
    accentSoft:    Color(0x286BA87A),
    onAccent:      Color(0xFFFFFFFF),
    danger:        Color(0xFFB94040),
    warning:       Color(0xFFB88A10),
    ink:           _ink,
    onInk:         Color(0xFFFFFFFF),
    sage:          _sage,
    amber:         _amber,
    sky:           _sky,
    lavender:      _lavender,
  );

  @override
  AppTokens copyWith({
    Color? bgBase, Color? bgSurface, Color? bgRaised,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? border, Color? borderStrong,
    Color? accent, Color? accentSoft, Color? onAccent,
    Color? danger, Color? warning,
    Color? ink, Color? onInk,
    Color? sage, Color? amber, Color? sky, Color? lavender,
  }) => AppTokens(
    bgBase:        bgBase        ?? this.bgBase,
    bgSurface:     bgSurface     ?? this.bgSurface,
    bgRaised:      bgRaised      ?? this.bgRaised,
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary:  textTertiary  ?? this.textTertiary,
    border:        border        ?? this.border,
    borderStrong:  borderStrong  ?? this.borderStrong,
    accent:        accent        ?? this.accent,
    accentSoft:    accentSoft    ?? this.accentSoft,
    onAccent:      onAccent      ?? this.onAccent,
    danger:        danger        ?? this.danger,
    warning:       warning       ?? this.warning,
    ink:           ink           ?? this.ink,
    onInk:         onInk         ?? this.onInk,
    sage:          sage          ?? this.sage,
    amber:         amber         ?? this.amber,
    sky:           sky           ?? this.sky,
    lavender:      lavender      ?? this.lavender,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      bgBase:        Color.lerp(bgBase, other.bgBase, t)!,
      bgSurface:     Color.lerp(bgSurface, other.bgSurface, t)!,
      bgRaised:      Color.lerp(bgRaised, other.bgRaised, t)!,
      textPrimary:   Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary:  Color.lerp(textTertiary, other.textTertiary, t)!,
      border:        Color.lerp(border, other.border, t)!,
      borderStrong:  Color.lerp(borderStrong, other.borderStrong, t)!,
      accent:        Color.lerp(accent, other.accent, t)!,
      accentSoft:    Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent:      Color.lerp(onAccent, other.onAccent, t)!,
      danger:        Color.lerp(danger, other.danger, t)!,
      warning:       Color.lerp(warning, other.warning, t)!,
      ink:           Color.lerp(ink, other.ink, t)!,
      onInk:         Color.lerp(onInk, other.onInk, t)!,
      sage:          Color.lerp(sage, other.sage, t)!,
      amber:         Color.lerp(amber, other.amber, t)!,
      sky:           Color.lerp(sky, other.sky, t)!,
      lavender:      Color.lerp(lavender, other.lavender, t)!,
    );
  }
}

// ─── Context extension ────────────────────────────────────────────────────────

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

// ─── Editorial typography scale ───────────────────────────────────────────────

class AppTypography {
  static const String _f = 'Inter';

  /// 32px — hero greeting, stats numbers
  static TextStyle hero(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 32, fontWeight: FontWeight.w800,
        height: 1.1, color: t.textPrimary, letterSpacing: -0.5);

  /// 24px — screen headings ("All Topics", "Today's 5 minutes")
  static TextStyle display(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 24, fontWeight: FontWeight.w700,
        height: 1.2, color: t.textPrimary, letterSpacing: -0.3);

  /// 18px — card titles, paper names
  static TextStyle title(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 18, fontWeight: FontWeight.w700,
        height: 1.3, color: t.textPrimary);

  /// 15px — module names, section headings
  static TextStyle heading(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w600,
        height: 1.35, color: t.textPrimary);

  /// 14px — body text
  static TextStyle body(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w400,
        height: 1.6, color: t.textPrimary);

  /// 13px — secondary body
  static TextStyle bodySm(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 13, fontWeight: FontWeight.w400,
        height: 1.55, color: t.textSecondary);

  /// 12px — captions, meta
  static TextStyle caption(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 12, fontWeight: FontWeight.w400,
        height: 1.5, color: t.textTertiary);

  /// 11px — micro labels, nav labels
  static TextStyle micro(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 11, fontWeight: FontWeight.w500,
        height: 1.4, color: t.textTertiary);

  /// 10px — pill labels (CONCEPT, RECAP, etc.)
  static TextStyle pill(AppTokens t) => TextStyle(
        fontFamily: _f, fontSize: 10, fontWeight: FontWeight.w700,
        height: 1.2, letterSpacing: 0.8, color: t.textPrimary);
}

// ─── Theme builder ────────────────────────────────────────────────────────────

ThemeData buildTheme(AppTokens t) {
  final brightness = t.bgBase.computeLuminance() > 0.5
      ? Brightness.light
      : Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: t.bgBase,
    extensions: [t],
    textTheme: TextTheme(
      displayLarge:   AppTypography.display(t),
      titleLarge:     AppTypography.title(t),
      titleMedium:    AppTypography.heading(t),
      bodyLarge:      AppTypography.body(t),
      bodyMedium:     AppTypography.bodySm(t),
      bodySmall:      AppTypography.caption(t),
      labelSmall:     AppTypography.micro(t),
    ),
    // Keep snackbars and dialogs on-theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.ink,
      contentTextStyle: AppTypography.body(t).copyWith(color: t.onInk),
    ),
  );
}
