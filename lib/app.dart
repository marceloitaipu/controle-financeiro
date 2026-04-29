// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';

/// Widget raiz do aplicativo.
///
/// Responsabilidades:
/// - Monta o [MaterialApp.router] com tema, roteador e localização.
/// - Consome [appRouterProvider] (keepAlive, nunca recriado).
/// - Consome [themeModeNotifierProvider] para tema claro/escuro/sistema.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      // ── Identidade ──────────────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Tema ────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ── Roteamento ──────────────────────────────────────────────────────
      routerConfig: router,

      // ── Localização (pt-BR como primária) ────────────────────────────────
      // Habilita textos nativos do Material em português:
      // date pickers, tooltips, botões de diálogo ("CANCELAR", "OK"), etc.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en'),
      ],
      locale: const Locale('pt', 'BR'),

      // ── Comportamento de scroll ──────────────────────────────────────────
      // MaterialScrollBehavior padroniza o comportamento entre plataformas.
      scrollBehavior: const MaterialScrollBehavior(),
    );
  }
}
