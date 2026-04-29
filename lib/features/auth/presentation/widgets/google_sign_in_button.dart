// lib/features/auth/presentation/widgets/google_sign_in_button.dart

import 'package:flutter/material.dart';

/// Botão padronizado para "Continuar com Google".
///
/// Uso:
/// ```dart
/// GoogleSignInButton(
///   onPressed: isLoading ? null : _signInWithGoogle,
///   isLoading: isLoading,
/// )
/// ```
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoogleColoredG(),
                SizedBox(width: 10),
                Text('Continuar com Google'),
              ],
            ),
    );
  }
}

/// "G" estilizado nas cores oficiais do Google usando RichText.
class _GoogleColoredG extends StatelessWidget {
  const _GoogleColoredG();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Arial',
          height: 1.0,
        ),
        children: [
          TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
          TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))),
          TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))),
          TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
          TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))),
          TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))),
        ],
      ),
    );
  }
}