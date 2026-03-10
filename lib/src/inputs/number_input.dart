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
    List<TextInputFormatter>? inputFormatter,
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
    super.prefixWidget,
    super.prefixBackground,
    super.suffixWidget,
    super.suffixBackground,
    super.suffixIcon,
  }) : super(inputFormatter: [
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
          ...?inputFormatter,
        ]);
}
