// lib/features/credit_cards/domain/repositories/credit_card_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/credit_card.dart';
import '../entities/invoice.dart';

abstract interface class CreditCardRepository {
  Stream<List<CreditCard>> watchCreditCards();
  Future<Either<Failure, CreditCard>> getCreditCardById(String id);
  Future<Either<Failure, CreditCard>> createCreditCard(CreditCard card);
  Future<Either<Failure, CreditCard>> updateCreditCard(CreditCard card);
  Future<Either<Failure, void>> deleteCreditCard(String id);

  /// Retorna ou cria a fatura do cartão para o período indicado.
  Future<Either<Failure, Invoice>> getOrCreateInvoice({
    required String cardId,
    required String yearMonth,
  });

  Stream<List<Invoice>> watchInvoices(String cardId);
  Future<Either<Failure, Invoice>> getInvoiceByYearMonth({
    required String cardId,
    required String yearMonth,
  });

  /// Incrementa o total da fatura de forma atômica (FieldValue.increment).
  Future<Either<Failure, void>> addToInvoiceTotal({
    required String cardId,
    required String yearMonth,
    required int amount,
  });

  /// Marca a fatura como paga usando o ID da transação já criada externamente.
  Future<Either<Failure, void>> payInvoice({
    required String cardId,
    required String yearMonth,
    required String paymentTransactionId,
  });
}
