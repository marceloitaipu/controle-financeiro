// test/features/transactions/data/transaction_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:controle_financeiro/features/transactions/data/models/transaction_model.dart';
import 'package:controle_financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel makeModel({
  TransactionStatus status = TransactionStatus.completed,
  String? creditCardId,
}) {
  return TransactionModel(
    id: 'tx-1',
    userId: 'user-1',
    type: TransactionType.expense,
    amount: 5000,
    date: DateTime(2026, 5, 1),
    description: 'Teste',
    accountId: creditCardId != null ? '' : 'acc-1',
    creditCardId: creditCardId,
    status: status,
    recurrence: RecurrenceType.none,
    isInstallment: false,
    attachmentUrls: const [],
    createdAt: DateTime(2026, 5, 1, 10, 0),
  );
}

void main() {
  // ── toFirestore isCreate: false (padrão / atualização) ─────────────────────
  group('TransactionModel.toFirestore — atualização (isCreate: false)', () {
    test('createdAt é Timestamp (preserva data original)', () {
      final map = makeModel().toFirestore();
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('updatedAt é FieldValue (serverTimestamp)', () {
      final map = makeModel().toFirestore();
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('campos obrigatórios presentes', () {
      final map = makeModel().toFirestore();
      expect(map.containsKey('userId'), isTrue);
      expect(map.containsKey('type'), isTrue);
      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('status'), isTrue);
    });
  });

  // ── toFirestore isCreate: true (criação) ───────────────────────────────────
  group('TransactionModel.toFirestore — criação (isCreate: true)', () {
    test('createdAt é FieldValue (serverTimestamp)', () {
      final map = makeModel().toFirestore(isCreate: true);
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('updatedAt não está presente na criação', () {
      final map = makeModel().toFirestore(isCreate: true);
      expect(map.containsKey('updatedAt'), isFalse);
    });

    test('campos obrigatórios ainda presentes', () {
      final map = makeModel().toFirestore(isCreate: true);
      expect(map.containsKey('userId'), isTrue);
      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('type'), isTrue);
    });
  });

  // ── Campos opcionais ────────────────────────────────────────────────────────
  group('TransactionModel.toFirestore — campos opcionais', () {
    test('creditCardId omitido quando null', () {
      final map = makeModel().toFirestore();
      expect(map.containsKey('creditCardId'), isFalse);
    });

    test('creditCardId incluído quando não null', () {
      final map = makeModel(creditCardId: 'card-1').toFirestore();
      expect(map['creditCardId'], 'card-1');
    });

    test('status serializado como string do enum', () {
      final map = makeModel(status: TransactionStatus.pending).toFirestore();
      expect(map['status'], 'pending');
    });
  });

  // ── fromEntity / toEntity round-trip ────────────────────────────────────────
  group('TransactionModel round-trip fromEntity→toEntity', () {
    test('preserva todos os campos', () {
      final original = makeModel();
      final entity = original.toEntity();
      final rebuilt = TransactionModel.fromEntity(entity);
      expect(rebuilt.id, original.id);
      expect(rebuilt.amount, original.amount);
      expect(rebuilt.status, original.status);
      expect(rebuilt.createdAt, original.createdAt);
    });
  });
}
