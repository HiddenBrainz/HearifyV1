/// Port of HearifyV1/Utils/NumberToWordConverter.swift.
///
/// Converts inline digits to English words so that TTS reads "5 apples" as
/// "five apples". Behavior matches the Swift implementation line-for-line.
class NumberToWord {
  NumberToWord._();

  static const _ones = [
    '',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
  ];
  static const _teens = [
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];
  static const _tens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety',
  ];

  static String convertNumbersInText(String text) {
    final re = RegExp(r'\b\d+\b');
    return text.replaceAllMapped(re, (m) {
      final n = int.tryParse(m.group(0)!);
      return n == null ? m.group(0)! : numberToWords(n);
    });
  }

  static String numberToWords(int number) {
    if (number == 0) return 'zero';
    if (number < 0) return 'negative ${numberToWords(-number)}';
    if (number < 10) return _ones[number];
    if (number < 20) return _teens[number - 10];
    if (number < 100) {
      final t = number ~/ 10;
      final o = number % 10;
      return _tens[t] + (o > 0 ? ' ${_ones[o]}' : '');
    }
    if (number < 1000) {
      final h = number ~/ 100;
      final r = number % 100;
      return '${_ones[h]} hundred${r > 0 ? ' ${numberToWords(r)}' : ''}';
    }
    if (number < 1000000) {
      final k = number ~/ 1000;
      final r = number % 1000;
      return '${numberToWords(k)} thousand${r > 0 ? ' ${numberToWords(r)}' : ''}';
    }
    if (number < 1000000000) {
      final m = number ~/ 1000000;
      final r = number % 1000000;
      return '${numberToWords(m)} million${r > 0 ? ' ${numberToWords(r)}' : ''}';
    }
    final b = number ~/ 1000000000;
    final r = number % 1000000000;
    return '${numberToWords(b)} billion${r > 0 ? ' ${numberToWords(r)}' : ''}';
  }
}
