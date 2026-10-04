import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_validator.dart';
import 'package:bayna_chuktigari/features/vault/domain/agreement_record.dart';

/// Formatter and URL generator for 1-Tap WhatsApp dispatch with culturally resonant Bengali phrasing.
class WhatsAppShareService {
  static const String viralFooterBn =
      "✓ এই ডিজিটাল চুক্তিপত্রটি তৈরি হয়েছে 'DealDone' অ্যাপ দিয়ে।";

  /// Formats respectful, formal message text for sending via WhatsApp.
  static String formatShareMessage(AgreementRecord record) {
    return 'আসসালামু আলাইকুম। আমাদের আজকের ${record.titleBn} সংক্রান্ত স্মারক ও রসিদের কপি সংযুক্ত করা হলো।\n\n'
        'নথি নং: ${record.documentId}\n'
        'তারিখ: ${record.formattedDateBn}\n'
        'মোট টাকার পরিমাণ: ${record.amountInWords}\n\n'
        '$viralFooterBn';
  }

  /// Normalizes Bangladeshi mobile numbers to WhatsApp E.164 without plus: 8801XXXXXXXXX.
  static String toInternationalWhatsAppPhone(String mobile) {
    String digits = PartyValidator.normalizeDigits(mobile);
    if (digits.startsWith('+880')) {
      return digits.substring(1);
    }
    if (digits.startsWith('880')) {
      return digits;
    }
    if (digits.startsWith('0')) {
      return '88$digits';
    }
    return '880$digits';
  }

  /// Generates a valid WhatsApp Click-to-Chat URI.
  static Uri generateWhatsAppClickToChatUri(String mobile, String message) {
    final intlPhone = toInternationalWhatsAppPhone(mobile);
    final encodedText = Uri.encodeComponent(message);
    return Uri.parse('https://wa.me/$intlPhone?text=$encodedText');
  }

  /// Convenience string URL generator.
  static String generateWhatsAppUrl(String mobile, String message) {
    return generateWhatsAppClickToChatUri(mobile, message).toString();
  }
}
