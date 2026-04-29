// lib/features/notifications/data/services/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/utils/app_logger.dart';

/// Serviço singleton para notificações locais.
///
/// Deve ser inicializado uma única vez via [initialize] antes do [runApp].
/// Acesse via [LocalNotificationService.instance] em toda a aplicação.
final class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── IDs fixos ─────────────────────────────────────────────────────────────
  static const int _idDailyReminder = 1;
  static const int _idWeeklyReport = 2;

  // ── Channel IDs ───────────────────────────────────────────────────────────
  static const String _channelDailyId = 'daily_reminder';
  static const String _channelDailyName = 'Lembrete diário';
  static const String _channelBudgetId = 'budget_alerts';
  static const String _channelBudgetName = 'Alertas de orçamento';
  static const String _channelGoalId = 'goal_reminders';
  static const String _channelGoalName = 'Lembretes de metas';
  static const String _channelReportId = 'weekly_report';
  static const String _channelReportName = 'Relatório semanal';

  // ── Inicialização ─────────────────────────────────────────────────────────

  /// Inicializa o plugin, os canais Android e o fuso horário local.
  /// Deve ser chamado em [main] antes de [runApp].
  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone — necessário para zonedSchedule
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      // Fallback para o fuso de Brasília
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
      AppLogger.warning(
          'flutter_timezone falhou — usando America/Sao_Paulo', e);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _createChannels();

    _initialized = true;
    AppLogger.info('LocalNotificationService inicializado');
  }

  Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    const channels = [
      AndroidNotificationChannel(
        _channelDailyId,
        _channelDailyName,
        description: 'Lembrete diário para registrar transações',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _channelBudgetId,
        _channelBudgetName,
        description: 'Alertas quando um orçamento está próximo do limite',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _channelGoalId,
        _channelGoalName,
        description: 'Lembretes de metas com prazo próximo',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        _channelReportId,
        _channelReportName,
        description: 'Resumo financeiro semanal',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  // ── Permissões ────────────────────────────────────────────────────────────

  /// Solicita permissão ao usuário. Retorna [true] se foi concedida.
  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      return await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  /// Verifica se as notificações estão habilitadas no sistema.
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }
    // iOS: assume habilitado se o plugin foi inicializado
    return _initialized;
  }

  // ── Lembrete diário ───────────────────────────────────────────────────────

  /// Agenda lembrete diário às [hour]:[minute] no fuso local.
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _plugin.zonedSchedule(
      _idDailyReminder,
      'Controle Financeiro',
      'Não esqueça de registrar suas transações de hoje 💰',
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelDailyId,
          _channelDailyName,
          channelDescription: 'Lembrete diário para registrar transações',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    AppLogger.debug(
        'Lembrete diário agendado: $hour:${minute.toString().padLeft(2, '0')}');
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_idDailyReminder);
    AppLogger.debug('Lembrete diário cancelado');
  }

  // ── Relatório semanal ─────────────────────────────────────────────────────

  /// Agenda relatório semanal toda domingo às 9h.
  Future<void> scheduleWeeklyReport() async {
    await _plugin.zonedSchedule(
      _idWeeklyReport,
      'Resumo semanal',
      'Confira como foi sua semana financeira 📊',
      _nextSunday9am(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelReportId,
          _channelReportName,
          channelDescription: 'Resumo financeiro semanal',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    AppLogger.debug('Relatório semanal agendado');
  }

  Future<void> cancelWeeklyReport() async {
    await _plugin.cancel(_idWeeklyReport);
    AppLogger.debug('Relatório semanal cancelado');
  }

  // ── Alertas de orçamento ──────────────────────────────────────────────────

  /// Exibe notificação imediata de alerta de orçamento.
  Future<void> showBudgetAlert({
    required String title,
    required String body,
    int id = 100,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelBudgetId,
          _channelBudgetName,
          channelDescription:
              'Alertas quando um orçamento está próximo do limite',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Lembretes de meta ─────────────────────────────────────────────────────

  /// Exibe notificação imediata de lembrete de meta.
  Future<void> showGoalReminder({
    required String title,
    required String body,
    required int id,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelGoalId,
          _channelGoalName,
          channelDescription: 'Lembretes de metas com prazo próximo',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  // ── Cancelamento ──────────────────────────────────────────────────────────

  /// Cancela todas as notificações agendadas e pendentes.
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Helpers de data ───────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextSunday9am() {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
    // Avança até o próximo domingo (DateTime.sunday == 7)
    while (d.weekday != DateTime.sunday || d.isBefore(now)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}
