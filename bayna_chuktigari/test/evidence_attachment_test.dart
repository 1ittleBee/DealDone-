import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/evidence_attachment.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/transaction_terms.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/wizard_state.dart';

void main() {
  group('Story 3.3: Photo & Physical Evidence Attachment Tests', () {
    test('EvidenceAttachment accurately calculates size limit threshold', () {
      final valid = EvidenceAttachment(
        id: 'att-1',
        filePath: '/data/user/0/com.bayna/app_flutter/nid_front.jpg',
        titleBn: 'জাতীয় পরিচয়পত্র (সামনের অংশ)',
        type: AttachmentType.nidCard,
        fileSizeBytes: 245 * 1024, // 245 KB
        capturedAt: DateTime(2026, 9, 30),
      );

      expect(valid.isWithinSizeLimit, isTrue);

      final oversized = valid.copyWith(fileSizeBytes: 301 * 1024); // 301 KB
      expect(oversized.isWithinSizeLimit, isFalse);
    });

    test('AttachmentManager enforces strict maximum limit of 3 attachments', () {
      final manager = AttachmentManager();
      expect(manager.canAddMore, isTrue);

      manager.addAttachment(
        EvidenceAttachment(
          id: '1',
          filePath: '/path/1.jpg',
          titleBn: 'NID Front',
          fileSizeBytes: 100 * 1024,
          capturedAt: DateTime.now(),
        ),
      );
      manager.addAttachment(
        EvidenceAttachment(
          id: '2',
          filePath: '/path/2.jpg',
          titleBn: 'NID Back',
          fileSizeBytes: 150 * 1024,
          capturedAt: DateTime.now(),
        ),
      );
      manager.addAttachment(
        EvidenceAttachment(
          id: '3',
          filePath: '/path/3.jpg',
          titleBn: 'Receipt',
          fileSizeBytes: 200 * 1024,
          capturedAt: DateTime.now(),
        ),
      );

      expect(manager.count, equals(3));
      expect(manager.canAddMore, isFalse);

      // Attempting to add a 4th attachment throws StateError
      expect(
        () => manager.addAttachment(
          EvidenceAttachment(
            id: '4',
            filePath: '/path/4.jpg',
            titleBn: 'Extra',
            fileSizeBytes: 50 * 1024,
            capturedAt: DateTime.now(),
          ),
        ),
        throwsStateError,
      );
    });

    test('AttachmentManager rejects attachments exceeding 300KB budget', () {
      final manager = AttachmentManager();

      expect(
        () => manager.addAttachment(
          EvidenceAttachment(
            id: 'heavy',
            filePath: '/path/heavy.png',
            titleBn: 'High-Res Photo',
            fileSizeBytes: 307201, // 1 byte over 300KB
            capturedAt: DateTime.now(),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('AttachmentManager successfully removes attachment by ID', () {
      final manager = AttachmentManager();
      manager.addAttachment(
        EvidenceAttachment(
          id: 'remove-me',
          filePath: '/path/temp.jpg',
          titleBn: 'Temp',
          fileSizeBytes: 1024,
          capturedAt: DateTime.now(),
        ),
      );

      expect(manager.count, equals(1));
      final removed = manager.removeAttachment('remove-me');
      expect(removed, isTrue);
      expect(manager.count, equals(0));
    });

    test('WizardDraftState validates Step 3 and serializes attachments cleanly', () {
      final state = WizardDraftState(
        templateId: 'used_vehicle_gadget_sale',
        templateTitleBn: 'পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি',
        firstParty: const PartyDetails(
          name: 'করিম মিয়া',
          mobileNumber: '01711223344',
        ),
        secondParty: const PartyDetails(
          name: 'রহিম মোল্লা',
          mobileNumber: '01811223344',
        ),
        terms: const TransactionTerms(totalAmount: 50000),
        attachments: [
          EvidenceAttachment(
            id: 'att-nid',
            filePath: '/storage/nid.jpg',
            titleBn: 'জাতীয় পরিচয়পত্র',
            type: AttachmentType.nidCard,
            fileSizeBytes: 180 * 1024,
            capturedAt: DateTime(2026, 9, 30),
            base64Thumbnail: 'base64ThumbnailData',
          ),
        ],
      );

      expect(state.isEvidenceValid, isTrue);
      expect(state.canProceedToStep4, isTrue);

      final json = state.toJson();
      final restored = WizardDraftState.fromJson(json);

      expect(restored.attachments.length, equals(1));
      expect(restored.attachments.first.id, equals('att-nid'));
      expect(restored.attachments.first.type, equals(AttachmentType.nidCard));
      expect(restored.attachments.first.base64Thumbnail, equals('base64ThumbnailData'));
      expect(restored.canProceedToStep4, isTrue);
    });
  });
}
