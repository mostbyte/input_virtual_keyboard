import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_virtual_keyboard/desktop_virtual_keyboard.dart';

void main() {
  group('KeyboardOverlay.handleKeyPressed', () {
    test('вставляет символ в позицию курсора', () {
      final controller = TextEditingController(text: 'ac');
      controller.selection = const TextSelection.collapsed(offset: 1);
      KeyboardOverlay.handleKeyPressed('b', controller, const []);
      expect(controller.text, 'abc');
      expect(controller.selection.baseOffset, 2);
    });

    test('заменяет выделение', () {
      final controller = TextEditingController(text: 'hello');
      controller.selection =
          const TextSelection(baseOffset: 1, extentOffset: 4);
      KeyboardOverlay.handleKeyPressed('X', controller, const []);
      expect(controller.text, 'hXo');
    });

    test('невалидное выделение — вставка в конец', () {
      final controller = TextEditingController(text: 'ab');
      controller.value = controller.value
          .copyWith(selection: const TextSelection.collapsed(offset: -1));
      KeyboardOverlay.handleKeyPressed('c', controller, const []);
      expect(controller.text, 'abc');
    });

    test('уважает LengthLimitingTextInputFormatter', () {
      final controller = TextEditingController(text: '1234');
      controller.selection = const TextSelection.collapsed(offset: 4);
      KeyboardOverlay.handleKeyPressed(
        '5',
        controller,
        [LengthLimitingTextInputFormatter(4)],
      );
      expect(controller.text, '1234');
    });

    test('прогоняет ввод через PhoneFormatter', () {
      final controller = TextEditingController(text: '93');
      controller.selection = const TextSelection.collapsed(offset: 2);
      KeyboardOverlay.handleKeyPressed('4', controller, const [PhoneFormatter()]);
      expect(controller.text, '93 4');
    });

    test('вызывает onChanged с новым текстом', () {
      final controller = TextEditingController();
      String? emitted;
      KeyboardOverlay.handleKeyPressed('a', controller, const [], (v) {
        emitted = v;
      });
      expect(emitted, 'a');
    });
  });

  group('KeyboardOverlay.handleBackspace', () {
    test('удаляет символ перед курсором', () {
      final controller = TextEditingController(text: 'abc');
      controller.selection = const TextSelection.collapsed(offset: 3);
      KeyboardOverlay.handleBackspace(controller, const []);
      expect(controller.text, 'ab');
      expect(controller.selection.baseOffset, 2);
    });

    test('удаляет выделение целиком', () {
      final controller = TextEditingController(text: 'hello');
      controller.selection =
          const TextSelection(baseOffset: 1, extentOffset: 4);
      KeyboardOverlay.handleBackspace(controller, const []);
      expect(controller.text, 'ho');
      expect(controller.selection.baseOffset, 1);
    });

    test('в начале строки — ничего не делает', () {
      final controller = TextEditingController(text: 'abc');
      controller.selection = const TextSelection.collapsed(offset: 0);
      KeyboardOverlay.handleBackspace(controller, const []);
      expect(controller.text, 'abc');
    });

    test('суррогатная пара (эмодзи) удаляется целиком', () {
      final controller = TextEditingController(text: 'a😀');
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
      KeyboardOverlay.handleBackspace(controller, const []);
      expect(controller.text, 'a');
    });

    test('маска телефона: backspace через разделитель не залипает', () {
      // "93 434" → удаляем последнюю цифру, форматтер не должен
      // восстановить её обратно.
      final controller = TextEditingController(text: '93 434');
      controller.selection = const TextSelection.collapsed(offset: 6);
      KeyboardOverlay.handleBackspace(controller, const [PhoneFormatter()]);
      expect(controller.text, '93 43');

      // "93 4" → две итерации: удаление '4', затем пробел+цифра.
      final controller2 = TextEditingController(text: '93 4');
      controller2.selection = const TextSelection.collapsed(offset: 4);
      KeyboardOverlay.handleBackspace(controller2, const [PhoneFormatter()]);
      expect(controller2.text, '93');
      KeyboardOverlay.handleBackspace(controller2, const [PhoneFormatter()]);
      expect(controller2.text, '9');
    });

    test('вызывает onChanged', () {
      final controller = TextEditingController(text: 'ab');
      controller.selection = const TextSelection.collapsed(offset: 2);
      String? emitted;
      KeyboardOverlay.handleBackspace(controller, const [], (v) {
        emitted = v;
      });
      expect(emitted, 'a');
    });
  });

  group('KeyboardOverlay.moveCursor', () {
    test('двигает курсор влево и вправо', () {
      final controller = TextEditingController(text: 'abc');
      controller.selection = const TextSelection.collapsed(offset: 2);
      KeyboardOverlay.moveCursor(controller, -1);
      expect(controller.selection.baseOffset, 1);
      KeyboardOverlay.moveCursor(controller, 1);
      expect(controller.selection.baseOffset, 2);
    });

    test('не выходит за границы', () {
      final controller = TextEditingController(text: 'ab');
      controller.selection = const TextSelection.collapsed(offset: 0);
      KeyboardOverlay.moveCursor(controller, -1);
      expect(controller.selection.baseOffset, 0);
      controller.selection = const TextSelection.collapsed(offset: 2);
      KeyboardOverlay.moveCursor(controller, 1);
      expect(controller.selection.baseOffset, 2);
    });

    test('перешагивает суррогатную пару целиком', () {
      final controller = TextEditingController(text: 'a😀b');
      controller.selection = const TextSelection.collapsed(offset: 3);
      KeyboardOverlay.moveCursor(controller, -1);
      expect(controller.selection.baseOffset, 1);
      KeyboardOverlay.moveCursor(controller, 1);
      expect(controller.selection.baseOffset, 3);
    });
  });
}
