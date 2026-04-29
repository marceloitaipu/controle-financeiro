// lib/core/widgets/app_loading.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Indicador de carregamento centralizado e consistente.
///
/// Variantes:
/// - [AppLoading] — spinner circular com mensagem opcional
/// - [AppLoading.overlay] — fullscreen semi-transparente
/// - [AppLoading.linear] — barra de progresso linear no topo da tela
/// - [AppLoading.shimmerBox] — retângulo shimmer para skeleton loading
/// - [AppLoading.shimmerList] — lista de skeletons para loading de lista
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            AppSpacing.vLg,
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Overlay fullscreen com fundo semi-transparente.
  static Widget overlay({String? message}) {
    return ColoredBox(
      color: Colors.black26,
      child: AppLoading(message: message),
    );
  }

  /// Barra de progresso linear — use no topo de páginas em carregamento.
  static Widget linear({Color? color}) {
    return Builder(
      builder: (context) => LinearProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  /// Retângulo shimmer — substitua Cards/Containers enquanto carrega.
  ///
  /// Parâmetros:
  /// - [width]: largura (padrão: 100% disponível)
  /// - [height]: altura em pontos
  /// - [borderRadius]: raio da borda (padrão: AppRadius.md)
  static Widget shimmerBox({
    double? width,
    double height = 60,
    BorderRadius? borderRadius,
  }) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Shimmer.fromColors(
          baseColor: cs.surfaceContainerHighest,
          highlightColor: cs.surfaceContainerLow,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: borderRadius ?? AppRadius.cardRadius,
            ),
          ),
        );
      },
    );
  }

  /// Lista de skeletons para carregamento de listas.
  ///
  /// - [itemCount]: número de items placeholder (padrão: 5)
  /// - [itemHeight]: altura de cada item (padrão: 72)
  static Widget shimmerList({
    int itemCount = 5,
    double itemHeight = 72,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? AppSpacing.pageHorizontal,
      child: Column(
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: shimmerBox(height: itemHeight),
          );
        }),
      ),
    );
  }
}

