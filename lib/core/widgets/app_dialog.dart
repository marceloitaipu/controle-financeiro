// lib/core/widgets/app_dialog.dart

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Helper estático para exibir Dialogs padronizados.
///
/// Uso:
/// ```dart
/// final confirmed = await AppDialog.confirm(
///   context,
///   title: 'Excluir conta',
///   message: 'Esta ação não pode ser desfeita.',
///   confirmLabel: 'Excluir',
///   isDestructive: true,
/// );
/// if (confirmed == true) { ... }
/// ```
abstract final class AppDialog {
  // ── Confirmação ─────────────────────────────────────────────────────────

  /// Dialog de confirmação com botão de ação e cancelar.
  /// Retorna `true` se confirmado, `false` ou `null` se cancelado.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  // ── Alerta (apenas fechar) ───────────────────────────────────────────────

  /// Dialog informativo com um único botão "Fechar".
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String closeLabel = 'Fechar',
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _AppAlertDialog(
        title: title,
        message: message,
        closeLabel: closeLabel,
        icon: icon,
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Dialog não-dismissível de carregamento.
  /// Feche com [Navigator.of(context).pop()].
  static Future<T?> loading<T>(
    BuildContext context, {
    String message = 'Aguarde...',
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(strokeWidth: 3),
                AppSpacing.hXl2,
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Implementações privadas ────────────────────────────────────────────────────

class _AppConfirmDialog extends StatelessWidget {
  const _AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              size: 32,
              color: isDestructive ? colorScheme.error : colorScheme.primary,
            )
          : null,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        isDestructive
            ? FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: Text(confirmLabel),
              )
            : FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
      ],
    );
  }
}

class _AppAlertDialog extends StatelessWidget {
  const _AppAlertDialog({
    required this.title,
    required this.message,
    required this.closeLabel,
    this.icon,
  });

  final String title;
  final String message;
  final String closeLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: icon != null
          ? Icon(icon, size: 32, color: colorScheme.primary)
          : null,
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(closeLabel),
        ),
      ],
    );
  }
}
