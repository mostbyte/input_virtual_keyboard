/// Описание раскладки полноразмерной клавиатуры.
///
/// Раскладка — это просто данные: три ряда символов плюс карта альтернативных
/// символов, которые вводятся долгим нажатием (например `е` → `ё`).
/// Свои раскладки можно передать в [InputVirtualKeyboard.init] или напрямую
/// в `FullKeyboard(layouts: ...)`.
class KeyboardLayout {
  const KeyboardLayout({
    required this.code,
    required this.name,
    required this.rows,
    this.longPressAlternatives = const {},
  });

  /// Короткий код на клавише переключения языка («EN», «РУ», «UZ»).
  final String code;

  /// Человекочитаемое название.
  final String name;

  /// Три ряда символьных клавиш.
  final List<List<String>> rows;

  /// Альтернативный символ по долгому нажатию: клавиша → символ.
  final Map<String, String> longPressAlternatives;

  static const KeyboardLayout english = KeyboardLayout(
    code: 'EN',
    name: 'English',
    rows: [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '@'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.'],
    ],
  );

  static const KeyboardLayout russian = KeyboardLayout(
    code: 'РУ',
    name: 'Русский',
    rows: [
      ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
      ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
      ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'],
    ],
    longPressAlternatives: {'е': 'ё'},
  );

  static const KeyboardLayout uzbekLatin = KeyboardLayout(
    code: 'UZ',
    name: 'Oʻzbekcha',
    rows: [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ʼ'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.'],
    ],
    longPressAlternatives: {'o': 'oʻ', 'g': 'gʻ'},
  );

  static const KeyboardLayout uzbekCyrillic = KeyboardLayout(
    code: 'ЎЗ',
    name: 'Ўзбекча',
    rows: [
      ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'ў', 'з', 'х', 'ъ'],
      ['ф', 'қ', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', 'ҳ'],
      ['я', 'ч', 'с', 'м', 'и', 'т', 'ғ', 'б', 'ю'],
    ],
    longPressAlternatives: {'е': 'ё'},
  );

  /// Набор по умолчанию, если ничего не настроено.
  static const List<KeyboardLayout> defaults = [english, russian];

  /// Все встроенные раскладки.
  static const List<KeyboardLayout> all = [
    english,
    russian,
    uzbekLatin,
    uzbekCyrillic,
  ];
}
