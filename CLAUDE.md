# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example && flutter run

# Analyze code
flutter analyze
```

## Package Overview

This is a Flutter package providing customizable virtual keyboard widgets for desktop applications. The virtual keyboard automatically disables on Android/iOS and falls back to system keyboard.

## Architecture

### Library Entry Point
[input_virtual_keyboard.dart](lib/input_virtual_keyboard.dart) - Exports all public APIs and holds global config (`InputVirtualKeyboard`): theme, `autoShowOnFocus`, `placement` (floating/docked), `layouts`, `decimalSeparator`, session memory flags. `init()` is optional — sane defaults apply without it.

### Keyboard Types
- **FullKeyboard** ([full_keyboard.dart](lib/src/keyboard/full_keyboard.dart)): letter keyboard driven by `KeyboardLayout` data ([keyboard_layout.dart](lib/src/keyboard/keyboard_layout.dart) — EN/RU/UZ-latin/UZ-cyrillic presets + custom layouts). One-shot shift, caps lock on double-tap, long-press alternatives (`е`→`ё`, `o`→`oʻ`), backspace auto-repeat, optional quick keys row (email: `@`/`.com`/…), number/symbol mode toggle. Remembers last layout per session (static).
- **NumberKeyboard** ([number_keyboard.dart](lib/src/keyboard/number_keyboard.dart)): numeric keypad with `00` key, configurable decimal separator, `phoneMode` (`+` key) and `shuffleDigits` (PIN entry).

### Keyboard Overlay
[keyboard_overlay.dart](lib/src/keyboard/keyboard_overlay.dart) - Static overlay manager:
- Single keyboard at a time, with explicit `owner` (the Input state). `hideIfOwner` prevents one field from closing another field's keyboard; visibility state flows only through `onVisibilityChanged`.
- Selects keyboard by `TextInputType` (number → NumberKeyboard, phone → NumberKeyboard phoneMode, emailAddress → FullKeyboard + quick keys, everything else → FullKeyboard).
- `_KeyboardShell` handles positioning (clamped to screen, opens above field when no room below), dragging (floating), docked mode, show/hide animation, close button, tap-outside dismiss. Dragged position is remembered per session.
- Editing handlers (`handleKeyPressed`/`handleBackspace`/`moveCursor`) are `@visibleForTesting` statics: they run input through `inputFormatters` like EditableText does (same oldValue, cascaded newValue, single controller assignment), handle UTF-16 surrogate pairs, and step over mask separators on backspace (phone mask doesn't "stick").

### Input Widgets
Base class [input.dart](lib/src/inputs/input.dart) provides the core implementation. All specialized inputs extend it: `TextInput`, `NumberInput`, `TextAreaInput`, `PhoneInput`, `SearchInput` (built-in `showSearchAffix`), `PasswordInput` (built-in `showPasswordToggle`, optional `pinMode`/`shufflePin`).

Key behaviors:
- `useCustomKeyboard` flag (auto-disabled on mobile platforms), `autoShowKeyboard` per-field override of global `autoShowOnFocus`.
- Validation error text is rendered by Input itself below the field (built-in TextFormField error is suppressed via zero-size errorStyle — tests must match the visible `fontSize: 12` Text).
- `controller` and `initialValue` are mutually exclusive (assert).
- `DropdownInput<T>` ([dropdown_input.dart](lib/src/inputs/dropdown_input.dart)) is typed: `items: List<DropdownEntry<T>>` + `value`; legacy `options`/`result` maps are deprecated but still work.

### Theming
[virtual_keyboard_theme.dart](lib/virtual_keyboard_theme.dart) - `VKTheme` covers both inputs (colors, text size, min height, error color) and keyboards (key/keyboard backgrounds, key sizes, spacing, radii). Also defines `VKPlacement` (floating/docked).

## Usage Pattern

```dart
// main.dart (optional)
await InputVirtualKeyboard.init(
  theme: const VKTheme(),
  autoShowOnFocus: true,
  layouts: KeyboardLayout.all,
);

// In widgets
TextInput(name: 'field_name', hint: 'Enter text')
PasswordInput(name: 'pin', pinMode: true, shufflePin: true)
DropdownInput<int>(name: 'x', items: [DropdownEntry(1, 'One')])
```

## Gotchas

- `FullKeyboard._sessionLayoutCode` is static session state — reset `InputVirtualKeyboard.rememberLayout = false` in widget tests.
- Keyboard icon assets ship with the package (`package: 'input_virtual_keyboard'`); consumers don't add them.
