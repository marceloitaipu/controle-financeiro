// lib/features/accounts/presentation/pages/account_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_list_tile.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import '../widgets/account_card.dart';

/// Tela de detalhe de uma conta financeira.
///
/// Exibe informações da conta e o extrato (últimas transações).
/// Suporta edição e exclusão.
class AccountDetailPage extends ConsumerWidget {
  const AccountDetailPage({
    super.key,
    required this.accountId,
    this.account,
  });

  final String accountId;
  final Account? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (account != null) {
      return _DetailContent(account: account!);
    }

    final accountAsync = ref.watch(accountByIdProvider(accountId));
    return accountAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Conta')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Conta')),
        body: Center(
          child: Text(
            'Erro ao carregar conta.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      data: (acc) {
        if (acc == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Conta')),
            body: const Center(child: Text('Conta não encontrada.')),
          );
        }
        return _DetailContent(account: acc);
      },
    );
  }
}

// ── Conteúdo principal ────────────────────────────────────────────────────────

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.account});
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Excluir conta',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Card da conta ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: AccountCard(account: account),
            ),
          ),

          // ── Informações ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl2,
                AppSpacing.lg,
                0,
              ),
              child: _InfoGrid(account: account),
            ),
          ),

          // ── Botão editar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                0,
              ),
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed(
                  AppRoutes.accountNewName,
                  extra: account,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar conta'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
          ),

          // ── Divider + header do extrato ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl2,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'EXTRATO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Divider(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Lista de transações ──────────────────────────────────────────
          _AccountTransactionsList(accountId: account.id),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          AppRoutes.transactionNewName,
          queryParameters: {'accountId': account.id},
        ),
        tooltip: 'Nova transação',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final colorScheme = Theme.of(context).colorScheme;

    // Aviso quando conta tem saldo não-zero
    final hasBalance = account.balance != 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja excluir esta conta?'),
            if (hasBalance) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Esta conta possui saldo de '
                        '${CurrencyFormatter.format(account.balance.abs())}.',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccount(account.id);

      if (success && context.mounted) {
        context.pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir conta.')),
        );
      }
    }
  }
}

// ── Grid de informações ───────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.account});
  final Account account;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final balanceColor = account.balance >= 0
        ? AppColors.income
        : AppColors.expense;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Tipo',
            value: account.type.label,
          ),
          _InfoRow(
            icon: Icons.account_balance_outlined,
            label: 'Banco',
            value: account.bankName ?? '—',
          ),
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Saldo atual',
            value: CurrencyFormatter.format(account.balance),
            valueColor: balanceColor,
          ),
          _InfoRow(
            icon: Icons.visibility_outlined,
            label: 'Incluído no total',
            value: account.includeInTotal ? 'Sim' : 'Não',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

// ── Lista de transações da conta ──────────────────────────────────────────────

class _AccountTransactionsList extends ConsumerWidget {
  const _AccountTransactionsList({required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync =
        ref.watch(watchAccountTransactionsProvider(accountId));
    final colorScheme = Theme.of(context).colorScheme;

    return transactionsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Erro ao carregar transações.',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Nenhuma transação nesta conta.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Agrupa por dia
        final groups = <DateTime, List<Transaction>>{};
        for (final tx in transactions) {
          final day =
              DateTime(tx.date.year, tx.date.month, tx.date.day);
          groups.putIfAbsent(day, () => []).add(tx);
        }
        final sortedDays = groups.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(0, 0, 0, 100),
          sliver: SliverList.builder(
            itemCount: sortedDays.length,
            itemBuilder: (_, idx) {
              final day = sortedDays[idx];
              final dayTx = groups[day]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      _formatDay(day),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...dayTx.map(
                    (tx) => TransactionListTile(
                      transaction: tx,
                      showDate: false,
                      onTap: () => context.push(
                        AppRoutes.transactionDetailPath(tx.id),
                        extra: tx,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'HOJE';
    if (d == yesterday) return 'ONTEM';
    return DateFormatter.fullDate(date).toUpperCase();
  }
}
