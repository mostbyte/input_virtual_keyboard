library;

import 'package:input_virtual_keyboard/src/keyboard/keyboard_layout.dart';
import 'package:input_virtual_keyboard/virtual_keyboard_theme.dart';

export 'virtual_keyboard_theme.dart';
export 'src/keyboard/keyboard_layout.dart';
export 'src/keyboard/number_keyboard.dart';
export 'src/keyboard/full_keyboard.dart';
export 'src/keyboard/keyboard_overlay.dart'
    show KeyboardOverlay, KeyboardVisibilityChanged;
export 'src/inputs/input.dart';
export 'src/inputs/text_input.dart';
export 'src/inputs/number_input.dart';
export 'src/inputs/text_area_input.dart';
export 'src/inputs/phone_input.dart';
export 'src/inputs/search_input.dart';
export 'src/inputs/password_input.dart';
export 'src/inputs/dropdown_input.dart';
export 'src/utils/phone_masked_input.dart';

/// Глобальная конфигурация пакета.
///
/// Вызов [init] опционален — без него используются значения по умолчанию.
class InputVirtualKeyboard {
  InputVirtualKeyboard._();

  static VKTheme _theme = const VKTheme();
  static VKTheme get theme => _theme;

  /// Глобальный флаг: показывать ли иконку/оверлей виртуальной клавиатуры.
  /// На Android/iOS кастомная клавиатура отключается независимо от флага.
  static bool useCustomKeyboard = true;

  /// Открывать клавиатуру автоматически при получении полем фокуса.
  static bool autoShowOnFocus = false;

  /// Плавающая или прижатая к низу экрана клавиатура.
  static VKPlacement placement = VKPlacement.floating;

  /// Доступные раскладки полноразмерной клавиатуры.
  static List<KeyboardLayout> layouts = KeyboardLayout.defaults;

  /// Десятичный разделитель на цифровой клавиатуре.
  static String decimalSeparator = '.';

  /// Запоминать последнюю выбранную раскладку в рамках сессии.
  static bool rememberLayout = true;

  /// Запоминать позицию, куда пользователь перетащил клавиатуру.
  static bool rememberPosition = true;

  /// Вызываем в main.dart. Все параметры опциональны.
  static Future<void> init({
    VKTheme? theme,
    bool useCustomKeyboard = true,
    bool autoShowOnFocus = false,
    VKPlacement placement = VKPlacement.floating,
    List<KeyboardLayout>? layouts,
    String decimalSeparator = '.',
    bool rememberLayout = true,
    bool rememberPosition = true,
  }) async {
    _theme = theme ?? const VKTheme();
    InputVirtualKeyboard.useCustomKeyboard = useCustomKeyboard;
    InputVirtualKeyboard.autoShowOnFocus = autoShowOnFocus;
    InputVirtualKeyboard.placement = placement;
    InputVirtualKeyboard.layouts =
        (layouts == null || layouts.isEmpty) ? KeyboardLayout.defaults : layouts;
    InputVirtualKeyboard.decimalSeparator = decimalSeparator;
    InputVirtualKeyboard.rememberLayout = rememberLayout;
    InputVirtualKeyboard.rememberPosition = rememberPosition;
  }
}
