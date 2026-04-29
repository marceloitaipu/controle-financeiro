// lib/core/theme/app_shadows.dart

import 'package:flutter/material.dart';

/// Tokens de sombra (BoxShadow) do design system.
///
/// Nomeados semanticamente (none, sm, md, lg, colored).
/// Use em vez de definir BoxShadow diretamente nos widgets.
abstract final class AppShadows {
  /// Sem sombra — para cards elevados via border apenas.
  static const List<BoxShadow> none = [];

  /// Sombra sutil — cards de lista, items hover.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra padrão — cards de destaque, FAB.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Sombra forte — modais, bottom sheets, menus.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  /// Sombra para cards de saldo — efeito premium.
  static const List<BoxShadow> balanceCard = [
    BoxShadow(
      color: Color(0x331565C0), // seed color com 20% opacidade
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Retorna uma sombra colorida para cards de categoria/conta.
  static List<BoxShadow> colored(Color color, {double opacity = 0.25}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
