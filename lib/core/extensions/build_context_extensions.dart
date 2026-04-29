// lib/core/extensions/build_context_extensions.dart

import 'package:flutter/material.dart';

/// Atalhos de [BuildContext] para reduzir verbosidade no código de UI.
///
/// Uso:
/// ```dart
/// // Antes:
/// Theme.of(context).colorScheme.primary
/// MediaQuery.of(context).size.width
///
/// // Depois:
/// context.colorScheme.primary
/// context.screenWidth
/// ```
extension BuildContextExtensions on BuildContext {
  // ── Theme ─────────────────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isLightMode => !isDarkMode;

  // ── MediaQuery ────────────────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Tela pequena (< 600pt, celulares)
  bool get isSmallScreen => screenWidth < 600;

  /// Tela média (600–900pt, tablets)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;

  /// Tela grande (>= 900pt, desktops)
  bool get isLargeScreen => screenWidth >= 900;

  // ── Scaffold ─────────────────────────────────────────────────────────────

  ScaffoldMessengerState get messenger => ScaffoldMessenger.of(this);

  void hideCurrentSnackBar() => ScaffoldMessenger.of(this).hideCurrentSnackBar();

  // ── FocusScope ────────────────────────────────────────────────────────────

  void unfocus() => FocusScope.of(this).unfocus();
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);
}
