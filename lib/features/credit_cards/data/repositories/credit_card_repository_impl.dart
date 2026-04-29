// lib/features/credit_cards/data/repositories/credit_card_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/firestore_helper.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../datasources/credit_card_remote_datasource.dart';
import '../models/credit_card_model.dart';

final class CreditCardRepositoryImpl
    with FirestoreExceptionMapper
    implements CreditCardRepository {
  CreditCardRepositoryImpl(this._ds, this._userId);

  final CreditCardRemoteDataSource _ds;
  final String _userId;

  @override
  Stream<List<CreditCard>> watchCreditCards() {
    return _ds
        .watchCreditCards(_userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, CreditCard>> getCreditCardById(String id) async {
    try {
      return Right((await _ds.getCreditCardById(_userId, id)).toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.getById'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> createCreditCard(
    CreditCard card,
  ) async {
    try {
      final model = await _ds.createCreditCard(
        CreditCardModel.fromEntity(card),
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.create'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> updateCreditCard(
    CreditCard card,
  ) async {
    try {
      final model = await _ds.updateCreditCard(
        CreditCardModel.fromEntity(card),
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.update'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCreditCard(String id) async {
    try {
      await _ds.deleteCreditCard(_userId, id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.delete'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getOrCreateInvoice({
    required String cardId,
    required String yearMonth,
  }) async {
    try {
      // Calcula datas com base no dia de fechamento do cartão
      final card = await _ds.getCreditCardById(_userId, cardId);
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // Clamp para o último dia válido do mês, evitando overflow silencioso
      // (ex: DateTime(2025, 2, 30) → 2025-03-02 sem clamp)
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final safeClosingDay = card.closingDay.clamp(1, daysInMonth);
      final safeDueDay = card.dueDay.clamp(1, daysInMonth);

      final closingDate = DateTime(year, month, safeClosingDay);
      final dueDate = DateTime(year, month, safeDueDay);

      final model = await _ds.getOrCreateInvoice(
        userId: _userId,
        cardId: cardId,
        yearMonth: yearMonth,
        closingDate: closingDate,
        dueDate: dueDate,
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.getOrCreateInvoice'));
    }
  }

  @override
  Stream<List<Invoice>> watchInvoices(String cardId) {
    return _ds
        .watchInvoices(_userId, cardId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Invoice>> getInvoiceByYearMonth({
    required String cardId,
    required String yearMonth,
  }) async {
    try {
      final model = await _ds.getInvoiceByYearMonth(
        userId: _userId,
        cardId: cardId,
        yearMonth: yearMonth,
      );
      if (model == null) {
        return const Left(NotFoundFailure('Fatura não encontrada.'));
      }
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.getInvoice'));
    }
  }

  @override
  Future<Either<Failure, void>> addToInvoiceTotal({
    required String cardId,
    required String yearMonth,
    required int amount,
  }) async {
    try {
      await _ds.addToInvoiceTotal(
        userId: _userId,
        cardId: cardId,
        yearMonth: yearMonth,
        amount: amount,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'CreditCardRepo.addToInvoiceTotal'));
    }
  }

  @override
  Future<Either<Failure, void>> payInvoice({
    required String cardId,
    required String yearMonth,
    required String paymentTransactionId,
  }) async {
    try {
      await _ds.payInvoice(
        userId: _userId,
        cardId: cardId,
        yearMonth: yearMonth,
        paymentTransactionId: paymentTransactionId,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      AppLogger.error('CreditCardRepo.payInvoice', e, st);
      return Left(mapUnexpected(e, st, 'CreditCardRepo.payInvoice'));
    }
  }
}
