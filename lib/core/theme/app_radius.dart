// lib/core/theme/app_radius.dart

import 'package:flutter/material.dart';

/// Tokens de BorderRadius do design system.
///
/// Baseados no Material 3 shape system com valores semânticos nomeados.
/// Use sempre esses tokens para garantir consistência visual.
abstract final class AppRadius {
  /// 4pt — chips compactos, badges
  static const double xs = 4;

  /// 8pt — botões pequenos, inputs compactos
  static const double sm = 8;

  /// 12pt — inputs de formulário, campos de texto
  static const double md = 12;

  /// 16pt — cards, containers padrão
  static const double lg = 16;

  /// 20pt — cards destacados, modais
  static const double xl = 20;

  /// 24pt — bottom sheets, dialogs
  static const double xl2 = 24;

  /// 32pt — avatares, ícones circulares grandes
  static const double xl3 = 32;

  /// Completamente circular (ex: FAB, avatar)
  static const double full = 999;

  // ── BorderRadius prontos ──────────────────────────────────────────────────

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl2),
  );
  static const BorderRadius avatarRadius =
      BorderRadius.all(Radius.circular(xl3));
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(md));
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius fullRadius =
      BorderRadius.all(Radius.circular(full));
}
