// lib/features/auth/presentation/pages/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen: transição de loading → data = sucesso; erro = SnackBar.
    ref.listen<AsyncValue<void>>(authNotifierProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue) {
        if (mounted) setState(() => _emailSent = true);
        return;
      }
      next.whenOrNull(
        error: (e, _) => AppSnackBar.error(
          context,
          e is Failure ? e.message : 'Erro ao enviar e-mail.',
        ),
      );
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir senha'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child:
                  _emailSent ? _buildSuccess(context) : _buildForm(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  // ── Formulário ────────────────────────────────────────────────────────────

  Widget _buildForm(bool isLoading) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Ícone ──────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 38,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          AppSpacing.vXl2,

          // ── Título ──────────────────────────────────────────────────────
          Text(
            'Esqueceu a senha?',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSm,
          Text(
            'Informe seu e-mail e enviaremos um link para redefinir sua senha.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vXl3,

          // ── Campo e-mail ─────────────────────────────────────────────────
          AppTextField(
            label: 'E-mail cadastrado',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _submit(),
          ),
          AppSpacing.vXl2,

          // ── Botão enviar ─────────────────────────────────────────────────
          FilledButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enviar link'),
          ),
          AppSpacing.vMd,

          // ── Voltar ───────────────────────────────────────────────────────
          TextButton(
            onPressed: isLoading ? null : () => context.pop(),
            child: const Text('Voltar para o login'),
          ),
        ],
      ),
    );
  }

  // ── Tela de sucesso ───────────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 38,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
        AppSpacing.vXl2,
        Text(
          'E-mail enviado!',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vSm,
        Text(
          'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXl3,
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Voltar para o login'),
        ),
        AppSpacing.vMd,
        OutlinedButton(
          onPressed: () {
            // Permite reenviar o e-mail
            ref.read(authNotifierProvider.notifier).resetState();
            setState(() => _emailSent = false);
          },
          child: const Text('Reenviar e-mail'),
        ),
      ],
    );
  }
}