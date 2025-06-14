import 'package:flutter/material.dart';

class NumberKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  const NumberKeyboard({
    Key? key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSubmit,
  }) : super(key: key);

  Widget _buildKey(String text, {Color? backgroundColor, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: backgroundColor ?? const Color(0xFF2D2F33),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onKeyPressed(text),
          child: Container(
            height: 60,
            width: 110,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: textColor ?? Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required Widget child,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: backgroundColor ?? const Color(0xFF2D2F33),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 110,
            height: 60,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF1A1B1E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildKey('-'),
            ],
          ),
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
              _buildKey('_'),
            ],
          ),
          Row(
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
              _buildSpecialKey(
                backgroundColor: Colors.red[800],
                onTap: onBackspace,
                child:
                    const Icon(Icons.backspace_outlined, color: Colors.white70),
              ),
            ],
          ),
          Row(
            children: [
              _buildKey('.'),
              _buildKey('0'),
              _buildKey(','),
              _buildSpecialKey(
                backgroundColor: Colors.blue[800],
                onTap: onSubmit,
                child: const Icon(Icons.keyboard_return, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
