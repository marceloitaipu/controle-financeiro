// lib/features/home/presentation/widgets/balance_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../providers/dashboard_provider.dart';

/// Card principal do dashboard exibindo o saldo total consolidado.
/// Suporta ocultação do saldo com animação de toggle.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(watchAccountsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final isVisible = ref.watch(balanceVisibilityNotifierProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.seed,
            AppColors.seed.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.seed.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo total',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => ref
                    .read(balanceVisibilityNotifierProvider.notifier)
                    .toggle(),
                child: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          accountsAsync.when(
            loading: () => _buildShimmerBalance(),
            error: (_, __) => _buildErrorBalance(),
            data: (_) => _buildBalance(totalBalance, isVisible),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildAccountCount(accountsAsync),
        ],
      ),
    );
  }

  Widget _buildBalance(int totalBalance, bool isVisible) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isVisible
          ? Text(
              CurrencyFormatter.format(totalBalance),
              key: const ValueKey('visible'),
              style: AppTextStyles.currencyLarge.copyWith(
                color: Colors.white,
              ),
            )
          : Text(
              '•••••',
              key: const ValueKey('hidden'),
              style: AppTextStyles.currencyLarge.copyWith(
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
    );
  }

  Widget _buildShimmerBalance() {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white54,
      child: Container(
        height: 42,
        width: 160,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.chipRadius,
        ),
      ),
    );
  }

  Widget _buildErrorBalance() {
    return const Text(
      'Erro ao carregar',
      style: TextStyle(color: Colors.white70, fontSize: 16),
    );
  }

  Widget _buildAccountCount(AsyncValue<dynamic> accountsAsync) {
    return accountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (accounts) {
        final count = (accounts as List).length;
        return Text(
          count == 0
              ? 'Nenhuma conta cadastrada'
              : '$count ${count == 1 ? 'conta' : 'contas'}',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        );
      },
    );
  }
}
