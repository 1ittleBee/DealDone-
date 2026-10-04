import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/vault/domain/agreement_record.dart';
import 'package:bayna_chuktigari/features/vault/domain/vault_repository.dart';

void main() {
  group('Story 6.1: Encrypted Storage Vault & Multi-Field Search Tests', () {
    final record1 = AgreementRecord(
      documentId: 'BC-2026-00001',
      titleBn: 'পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি',
      templateId: 'used_vehicle_gadget_sale',
      firstPartyName: 'মো. রফিকুল ইসলাম',
      firstPartyMobile: '01711223344',
      secondPartyName: 'তানভীর আহমেদ',
      secondPartyMobile: '01811223344',
      totalAmount: 150000,
      dueAmount: 50000,
      createdAt: DateTime(2026, 9, 28, 10, 0),
      pdfPath: '/vault/pdfs/BC-2026-00001.pdf',
      sha256Hash: 'hash00001',
    );

    final record2 = AgreementRecord(
      documentId: 'BC-2026-00002',
      titleBn: 'টাকা ধার ও পরিশোধের অঙ্গীকারনামা',
      templateId: 'personal_loan_promissory',
      firstPartyName: 'আব্দুর রহিম',
      firstPartyMobile: '01912345678',
      secondPartyName: 'কামাল হোসেন',
      secondPartyMobile: '01512345678',
      totalAmount: 25000,
      dueAmount: 0,
      createdAt: DateTime(2026, 9, 30, 15, 30),
      pdfPath: '/vault/pdfs/BC-2026-00002.pdf',
      sha256Hash: 'hash00002',
    );

    test('AgreementRecord formats currency in words and localized Bengali dates', () {
      expect(record1.amountInWords, equals('এক লক্ষ পঞ্চাশ হাজার টাকা মাত্র'));
      expect(record1.formattedDateBn, equals('২৮ সেপ্টেম্বর ২০২৬'));
    });

    test('LocalVaultRepository saves, retrieves, and orders records newest first', () async {
      final repo = LocalVaultRepository();
      expect(await repo.getCount(), equals(0));

      await repo.saveAgreement(record1);
      await repo.saveAgreement(record2);

      expect(await repo.getCount(), equals(2));

      final all = await repo.getAllAgreements();
      // record2 is from Sept 30, record1 is from Sept 28 -> record2 must appear first
      expect(all.first.documentId, equals('BC-2026-00002'));
      expect(all.last.documentId, equals('BC-2026-00001'));

      final retrieved = await repo.getAgreement('BC-2026-00001');
      expect(retrieved?.firstPartyName, equals('মো. রফিকুল ইসলাম'));
    });

    test('VaultSearchEngine filters accurately by party name in Bengali', () async {
      final repo = LocalVaultRepository([record1, record2]);

      final results1 = await repo.searchAgreements('রফিকুল');
      expect(results1.length, equals(1));
      expect(results1.first.documentId, equals('BC-2026-00001'));

      final results2 = await repo.searchAgreements('কামাল');
      expect(results2.length, equals(1));
      expect(results2.first.documentId, equals('BC-2026-00002'));
    });

    test('VaultSearchEngine filters by mobile number (ASCII and Bengali digits)', () async {
      final repo = LocalVaultRepository([record1, record2]);

      // ASCII match
      final res1 = await repo.searchAgreements('01711');
      expect(res1.length, equals(1));
      expect(res1.first.documentId, equals('BC-2026-00001'));

      // Bengali digits match: '০১৭১১'
      final res2 = await repo.searchAgreements('০১৭১১');
      expect(res2.length, equals(1));
      expect(res2.first.documentId, equals('BC-2026-00001'));
    });

    test('VaultSearchEngine filters by Document ID and empty query returns all', () async {
      final repo = LocalVaultRepository([record1, record2]);

      final byId = await repo.searchAgreements('BC-2026-00002');
      expect(byId.length, equals(1));
      expect(byId.first.secondPartyName, equals('কামাল হোসেন'));

      final all = await repo.searchAgreements('');
      expect(all.length, equals(2));

      final nonExistent = await repo.searchAgreements('nonexistent_query_xyz');
      expect(nonExistent, isEmpty);
    });

    test('LocalVaultRepository successfully deletes records by document ID', () async {
      final repo = LocalVaultRepository([record1, record2]);
      expect(await repo.getCount(), equals(2));

      final deleted = await repo.deleteAgreement('BC-2026-00001');
      expect(deleted, isTrue);
      expect(await repo.getCount(), equals(1));

      final remaining = await repo.getAgreement('BC-2026-00001');
      expect(remaining, isNull);
    });

    test('Serialization to/from JSON roundtrips cleanly', () {
      final json = record1.toJson();
      final restored = AgreementRecord.fromJson(json);

      expect(restored.documentId, equals(record1.documentId));
      expect(restored.titleBn, equals(record1.titleBn));
      expect(restored.totalAmount, equals(record1.totalAmount));
      expect(restored.sha256Hash, equals(record1.sha256Hash));
    });
  });
}
