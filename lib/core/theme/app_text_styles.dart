// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estilos de texto reutilizáveis que complementam o TextTheme do Material 3.
/// Use esses estilos para casos específicos não cobertos pelo tema.
abstract final class AppTextStyles {
  // ── Família base ─────────────────────────────────────────────────────────
  static TextStyle get _base => GoogleFonts.inter();

  // ── Valores monetários ────────────────────────────────────────────────────
  static TextStyle get currencyLarge => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get currencyMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );

  static TextStyle get currencySmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // ── Labels de categoria / chip ────────────────────────────────────────────
  static TextStyle get categoryLabel => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // ── Rótulos de seção ──────────────────────────────────────────────────────
  static TextStyle get sectionTitle => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  // ── Percentuais de progresso ──────────────────────────────────────────────
  static TextStyle get percentLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      );

  // ── Data compacta ─────────────────────────────────────────────────────────
  static TextStyle get dateCompact => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  // ── Número de cartão / dígitos ────────────────────────────────────────────
  static TextStyle get cardNumber => GoogleFonts.robotoMono(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      );
}
