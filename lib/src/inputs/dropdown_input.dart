import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

/// Типизированный элемент выпадающего списка.
class DropdownEntry<T> {
  const DropdownEntry(this.value, this.label);

  final T value;
  final String label;
}

class DropdownInput<T> extends StatefulWidget {
  final String name;
  final String hint;
  final bool enabled;
  final bool isRequired;

  /// Типизированные элементы списка. Предпочтительный способ.
  final List<DropdownEntry<T>> items;

  /// Устаревший формат: список карт с ключами `index` (значение) и `value`
  /// (подпись). Используется, только если [items] пуст.
  @Deprecated('Используйте items вместо options')
  final List<Map<String, dynamic>> options;

  /// Выбранное значение.
  final T? value;

  /// Устаревшее имя для [value].
  @Deprecated('Используйте value вместо result')
  final dynamic result;

  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
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
    this.name = "",
    this.hint = "",
    this.enabled = true,
    this.isRequired = false,
    this.items = const [],
    @Deprecated('Используйте items вместо options') this.options = const [],
    this.value,
    @Deprecated('Используйте value вместо result') this.result,
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
  VKTheme get t => InputVirtualKeyboard.theme;
  String? _errorText;
  T? _selectedValue;

  List<DropdownEntry<T>> get _effectiveItems {
    if (widget.items.isNotEmpty) return widget.items;
    // ignore: deprecated_member_use_from_same_package
    return widget.options
        .map((o) => DropdownEntry<T>(o["index"] as T, '${o["value"]}'))
        .toList();
  }

  // ignore: deprecated_member_use_from_same_package
  T? get _widgetValue => widget.value ?? widget.result as T?;

  @override
  void initState() {
    super.initState();
    _selectedValue = _widgetValue;
  }

  @override
  void didUpdateWidget(covariant DropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ignore: deprecated_member_use_from_same_package
    final oldValue = oldWidget.value ?? oldWidget.result as T?;
    if (_widgetValue != oldValue) {
      _selectedValue = _widgetValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    final items = _effectiveItems;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: hasError
                  ? Border.all(color: t.errorColor)
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
                        minHeight: widget.minHeight ?? t.minHeight,
                      ),
                      child: Center(
                        child: DropdownButtonFormField<T>(
                          initialValue: _selectedValue,
                          isExpanded: true,
                          icon: widget.icon ?? const Icon(Icons.arrow_drop_down),
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            hintStyle: TextStyle(
                              color: widget.hintColor ?? t.hintColor,
                              fontSize: t.textSize,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            errorStyle: const TextStyle(
                              fontSize: 0.01,
                              height: 0.01,
                              color: Colors.transparent,
                            ),
                          ),
                          style: widget.style ??
                              TextStyle(
                                color: widget.textColor ?? t.textColor,
                                fontSize: t.textSize,
                              ),
                          onTap: widget.onTap,
                          items: items
                              .map((entry) => DropdownMenuItem<T>(
                                    value: entry.value,
                                    child: Text(entry.label),
                                  ))
                              .toList(),
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
                if (widget.suffixWidget != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(widget.borderRadius),
                        bottomRight: Radius.circular(widget.borderRadius),
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
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
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
