import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/signatures/domain/digital_signature.dart';
import 'package:bayna_chuktigari/features/signatures/domain/tipshoi_capture.dart';
import 'package:bayna_chuktigari/features/signatures/domain/witness_attestation.dart';

void main() {
  group('Story 4.3: Multi-Party Witness & Rural Salish Attestation Tests', () {
    test('WitnessAttestation validates party name, mobile, and attestation status', () {
      final invalidRecord = WitnessAttestation(
        id: 'w-1',
        name: 'সাক্ষী এক',
        mobileNumber: '12345', // invalid
        attestation: const PartyAttestation(
          role: PartyRole.witness,
          partyName: 'সাক্ষী এক',
        ),
      );

      expect(invalidRecord.isValid, isFalse);
      expect(invalidRecord.validate(), equals('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন'));

      final stroke = SignatureStroke(
        points: List.generate(
          16,
          (i) => SignaturePoint(x: i.toDouble(), y: i.toDouble(), timestampMs: i),
        ),
      );

      final validRecord = invalidRecord.copyWith(
        mobileNumber: '01712345678',
        attestation: PartyAttestation(
          role: PartyRole.witness,
          partyName: 'সাক্ষী এক',
          signature: DigitalSignature(
            id: 'sig-w',
            signerName: 'সাক্ষী এক',
            role: PartyRole.witness,
            strokes: [stroke],
            signedAt: DateTime.now(),
          ),
        ),
      );

      expect(validRecord.isValid, isTrue);
      expect(validRecord.validate(), isNull);
    });

    test('MultiPartyAttestationManager enforces max 2 witnesses for standard agreements', () {
      final manager = MultiPartyAttestationManager(isSalishTemplate: false);
      expect(manager.maxAllowed, equals(2));

      final stubAttestation = PartyAttestation(
        role: PartyRole.witness,
        partyName: 'Test',
        tipshoi: TipshoiCapture(
          id: 'tip',
          signerName: 'Test',
          role: PartyRole.witness,
          imagePath: '/path',
          capturedAt: DateTime.now(),
        ),
      );

      manager.add(
        WitnessAttestation(
          id: 'w-1',
          name: 'সাক্ষী ১',
          mobileNumber: '01711111111',
          attestation: stubAttestation,
        ),
      );
      manager.add(
        WitnessAttestation(
          id: 'w-2',
          name: 'সাক্ষী ২',
          mobileNumber: '01722222222',
          attestation: stubAttestation,
        ),
      );

      expect(manager.count, equals(2));
      expect(manager.canAddMore, isFalse);

      // Attempting 3rd witness throws StateError
      expect(
        () => manager.add(
          WitnessAttestation(
            id: 'w-3',
            name: 'সাক্ষী ৩',
            mobileNumber: '01733333333',
            attestation: stubAttestation,
          ),
        ),
        throwsStateError,
      );
    });

    test('MultiPartyAttestationManager allows up to 3 elders for Village Salish', () {
      final manager = MultiPartyAttestationManager(isSalishTemplate: true);
      expect(manager.maxAllowed, equals(3));

      final stubAttestation = PartyAttestation(
        role: PartyRole.witness,
        partyName: 'Salishdar',
        tipshoi: TipshoiCapture(
          id: 'tip',
          signerName: 'Salishdar',
          role: PartyRole.witness,
          imagePath: '/path',
          capturedAt: DateTime.now(),
        ),
      );

      for (int i = 1; i <= 3; i++) {
        manager.add(
          WitnessAttestation(
            id: 's-$i',
            name: 'শালিসদার $i',
            mobileNumber: '0181111111$i',
            role: AttestationRole.salishdar,
            designation: i == 1 ? 'ইউপি সদস্য' : 'গ্রাম্য প্রধান',
            attestation: stubAttestation,
          ),
        );
      }

      expect(manager.count, equals(3));
      expect(manager.canAddMore, isFalse);

      // Attempting 4th salishdar throws StateError
      expect(
        () => manager.add(
          WitnessAttestation(
            id: 's-4',
            name: 'শালিসদার ৪',
            mobileNumber: '01811111114',
            role: AttestationRole.salishdar,
            attestation: stubAttestation,
          ),
        ),
        throwsStateError,
      );
    });

    test('Serialization to/from JSON roundtrips cleanly', () {
      final stroke = SignatureStroke(
        points: List.generate(
          16,
          (i) => SignaturePoint(x: i.toDouble(), y: i.toDouble(), timestampMs: i),
        ),
      );

      final original = WitnessAttestation(
        id: 'w-rt',
        name: 'হাজী মো. মফিজুল হক',
        mobileNumber: '01912345678',
        role: AttestationRole.salishdar,
        designation: 'সভাপতি, গ্রাম উন্নয়ন কমিটি',
        attestation: PartyAttestation(
          role: PartyRole.witness,
          partyName: 'হাজী মো. মফিজুল হক',
          signature: DigitalSignature(
            id: 'sig-rt',
            signerName: 'হাজী মো. মফিজুল হক',
            role: PartyRole.witness,
            strokes: [stroke],
            signedAt: DateTime(2026, 9, 30),
          ),
        ),
      );

      final json = original.toJson();
      final restored = WitnessAttestation.fromJson(json);

      expect(restored.id, equals('w-rt'));
      expect(restored.name, equals('হাজী মো. মফিজুল হক'));
      expect(restored.role, equals(AttestationRole.salishdar));
      expect(restored.designation, equals('সভাপতি, গ্রাম উন্নয়ন কমিটি'));
      expect(restored.isValid, isTrue);
    });
  });
}
