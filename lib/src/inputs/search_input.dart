import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class SearchInput extends Input {
  const SearchInput({
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
    super.minHeight,
    super.borderRadius,
    super.prefixWidget,
    super.prefixBackground,
    super.suffixWidget,
    super.suffixBackground,
  }) : super(
          textInputType: TextInputType.text,
          showSearchAffix: true,
        );
}
