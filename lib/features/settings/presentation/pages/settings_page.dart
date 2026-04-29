// lib/features/settings/presentation/pages/settings_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Tela central de configuracoes do aplicativo.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final currency = ref.watch(currencyNotifierProvider);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, 'Erro ao sair da conta.'),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: AppSpacing.sm),

          const _SectionLabel('Aparência'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            iconColor: AppColors.seed,
            title: 'Tema do aplicativo',
            subtitle: _themeName(themeMode),
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),

          const _SectionLabel('Preferências'),
          _SettingsTile(
            icon: Icons.attach_money_rounded,
            iconColor: AppColors.income,
            title: 'Moeda',
            subtitle: '${currency.name} (${currency.symbol})',
            onTap: () => _showCurrencyPicker(context, ref, currency),
          ),

          const _SectionLabel('Notificações'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.warning,
            title: 'Notificações e lembretes',
            subtitle: 'Lembretes, alertas de orcamento e metas',
            onTap: () => context.push(AppRoutes.notifications),
          ),

          const _SectionLabel('Segurança'),
          _SettingsTile(
            icon: Icons.security_rounded,
            iconColor: AppColors.info,
            title: 'Segurança',
            subtitle: 'Alterar senha e exclusão de conta',
            onTap: () => context.push(AppRoutes.security),
          ),

          const _SectionLabel('Dados'),
          _SettingsTile(
            icon: Icons.download_outlined,
            iconColor: AppColors.success,
            title: 'Exportar dados',
            subtitle: 'CSV ou PDF do período selecionado',
            onTap: () => context.push(AppRoutes.export),
          ),

          const _SectionLabel('Conta'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            title: 'Sair',
            subtitle: 'Encerrar sessão',
            enabled: !isLoading,
            onTap: () => _confirmLogout(context, ref),
          ),

          const _SectionLabel('Sobre'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.info,
            title: 'Sobre o aplicativo',
            subtitle: AppConstants.appName,
            onTap: () => _showAbout(context),
          ),
          _SettingsTile(
            icon: Icons.tag_rounded,
            iconColor: Theme.of(context).colorScheme.outline,
            title: 'Versão',
            subtitle: AppConstants.appVersion,
            onTap: null,
          ),

          const SizedBox(height: AppSpacing.xl3),
        ],
      ),
    );
  }

  static String _themeName(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Claro',
        ThemeMode.dark => 'Escuro',
        ThemeMode.system => 'Seguir sistema',
      };

  void _showThemePicker(
      BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text(
                'Tema do aplicativo',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(),
            for (final mode in ThemeMode.values)
              ListTile(
                title: Text(_themeName(mode)),
                leading: Icon(
                  mode == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: mode == current
                      ? Theme.of(ctx).colorScheme.primary
                      : null,
                ),
                selected: mode == current,
                onTap: () {
                  ref
                      .read(themeModeNotifierProvider.notifier)
                      .setThemeMode(mode);
                  Navigator.of(ctx).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, CurrencyOption current) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text(
                'Moeda',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(),
            for (final option in CurrencyOption.values)
              ListTile(
                leading: Icon(
                  option == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: option == current
                      ? Theme.of(ctx).colorScheme.primary
                      : null,
                ),
                title: Text(option.name),
                subtitle: Text('${option.code} - ${option.symbol}'),
                selected: option == current,
                onTap: () {
                  ref
                      .read(currencyNotifierProvider.notifier)
                      .setCurrency(option);
                  Navigator.of(ctx).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Sair da conta',
      message: 'Deseja realmente encerrar a sessao?',
      confirmLabel: 'Sair',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.account_balance_wallet_rounded,
        size: 48,
        color: AppColors.seed,
      ),
      children: const [
        SizedBox(height: AppSpacing.sm),
        Text(
          'Controle financeiro pessoal premium. '
          'Desenvolvido com Flutter e Firebase.',
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(AppRoutes.profile),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundImage: (user?.photoUrl != null &&
                          user!.photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: (user?.photoUrl == null ||
                          (user?.photoUrl?.isEmpty ?? true))
                      ? Text(
                          user?.initials ?? '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Usuário',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: onTap,
    );
  }
}
