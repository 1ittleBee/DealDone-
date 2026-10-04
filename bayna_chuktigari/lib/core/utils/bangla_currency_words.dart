/// Pure synchronous deterministic Bengali currency-to-words converter.
/// Implements FR-4 and ARCH-5.
/// Converts integers from 1 to 99,99,99,999 into formal legal Bengali words.
class BanglaCurrencyWords {
  BanglaCurrencyWords._();

  static const List<String> _units0To99 = [
    'শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়',
    'দশ', 'এগারো', 'বারো', 'তেরো', 'চৌদ্দ', 'পনেরো', 'ষোলো', 'সতেরো', 'আঠারো', 'উনিশ',
    'বিশ', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', 'সাতাশ', 'আঠাশ', 'উনত্রিশ',
    'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ', 'সাঁইত্রিশ', 'আটত্রিশ', 'উনচল্লিশ',
    'চল্লিশ', 'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ', 'পঁয়তাল্লিশ', 'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'উনপঞ্চাশ',
    'পঞ্চাশ', 'একান্ন', 'বায়ান্ন', 'তিপ্পান্ন', 'চুয়ান্ন', 'পঞ্চান্ন', 'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'উনষাট',
    'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', 'পঁয়ষট্টি', 'ছেষট্টি', 'সাতষট্টি', 'আটষট্টি', 'উনসত্তর',
    'সত্তর', 'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর', 'ছিয়াত্তর', 'সাতাত্তর', 'আঠাত্তর', 'উনাশি',
    'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', 'চুরাশি', 'পঁচাশি', 'ছিয়াশি', 'সাতাশি', 'অষ্টআশি', 'ঊননব্বই',
    'নব্বই', 'একানব্বই', 'বানব্বই', 'তিরানব্বই', 'চুরানব্বই', 'পঁচানব্বই', 'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই'
  ];

  /// Converts [amount] into written Bengali words suffixed with 'টাকা মাত্র'.
  /// Example: 25500 -> "পঁচিশ হাজার পাঁচশত টাকা মাত্র"
  static String convert(int amount) {
    if (amount <= 0) {
      return 'শূন্য টাকা মাত্র';
    }

    final buffer = StringBuffer();

    // 1 Crore = 1,00,00,000 (10^7)
    final crore = amount ~/ 10000000;
    var remainder = amount % 10000000;

    if (crore > 0) {
      buffer.write(_convertPart(crore));
      buffer.write(' কোটি ');
    }

    // 1 Lakh = 1,00,000 (10^5)
    final lakh = remainder ~/ 100000;
    remainder = remainder % 100000;

    if (lakh > 0) {
      buffer.write(_convertPart(lakh));
      buffer.write(' লক্ষ ');
    }

    // 1 Thousand = 1,000 (10^3)
    final thousand = remainder ~/ 1000;
    remainder = remainder % 1000;

    if (thousand > 0) {
      buffer.write(_convertPart(thousand));
      buffer.write(' হাজার ');
    }

    // 1 Hundred = 100 (10^2)
    final hundred = remainder ~/ 100;
    remainder = remainder % 100;

    if (hundred > 0) {
      buffer.write(_convertPart(hundred));
      buffer.write('শত ');
    }

    // Remaining 0-99
    if (remainder > 0) {
      buffer.write(_units0To99[remainder]);
      buffer.write(' ');
    }

    final result = buffer.toString().trim();
    return '$result টাকা মাত্র';
  }

  static String _convertPart(int n) {
    if (n < 100) {
      return _units0To99[n];
    }
    // Recursive for crore of crores if needed
    final hundred = n ~/ 100;
    final rem = n % 100;
    if (rem == 0) {
      return '${_units0To99[hundred]}শত';
    }
    return '${_units0To99[hundred]}শত ${_units0To99[rem]}';
  }
}
