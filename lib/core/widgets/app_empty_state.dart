// lib/core/widgets/app_empty_state.dart

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Widget de estado vazio — exibido quando uma lista não tem itens.
///
/// Variantes:
/// - [AppEmptyState] — tela cheia com ícone grande e CTA opcional
/// - [AppEmptyState.compact] — versão menor para uso em cards/seções
///
/// Uso:
/// ```dart
/// AppEmptyState(
///   icon: AppIcons.transactions,
///   title: 'Nenhuma transação',
///   description: 'Adicione sua primeira transação.',
///   actionLabel: 'Adicionar',
///   onAction: () => context.push(AppRoutes.transactionNew),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Se true, renderiza versão compacta (para dentro de seções/cards).
  final bool compact;

  /// Construtor factory para uso compacto.
  const factory AppEmptyState.compact({
    Key? key,
    required IconData icon,
    required String title,
    String? description,
  }) = _CompactEmptyState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (compact) {
      return _buildCompact(context, colorScheme);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                size: 44,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            AppSpacing.vXl2,
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              AppSpacing.vSm,
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vXl2,
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl2,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant),
          AppSpacing.vSm,
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            AppSpacing.vXs,
            Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Implementação interna para o factory `AppEmptyState.compact`.
class _CompactEmptyState extends AppEmptyState {
  const _CompactEmptyState({
    super.key,
    required super.icon,
    required super.title,
    super.description,
  }) : super(compact: true);
}
