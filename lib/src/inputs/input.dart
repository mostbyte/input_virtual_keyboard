import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';
import 'package:input_virtual_keyboard/src/keyboard/keyboard_overlay.dart';

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
  bool useCustomKeyboard;
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
  final String? obSecureCharacter;

  Input(
      {Key? key,
      this.controller,
      this.enabled = true,
      required this.name,
      this.hint = "",
      this.onChanged,
      this.validator,
      this.maxLength,
      this.onSubmitted,
      this.onEditingComplete,
      this.initialValue,
      this.inputFormatter,
      required this.nextAction,
      this.autofocus = false,
      this.isRequired = false,
      this.focusNode,
      this.useCustomKeyboard = true,
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
      this.obSecureCharacter})
      : super(key: key);

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final t = InputVirtualKeyboard.theme;
  late final TextEditingController _controller = widget.controller ??
      TextEditingController(
        text: widget.initialValue,
      );
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _isKeyboardVisible = false;
  List<TextInputFormatter> _inputFormatter = [];
  final GlobalKey _keyboardButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      widget.useCustomKeyboard = false;
    }
    KeyboardOverlay.textInputType = widget.textInputType;

    if (widget.inputFormatter != null) {
      _inputFormatter = [...?widget.inputFormatter];
      if (widget.maxLength != null) {
        _inputFormatter.add(LengthLimitingTextInputFormatter(widget.maxLength));
      }
    } else if (widget.maxLength != null) {
      _inputFormatter.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    KeyboardOverlay.hideKeyboard();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      KeyboardOverlay.hideKeyboard();
      setState(() {
        _isKeyboardVisible = false;
      });
    }
  }

  void _toggleKeyboard() {
    setState(() {
      _isKeyboardVisible = !_isKeyboardVisible;
    });
    final formatters = <TextInputFormatter>[
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(widget.maxLength),
      ...?widget.inputFormatter,
    ];
    KeyboardOverlay.textInputType = widget.textInputType;
    KeyboardOverlay.toggleKeyboard(
      context,
      _controller,
      formatters,
      _focusNode,
      _keyboardButtonKey,
      // show: _isKeyboardVisible,
      onVisibilityChanged: (bool visible) {
        // This fires **every** time the overlay shows or hides
        setState(() => _isKeyboardVisible = visible);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      widget.useCustomKeyboard = false;
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (widget.useCustomKeyboard)
              ? SizedBox(
                  width: 30,
                  child: Row(
                    children: [
                      if (widget.icon != null) widget.icon!,
                      GestureDetector(
                        key: _keyboardButtonKey,
                        onTap: () {
                          _toggleKeyboard();
                        },
                        child: Image.asset(
                          _isKeyboardVisible
                              ? "assets/active_keyboard.png"
                              : "assets/passive_keyboard.png",
                          package: 'input_virtual_keyboard',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: (widget.isRequired)
                    ? Border.all(color: Colors.red)
                    : Border.all(
                        width: 0, color: widget.borderColor ?? t.borderColor),
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
                        color: widget.prefixBackground ?? Color(0xff1050BA),
                      ),
                      alignment: Alignment.center,
                      height: widget.minHeight ?? t.minHeight,
                      child: widget.prefixWidget,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                widget.textInputType == TextInputType.multiline
                                    ? 200
                                    : widget.minHeight ?? t.minHeight,
                            minHeight: widget.minHeight ?? t.minHeight),
                        child: Center(
                          child: TextFormField(
                            obscuringCharacter: widget.obSecureCharacter ?? '•',
                            obscureText: widget.obscureText,
                            onFieldSubmitted: widget.onSubmitted,
                            style: widget.style ??
                                TextStyle(
                                  color: widget.textColor ?? t.textColor,
                                  fontSize: t.textSize,
                                ),
                            key: ValueKey(widget.name),
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: widget.textInputType,
                            maxLines: widget.expands ? null : widget.maxLines,
                            minLines: widget.expands ? null : widget.minLines,
                            textAlignVertical: TextAlignVertical.top,
                            inputFormatters: [
                              if (widget.maxLength != null)
                                LengthLimitingTextInputFormatter(
                                    widget.maxLength),
                              ...?widget.inputFormatter,
                            ],
                            expands: widget.expands,
                            // readOnly: widget.useCustomKeyboard, // отключаем системную
                            textInputAction: widget.nextAction
                                ? TextInputAction.next
                                : TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              hintStyle: TextStyle(
                                      color: widget.hintColor ?? t.hintColor)
                                  .copyWith(fontSize: t.textSize),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: widget.onChanged,
                            validator: widget.isRequired
                                ? (v) => (v == null || v.isEmpty)
                                    ? 'Обязательное поле'
                                    : null
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.suffixIcon != null)
                    Container(
                      alignment: Alignment.center,
                      height: widget.minHeight ?? t.minHeight,
                      child: widget.suffixIcon,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  if (widget.suffixWidget != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(widget.borderRadius),
                          bottomRight: Radius.circular(widget.borderRadius),
                        ),
                        color: widget.suffixBackground ?? Color(0xff1050BA),
                      ),
                      alignment: Alignment.center,
                      height: widget.minHeight ?? t.minHeight,
                      child: widget.suffixWidget,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
