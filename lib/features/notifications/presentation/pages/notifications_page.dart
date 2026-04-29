// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/services/local_notification_service.dart';
import '../../domain/entities/notification_preferences.dart';
import '../providers/fcm_provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../providers/notification_scheduler_provider.dart';
import '../../../insights/presentation/providers/insight_providers.dart';

/// Tela de configuração de notificações e lembretes.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool? _permissionGranted;
  bool _sendingAlerts = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted =
        await LocalNotificationService.instance.areNotificationsEnabled();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  @override
  Widget build(BuildContext context) {
    // Ativa o scheduler keepAlive enquanto a página está montada
    ref.watch(notificationSchedulerProvider);

    final prefs = ref.watch(notificationPreferencesNotifierProvider);
    final notifier =
        ref.read(notificationPreferencesNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações e Lembretes'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // ── Banner de permissão ────────────────────────────────────────────
          if (_permissionGranted == false) ...[
            _PermissionBanner(
              onAllow: () async {
                final granted = await LocalNotificationService.instance
                    .requestPermissions();
                if (mounted) setState(() => _permissionGranted = granted);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Lembrete diário ────────────────────────────────────────────────
          _SectionCard(
            title: 'Lembrete diário',
            icon: Icons.alarm_rounded,
            iconColor: AppColors.info,
            children: [
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                title: const Text('Registrar transações'),
                subtitle: const Text(
                    'Lembrete diário para manter o controle em dia'),
                value: prefs.dailyReminder,
                onChanged: (v) => notifier.setDailyReminder(v),
              ),
              if (prefs.dailyReminder) ...[
                const Divider(height: 1, indent: AppSpacing.lg),
                _TimePickerTile(
                  time: prefs.dailyReminderTime,
                  onTap: () => _pickTime(prefs, notifier),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Alertas de orçamento ───────────────────────────────────────────
          _SectionCard(
            title: 'Orçamentos',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.warning,
            children: [
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                title: const Text('Alertas de orçamento'),
                subtitle: const Text(
                    'Avisa quando um orçamento atingir 80% ou for ultrapassado'),
                value: prefs.budgetAlerts,
                onChanged: (v) => notifier.setBudgetAlerts(v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Lembretes de metas ─────────────────────────────────────────────
          _SectionCard(
            title: 'Metas',
            icon: Icons.flag_rounded,
            iconColor: AppColors.success,
            children: [
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                title: const Text('Metas com prazo próximo'),
                subtitle: const Text(
                    'Lembrete para metas que vencem nos próximos 7 dias'),
                value: prefs.goalReminders,
                onChanged: (v) => notifier.setGoalReminders(v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Relatório semanal ──────────────────────────────────────────────
          _SectionCard(
            title: 'Relatórios',
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.seed,
            children: [
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                title: const Text('Resumo semanal'),
                subtitle:
                    const Text('Relatório financeiro todo domingo às 9h'),
                value: prefs.weeklyReport,
                onChanged: (v) => notifier.setWeeklyReport(v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Verificar alertas agora ────────────────────────────────────────
          _SectionCard(
            title: 'Verificar alertas',
            icon: Icons.notifications_active_outlined,
            iconColor: AppColors.danger,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Analisa orçamentos e metas do mês atual e envia notificações para as situações críticas.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: _sendingAlerts ? null : _sendAlerts,
                      icon: _sendingAlerts
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.notifications_active_rounded),
                      label: const Text('Verificar alertas agora'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Notificações push ──────────────────────────────────────────────
          const _FcmSection(),

          const SizedBox(height: AppSpacing.xl3),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    NotificationPreferences prefs,
    NotificationPreferencesNotifier notifier,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: prefs.dailyReminderTime,
      helpText: 'Horário do lembrete diário',
    );
    if (picked != null && mounted) {
      await notifier.setDailyReminderTime(picked.hour, picked.minute);
    }
  }

  Future<void> _sendAlerts() async {
    setState(() => _sendingAlerts = true);
    try {
      final prefs = ref.read(notificationPreferencesNotifierProvider);
      final insights =
          ref.read(currentMonthInsightsProvider).valueOrNull ?? [];
      final service = LocalNotificationService.instance;

      var budgetId = 200;
      var goalId = 300;
      var sentCount = 0;

      for (final insight in insights) {
        if (prefs.budgetAlerts &&
            (insight.type == InsightType.budgetOver ||
                insight.type == InsightType.budgetAlert)) {
          await service.showBudgetAlert(
            title: insight.title,
            body: insight.description,
            id: budgetId++,
          );
          sentCount++;
        }
        if (prefs.goalReminders &&
            (insight.type == InsightType.goalExpiringSoon ||
                insight.type == InsightType.goalAtRisk)) {
          await service.showGoalReminder(
            title: insight.title,
            body: insight.description,
            id: goalId++,
          );
          sentCount++;
        }
      }

      if (mounted) {
        final msg = sentCount == 0
            ? 'Nenhum alerta crítico encontrado no momento.'
            : '$sentCount alerta${sentCount > 1 ? 's' : ''} enviado${sentCount > 1 ? 's' : ''}.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _sendingAlerts = false);
    }
  }
}

// ── Banner de permissão ───────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onAllow});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_outlined,
              color: AppColors.warning, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações desativadas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ative as notificações para receber lembretes e alertas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: onAllow,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }
}

// ── Card de seção ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: iconColor,
                      ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

// ── Tile de horário ───────────────────────────────────────────────────────────

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({required this.time, required this.onTap});

  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: const Icon(Icons.schedule_rounded),
      title: const Text('Horário do lembrete'),
      trailing: Chip(
        label: Text(
          formatted,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      onTap: onTap,
    );
  }
}

// ── Seção FCM ─────────────────────────────────────────────────────────────────

class _FcmSection extends ConsumerWidget {
  const _FcmSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(fcmTokenProvider);

    return _SectionCard(
      title: 'Notificações push',
      icon: Icons.cloud_outlined,
      iconColor: AppColors.info,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          leading: const Icon(Icons.smartphone_rounded),
          title: const Text('Este dispositivo'),
          subtitle: tokenAsync.when(
            data: (token) => Text(
              token != null ? 'Conectado ao servidor de push' : 'Permissão negada',
              style: TextStyle(
                  color: token != null
                      ? AppColors.success
                      : AppColors.warning),
            ),
            loading: () => const Text('Verificando...'),
            error: (_, __) =>
                const Text('Erro ao verificar', style: TextStyle(color: AppColors.danger)),
          ),
          trailing: tokenAsync.when(
            data: (token) => Icon(
              token != null
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: token != null ? AppColors.success : AppColors.warning,
            ),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Icon(Icons.error_outline,
                color: AppColors.danger),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Text(
            'As notificações push permitem receber alertas mesmo com o app fechado. O suporte completo estará disponível em versões futuras.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
        ),
      ],
    );
  }
}
