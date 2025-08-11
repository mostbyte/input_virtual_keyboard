import 'dart:ui';

import 'package:flutter/material.dart';

class VKTheme {
  const VKTheme({
    this.primaryColor = const Color(0xFF1050BA),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.hintColor = const Color(0xFFBDBDBD),
    this.textColor = Colors.black,
    this.borderColor = const Color(0xFFBDBDBD),
    this.minHeight = 50,
    this.textSize = 14,
  });

  final Color primaryColor;
  final Color backgroundColor;
  final Color hintColor;
  final Color borderColor;
  final Color textColor;
  final double minHeight;
  final double textSize;
}
