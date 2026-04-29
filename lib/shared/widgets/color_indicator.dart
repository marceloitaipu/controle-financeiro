// lib/shared/widgets/color_indicator.dart

import 'package:flutter/material.dart';

/// Círculo colorido para indicar cor de categorias e contas.
///
/// Uso:
/// ```dart
/// ColorIndicator(color: AppColors.categoryColors[3])
/// ColorIndicator(color: Colors.blue, size: 20)
/// ColorIndicator.withBorder(color: Colors.red, isSelected: true)
/// ```
class ColorIndicator extends StatelessWidget {
  const ColorIndicator({
    super.key,
    required this.color,
    this.size = 16,
    this.showBorder = false,
    this.isSelected = false,
  });

  final Color color;
  final double size;
  final bool showBorder;
  final bool isSelected;

  /// Variante com anel de seleção.
  const ColorIndicator.withBorder({
    super.key,
    required this.color,
    this.size = 28,
    this.isSelected = false,
  }) : showBorder = true;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (!showBorder) return circle;

    // Anel de seleção
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size + (isSelected ? 8 : 4),
      height: size + (isSelected ? 8 : 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: Center(child: circle),
    );
  }
}
