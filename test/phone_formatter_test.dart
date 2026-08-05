import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

TextEditingValue _format(String text) {
  const formatter = PhoneFormatter();
  return formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
}

void main() {
  group('PhoneFormatter', () {
    test('форматирует полный номер по маске 2-3-2-2', () {
      expect(_format('934347777').text, '93 434 77 77');
    });

    test('частичный ввод форматируется по мере набора', () {
      expect(_format('9').text, '9');
      expect(_format('93').text, '93');
      expect(_format('934').text, '93 4');
      expect(_format('93434').text, '93 434');
      expect(_format('934347').text, '93 434 7');
      expect(_format('9343477').text, '93 434 77');
      expect(_format('93434777').text, '93 434 77 7');
    });

    test('нецифровые символы отбрасываются', () {
      expect(_format('93-434-77-77').text, '93 434 77 77');
      expect(_format('abc93').text, '93');
    });

    test('лишние цифры обрезаются до 9', () {
      expect(_format('93434777712345').text, '93 434 77 77');
    });

    test('курсор всегда в конце', () {
      final value = _format('934347777');
      expect(value.selection.baseOffset, value.text.length);
    });
  });
}
