import 'package:flutter/material.dart';
import 'package:desktop_virtual_keyboard/src/inputs/input.dart';

class TextAreaInput extends Input {
  const TextAreaInput({
    super.key,
    super.controller,
    super.name,
    super.hint,
    super.enabled,
    super.onChanged,
    super.validator,
    super.onSubmitted,
    super.maxLength,
    super.onEditingComplete,
    super.initialValue,
    super.inputFormatter,
    super.nextAction,
    super.autofocus,
    super.isRequired,
    super.focusNode,
    super.useCustomKeyboard,
    super.autoShowKeyboard,
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
    super.borderRadius,
  });
}
