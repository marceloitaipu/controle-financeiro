// lib/core/router/app_router.dart

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/accounts/domain/entities/account.dart';
import '../../features/accounts/presentation/pages/account_detail_page.dart';
import '../../features/accounts/presentation/pages/account_form_page.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/domain/entities/onboarding_status.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/categories/presentation/pages/category_form_page.dart';
import '../../features/credit_cards/domain/entities/credit_card.dart';
import '../../features/credit_cards/domain/entities/invoice.dart';
import '../../features/credit_cards/presentation/pages/credit_card_detail_page.dart';
import '../../features/credit_cards/presentation/pages/credit_card_form_page.dart';
import '../../features/credit_cards/presentation/pages/credit_cards_page.dart';
import '../../features/credit_cards/presentation/pages/invoice_page.dart';
import '../../features/goals/domain/entities/goal.dart';
import '../../features/goals/presentation/pages/goal_detail_page.dart';
import '../../features/goals/presentation/pages/goal_form_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/splash_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/export_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/security_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/transactions/presentation/pages/transaction_form_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../services/analytics_service.dart';
import '../utils/app_logger.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

/// Provider do GoRouter — instância única (keepAlive: true).
///
/// Usa [_RouterAuthNotifier] com [GoRouter.refreshListenable] para reagir
/// a mudanças de autenticação sem recriar o GoRouter. Isso preserva o
/// histórico de navegação e evita flashes visuais ao fazer login/logout.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authNotifier = _RouterAuthNotifier();

  // fireImmediately: true popula o estado inicial de forma síncrona,
  // antes do GoRouter avaliar o primeiro redirect.
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (_, next) => authNotifier.update(next),
    fireImmediately: true,
  );

  // Escuta mudanças no status de onboarding para re-avaliar redirect
  // (ex: quando completeOnboarding invalida o provider)
  ref.listen<AsyncValue<OnboardingStatus?>>(
    onboardingStatusProvider,
    (_, next) {
      final status = next.valueOrNull;
      authNotifier.updateOnboarding(status?.isCompleted);
    },
    fireImmediately: true,
  );

  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,

    // refreshListenable dispara re-avaliação do redirect sem recriar o router.
    refreshListenable: authNotifier,

    // Observer de log só ativo em modo debug.
    // FirebaseAnalyticsObserver ativo em produção.
    observers: [
      if (kDebugMode) _RouterObserver(),
      if (!kDebugMode) AnalyticsService.instance.observer,
    ],

    redirect: (context, state) => authNotifier.redirect(state),

    routes: [
      // ── Splash ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),

      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const ForgotPasswordPage(),
        ),
      ),

      // ── Onboarding ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const OnboardingPage(),
        ),
      ),

      // ── Home ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const HomePage(),
        ),
      ),

      // ── Accounts ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.accounts,
        name: AppRoutes.accountsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const AccountsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.accountNew,
        name: AppRoutes.accountNewName,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final account = extra is Account ? extra : null;
          return _slideTransition(
            state: state,
            child: AccountFormPage(account: account),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.accountDetail,
        name: AppRoutes.accountDetailName,
        pageBuilder: (context, state) {
          final accountId = state.pathParameters['accountId']!;
          final extra = state.extra;
          final account = extra is Account ? extra : null;
          return _slideTransition(
            state: state,
            child: AccountDetailPage(
              accountId: accountId,
              account: account,
            ),
          );
        },
      ),

      // ── Transactions ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.transactions,
        name: AppRoutes.transactionsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const TransactionsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionNew,
        name: AppRoutes.transactionNewName,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final tx = extra is Transaction ? extra : null;
          final typeParam = state.uri.queryParameters['type'];
          final type = tx?.type.name ?? typeParam;
          return _slideTransition(
            state: state,
            child: TransactionFormPage(
              transactionType: type,
              transaction: tx,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        name: AppRoutes.transactionDetailName,
        pageBuilder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          final extra = state.extra;
          final tx = extra is Transaction ? extra : null;
          return _slideTransition(
            state: state,
            child: TransactionDetailPage(
              transactionId: transactionId,
              transaction: tx,
            ),
          );
        },
      ),

      // ── Categories ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.categories,
        name: AppRoutes.categoriesName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const CategoriesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.categoryNew,
        name: AppRoutes.categoryNewName,
        pageBuilder: (context, state) {
          final extra = state.extra;
          // extra pode ser Category (editar) ou CategoryType (criar com tipo pré-definido)
          final category = extra is Category ? extra : null;
          final initialType =
              extra is CategoryType ? extra : null;
          return _slideTransition(
            state: state,
            child: CategoryFormPage(
              category: category,
              initialType: initialType,
            ),
          );
        },
      ),

      // ── Credit Cards ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.creditCards,
        name: AppRoutes.creditCardsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const CreditCardsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.creditCardNew,
        name: AppRoutes.creditCardNewName,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final card = extra is CreditCard ? extra : null;
          return _slideTransition(
            state: state,
            child: CreditCardFormPage(creditCard: card),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.creditCardDetail,
        name: AppRoutes.creditCardDetailName,
        pageBuilder: (context, state) {
          final cardId = state.pathParameters['cardId']!;
          final extra = state.extra;
          final card = extra is CreditCard ? extra : null;
          return _slideTransition(
            state: state,
            child: CreditCardDetailPage(cardId: cardId, creditCard: card),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoice,
        name: AppRoutes.invoiceName,
        pageBuilder: (context, state) {
          final cardId = state.pathParameters['cardId']!;
          final yearMonth = state.pathParameters['yearMonth']!;
          final extra = state.extra;
          final inv = extra is Invoice ? extra : null;
          return _slideTransition(
            state: state,
            child: InvoicePage(
              cardId: cardId,
              yearMonth: yearMonth,
              invoice: inv,
            ),
          );
        },
      ),

      // ── Goals ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.goals,
        name: AppRoutes.goalsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const GoalsPage(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: AppRoutes.goalNewName,
            pageBuilder: (context, state) {
              final extra = state.extra;
              return _slideTransition(
                state: state,
                child: GoalFormPage(
                  goal: extra is Goal ? extra : null,
                ),
              );
            },
          ),
          GoRoute(
            path: ':goalId',
            name: AppRoutes.goalDetailName,
            pageBuilder: (context, state) {
              final goalId = state.pathParameters['goalId']!;
              final extra = state.extra;
              return _slideTransition(
                state: state,
                child: GoalDetailPage(
                  goalId: goalId,
                  initialGoal: extra is Goal ? extra : null,
                ),
              );
            },
          ),
        ],
      ),

      // ── Budgets ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.budgets,
        name: AppRoutes.budgetsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const BudgetsPage(),
        ),
      ),

      // ── Reports ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.reports,
        name: AppRoutes.reportsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const ReportsPage(),
        ),
      ),

      // ── Insights ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.insights,
        name: AppRoutes.insightsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const InsightsPage(),
        ),
      ),

      // ── Settings ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const SettingsPage(),
        ),
      ),

      // ── Notifications ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const NotificationsPage(),
        ),
      ),
      // ── Profile ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const ProfilePage(),
        ),
      ),

      // ── Security ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.security,
        name: AppRoutes.securityName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const SecurityPage(),
        ),
      ),

      // ── Export ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.export,
        name: AppRoutes.exportName,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const ExportPage(),
        ),
      ),
    ],

    errorBuilder: (context, state) => _RouterErrorPage(
      location: state.uri.toString(),
    ),
  );
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────

/// [ChangeNotifier] interno que mantém o estado de autenticação e o status
/// de onboarding, servindo como [GoRouter.refreshListenable].
///
/// Ao receber novos estados via [update] ou [notifyListeners], o GoRouter
/// re-avalia o [redirect] sem recriar a instância.
class _RouterAuthNotifier extends ChangeNotifier {
  AsyncValue<AppUser?> _authState = const AsyncLoading();

  // Status do onboarding: null = ainda carregando, true = concluído
  bool? _onboardingCompleted;

  void update(AsyncValue<AppUser?> newState) {
    _authState = newState;
    // Ao fazer logout, resetar status de onboarding
    if (newState.valueOrNull == null && !newState.isLoading) {
      _onboardingCompleted = null;
    }
    notifyListeners();
  }

  void updateOnboarding(bool? completed) {
    _onboardingCompleted = completed;
    notifyListeners();
  }

  /// Lógica de redirecionamento chamada pelo GoRouter a cada navegação
  /// e sempre que [notifyListeners] é acionado.
  String? redirect(GoRouterState state) {
    final isAuthLoading = _authState.isLoading;
    final isAuthenticated = _authState.valueOrNull != null;
    final location = state.matchedLocation;
    final isOnAuthRoute = location.startsWith('/auth');
    final isOnSplash = location == AppRoutes.splash;
    final isOnOnboarding = location == AppRoutes.onboarding;

    // 1. Aguardando estado de auth → fica no splash
    if (isAuthLoading && isOnSplash) return null;

    // 2. Não autenticado fora do fluxo de auth → vai para login
    // (inclui a splash, pois auth já resolveu como null)
    if (!isAuthenticated && !isOnAuthRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated) {
      // 3. Autenticado numa rota de auth ou splash → decide destino
      if (isOnAuthRoute || isOnSplash) {
        // Onboarding ainda carregando: fica no splash para evitar flash
        if (_onboardingCompleted == null && isOnSplash) return null;
        // Onboarding não concluído → vai para onboarding
        if (_onboardingCompleted == false) return AppRoutes.onboarding;
        // Onboarding concluído (ou null fora do splash) → vai para home
        return AppRoutes.home;
      }

      // 4. Autenticado no onboarding mas já concluiu → vai para home
      if (isOnOnboarding && _onboardingCompleted == true) {
        return AppRoutes.home;
      }

      // 5. Autenticado em rota protegida mas onboarding não feito → onboarding
      if (!isOnOnboarding &&
          !isOnSplash &&
          _onboardingCompleted == false) {
        return AppRoutes.onboarding;
      }
    }

    return null;
  }
}

// ── Router Observer ───────────────────────────────────────────────────────────

/// Log de navegação em modo debug.
/// Auxilia no diagnóstico de fluxos de rota durante o desenvolvimento.
class _RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.debug('[Router] push → ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.debug('[Router] pop ← ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.debug('[Router] replace → ${newRoute?.settings.name}');
  }
}

// ── Error Page ────────────────────────────────────────────────────────────────

/// Página exibida quando o GoRouter não encontra uma rota registrada.
class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 72,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Página não encontrada',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers de transição ──────────────────────────────────────────────────────

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}
