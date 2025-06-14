import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../keyboard/keyboard_overlay.dart';
import './default_input.dart';

class TextInput extends StatefulWidget {
  final TextEditingController? controller;
  final String name;
  final String hint;
  final bool enabled;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Function(String?)? onSubmitted;
  final int? maxLength;
  final VoidCallback? onEditingComplete;
  final String initialValue;
  final bool nextAction;
  final bool autofocus;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;
  final bool useCustomKeyboard;
  final Widget? icon;

  const TextInput({
    Key? key,
    this.controller,
    this.enabled = true,
    required this.name,
    this.hint = "",
    this.onChanged,
    this.validator,
    this.maxLength,
    this.onSubmitted,
    this.onEditingComplete,
    this.initialValue = "",
    this.inputFormatter,
    required this.nextAction,
    this.autofocus = false,
    this.isRequired = false,
    this.focusNode,
    this.useCustomKeyboard = true,
    this.icon,
  }) : super(key: key);

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isKeyboardVisible = false;
  List<TextInputFormatter> _inputFormatter = [];
  final GlobalKey _keyboardButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.inputFormatter != null) {
      _inputFormatter = widget.inputFormatter!;
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
    if (_isKeyboardVisible) {
      KeyboardOverlay.hideKeyboard();
      _focusNode.unfocus();
      setState(() {
        _isKeyboardVisible = false;
      });
    } else {
      _focusNode.requestFocus();
      KeyboardOverlay.showKeyboard(
          context, _controller, _focusNode, _keyboardButtonKey);
      setState(() {
        _isKeyboardVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultInput(
      isRequired: widget.isRequired,
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              initialValue: null,
              validator: widget.validator,
              textInputAction: widget.nextAction
                  ? TextInputAction.next
                  : TextInputAction.done,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              name: widget.name,
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
              inputFormatters: _inputFormatter,
              keyboardType: widget.useCustomKeyboard
                  ? TextInputType.none
                  : TextInputType.text,
              controller: _controller,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                hintText: widget.hint,
                hintStyle: const TextStyle(fontSize: 14),
              ),
              onTap: widget.useCustomKeyboard ? _toggleKeyboard : null,
            ),
          ),
          if (widget.useCustomKeyboard)
            SizedBox(
              width: 30,
              child: Row(
                children: [
                  if (widget.icon != null) widget.icon!,
                  GestureDetector(
                    key: _keyboardButtonKey,
                    onTap: _toggleKeyboard,
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
            ),
        ],
      ),
    );
  }
}
