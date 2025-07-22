import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class TextAreaInput extends Input {
  TextAreaInput({
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
    bool isRequired = false,
    FocusNode? focusNode,
    bool useCustomKeyboard = true,
    super.icon,
    super.style,
    super.backgroundColor,
    super.borderColor,
    super.hintColor,
    super.textColor,
    super.textInputType = TextInputType.multiline,
    super.maxLines,
    super.minLines,
    super.expands,
    super.minHeight,
  });
}
