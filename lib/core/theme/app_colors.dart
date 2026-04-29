// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Paleta de cores do aplicativo.
/// Baseada no Material 3 Color System com seed personalizado.
abstract final class AppColors {
  // ── Seed / Brand ──────────────────────────────────────────────────────────
  static const Color seed = Color(0xFF1565C0); // Azul financeiro

  // ── Receitas e Despesas ───────────────────────────────────────────────────
  static const Color income = Color(0xFF2E7D32);       // Verde escuro
  static const Color incomeLight = Color(0xFFA5D6A7);  // Verde claro
  static const Color expense = Color(0xFFC62828);      // Vermelho escuro
  static const Color expenseLight = Color(0xFFEF9A9A); // Vermelho claro
  static const Color transfer = Color(0xFF1565C0);     // Azul

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1);
  static const Color danger = Color(0xFFD32F2F);

  // ── Gráficos (paleta sequencial para charts) ──────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFFF57C00),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFAD1457),
    Color(0xFF37474F),
    Color(0xFF4E342E),
  ];

  // ── Categorias padrão (ícones/cores) ──────────────────────────────────────
  static const Color categoryFood = Color(0xFFFF7043);
  static const Color categoryTransport = Color(0xFF42A5F5);
  static const Color categoryHealth = Color(0xFFEC407A);
  static const Color categoryLeisure = Color(0xFFAB47BC);
  static const Color categoryEducation = Color(0xFF26A69A);
  static const Color categoryHousing = Color(0xFF8D6E63);
  static const Color categoryShopping = Color(0xFFFFCA28);
  static const Color categoryInvestments = Color(0xFF66BB6A);
  static const Color categorySalary = Color(0xFF26C6DA);
  static const Color categoryOther = Color(0xFF78909C);
}
