import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/share/domain/whatsapp_share_service.dart';
import 'package:bayna_chuktigari/features/vault/domain/agreement_record.dart';

void main() {
  group('Story 6.2: 1-Tap WhatsApp Share & Viral Dual-Receipt Footer Tests', () {
    final record = AgreementRecord(
      documentId: 'BC-2026-00001',
      titleBn: 'বাসাভাড়া বুকিং ও অগ্রিম বায়না রশিদ',
      templateId: 'rental_flat_advance',
      firstPartyName: 'মো. হাবিবুর রহমান',
      firstPartyMobile: '01711223344',
      secondPartyName: 'তানভীর আহমেদ',
      secondPartyMobile: '01811223344',
      totalAmount: 30000,
      dueAmount: 0,
      createdAt: DateTime(2026, 9, 30),
      pdfPath: '/vault/BC-2026-00001.pdf',
      sha256Hash: 'hash-abc',
    );

    test('Normalizes various mobile formats to WhatsApp international format', () {
      expect(
        WhatsAppShareService.toInternationalWhatsAppPhone('01711223344'),
        equals('8801711223344'),
      );
      expect(
        WhatsAppShareService.toInternationalWhatsAppPhone('+8801711223344'),
        equals('8801711223344'),
      );
      expect(
        WhatsAppShareService.toInternationalWhatsAppPhone('8801711223344'),
        equals('8801711223344'),
      );
      expect(
        WhatsAppShareService.toInternationalWhatsAppPhone('০১৭১১২২৩৩৪৪'),
        equals('8801711223344'),
      );
    });

    test('Formats respectful Bengali share message with viral footer attribution', () {
      final message = WhatsAppShareService.formatShareMessage(record);

      expect(message, contains('আসসালামু আলাইকুম'));
      expect(message, contains('বাসাভাড়া বুকিং ও অগ্রিম বায়না রশিদ'));
      expect(message, contains('নথি নং: BC-2026-00001'));
      expect(message, contains('মোট টাকার পরিমাণ: ত্রিশ হাজার টাকা মাত্র'));
      expect(
        message,
        contains("✓ এই ডিজিটাল চুক্তিপত্রটি তৈরি হয়েছে 'DealDone' অ্যাপ দিয়ে।"),
      );
    });

    test('Generates valid WhatsApp Click-to-Chat URI with encoded parameters', () {
      final message = WhatsAppShareService.formatShareMessage(record);
      final uri = WhatsAppShareService.generateWhatsAppClickToChatUri(
        record.secondPartyMobile,
        message,
      );

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('wa.me'));
      expect(uri.path, equals('/8801811223344'));
      expect(uri.queryParameters['text'], equals(message));

      final url = WhatsAppShareService.generateWhatsAppUrl(
        record.secondPartyMobile,
        message,
      );
      expect(url, startsWith('https://wa.me/8801811223344?text='));
    });
  });
}
