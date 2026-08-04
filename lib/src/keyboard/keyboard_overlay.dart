import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

typedef KeyboardVisibilityChanged = void Function(bool isVisible);

/// Менеджер оверлея виртуальной клавиатуры.
///
/// Одновременно может быть открыта только одна клавиатура. Каждая клавиатура
/// принадлежит конкретному полю (`owner`), поэтому переключение между полями
/// корректно закрывает старую и открывает новую с уведомлением обоих полей.
class KeyboardOverlay {
  KeyboardOverlay._();

  static OverlayEntry? _overlayEntry;
  static Object? _owner;
  static KeyboardVisibilityChanged? _listener;

  /// Позиция, куда пользователь перетащил клавиатуру (живёт до конца сессии).
  static Offset? _savedPosition;

  static final GlobalKey<_KeyboardShellState> _shellKey = GlobalKey();

  static bool get isVisible => _overlayEntry != null;

  /// Открыть/закрыть клавиатуру по кнопке поля.
  static void toggleKeyboard(
    BuildContext context, {
    required Object owner,
    required TextInputType inputType,
    required TextEditingController controller,
    required FocusNode focusNode,
    required KeyboardVisibilityChanged onVisibilityChanged,
    List<TextInputFormatter> formatters = const [],
    GlobalKey? anchorKey,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmit,
    bool shuffleDigits = false,
  }) {
    if (_overlayEntry != null && identical(_owner, owner)) {
      hideKeyboard();
      return;
    }
    showKeyboard(
      context,
      owner: owner,
      inputType: inputType,
      controller: controller,
      focusNode: focusNode,
      onVisibilityChanged: onVisibilityChanged,
      formatters: formatters,
      anchorKey: anchorKey,
      onChanged: onChanged,
      onSubmit: onSubmit,
      shuffleDigits: shuffleDigits,
    );
  }

  static void showKeyboard(
    BuildContext context, {
    required Object owner,
    required TextInputType inputType,
    required TextEditingController controller,
    required FocusNode focusNode,
    required KeyboardVisibilityChanged onVisibilityChanged,
    List<TextInputFormatter> formatters = const [],
    GlobalKey? anchorKey,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmit,
    bool shuffleDigits = false,
  }) {
    if (_overlayEntry != null) {
      // Переключение с другого поля: старую убираем сразу, без анимации.
      _removeNow();
    }

    final overlayState = Overlay.of(context);

    Offset anchorOffset = Offset.zero;
    Size anchorSize = Size.zero;
    final renderBox =
        anchorKey?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      anchorOffset = renderBox.localToGlobal(Offset.zero);
      anchorSize = renderBox.size;
    }

    _owner = owner;
    _listener = onVisibilityChanged;

    _overlayEntry = OverlayEntry(
      builder: (context) => _KeyboardShell(
        key: _shellKey,
        anchor: anchorOffset,
        anchorSize: anchorSize,
        initialPosition:
            InputVirtualKeyboard.rememberPosition ? _savedPosition : null,
        placement: InputVirtualKeyboard.placement,
        focusNode: focusNode,
        onDragEnd: (position) => _savedPosition = position,
        keyboard: _buildKeyboardFor(
          inputType,
          controller,
          formatters,
          focusNode,
          onChanged,
          onSubmit,
          shuffleDigits,
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
    _listener?.call(true);
  }

  /// Закрыть клавиатуру (с анимацией).
  static void hideKeyboard() {
    if (_overlayEntry == null) return;
    final shell = _shellKey.currentState;
    if (shell == null) {
      _removeNow();
    } else {
      shell.close(_removeNow);
    }
  }

  /// Закрыть клавиатуру, только если она принадлежит [owner].
  static void hideIfOwner(Object owner) {
    if (identical(_owner, owner)) {
      hideKeyboard();
    }
  }

  static void _removeNow() {
    final entry = _overlayEntry;
    if (entry == null) return;
    _overlayEntry = null;
    _owner = null;
    entry.remove();
    entry.dispose();
    _listener?.call(false);
    _listener = null;
  }

  static Widget _buildKeyboardFor(
    TextInputType inputType,
    TextEditingController controller,
    List<TextInputFormatter> formatters,
    FocusNode focusNode,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmit,
    bool shuffleDigits,
  ) {
    void submit() {
      if (onSubmit != null) {
        onSubmit();
      } else {
        hideKeyboard();
        focusNode.unfocus();
      }
    }

    if (inputType == TextInputType.number) {
      return NumberKeyboard(
        shuffleDigits: shuffleDigits,
        onKeyPressed: (text) =>
            handleKeyPressed(text, controller, formatters, onChanged),
        onBackspace: () => handleBackspace(controller, formatters, onChanged),
        onSubmit: submit,
      );
    }
    if (inputType == TextInputType.phone) {
      return NumberKeyboard(
        phoneMode: true,
        onKeyPressed: (text) =>
            handleKeyPressed(text, controller, formatters, onChanged),
        onBackspace: () => handleBackspace(controller, formatters, onChanged),
        onSubmit: submit,
      );
    }

    // Всё остальное (text, multiline, email, url, name, …) — полная клавиатура.
    return FullKeyboard(
      quickKeys: inputType == TextInputType.emailAddress
          ? const ['@', '.com', '.uz', '.ru']
          : const [],
      onKeyPressed: (text) =>
          handleKeyPressed(text, controller, formatters, onChanged),
      onBackspace: () => handleBackspace(controller, formatters, onChanged),
      onSubmit: submit,
      onLeftArrow: () => moveCursor(controller, -1),
      onRightArrow: () => moveCursor(controller, 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Обработчики редактирования. Вынесены в статические методы, чтобы их можно
  // было покрыть юнит-тестами без построения виджетов.
  // ---------------------------------------------------------------------------

  static TextEditingValue _applyFormatters(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    List<TextInputFormatter> formatters,
  ) {
    // Как в EditableText: всем форматтерам передаётся одно и то же старое
    // значение, а новое — каскадом через цепочку.
    var value = newValue;
    for (final formatter in formatters) {
      value = formatter.formatEditUpdate(oldValue, value);
    }
    return value;
  }

  static bool _selectionValid(TextSelection selection, String text) {
    return selection.start >= 0 &&
        selection.end >= 0 &&
        selection.start <= text.length &&
        selection.end <= text.length;
  }

  @visibleForTesting
  static void handleKeyPressed(
    String text,
    TextEditingController controller,
    List<TextInputFormatter> formatters, [
    ValueChanged<String>? onChanged,
  ]) {
    final current = controller.value;
    var selection = current.selection;
    if (!_selectionValid(selection, current.text)) {
      selection = TextSelection.collapsed(offset: current.text.length);
    }

    final newText =
        current.text.replaceRange(selection.start, selection.end, text);
    final candidate = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + text.length),
    );
    controller.value = _applyFormatters(current, candidate, formatters);
    onChanged?.call(controller.text);
  }

  @visibleForTesting
  static void handleBackspace(
    TextEditingController controller,
    List<TextInputFormatter> formatters, [
    ValueChanged<String>? onChanged,
  ]) {
    final current = controller.value;
    final text = current.text;
    var selection = current.selection;
    if (!_selectionValid(selection, text)) {
      selection = TextSelection.collapsed(offset: text.length);
    }

    if (selection.end - selection.start > 0) {
      final candidate = TextEditingValue(
        text: text.replaceRange(selection.start, selection.end, ''),
        selection: TextSelection.collapsed(offset: selection.start),
      );
      controller.value = _applyFormatters(current, candidate, formatters);
      onChanged?.call(controller.text);
      return;
    }

    if (selection.start == 0) return;

    var deleteFrom = selection.start -
        (_isUtf16Surrogate(text.codeUnitAt(selection.start - 1)) ? 2 : 1);
    if (deleteFrom < 0) deleteFrom = 0;

    var formatted = _applyFormatters(
      current,
      TextEditingValue(
        text: text.replaceRange(deleteFrom, selection.start, ''),
        selection: TextSelection.collapsed(offset: deleteFrom),
      ),
      formatters,
    );

    // Маскированный ввод (телефон и т.п.): если форматтер восстановил
    // удалённый разделитель и текст не изменился — удаляем следующий символ,
    // иначе backspace «залипает» на разделителе.
    var guard = 0;
    while (formatted.text == text && deleteFrom > 0 && guard < 8) {
      deleteFrom--;
      formatted = _applyFormatters(
        current,
        TextEditingValue(
          text: text.replaceRange(deleteFrom, selection.start, ''),
          selection: TextSelection.collapsed(offset: deleteFrom),
        ),
        formatters,
      );
      guard++;
    }

    controller.value = formatted;
    onChanged?.call(controller.text);
  }

  @visibleForTesting
  static void moveCursor(TextEditingController controller, int direction) {
    final text = controller.text;
    final selection = controller.selection;
    if (!_selectionValid(selection, text)) {
      controller.selection = TextSelection.collapsed(offset: text.length);
      return;
    }
    var offset = direction < 0 ? selection.start : selection.end;
    if (direction < 0 && offset > 0) {
      offset -= _isUtf16Surrogate(text.codeUnitAt(offset - 1)) ? 2 : 1;
    } else if (direction > 0 && offset < text.length) {
      offset += _isUtf16Surrogate(text.codeUnitAt(offset)) ? 2 : 1;
    }
    controller.selection =
        TextSelection.collapsed(offset: offset.clamp(0, text.length));
  }

  static bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }
}

/// Обёртка вокруг клавиатуры в оверлее: позиционирование с прижатием к
/// границам экрана, drag, docked-режим, анимация появления/скрытия и
/// кнопка закрытия.
class _KeyboardShell extends StatefulWidget {
  const _KeyboardShell({
    super.key,
    required this.anchor,
    required this.anchorSize,
    required this.initialPosition,
    required this.placement,
    required this.focusNode,
    required this.onDragEnd,
    required this.keyboard,
  });

  final Offset anchor;
  final Size anchorSize;
  final Offset? initialPosition;
  final VKPlacement placement;
  final FocusNode focusNode;
  final ValueChanged<Offset> onDragEnd;
  final Widget keyboard;

  @override
  State<_KeyboardShell> createState() => _KeyboardShellState();
}

class _KeyboardShellState extends State<_KeyboardShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  )..forward();

  final GlobalKey _contentKey = GlobalKey();
  late Offset _position;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition ??
        Offset(
          widget.anchor.dx,
          widget.anchor.dy + widget.anchorSize.height + 10,
        );
    // Точный размер клавиатуры известен только после первого лэйаута —
    // тогда и прижимаем её к границам экрана.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _position = _fitOnScreen(_position));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Запускает анимацию закрытия и по её завершении убирает оверлей.
  void close(VoidCallback onDismissed) {
    if (_closing) {
      return;
    }
    _closing = true;
    _controller.reverse().whenCompleteOrCancel(onDismissed);
  }

  Size? get _keyboardSize => _contentKey.currentContext?.size;

  Offset _clampToScreen(Offset position) {
    final size = _keyboardSize;
    if (size == null || !mounted) return position;
    final screen = MediaQuery.sizeOf(context);
    return Offset(
      position.dx.clamp(0.0, max(0.0, screen.width - size.width)),
      position.dy.clamp(0.0, max(0.0, screen.height - size.height)),
    );
  }

  /// Первичное позиционирование: если под полем не хватает места —
  /// открываемся над ним, иначе просто прижимаемся к границам.
  Offset _fitOnScreen(Offset position) {
    final size = _keyboardSize;
    if (size == null || !mounted) return position;
    final screen = MediaQuery.sizeOf(context);
    var result = position;
    if (widget.initialPosition == null &&
        result.dy + size.height > screen.height) {
      final above = widget.anchor.dy - size.height - 10;
      if (above >= 0) {
        result = Offset(result.dx, above);
      }
    }
    return _clampToScreen(result);
  }

  void _dismiss() {
    KeyboardOverlay.hideKeyboard();
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    final content = Container(
      key: _contentKey,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.keyboard,
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  alignment: Alignment.center,
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: InputVirtualKeyboard.theme.primaryColor,
                    ),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final tapOutsideLayer = Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: const SizedBox.expand(),
      ),
    );

    if (widget.placement == VKPlacement.docked) {
      return Stack(
        children: [
          tapOutsideLayer,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: Material(
                color: Colors.transparent,
                child: SafeArea(child: Center(child: content)),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        tapOutsideLayer,
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: FadeTransition(
            opacity: curved,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _position = _clampToScreen(_position + details.delta);
                });
              },
              onPanEnd: (_) => widget.onDragEnd(_position),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}
