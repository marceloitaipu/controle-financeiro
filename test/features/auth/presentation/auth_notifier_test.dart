// test/features/auth/presentation/auth_notifier_test.dart

import 'package:controle_financeiro/core/errors/failure.dart';
import 'package:controle_financeiro/features/auth/domain/entities/app_user.dart';
import 'package:controle_financeiro/features/auth/domain/repositories/auth_repository.dart';
import 'package:controle_financeiro/features/auth/presentation/providers/auth_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements AuthRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────
AppUser makeUser({String id = 'u1', String email = 'a@b.com'}) {
  return AppUser(id: id, email: email, createdAt: DateTime(2026, 1, 1));
}

ProviderContainer makeContainer(MockAuthRepository mockRepo) {
  return ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
  );
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    // Stub padrão para authStateChanges (usado por authStateProvider)
    when(() => mockRepo.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepo.currentUser).thenReturn(null);
  });

  // ── build ─────────────────────────────────────────────────────────────────
  group('AuthNotifier — estado inicial', () {
    test('build retorna AsyncData(null)', () {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      expect(
        container.read(authNotifierProvider),
        const AsyncData<void>(null),
      );
    });
  });

  // ── signInWithEmailAndPassword ────────────────────────────────────────────
  group('AuthNotifier.signInWithEmailAndPassword', () {
    test('estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signInWithEmailAndPassword(
            email: 'a@b.com',
            password: '123',
          )).thenAnswer((_) async => Right(makeUser()));

      await container.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
            email: 'a@b.com',
            password: '123',
          );

      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });

    test('estado → AsyncError(AuthFailure) em caso de falha', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(AuthFailure('inválido')));

      await container.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
            email: 'wrong@b.com',
            password: 'bad',
          );

      expect(
        container.read(authNotifierProvider),
        isA<AsyncError<void>>()
            .having((e) => e.error, 'error', isA<AuthFailure>()),
      );
    });
  });

  // ── createUserWithEmailAndPassword ────────────────────────────────────────
  group('AuthNotifier.createUserWithEmailAndPassword', () {
    test('estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => Right(makeUser()));

      await container
          .read(authNotifierProvider.notifier)
          .createUserWithEmailAndPassword(
            email: 'novo@b.com',
            password: '123456',
            displayName: 'Novo',
          );

      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });

    test('estado → AsyncError para ConflictFailure', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => const Left(ConflictFailure('email em uso')));

      await container
          .read(authNotifierProvider.notifier)
          .createUserWithEmailAndPassword(
            email: 'exists@b.com',
            password: '123',
            displayName: 'x',
          );

      expect(
        container.read(authNotifierProvider),
        isA<AsyncError<void>>()
            .having((e) => e.error, 'error', isA<ConflictFailure>()),
      );
    });
  });

  // ── signInWithGoogle ──────────────────────────────────────────────────────
  group('AuthNotifier.signInWithGoogle', () {
    test('estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signInWithGoogle())
          .thenAnswer((_) async => Right(makeUser()));

      await container.read(authNotifierProvider.notifier).signInWithGoogle();

      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });

    test('CancelledFailure → AsyncData(null) — silencioso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signInWithGoogle())
          .thenAnswer((_) async => const Left(CancelledFailure()));

      await container.read(authNotifierProvider.notifier).signInWithGoogle();

      // Cancelamento não deve gerar AsyncError
      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });

    test('NetworkFailure → AsyncError (não silencioso)', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signInWithGoogle())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      await container.read(authNotifierProvider.notifier).signInWithGoogle();

      expect(
        container.read(authNotifierProvider),
        isA<AsyncError<void>>()
            .having((e) => e.error, 'error', isA<NetworkFailure>()),
      );
    });
  });

  // ── signOut ───────────────────────────────────────────────────────────────
  group('AuthNotifier.signOut', () {
    test('estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signOut())
          .thenAnswer((_) async => const Right(null));

      await container.read(authNotifierProvider.notifier).signOut();

      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });

    test('estado → AsyncError em caso de falha', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.signOut()).thenAnswer(
        (_) async => const Left(UnexpectedFailure()),
      );

      await container.read(authNotifierProvider.notifier).signOut();

      expect(
        container.read(authNotifierProvider),
        isA<AsyncError<void>>(),
      );
    });
  });

  // ── sendPasswordResetEmail ────────────────────────────────────────────────
  group('AuthNotifier.sendPasswordResetEmail', () {
    test('estado → AsyncData(null) em caso de sucesso', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      when(() => mockRepo.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async => const Right(null));

      await container
          .read(authNotifierProvider.notifier)
          .sendPasswordResetEmail(email: 'x@b.com');

      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });
  });

  // ── resetState ────────────────────────────────────────────────────────────
  group('AuthNotifier.resetState', () {
    test('limpa AsyncError e volta para AsyncData(null)', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      // Primeiro cria um estado de erro
      when(() => mockRepo.signOut()).thenAnswer(
        (_) async => const Left(UnexpectedFailure()),
      );
      await container.read(authNotifierProvider.notifier).signOut();
      expect(container.read(authNotifierProvider), isA<AsyncError<void>>());

      // Agora reseta
      container.read(authNotifierProvider.notifier).resetState();
      expect(container.read(authNotifierProvider), const AsyncData<void>(null));
    });
  });
}
