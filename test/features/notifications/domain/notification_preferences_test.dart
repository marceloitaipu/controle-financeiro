// test/features/notifications/domain/notification_preferences_test.dart

import 'package:controle_financeiro/features/notifications/domain/entities/notification_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  NotificationPreferences makePrefs({
    bool dailyReminder = true,
    int dailyReminderHour = 9,
    int dailyReminderMinute = 0,
    bool budgetAlerts = true,
    bool goalReminders = true,
    bool weeklyReport = false,
  }) {
    return NotificationPreferences(
      dailyReminder: dailyReminder,
      dailyReminderHour: dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute,
      budgetAlerts: budgetAlerts,
      goalReminders: goalReminders,
      weeklyReport: weeklyReport,
    );
  }

  // ── dailyReminderTime ─────────────────────────────────────────────────────
  group('NotificationPreferences.dailyReminderTime', () {
    test('retorna TimeOfDay com hour=9 e minute=0', () {
      final prefs = makePrefs(dailyReminderHour: 9, dailyReminderMinute: 0);
      expect(prefs.dailyReminderTime, const TimeOfDay(hour: 9, minute: 0));
    });

    test('retorna TimeOfDay com hour=22 e minute=30', () {
      final prefs = makePrefs(dailyReminderHour: 22, dailyReminderMinute: 30);
      expect(prefs.dailyReminderTime, const TimeOfDay(hour: 22, minute: 30));
    });

    test('retorna TimeOfDay com hour=0 e minute=0 (meia-noite)', () {
      final prefs = makePrefs(dailyReminderHour: 0, dailyReminderMinute: 0);
      expect(prefs.dailyReminderTime, const TimeOfDay(hour: 0, minute: 0));
    });

    test('retorna TimeOfDay com hour=23 e minute=59', () {
      final prefs = makePrefs(dailyReminderHour: 23, dailyReminderMinute: 59);
      expect(prefs.dailyReminderTime, const TimeOfDay(hour: 23, minute: 59));
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('NotificationPreferences — igualdade (Equatable)', () {
    test('mesmos campos são iguais', () {
      expect(makePrefs(), equals(makePrefs()));
    });

    test('dailyReminder diferente → diferentes', () {
      expect(
        makePrefs(dailyReminder: true),
        isNot(equals(makePrefs(dailyReminder: false))),
      );
    });

    test('dailyReminderHour diferente → diferentes', () {
      expect(
        makePrefs(dailyReminderHour: 8),
        isNot(equals(makePrefs(dailyReminderHour: 9))),
      );
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('NotificationPreferences.copyWith', () {
    test('altera dailyReminderHour e mantém demais campos', () {
      final original = makePrefs(dailyReminderHour: 9);
      final copy = original.copyWith(dailyReminderHour: 8);
      expect(copy.dailyReminderHour, 8);
      expect(copy.dailyReminder, original.dailyReminder);
    });

    test('sem argumentos retorna objeto equivalente', () {
      expect(makePrefs().copyWith(), equals(makePrefs()));
    });

    test('altera weeklyReport de false para true', () {
      final copy = makePrefs(weeklyReport: false).copyWith(weeklyReport: true);
      expect(copy.weeklyReport, true);
    });

    test('dailyReminderTime reflete o novo horário após copyWith', () {
      final original = makePrefs(dailyReminderHour: 9, dailyReminderMinute: 0);
      final copy = original.copyWith(
        dailyReminderHour: 20,
        dailyReminderMinute: 15,
      );
      expect(copy.dailyReminderTime, const TimeOfDay(hour: 20, minute: 15));
    });
  });
}
