// lib/features/auth/presentation/widgets/auth_logo.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';

/// Logo do aplicativo para as telas de autenticação.
///
/// Exibe ícone + nome do app verticalmente.
/// Reutilizado em LoginPage, RegisterPage e ForgotPasswordPage.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.showAppName = true, this.size = 72});

  final bool showAppName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: size * 0.54,
            color: cs.onPrimaryContainer,
          ),
        ),
        if (showAppName) ...[
          AppSpacing.vMd,
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ],
    );
  }
}
