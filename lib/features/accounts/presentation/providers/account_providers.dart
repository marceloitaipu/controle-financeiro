// lib/features/accounts/presentation/providers/account_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

part 'account_providers.g.dart';

// ── Infra (keepAlive — reutilizados em toda a sessão) ─────────────────────────

@Riverpod(keepAlive: true)
AccountRemoteDataSource accountRemoteDataSource(Ref ref) {
  return AccountRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepositoryImpl(
    ref.watch(accountRemoteDataSourceProvider),
    ref.watch(currentUserIdProvider),
  );
}

// ── Streams e dados derivados ─────────────────────────────────────────────────

/// Stream de todas as contas do usuário, ordenadas por nome.
@riverpod
Stream<List<Account>> watchAccounts(Ref ref) {
  return ref.watch(accountRepositoryProvider).watchAccounts();
}

/// Saldo total de todas as contas marcadas como [includeInTotal].
/// Derivado do stream de contas — atualiza automaticamente.
@riverpod
int totalBalance(Ref ref) {
  final accounts = ref.watch(watchAccountsProvider).valueOrNull ?? [];
  return accounts
      .where((a) => a.includeInTotal)
      .fold<int>(0, (sum, a) => sum + a.balance);
}

// ── CRUD de contas ────────────────────────────────────────────────────────────

/// Notifier para criação, edição e exclusão de contas.
///
/// Estado: [AsyncValue<void>] — AsyncData = idle, AsyncLoading = em progresso,
/// AsyncError = falha com mensagem da [Failure].
@riverpod
class AccountNotifier extends _$AccountNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createAccount(Account account) async {
    state = const AsyncLoading();
    final result =
        await ref.read(accountRepositoryProvider).createAccount(account);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> updateAccount(Account account) async {
    state = const AsyncLoading();
    final result =
        await ref.read(accountRepositoryProvider).updateAccount(account);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> deleteAccount(String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(accountRepositoryProvider).deleteAccount(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

// ── Consulta por ID ───────────────────────────────────────────────────────────

/// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
@riverpod
Future<Account?> accountById(Ref ref, String id) async {
  final result =
      await ref.read(accountRepositoryProvider).getAccountById(id);
  return result.fold((_) => null, (a) => a);
}
