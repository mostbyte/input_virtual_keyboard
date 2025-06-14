<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Input Virtual Keyboard

A Flutter package that provides a customizable virtual keyboard with multiple language support.

## Features

- Custom virtual keyboard with English and Russian language support
- Floating keyboard overlay
- Active/Passive keyboard state indicators
- Shift key functionality for special characters
- Arrow key navigation
- Backspace and submit buttons

## Getting Started

1. Add the package to your pubspec.yaml:

```yaml
dependencies:
  input_virtual_keyboard: ^0.0.1
```

2. Add the keyboard icons to your assets:

Create an `assets` directory in your package and add two icons:
- `active_keyboard.png`: The keyboard icon when the virtual keyboard is active
- `passive_keyboard.png`: The keyboard icon when the virtual keyboard is inactive

The recommended size for the keyboard icons is 24x24 pixels.

## Usage

```dart
TextInput(
  name: 'my_input',
  hint: 'Enter text',
  useCustomKeyboard: true, // Enable/disable custom keyboard
  nextAction: true, // Show next action button
)
```

## Keyboard Icons

Place the following files in your assets directory:

1. active_keyboard.png:
   - Size: 24x24 pixels
   - Color: #2196F3 (Blue)
   - Description: Keyboard icon with a filled/solid style

2. passive_keyboard.png:
   - Size: 24x24 pixels
   - Color: #9E9E9E (Grey)
   - Description: Keyboard icon with an outline style

You can use any keyboard icon design that matches your app's theme, but make sure to maintain the naming convention and place them in the assets directory.

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
