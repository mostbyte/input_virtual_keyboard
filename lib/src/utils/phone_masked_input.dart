import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  const PhoneFormatter();
  static const int maxDigits = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters.
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit the digits to a maximum of 9.
    final limitedDigits = digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;

    // Build the formatted string according to the desired pattern: 93 434 77 77.
    final buffer = StringBuffer();
    int index = 0;

    // First group: 2 digits
    if (limitedDigits.length >= 2) {
      buffer.write(limitedDigits.substring(0, 2));
      index = 2;
      if (limitedDigits.length > index) buffer.write(' ');
    } else {
      buffer.write(limitedDigits);
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.toString().length),
      );
    }

    // Second group: 3 digits
    if (limitedDigits.length >= index + 3) {
      buffer.write(limitedDigits.substring(index, index + 3));
      index += 3;
      if (limitedDigits.length > index) buffer.write(' ');
    } else {
      buffer.write(limitedDigits.substring(index));
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.toString().length),
      );
    }

    // Third group: 2 digits
    if (limitedDigits.length >= index + 2) {
      buffer.write(limitedDigits.substring(index, index + 2));
      index += 2;
      if (limitedDigits.length > index) buffer.write(' ');
    } else {
      buffer.write(limitedDigits.substring(index));
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.toString().length),
      );
    }

    // Fourth group: remaining digits (up to 2 digits, since total is 9)
    if (limitedDigits.length > index) {
      buffer.write(limitedDigits.substring(index));
    }

    final formattedText = buffer.toString();

    // Return the new formatted value.
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
