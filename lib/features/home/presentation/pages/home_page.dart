// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_scheduler_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/accounts_carousel.dart';
import '../widgets/balance_card.dart';
import '../widgets/month_selector.dart';
import '../widgets/month_summary_card.dart';
import '../widgets/monthly_chart.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_transactions_list.dart';
import '../../../../shared/widgets/section_header.dart';

/// Página principal do app — Dashboard com dados reais do Firestore.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.valueOrNull;
    final firstName = currentUser?.displayName?.split(' ').first ?? 'você';

    // Ativa o agendador de notificações (keepAlive) ao abrir o app
    ref.watch(notificationSchedulerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            Text(
              firstName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        titleSpacing: AppSpacing.lg,
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificações',
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: const _DashboardBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.transactionNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Transação'),
        elevation: 4,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Transações',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cartões',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Orçamentos',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              context.push(AppRoutes.transactions);
            case 2:
              context.push(AppRoutes.creditCards);
            case 3:
              context.push(AppRoutes.goals);
            case 4:
              context.push(AppRoutes.budgets);
          }
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }
}

// ── Corpo do dashboard ────────────────────────────────────────────────────────

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthNotifierProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(selectedMonthNotifierProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // ── Saldo total ──────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: BalanceCard(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Atalhos rápidos ───────────────────────────────────────────────
          const QuickActionsRow(),

          const SizedBox(height: AppSpacing.xl),

          // ── Contas ────────────────────────────────────────────────────────
          SectionHeader(
            title: 'CONTAS',
            actionLabel: 'Ver todas',
            onAction: () => context.push(AppRoutes.accounts),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
          ),
          const AccountsCarousel(),

          const SizedBox(height: AppSpacing.xl),

          // ── Seletor de mês + resumo ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: MonthSelector(),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: MonthSummaryCard(month: selectedMonth),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Gráfico mensal ────────────────────────────────────────────────
          const SectionHeader(
            title: 'EVOLUÇÃO MENSAL',
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
          ),
          const MonthlyBarChart(),

          const SizedBox(height: AppSpacing.xl),

          // ── Últimas transações ────────────────────────────────────────────
          SectionHeader(
            title: 'ÚLTIMAS TRANSAÇÕES',
            actionLabel: 'Ver todas',
            onAction: () => context.push(AppRoutes.transactions),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
          ),
          const RecentTransactionsList(),
        ],
      ),
    );
  }
}