import 'package:flutter/material.dart';
import 'package:input_virtual_keyboard/input_virtual_keyboard.dart';
import 'package:input_virtual_keyboard/virtual_keyboard_theme.dart';

void main() async {
  await InputVirtualKeyboard.init(
    theme: const VKTheme(minHeight: 38, textSize: 15),
    useCustomKeyboard: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  changed(p0) {
    print("Search: $p0");
  }

  TextEditingController numberController = TextEditingController();
  @override
  void initState() {
    numberController.text = "123.0";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 200),
            SizedBox(
              width: 400,
              child: SearchInput(
                onChanged: changed,
                name: "some",
                nextAction: false,
                initialValue: "",
                hint: "Enter search",
                hintColor: Colors.grey,
              ),
            ),
            SizedBox(
              width: 400,
              child: PasswordInput(
                name: "some",
                nextAction: false,
                initialValue: "",
                hint: "Enter password",
                hintColor: Colors.grey,
              ),
            ),
            SizedBox(
              width: 200,
              child: TextInput(
                prefixWidget: Icon(Icons.money, color: Colors.white),
                isRequired: true,
                name: "some",
                nextAction: false,
                initialValue: "",
                hint: "Enter text",
                hintColor: Colors.grey,
                // maxLength: 5,
              ),
            ),
            SizedBox(
              width: 200,
              child: TextAreaInput(
                isRequired: true,
                name: "some",
                nextAction: false,
                initialValue: "",
                hint: "Enter area text",
                hintColor: Colors.grey,
                maxLength: 200,
                maxLines: null,
                minLines: null,
                minHeight: 200,
              ),
            ),
            SizedBox(
              width: 500,
              child: NumberInput(
                controller: numberController,
                prefixWidget: Text(
                  "+998",
                  style: TextStyle(color: Colors.white),
                ),
                isRequired: true,
                hint: "99 123 45 67",
                name: "some",
                nextAction: false,
                initialValue: "",
                hintColor: Colors.grey,
                suffixWidget: Icon(Icons.money, color: Colors.red),
                suffixBackground: Colors.green,
                suffixIcon: Icon(
                  Icons.remove_red_eye_sharp,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              width: 500,
              child: PhoneInput(
                prefixWidget: Text(
                  "+998",
                  style: TextStyle(color: Colors.white),
                ),
                isRequired: true,
                hint: "99 123 45 67",
                name: "some",
                nextAction: false,
                initialValue: "",
                hintColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
