// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Temas Material 3 do aplicativo — claro e escuro.
abstract final class AppTheme {
  // ── ColorScheme ───────────────────────────────────────────────────────────
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.dark,
  );

  // ── TextTheme ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return GoogleFonts.interTextTheme(
      ThemeData(colorScheme: colorScheme).textTheme,
    );
  }

  // ── Componentes compartilhados ────────────────────────────────────────────
  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: GoogleFonts.inter(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );

  static CardThemeData _cardTheme(ColorScheme cs) => CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        color: cs.surface,
        margin: EdgeInsets.zero,
      );

  static InputDecorationTheme _inputTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      );

  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: cs.outline),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static BottomNavigationBarThemeData _bottomNavTheme(ColorScheme cs) =>
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        backgroundColor: cs.surface,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      );

  static NavigationBarThemeData _navBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: cs.onSurfaceVariant,
          );
        }),
      );

  static ChipThemeData _chipTheme(ColorScheme cs) => ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: cs.outlineVariant),
      );

  static SnackBarThemeData _snackBarTheme(ColorScheme cs) => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: cs.inverseSurface,
        contentTextStyle: GoogleFonts.inter(
          color: cs.onInverseSurface,
          fontSize: 14,
        ),
      );

  static DialogThemeData _dialogTheme(ColorScheme cs) => DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 6,
      );

  // ── Tema Claro ────────────────────────────────────────────────────────────
  static ThemeData get light {
    final cs = _lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _buildTextTheme(cs),
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(cs),
      inputDecorationTheme: _inputTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      bottomNavigationBarTheme: _bottomNavTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      chipTheme: _chipTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      dialogTheme: _dialogTheme(cs),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        space: 1,
      ),
      scaffoldBackgroundColor: cs.surfaceContainerLowest,
    );
  }

  // ── Tema Escuro ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    final cs = _darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _buildTextTheme(cs),
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(cs),
      inputDecorationTheme: _inputTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      bottomNavigationBarTheme: _bottomNavTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      chipTheme: _chipTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      dialogTheme: _dialogTheme(cs),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        space: 1,
      ),
      scaffoldBackgroundColor: cs.surfaceContainerLowest,
    );
  }
}
