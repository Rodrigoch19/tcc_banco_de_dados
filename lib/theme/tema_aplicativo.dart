// Cores e estilos visuais usados em todo o aplicativo.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system "Obsidian": dark mode profundo, vidro fosco e neon.
class AppColors {
  static const background = Color(0xFF07090F);
  static const surface = Color(0xFF0D1119);
  static const foreground = Color(0xFFEAEEF7);
  static const muted = Color(0xFF8A93A6);
  static const primary = Color(0xFF3B82F6);
  static const critical = Color(0xFFEF4444);
  static const medium = Color(0xFFF59E0B);
  static const safe = Color(0xFF10B981);
  static const glass = Color(0x14FFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.foreground,
        error: AppColors.critical,
      ),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
    );
  }

  /// Sombra neon usada em marcadores e botoes de acao.
  static List<BoxShadow> glow(Color color,
          {double blur = 24, double opacity = 0.45}) =>
      [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: blur,
          spreadRadius: 1,
        ),
      ];
}
