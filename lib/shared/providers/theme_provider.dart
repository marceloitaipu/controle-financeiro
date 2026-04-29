// lib/shared/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import 'shared_preferences_provider.dart';

part 'theme_provider.g.dart';

/// Gerenciador do tema do aplicativo (claro, escuro, sistema).
///
/// Persiste a preferência em [SharedPreferences] sob [AppConstants.kThemeModeKey].
/// keepAlive: true garante que o estado do tema nunca seja descartado.
///
/// Leitura: ref.watch(themeModeNotifierProvider)
/// Escrita:  ref.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.dark)
/// Toggle:   ref.read(themeModeNotifierProvider.notifier).toggleTheme()
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.kThemeModeKey);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Aplica o [mode] imediatamente no UI e persiste no [SharedPreferences].
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await ref
        .read(sharedPreferencesProvider)
        .setString(AppConstants.kThemeModeKey, value);
    state = mode;
  }

  /// Alterna entre claro e escuro.
  /// Atalho para o ícone de toggle na AppBar de Configurações.
  Future<void> toggleTheme() async {
    await setThemeMode(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
