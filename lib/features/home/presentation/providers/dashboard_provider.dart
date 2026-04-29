// lib/features/home/presentation/providers/dashboard_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

// ── Mês selecionado ───────────────────────────────────────────────────────────

/// Controla o mês de referência exibido no dashboard.
/// Inicializa com o mês atual e não permite navegar para o futuro.
@riverpod
class SelectedMonthNotifier extends _$SelectedMonthNotifier {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  /// Navega para o mês anterior.
  void selectPrevious() {
    state = DateTime(state.year, state.month - 1);
  }

  /// Navega para o próximo mês, bloqueando meses futuros.
  void selectNext() {
    final now = DateTime.now();
    final candidate = DateTime(state.year, state.month + 1);
    final notFuture = candidate.year < now.year ||
        (candidate.year == now.year && candidate.month <= now.month);
    if (notFuture) state = candidate;
  }

  /// Volta para o mês atual.
  void resetToCurrentMonth() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }

  /// Verdadeiro se o mês selecionado é o mês atual.
  bool get isCurrentMonth {
    final now = DateTime.now();
    return state.year == now.year && state.month == now.month;
  }
}

// ── Visibilidade do saldo ─────────────────────────────────────────────────────

/// Controla se o saldo total é exibido ou ocultado (•••••).
@riverpod
class BalanceVisibilityNotifier extends _$BalanceVisibilityNotifier {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
