// lib/shared/providers/currency_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import 'shared_preferences_provider.dart';

part 'currency_provider.g.dart';

/// Opções de moeda disponíveis no app.
///
/// Cada opção carrega código ISO 4217, símbolo exibível, nome amigável
/// e locale para formatação numérica.
enum CurrencyOption {
  brl(code: 'BRL', symbol: 'R\$', name: 'Real brasileiro', locale: 'pt_BR'),
  usd(code: 'USD', symbol: '\$', name: 'Dólar americano', locale: 'en_US'),
  eur(code: 'EUR', symbol: '€', name: 'Euro', locale: 'pt_PT'),
  gbp(code: 'GBP', symbol: '£', name: 'Libra Esterlina', locale: 'en_GB'),
  ars(code: 'ARS', symbol: '\$', name: 'Peso Argentino', locale: 'es_AR'),
  pyg(code: 'PYG', symbol: '₲', name: 'Guarani Paraguaio', locale: 'es_PY');

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
  });

  final String code;
  final String symbol;
  final String name;
  final String locale;
}

/// Gerenciador da preferência de moeda do usuário.
///
/// Persiste em [SharedPreferences] sob [AppConstants.kCurrencyKey].
/// keepAlive: true — mantém o estado durante toda a sessão.
///
/// Leitura: `ref.watch(currencyNotifierProvider)`
/// Escrita:  `ref.read(currencyNotifierProvider.notifier).setCurrency(CurrencyOption.usd)`
@Riverpod(keepAlive: true)
class CurrencyNotifier extends _$CurrencyNotifier {
  @override
  CurrencyOption build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.kCurrencyKey);
    return CurrencyOption.values.firstWhere(
      (c) => c.code == saved,
      orElse: () => CurrencyOption.brl,
    );
  }

  /// Persiste a [option] e atualiza o estado imediatamente.
  Future<void> setCurrency(CurrencyOption option) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(AppConstants.kCurrencyKey, option.code);
    state = option;
  }
}
