import 'package:test/test.dart';
import '../lib/core/utils/bangla_currency_words.dart';

void main() {
  group('Story 1.3: BanglaCurrencyWords Converter Tests', () {
    test('Converts zero and negative amounts safely', () {
      expect(BanglaCurrencyWords.convert(0), equals('শূন্য টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(-500), equals('শূন্য টাকা মাত্র'));
    });

    test('Converts single and double digit amounts (1 to 99)', () {
      expect(BanglaCurrencyWords.convert(1), equals('এক টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(7), equals('সাত টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(15), equals('পনেরো টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(50), equals('পঞ্চাশ টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(99), equals('নিরানব্বই টাকা মাত্র'));
    });

    test('Converts hundreds', () {
      expect(BanglaCurrencyWords.convert(100), equals('একশত টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(500), equals('পাঁচশত টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(725), equals('সাতশত পঁচিশ টাকা মাত্র'));
    });

    test('Converts thousands (1,000 to 99,999)', () {
      expect(BanglaCurrencyWords.convert(1000), equals('এক হাজার টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(5000), equals('পাঁচ হাজার টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(10000), equals('দশ হাজার টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(25500), equals('পঁচিশ হাজার পাঁচশত টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(30000), equals('ত্রিশ হাজার টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(78450), equals('আঠাত্তর হাজার চারশত পঞ্চাশ টাকা মাত্র'));
    });

    test('Converts lakhs (1,00,000 to 99,99,999)', () {
      expect(BanglaCurrencyWords.convert(100000), equals('এক লক্ষ টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(165000), equals('এক লক্ষ পঁয়ষট্টি হাজার টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(1520300), equals('পনেরো লক্ষ বিশ হাজার তিনশত টাকা মাত্র'));
    });

    test('Converts crores (1,00,00,000 to 99,99,99,999)', () {
      expect(BanglaCurrencyWords.convert(10000000), equals('এক কোটি টাকা মাত্র'));
      expect(BanglaCurrencyWords.convert(50000000), equals('পাঁচ কোটি টাকা মাত্র'));
      expect(
        BanglaCurrencyWords.convert(50050712),
        equals('পাঁচ কোটি পঞ্চাশ হাজার সাতশত বারো টাকা মাত্র'),
      );
    });
  });
}
