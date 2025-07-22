import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/src/inputs/input.dart';

class SearchInput extends StatefulWidget {
  SearchInput({
    Key? key,
    this.controller,
    this.name = '',
    this.hint = '',
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.onSubmitted,
    this.maxLength,
    this.onEditingComplete,
    this.initialValue,
    this.inputFormatter,
    this.expands = false,
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
    this.maxLines = 1,
    this.minLines,
    this.minHeight,
    this.textInputType = TextInputType.text,
    this.borderRadius,
    this.prefixWidget,
    this.prefixBackground,
    this.suffixWidget,
    this.suffixBackground,
    this.suffixIcon,
  }) : super(key: key);
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
  final bool isRequired;
  final bool expands;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;
  final bool useCustomKeyboard;
  final Widget? icon;
  final bool autofocus;
  final TextStyle? style;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hintColor;
  final Color? textColor;
  final TextInputType textInputType;
  final int? maxLines;
  final int? minLines;
  final double? minHeight;
  final double? borderRadius;
  final Widget? prefixWidget;
  final Color? prefixBackground;
  final Widget? suffixWidget;
  final Color? suffixBackground;
  final Widget? suffixIcon;

  @override
  State<SearchInput> createState() => _SearchInputState();
  //  : super(
  //           key: key,
  //           controller: controller,
  //           name: name,
  //           hint: hint,
  //           enabled: enabled,
  //           onChanged: onChanged,
  //           validator: validator,
  //           onSubmitted: onSubmitted,
  //           maxLength: maxLength,
  //           onEditingComplete: onEditingComplete,
  //           initialValue: initialValue,
  //           inputFormatter: inputFormatter,
  //           nextAction: nextAction,
  //           autofocus: autofocus,
  //           isRequired: isRequired,
  //           focusNode: focusNode,
  //           useCustomKeyboard: useCustomKeyboard,
  //           icon: icon,
  //           style: style,
  //           backgroundColor: backgroundColor,
  //           borderColor: borderColor,
  //           hintColor: hintColor,
  //           textColor: textColor,
  //           textInputType: textInputType,
  //           borderRadius: borderRadius ?? 8.0,
  //           prefixWidget: prefixWidget,
  //           prefixBackground: prefixBackground,
  //           suffixWidget: suffixWidget,
  //           suffixBackground: suffixBackground,

  //           /// если null — подставляем дефолтный луп
  //           suffixIcon: suffixIcon ??
  //               ValueListenableBuilder<TextEditingValue>(
  //                   valueListenable: controller ?? TextEditingController(),
  //                   builder: (context, value, _) {
  //                     final bool empty = value.text.isEmpty;
  //                     if (empty) {
  //                       return Container(
  //                         width: 24,
  //                         height: 24,
  //                         decoration: BoxDecoration(
  //                             color: Color(0xff1050BA),
  //                             borderRadius: BorderRadius.circular(6)),
  //                         child: Image.asset(
  //                           "assets/search.png",
  //                           package: 'input_virtual_keyboard',
  //                           width: 9,
  //                           height: 9,
  //                         ),
  //                       );
  //                     }
  //                     return Container(
  //                       width: 24,
  //                       height: 24,
  //                       decoration: BoxDecoration(
  //                           color: Color(0xffBA1010),
  //                           borderRadius: BorderRadius.circular(6)),
  //                       child: Image.asset(
  //                         "assets/close.png",
  //                         package: 'input_virtual_keyboard',
  //                         width: 9,
  //                         height: 9,
  //                       ),
  //                     );
  //                   }));
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _ctl =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Input(
      key: widget.key,
      controller: _ctl,
      name: widget.name,
      nextAction: widget.nextAction,
      textInputType: TextInputType.text,
      hint: widget.hint,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
      maxLength: widget.maxLength,
      onEditingComplete: widget.onEditingComplete,
      initialValue: widget.initialValue,
      inputFormatter: widget.inputFormatter,
      autofocus: widget.autofocus,
      isRequired: widget.isRequired,
      focusNode: widget.focusNode,
      useCustomKeyboard: widget.useCustomKeyboard,
      icon: widget.icon,
      style: widget.style,
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      hintColor: widget.hintColor,
      textColor: widget.textColor,
      borderRadius: widget.borderRadius ?? 8.0,
      prefixWidget: widget.prefixWidget,
      prefixBackground: widget.prefixBackground,
      suffixWidget: widget.suffixWidget,
      suffixBackground: widget.suffixBackground,

      // ---------- динамический suffixIcon ----------
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _ctl, // слушаем тот же объект
        builder: (context, value, _) {
          final bool empty = value.text.isEmpty;
          if (empty) {
            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  color: Color(0xff1050BA),
                  borderRadius: BorderRadius.circular(6)),
              child: Image.asset(
                "assets/search.png",
                package: 'input_virtual_keyboard',
                width: 9,
                height: 9,
              ),
            );
          }
          return InkWell(
            onTap: () => _ctl.clear(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  color: Color(0xffBA1010),
                  borderRadius: BorderRadius.circular(6)),
              child: Image.asset(
                "assets/close.png",
                package: 'input_virtual_keyboard',
                width: 9,
                height: 9,
              ),
            ),
          );
        },
      ),
      // …остальные параметры super-класса Input…
    );
  }
}
