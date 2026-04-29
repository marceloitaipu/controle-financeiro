// lib/core/services/analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

/// Wrapper do Firebase Analytics.
///
/// Centraliza todos os eventos de rastreamento do app em um único lugar.
/// Use [AnalyticsService.instance] ou injete via [analyticsServiceProvider].
///
/// Eventos são silenciados automaticamente em modo debug para não poluir
/// os dados de produção. Para testá-los em debug, chame
/// [FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)]
/// durante desenvolvimento.
final class AnalyticsService {
  AnalyticsService._() : _analytics = FirebaseAnalytics.instance;

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics;

  /// Observer para tracking automático de rotas com GoRouter.
  ///
  /// Registre em [GoRouter.observers]:
  /// ```dart
  /// observers: [AnalyticsService.instance.observer],
  /// ```
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ── Usuário ──────────────────────────────────────────────────────────────

  /// Define o ID do usuário no Analytics (chamado no login).
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e, st) {
      AppLogger.warning('Analytics.setUserId failed', e, st);
    }
  }

  /// Remove o ID do usuário (chamado no logout).
  Future<void> clearUserId() => setUserId(null);

  // ── Autenticação ─────────────────────────────────────────────────────────

  Future<void> logLogin({required String method}) async {
    _safeLog(() => _analytics.logLogin(loginMethod: method));
  }

  Future<void> logSignUp({required String method}) async {
    _safeLog(() => _analytics.logSignUp(signUpMethod: method));
  }

  // ── Transações ───────────────────────────────────────────────────────────

  Future<void> logTransactionCreated({
    required String type,
    required int amountCents,
  }) async {
    _safeLog(() => _analytics.logEvent(
          name: 'transaction_created',
          parameters: {
            'type': type,
            'amount_cents': amountCents,
          },
        ));
  }

  Future<void> logTransactionDeleted() async {
    _safeLog(() => _analytics.logEvent(name: 'transaction_deleted'));
  }

  // ── Contas ────────────────────────────────────────────────────────────────

  Future<void> logAccountCreated({required String accountType}) async {
    _safeLog(() => _analytics.logEvent(
          name: 'account_created',
          parameters: {'account_type': accountType},
        ));
  }

  // ── Metas ─────────────────────────────────────────────────────────────────

  Future<void> logGoalCreated({required int targetAmountCents}) async {
    _safeLog(() => _analytics.logEvent(
          name: 'goal_created',
          parameters: {'target_amount_cents': targetAmountCents},
        ));
  }

  Future<void> logGoalCompleted() async {
    _safeLog(() => _analytics.logEvent(name: 'goal_completed'));
  }

  // ── Orçamentos ────────────────────────────────────────────────────────────

  Future<void> logBudgetCreated({required int amountCents}) async {
    _safeLog(() => _analytics.logEvent(
          name: 'budget_created',
          parameters: {'amount_cents': amountCents},
        ));
  }

  // ── Cartões de crédito ────────────────────────────────────────────────────

  Future<void> logCreditCardCreated() async {
    _safeLog(() => _analytics.logEvent(name: 'credit_card_created'));
  }

  // ── Configurações ─────────────────────────────────────────────────────────

  Future<void> logThemeChanged({required String theme}) async {
    _safeLog(() => _analytics.logEvent(
          name: 'theme_changed',
          parameters: {'theme': theme},
        ));
  }

  Future<void> logCurrencyChanged({required String currency}) async {
    _safeLog(() => _analytics.logEvent(
          name: 'currency_changed',
          parameters: {'currency': currency},
        ));
  }

  // ── Telas ─────────────────────────────────────────────────────────────────

  /// Loga visualização de tela manualmente (quando GoRouter observer
  /// não captura corretamente — ex: bottom sheets, dialogs).
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    _safeLog(() => _analytics.logScreenView(
          screenName: screenName,
          screenClass: screenClass,
        ));
  }

  // ── Interno ───────────────────────────────────────────────────────────────

  void _safeLog(Future<void> Function() fn) {
    if (kDebugMode) return; // não poluir dados de produção com testes
    fn().catchError((Object e, StackTrace st) {
      AppLogger.warning('Analytics event failed', e, st);
    });
  }
}
