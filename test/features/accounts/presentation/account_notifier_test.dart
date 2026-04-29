// test/features/accounts/presentation/account_notifier_test.dart

import 'package:controle_financeiro/core/errors/failure.dart';
import 'package:controle_financeiro/features/accounts/domain/entities/account.dart';
import 'package:controle_financeiro/features/accounts/domain/repositories/account_repository.dart';
import 'package:controle_financeiro/features/accounts/presentation/providers/account_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockAccountRepository extends Mock implements AccountRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────
Account makeAccount({
  String id = 'acc-1',
  String userId = 'user-1',
  String name = 'Conta Corrente',
  AccountType type = AccountType.checking,
  int balance = 100000, // R$ 1.000,00
}) {
  return Account(
    id: id,
    userId: userId,
    name: name,
    type: type,
    balance: balance,
    colorHex: '#1565C0',
    iconCodePoint: 0xe2b3,
    iconFontFamily: 'MaterialIcons',
    createdAt: DateTime(2026, 1, 1),
  );
}

ProviderContainer makeContainer(MockAccountRepository mockRepo) {
  return ProviderContainer(
    overrides: [accountRepositoryProvider.overrideWithValue(mockRepo)],
  );
}

void main() {
  late MockAccountRepository mockRepo;

  setUp(() {
    mockRepo = MockAccountRepository();
    // watchAccounts é usado por outros providers derivados
    when(() => mockRepo.watchAccounts()).thenAnswer((_) => const Stream.empty());
  });

  // ── build ─────────────────────────────────────────────────────────────────
  group('AccountNotifier — estado inicial', () {
    test('build retorna AsyncData(null)', () {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      expect(
        container.read(accountNotifierProvider),
        const AsyncData<void>(null),
      );
    });
  });

  // ── createAccount ─────────────────────────────────────────────────────────
  group('AccountNotifier.createAccount', () {
    test('retorna true e estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      final account = makeAccount();

      when(() => mockRepo.createAccount(account))
          .thenAnswer((_) async => Right(account));

      final result = await container
          .read(accountNotifierProvider.notifier)
          .createAccount(account);

      expect(result, isTrue);
      expect(container.read(accountNotifierProvider), const AsyncData<void>(null));
    });

    test('retorna false e estado → AsyncError em caso de falha', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      final account = makeAccount();

      when(() => mockRepo.createAccount(account)).thenAnswer(
        (_) async => const Left(ConflictFailure('nome já existe')),
      );

      final result = await container
          .read(accountNotifierProvider.notifier)
          .createAccount(account);

      expect(result, isFalse);
      expect(
        container.read(accountNotifierProvider),
        isA<AsyncError<void>>(),
      );
    });

    test('estado → AsyncError carrega mensagem da Failure', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      final account = makeAccount();
      const msg = 'conta duplicada';

      when(() => mockRepo.createAccount(account)).thenAnswer(
        (_) async => const Left(ConflictFailure(msg)),
      );

      await container
          .read(accountNotifierProvider.notifier)
          .createAccount(account);

      final stateError =
          container.read(accountNotifierProvider) as AsyncError<void>;
      expect(stateError.error, msg);
    });
  });

  // ── updateAccount ─────────────────────────────────────────────────────────
  group('AccountNotifier.updateAccount', () {
    test('retorna true e estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      final account = makeAccount();

      when(() => mockRepo.updateAccount(account))
          .thenAnswer((_) async => Right(account));

      final result = await container
          .read(accountNotifierProvider.notifier)
          .updateAccount(account);

      expect(result, isTrue);
      expect(container.read(accountNotifierProvider), const AsyncData<void>(null));
    });

    test('retorna false em caso de falha', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      final account = makeAccount();

      when(() => mockRepo.updateAccount(account)).thenAnswer(
        (_) async => const Left(NotFoundFailure('conta não encontrada')),
      );

      final result = await container
          .read(accountNotifierProvider.notifier)
          .updateAccount(account);

      expect(result, isFalse);
    });
  });

  // ── deleteAccount ─────────────────────────────────────────────────────────
  group('AccountNotifier.deleteAccount', () {
    test('retorna true e estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.deleteAccount('acc-1'))
          .thenAnswer((_) async => const Right(null));

      final result = await container
          .read(accountNotifierProvider.notifier)
          .deleteAccount('acc-1');

      expect(result, isTrue);
      expect(container.read(accountNotifierProvider), const AsyncData<void>(null));
    });

    test('retorna false e estado → AsyncError em caso de falha', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.deleteAccount(any())).thenAnswer(
        (_) async => const Left(UnexpectedFailure()),
      );

      final result = await container
          .read(accountNotifierProvider.notifier)
          .deleteAccount('acc-99');

      expect(result, isFalse);
      expect(
        container.read(accountNotifierProvider),
        isA<AsyncError<void>>(),
      );
    });
  });

  // ── accountById ───────────────────────────────────────────────────────────
  group('accountByIdProvider', () {
    test('retorna Account quando repositório tem sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      final account = makeAccount();

      when(() => mockRepo.getAccountById('acc-1'))
          .thenAnswer((_) async => Right(account));

      final result =
          await container.read(accountByIdProvider('acc-1').future);

      expect(result, account);
    });

    test('retorna null quando repositório retorna Failure', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.getAccountById(any())).thenAnswer(
        (_) async => const Left(NotFoundFailure('não existe')),
      );

      final result =
          await container.read(accountByIdProvider('xxx').future);

      expect(result, isNull);
    });
  });
}
