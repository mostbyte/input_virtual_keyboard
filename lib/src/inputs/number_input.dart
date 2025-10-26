import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class NumberInput extends Input {
  NumberInput({
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
    final List<TextInputFormatter>? inputFormatter,
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
    maxLines = 1,
    minLines = 1,
    super.textInputType = TextInputType.number,
    super.borderRadius,
    super.prefixWidget,
    super.prefixBackground,
    super.suffixWidget,
    super.suffixBackground,
    super.suffixIcon,
  }) : super(inputFormatter: [
          // FilteringTextInputFormatter.digitsOnly,
          FilteringTextInputFormatter.allow(
            RegExp(r'^[0-9.]*$'),
          )
        ]);
}
