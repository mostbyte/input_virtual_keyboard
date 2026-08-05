# Desktop Virtual Keyboard

[Русская версия](https://github.com/mostbyte/desktop_virtual_keyboard/blob/master/README.ru.md)

A customizable on-screen virtual keyboard and a set of ready-made input widgets for Flutter desktop applications (POS terminals, kiosks, dashboards). On Android/iOS the virtual keyboard is disabled automatically and the system keyboard is used instead.

## Features

- **Full keyboard** with EN / RU / Uzbek-Latin / Uzbek-Cyrillic layouts and support for custom layouts
- **Numeric keyboard** with a `00` key, configurable decimal separator and a phone mode (`+`)
- **Smart Shift**: one-shot (resets after one character), Caps Lock on double-tap
- **Long press**: backspace auto-repeat; alternative characters (`е` → `ё`, `o` → `oʻ`, `g` → `gʻ`)
- **Quick keys** for email fields: `@`, `.com`, `.uz`, `.ru`
- **PIN mode** for password fields: numeric keyboard with optional digit shuffling
- **Floating** (draggable, clamped to screen bounds) or **docked** (pinned to the bottom edge) keyboard
- Optional auto-show on focus
- Remembers the last layout and the dragged keyboard position within a session
- Show/hide animation
- Ready-made fields: `TextInput`, `NumberInput`, `TextAreaInput`, `PhoneInput` (+998 mask), `SearchInput`, `PasswordInput`, `DropdownInput<T>`
- Validation with an error message below the field, theming via `VKTheme`

## Quick start

```dart
// main.dart — init is optional; sane defaults apply without it
await DesktopVirtualKeyboard.init(
  theme: const VKTheme(minHeight: 44, textSize: 15),
  autoShowOnFocus: true,                // open the keyboard on focus
  placement: VKPlacement.floating,      // or VKPlacement.docked
  layouts: KeyboardLayout.all,          // EN / RU / UZ-Latin / UZ-Cyrillic
  decimalSeparator: ',',
);
runApp(const MyApp());
```

```dart
TextInput(
  name: 'title',
  hint: 'Title',
  isRequired: true,
  onChanged: (v) => print(v),
)

PasswordInput(
  name: 'pin',
  hint: 'PIN code',
  pinMode: true,       // numeric keyboard, digits only
  shufflePin: true,    // shuffle digits (shoulder-surfing protection)
  maxLength: 4,
)

DropdownInput<int>(
  name: 'branch',
  hint: 'Branch',
  items: const [
    DropdownEntry(1, 'Branch #1'),
    DropdownEntry(2, 'Warehouse'),
  ],
  onChanged: (id) => print(id),
)
```

## Custom layout

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

await DesktopVirtualKeyboard.init(
  layouts: [KeyboardLayout.russian, kazakh],
);
```

## Keyboard selection by field type

| `textInputType` | Keyboard                                  |
| --------------- | ----------------------------------------- |
| `number`        | Numeric (`00`, decimal separator)         |
| `phone`         | Numeric with `+`                          |
| `emailAddress`  | Full + quick keys `@`/`.com`/…            |
| everything else | Full                                      |

## Standalone keyboards

`FullKeyboard` and `NumberKeyboard` can be embedded directly (e.g. a custom PIN pad) without the overlay. Use the public editing handlers so formatters and surrogate pairs are handled correctly:

```dart
FullKeyboard(
  onKeyPressed: (text) =>
      KeyboardOverlay.handleKeyPressed(text, controller, const []),
  onBackspace: () => KeyboardOverlay.handleBackspace(controller, const []),
  onSubmit: () => print(controller.text),
)
```

## Theming

All key colors and sizes are configurable via `VKTheme`: `keyboardBackground`, `keyBackground`, `keyTextColor`, `submitKeyBackground`, `keyWidth`/`keyHeight`/`keySpacing`, etc.

## Tests

```bash
flutter test
```
