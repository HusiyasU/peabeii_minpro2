import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── DARK COLORS ────────────────────────────────────────────────────────────
  static const _darkBg      = Color(0xff080c14);
  static const _darkSurface = Color(0xff0e1520);
  static const _darkCard    = Color(0xff131d2e);
  static const _darkBorder  = Color(0xff1e2d42);
  static const neon         = Color(0xff00e5ff);
  static const accent       = Color(0xffff3c5f);
  static const gold         = Color(0xffffc840);
  static const _darkTextPri = Color(0xfff0f4ff);
  static const _darkTextSec = Color(0xff6b7e9a);

  // ─── LIGHT COLORS ───────────────────────────────────────────────────────────
  static const _lightBg      = Color(0xfff0f4ff);
  static const _lightSurface = Color(0xffffffff);
  static const _lightCard    = Color(0xffffffff);
  static const _lightBorder  = Color(0xffe2e8f0);
  static const _lightTextPri = Color(0xff0f172a);
  static const _lightTextSec = Color(0xff64748b);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      colorScheme: const ColorScheme.dark(
        primary:   neon,
        secondary: accent,
        surface:   _darkSurface,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme().apply(
        bodyColor:    _darkTextPri,
        displayColor: _darkTextPri,
      ),
      extensions: const [AppColors.dark],
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      colorScheme: const ColorScheme.light(
        primary:   Color(0xff0099bb),
        secondary: accent,
        surface:   _lightSurface,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme().apply(
        bodyColor:    _lightTextPri,
        displayColor: _lightTextPri,
      ),
      extensions: const [AppColors.light],
    );
  }
}

// ─── THEME EXTENSION ──────────────────────────────────────────────────────────
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPri;
  final Color textSec;
  final Color neon;
  final Color accent;
  final Color gold;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPri,
    required this.textSec,
    required this.neon,
    required this.accent,
    required this.gold,
  });

  static const dark = AppColors(
    bg:      Color(0xff080c14),
    surface: Color(0xff0e1520),
    card:    Color(0xff131d2e),
    border:  Color(0xff1e2d42),
    textPri: Color(0xfff0f4ff),
    textSec: Color(0xff6b7e9a),
    neon:    Color(0xff00e5ff),
    accent:  Color(0xffff3c5f),
    gold:    Color(0xffffc840),
  );

  static const light = AppColors(
    bg:      Color(0xfff0f4ff),
    surface: Color(0xffffffff),
    card:    Color(0xffffffff),
    border:  Color(0xffe2e8f0),
    textPri: Color(0xff0f172a),
    textSec: Color(0xff64748b),
    neon:    Color(0xff0099bb),
    accent:  Color(0xffff3c5f),
    gold:    Color(0xfff59e0b),
  );

  @override
  AppColors copyWith({
    Color? bg, Color? surface, Color? card, Color? border,
    Color? textPri, Color? textSec, Color? neon, Color? accent, Color? gold,
  }) {
    return AppColors(
      bg:      bg      ?? this.bg,
      surface: surface ?? this.surface,
      card:    card    ?? this.card,
      border:  border  ?? this.border,
      textPri: textPri ?? this.textPri,
      textSec: textSec ?? this.textSec,
      neon:    neon    ?? this.neon,
      accent:  accent  ?? this.accent,
      gold:    gold    ?? this.gold,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg:      Color.lerp(bg,      other.bg,      t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card:    Color.lerp(card,    other.card,    t)!,
      border:  Color.lerp(border,  other.border,  t)!,
      textPri: Color.lerp(textPri, other.textPri, t)!,
      textSec: Color.lerp(textSec, other.textSec, t)!,
      neon:    Color.lerp(neon,    other.neon,    t)!,
      accent:  Color.lerp(accent,  other.accent,  t)!,
      gold:    Color.lerp(gold,    other.gold,    t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
