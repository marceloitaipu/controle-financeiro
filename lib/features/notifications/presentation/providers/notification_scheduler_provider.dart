// lib/features/notifications/presentation/providers/notification_scheduler_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/local_notification_service.dart';
import 'notification_preferences_provider.dart';

part 'notification_scheduler_provider.g.dart';

/// Agendador reativo de notificações locais.
///
/// Observa [notificationPreferencesNotifierProvider] e reagenda ou cancela
/// os alertas de lembrete diário e relatório semanal sempre que as
/// preferências forem alteradas.
///
/// Deve ser assistido (watched) em um widget de vida longa — ex: [HomePage] —
/// para garantir que o agendamento ocorra ao abrir o app.
@Riverpod(keepAlive: true)
Future<void> notificationScheduler(Ref ref) async {
  final prefs = ref.watch(notificationPreferencesNotifierProvider);
  final service = LocalNotificationService.instance;

  if (prefs.dailyReminder) {
    await service.scheduleDailyReminder(
        prefs.dailyReminderHour, prefs.dailyReminderMinute);
  } else {
    await service.cancelDailyReminder();
  }

  if (prefs.weeklyReport) {
    await service.scheduleWeeklyReport();
  } else {
    await service.cancelWeeklyReport();
  }
}
