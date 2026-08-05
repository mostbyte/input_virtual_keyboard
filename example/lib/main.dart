import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

/// Пример собственной раскладки — казахская на базе ЙЦУКЕН.
const kazakhLayout = KeyboardLayout(
  code: 'ҚЗ',
  name: 'Қазақша',
  rows: [
    ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х'],
    ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
    ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'],
  ],
  longPressAlternatives: {'к': 'қ', 'г': 'ғ', 'у': 'ұ', 'о': 'ө', 'е': 'ё'},
);

void main() async {
  await InputVirtualKeyboard.init(
    theme: const VKTheme(minHeight: 40, textSize: 15),
    useCustomKeyboard: true,
    autoShowOnFocus: false,
    placement: VKPlacement.floating,
    layouts: KeyboardLayout.all, // EN / РУ / UZ / ЎЗ
    decimalSeparator: '.',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input Virtual Keyboard — все кейсы',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController(text: '123.45');
  final _standaloneController = TextEditingController();

  bool _autoShow = false;
  bool _docked = false;
  bool _commaSeparator = false;
  bool _withKazakh = false;
  String _lastEvent = '—';

  @override
  void dispose() {
    _numberController.dispose();
    _standaloneController.dispose();
    super.dispose();
  }

  void _log(String event) {
    setState(() => _lastEvent = event);
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Input Virtual Keyboard — все кейсы'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ------------------------------------------------------------
                _section('Глобальные настройки (меняются вживую)', [
                  SwitchListTile(
                    dense: true,
                    title: const Text('autoShowOnFocus — клавиатура по фокусу'),
                    value: _autoShow,
                    onChanged: (v) {
                      setState(() => _autoShow = v);
                      InputVirtualKeyboard.autoShowOnFocus = v;
                    },
                  ),
                  SwitchListTile(
                    dense: true,
                    title: const Text('VKPlacement.docked — панель снизу'),
                    value: _docked,
                    onChanged: (v) {
                      setState(() => _docked = v);
                      InputVirtualKeyboard.placement =
                          v ? VKPlacement.docked : VKPlacement.floating;
                    },
                  ),
                  SwitchListTile(
                    dense: true,
                    title: const Text('Десятичный разделитель «,» вместо «.»'),
                    value: _commaSeparator,
                    onChanged: (v) {
                      setState(() => _commaSeparator = v);
                      InputVirtualKeyboard.decimalSeparator = v ? ',' : '.';
                    },
                  ),
                  SwitchListTile(
                    dense: true,
                    title: const Text('+ казахская раскладка (custom layout)'),
                    subtitle: const Text('долгое нажатие: к→қ, г→ғ, у→ұ, о→ө'),
                    value: _withKazakh,
                    onChanged: (v) {
                      setState(() => _withKazakh = v);
                      InputVirtualKeyboard.layouts = v
                          ? [...KeyboardLayout.all, kazakhLayout]
                          : KeyboardLayout.all;
                    },
                  ),
                  Text('Последнее событие: $_lastEvent',
                      style: const TextStyle(color: Colors.grey)),
                ]),

                // ------------------------------------------------------------
                _section('Текстовые поля', [
                  TextInput(
                    name: 'text_plain',
                    hint: 'Обычный текст (раскладки, shift, long-press ё)',
                    hintColor: Colors.grey,
                    onChanged: (v) => _log('text: $v'),
                  ),
                  TextInput(
                    name: 'text_required',
                    hint: 'Обязательное поле (isRequired)',
                    hintColor: Colors.grey,
                    isRequired: true,
                  ),
                  TextInput(
                    name: 'text_validator',
                    hint: 'Свой validator: минимум 3 символа',
                    hintColor: Colors.grey,
                    validator: (v) => (v != null && v.isNotEmpty && v.length < 3)
                        ? 'Минимум 3 символа'
                        : null,
                  ),
                  TextInput(
                    name: 'text_maxlength',
                    hint: 'maxLength: 5',
                    hintColor: Colors.grey,
                    maxLength: 5,
                  ),
                  TextInput(
                    name: 'text_email',
                    textInputType: TextInputType.emailAddress,
                    hint: 'Email — быстрые клавиши @ .com .uz .ru',
                    hintColor: Colors.grey,
                  ),
                  TextInput(
                    name: 'text_disabled',
                    hint: 'enabled: false — редактирование запрещено',
                    hintColor: Colors.grey,
                    enabled: false,
                    initialValue: 'Заблокировано',
                  ),
                  TextInput(
                    name: 'text_no_vk',
                    hint: 'useCustomKeyboard: false — без иконки клавиатуры',
                    hintColor: Colors.grey,
                    useCustomKeyboard: false,
                  ),
                  TextInput(
                    name: 'text_autoshow',
                    hint: 'autoShowKeyboard: true — только у этого поля',
                    hintColor: Colors.grey,
                    autoShowKeyboard: true,
                  ),
                  TextInput(
                    name: 'text_next',
                    hint: 'nextAction: true — Enter ведёт в следующее поле',
                    hintColor: Colors.grey,
                    nextAction: true,
                  ),
                  TextInput(
                    name: 'text_after_next',
                    hint: '…сюда придёт фокус',
                    hintColor: Colors.grey,
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Prefix / suffix', [
                  TextInput(
                    name: 'text_prefix_suffix',
                    hint: 'prefixWidget + suffixWidget + suffixIcon',
                    hintColor: Colors.grey,
                    prefixWidget:
                        const Icon(Icons.money, color: Colors.white),
                    suffixWidget:
                        const Icon(Icons.check, color: Colors.white),
                    suffixBackground: Colors.green,
                    suffixIcon: const Icon(Icons.info_outline,
                        size: 18, color: Colors.grey),
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Многострочный текст', [
                  TextAreaInput(
                    name: 'area',
                    hint: 'TextAreaInput: multiline, maxLength 200',
                    hintColor: Colors.grey,
                    maxLength: 200,
                    minHeight: 100,
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Числа и телефон', [
                  NumberInput(
                    name: 'number',
                    controller: _numberController,
                    hint: 'NumberInput: клавиши 00 и разделитель',
                    hintColor: Colors.grey,
                    isRequired: true,
                    onChanged: (v) => _log('number: $v'),
                  ),
                  PhoneInput(
                    name: 'phone',
                    hint: '99 123 45 67',
                    hintColor: Colors.grey,
                    isRequired: true,
                    onChanged: (v) => _log('phone: $v'),
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Поиск', [
                  SearchInput(
                    name: 'search',
                    hint: 'SearchInput: лупа → крестик очистки',
                    hintColor: Colors.grey,
                    onChanged: (v) => _log('search: $v'),
                    onSubmitted: (v) => _log('search submit: $v'),
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Пароли и PIN', [
                  PasswordInput(
                    name: 'password',
                    hint: 'Обычный пароль (глаз показать/скрыть)',
                    hintColor: Colors.grey,
                  ),
                  PasswordInput(
                    name: 'password_star',
                    hint: 'Свой obscureCharacter: *',
                    hintColor: Colors.grey,
                    obscureCharacter: '*',
                  ),
                  PasswordInput(
                    name: 'pin',
                    hint: 'pinMode: цифровая клавиатура, только цифры',
                    hintColor: Colors.grey,
                    pinMode: true,
                    maxLength: 4,
                  ),
                  PasswordInput(
                    name: 'pin_shuffled',
                    hint: 'pinMode + shufflePin: перемешанные цифры',
                    hintColor: Colors.grey,
                    pinMode: true,
                    shufflePin: true,
                    maxLength: 4,
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Выпадающие списки', [
                  DropdownInput<int>(
                    name: 'dropdown_typed',
                    hint: 'Типизированный: DropdownEntry<int>',
                    isRequired: true,
                    items: const [
                      DropdownEntry(1, 'Филиал №1'),
                      DropdownEntry(2, 'Филиал №2'),
                      DropdownEntry(3, 'Склад'),
                    ],
                    onChanged: (v) => _log('dropdown: $v'),
                  ),
                  // ignore: deprecated_member_use
                  DropdownInput<dynamic>(
                    name: 'dropdown_legacy',
                    hint: 'Устаревший формат options (deprecated)',
                    // ignore: deprecated_member_use
                    options: const [
                      {'index': 'a', 'value': 'Вариант A'},
                      {'index': 'b', 'value': 'Вариант B'},
                    ],
                    onChanged: (v) => _log('legacy dropdown: $v'),
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Валидация формы', [
                  FilledButton(
                    onPressed: () {
                      final ok = _formKey.currentState!.validate();
                      _log(ok ? 'Форма валидна ✅' : 'Есть ошибки ❌');
                    },
                    child: const Text('Проверить форму'),
                  ),
                ]),

                // ------------------------------------------------------------
                _section('Standalone-виджеты клавиатур', [
                  TextInput(
                    name: 'standalone_target',
                    controller: _standaloneController,
                    hint: 'Сюда печатают клавиатуры ниже',
                    hintColor: Colors.grey,
                    useCustomKeyboard: false,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: FullKeyboard(
                      quickKeys: const ['@', '.com'],
                      onKeyPressed: (text) => KeyboardOverlay.handleKeyPressed(
                          text, _standaloneController, const []),
                      onBackspace: () => KeyboardOverlay.handleBackspace(
                          _standaloneController, const []),
                      onSubmit: () => _log(
                          'standalone submit: ${_standaloneController.text}'),
                      onLeftArrow: () =>
                          KeyboardOverlay.moveCursor(_standaloneController, -1),
                      onRightArrow: () =>
                          KeyboardOverlay.moveCursor(_standaloneController, 1),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: NumberKeyboard(
                      onKeyPressed: (text) => KeyboardOverlay.handleKeyPressed(
                          text, _standaloneController, const []),
                      onBackspace: () => KeyboardOverlay.handleBackspace(
                          _standaloneController, const []),
                      onSubmit: () => _log(
                          'standalone submit: ${_standaloneController.text}'),
                    ),
                  ),
                ]),

                const SizedBox(height: 300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
