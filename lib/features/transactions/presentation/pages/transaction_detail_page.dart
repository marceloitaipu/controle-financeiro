// lib/features/transactions/presentation/pages/transaction_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../attachments/presentation/pages/attachment_viewer_page.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// Tela de detalhe de uma transação.
///
/// [transaction] pode ser fornecido diretamente (via `extra` do router) ou
/// carregado pelo [transactionByIdProvider] (deep link / recarregamento).
class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({
    super.key,
    required this.transactionId,
    this.transaction,
  });

  final String transactionId;
  final Transaction? transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa a transação passada diretamente, ou busca pelo ID
    if (transaction != null) {
      return _DetailContent(transaction: transaction!);
    }

    final txAsync = ref.watch(transactionByIdProvider(transactionId));
    return txAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detalhe')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Detalhe')),
        body: Center(
          child: Text(
            'Erro ao carregar transação.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhe')),
            body: const Center(child: Text('Transação não encontrada.')),
          );
        }
        return _DetailContent(transaction: tx);
      },
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final tx = transaction;

    final typeColor = switch (tx.type) {
      TransactionType.income => AppColors.income,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };

    final typeLabel = switch (tx.type) {
      TransactionType.income => 'Receita',
      TransactionType.expense => 'Despesa',
      TransactionType.transfer => 'Transferência',
    };

    final statusLabel = switch (tx.status) {
      TransactionStatus.completed => 'Pago',
      TransactionStatus.pending => 'Pendente',
      TransactionStatus.cancelled => 'Cancelado',
    };

    final statusColor = switch (tx.status) {
      TransactionStatus.completed => AppColors.success,
      TransactionStatus.pending => AppColors.warning,
      TransactionStatus.cancelled => colorScheme.onSurfaceVariant,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe'),
        actions: [
          // Botão de excluir
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Excluir',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        children: [
          // ── Header: valor + tipo ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl2),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: typeColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  CurrencyFormatter.format(tx.amount),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  tx.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl2),

          // ── Informações ───────────────────────────────────────────────────
          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Data',
            value: DateFormatter.shortDate(tx.date),
          ),
          _InfoTile(
            icon: Icons.circle_outlined,
            label: 'Status',
            value: statusLabel,
            valueColor: statusColor,
          ),
          _AccountTile(
            accountId: tx.accountId,
            label: tx.type == TransactionType.transfer
                ? 'Conta origem'
                : 'Conta',
          ),
          if (tx.destinationAccountId != null)
            _AccountTile(
              accountId: tx.destinationAccountId!,
              label: 'Conta destino',
            ),
          if (tx.categoryId != null)
            _CategoryTile(categoryId: tx.categoryId!),
          if (tx.recurrence != RecurrenceType.none)
            _InfoTile(
              icon: Icons.repeat,
              label: 'Recorrência',
              value: _recurrenceLabel(tx.recurrence),
            ),
          if (tx.notes != null && tx.notes!.isNotEmpty)
            _InfoTile(
              icon: Icons.notes_outlined,
              label: 'Notas',
              value: tx.notes!,
            ),
          _InfoTile(
            icon: Icons.access_time_outlined,
            label: 'Criado em',
            value: DateFormatter.relativeWithTime(tx.createdAt),
          ),

          const SizedBox(height: AppSpacing.xl3),

          // ── Comprovantes ──────────────────────────────────────────────────
          if (tx.attachmentUrls.isNotEmpty) ...[        
            _AttachmentSection(urls: tx.attachmentUrls),
            const SizedBox(height: AppSpacing.xl3),
          ],

          // ── Botão Editar ──────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: () => context.pushNamed(
              AppRoutes.transactionNewName,
              extra: tx,
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar transação'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  String _recurrenceLabel(RecurrenceType r) => switch (r) {
        RecurrenceType.none => 'Sem recorrência',
        RecurrenceType.daily => 'Diária',
        RecurrenceType.weekly => 'Semanal',
        RecurrenceType.monthly => 'Mensal',
        RecurrenceType.yearly => 'Anual',
      };

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text(
          'Esta ação é irreversível. O saldo da conta será ajustado automaticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(transaction);

      if (success && context.mounted) {
        context.pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir transação.')),
        );
      }
    }
  }
}

// ── Aux tiles ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.accountId, required this.label});
  final String accountId;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(watchAccountsProvider);
    final account = accountsAsync.valueOrNull
        ?.where((a) => a.id == accountId)
        .firstOrNull;

    return _InfoTile(
      icon: Icons.account_balance_wallet_outlined,
      label: label,
      value: account?.name ?? '—',
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(watchCategoriesProvider(CategoryType.expense));
    final income = ref.watch(watchCategoriesProvider(CategoryType.income));

    final all = [
      ...?expense.valueOrNull,
      ...?income.valueOrNull,
    ];
    final cat = all.where((c) => c.id == categoryId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            cat?.icon ?? Icons.category_outlined,
            size: 20,
            color: cat?.color ??
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                cat?.name ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Seção de comprovantes ─────────────────────────────────────────────────────

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection({required this.urls});

  final List<String> urls;

  static bool _isImage(String url) {
    final ext = url.toLowerCase().split('.').last.split('?').first;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  static String _nameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final raw = Uri.decodeComponent(uri.pathSegments.last);
      return raw.replaceFirst(RegExp(r'^\d+_'), '');
    } catch (_) {
      return 'anexo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file_rounded,
                size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'COMPROVANTES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            itemBuilder: (context, index) {
              final url = urls[index];
              final name = _nameFromUrl(url);
              final isImg = _isImage(url);

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttachmentViewerPage(
                        url: url,
                        fileName: name,
                      ),
                    ),
                  ),
                  borderRadius: AppRadius.cardRadius,
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.cardRadius,
                      border:
                          Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.cardRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isImg)
                            Expanded(
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image_outlined,
                                  size: 24,
                                ),
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : const Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2),
                                            ),
                                          ),
                              ),
                            )
                          else
                            Icon(
                              _fileIcon(name),
                              size: 28,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs),
                            child: Text(
                              name,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.toLowerCase().split('.').last;
    return switch (ext) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'doc' || 'docx' => Icons.description_outlined,
      'xls' || 'xlsx' => Icons.table_chart_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}

