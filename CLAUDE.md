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
[input_virtual_keyboard.dart](lib/input_virtual_keyboard.dart) - Exports all public APIs and manages global theme via `InputVirtualKeyboard.init()`.

### Keyboard Types
- **FullKeyboard** ([full_keyboard.dart](lib/src/keyboard/full_keyboard.dart)): QWERTY keyboard with English/Russian language support, shift for uppercase, and number/symbol mode toggle
- **NumberKeyboard** ([number_keyboard.dart](lib/src/keyboard/number_keyboard.dart)): Numeric keypad with decimal separators

### Keyboard Overlay
[keyboard_overlay.dart](lib/src/keyboard/keyboard_overlay.dart) - Static overlay manager that:
- Positions keyboard below input fields using GlobalKey
- Supports dragging to reposition
- Selects keyboard type based on `TextInputType` (number/phone → NumberKeyboard, text/multiline/email → FullKeyboard)
- Handles backspace with UTF-16 surrogate pair support

### Input Widgets
Base class [input.dart](lib/src/inputs/input.dart) provides the core implementation. Specialized inputs extend it:
- `TextInput`, `NumberInput`, `TextAreaInput`, `PhoneInput`, `SearchInput`, `PasswordInput`

All inputs share these key behaviors:
- `useCustomKeyboard` flag (auto-disabled on mobile platforms)
- Keyboard toggle icon appears left of input when custom keyboard is enabled
- Support for prefix/suffix widgets, validation, and input formatters

### Theming
[virtual_keyboard_theme.dart](lib/virtual_keyboard_theme.dart) - `VKTheme` class with colors, text size, and min height. Set via `InputVirtualKeyboard.init(theme: VKTheme(...))`.

## Usage Pattern

```dart
// In main.dart before runApp()
await InputVirtualKeyboard.init(theme: const VKTheme());

// In widgets
TextInput(
  name: 'field_name',
  hint: 'Enter text',
  nextAction: false,
  useCustomKeyboard: true,
)
```
