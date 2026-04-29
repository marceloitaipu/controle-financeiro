// lib/core/widgets/async_value_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failure.dart';
import '../extensions/failure_extensions.dart';
import 'app_error_widget.dart';
import 'app_loading.dart';

/// Widget genérico que mapeia [AsyncValue<T>] para estados de UI consistentes:
/// carregamento, erro e dados.
///
/// Elimina a repetição de `.when(loading: ..., error: ..., data: ...)` em cada
/// feature, garantindo que loading e erro sigam o mesmo design system em todo o
/// app. O estado de loading padrão é [AppLoading] e o de erro é [AppErrorWidget].
///
/// ---
/// **Uso mínimo (loading e erro padrão):**
/// ```dart
/// AsyncValueWidget<List<Transaction>>(
///   value: ref.watch(transactionsProvider),
///   data:  (list) => _TransactionsList(list),
///   onRetry: () => ref.invalidate(transactionsProvider),
/// )
/// ```
///
/// **Com shimmer customizado por feature:**
/// ```dart
/// AsyncValueWidget<List<Account>>(
///   value: accountsAsync,
///   loading: () => const _AccountsShimmer(),
///   data:    (accounts) => _AccountsList(accounts),
///   onRetry: () => ref.invalidate(watchAccountsProvider),
/// )
/// ```
///
/// **Com erro totalmente customizado:**
/// ```dart
/// AsyncValueWidget<Report>(
///   value: reportAsync,
///   error: (e, _) => _CustomErrorCard(message: e.toString()),
///   data:  (report) => _ReportContent(report),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
  });

  /// O [AsyncValue] a ser mapeado para a UI.
  final AsyncValue<T> value;

  /// Builder chamado quando [value] contém dados válidos.
  final Widget Function(T data) data;

  /// Builder de loading. Quando `null`, usa [AppLoading] (spinner centralizado).
  final Widget Function()? loading;

  /// Builder de erro. Quando `null`, usa [AppErrorWidget] com [FailureX.userMessage].
  final Widget Function(Object error, StackTrace stack)? error;

  /// Callback para o botão "Tentar novamente" no [AppErrorWidget] padrão.
  /// Ignorado se [error] for fornecido.
  final VoidCallback? onRetry;

  /// Se `true`, mantém dados antigos visíveis durante revalidação em background.
  /// Evita flash de loading ao navegar de volta para uma tela já carregada.
  final bool skipLoadingOnReload;

  /// Se `true`, mantém dados durante pull-to-refresh (RefreshIndicator).
  /// Padrão `true` — comportamento mais suave para o usuário.
  final bool skipLoadingOnRefresh;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      loading: loading ?? () => const AppLoading(),
      error: error ??
          (e, _) => AppErrorWidget(
                message: e is Failure
                    ? e.userMessage
                    : 'Ocorreu um erro inesperado.',
                onRetry: onRetry,
              ),
      data: data,
    );
  }
}
