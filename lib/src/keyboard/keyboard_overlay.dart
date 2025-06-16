import 'package:flutter/material.dart';
import 'full_keyboard.dart';

class KeyboardOverlay {
  static OverlayEntry? _overlayEntry;
  static Offset _position = Offset.zero;
  static bool _isVisible = false;

  static void toggleKeyboard(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    GlobalKey keyboardButtonKey, {
    bool? show,
  }) {
    if (show ?? !_isVisible) {
      showKeyboard(context, controller, focusNode, keyboardButtonKey);
    } else {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isVisible = false;
      }
    }
  }

  static void showKeyboard(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
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
      buttonPosition.dx - 400,
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
                    elevation: 8,
                    child: FullKeyboard(
                      onKeyPressed: (String text) {
                        final currentText = controller.text;
                        final textSelection = controller.selection;
                        final newText = currentText.replaceRange(
                          textSelection.start,
                          textSelection.end,
                          text,
                        );
                        final myTextLength = text.length;
                        controller.text = newText;
                        controller.selection = textSelection.copyWith(
                          baseOffset: textSelection.start + myTextLength,
                          extentOffset: textSelection.start + myTextLength,
                        );
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

                        final previousCodeUnit =
                            currentText.codeUnitAt(textSelection.start - 1);
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
    // if (_overlayEntry != null) {
    //   _overlayEntry?.remove();
    //   _overlayEntry = null;
    // }
  }

  static bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }
}
