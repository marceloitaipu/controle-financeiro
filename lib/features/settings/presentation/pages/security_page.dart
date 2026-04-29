// lib/features/settings/presentation/pages/security_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Tela de segurança: alterar senha via e-mail e excluir conta.
class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => AppSnackBar.error(
          context,
          e is Failure ? e.message : 'Ocorreu um erro. Tente novamente.',
        ),
      );
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Segurança')),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // ── Banner informativo ─────────────────────────────────────────────
          const _InfoBanner(
            message:
                'Mantenha sua conta protegida com uma senha forte e única.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Senha ──────────────────────────────────────────────────────────
          _SecurityCard(
            title: 'Senha',
            children: [
              _SecurityTile(
                icon: Icons.lock_reset_rounded,
                iconColor: AppColors.info,
                title: 'Alterar senha',
                subtitle:
                    'Enviar e-mail de redefinição para ${user?.email ?? ''}',
                loading: isLoading,
                onTap: () =>
                    _sendPasswordReset(context, ref, user?.email),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Zona de perigo ─────────────────────────────────────────────────
          _SecurityCard(
            title: 'Zona de perigo',
            titleColor: AppColors.danger,
            children: [
              _SecurityTile(
                icon: Icons.delete_forever_rounded,
                iconColor: AppColors.danger,
                title: 'Excluir conta',
                subtitle:
                    'Remove permanentemente sua conta e todos os dados',
                loading: isLoading,
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl3),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset(
    BuildContext context,
    WidgetRef ref,
    String? email,
  ) async {
    if (email == null || email.isEmpty) return;

    final confirmed = await AppDialog.confirm(
      context,
      title: 'Alterar senha',
      message: 'Enviaremos um link de redefinição para:\n\n$email',
      confirmLabel: 'Enviar',
      icon: Icons.lock_reset_rounded,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(authNotifierProvider.notifier)
          .sendPasswordResetEmail(email: email);
      if (context.mounted && !ref.read(authNotifierProvider).hasError) {
        AppSnackBar.success(
          context,
          'E-mail de redefinição enviado para $email.',
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Excluir conta',
      message: 'Esta ação é irreversível. Todos os seus dados serão '
          'permanentemente excluídos.\n\n'
          'Se fez login há muito tempo, pode ser necessário entrar '
          'novamente antes de excluir.',
      confirmLabel: 'Excluir conta',
      isDestructive: true,
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      // GoRouter redirect cuidará da navegação após logout automático.
    }
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: AppColors.info, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.title,
    required this.children,
    this.titleColor,
  });

  final String title;
  final List<Widget> children;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: titleColor ??
                        Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...children,
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !loading,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: loading ? null : onTap,
    );
  }
}
