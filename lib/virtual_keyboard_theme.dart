import 'package:flutter/material.dart';

/// Где показывать виртуальную клавиатуру.
enum VKPlacement {
  /// Плавающее окно рядом с полем, можно перетаскивать.
  floating,

  /// Панель, прижатая к нижнему краю экрана (как системная OSK).
  docked,
}

class VKTheme {
  const VKTheme({
    this.primaryColor = const Color(0xFF1050BA),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.hintColor = const Color(0xFFBDBDBD),
    this.textColor = Colors.black,
    this.borderColor = const Color(0xFFBDBDBD),
    this.errorColor = const Color(0xFFD32F2F),
    this.minHeight = 50,
    this.textSize = 14,
    // ----- клавиатура -----
    this.keyboardBackground = const Color(0xFF1A1B1E),
    this.keyBackground = const Color(0xFF2D2F33),
    this.keyActiveBackground = Colors.white,
    this.keyTextColor = Colors.white70,
    this.keySecondaryTextColor = Colors.white54,
    this.keyActiveTextColor = Colors.black,
    this.submitKeyBackground = const Color(0xFF1565C0),
    this.backspaceKeyBackground = const Color(0xFFC62828),
    this.keyWidth = 56,
    this.keyHeight = 64,
    this.numberKeyWidth = 110,
    this.numberKeyHeight = 60,
    this.keySpacing = 8,
    this.keyTextSize = 20,
    this.keyBorderRadius = 8,
  });

  final Color primaryColor;
  final Color backgroundColor;
  final Color hintColor;
  final Color borderColor;
  final Color textColor;
  final Color errorColor;
  final double minHeight;
  final double textSize;

  /// Фон панели клавиатуры.
  final Color keyboardBackground;

  /// Фон обычной клавиши.
  final Color keyBackground;

  /// Фон активной клавиши (нажатый shift и т.п.).
  final Color keyActiveBackground;

  /// Цвет текста на клавишах.
  final Color keyTextColor;

  /// Цвет вспомогательного текста на клавишах (подсказки long-press).
  final Color keySecondaryTextColor;

  /// Цвет текста на активной клавише.
  final Color keyActiveTextColor;

  /// Фон клавиши подтверждения (Enter).
  final Color submitKeyBackground;

  /// Фон клавиши удаления (Backspace) на цифровой клавиатуре.
  final Color backspaceKeyBackground;

  /// Ширина буквенной клавиши.
  final double keyWidth;

  /// Высота буквенной клавиши.
  final double keyHeight;

  /// Ширина клавиши цифровой клавиатуры.
  final double numberKeyWidth;

  /// Высота клавиши цифровой клавиатуры.
  final double numberKeyHeight;

  /// Расстояние между клавишами.
  final double keySpacing;

  /// Размер текста на клавишах.
  final double keyTextSize;

  /// Скругление клавиш.
  final double keyBorderRadius;
}
