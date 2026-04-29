// lib/core/widgets/app_error_widget.dart

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Widget de estado de erro reutilizável com opção de retry.
///
/// Variantes:
/// - Padrão — tela cheia com ícone grande e botão de retry
/// - [compact] — inline com ícone pequeno, usado em listas/cards
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.message = 'Ocorreu um erro inesperado.',
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;

  /// Se true, renderiza versão inline compacta (ícone + texto na mesma linha).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 16),
          AppSpacing.hSm,
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ),
          if (onRetry != null) ...[
            AppSpacing.hSm,
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.refresh, color: colorScheme.primary, size: 16),
              ),
            ),
          ],
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: colorScheme.error,
            ),
            AppSpacing.vLg,
            Text(
              'Algo deu errado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.vSm,
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.vXl2,
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
