import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DefaultInput extends StatefulWidget {
  Widget child;
  bool isRequired;
  DefaultInput({this.isRequired = false, required this.child, Key? key})
      : super(key: key);

  @override
  _DefaultInputState createState() => _DefaultInputState();
}

class _DefaultInputState extends State<DefaultInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 35,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: (widget.isRequired)
            ? Border.all(color: Colors.red)
            : Border.all(width: 0, color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.child,
    );
  }
}
