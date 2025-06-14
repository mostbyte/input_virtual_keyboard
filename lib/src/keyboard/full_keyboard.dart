import 'package:flutter/material.dart';

enum KeyboardLanguage {
  english,
  russian,
}

class FullKeyboard extends StatefulWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final VoidCallback? onNumberToggle;
  final VoidCallback? onLeftArrow;
  final VoidCallback? onRightArrow;
  final List<KeyboardLanguage> supportedLanguages;
  final KeyboardLanguage initialLanguage;
  final Function(KeyboardLanguage)? onLanguageChanged;
  final bool isNumberMode;

  const FullKeyboard({
    Key? key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSubmit,
    this.onNumberToggle,
    this.onLeftArrow,
    this.onRightArrow,
    this.supportedLanguages = const [
      KeyboardLanguage.english,
      KeyboardLanguage.russian
    ],
    this.initialLanguage = KeyboardLanguage.english,
    this.onLanguageChanged,
    this.isNumberMode = false,
  }) : super(key: key);

  @override
  State<FullKeyboard> createState() => _FullKeyboardState();
}

class _FullKeyboardState extends State<FullKeyboard> {
  late KeyboardLanguage _currentLanguage;
  bool _isShiftActive = false;

  final List<List<String>> _numberKeys = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['@', '#', '\$', '_', '&', '-', '+', '(', ')', '/'],
    ['*', '"', '\'', ':', ';', '!', '?', ',', '.', '='],
  ];

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage;
  }

  void _toggleLanguage() {
    final currentIndex = widget.supportedLanguages.indexOf(_currentLanguage);
    final nextIndex = (currentIndex + 1) % widget.supportedLanguages.length;
    setState(() {
      _currentLanguage = widget.supportedLanguages[nextIndex];
    });
    widget.onLanguageChanged?.call(_currentLanguage);
  }

  void _toggleShift() {
    setState(() {
      _isShiftActive = !_isShiftActive;
    });
  }

  String _getLanguageText() {
    switch (_currentLanguage) {
      case KeyboardLanguage.english:
        return 'EN';
      case KeyboardLanguage.russian:
        return 'RU';
      default:
        return 'EN';
    }
  }

  List<List<String>> _getCurrentLayoutKeys() {
    if (widget.isNumberMode) {
      return _numberKeys;
    }

    switch (_currentLanguage) {
      case KeyboardLanguage.english:
        return [
          ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
          ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '@'],
          ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.'],
        ];
      case KeyboardLanguage.russian:
        return [
          ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х'],
          ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
          ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'],
        ];
      default:
        return [
          ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
          ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '@'],
          ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.'],
        ];
    }
  }

  Widget _buildKey(String text, {String? topText, bool isActive = false}) {
    final displayText =
        _isShiftActive && !widget.isNumberMode ? text.toUpperCase() : text;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: isActive ? Colors.white : const Color(0xFF2D2F33),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onKeyPressed(
              _isShiftActive && !widget.isNumberMode
                  ? text.toUpperCase()
                  : text),
          child: Container(
            width: 56,
            height: 64,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (topText != null)
                  Text(
                    topText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.black : Colors.white54,
                    ),
                  ),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 20,
                    color: isActive ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
    double? width,
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
            width: 56 * (width != null ? (width) : 1) +
                (width != null ? (width * 5) : 0),
            height: 64,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layoutKeys = _getCurrentLayoutKeys();

    return Container(
      width: 660,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1B1E),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // children: _numberRowSymbols
            //     .map((symbols) => _buildNumberKey(symbols))
            //     .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: layoutKeys[0].map((key) => _buildKey(key)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: layoutKeys[1].map((key) => _buildKey(key)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.isNumberMode)
                _buildSpecialKey(
                  onTap: _toggleShift,
                  backgroundColor: _isShiftActive ? Colors.white : null,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: _isShiftActive ? Colors.black : Colors.white70,
                  ),
                ),
              ...layoutKeys[2].map((key) => _buildKey(key)).toList(),
              _buildSpecialKey(
                onTap: widget.onBackspace,
                child:
                    const Icon(Icons.backspace_outlined, color: Colors.white70),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpecialKey(
                onTap: _toggleLanguage,
                child: Text(
                  _getLanguageText(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildSpecialKey(
                onTap: widget.onLeftArrow ?? () {},
                child: const Icon(Icons.keyboard_arrow_left,
                    color: Colors.white70),
              ),
              _buildSpecialKey(
                onTap: widget.onRightArrow ?? () {},
                child: const Icon(Icons.keyboard_arrow_right,
                    color: Colors.white70),
              ),
              _buildSpecialKey(
                width: 3,
                onTap: () => widget.onKeyPressed(' '),
                child: const Icon(Icons.space_bar, color: Colors.white70),
              ),
              _buildKey('-'),
              _buildKey('_'),
              _buildSpecialKey(
                width: 2,
                backgroundColor: Colors.blue[800],
                onTap: widget.onSubmit,
                child: const Icon(Icons.keyboard_return, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
