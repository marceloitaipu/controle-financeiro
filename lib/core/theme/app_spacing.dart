// lib/core/theme/app_spacing.dart

import 'package:flutter/material.dart';

/// Tokens de espaçamento baseados em uma escala de 4pt.
///
/// Use sempre essas constantes em vez de valores literais.
/// Garante consistência visual em todo o app.
///
/// Escala: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64
abstract final class AppSpacing {
  /// 4pt — espaçamento mínimo entre elementos relacionados
  static const double xs = 4;

  /// 8pt — espaçamento interno de chips, badges
  static const double sm = 8;

  /// 12pt — padding compacto de cards
  static const double md = 12;

  /// 16pt — padding padrão de conteúdo
  static const double lg = 16;

  /// 20pt — gap entre seções próximas
  static const double xl = 20;

  /// 24pt — padding de cards principais
  static const double xl2 = 24;

  /// 32pt — separação entre seções
  static const double xl3 = 32;

  /// 40pt — espaçamento de itens de lista grandes
  static const double xl4 = 40;

  /// 48pt — margem de telas
  static const double xl5 = 48;

  /// 64pt — espaçamento de hero sections
  static const double xl6 = 64;

  // ── EdgeInsets prontos ────────────────────────────────────────────────────

  /// Padding padrão de página: horizontal 16, vertical 16
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);

  /// Padding horizontal de página: left/right 16
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: lg);

  /// Padding de card padrão: all 16
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Padding de card compacto: all 12
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  /// Padding de card generoso: all 24
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xl2);

  /// Padding de item de lista: vertical 12, horizontal 16
  static const EdgeInsets listItem =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  /// Padding de seção: top 24, bottom 8
  static const EdgeInsets sectionPadding =
      EdgeInsets.only(top: xl2, bottom: sm);

  // ── SizedBox atalhos ───────────────────────────────────────────────────────
  static const Widget hXs = SizedBox(width: xs);
  static const Widget hSm = SizedBox(width: sm);
  static const Widget hMd = SizedBox(width: md);
  static const Widget hLg = SizedBox(width: lg);
  static const Widget hXl = SizedBox(width: xl);
  static const Widget hXl2 = SizedBox(width: xl2);
  static const Widget hXl3 = SizedBox(width: xl3);

  static const Widget vXs = SizedBox(height: xs);
  static const Widget vSm = SizedBox(height: sm);
  static const Widget vMd = SizedBox(height: md);
  static const Widget vLg = SizedBox(height: lg);
  static const Widget vXl = SizedBox(height: xl);
  static const Widget vXl2 = SizedBox(height: xl2);
  static const Widget vXl3 = SizedBox(height: xl3);
  static const Widget vXl4 = SizedBox(height: xl4);
  static const Widget vXl5 = SizedBox(height: xl5);
}
