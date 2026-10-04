import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/pdf_generator/domain/document_id_generator.dart';

void main() {
  group('Story 5.2: Unique Document ID & Sequential Stamping Tests', () {
    test('Generates sequential document IDs with zero-padding and year', () {
      final docId1 = DocumentIdGenerator.generate(1, year: 2026);
      expect(docId1, equals('BC-2026-00001'));

      final docId42 = DocumentIdGenerator.generate(42, year: 2026);
      expect(docId42, equals('BC-2026-00042'));

      final docIdMax = DocumentIdGenerator.generate(99999, year: 2026);
      expect(docIdMax, equals('BC-2026-99999'));
    });

    test('Rejects invalid sequence numbers outside 1..99999 range', () {
      expect(() => DocumentIdGenerator.generate(0, year: 2026), throwsArgumentError);
      expect(() => DocumentIdGenerator.generate(-5, year: 2026), throwsArgumentError);
      expect(() => DocumentIdGenerator.generate(100000, year: 2026), throwsArgumentError);
    });

    test('Validates document ID format strictly with regex', () {
      expect(DocumentIdGenerator.isValid('BC-2026-00001'), isTrue);
      expect(DocumentIdGenerator.isValid('BC-2030-12345'), isTrue);

      expect(DocumentIdGenerator.isValid(null), isFalse);
      expect(DocumentIdGenerator.isValid(''), isFalse);
      expect(DocumentIdGenerator.isValid('BC-26-00001'), isFalse); // Year not 4 digits
      expect(DocumentIdGenerator.isValid('BC-2026-1'), isFalse); // Sequence not 5 digits
      expect(DocumentIdGenerator.isValid('AB-2026-00001'), isFalse); // Wrong prefix
      expect(DocumentIdGenerator.isValid('BC-2026-00001X'), isFalse); // Extra characters
    });

    test('Correctly extracts year and sequence parts from document ID', () {
      const docId = 'BC-2026-00789';

      expect(DocumentIdGenerator.extractYear(docId), equals(2026));
      expect(DocumentIdGenerator.extractSequence(docId), equals(789));

      expect(DocumentIdGenerator.extractYear('invalid'), isNull);
      expect(DocumentIdGenerator.extractSequence('invalid'), isNull);
    });

    test('DocumentStamp formats localized Bengali header and serializes cleanly', () {
      final stamp = DocumentStamp(
        documentId: 'BC-2026-00001',
        createdAt: DateTime(2026, 9, 30, 14, 30),
      );

      expect(stamp.documentId, equals('BC-2026-00001'));
      expect(stamp.formattedDateBn, equals('৩০ সেপ্টেম্বর ২০২৬'));
      expect(stamp.formattedNumericDateBn, equals('৩০/০৯/২০২৬'));
      expect(
        stamp.headerStampBn,
        equals('নথি নং: BC-2026-00001 | তারিখ: ৩০ সেপ্টেম্বর ২০২৬'),
      );

      final json = stamp.toJson();
      final restored = DocumentStamp.fromJson(json);

      expect(restored.documentId, equals('BC-2026-00001'));
      expect(restored.headerStampBn, equals(stamp.headerStampBn));
    });
  });
}
