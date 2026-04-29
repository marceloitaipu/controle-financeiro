// lib/features/notifications/presentation/providers/notification_preferences_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/shared_preferences_provider.dart';
import '../../domain/entities/notification_preferences.dart';

part 'notification_preferences_provider.g.dart';

/// Gerenciador das preferências de notificação do usuário.
///
/// Persiste cada preferência em [SharedPreferences] de forma imediata.
/// O agendamento/cancelamento dos alertas é delegado ao
/// [notificationSchedulerProvider], que reage automaticamente às mudanças
/// de estado deste notifier.
@Riverpod(keepAlive: true)
class NotificationPreferencesNotifier
    extends _$NotificationPreferencesNotifier {
  @override
  NotificationPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationPreferences(
      dailyReminder:
          prefs.getBool(AppConstants.kNotifDailyReminder) ?? true,
      dailyReminderHour:
          prefs.getInt(AppConstants.kNotifDailyHour) ?? 20,
      dailyReminderMinute:
          prefs.getInt(AppConstants.kNotifDailyMinute) ?? 0,
      budgetAlerts:
          prefs.getBool(AppConstants.kNotifBudgetAlerts) ?? true,
      goalReminders:
          prefs.getBool(AppConstants.kNotifGoalReminders) ?? true,
      weeklyReport:
          prefs.getBool(AppConstants.kNotifWeeklyReport) ?? false,
    );
  }

  // ── Lembrete diário ────────────────────────────────────────────────────────

  Future<void> setDailyReminder(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.kNotifDailyReminder, enabled);
    state = state.copyWith(dailyReminder: enabled);
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(AppConstants.kNotifDailyHour, hour);
    await prefs.setInt(AppConstants.kNotifDailyMinute, minute);
    state = state.copyWith(
        dailyReminderHour: hour, dailyReminderMinute: minute);
  }

  // ── Alertas de orçamento ───────────────────────────────────────────────────

  Future<void> setBudgetAlerts(bool enabled) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(AppConstants.kNotifBudgetAlerts, enabled);
    state = state.copyWith(budgetAlerts: enabled);
  }

  // ── Lembretes de metas ────────────────────────────────────────────────────

  Future<void> setGoalReminders(bool enabled) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(AppConstants.kNotifGoalReminders, enabled);
    state = state.copyWith(goalReminders: enabled);
  }

  // ── Relatório semanal ─────────────────────────────────────────────────────

  Future<void> setWeeklyReport(bool enabled) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(AppConstants.kNotifWeeklyReport, enabled);
    state = state.copyWith(weeklyReport: enabled);
  }
}

// ── Helper de leitura ─────────────────────────────────────────────────────────

/// Lê as preferências de notificação a partir do [SharedPreferences] diretamente,
/// sem passar pelo provider (útil para inicialização em [main]).
NotificationPreferences readNotificationPrefsFrom(SharedPreferences prefs) {
  return NotificationPreferences(
    dailyReminder: prefs.getBool(AppConstants.kNotifDailyReminder) ?? true,
    dailyReminderHour: prefs.getInt(AppConstants.kNotifDailyHour) ?? 20,
    dailyReminderMinute: prefs.getInt(AppConstants.kNotifDailyMinute) ?? 0,
    budgetAlerts: prefs.getBool(AppConstants.kNotifBudgetAlerts) ?? true,
    goalReminders: prefs.getBool(AppConstants.kNotifGoalReminders) ?? true,
    weeklyReport: prefs.getBool(AppConstants.kNotifWeeklyReport) ?? false,
  );
}
