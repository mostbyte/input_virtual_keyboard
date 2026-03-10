import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    this.controller,
    this.name = '',
    this.hint = '',
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.onSubmitted,
    this.maxLength,
    this.onEditingComplete,
    this.initialValue,
    this.inputFormatter,
    this.expands = false,
    required this.nextAction,
    this.autofocus = false,
    this.isRequired = false,
    this.focusNode,
    this.useCustomKeyboard,
    this.icon,
    this.style,
    this.backgroundColor,
    this.borderColor,
    this.hintColor,
    this.textColor,
    this.maxLines = 1,
    this.minLines,
    this.minHeight,
    this.textInputType = TextInputType.text,
    this.borderRadius,
    this.prefixWidget,
    this.prefixBackground,
    this.suffixWidget,
    this.suffixBackground,
    this.suffixIcon,
    this.obsecureText,
    this.obsecureCharacter,
  });
  final TextEditingController? controller;
  final String name;
  final String hint;
  final bool enabled;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Function(String?)? onSubmitted;
  final int? maxLength;
  final VoidCallback? onEditingComplete;
  final String? initialValue;
  final bool nextAction;
  final bool isRequired;
  final bool expands;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;
  final bool? useCustomKeyboard;
  final Widget? icon;
  final bool autofocus;
  final TextStyle? style;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hintColor;
  final Color? textColor;
  final TextInputType textInputType;
  final int? maxLines;
  final int? minLines;
  final double? minHeight;
  final double? borderRadius;
  final Widget? prefixWidget;
  final Color? prefixBackground;
  final Widget? suffixWidget;
  final Color? suffixBackground;
  final Widget? suffixIcon;
  final bool? obsecureText;
  final String? obsecureCharacter;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  late final TextEditingController _ctl =
      widget.controller ?? TextEditingController();
  late bool _obscureText = widget.obsecureText ?? true;

  @override
  void dispose() {
    if (widget.controller == null) _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Input(
      key: widget.key,
      controller: _ctl,
      name: widget.name,
      nextAction: widget.nextAction,
      textInputType: TextInputType.text,
      hint: widget.hint,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
      maxLength: widget.maxLength,
      onEditingComplete: widget.onEditingComplete,
      initialValue: widget.initialValue,
      inputFormatter: widget.inputFormatter,
      autofocus: widget.autofocus,
      isRequired: widget.isRequired,
      focusNode: widget.focusNode,
      useCustomKeyboard: widget.useCustomKeyboard,
      icon: widget.icon,
      style: widget.style,
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      hintColor: widget.hintColor,
      textColor: widget.textColor,
      borderRadius: widget.borderRadius ?? 8.0,
      prefixWidget: widget.prefixWidget,
      prefixBackground: widget.prefixBackground,
      suffixWidget: widget.suffixWidget,
      suffixBackground: widget.suffixBackground,
      obscureText: _obscureText,
      obSecureCharacter: widget.obsecureCharacter,
      suffixIcon: InkWell(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Container(
          width: 18,
          height: 24,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Image.asset(
            _obscureText ? "assets/eye_close.png" : "assets/eye.png",
            color: _obscureText ? const Color(0xff9C9AA5) : const Color(0xff1050BA),
            package: 'input_virtual_keyboard',
          ),
        ),
      ),
    );
  }
}
