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
