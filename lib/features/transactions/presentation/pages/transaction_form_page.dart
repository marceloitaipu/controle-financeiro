// lib/features/transactions/presentation/pages/transaction_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../attachments/presentation/providers/attachment_providers.dart';
import '../../../attachments/presentation/widgets/attachment_list_field.dart';
import '../../../../shared/widgets/amount_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../credit_cards/domain/entities/credit_card.dart';
import '../../../credit_cards/presentation/providers/credit_card_providers.dart';
import '../../../credit_cards/presentation/widgets/credit_card_picker_sheet.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../widgets/account_picker_sheet.dart';
import '../widgets/category_picker_sheet.dart';

/// Página de formulário de nova transação ou edição.
///
/// Para nova: [transactionType] define o tipo inicial, [transaction] é null.
/// Para edição: [transaction] é a transação existente.
class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({
    super.key,
    this.transactionType,
    this.transaction,
  });

  /// 'income', 'expense' ou 'transfer' — usado ao criar nova transação.
  final String? transactionType;

  /// Transação existente a ser editada. null = modo criação.
  final Transaction? transaction;

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _type;
  late DateTime _date;
  String? _selectedAccountId;
  String? _selectedDestAccountId;
  String? _selectedCategoryId;
  late TransactionStatus _status;
  late RecurrenceType _recurrence;

  // ── Estado para compra no cartão de crédito ───────────────────────────────
  bool _useCreditCard = false;
  CreditCard? _selectedCreditCard;
  int _totalInstallments = 2;
  bool _isInstallment = false;

  // ── Attachments ────────────────────────────────────────────────────────────
  late String _pendingTxId; // UUID pré-gerado para nova transação
  final List<XFile> _pendingFiles = []; // arquivos a enviar no save
  List<String> _keepUrls = []; // URLs existentes a manter
  final List<String> _removedUrls = []; // URLs a deletar do Storage após salvar

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final tx = widget.transaction;
    if (tx != null) {
      // Modo edição — pré-preenche os campos
      _type = tx.type;
      _date = tx.date;
      _selectedAccountId = tx.accountId;
      _selectedDestAccountId = tx.destinationAccountId;
      _selectedCategoryId = tx.categoryId;
      _status = tx.status;
      _recurrence = tx.recurrence;
      _descriptionController.text = tx.description;
      _notesController.text = tx.notes ?? '';
      // Converte centavos para reais no campo de valor
      final reais = tx.amount / 100;
      _amountController.text = reais.toStringAsFixed(2).replaceAll('.', ',');
    } else {
      // Modo criação
      _type = _parseType(widget.transactionType);
      _date = DateTime.now();
      _status = TransactionStatus.completed;
      _recurrence = RecurrenceType.none;
    }

    // Pré-gera o ID da transação (usado como pasta no Storage)
    _pendingTxId = const Uuid().v4();
    if (widget.transaction != null) {
      _keepUrls = List.of(widget.transaction!.attachmentUrls);
    }
  }

  TransactionType _parseType(String? s) => switch (s) {
        'income' => TransactionType.income,
        'expense' => TransactionType.expense,
        'transfer' => TransactionType.transfer,
        _ => TransactionType.expense,
      };

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _title => _isEditMode
      ? 'Editar transação'
      : switch (_type) {
          TransactionType.income => 'Nova Receita',
          TransactionType.expense => 'Nova Despesa',
          TransactionType.transfer => 'Nova Transferência',
        };

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(transactionNotifierProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final isLoading = notifierState.isLoading || purchaseState.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_title),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          children: [
            // ── Tipo ─────────────────────────────────────────────────────────
            if (!_isEditMode) ...[
              const _SectionLabel('Tipo'),
              const SizedBox(height: AppSpacing.sm),
              _TypeSelector(
                selected: _type,
                onChanged: (t) => setState(() {
                  _type = t;
                  // Limpa categoria ao mudar tipo
                  _selectedCategoryId = null;
                  // Reseta modo cartão se não for despesa
                  if (t != TransactionType.expense) {
                    _useCreditCard = false;
                    _selectedCreditCard = null;
                    _isInstallment = false;
                    _totalInstallments = 2;
                  }
                }),
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Valor ─────────────────────────────────────────────────────────
            const _SectionLabel('Valor'),
            const SizedBox(height: AppSpacing.sm),
            AmountField(
              controller: _amountController,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o valor';
                final amount =
                    CurrencyInputFormatter.extractValue(v) * 100;
                if (amount <= 0) return 'Valor deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Descrição ─────────────────────────────────────────────────────
            const _SectionLabel('Descrição'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Descrição',
              controller: _descriptionController,
              keyboardType: TextInputType.text,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Data ──────────────────────────────────────────────────────────
            const _SectionLabel('Data'),
            const SizedBox(height: AppSpacing.sm),
            _DateButton(
              date: _date,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Conta (oculta para compras no cartão) ──────────────────────
            if (!_useCreditCard) ...[
            const _SectionLabel('Conta'),
            const SizedBox(height: AppSpacing.sm),
            _AccountSelector(
              selectedId: _selectedAccountId,
              label: _type == TransactionType.transfer
                  ? 'Conta origem'
                  : 'Conta',
              excludeId: null,
              onChanged: (id) => setState(() => _selectedAccountId = id),
            ),
            const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Conta destino (só transferência) ──────────────────────────────
            if (_type == TransactionType.transfer) ...[
              const _SectionLabel('Conta destino'),
              const SizedBox(height: AppSpacing.sm),
              _AccountSelector(
                selectedId: _selectedDestAccountId,
                label: 'Conta destino',
                excludeId: _selectedAccountId,
                onChanged: (id) =>
                    setState(() => _selectedDestAccountId = id),
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Categoria (oculta para transferências) ────────────────────────
            if (_type != TransactionType.transfer) ...[
              const _SectionLabel('Categoria'),
              const SizedBox(height: AppSpacing.sm),
              _CategorySelector(
                type: _type,
                selectedId: _selectedCategoryId,
                onChanged: (id) => setState(() => _selectedCategoryId = id),
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Cartão de crédito (só despesas em modo criação) ───────────────
            if (_type == TransactionType.expense && !_isEditMode) ...[
              const _SectionLabel('Forma de pagamento'),
              const SizedBox(height: AppSpacing.sm),
              _CreditCardToggle(
                value: _useCreditCard,
                onChanged: (v) => setState(() {
                  _useCreditCard = v;
                  if (!v) {
                    _selectedCreditCard = null;
                    _isInstallment = false;
                    _totalInstallments = 2;
                  }
                }),
              ),
              if (_useCreditCard) ...[
                const SizedBox(height: AppSpacing.xl2),
                const _SectionLabel('Cartão'),
                const SizedBox(height: AppSpacing.sm),
                _CreditCardSelector(
                  selectedCard: _selectedCreditCard,
                  onChanged: (card) =>
                      setState(() => _selectedCreditCard = card),
                ),
                const SizedBox(height: AppSpacing.xl2),
                const _SectionLabel('Parcelamento'),
                const SizedBox(height: AppSpacing.sm),
                _InstallmentSection(
                  isInstallment: _isInstallment,
                  totalInstallments: _totalInstallments,
                  onInstallmentChanged: (v) => setState(() {
                    _isInstallment = v;
                    if (!v) _totalInstallments = 2;
                  }),
                  onCountChanged: (c) =>
                      setState(() => _totalInstallments = c),
                ),
              ],
              const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Status ────────────────────────────────────────────────────────
            const _SectionLabel('Status'),
            const SizedBox(height: AppSpacing.sm),
            _StatusToggle(
              status: _status,
              onChanged: (s) => setState(() => _status = s),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Recorrência ───────────────────────────────────────────────────
            const _SectionLabel('Recorrência'),
            const SizedBox(height: AppSpacing.sm),
            _RecurrenceDropdown(
              value: _recurrence,
              onChanged: (r) => setState(() => _recurrence = r),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Comprovantes ──────────────────────────────────────────────────
            const _SectionLabel('Comprovantes'),
            const SizedBox(height: AppSpacing.sm),
            AttachmentListField(
              existingUrls: _keepUrls,
              pendingFiles: _pendingFiles,
              onAddFiles: (files) => setState(() => _pendingFiles.addAll(files)),
              onRemoveUrl: (url) => setState(() {
                _keepUrls.remove(url);
                _removedUrls.add(url);
              }),
              onRemoveFile: (file) =>
                  setState(() => _pendingFiles.remove(file)),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Notas ─────────────────────────────────────────────────────────
            const _SectionLabel('Notas (opcional)'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Notas',
              controller: _notesController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl3),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação específica para cada modo
    if (_useCreditCard && !_isEditMode) {
      if (_selectedCreditCard == null) {
        _showSnack('Selecione um cartão.');
        return;
      }
    } else {
      if (_selectedAccountId == null) {
        _showSnack('Selecione uma conta.');
        return;
      }
    }

    if (_type == TransactionType.transfer &&
        _selectedDestAccountId == null) {
      _showSnack('Selecione a conta destino.');
      return;
    }

    final amountReais =
        CurrencyInputFormatter.extractValue(_amountController.text);
    final amountCentavos = (amountReais * 100).round();
    final userId = ref.read(currentUserIdProvider);

    // ── Compra no cartão de crédito ───────────────────────────────────────
    if (_useCreditCard && !_isEditMode && _selectedCreditCard != null) {
      final success = await ref
          .read(purchaseNotifierProvider.notifier)
          .createPurchase(
            card: _selectedCreditCard!,
            description: _descriptionController.text.trim(),
            totalAmountCents: amountCentavos,
            date: _date,
            userId: userId,
            categoryId: _selectedCategoryId,
            totalInstallments: _isInstallment ? _totalInstallments : 1,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (!success && mounted) {
        final errorState = ref.read(purchaseNotifierProvider);
        _showSnack(
          errorState.error?.toString() ?? 'Erro ao salvar compra.',
        );
      }
      return;
    }

    final tx = (_isEditMode ? widget.transaction! : null);
    final txId = tx?.id ?? _pendingTxId;

    // ── Upload de anexos pendentes ─────────────────────────────────────────
    final uploadedUrls = <String>[];
    if (_pendingFiles.isNotEmpty) {
      final repo = ref.read(attachmentRepositoryProvider);
      for (final file in _pendingFiles) {
        final result = await repo.uploadFile(
          userId: userId,
          transactionId: txId,
          file: file,
        );
        result.fold(
          (failure) => AppLogger.error(
              'TransactionForm.upload', failure.message, StackTrace.current),
          uploadedUrls.add,
        );
      }
    }

    final newTx = Transaction(
      id: txId,
      userId: userId,
      type: _type,
      amount: amountCentavos,
      description: _descriptionController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      date: _date,
      accountId: _selectedAccountId!,
      destinationAccountId: _type == TransactionType.transfer
          ? _selectedDestAccountId
          : null,
      categoryId: _type != TransactionType.transfer
          ? _selectedCategoryId
          : null,
      status: _status,
      recurrence: _recurrence,
      attachmentUrls: [..._keepUrls, ...uploadedUrls],
      createdAt: tx?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditMode) {
      success = await ref
          .read(transactionNotifierProvider.notifier)
          .updateTransaction(newTx, widget.transaction!);
    } else {
      success = await ref
          .read(transactionNotifierProvider.notifier)
          .createTransaction(newTx);
    }

    if (success && mounted) {
      // Remove do Storage as URLs que o usuário deletou
      if (_removedUrls.isNotEmpty) {
        final repo = ref.read(attachmentRepositoryProvider);
        for (final url in _removedUrls) {
          await repo.deleteFile(url);
        }
      }
      if (mounted) Navigator.of(context).pop();
    } else if (!success && mounted) {
      final errorState = ref.read(transactionNotifierProvider);
      _showSnack(errorState.error?.toString() ?? 'Erro ao salvar transação.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ── Auxiliary widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeChip(
          label: 'Despesa',
          type: TransactionType.expense,
          color: AppColors.expense,
          selected: selected,
          onTap: onChanged,
        ),
        const SizedBox(width: AppSpacing.sm),
        _TypeChip(
          label: 'Receita',
          type: TransactionType.income,
          color: AppColors.income,
          selected: selected,
          onTap: onChanged,
        ),
        const SizedBox(width: AppSpacing.sm),
        _TypeChip(
          label: 'Transferência',
          type: TransactionType.transfer,
          color: AppColors.transfer,
          selected: selected,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.type,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final TransactionType type;
  final Color color;
  final TransactionType selected;
  final ValueChanged<TransactionType> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Text(formatted, style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _AccountSelector extends ConsumerWidget {
  const _AccountSelector({
    required this.selectedId,
    required this.label,
    required this.excludeId,
    required this.onChanged,
  });

  final String? selectedId;
  final String label;
  final String? excludeId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(watchAccountsProvider);

    return accountsAsync.when(
      loading: () => const SizedBox(height: 52, child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (accounts) {
        final filtered = excludeId != null
            ? accounts.where((a) => a.id != excludeId).toList()
            : accounts;

        final selected = filtered
            .where((a) => a.id == selectedId)
            .firstOrNull;

        return InkWell(
          onTap: () async {
            final account = await showAccountPicker(
              context: context,
              ref: ref,
              excludeId: excludeId,
            );
            if (account != null) onChanged(account.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    selected?.name ?? 'Selecionar conta...',
                    style: TextStyle(
                      color: selected != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategorySelector extends ConsumerWidget {
  const _CategorySelector({
    required this.type,
    required this.selectedId,
    required this.onChanged,
  });

  final TransactionType type;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catType = type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;

    final categoriesAsync = ref.watch(
      watchCategoriesProvider(catType),
    );

    final selected = categoriesAsync.valueOrNull
        ?.where((c) => c.id == selectedId)
        .firstOrNull;

    return InkWell(
      onTap: () async {
        final cat = await showCategoryPicker(
          context: context,
          ref: ref,
          type: catType,
          selectedId: selectedId,
        );
        if (cat != null) onChanged(cat.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            if (selected != null)
              Icon(selected.icon, size: 18, color: selected.color)
            else
              Icon(
                Icons.category_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selected?.name ?? 'Selecionar categoria...',
                style: TextStyle(
                  color: selected != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.status, required this.onChanged});
  final TransactionStatus status;
  final ValueChanged<TransactionStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusChip(
          label: 'Pago',
          icon: Icons.check_circle_outline,
          status: TransactionStatus.completed,
          current: status,
          activeColor: AppColors.success,
          onTap: onChanged,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatusChip(
          label: 'Pendente',
          icon: Icons.schedule_outlined,
          status: TransactionStatus.pending,
          current: status,
          activeColor: AppColors.warning,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.status,
    required this.current,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final TransactionStatus status;
  final TransactionStatus current;
  final Color activeColor;
  final ValueChanged<TransactionStatus> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = current == status;
    return GestureDetector(
      onTap: () => onTap(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? activeColor : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? activeColor : null),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurrenceDropdown extends StatelessWidget {
  const _RecurrenceDropdown({required this.value, required this.onChanged});
  final RecurrenceType value;
  final ValueChanged<RecurrenceType> onChanged;

  String _label(RecurrenceType r) => switch (r) {
        RecurrenceType.none => 'Sem recorrência',
        RecurrenceType.daily => 'Diária',
        RecurrenceType.weekly => 'Semanal',
        RecurrenceType.monthly => 'Mensal',
        RecurrenceType.yearly => 'Anual',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<RecurrenceType>(
      initialValue: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      items: RecurrenceType.values
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text(_label(r)),
            ),
          )
          .toList(),
      onChanged: (r) {
        if (r != null) onChanged(r);
      },
    );
  }
}

// ── Widgets para compra no cartão ─────────────────────────────────────────────

class _CreditCardToggle extends StatelessWidget {
  const _CreditCardToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: SwitchListTile(
        title: const Text('Pagar com cartão de crédito'),
        subtitle: value ? null : const Text('Toque para ativar'),
        value: value,
        onChanged: onChanged,
        secondary: const Icon(Icons.credit_card_outlined),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _CreditCardSelector extends ConsumerWidget {
  const _CreditCardSelector({
    required this.selectedCard,
    required this.onChanged,
  });

  final CreditCard? selectedCard;
  final ValueChanged<CreditCard?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? cardColor;
    if (selectedCard != null) {
      try {
        cardColor = Color(
          int.parse(
            'FF${selectedCard!.colorHex.replaceFirst('#', '')}',
            radix: 16,
          ),
        );
      } catch (_) {
        cardColor = colorScheme.primary;
      }
    }

    return InkWell(
      onTap: () async {
        final card = await showCreditCardPicker(
          context: context,
          ref: ref,
          selectedId: selectedCard?.id,
        );
        if (card != null) onChanged(card);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cardColor ?? colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.credit_card,
                size: 16,
                color: cardColor != null
                    ? Colors.white
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selectedCard != null
                    ? '${selectedCard!.name}  •  •••• ${selectedCard!.lastFourDigits}'
                    : 'Selecionar cartão...',
                style: TextStyle(
                  color: selectedCard != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallmentSection extends StatelessWidget {
  const _InstallmentSection({
    required this.isInstallment,
    required this.totalInstallments,
    required this.onInstallmentChanged,
    required this.onCountChanged,
  });

  final bool isInstallment;
  final int totalInstallments;
  final ValueChanged<bool> onInstallmentChanged;
  final ValueChanged<int> onCountChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: SwitchListTile(
            title: const Text('Parcelar compra'),
            value: isInstallment,
            onChanged: onInstallmentChanged,
            secondary: const Icon(Icons.splitscreen_outlined),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (isInstallment) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Número de parcelas:',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: totalInstallments > 2
                    ? () => onCountChanged(totalInstallments - 1)
                    : null,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$totalInstallments',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: totalInstallments < 60
                    ? () => onCountChanged(totalInstallments + 1)
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
