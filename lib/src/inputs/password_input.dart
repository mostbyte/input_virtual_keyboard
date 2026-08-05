import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class PasswordInput extends Input {
  PasswordInput({
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
    List<TextInputFormatter>? inputFormatter,
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
    super.obscureCharacter,

    /// PIN-режим: цифровая клавиатура и ввод только цифр.
    bool pinMode = false,

    /// Перемешивать цифры на клавиатуре (защита от подглядывания).
    bool shufflePin = false,
  }) : super(
          textInputType:
              pinMode ? TextInputType.number : TextInputType.text,
          obscureText: true,
          showPasswordToggle: true,
          shufflePinDigits: pinMode && shufflePin,
          inputFormatter: [
            if (pinMode) FilteringTextInputFormatter.digitsOnly,
            ...?inputFormatter,
          ],
        );
}
