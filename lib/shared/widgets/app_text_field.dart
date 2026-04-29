// lib/shared/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto padronizado para formulários do app.
///
/// Encapsula [TextFormField] com visual consistente, botão de limpar,
/// toggle de senha, label e validator integrados.
///
/// Uso:
/// ```dart
/// AppTextField(
///   label: 'E-mail',
///   prefixIcon: AppIcons.email,
///   keyboardType: TextInputType.emailAddress,
///   validator: Validators.email,
/// )
///
/// AppTextField.password(label: 'Senha', validator: Validators.password)
/// AppTextField.search(onChanged: (v) => setState(() => _query = v))
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.autofillHints,
    this.autovalidateMode,
    this.showClearButton = true,
    this.autofocus = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final bool showClearButton;
  final bool autofocus;

  // ── Factories ─────────────────────────────────────────────────────────────

  /// Campo de senha com toggle de visibilidade integrado.
  factory AppTextField.password({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    AutovalidateMode? autovalidateMode,
  }) {
    return _PasswordTextField(
      key: key,
      label: label ?? 'Senha',
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
    );
  }

  /// Campo de busca com ícone de lupa e limpar embutidos.
  factory AppTextField.search({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    return _SearchTextField(
      key: key,
      label: label ?? 'Buscar',
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onClear: onClear,
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  bool _hasText = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _isOwner = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isOwner) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffixWidget = widget.suffixIcon;

    if (suffixWidget == null && widget.showClearButton && _hasText && widget.enabled) {
      suffixWidget = IconButton(
        icon: const Icon(Icons.cancel_rounded),
        iconSize: 20,
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
        tooltip: 'Limpar',
      );
    }

    return TextFormField(
      key: widget.key,
      controller: _controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      autovalidateMode: widget.autovalidateMode,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: suffixWidget,
      ),
    );
  }
}

// ── Implementações de factories ────────────────────────────────────────────────

class _PasswordTextField extends AppTextField {
  const _PasswordTextField({
    super.key,
    super.label = 'Senha',
    super.hint,
    super.controller,
    super.focusNode,
    super.textInputAction,
    super.validator,
    super.onChanged,
    super.onFieldSubmitted,
    super.autovalidateMode,
  }) : super(
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          showClearButton: false,
          autofillHints: const [AutofillHints.password],
        );

  @override
  State<AppTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends _AppTextFieldState {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      autovalidateMode: widget.autovalidateMode,
      obscureText: _isObscured,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          iconSize: 20,
          onPressed: () => setState(() => _isObscured = !_isObscured),
          tooltip: _isObscured ? 'Mostrar senha' : 'Ocultar senha',
        ),
      ),
    );
  }
}

class _SearchTextField extends AppTextField {
  const _SearchTextField({
    super.key,
    super.label = 'Buscar',
    super.hint,
    super.controller,
    super.focusNode,
    super.onChanged,
    this.onClear,
  }) : super(
          prefixIcon: Icons.search_rounded,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          showClearButton: true,
        );

  final VoidCallback? onClear;
}
