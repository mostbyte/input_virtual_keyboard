import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';
import 'package:input_virtual_keyboard/src/utils/phone_masked_input.dart';

class PhoneInput extends Input {
  const PhoneInput({
    super.key,
    super.controller,
    super.name = "",
    super.hint = "",
    super.enabled = true,
    super.onChanged,
    super.validator,
    super.onSubmitted,
    super.maxLength = 12,
    super.onEditingComplete,
    super.initialValue,
    super.inputFormatter = const [PhoneFormatter()],
    required super.nextAction,
    super.autofocus = false,
    super.isRequired,
    super.focusNode,
    super.useCustomKeyboard,
    super.icon,
    super.style,
    super.backgroundColor,
    super.borderColor,
    super.hintColor,
    super.textColor,
    super.maxLines = 1,
    super.minLines,
    super.textInputType = TextInputType.number,
    super.borderRadius,
    super.prefixWidget = const Text(
      "+998",
      style: TextStyle(color: Colors.white),
    ),
    super.prefixBackground,
  });
}
