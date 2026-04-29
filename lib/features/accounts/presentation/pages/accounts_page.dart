// lib/features/accounts/presentation/pages/accounts_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import '../widgets/account_card.dart';

/// Tela de listagem de contas financeiras.
///
/// Exibe o saldo total consolidado, lista de contas com cards coloridos,
/// e botão para criar nova conta.
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(watchAccountsProvider);
    final totalBal = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nova conta',
            onPressed: () => context.pushNamed(AppRoutes.accountNewName),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => _buildShimmer(),
        error: (_, __) => AppErrorWidget(
          message: 'Erro ao carregar contas.',
          onRetry: () => ref.invalidate(watchAccountsProvider),
        ),
        data: (accounts) => accounts.isEmpty
            ? _buildEmpty(context)
            : _buildList(context, accounts, totalBal),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.accountNewName),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova conta'),
      ),
    );
  }

  // ── Lista com saldo total ─────────────────────────────────────────────────

  Widget _buildList(
    BuildContext context,
    List<Account> accounts,
    int totalBal,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        // ── Card de saldo total ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.seed,
                    AppColors.seed.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patrimônio líquido',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CurrencyFormatter.format(totalBal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${accounts.where((a) => a.includeInTotal).length} '
                    'de ${accounts.length} contas incluídas',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Header da seção ────────────────────────────────────────────────
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
                  'SUAS CONTAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${accounts.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Lista de contas ────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            100,
          ),
          sliver: SliverList.separated(
            itemCount: accounts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, index) {
              final account = accounts[index];
              return AccountCard(
                account: account,
                onTap: () => context.pushNamed(
                  AppRoutes.accountDetailName,
                  pathParameters: {'accountId': account.id},
                  extra: account,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Estado vazio ─────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Nenhuma conta cadastrada',
      description:
          'Adicione sua primeira conta para começar a controlar suas finanças.',
      actionLabel: 'Adicionar conta',
      onAction: () => context.pushNamed(AppRoutes.accountNewName),
    );
  }

  // ── Shimmer de carregamento ───────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 128,
          decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: AppRadius.cardRadius,
          ),
        ),
      ),
    );
  }
}
