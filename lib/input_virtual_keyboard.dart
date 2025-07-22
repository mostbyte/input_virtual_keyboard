library input_virtual_keyboard;

import 'package:input_virtual_keyboard/virtual_keyboard_theme.dart';

export 'src/keyboard/number_keyboard.dart';
export 'src/keyboard/full_keyboard.dart';
export 'src/inputs/text_input.dart';
export 'src/inputs/number_input.dart';
export 'src/inputs/text_area_input.dart';
export 'src/inputs/phone_input.dart';
export 'src/inputs/search_input.dart';

class InputVirtualKeyboard {
  InputVirtualKeyboard._();

  static late VKTheme _theme;
  static VKTheme get theme => _theme;

  /// Вызываем в main.dart
  static Future<void> init({VKTheme? theme}) async {
    _theme = theme ?? const VKTheme(); // если не передали — берём дефолт
    // здесь можно грузить шрифты/иконки, если нужно await
  }
}
