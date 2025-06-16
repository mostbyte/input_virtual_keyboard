import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DefaultInput extends StatefulWidget {
  Widget child;
  bool isRequired;
  Widget? keyboard;
  DefaultInput(
      {this.isRequired = false, this.keyboard, required this.child, Key? key})
      : super(key: key);

  @override
  _DefaultInputState createState() => _DefaultInputState();
}

class _DefaultInputState extends State<DefaultInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35,
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.keyboard ?? const SizedBox(),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: (widget.isRequired)
                    ? Border.all(color: Colors.red)
                    : Border.all(width: 0, color: Colors.grey),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
