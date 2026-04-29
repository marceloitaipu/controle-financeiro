// lib/shared/providers/shared_preferences_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Provider do [SharedPreferences].
/// Deve ser inicializado via [override] no main.dart antes do runApp.
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use. '
    'Call SharedPreferences.getInstance() in main.dart and override this provider.',
  );
}
