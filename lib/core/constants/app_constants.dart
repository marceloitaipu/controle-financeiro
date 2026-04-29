// lib/core/constants/app_constants.dart

/// Constantes globais do aplicativo.
/// Nunca use strings literais espalhadas pelo código — centralize aqui.
abstract final class AppConstants {
  // ── Identidade do App ───────────────────────────────────────────────────
  static const String appName = 'Controle Financeiro';
  static const String appVersion = '1.0.0';

  // ── Locale ──────────────────────────────────────────────────────────────
  static const String defaultLocale = 'pt_BR';
  static const String defaultCurrency = 'BRL';
  static const String defaultCurrencySymbol = 'R\$';

  // ── Paginação ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Armazenamento local (chaves SharedPreferences) ──────────────────────
  static const String kThemeModeKey = 'theme_mode';
  static const String kOnboardingDoneKey = 'onboarding_done';
  static const String kSelectedAccountIdKey = 'selected_account_id';

  // ── Preferências de notificação ───────────────────────────────────────────
  static const String kNotifDailyReminder = 'notif_daily_reminder';
  static const String kNotifDailyHour = 'notif_daily_hour';
  static const String kNotifDailyMinute = 'notif_daily_minute';
  static const String kNotifBudgetAlerts = 'notif_budget_alerts';
  static const String kNotifGoalReminders = 'notif_goal_reminders';
  static const String kNotifWeeklyReport = 'notif_weekly_report';

  // ── Preferência de moeda ────────────────────────────────────────────────
  static const String kCurrencyKey = 'currency';

  // ── Firebase Storage paths ───────────────────────────────────────────────
  static const String storageAvatarsPath = 'avatars';
  static const String storageAttachmentsPath = 'attachments';

  // ── Limites de negócio ──────────────────────────────────────────────────
  static const int maxAttachmentsPerTransaction = 5;
  static const double maxTransactionAmountBRL = 9999999.99;
  static const int maxCategoryNameLength = 40;
  static const int maxGoalNameLength = 60;
  static const int maxNotesLength = 500;

  // ── Durations ────────────────────────────────────────────────────────────
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
}
