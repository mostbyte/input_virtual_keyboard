import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desktop_virtual_keyboard/desktop_virtual_keyboard.dart';

class Input extends StatefulWidget {
  final TextEditingController? controller;
  final String name;
  final String hint;
  final bool enabled;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Function(String?)? onSubmitted;
  final int? maxLength;
  final VoidCallback? onEditingComplete;
  final String? initialValue;
  final bool nextAction;
  final bool autofocus;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;
  final bool? useCustomKeyboard;

  /// Открывать клавиатуру автоматически при фокусе.
  /// null — глобальная настройка [DesktopVirtualKeyboard.autoShowOnFocus].
  final bool? autoShowKeyboard;
  final Widget? icon;
  final TextStyle? style;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hintColor;
  final Color? textColor;
  final TextInputType textInputType;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final double? minHeight;
  final double borderRadius;
  final Widget? prefixWidget;
  final Color? prefixBackground;
  final Widget? suffixWidget;
  final Color? suffixBackground;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? obscureCharacter;

  /// Встроенная кнопка «глаз» для показа/скрытия пароля.
  final bool showPasswordToggle;

  /// Встроенный суффикс поиска: лупа, а при непустом тексте — кнопка очистки.
  final bool showSearchAffix;

  /// Перемешивать цифры на цифровой клавиатуре (PIN-режим).
  final bool shufflePinDigits;

  const Input({
    super.key,
    this.controller,
    this.enabled = true,
    this.name = "",
    this.hint = "",
    this.onChanged,
    this.validator,
    this.maxLength,
    this.onSubmitted,
    this.onEditingComplete,
    this.initialValue,
    this.inputFormatter,
    this.nextAction = false,
    this.autofocus = false,
    this.isRequired = false,
    this.focusNode,
    this.useCustomKeyboard,
    this.autoShowKeyboard,
    this.icon,
    this.style,
    this.backgroundColor,
    this.borderColor,
    this.hintColor,
    this.textColor,
    required this.textInputType,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.minHeight,
    this.borderRadius = 8.0,
    this.prefixWidget,
    this.prefixBackground,
    this.suffixWidget,
    this.suffixBackground,
    this.suffixIcon,
    this.obscureText = false,
    this.obscureCharacter,
    this.showPasswordToggle = false,
    this.showSearchAffix = false,
    this.shufflePinDigits = false,
  }) : assert(
          controller == null || initialValue == null,
          'Передайте либо controller, либо initialValue — не оба сразу',
        );

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  VKTheme get t => DesktopVirtualKeyboard.theme;
  late final TextEditingController _controller = widget.controller ??
      TextEditingController(text: widget.initialValue);
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _isKeyboardVisible = false;
  String? _errorText;
  late bool _obscured = widget.obscureText;
  final GlobalKey _keyboardButtonKey = GlobalKey();
  String _lastEmitted = '';
  late bool _useCustomKeyboard;

  bool get _autoShow =>
      widget.autoShowKeyboard ?? DesktopVirtualKeyboard.autoShowOnFocus;

  List<TextInputFormatter> get _effectiveFormatters => [
        if (widget.maxLength != null)
          LengthLimitingTextInputFormatter(widget.maxLength),
        ...?widget.inputFormatter,
      ];

  @override
  void initState() {
    super.initState();
    // На мобильных платформах всегда используем системную клавиатуру.
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      _useCustomKeyboard = false;
    } else {
      _useCustomKeyboard =
          widget.useCustomKeyboard ?? DesktopVirtualKeyboard.useCustomKeyboard;
    }

    _focusNode.addListener(_handleFocusChange);
    _lastEmitted = _controller.text;
    _controller.addListener(_emitIfChanged);
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_emitIfChanged);
    KeyboardOverlay.hideIfOwner(this);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (_autoShow &&
          _useCustomKeyboard &&
          widget.enabled &&
          !_isKeyboardVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _focusNode.hasFocus && !_isKeyboardVisible) {
            _showKeyboard();
          }
        });
      }
    } else {
      KeyboardOverlay.hideIfOwner(this);
    }
  }

  void _handleSubmit() {
    widget.onSubmitted?.call(_controller.text);
    widget.onEditingComplete?.call();
    KeyboardOverlay.hideIfOwner(this);
    if (widget.nextAction) {
      FocusScope.of(context).nextFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _emitIfChanged() {
    final text = _controller.text;
    if (text != _lastEmitted) {
      _lastEmitted = text;
      widget.onChanged?.call(text);
    }
  }

  void _onKeyboardVisibilityChanged(bool visible) {
    if (mounted) {
      setState(() => _isKeyboardVisible = visible);
    } else {
      _isKeyboardVisible = visible;
    }
  }

  void _showKeyboard() {
    KeyboardOverlay.showKeyboard(
      context,
      owner: this,
      inputType: widget.textInputType,
      controller: _controller,
      focusNode: _focusNode,
      formatters: _effectiveFormatters,
      anchorKey: _keyboardButtonKey,
      onSubmit: _handleSubmit,
      shuffleDigits: widget.shufflePinDigits,
      onVisibilityChanged: _onKeyboardVisibilityChanged,
    );
  }

  void _toggleKeyboard() {
    KeyboardOverlay.toggleKeyboard(
      context,
      owner: this,
      inputType: widget.textInputType,
      controller: _controller,
      focusNode: _focusNode,
      formatters: _effectiveFormatters,
      anchorKey: _keyboardButtonKey,
      onSubmit: _handleSubmit,
      shuffleDigits: widget.shufflePinDigits,
      onVisibilityChanged: _onKeyboardVisibilityChanged,
    );
  }

  Widget _buildPasswordToggle() {
    return InkWell(
      onTap: () => setState(() => _obscured = !_obscured),
      child: SizedBox(
        width: 18,
        height: 24,
        child: Image.asset(
          _obscured ? "assets/eye_close.png" : "assets/eye.png",
          color: _obscured ? const Color(0xff9C9AA5) : t.primaryColor,
          package: 'desktop_virtual_keyboard',
        ),
      ),
    );
  }

  Widget _buildSearchAffix() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: t.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Image.asset(
              "assets/search.png",
              package: 'desktop_virtual_keyboard',
              width: 9,
              height: 9,
            ),
          );
        }
        return InkWell(
          onTap: () {
            _controller.clear();
            widget.onSubmitted?.call('');
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xffBA1010),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Image.asset(
              "assets/close.png",
              package: 'desktop_virtual_keyboard',
              width: 9,
              height: 9,
            ),
          ),
        );
      },
    );
  }

  Widget? get _effectiveSuffixIcon {
    if (widget.showPasswordToggle) return _buildPasswordToggle();
    if (widget.showSearchAffix) return _buildSearchAffix();
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final suffixIcon = _effectiveSuffixIcon;
    final hasError = _errorText != null;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_useCustomKeyboard)
                SizedBox(
                  width: 30,
                  child: Row(
                    children: [
                      if (widget.icon != null) widget.icon!,
                      GestureDetector(
                        key: _keyboardButtonKey,
                        onTap: widget.enabled ? _toggleKeyboard : null,
                        child: Image.asset(
                          _isKeyboardVisible
                              ? "assets/active_keyboard.png"
                              : "assets/passive_keyboard.png",
                          package: 'desktop_virtual_keyboard',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: hasError
                        ? Border.all(color: t.errorColor)
                        : Border.all(
                            width: 0,
                            color: widget.borderColor ?? t.borderColor,
                          ),
                    color: widget.backgroundColor ?? t.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixWidget != null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(widget.borderRadius),
                              bottomLeft: Radius.circular(widget.borderRadius),
                            ),
                            color: widget.prefixBackground ?? t.primaryColor,
                          ),
                          alignment: Alignment.center,
                          height: widget.minHeight ?? t.minHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: widget.prefixWidget,
                        ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: widget.textInputType ==
                                      TextInputType.multiline
                                  ? 200
                                  : widget.minHeight ?? t.minHeight,
                              minHeight: widget.minHeight ?? t.minHeight,
                            ),
                            child: Center(
                              child: TextFormField(
                                enabled: widget.enabled,
                                autofocus: widget.autofocus,
                                obscuringCharacter:
                                    widget.obscureCharacter ?? '•',
                                obscureText: _obscured,
                                onFieldSubmitted: (_) => _handleSubmit(),
                                onEditingComplete: () => _handleSubmit(),
                                style: widget.style ??
                                    TextStyle(
                                      color: widget.textColor ?? t.textColor,
                                      fontSize: t.textSize,
                                    ),
                                key: ValueKey(widget.name),
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: widget.textInputType,
                                maxLines:
                                    widget.expands ? null : widget.maxLines,
                                minLines:
                                    widget.expands ? null : widget.minLines,
                                textAlignVertical: TextAlignVertical.top,
                                inputFormatters: _effectiveFormatters,
                                expands: widget.expands,
                                textInputAction: widget.nextAction
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: widget.hint,
                                  hintStyle: TextStyle(
                                    color: widget.hintColor ?? t.hintColor,
                                    fontSize: t.textSize,
                                  ),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  // Текст ошибки рисуем сами под полем —
                                  // встроенный клипается из-за isCollapsed.
                                  errorStyle: const TextStyle(
                                    fontSize: 0.01,
                                    height: 0.01,
                                    color: Colors.transparent,
                                  ),
                                ),
                                validator: (v) {
                                  String? error;
                                  if (widget.isRequired &&
                                      (v == null || v.isEmpty)) {
                                    error = 'Обязательное поле';
                                  }
                                  error ??= widget.validator?.call(v);
                                  if (error != _errorText) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        setState(() => _errorText = error);
                                      }
                                    });
                                  }
                                  return error;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (suffixIcon != null)
                        Container(
                          alignment: Alignment.center,
                          height: widget.minHeight ?? t.minHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: suffixIcon,
                        ),
                      if (widget.suffixWidget != null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(widget.borderRadius),
                              bottomRight:
                                  Radius.circular(widget.borderRadius),
                            ),
                            color: widget.suffixBackground ?? t.primaryColor,
                          ),
                          alignment: Alignment.center,
                          height: widget.minHeight ?? t.minHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: widget.suffixWidget,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: _useCustomKeyboard ? 30 : 0,
              ),
              child: Text(
                _errorText!,
                style: TextStyle(color: t.errorColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
