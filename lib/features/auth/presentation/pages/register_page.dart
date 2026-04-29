// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_logo.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authNotifierProvider.notifier)
        .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => AppSnackBar.error(
          context,
          e is Failure ? e.message : 'Erro ao criar conta.',
        ),
      );
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Cabeçalho ────────────────────────────────────────
                      const Center(child: AuthLogo(showAppName: false, size: 56)),
                      AppSpacing.vXl2,
                      Text(
                        'Crie sua conta gratuita',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      AppSpacing.vXs,
                      Text(
                        'Comece a controlar suas finanças agora.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                      AppSpacing.vXl2,

                      // ── Nome ─────────────────────────────────────────────
                      AppTextField(
                        label: 'Nome completo',
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: Validators.name,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (_) =>
                            _emailFocusNode.requestFocus(),
                      ),
                      AppSpacing.vLg,

                      // ── E-mail ───────────────────────────────────────────
                      AppTextField(
                        label: 'E-mail',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (_) =>
                            _passwordFocusNode.requestFocus(),
                      ),
                      AppSpacing.vLg,

                      // ── Senha ────────────────────────────────────────────
                      AppTextField.password(
                        label: 'Senha',
                        hint: 'Mín. 8 chars com letras e números',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (_) =>
                            _confirmFocusNode.requestFocus(),
                      ),
                      AppSpacing.vLg,

                      // ── Confirmar senha ──────────────────────────────────
                      AppTextField.password(
                        label: 'Confirmar senha',
                        controller: _confirmController,
                        focusNode: _confirmFocusNode,
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            Validators.confirmPassword(
                              _passwordController.text,
                            )(v),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      AppSpacing.vXl3,

                      // ── Botão criar conta ────────────────────────────────
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
                            : const Text('Criar conta'),
                      ),
                      AppSpacing.vLg,

                      // ── Já tem conta ─────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já tem uma conta? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed:
                                isLoading ? null : () => context.pop(),
                            child: const Text('Entrar'),
                          ),
                        ],
                      ),
                      AppSpacing.vMd,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}