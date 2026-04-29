// lib/features/settings/presentation/pages/profile_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Tela de perfil do usuário.
///
/// Permite editar o nome de exibição, visualizar o e-mail (somente leitura)
/// e fazer logout. A atualização de foto de perfil será implementada
/// em uma etapa futura.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final original = ref.read(currentUserProvider)?.displayName ?? '';
    final changed = _nameController.text.trim() != original.trim();
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => AppSnackBar.error(
          context,
          e is Failure ? e.message : 'Erro ao atualizar perfil.',
        ),
      );
    });

    final user = ref.watch(currentUserProvider);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          TextButton(
            onPressed: (_hasChanges && !isLoading) ? _save : null,
            child: const Text('Salvar'),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                _ProfileAvatar(
                  photoUrl: user?.photoUrl,
                  initials: user?.initials ?? '??',
                  radius: 52,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Atualização de foto disponível em breve.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl2),

          // ── Formulário ────────────────────────────────────────────────────
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Nome completo',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.required('Nome'),
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'E-mail',
                  initialValue: user?.email ?? '',
                  prefixIcon: Icons.email_outlined,
                  readOnly: true,
                  enabled: false,
                  showClearButton: false,
                ),
              ],
            ),
          ),

          // ── Botão salvar (quando há alterações) ───────────────────────────
          if (_hasChanges) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: isLoading ? null : _save,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Salvar alterações'),
            ),
          ],

          // ── Logout ────────────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.xl3),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: isLoading ? null : _confirmLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta'),
          ),
          const SizedBox(height: AppSpacing.xl3),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: _nameController.text.trim(),
        );
    if (mounted && !ref.read(authNotifierProvider).hasError) {
      setState(() => _hasChanges = false);
      AppSnackBar.success(context, 'Perfil atualizado com sucesso!');
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Sair da conta',
      message: 'Deseja realmente encerrar a sessão?',
      confirmLabel: 'Sair',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

/// Avatar circular com foto (CachedNetworkImage) ou iniciais como fallback.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.initials,
    required this.radius,
  });

  final String? photoUrl;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diameter = radius * 2;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsCircle(theme),
          errorWidget: (_, __, ___) => _initialsCircle(theme),
        ),
      );
    }
    return _initialsCircle(theme);
  }

  Widget _initialsCircle(ThemeData theme) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.52,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
