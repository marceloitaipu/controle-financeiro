// lib/core/widgets/app_snack_bar.dart

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../errors/failure.dart';
import '../extensions/failure_extensions.dart';

/// Helper estático para exibir SnackBars padronizados.
///
/// Uso:
/// ```dart
/// AppSnackBar.success(context, 'Transação salva com sucesso!');
/// AppSnackBar.error(context, 'Erro ao salvar. Tente novamente.');
/// AppSnackBar.warning(context, 'Saldo insuficiente.');
/// AppSnackBar.info(context, 'Sincronizando dados...');
/// ```
abstract final class AppSnackBar {
  // ── Tipos ────────────────────────────────────────────────────────────────

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFB71C1C),
      foregroundColor: Colors.white,
      // Só exibe o botão de retry quando onAction é fornecido.
      actionLabel: onAction != null ? (actionLabel ?? 'Tentar novamente') : actionLabel,
      onAction: onAction,
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFE65100),
      foregroundColor: Colors.white,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF01579B),
      foregroundColor: Colors.white,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  // ── Implementação interna ────────────────────────────────────────────────

  /// Exibe snack de erro a partir de uma [Failure] da camada de domínio.
  ///
  /// [CancelledFailure] é silenciada — nada é exibido.
  /// Use [onRetry] para adicionar o botão "Tentar novamente".
  ///
  /// ```dart
  /// result.fold(
  ///   (failure) => AppSnackBar.fromFailure(context, failure),
  ///   (_) => AppSnackBar.success(context, 'Salvo!'),
  /// );
  /// ```
  static void fromFailure(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    if (failure.isSilent) return;
    error(
      context,
      failure.userMessage,
      onAction: onRetry,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration ?? AppConstants.snackBarDuration,
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: foregroundColor.withValues(alpha: 0.85),
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }
}
