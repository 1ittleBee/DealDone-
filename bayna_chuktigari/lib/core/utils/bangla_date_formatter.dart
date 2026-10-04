/// Utility to format DateTime instances into standard Bengali format with Bengali numerals.
class BanglaDateFormatter {
  static const List<String> _bnMonths = [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  static const Map<String, String> _enToBnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Converts standard ASCII digits to Bengali digits.
  static String toBengaliDigits(dynamic number) {
    final str = number.toString();
    return str.split('').map((c) => _enToBnDigits[c] ?? c).join('');
  }

  /// Formats date to: "৩০ সেপ্টেম্বর ২০২৬"
  static String formatBengali(DateTime date) {
    final day = toBengaliDigits(date.day);
    final month = _bnMonths[date.month - 1];
    final year = toBengaliDigits(date.year);
    return '$day $month $year';
  }

  /// Formats date to standard dd/mm/yyyy with Bengali digits: "৩০/০৯/২০২৬"
  static String formatNumericBengali(DateTime date) {
    final day = toBengaliDigits(date.day.toString().padLeft(2, '0'));
    final month = toBengaliDigits(date.month.toString().padLeft(2, '0'));
    final year = toBengaliDigits(date.year);
    return '$day/$month/$year';
  }
}
