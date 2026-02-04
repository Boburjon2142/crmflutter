import 'package:flutter/services.dart';

String formatNumber(num value) {
  final negative = value < 0;
  final text = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final indexFromEnd = text.length - i;
    buffer.write(text[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(' ');
    }
  }
  final result = buffer.toString().trimRight();
  return negative ? '-$result' : result;
}

String formatMoney(num? value) {
  if (value == null) {
    return '0 so\'m';
  }
  return '${formatNumber(value)} so\'m';
}

String formatMoneyDynamic(dynamic value) {
  if (value == null) {
    return '0 so\'m';
  }
  if (value is num) {
    return formatMoney(value);
  }
  final raw = value.toString().replaceAll(' ', '').replaceAll(',', '');
  final parsed = num.tryParse(raw);
  if (parsed == null) {
    return '0 so\'m';
  }
  return formatMoney(parsed);
}

String stripNumberFormatting(String raw, {bool allowNegative = false}) {
  final normalized = _normalizeDigits(raw);
  if (!allowNegative) {
    return normalized.replaceAll('-', '');
  }
  if (normalized.isEmpty) {
    return normalized;
  }
  final isNegative = normalized.startsWith('-');
  final digits = normalized.replaceAll('-', '');
  return isNegative ? '-$digits' : digits;
}

int? parseFormattedInt(String raw, {bool allowNegative = false}) {
  final cleaned = stripNumberFormatting(raw, allowNegative: allowNegative);
  if (cleaned.isEmpty || cleaned == '-') {
    return null;
  }
  return int.tryParse(cleaned);
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) {
      return newValue;
    }

    final negative = allowNegative && raw.startsWith('-');
    final digits = _normalizeDigits(raw).replaceAll('-', '');
    if (digits.isEmpty) {
      if (negative) {
        return const TextEditingValue(
          text: '-',
          selection: TextSelection.collapsed(offset: 1),
        );
      }
      return const TextEditingValue(text: '');
    }

    final formatted = _groupDigits(digits);
    final text = negative ? '-$formatted' : formatted;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String _groupDigits(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(' ');
    }
  }
  return buffer.toString().trimRight();
}

String _normalizeDigits(String raw) {
  final buffer = StringBuffer();
  for (final rune in raw.runes) {
    final char = String.fromCharCode(rune);
    if (char == '-') {
      buffer.write('-');
      continue;
    }
    final mapped = _mapDigit(char);
    if (mapped != null) {
      buffer.write(mapped);
    }
  }
  return buffer.toString();
}

String? _mapDigit(String char) {
  if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
    return char;
  }
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const easternArabicIndic = '۰۱۲۳۴۵۶۷۸۹';
  final indexArabic = arabicIndic.indexOf(char);
  if (indexArabic != -1) {
    return indexArabic.toString();
  }
  final indexEastern = easternArabicIndic.indexOf(char);
  if (indexEastern != -1) {
    return indexEastern.toString();
  }
  final parsed = int.tryParse(char);
  if (parsed != null) {
    return parsed.toString();
  }
  return null;
}
