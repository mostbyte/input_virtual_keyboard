import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/src/keyboard/number_keyboard.dart';
import 'full_keyboard.dart';

typedef KeyboardVisibilityChanged = void Function(bool isVisible);

class KeyboardOverlay {
  static TextInputType? textInputType;
  static OverlayEntry? _overlayEntry;
  static Offset _position = Offset.zero;
  static bool _isVisible = false;
  static KeyboardVisibilityChanged? _listener; // <<–– store the callback

  static void toggleKeyboard(
    BuildContext context,
    TextEditingController controller,
    List<TextInputFormatter> formatters,
    FocusNode focusNode,
    GlobalKey keyboardButtonKey, {
    required KeyboardVisibilityChanged onVisibilityChanged,
  }) {
    if (_overlayEntry == null) {
      _listener = onVisibilityChanged;
      _listener!(true);
      showKeyboard(
          context, controller, focusNode, formatters, keyboardButtonKey);
    } else {
      hideKeyboard();
    }
  }

  static void showKeyboard(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    List<TextInputFormatter> formatters,
    GlobalKey keyboardButtonKey,
  ) {
    if (_overlayEntry != null) {
      return;
    }

    // Get the keyboard button position
    final RenderBox? renderBox =
        keyboardButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    // Initialize the position
    _position = Offset(
      buttonPosition.dx,
      buttonPosition.dy + renderBox.size.height + 10,
    );

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Transparent overlay to handle taps outside keyboard
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    hideKeyboard();
                    focusNode.unfocus();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Draggable Keyboard
              Positioned(
                left: _position.dx,
                top: _position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    _position += details.delta;
                    _overlayEntry?.markNeedsBuild();
                  },
                  child: Material(
                    elevation: 0,
                    child: Stack(
                      children: [
                        if (textInputType == TextInputType.number ||
                            textInputType == TextInputType.phone)
                          NumberKeyboard(
                            onKeyPressed: (String text) {
                              final current = controller.value;
                              TextSelection sel = controller.selection;

                              // ── 1. make sure the selection is inside current.text ──────────────
                              final bool invalid = sel.start < 0 ||
                                  sel.end < 0 ||
                                  sel.start > current.text.length ||
                                  sel.end > current.text.length;

                              if (invalid) {
                                // place the caret at the end of the string (or at 0 if empty)
                                final int safeOffset = current.text.length;
                                sel =
                                    TextSelection.collapsed(offset: safeOffset);
                              }

                              // ── 2. replace the selected range with the key that was pressed ────
                              final newText = current.text
                                  .replaceRange(sel.start, sel.end, text);

                              controller.value = controller.value.copyWith(
                                text: newText,
                                selection: TextSelection.collapsed(
                                  offset: sel.start + text.length,
                                ),
                                composing: TextRange.empty,
                              );
                              for (final f in formatters) {
                                controller.value = f.formatEditUpdate(
                                    current, controller.value);
                              }
                            },
                            onBackspace: () {
                              final currentText = controller.text;
                              final textSelection = controller.selection;
                              final selectionLength =
                                  textSelection.end - textSelection.start;

                              if (selectionLength > 0) {
                                final newText = currentText.replaceRange(
                                  textSelection.start,
                                  textSelection.end,
                                  '',
                                );
                                controller.text = newText;
                                controller.selection = textSelection.copyWith(
                                  baseOffset: textSelection.start,
                                  extentOffset: textSelection.start,
                                );
                                return;
                              }

                              if (textSelection.start == 0) {
                                return;
                              }

                              final previousCodeUnit = currentText
                                  .codeUnitAt(textSelection.start - 1);
                              final offset =
                                  _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
                              final newText = currentText.replaceRange(
                                textSelection.start - offset,
                                textSelection.start,
                                '',
                              );
                              controller.text = newText;
                              controller.selection = textSelection.copyWith(
                                baseOffset: textSelection.start - offset,
                                extentOffset: textSelection.start - offset,
                              );
                            },
                            onSubmit: () {
                              hideKeyboard();
                              focusNode.unfocus();
                            },
                          ),
                        if (textInputType == TextInputType.text ||
                            textInputType == TextInputType.multiline ||
                            textInputType == TextInputType.emailAddress)
                          FullKeyboard(
                            onKeyPressed: (String text) {
                              final current = controller.value;
                              TextSelection sel = controller.selection;

                              // ── 1. make sure the selection is inside current.text ──────────────
                              final bool invalid = sel.start < 0 ||
                                  sel.end < 0 ||
                                  sel.start > current.text.length ||
                                  sel.end > current.text.length;

                              if (invalid) {
                                // place the caret at the end of the string (or at 0 if empty)
                                final int safeOffset = current.text.length;
                                sel =
                                    TextSelection.collapsed(offset: safeOffset);
                              }

                              // ── 2. replace the selected range with the key that was pressed ────
                              final newText = current.text
                                  .replaceRange(sel.start, sel.end, text);

                              controller.value = controller.value.copyWith(
                                text: newText,
                                selection: TextSelection.collapsed(
                                  offset: sel.start + text.length,
                                ),
                                composing: TextRange.empty,
                              );
                              for (final f in formatters) {
                                controller.value = f.formatEditUpdate(
                                    current, controller.value);
                              }
                            },
                            onBackspace: () {
                              final currentText = controller.text;
                              final textSelection = controller.selection;
                              final selectionLength =
                                  textSelection.end - textSelection.start;

                              if (selectionLength > 0) {
                                final newText = currentText.replaceRange(
                                  textSelection.start,
                                  textSelection.end,
                                  '',
                                );
                                controller.text = newText;
                                controller.selection = textSelection.copyWith(
                                  baseOffset: textSelection.start,
                                  extentOffset: textSelection.start,
                                );
                                return;
                              }

                              if (textSelection.start == 0) {
                                return;
                              }

                              final previousCodeUnit = currentText
                                  .codeUnitAt(textSelection.start - 1);
                              final offset =
                                  _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
                              final newText = currentText.replaceRange(
                                textSelection.start - offset,
                                textSelection.start,
                                '',
                              );
                              controller.text = newText;
                              controller.selection = textSelection.copyWith(
                                baseOffset: textSelection.start - offset,
                                extentOffset: textSelection.start - offset,
                              );
                            },
                            onSubmit: () {
                              hideKeyboard();
                              focusNode.unfocus();
                            },
                            onLeftArrow: () {
                              final textSelection = controller.selection;
                              final newOffset = textSelection.start - 1;
                              if (newOffset >= 0) {
                                controller.selection = textSelection.copyWith(
                                  baseOffset: newOffset,
                                  extentOffset: newOffset,
                                );
                              }
                            },
                            onRightArrow: () {
                              final currentText = controller.text;
                              final textSelection = controller.selection;
                              final newOffset = textSelection.start + 1;
                              if (newOffset <= currentText.length) {
                                controller.selection = textSelection.copyWith(
                                  baseOffset: newOffset,
                                  extentOffset: newOffset,
                                );
                              }
                            },
                          ),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => hideKeyboard(),
                              child: Container(
                                alignment: Alignment.center,
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.blue,
                                    ),
                                    color: Colors.white),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  weight: 20,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState?.insert(_overlayEntry!);
  }

  static void hideKeyboard() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      _listener?.call(_isVisible); // 🔔 notify: now hidden
      _listener = null;
    }
  }

  static bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }
}
