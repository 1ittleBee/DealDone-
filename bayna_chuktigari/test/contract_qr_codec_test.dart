import 'package:flutter_test/flutter_test.dart';
import 'package:bayna_chuktigari/features/pdf_generator/domain/sha256_digest_service.dart';
import 'package:bayna_chuktigari/features/qr_scanner/domain/contract_qr_codec.dart';

void main() {
  group('ContractQrCodeCodec Proprietary Contract QR Tests', () {
    const payload = CanonicalAgreementPayload(
      documentId: 'BC-2026-00042',
      templateId: 'used_vehicle_gadget_sale',
      timestampIso: '2026-03-29T12:00:00.000Z',
      firstPartyName: 'রফিকুল ইসলাম',
      firstPartyMobile: '01712000000',
      secondPartyName: 'কামাল হোসেন',
      secondPartyMobile: '01812000000',
      totalAmount: 50000,
      dueAmount: 10000,
    );

    test('Encodes contract into DealDone proprietary format with prefix', () {
      final qrString = ContractQrCodeCodec.encode(
        payload: payload,
        titleBn: 'পুরাতন গাড়ি বিক্রয় চুক্তি',
      );

      expect(qrString.startsWith('DEALDONE-CONTRACT-V1:'), isTrue);
      expect(ContractQrCodeCodec.isDealDoneQrCode(qrString), isTrue);
    });

    test('Decodes and cryptographically verifies authentic DealDone QR code', () {
      final qrString = ContractQrCodeCodec.encode(
        payload: payload,
        titleBn: 'পুরাতন গাড়ি বিক্রয় চুক্তি',
      );

      final result = ContractQrCodeCodec.decodeAndVerify(qrString);

      expect(result.isDealDone, isTrue);
      expect(result.isTampered, isFalse);
      expect(result.isValid, isTrue);
      expect(result.documentId, 'BC-2026-00042');
      expect(result.firstPartyName, 'রফিকুল ইসলাম');
      expect(result.secondPartyName, 'কামাল হোসেন');
      expect(result.totalAmount, 50000);
      expect(result.dueAmount, 10000);
    });

    test('Rejects arbitrary non-DealDone QR codes (URLs, WiFi, random text)', () {
      expect(ContractQrCodeCodec.isDealDoneQrCode('https://google.com'), isFalse);
      expect(ContractQrCodeCodec.isDealDoneQrCode('WIFI:S:MyWifi;P:password;;'), isFalse);
      expect(ContractQrCodeCodec.isDealDoneQrCode('Random plain text QR code'), isFalse);

      final result = ContractQrCodeCodec.decodeAndVerify('https://example.com/not-a-contract');
      expect(result.isDealDone, isFalse);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('DealDone'));
    });

    test('Detects tampered data when hash does not match payload facts', () {
      final validQr = ContractQrCodeCodec.encode(
        payload: payload,
        titleBn: 'পুরাতন গাড়ি বিক্রয় চুক্তি',
      );

      // Tamper with the base64 part
      final tamperedQr = validQr.replaceAll('A', 'B');
      final result = ContractQrCodeCodec.decodeAndVerify(tamperedQr);

      // Either decoding fails or hash mismatch is detected
      expect(result.isValid, isFalse);
    });
  });
}
