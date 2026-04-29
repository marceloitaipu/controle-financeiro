// lib/core/widgets/app_bottom_sheet.dart

import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Helper e widget para bottom sheets padronizados.
///
/// Uso simples:
/// ```dart
/// AppBottomSheet.show(
///   context,
///   title: 'Filtrar por',
///   child: FilterContent(),
/// );
/// ```
///
/// Uso com builder (scroll interno):
/// ```dart
/// AppBottomSheet.show(
///   context,
///   title: 'Selecionar conta',
///   isScrollControlled: true,
///   child: AccountListContent(),
/// );
/// ```
abstract final class AppBottomSheet {
  /// Exibe um bottom sheet padronizado com drag handle, título e conteúdo.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (context) => AppBottomSheetContent(
        title: title,
        padding: padding,
        child: child,
      ),
    );
  }

  /// Bottom sheet com lista de opções (menu de ações).
  static Future<T?> showMenu<T>(
    BuildContext context, {
    String? title,
    required List<AppBottomSheetOption<T>> options,
  }) {
    return show<T>(
      context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (option) => ListTile(
                leading: option.icon != null
                    ? Icon(
                        option.icon,
                        color: option.isDestructive
                            ? Theme.of(context).colorScheme.error
                            : null,
                      )
                    : null,
                title: Text(
                  option.label,
                  style: option.isDestructive
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        )
                      : null,
                ),
                subtitle: option.subtitle != null
                    ? Text(option.subtitle!)
                    : null,
                onTap: () => Navigator.of(context).pop(option.value),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Widget de conteúdo padrão para bottom sheets.
/// Inclui drag handle, título opcional e padding configurável.
class AppBottomSheetContent extends StatelessWidget {
  const AppBottomSheetContent({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  final String? title;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Drag handle ──────────────────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
          ),
        ),

        // ── Título opcional ──────────────────────────────────────────────
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ] else
          AppSpacing.vSm,

        // ── Conteúdo ─────────────────────────────────────────────────────
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }
}

/// Opção de item para [AppBottomSheet.showMenu].
class AppBottomSheetOption<T> {
  const AppBottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.subtitle,
    this.isDestructive = false,
  });

  final String label;
  final T value;
  final IconData? icon;
  final String? subtitle;
  final bool isDestructive;
}
