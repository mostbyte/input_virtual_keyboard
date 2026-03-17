import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

class DropdownInput<T> extends StatefulWidget {
  final String name;
  final String hint;
  final bool enabled;
  final bool isRequired;
  final List<Map<String, dynamic>> options;
  final dynamic result;
  final Function(dynamic)? onChanged;
  final String? Function(dynamic)? validator;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hintColor;
  final Color? textColor;
  final TextStyle? style;
  final double borderRadius;
  final double? minHeight;
  final Widget? prefixWidget;
  final Color? prefixBackground;
  final Widget? suffixWidget;
  final Color? suffixBackground;
  final Widget? icon;

  const DropdownInput({
    super.key,
    required this.name,
    this.hint = "",
    this.enabled = true,
    this.isRequired = false,
    this.options = const [],
    this.result,
    this.onChanged,
    this.validator,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.hintColor,
    this.textColor,
    this.style,
    this.borderRadius = 8.0,
    this.minHeight,
    this.prefixWidget,
    this.prefixBackground,
    this.suffixWidget,
    this.suffixBackground,
    this.icon,
  });

  @override
  State<DropdownInput<T>> createState() => _DropdownInputState<T>();
}

class _DropdownInputState<T> extends State<DropdownInput<T>> {
  final t = InputVirtualKeyboard.theme;
  bool _hasError = false;
  dynamic _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.result;
  }

  @override
  void didUpdateWidget(covariant DropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != oldWidget.result) {
      _selectedValue = widget.result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          border: _hasError
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
                  color: widget.prefixBackground ?? const Color(0xff1050BA),
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
                    minHeight: widget.minHeight ?? t.minHeight,
                  ),
                  child: Center(
                    child: DropdownButtonFormField<dynamic>(
                      initialValue: _selectedValue,
                      isExpanded: true,
                      icon: widget.icon ??
                          const Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: widget.hintColor ?? t.hintColor,
                          fontSize: t.textSize,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: widget.style ??
                          TextStyle(
                            color: widget.textColor ?? t.textColor,
                            fontSize: t.textSize,
                          ),
                      onTap: widget.onTap,
                      items: widget.options.map((option) {
                        return DropdownMenuItem<dynamic>(
                          value: option["index"],
                          child: Text(option["value"].toString()),
                        );
                      }).toList(),
                      onChanged: widget.enabled
                          ? (value) {
                              setState(() => _selectedValue = value);
                              widget.onChanged?.call(value);
                            }
                          : null,
                      validator: (value) {
                        String? error;
                        if (widget.isRequired && value == null) {
                          error = 'Обязательное поле';
                        }
                        error ??= widget.validator?.call(value);
                        final showError = error != null;
                        if (showError != _hasError) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _hasError = showError);
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
            if (widget.suffixWidget != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(widget.borderRadius),
                    bottomRight: Radius.circular(widget.borderRadius),
                  ),
                  color: widget.suffixBackground ?? const Color(0xff1050BA),
                ),
                alignment: Alignment.center,
                height: widget.minHeight ?? t.minHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: widget.suffixWidget,
              ),
          ],
        ),
      ),
    );
  }
}
