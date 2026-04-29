// lib/features/notifications/domain/entities/notification_preferences.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Preferências de notificação do usuário persistidas em [SharedPreferences].
final class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.dailyReminder = true,
    this.dailyReminderHour = 20,
    this.dailyReminderMinute = 0,
    this.budgetAlerts = true,
    this.goalReminders = true,
    this.weeklyReport = false,
  });

  /// Habilita o lembrete diário para registro de transações.
  final bool dailyReminder;

  /// Hora do lembrete diário (0–23). Padrão: 20h.
  final int dailyReminderHour;

  /// Minuto do lembrete diário (0–59). Padrão: 00min.
  final int dailyReminderMinute;

  /// Habilita alertas quando um orçamento atingir 80% ou for ultrapassado.
  final bool budgetAlerts;

  /// Habilita lembretes de metas com prazo nos próximos 7 dias.
  final bool goalReminders;

  /// Habilita relatório semanal aos domingos às 9h.
  final bool weeklyReport;

  /// [TimeOfDay] derivado dos campos de hora/minuto do lembrete diário.
  TimeOfDay get dailyReminderTime =>
      TimeOfDay(hour: dailyReminderHour, minute: dailyReminderMinute);

  NotificationPreferences copyWith({
    bool? dailyReminder,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? budgetAlerts,
    bool? goalReminders,
    bool? weeklyReport,
  }) =>
      NotificationPreferences(
        dailyReminder: dailyReminder ?? this.dailyReminder,
        dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
        dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
        budgetAlerts: budgetAlerts ?? this.budgetAlerts,
        goalReminders: goalReminders ?? this.goalReminders,
        weeklyReport: weeklyReport ?? this.weeklyReport,
      );

  @override
  List<Object?> get props => [
        dailyReminder,
        dailyReminderHour,
        dailyReminderMinute,
        budgetAlerts,
        goalReminders,
        weeklyReport,
      ];
}
