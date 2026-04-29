// lib/core/router/app_routes.dart

/// Centraliza todos os nomes e paths de rota do aplicativo.
/// Use sempre essas constantes — nunca strings literais.
abstract final class AppRoutes {
  // ── Splash ────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String splashName = 'splash';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String loginName = 'login';

  static const String register = '/auth/register';
  static const String registerName = 'register';

  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordName = 'forgot-password';

  // ── Onboarding (compatibilidade futura) ────────────────────────────────────
  /// Rota reservada para o fluxo de onboarding pós-cadastro.
  /// Ativar no router quando a ETAPA de Onboarding for implementada.
  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  // ── Home (shell) ──────────────────────────────────────────────────────────
  static const String home = '/home';
  static const String homeName = 'home';

  // ── Accounts ──────────────────────────────────────────────────────────────
  static const String accounts = '/accounts';
  static const String accountsName = 'accounts';

  static const String accountNew = '/accounts/new';
  static const String accountNewName = 'account-new';

  static const String accountDetail = '/accounts/:accountId';
  static const String accountDetailName = 'account-detail';

  // ── Transactions ──────────────────────────────────────────────────────────
  static const String transactions = '/transactions';
  static const String transactionsName = 'transactions';

  static const String transactionNew = '/transactions/new';
  static const String transactionNewName = 'transaction-new';

  static const String transactionDetail = '/transactions/:transactionId';
  static const String transactionDetailName = 'transaction-detail';

  // ── Categories ────────────────────────────────────────────────────────────
  static const String categories = '/categories';
  static const String categoriesName = 'categories';

  static const String categoryNew = '/categories/new';
  static const String categoryNewName = 'category-new';

  // ── Credit Cards ──────────────────────────────────────────────────────────
  static const String creditCards = '/credit-cards';
  static const String creditCardsName = 'credit-cards';

  static const String creditCardNew = '/credit-cards/new';
  static const String creditCardNewName = 'credit-card-new';

  static const String creditCardDetail = '/credit-cards/:cardId';
  static const String creditCardDetailName = 'credit-card-detail';

  static const String invoice = '/credit-cards/:cardId/invoices/:yearMonth';
  static const String invoiceName = 'invoice';

  // ── Goals ─────────────────────────────────────────────────────────────────
  static const String goals = '/goals';
  static const String goalsName = 'goals';

  static const String goalNew = '/goals/new';
  static const String goalNewName = 'goal-new';

  static const String goalDetail = '/goals/:goalId';
  static const String goalDetailName = 'goal-detail';

  // ── Budgets ───────────────────────────────────────────────────────────────
  static const String budgets = '/budgets';
  static const String budgetsName = 'budgets';

  // ── Reports ───────────────────────────────────────────────────────────────
  static const String reports = '/reports';
  static const String reportsName = 'reports';

  // ── Insights ─────────────────────────────────────────────────────────────
  static const String insights = '/insights';
  static const String insightsName = 'insights';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const String settings = '/settings';
  static const String settingsName = 'settings';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsName = 'notifications';

  // ── Profile ──────────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String profileName = 'profile';

  // ── Security ─────────────────────────────────────────────────────────────
  static const String security = '/security';
  static const String securityName = 'security';

  // ── Export ────────────────────────────────────────────────────────────────
  static const String export = '/export';
  static const String exportName = 'export';

  // ── Helpers para paths com parâmetros ─────────────────────────────────────
  static String accountDetailPath(String accountId) =>
      '/accounts/$accountId';

  static String transactionDetailPath(String transactionId) =>
      '/transactions/$transactionId';

  static String creditCardDetailPath(String cardId) =>
      '/credit-cards/$cardId';

  static String invoicePath(String cardId, String yearMonth) =>
      '/credit-cards/$cardId/invoices/$yearMonth';

  static String goalDetailPath(String goalId) =>
      '/goals/$goalId';
}
