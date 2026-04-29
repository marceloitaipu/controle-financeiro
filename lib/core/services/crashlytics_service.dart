// lib/core/services/crashlytics_service.dart

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Crashlytics não suporta web. Todos os métodos públicos desta classe
// devem ser chamados apenas quando !kIsWeb (ver main.dart).

import '../utils/app_logger.dart';

/// Wrapper do Firebase Crashlytics.
///
/// Centraliza toda a integração com Crashlytics em um único lugar.
/// Use [CrashlyticsService.instance] para registrar erros e configurar
/// o usuário logado.
///
/// Crashlytics é desabilitado automaticamente em [kDebugMode] para não
/// misturar crashes de desenvolvimento com os de produção.
final class CrashlyticsService {
  CrashlyticsService._() : _crashlytics = FirebaseCrashlytics.instance;

  static CrashlyticsService? _instance;

  /// Retorna a instância única. Nunca chame em plataforma web (kIsWeb).
  static CrashlyticsService get instance {
    _instance ??= CrashlyticsService._();
    return _instance!;
  }

  final FirebaseCrashlytics _crashlytics;

  /// Inicializa o Crashlytics.
  ///
  /// Deve ser chamado em [main()] após [Firebase.initializeApp()].
  /// Registra os handlers globais de erro do Flutter e da plataforma.
  Future<void> initialize() async {
    // Desabilitar em debug — erros de dev não devem ir para produção.
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Captura exceções lançadas dentro do pipeline de build/layout/paint.
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // Em debug, exibe no console com stack trace completo.
        FlutterError.dumpErrorToConsole(details);
      } else {
        _crashlytics.recordFlutterFatalError(details);
      }
      AppLogger.fatal(
        details.exceptionAsString(),
        details.exception,
        details.stack,
      );
    };

    // Captura erros assíncronos fora da zona Flutter.
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (!kDebugMode) {
        _crashlytics.recordError(error, stack, fatal: true);
      }
      AppLogger.fatal('PlatformDispatcher unhandled error', error, stack);
      return true;
    };
  }

  // ── Usuário ──────────────────────────────────────────────────────────────

  /// Associa o ID do usuário autenticado aos relatórios de crash.
  /// Chame após login bem-sucedido.
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e, st) {
      AppLogger.warning('Crashlytics.setUserId failed', e, st);
    }
  }

  /// Remove o ID do usuário dos relatórios (chame no logout).
  Future<void> clearUserId() async {
    try {
      await _crashlytics.setUserIdentifier('');
    } catch (e, st) {
      AppLogger.warning('Crashlytics.clearUserId failed', e, st);
    }
  }

  // ── Erros não-fatais ──────────────────────────────────────────────────────

  /// Registra um erro não-fatal no Crashlytics.
  ///
  /// Use para erros esperados mas relevantes de monitorar
  /// (ex: falha de rede, timeout de Firestore).
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      AppLogger.error('CrashlyticsService.recordError [debug]', error, stack);
      return;
    }
    try {
      await _crashlytics.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (e, st) {
      AppLogger.warning('Crashlytics.recordError failed', e, st);
    }
  }

  // ── Chaves customizadas ───────────────────────────────────────────────────

  /// Adiciona uma chave-valor ao contexto do relatório de crash.
  ///
  /// Exemplos úteis:
  /// ```dart
  /// CrashlyticsService.instance.setCustomKey('last_route', '/home');
  /// CrashlyticsService.instance.setCustomKey('currency', 'BRL');
  /// ```
  Future<void> setCustomKey(String key, Object value) async {
    if (kDebugMode) return;
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e, st) {
      AppLogger.warning('Crashlytics.setCustomKey failed', e, st);
    }
  }

  /// Adiciona uma linha de log ao relatório de crash (últimas 64 linhas
  /// são incluídas no relatório).
  Future<void> log(String message) async {
    if (kDebugMode) return;
    try {
      await _crashlytics.log(message);
    } catch (e, st) {
      AppLogger.warning('Crashlytics.log failed', e, st);
    }
  }
}
