import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  setUp(() {
    // Не тащим состояние раскладки между тестами.
    InputVirtualKeyboard.rememberLayout = false;
    InputVirtualKeyboard.layouts = KeyboardLayout.defaults;
  });

  group('FullKeyboard', () {
    testWidgets('нажатие клавиши отдаёт символ', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(FullKeyboard(
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.tap(find.text('q'));
      expect(pressed, ['q']);
    });

    testWidgets('shift одноразовый: одна заглавная, потом строчные',
        (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(FullKeyboard(
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pump();
      await tester.tap(find.text('Q'));
      await tester.pump();
      await tester.tap(find.text('w'));
      expect(pressed, ['Q', 'w']);
    });

    testWidgets('двойной тап по shift включает caps lock', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(FullKeyboard(
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pump();
      expect(find.byIcon(Icons.keyboard_capslock), findsOneWidget);

      await tester.tap(find.text('Q'));
      await tester.pump();
      await tester.tap(find.text('W'));
      expect(pressed, ['Q', 'W']);
    });

    testWidgets('переключение раскладки EN → РУ', (tester) async {
      await tester.pumpWidget(_wrap(FullKeyboard(
        onKeyPressed: (_) {},
        onBackspace: () {},
        onSubmit: () {},
      )));

      expect(find.text('q'), findsOneWidget);
      await tester.tap(find.text('EN'));
      await tester.pump();
      expect(find.text('й'), findsOneWidget);
      expect(find.text('ъ'), findsOneWidget);
    });

    testWidgets('русская раскладка: долгое нажатие на е вводит ё',
        (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(FullKeyboard(
        layouts: const [KeyboardLayout.russian],
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.longPress(find.text('е'));
      expect(pressed, ['ё']);
    });

    testWidgets('режим цифр и символов', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(FullKeyboard(
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.tap(find.text('123*/'));
      await tester.pump();
      await tester.tap(find.text('7'));
      expect(pressed, ['7']);
      expect(find.text('АБВ'), findsOneWidget);
    });

    testWidgets('быстрые клавиши вставляют строку целиком', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(FullKeyboard(
        quickKeys: const ['@', '.com'],
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.tap(find.text('.com'));
      expect(pressed, ['.com']);
    });
  });

  group('NumberKeyboard', () {
    testWidgets('цифры, 00 и разделитель', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_wrap(NumberKeyboard(
        decimalSeparator: ',',
        onKeyPressed: pressed.add,
        onBackspace: () {},
        onSubmit: () {},
      )));

      await tester.tap(find.text('5'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text(','));
      expect(pressed, ['5', '00', ',']);
    });

    testWidgets('phoneMode: есть +, нет 00', (tester) async {
      await tester.pumpWidget(_wrap(NumberKeyboard(
        phoneMode: true,
        onKeyPressed: (_) {},
        onBackspace: () {},
        onSubmit: () {},
      )));

      expect(find.text('+'), findsOneWidget);
      expect(find.text('00'), findsNothing);
    });

    testWidgets('shuffleDigits: все 10 цифр на месте', (tester) async {
      await tester.pumpWidget(_wrap(NumberKeyboard(
        shuffleDigits: true,
        onKeyPressed: (_) {},
        onBackspace: () {},
        onSubmit: () {},
      )));

      for (var digit = 0; digit <= 9; digit++) {
        expect(find.text('$digit'), findsOneWidget);
      }
    });
  });
}
