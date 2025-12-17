import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class TextInput extends Input {
  TextInput({
    super.key,
    super.controller,
    super.name = "",
    super.hint = "",
    super.enabled = true,
    super.onChanged,
    super.validator,
    super.onSubmitted,
    super.maxLength,
    super.onEditingComplete,
    super.initialValue,
    super.inputFormatter,
    required super.nextAction,
    super.autofocus = false,
    super.isRequired = false,
    super.focusNode,
    super.useCustomKeyboard = true,
    super.icon,
    super.style,
    super.backgroundColor,
    super.borderColor,
    super.hintColor,
    super.textColor,
    super.textInputType = TextInputType.text,
    super.borderRadius,
    super.prefixWidget,
    super.prefixBackground,
    super.suffixWidget,
    super.suffixBackground,
    super.suffixIcon,
  });
}
