import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/pdf_generator/domain/sha256_digest_service.dart';

void main() {
  group('Story 5.3: SHA-256 Cryptographic Integrity Digest & QR Verification Tests', () {
    final samplePayload = CanonicalAgreementPayload(
      documentId: 'BC-2026-00001',
      templateId: 'used_vehicle_gadget_sale',
      timestampIso: '2026-09-30T10:00:00.000Z',
      firstPartyName: 'মো. রফিকুল ইসলাম',
      firstPartyMobile: '01711223344',
      secondPartyName: 'তানভীর আহমেদ',
      secondPartyMobile: '01811223344',
      totalAmount: 150000,
      dueAmount: 50000,
    );

    test('Computes valid 64-character lowercase SHA-256 hexadecimal hash', () {
      final digest = samplePayload.computeSha256Digest();

      expect(digest.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(digest), isTrue);
    });

    test('Detects tampering: even 1 digit change causes completely different hash', () {
      final originalHash = samplePayload.computeSha256Digest();

      // Tampered amount (150001 instead of 150000)
      final tamperedPayload = CanonicalAgreementPayload(
        documentId: samplePayload.documentId,
        templateId: samplePayload.templateId,
        timestampIso: samplePayload.timestampIso,
        firstPartyName: samplePayload.firstPartyName,
        firstPartyMobile: samplePayload.firstPartyMobile,
        secondPartyName: samplePayload.secondPartyName,
        secondPartyMobile: samplePayload.secondPartyMobile,
        totalAmount: 150001,
        dueAmount: samplePayload.dueAmount,
      );

      final tamperedHash = tamperedPayload.computeSha256Digest();

      expect(tamperedHash, isNot(equals(originalHash)));
      expect(Sha256DigestService.verifyIntegrity(tamperedPayload, originalHash), isFalse);
    });

    test('Verifies integrity successfully for authentic payload', () {
      final digest = Sha256DigestService.calculateDigest(samplePayload);
      expect(Sha256DigestService.verifyIntegrity(samplePayload, digest), isTrue);
    });

    test('Generates structured QR verification text with Bengali details and URI', () {
      final qrText = samplePayload.generateQrVerificationText();

      expect(qrText, contains('DEALDONE-VERIFICATION'));
      expect(qrText, contains('ID: BC-2026-00001'));
      expect(qrText, contains('১ম পক্ষ: মো. রফিকুল ইসলাম (01711223344)'));
      expect(qrText, contains('২য় পক্ষ: তানভীর আহমেদ (01811223344)'));
      expect(qrText, contains('মোট টাকা: ৳১৫০০০০'));
      expect(qrText, contains('SHA256:'));
      expect(qrText, contains('URI: dealdone://verify?id=BC-2026-00001'));
    });

    test('Serialization to/from JSON preserves all canonical fields', () {
      final json = samplePayload.toJson();
      final restored = CanonicalAgreementPayload.fromJson(json);

      expect(restored.documentId, equals(samplePayload.documentId));
      expect(restored.totalAmount, equals(150000));
      expect(restored.computeSha256Digest(), equals(samplePayload.computeSha256Digest()));
    });
  });
}
