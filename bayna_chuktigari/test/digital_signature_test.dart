import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/signatures/domain/digital_signature.dart';

void main() {
  group('Story 4.1: Dual-Party On-Screen Vector Signature Canvas Tests', () {
    test('Enforces strict minimum 15-point attestation threshold', () {
      // Empty signature
      final emptySig = DigitalSignature(
        id: 'sig-1',
        signerName: 'আনিসুর রহমান',
        role: PartyRole.firstParty,
        strokes: const [],
        signedAt: DateTime(2026, 9, 30),
      );

      expect(emptySig.isValid, isFalse);
      expect(emptySig.validate(), equals('স্বাক্ষর প্রদান করুন'));

      // 5 points only (accidental tap or single dot)
      final shortStroke = SignatureStroke(
        points: List.generate(
          5,
          (i) => SignaturePoint(x: i * 2.0, y: i * 3.0, timestampMs: i * 10),
        ),
      );

      final shortSig = emptySig.copyWith(strokes: [shortStroke]);
      expect(shortSig.totalPoints, equals(5));
      expect(shortSig.isValid, isFalse);
      expect(
        shortSig.validate(),
        equals('স্বাক্ষর সম্পন্ন করতে আরও স্পষ্ট করে আঁকুন (কমপক্ষে ১৫টি পয়েন্ট)'),
      );
    });

    test('Validates signature when points exceed or equal 15 points', () {
      final stroke1 = SignatureStroke(
        points: List.generate(
          10,
          (i) => SignaturePoint(x: 10.0 + i, y: 20.0 + i, timestampMs: i * 10),
        ),
      );
      final stroke2 = SignatureStroke(
        points: List.generate(
          8,
          (i) => SignaturePoint(x: 30.0 + i, y: 40.0 + i, timestampMs: 100 + i * 10),
        ),
      );

      final validSig = DigitalSignature(
        id: 'sig-2',
        signerName: 'ফরিদা বেগম',
        role: PartyRole.secondParty,
        strokes: [stroke1, stroke2],
        signedAt: DateTime(2026, 9, 30),
      );

      expect(validSig.totalPoints, equals(18));
      expect(validSig.isValid, isTrue);
      expect(validSig.validate(), isNull);
    });

    test('Generates valid SVG path data for vector rendering', () {
      final stroke = SignatureStroke(
        points: [
          const SignaturePoint(x: 10.0, y: 15.0, timestampMs: 0),
          const SignaturePoint(x: 12.0, y: 18.0, timestampMs: 10),
          const SignaturePoint(x: 15.0, y: 22.0, timestampMs: 20),
        ],
      );

      final sig = DigitalSignature(
        id: 'sig-3',
        signerName: 'করিম',
        role: PartyRole.firstParty,
        strokes: [stroke],
        signedAt: DateTime(2026, 9, 30),
      );

      final svgPath = sig.toSvgPathData();
      expect(svgPath, equals('M 10.0 15.0 L 12.0 18.0 L 15.0 22.0'));
    });

    test('Serialization to/from JSON roundtrips cleanly', () {
      final stroke = SignatureStroke(
        points: List.generate(
          16,
          (i) => SignaturePoint(x: i.toDouble(), y: (i * 2).toDouble(), timestampMs: i * 15),
        ),
      );

      final original = DigitalSignature(
        id: 'sig-roundtrip',
        signerName: 'আনিসুর রহমান',
        role: PartyRole.firstParty,
        strokes: [stroke],
        signedAt: DateTime(2026, 9, 30, 12, 0),
        base64Png: 'data:image/png;base64,iVBORw0KGgo...',
      );

      final json = original.toJson();
      final restored = DigitalSignature.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.signerName, equals(original.signerName));
      expect(restored.role, equals(PartyRole.firstParty));
      expect(restored.totalPoints, equals(16));
      expect(restored.isValid, isTrue);
      expect(restored.base64Png, equals(original.base64Png));
    });
  });
}
