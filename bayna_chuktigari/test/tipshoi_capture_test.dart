import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/signatures/domain/digital_signature.dart';
import 'package:bayna_chuktigari/features/signatures/domain/tipshoi_capture.dart';
import 'package:bayna_chuktigari/features/vault/domain/agreement_record.dart';

void main() {
  group('Story 4.2: Tipshoi (টিপসই) Physical Thumbprint Capture Tests', () {
    test('TipshoiCapture preserves finger specifications and square 1:1 ratio', () {
      final tipshoi = TipshoiCapture(
        id: 'tip-1',
        signerName: 'আনোয়ারা বেগম',
        role: PartyRole.firstParty,
        finger: ThumbprintFinger.leftThumb,
        imagePath: '/storage/emulated/0/Bayna/tipshoi_1.jpg',
        capturedAt: DateTime(2026, 9, 30),
      );

      expect(tipshoi.finger.titleBn, equals('বাম বৃদ্ধাঙ্গুলি'));
      expect(tipshoi.aspectRatio, equals(1.0));
      expect(tipshoi.imagePath, isNotEmpty);
    });

    test('PartyAttestation validates presence of either valid signature or physical tipshoi', () {
      // 1. Unattested
      final emptyAttestation = PartyAttestation(
        role: PartyRole.firstParty,
        partyName: 'করিম মিয়া',
      );

      expect(emptyAttestation.hasAttestation, isFalse);
      expect(emptyAttestation.validate(), equals('স্বাক্ষর অথবা টিপসই প্রদান করুন'));

      // 2. Attested via Tipshoi
      final tipshoiAttested = PartyAttestation(
        role: PartyRole.firstParty,
        partyName: 'করিম মিয়া',
        tipshoi: TipshoiCapture(
          id: 'tip-2',
          signerName: 'করিম মিয়া',
          role: PartyRole.firstParty,
          finger: ThumbprintFinger.rightThumb,
          imagePath: '/path/thumb.png',
          capturedAt: DateTime(2026, 9, 30),
        ),
      );

      expect(tipshoiAttested.hasAttestation, isTrue);
      expect(tipshoiAttested.validate(), isNull);

      // 3. Attested via Digital Signature
      final stroke = SignatureStroke(
        points: List.generate(
          16,
          (i) => SignaturePoint(x: i.toDouble(), y: i.toDouble(), timestampMs: i),
        ),
      );
      final sigAttested = PartyAttestation(
        role: PartyRole.secondParty,
        partyName: 'রহিম মোল্লা',
        signature: DigitalSignature(
          id: 'sig-valid',
          signerName: 'রহিম মোল্লা',
          role: PartyRole.secondParty,
          strokes: [stroke],
          signedAt: DateTime(2026, 9, 30),
        ),
      );

      expect(sigAttested.hasAttestation, isTrue);
      expect(sigAttested.validate(), isNull);

      // 4. Invalid signature (< 15 points) without tipshoi
      final invalidSigAttested = PartyAttestation(
        role: PartyRole.firstParty,
        partyName: 'করিম মিয়া',
        signature: DigitalSignature(
          id: 'sig-inv',
          signerName: 'করিম মিয়া',
          role: PartyRole.firstParty,
          strokes: [
            SignatureStroke(
              points: [const SignaturePoint(x: 1, y: 1, timestampMs: 0)],
            ),
          ],
          signedAt: DateTime(2026, 9, 30),
        ),
      );

      expect(invalidSigAttested.hasAttestation, isFalse);
    });

    test('Serialization to/from JSON roundtrips cleanly for Tipshoi and PartyAttestation', () {
      final attestation = PartyAttestation(
        role: PartyRole.firstParty,
        partyName: 'হাফেজ মো. ইউনুস',
        tipshoi: TipshoiCapture(
          id: 'tip-rt',
          signerName: 'হাফেজ মো. ইউনুস',
          role: PartyRole.firstParty,
          finger: ThumbprintFinger.leftThumb,
          imagePath: '/vault/signatures/tipshoi_yunus.jpg',
          capturedAt: DateTime(2026, 9, 30, 10, 30),
          base64Thumbnail: 'base64ThumbnailDataThumb',
        ),
      );

      final json = attestation.toJson();
      final restored = PartyAttestation.fromJson(json);

      expect(restored.role, equals(PartyRole.firstParty));
      expect(restored.partyName, equals('হাফেজ মো. ইউনুস'));
      expect(restored.hasAttestation, isTrue);
      expect(restored.tipshoi?.finger, equals(ThumbprintFinger.leftThumb));
      expect(restored.tipshoi?.base64Thumbnail, equals('base64ThumbnailDataThumb'));
    });

    test('AgreementRecord preserves Tipshoi thumbprint image path and finger specification', () {
      final record = AgreementRecord(
        documentId: 'DD-2026-00001',
        titleBn: 'বায়না চুক্তি',
        templateId: 'vehicle_sale',
        firstPartyName: 'করিম সাহেব',
        firstPartyMobile: '01711111111',
        secondPartyName: 'রহিম সাহেব',
        secondPartyMobile: '01822222222',
        totalAmount: 50000,
        dueAmount: 10000,
        createdAt: DateTime(2026, 10, 4),
        pdfPath: 'local://documents/DD-2026-00001.pdf',
        sha256Hash: 'dummyhash123',
        firstPartyTipshoiPath: '/data/user/0/tipshoi_p1.png',
        firstPartyFinger: 'ডান বৃদ্ধাঙ্গুলি',
        secondPartySignature: 'রহিম সাহেব',
      );

      final json = record.toJson();
      expect(json['firstPartyTipshoiPath'], equals('/data/user/0/tipshoi_p1.png'));
      expect(json['firstPartyFinger'], equals('ডান বৃদ্ধাঙ্গুলি'));
      expect(json['secondPartySignature'], equals('রহিম সাহেব'));

      final restored = AgreementRecord.fromJson(json);
      expect(restored.firstPartyTipshoiPath, equals('/data/user/0/tipshoi_p1.png'));
      expect(restored.firstPartyFinger, equals('ডান বৃদ্ধাঙ্গুলি'));
      expect(restored.secondPartySignature, equals('রহিম সাহেব'));
    });
  });
}
