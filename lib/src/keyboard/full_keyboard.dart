import 'dart:async';

import 'package:flutter/material.dart';
import 'package:desktop_virtual_keyboard/desktop_virtual_keyboard.dart';

/// Состояние клавиши Shift.
enum ShiftState {
  /// Выключен.
  off,

  /// Одноразовый: сбрасывается после ввода одного символа.
  single,

  /// Caps Lock: включается двойным тапом по Shift.
  locked,
}

class FullKeyboard extends StatefulWidget {
  const FullKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSubmit,
    this.onLeftArrow,
    this.onRightArrow,
    this.layouts,
    this.initialLayoutCode,
    this.onLayoutChanged,
    this.quickKeys = const [],
  });

  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final VoidCallback? onLeftArrow;
  final VoidCallback? onRightArrow;

  /// Раскладки. По умолчанию — [DesktopVirtualKeyboard.layouts].
  final List<KeyboardLayout>? layouts;

  /// Код начальной раскладки. По умолчанию — последняя использованная.
  final String? initialLayoutCode;

  final ValueChanged<KeyboardLayout>? onLayoutChanged;

  /// Дополнительный ряд «быстрых» клавиш, вставляющих строку целиком
  /// (например `['@', '.com', '.uz']` для email-полей).
  final List<String> quickKeys;

  @override
  State<FullKeyboard> createState() => _FullKeyboardState();
}

class _FullKeyboardState extends State<FullKeyboard> {
  /// Последняя выбранная раскладка — живёт, пока живо приложение.
  static String? _sessionLayoutCode;

  VKTheme get t => DesktopVirtualKeyboard.theme;

  late List<KeyboardLayout> _layouts;
  late KeyboardLayout _layout;
  ShiftState _shift = ShiftState.off;
  bool _numberMode = false;
  DateTime? _lastShiftTap;
  Timer? _backspaceRepeat;

  static const List<List<String>> _numberRows = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['@', '#', '\$', '&', '+', '(', ')', '/', '_', '*'],
    ['"', '\'', ':', ';', '!', '?', ',', '.', '='],
  ];

  @override
  void initState() {
    super.initState();
    _layouts = widget.layouts ?? DesktopVirtualKeyboard.layouts;
    if (_layouts.isEmpty) {
      _layouts = const [KeyboardLayout.english];
    }
    final preferredCode = widget.initialLayoutCode ??
        (DesktopVirtualKeyboard.rememberLayout ? _sessionLayoutCode : null);
    _layout = _layouts.firstWhere(
      (l) => l.code == preferredCode,
      orElse: () => _layouts.first,
    );
  }

  @override
  void dispose() {
    _backspaceRepeat?.cancel();
    super.dispose();
  }

  bool get _uppercase => _shift != ShiftState.off && !_numberMode;

  void _emit(String text) {
    widget.onKeyPressed(_uppercase ? text.toUpperCase() : text);
    if (_shift == ShiftState.single) {
      setState(() => _shift = ShiftState.off);
    }
  }

  void _tapShift() {
    final now = DateTime.now();
    final isDoubleTap = _lastShiftTap != null &&
        now.difference(_lastShiftTap!) < const Duration(milliseconds: 350);
    _lastShiftTap = now;
    setState(() {
      switch (_shift) {
        case ShiftState.off:
          _shift = ShiftState.single;
        case ShiftState.single:
          _shift = isDoubleTap ? ShiftState.locked : ShiftState.off;
        case ShiftState.locked:
          _shift = ShiftState.off;
      }
    });
  }

  void _toggleNumberMode() {
    setState(() => _numberMode = !_numberMode);
  }

  void _switchLayout() {
    final index = _layouts.indexOf(_layout);
    setState(() {
      _layout = _layouts[(index + 1) % _layouts.length];
    });
    if (DesktopVirtualKeyboard.rememberLayout) {
      _sessionLayoutCode = _layout.code;
    }
    widget.onLayoutChanged?.call(_layout);
  }

  void _startBackspaceRepeat() {
    widget.onBackspace();
    _backspaceRepeat?.cancel();
    _backspaceRepeat = Timer.periodic(
      const Duration(milliseconds: 70),
      (_) => widget.onBackspace(),
    );
  }

  void _stopBackspaceRepeat() {
    _backspaceRepeat?.cancel();
    _backspaceRepeat = null;
  }

  List<List<String>> get _rows => _numberMode ? _numberRows : _layout.rows;

  double _spanWidth(double span) =>
      t.keyWidth * span + t.keySpacing * (span - 1);

  Widget _keyShell({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    double? width,
  }) {
    return Padding(
      padding: EdgeInsets.all(t.keySpacing / 2),
      child: Material(
        color: backgroundColor ?? t.keyBackground,
        borderRadius: BorderRadius.circular(t.keyBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.keyBorderRadius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox(
            width: width ?? t.keyWidth,
            height: t.keyHeight,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String key) {
    final alt = _numberMode ? null : _layout.longPressAlternatives[key];
    final display = _uppercase ? key.toUpperCase() : key;
    return _keyShell(
      onTap: () => _emit(key),
      onLongPress: alt == null ? null : () => _emit(alt),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (alt != null)
            Text(
              _uppercase ? alt.toUpperCase() : alt,
              style: TextStyle(
                fontSize: t.keyTextSize * 0.55,
                color: t.keySecondaryTextColor,
              ),
            ),
          Text(
            display,
            style: TextStyle(
              fontSize: t.keyTextSize,
              color: t.keyTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftKey() {
    final active = _shift != ShiftState.off;
    return _keyShell(
      onTap: _tapShift,
      backgroundColor: active ? t.keyActiveBackground : null,
      child: Icon(
        _shift == ShiftState.locked
            ? Icons.keyboard_capslock
            : Icons.keyboard_arrow_up,
        color: active ? t.keyActiveTextColor : t.keyTextColor,
      ),
    );
  }

  Widget _buildBackspaceKey() {
    // GestureDetector поверх InkWell: одиночный тап — одно удаление,
    // удержание — автоповтор до отпускания.
    return GestureDetector(
      onLongPressStart: (_) => _startBackspaceRepeat(),
      onLongPressEnd: (_) => _stopBackspaceRepeat(),
      onLongPressCancel: _stopBackspaceRepeat,
      child: _keyShell(
        onTap: widget.onBackspace,
        child: Icon(Icons.backspace_outlined, color: t.keyTextColor),
      ),
    );
  }

  Widget _buildSpecialText(String text, VoidCallback onTap, {double? width}) {
    return _keyShell(
      onTap: onTap,
      width: width,
      child: Text(
        text,
        style: TextStyle(
          color: t.keyTextColor,
          fontSize: t.keyTextSize * 0.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.keyboardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.quickKeys.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final quick in widget.quickKeys)
                  _buildSpecialText(
                    quick,
                    () => widget.onKeyPressed(quick),
                    width: _spanWidth(1.5),
                  ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows[0].map(_buildKey).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows[1].map(_buildKey).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_numberMode) _buildShiftKey(),
              ...rows[2].map(_buildKey),
              _buildBackspaceKey(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_layouts.length > 1)
                _buildSpecialText(_layout.code, _switchLayout),
              _buildSpecialText(
                _numberMode ? 'АБВ' : '123*/',
                _toggleNumberMode,
              ),
              _keyShell(
                onTap: widget.onLeftArrow ?? () {},
                child: Icon(Icons.keyboard_arrow_left, color: t.keyTextColor),
              ),
              _keyShell(
                onTap: widget.onRightArrow ?? () {},
                child: Icon(Icons.keyboard_arrow_right, color: t.keyTextColor),
              ),
              _keyShell(
                onTap: () => widget.onKeyPressed(' '),
                width: _spanWidth(3),
                child: Icon(Icons.space_bar, color: t.keyTextColor),
              ),
              _buildKey('-'),
              _keyShell(
                onTap: widget.onSubmit,
                width: _spanWidth(2),
                backgroundColor: t.submitKeyBackground,
                child: Icon(Icons.keyboard_return, color: t.keyTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
