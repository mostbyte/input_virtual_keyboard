import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_virtual_keyboard/desktop_virtual_keyboard.dart';

/// Видимый текст ошибки (наш, под полем), а не скрытый встроенный
/// error-текст TextFormField с нулевым размером шрифта.
Finder _visibleError(String text) => find.byWidgetPredicate(
      (w) => w is Text && w.data == text && w.style?.fontSize == 12,
    );

Widget _wrap(Widget child, {GlobalKey<FormState>? formKey}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        key: formKey,
        child: SizedBox(width: 400, child: child),
      ),
    ),
  );
}

void main() {
  group('Input', () {
    testWidgets('enabled: false запрещает редактирование', (tester) async {
      final controller = TextEditingController(text: 'locked');
      await tester.pumpWidget(_wrap(TextInput(
        name: 'test',
        enabled: false,
        controller: controller,
      )));

      final field =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('обычный ввод работает и вызывает onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(TextInput(
        name: 'test',
        onChanged: (v) => changed = v,
      )));

      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('isRequired показывает текст ошибки под полем',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(_wrap(
        const TextInput(name: 'test', isRequired: true),
        formKey: formKey,
      ));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(_visibleError('Обязательное поле'), findsOneWidget);
    });

    testWidgets('ошибка исчезает после исправления', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(_wrap(
        const TextInput(name: 'test', isRequired: true),
        formKey: formKey,
      ));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(_visibleError('Обязательное поле'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'value');
      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(find.text('Обязательное поле'), findsNothing);
    });

    testWidgets('кастомный validator', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(_wrap(
        TextInput(
          name: 'test',
          validator: (v) =>
              (v != null && v.length < 3) ? 'Слишком коротко' : null,
        ),
        formKey: formKey,
      ));

      await tester.enterText(find.byType(TextFormField), 'ab');
      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(_visibleError('Слишком коротко'), findsOneWidget);
    });

    testWidgets('PasswordInput скрывает текст и переключается глазом',
        (tester) async {
      await tester.pumpWidget(_wrap(PasswordInput(name: 'pwd')));

      EditableText editable() =>
          tester.widget<EditableText>(find.byType(EditableText));
      expect(editable().obscureText, isTrue);

      // Глаз — единственный Image с asset eye_close.
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(editable().obscureText, isFalse);
    });

    testWidgets('SearchInput: кнопка очистки стирает текст', (tester) async {
      final controller = TextEditingController(text: 'query');
      await tester.pumpWidget(_wrap(SearchInput(
        name: 'search',
        controller: controller,
      )));
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('controller + initialValue одновременно — assert',
        (tester) async {
      expect(
        () => TextInput(
          name: 'x',
          controller: TextEditingController(),
          initialValue: 'y',
        ),
        throwsAssertionError,
      );
    });
  });

  group('DropdownInput', () {
    testWidgets('типизированные items и onChanged', (tester) async {
      int? selected;
      await tester.pumpWidget(_wrap(DropdownInput<int>(
        name: 'dd',
        items: const [
          DropdownEntry(1, 'Один'),
          DropdownEntry(2, 'Два'),
        ],
        onChanged: (v) => selected = v,
      )));

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Два').last);
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('isRequired показывает ошибку', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(_wrap(
        const DropdownInput<int>(name: 'dd', isRequired: true),
        formKey: formKey,
      ));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(_visibleError('Обязательное поле'), findsOneWidget);
    });

    testWidgets('легаси options: null-значение не падает при T=Object',
        (tester) async {
      // Регрессия: `null as T` для ненулевого выведенного T кидал _TypeError.
      await tester.pumpWidget(_wrap(
        // ignore: deprecated_member_use
        const DropdownInput<Object>(
          name: 'dd',
          // ignore: deprecated_member_use
          options: [
            {'index': null, 'value': 'Не выбрано'},
            {'index': 1, 'value': 'Один'},
          ],
        ),
      ));

      expect(find.text('Не выбрано'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
