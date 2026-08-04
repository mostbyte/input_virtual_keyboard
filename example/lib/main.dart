import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';

void main() async {
  await InputVirtualKeyboard.init(
    theme: const VKTheme(minHeight: 38, textSize: 15),
    useCustomKeyboard: true,
    // Попробуйте включить:
    // autoShowOnFocus: true,
    // placement: VKPlacement.docked,
    layouts: KeyboardLayout.all, // EN / РУ / UZ / ЎЗ
    decimalSeparator: ',',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input Virtual Keyboard Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Input Virtual Keyboard Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController numberController =
      TextEditingController(text: "123.0");

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                width: 400,
                child: SearchInput(
                  onChanged: (v) => debugPrint("Search: $v"),
                  name: "search",
                  hint: "Enter search",
                  hintColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: PasswordInput(
                  name: "password",
                  hint: "Enter password",
                  hintColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: PasswordInput(
                  name: "pin",
                  hint: "PIN (перемешанные цифры)",
                  hintColor: Colors.grey,
                  pinMode: true,
                  shufflePin: true,
                  maxLength: 4,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: TextInput(
                  prefixWidget: const Icon(Icons.money, color: Colors.white),
                  isRequired: true,
                  name: "text",
                  hint: "Enter text",
                  hintColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: TextInput(
                  name: "email",
                  textInputType: TextInputType.emailAddress,
                  hint: "Email (с быстрыми клавишами @/.com)",
                  hintColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: TextAreaInput(
                  isRequired: true,
                  name: "area",
                  hint: "Enter area text",
                  hintColor: Colors.grey,
                  maxLength: 200,
                  minHeight: 120,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: NumberInput(
                  controller: numberController,
                  isRequired: true,
                  hint: "Сумма",
                  name: "number",
                  hintColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: PhoneInput(
                  isRequired: true,
                  hint: "99 123 45 67",
                  name: "phone",
                  hintColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: DropdownInput<int>(
                  name: "dropdown",
                  hint: "Выберите филиал",
                  isRequired: true,
                  items: const [
                    DropdownEntry(1, "Филиал №1"),
                    DropdownEntry(2, "Филиал №2"),
                    DropdownEntry(3, "Склад"),
                  ],
                  onChanged: (v) => debugPrint("Dropdown: $v"),
                ),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
