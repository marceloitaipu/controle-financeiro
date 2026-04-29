// lib/core/extensions/num_extensions.dart

import 'package:flutter/material.dart';

/// Extensions em [num] (int e double) para uso em UI.
///
/// Proporciona atalhos para criar SizedBox, EdgeInsets e BorderRadius.
///
/// Uso:
/// ```dart
/// 16.vSpace   // SizedBox(height: 16)
/// 16.hSpace   // SizedBox(width: 16)
/// 16.allPad   // Padding(all: 16)
/// ```
extension IntSpacingExtension on int {
  /// SizedBox vertical com esta altura.
  SizedBox get vSpace => SizedBox(height: toDouble());

  /// SizedBox horizontal com esta largura.
  SizedBox get hSpace => SizedBox(width: toDouble());

  /// EdgeInsets simétrico horizontal.
  EdgeInsets get hPad => EdgeInsets.symmetric(horizontal: toDouble());

  /// EdgeInsets simétrico vertical.
  EdgeInsets get vPad => EdgeInsets.symmetric(vertical: toDouble());

  /// EdgeInsets em todos os lados.
  EdgeInsets get allPad => EdgeInsets.all(toDouble());

  /// EdgeInsets apenas na direita.
  EdgeInsets get rightPad => EdgeInsets.only(right: toDouble());

  /// EdgeInsets apenas na esquerda.
  EdgeInsets get leftPad => EdgeInsets.only(left: toDouble());

  /// EdgeInsets apenas em cima.
  EdgeInsets get topPad => EdgeInsets.only(top: toDouble());

  /// EdgeInsets apenas embaixo.
  EdgeInsets get bottomPad => EdgeInsets.only(bottom: toDouble());

  /// BorderRadius circular.
  BorderRadius get radius => BorderRadius.circular(toDouble());

  /// Radius circular.
  Radius get radiusValue => Radius.circular(toDouble());
}

extension DoubleSpacingExtension on double {
  /// SizedBox vertical com esta altura.
  SizedBox get vSpace => SizedBox(height: this);

  /// SizedBox horizontal com esta largura.
  SizedBox get hSpace => SizedBox(width: this);

  /// EdgeInsets simétrico horizontal.
  EdgeInsets get hPad => EdgeInsets.symmetric(horizontal: this);

  /// EdgeInsets simétrico vertical.
  EdgeInsets get vPad => EdgeInsets.symmetric(vertical: this);

  /// EdgeInsets em todos os lados.
  EdgeInsets get allPad => EdgeInsets.all(this);

  /// BorderRadius circular.
  BorderRadius get radius => BorderRadius.circular(this);

  /// Radius circular.
  Radius get radiusValue => Radius.circular(this);

  /// Clamp entre 0.0 e 1.0 — útil para progress indicators.
  double get clampedProgress => clamp(0.0, 1.0).toDouble();

  /// Converte para porcentagem formatada: 0.75 → "75%"
  String get toPercentString => '${(this * 100).toStringAsFixed(0)}%';
}
