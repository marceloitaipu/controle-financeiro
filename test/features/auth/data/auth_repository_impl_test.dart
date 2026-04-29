// test/features/auth/data/auth_repository_impl_test.dart

import 'package:controle_financeiro/core/errors/app_exception.dart';
import 'package:controle_financeiro/core/errors/failure.dart';
import 'package:controle_financeiro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:controle_financeiro/features/auth/data/models/app_user_model.dart';
import 'package:controle_financeiro/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

// ── Helpers ───────────────────────────────────────────────────────────────────
AppUserModel makeUserModel({
  String id = 'user-1',
  String email = 'joao@test.com',
  String? displayName = 'João Silva',
}) {
  return AppUserModel(
    id: id,
    email: email,
    displayName: displayName,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  // ── signInWithEmailAndPassword ────────────────────────────────────────────
  group('AuthRepositoryImpl.signInWithEmailAndPassword', () {
    test('retorna Right(AppUser) em caso de sucesso', () async {
      final model = makeUserModel();
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: 'joao@test.com',
            password: '123456',
          )).thenAnswer((_) async => model);

      final result = await repository.signInWithEmailAndPassword(
        email: 'joao@test.com',
        password: '123456',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('esperava Right'),
        (user) {
          expect(user.id, model.id);
          expect(user.email, model.email);
          expect(user.displayName, model.displayName);
        },
      );
    });

    test('retorna Left(AuthFailure) quando lança AuthException', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('credenciais inválidas'));

      final result = await repository.signInWithEmailAndPassword(
        email: 'x@test.com',
        password: 'wrong',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('esperava Left'),
      );
    });

    test('retorna Left(NetworkFailure) quando lança NetworkException', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const NetworkException());

      final result = await repository.signInWithEmailAndPassword(
        email: 'x@test.com',
        password: 'pass',
      );

      expect(result, equals(const Left(NetworkFailure())));
    });

    test('retorna Left(UnexpectedFailure) para exceção genérica', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('falha estranha'));

      final result = await repository.signInWithEmailAndPassword(
        email: 'x@test.com',
        password: 'pass',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('esperava Left'),
      );
    });
  });

  // ── createUserWithEmailAndPassword ────────────────────────────────────────
  group('AuthRepositoryImpl.createUserWithEmailAndPassword', () {
    test('retorna Right(AppUser) em caso de sucesso', () async {
      final model = makeUserModel(displayName: 'Maria');
      when(() => mockDataSource.createUserWithEmailAndPassword(
            email: 'maria@test.com',
            password: 'senha123',
            displayName: 'Maria',
          )).thenAnswer((_) async => model);

      final result = await repository.createUserWithEmailAndPassword(
        email: 'maria@test.com',
        password: 'senha123',
        displayName: 'Maria',
      );

      expect(result.isRight(), isTrue);
    });

    test('retorna Left(ValidationFailure) quando lança ValidationException',
        () async {
      when(() => mockDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(const ValidationException('email inválido'));

      final result = await repository.createUserWithEmailAndPassword(
        email: 'bad',
        password: '123',
        displayName: 'x',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('esperava Left'),
      );
    });

    test('retorna Left(ConflictFailure) quando lança ConflictException',
        () async {
      when(() => mockDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(const ConflictException('email já em uso'));

      final result = await repository.createUserWithEmailAndPassword(
        email: 'exists@test.com',
        password: '123',
        displayName: 'x',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ConflictFailure>()),
        (_) => fail('esperava Left'),
      );
    });
  });

  // ── signInWithGoogle ──────────────────────────────────────────────────────
  group('AuthRepositoryImpl.signInWithGoogle', () {
    test('retorna Right(AppUser) em caso de sucesso', () async {
      final model = makeUserModel();
      when(() => mockDataSource.signInWithGoogle())
          .thenAnswer((_) async => model);

      final result = await repository.signInWithGoogle();

      expect(result.isRight(), isTrue);
    });

    test('retorna Left(CancelledFailure) quando usuário cancela', () async {
      when(() => mockDataSource.signInWithGoogle())
          .thenThrow(const CancelledException());

      final result = await repository.signInWithGoogle();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<CancelledFailure>()),
        (_) => fail('esperava Left'),
      );
    });
  });

  // ── signOut ───────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl.signOut', () {
    test('retorna Right(null) em caso de sucesso', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, equals(const Right<Failure, void>(null)));
    });

    test('retorna Left(UnexpectedFailure) para exceção genérica', () async {
      when(() => mockDataSource.signOut()).thenThrow(Exception('erro'));

      final result = await repository.signOut();

      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('esperava Left'),
      );
    });
  });

  // ── sendPasswordResetEmail ────────────────────────────────────────────────
  group('AuthRepositoryImpl.sendPasswordResetEmail', () {
    test('retorna Right(null) em caso de sucesso', () async {
      when(() => mockDataSource.sendPasswordResetEmail(
            email: 'joao@test.com',
          )).thenAnswer((_) async {});

      final result = await repository.sendPasswordResetEmail(
        email: 'joao@test.com',
      );

      expect(result, equals(const Right<Failure, void>(null)));
    });

    test('retorna Left(NetworkFailure) quando sem conexão', () async {
      when(() => mockDataSource.sendPasswordResetEmail(
            email: any(named: 'email'),
          )).thenThrow(const NetworkException());

      final result = await repository.sendPasswordResetEmail(
        email: 'x@test.com',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('esperava Left'),
      );
    });
  });

  // ── _mapException coverage ────────────────────────────────────────────────
  group('AuthRepositoryImpl._mapException — mapeamento completo', () {
    test('CancelledException → CancelledFailure', () async {
      when(() => mockDataSource.signOut())
          .thenThrow(const CancelledException());

      final result = await repository.signOut();
      result.fold(
        (f) => expect(f, isA<CancelledFailure>()),
        (_) => fail('esperava Left'),
      );
    });

    test('StorageException → StorageFailure', () async {
      when(() => mockDataSource.signOut())
          .thenThrow(const StorageException('disco cheio'));

      final result = await repository.signOut();
      result.fold(
        (f) => expect(f, isA<StorageFailure>()),
        (_) => fail('esperava Left'),
      );
    });
  });

  // ── authStateChanges stream ───────────────────────────────────────────────
  group('AuthRepositoryImpl.authStateChanges', () {
    test('emite null quando dataSource emite null', () {
      when(() => mockDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      expect(repository.authStateChanges, emits(null));
    });

    test('emite AppUser quando dataSource emite AppUserModel', () {
      final model = makeUserModel();
      when(() => mockDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(model));

      expect(
        repository.authStateChanges,
        emits(predicate<dynamic>((u) => u?.id == model.id)),
      );
    });
  });
}
