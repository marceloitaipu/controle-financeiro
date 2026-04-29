// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeModeNotifierHash() => r'84bc0aa80b8613271e977905aaf803dd5a3157a5';

/// Gerenciador do tema do aplicativo (claro, escuro, sistema).
///
/// Persiste a preferência em [SharedPreferences] sob [AppConstants.kThemeModeKey].
/// keepAlive: true garante que o estado do tema nunca seja descartado.
///
/// Leitura: ref.watch(themeModeNotifierProvider)
/// Escrita:  ref.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.dark)
/// Toggle:   ref.read(themeModeNotifierProvider.notifier).toggleTheme()
///
/// Copied from [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
  ThemeModeNotifier.new,
  name: r'themeModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeModeNotifier = Notifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
