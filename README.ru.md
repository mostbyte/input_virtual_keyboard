# Input Virtual Keyboard

Кастомизируемая виртуальная клавиатура и набор готовых полей ввода для Flutter-приложений на десктопе (POS-терминалы, киоски, дашборды). На Android/iOS виртуальная клавиатура автоматически отключается — используется системная.

## Возможности

- **Полная клавиатура** с раскладками EN / РУ / UZ (латиница) / ЎЗ (кириллица) и поддержкой собственных раскладок
- **Цифровая клавиатура** с клавишей `00`, настраиваемым десятичным разделителем и режимом телефона (`+`)
- **Умный Shift**: одноразовый (сбрасывается после символа), Caps Lock по двойному тапу
- **Долгое нажатие**: автоповтор Backspace; альтернативные символы (`е` → `ё`, `o` → `oʻ`, `g` → `gʻ`)
- **Быстрые клавиши** для email-полей: `@`, `.com`, `.uz`, `.ru`
- **PIN-режим** для пароля: цифровая клавиатура с опциональным перемешиванием цифр
- **Плавающая** (перетаскиваемая, с прижатием к границам экрана) или **прижатая к низу** (docked) клавиатура
- Автопоказ клавиатуры при фокусе (опционально)
- Запоминание последней раскладки и позиции клавиатуры в рамках сессии
- Анимация появления/скрытия
- Готовые поля: `TextInput`, `NumberInput`, `TextAreaInput`, `PhoneInput` (маска +998), `SearchInput`, `PasswordInput`, `DropdownInput<T>`
- Валидация с текстом ошибки под полем, тема через `VKTheme`

## Быстрый старт

```dart
// main.dart — init опционален, без него используются значения по умолчанию
await InputVirtualKeyboard.init(
  theme: const VKTheme(minHeight: 44, textSize: 15),
  autoShowOnFocus: true,                // открывать клавиатуру при фокусе
  placement: VKPlacement.floating,      // или VKPlacement.docked
  layouts: KeyboardLayout.all,          // EN / РУ / UZ / ЎЗ
  decimalSeparator: ',',
);
runApp(const MyApp());
```

```dart
TextInput(
  name: 'title',
  hint: 'Название',
  isRequired: true,
  onChanged: (v) => print(v),
)

PasswordInput(
  name: 'pin',
  hint: 'PIN-код',
  pinMode: true,       // цифровая клавиатура
  shufflePin: true,    // перемешать цифры (защита от подглядывания)
  maxLength: 4,
)

DropdownInput<int>(
  name: 'filial',
  hint: 'Филиал',
  items: const [
    DropdownEntry(1, 'Филиал №1'),
    DropdownEntry(2, 'Склад'),
  ],
  onChanged: (id) => print(id),
)
```

## Своя раскладка

```dart
const kazakh = KeyboardLayout(
  code: 'ҚЗ',
  name: 'Қазақша',
  rows: [
    ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х'],
    ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
    ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'],
  ],
  longPressAlternatives: {'к': 'қ', 'г': 'ғ', 'у': 'ұ'},
);

await InputVirtualKeyboard.init(
  layouts: [KeyboardLayout.russian, kazakh],
);
```

## Выбор клавиатуры по типу поля

| `textInputType`            | Клавиатура                              |
| -------------------------- | ---------------------------------------- |
| `number`                   | Цифровая (`00`, десятичный разделитель) |
| `phone`                    | Цифровая с `+`                           |
| `emailAddress`             | Полная + быстрые клавиши `@`/`.com`/…   |
| остальные                  | Полная                                   |

## Тема

Все цвета и размеры клавиш настраиваются через `VKTheme`: `keyboardBackground`, `keyBackground`, `keyTextColor`, `submitKeyBackground`, `keyWidth`/`keyHeight`/`keySpacing` и т.д. См. [virtual_keyboard_theme.dart](lib/virtual_keyboard_theme.dart).

## Тесты

```bash
flutter test
```
