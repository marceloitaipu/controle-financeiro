// lib/core/observers/app_provider_observer.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_logger.dart';

/// Observa o ciclo de vida dos providers Riverpod.
/// Registrado no [ProviderScope] apenas em [kDebugMode].
/// Útil para diagnosticar providers que não estão sendo criados/dispostos
/// como esperado, ou que estão lançando erros silenciosamente.
final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    AppLogger.debug('[Riverpod] ← ${_name(provider)}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Só loga se o valor realmente mudou (evita spam em providers de stream)
    if (previousValue != newValue) {
      AppLogger.debug('[Riverpod] ↺ ${_name(provider)}');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.debug('[Riverpod] × ${_name(provider)}');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      '[Riverpod] ✕ error in ${_name(provider)}',
      error,
      stackTrace,
    );
  }

  String _name(ProviderBase<Object?> provider) =>
      provider.name ?? provider.runtimeType.toString();
}
