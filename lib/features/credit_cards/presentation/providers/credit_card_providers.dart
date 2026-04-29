// lib/features/credit_cards/presentation/providers/credit_card_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/credit_card_remote_datasource.dart';
import '../../data/repositories/credit_card_repository_impl.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/credit_card_repository.dart';

part 'credit_card_providers.g.dart';

// ── Infra (keepAlive) ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
CreditCardRemoteDataSource creditCardRemoteDataSource(Ref ref) {
  return CreditCardRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
CreditCardRepository creditCardRepository(Ref ref) {
  return CreditCardRepositoryImpl(
    ref.watch(creditCardRemoteDataSourceProvider),
    ref.watch(currentUserIdProvider),
  );
}

// ── Streams ───────────────────────────────────────────────────────────────────

@riverpod
Stream<List<CreditCard>> watchCreditCards(Ref ref) {
  return ref.watch(creditCardRepositoryProvider).watchCreditCards();
}

@riverpod
Stream<List<Invoice>> watchInvoices(Ref ref, String cardId) {
  return ref.watch(creditCardRepositoryProvider).watchInvoices(cardId);
}

// ── CRUD cartões ──────────────────────────────────────────────────────────────

/// Notifier para operações de criação, edição e exclusão de cartões.
@riverpod
class CreditCardNotifier extends _$CreditCardNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createCreditCard(CreditCard card) async {
    state = const AsyncLoading();
    final result =
        await ref.read(creditCardRepositoryProvider).createCreditCard(card);
    return result.fold(
      (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> updateCreditCard(CreditCard card) async {
    state = const AsyncLoading();
    final result =
        await ref.read(creditCardRepositoryProvider).updateCreditCard(card);
    return result.fold(
      (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> deleteCreditCard(String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(creditCardRepositoryProvider).deleteCreditCard(id);
    return result.fold(
      (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Calcula o yearMonth ('YYYY-MM') da fatura para uma compra.
///
/// Se a data da compra é anterior ao dia de fechamento, a compra vai para a
/// fatura do mês corrente; caso contrário, para a fatura do próximo mês.
String computeInvoiceYearMonth(DateTime date, int closingDay) {
  if (date.day < closingDay) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
  final next = DateTime(date.year, date.month + 1);
  return '${next.year}-${next.month.toString().padLeft(2, '0')}';
}

// ── Compra no cartão ──────────────────────────────────────────────────────────

/// Notifier para criação de compras no cartão de crédito (com suporte a parcelamento).
///
/// Para cada parcela, cria uma transação com [accountId] vazio e atualiza o
/// total da fatura do mês correspondente de forma atômica.
@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createPurchase({
    required CreditCard card,
    required String description,
    required int totalAmountCents,
    required DateTime date,
    required String userId,
    String? categoryId,
    int totalInstallments = 1,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      final cardRepo = ref.read(creditCardRepositoryProvider);

      final n = totalInstallments.clamp(1, 60);
      final baseAmount = (totalAmountCents / n).round();
      final now = DateTime.now();

      // ── 1. Constrói todas as transações de parcela em memória ──────────
      final transactions = <Transaction>[];
      for (var i = 0; i < n; i++) {
        final purchaseDate = DateTime(date.year, date.month + i, date.day);
        // Última parcela absorve o resto do arredondamento
        final installmentAmount =
            (i == n - 1) ? totalAmountCents - baseAmount * (n - 1) : baseAmount;

        transactions.add(Transaction(
          id: '',
          userId: userId,
          type: TransactionType.expense,
          amount: installmentAmount,
          description: n > 1 ? '$description (${i + 1}/$n)' : description,
          date: purchaseDate,
          accountId: '', // vazio = compra no cartão (sem débito em conta)
          creditCardId: card.id,
          categoryId: categoryId,
          status: TransactionStatus.completed,
          recurrence: RecurrenceType.none,
          isInstallment: n > 1,
          installmentNumber: n > 1 ? i + 1 : null,
          totalInstallments: n > 1 ? n : null,
          notes: notes,
          createdAt: now,
        ));
      }

      // ── 2. Persiste TODAS as parcelas atomicamente ─────────────────────
      // Se qualquer uma falhar, nenhuma é criada — sem dados órfãos.
      final batchResult = await txRepo.createTransactionsBatch(transactions);
      if (batchResult.isLeft()) {
        final msg = batchResult.fold(
            (l) => l.message, (_) => 'Erro ao salvar compra.');
        state = AsyncError(msg, StackTrace.current);
        return false;
      }

      // ── 3. Atualiza totais das faturas (operações separadas por fatura) ─
      // Falhas aqui não causam perda de transações — apenas inconsistência
      // no total da fatura, que pode ser corrigida numa futura sincronização.
      final savedTransactions = batchResult.getOrElse(() => []);
      for (var i = 0; i < n; i++) {
        final purchaseDate = DateTime(date.year, date.month + i, date.day);
        final yearMonth =
            computeInvoiceYearMonth(purchaseDate, card.closingDay);
        await cardRepo.getOrCreateInvoice(
            cardId: card.id, yearMonth: yearMonth);
        await cardRepo.addToInvoiceTotal(
          cardId: card.id,
          yearMonth: yearMonth,
          amount: savedTransactions[i].amount,
        );
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// ── Pagamento de fatura ───────────────────────────────────────────────────────

/// Notifier para pagamento de fatura de cartão de crédito.
///
/// 1. Cria uma transação de despesa na conta de pagamento.
/// 2. Marca a fatura como paga com o ID da transação criada.
@riverpod
class PayInvoiceNotifier extends _$PayInvoiceNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> payInvoice({
    required String cardId,
    required Invoice invoice,
    required String paymentAccountId,
    required String userId,
  }) async {
    state = const AsyncLoading();
    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      final cardRepo = ref.read(creditCardRepositoryProvider);

      // Cria transação de débito na conta de pagamento
      final tx = Transaction(
        id: '',
        userId: userId,
        type: TransactionType.expense,
        amount: invoice.totalAmount,
        description:
            'Pagamento fatura ${_formatYearMonth(invoice.yearMonth)}',
        date: DateTime.now(),
        accountId: paymentAccountId,
        status: TransactionStatus.completed,
        recurrence: RecurrenceType.none,
        notes: 'Pagamento cartão de crédito',
        createdAt: DateTime.now(),
      );

      final txResult = await txRepo.createTransaction(tx);
      if (txResult.isLeft()) {
        final msg = txResult.fold(
            (l) => l.message, (_) => 'Erro ao criar transação de pagamento.');
        state = AsyncError(msg, StackTrace.current);
        return false;
      }

      final createdTx = txResult.getOrElse(() => tx);

      // Marca fatura como paga com o ID real da transação
      final payResult = await cardRepo.payInvoice(
        cardId: cardId,
        yearMonth: invoice.yearMonth,
        paymentTransactionId: createdTx.id,
      );

      return payResult.fold(
        (f) {
          state = AsyncError(f.message, StackTrace.current);
          return false;
        },
        (_) {
          state = const AsyncData(null);
          return true;
        },
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  String _formatYearMonth(String yearMonth) {
    final parts = yearMonth.split('-');
    if (parts.length != 2) return yearMonth;
    final month = int.tryParse(parts[1]) ?? 0;
    const months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${months[month]}/${parts[0]}';
  }
}
