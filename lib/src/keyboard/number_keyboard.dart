import 'dart:math';

import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

class NumberKeyboard extends StatefulWidget {
  const NumberKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSubmit,
    this.decimalSeparator,
    this.showDecimal = true,
    this.showDoubleZero = true,
    this.phoneMode = false,
    this.shuffleDigits = false,
  });

  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  /// Десятичный разделитель. По умолчанию — из [InputVirtualKeyboard].
  final String? decimalSeparator;

  /// Показывать клавишу десятичного разделителя.
  final bool showDecimal;

  /// Показывать клавишу «00» (удобно для денежных сумм).
  final bool showDoubleZero;

  /// Режим телефона: вместо «00» и разделителя — клавиша «+».
  final bool phoneMode;

  /// Перемешивать цифры при каждом открытии (для PIN-кодов).
  final bool shuffleDigits;

  @override
  State<NumberKeyboard> createState() => _NumberKeyboardState();
}

class _NumberKeyboardState extends State<NumberKeyboard> {
  VKTheme get t => InputVirtualKeyboard.theme;

  late final List<String> _digits;

  @override
  void initState() {
    super.initState();
    _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    if (widget.shuffleDigits) {
      _digits.shuffle(Random());
    }
  }

  String get _separator =>
      widget.decimalSeparator ?? InputVirtualKeyboard.decimalSeparator;

  Widget _buildKey(String text, {Color? backgroundColor, Color? textColor}) {
    return Padding(
      padding: EdgeInsets.all(t.keySpacing / 2),
      child: Material(
        color: backgroundColor ?? t.keyBackground,
        borderRadius: BorderRadius.circular(t.keyBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.keyBorderRadius),
          onTap: () => widget.onKeyPressed(text),
          child: SizedBox(
            width: t.numberKeyWidth,
            height: t.numberKeyHeight,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: t.keyTextSize * 1.2,
                  color: textColor ?? t.keyTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required Widget child,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: EdgeInsets.all(t.keySpacing / 2),
      child: Material(
        color: backgroundColor ?? t.keyBackground,
        borderRadius: BorderRadius.circular(t.keyBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.keyBorderRadius),
          onTap: onTap,
          child: SizedBox(
            width: t.numberKeyWidth,
            height: t.numberKeyHeight,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _blank() {
    return Padding(
      padding: EdgeInsets.all(t.keySpacing / 2),
      child: SizedBox(width: t.numberKeyWidth, height: t.numberKeyHeight),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 4-я колонка: backspace / доп. клавиша / разделитель / enter.
    final Widget extraKey;
    if (widget.phoneMode) {
      extraKey = _buildKey('+');
    } else if (widget.showDoubleZero) {
      extraKey = _buildKey('00');
    } else {
      extraKey = _blank();
    }

    final Widget separatorKey = (!widget.phoneMode && widget.showDecimal)
        ? _buildKey(_separator)
        : _blank();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.keyboardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKey(_digits[0]),
              _buildKey(_digits[1]),
              _buildKey(_digits[2]),
              _buildSpecialKey(
                backgroundColor: t.backspaceKeyBackground,
                onTap: widget.onBackspace,
                child: Icon(Icons.backspace_outlined, color: t.keyTextColor),
              ),
            ],
          ),
          Row(
            children: [
              _buildKey(_digits[3]),
              _buildKey(_digits[4]),
              _buildKey(_digits[5]),
              extraKey,
            ],
          ),
          Row(
            children: [
              _buildKey(_digits[6]),
              _buildKey(_digits[7]),
              _buildKey(_digits[8]),
              separatorKey,
            ],
          ),
          Row(
            children: [
              _blank(),
              _buildKey(_digits[9]),
              _blank(),
              _buildSpecialKey(
                backgroundColor: t.submitKeyBackground,
                onTap: widget.onSubmit,
                child: Icon(Icons.keyboard_return, color: t.keyTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
