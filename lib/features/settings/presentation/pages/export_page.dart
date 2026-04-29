// lib/features/settings/presentation/pages/export_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Tela de exportação de dados financeiros.
///
/// Permite ao usuário selecionar um período e exportar as transações
/// no formato **CSV** (compatível com Excel) ou **PDF** (relatório formatado).
class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  late DateTime _start;
  late DateTime _end;
  bool _isLoading = false;

  static final _displayFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  // ── Ações ──────────────────────────────────────────────────────────────────

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecionar período',
      saveText: 'Confirmar',
      cancelText: 'Cancelar',
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _start = picked.start;
      _end = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _start = DateTime(now.year, now.month, 1);
      _end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    });
  }

  void _setLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    setState(() {
      _start = DateTime(lastMonth.year, lastMonth.month, 1);
      _end = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
    });
  }

  void _setThisYear() {
    final now = DateTime.now();
    setState(() {
      _start = DateTime(now.year, 1, 1);
      _end = DateTime(now.year, 12, 31, 23, 59, 59);
    });
  }

  Future<void> _export(_ExportFormat format) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final filter = TransactionFilter(
        startDate: _start,
        endDate: _end,
        limit: 10000,
      );
      final transactions = await repo.watchTransactions(filter: filter).first;

      if (transactions.isEmpty) {
        AppSnackBar.warning(
          context,
          'Nenhuma transação no período selecionado.',
        );
        return;
      }

      if (format == _ExportFormat.csv) {
        await ExportService.instance.exportCsv(
          transactions: transactions,
          start: _start,
          end: _end,
        );
      } else {
        await ExportService.instance.exportPdf(
          transactions: transactions,
          start: _start,
          end: _end,
        );
      }

      AnalyticsService.instance._safeLogExport(format.name);

      if (mounted) {
        AppSnackBar.success(context, 'Exportação concluída!');
      }
    } catch (e, st) {
      debugPrint('ExportPage error: $e\n$st');
      if (mounted) {
        AppSnackBar.error(context, 'Erro ao exportar dados. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Exportar dados')),
      body: Stack(
        children: [
          ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // ── Período ────────────────────────────────────────────────────
              const _SectionLabel('Período'),
              const SizedBox(height: AppSpacing.sm),

              // Atalhos rápidos
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _QuickChip(
                    label: 'Este mês',
                    onTap: _setThisMonth,
                  ),
                  _QuickChip(
                    label: 'Mês passado',
                    onTap: _setLastMonth,
                  ),
                  _QuickChip(
                    label: 'Este ano',
                    onTap: _setThisYear,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Card com período selecionado
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        color: cs.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${_displayFmt.format(_start)}  →  ${_displayFmt.format(_end)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar_outlined,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl3),

              // ── Formato ────────────────────────────────────────────────────
              const _SectionLabel('Exportar como'),
              const SizedBox(height: AppSpacing.md),

              // CSV
              _ExportButton(
                icon: Icons.table_chart_outlined,
                label: 'Planilha CSV',
                sublabel: 'Compatível com Excel e Google Sheets',
                color: AppColors.income,
                onTap: _isLoading ? null : () => _export(_ExportFormat.csv),
              ),

              const SizedBox(height: AppSpacing.md),

              // PDF
              _ExportButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Relatório PDF',
                sublabel: 'Resumo + tabela de transações formatada',
                color: AppColors.danger,
                onTap: _isLoading ? null : () => _export(_ExportFormat.pdf),
                filled: true,
              ),

              const SizedBox(height: AppSpacing.xl3),

              // ── Nota informativa ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'A exportação inclui todas as receitas, despesas e '
                        'transferências do período selecionado. '
                        'Limite: 10.000 transações por exportação.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl3),
            ],
          ),

          // ── Overlay de loading ─────────────────────────────────────────────
          if (_isLoading)
            const _LoadingOverlay(),
        ],
      ),
    );
  }
}

// ── Enum ────────────────────────────────────────────────────────────────────

enum _ExportFormat { csv, pdf }

// ── Widgets internos ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Material(
      color: filled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: filled ? Colors.white : color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: filled ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: filled
                            ? Colors.white.withValues(alpha: 0.8)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: filled ? Colors.white70 : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl2,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Gerando exportação...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Extensão interna para Analytics ─────────────────────────────────────────

extension _AnalyticsExport on AnalyticsService {
  void _safeLogExport(String format) {
    logScreenView(screenName: 'export_$format');
  }
}
