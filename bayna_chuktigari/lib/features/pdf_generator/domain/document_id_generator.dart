import 'package:bayna_chuktigari/core/utils/bangla_date_formatter.dart';

/// Generator and validator for immutable Bayna document IDs in BC-{YYYY}-{XXXXX} format.
class DocumentIdGenerator {
  static final RegExp idRegex = RegExp(r'^BC-\d{4}-\d{5}$');

  /// Generates a standardized document ID: BC-2026-00001
  static String generate(int sequence, {int? year, DateTime? date}) {
    if (sequence < 1 || sequence > 99999) {
      throw ArgumentError('Sequence number must be between 1 and 99999');
    }
    final effectiveYear = year ?? (date ?? DateTime.now()).year;
    final paddedSequence = sequence.toString().padLeft(5, '0');
    return 'BC-$effectiveYear-$paddedSequence';
  }

  /// Validates format compliance: ^BC-\d{4}-\d{5}$
  static bool isValid(String? docId) {
    if (docId == null) return false;
    return idRegex.hasMatch(docId.trim());
  }

  /// Extracts the year from a valid document ID.
  static int? extractYear(String docId) {
    if (!isValid(docId)) return null;
    final parts = docId.split('-');
    return int.tryParse(parts[1]);
  }

  /// Extracts the sequence number from a valid document ID.
  static int? extractSequence(String docId) {
    if (!isValid(docId)) return null;
    final parts = docId.split('-');
    return int.tryParse(parts[2]);
  }
}

/// Formats localized header stamps with document ID and Bengali date/time.
class DocumentStamp {
  final String documentId;
  final DateTime createdAt;

  const DocumentStamp({
    required this.documentId,
    required this.createdAt,
  });

  /// Localized Bengali date (e.g., "৩০ সেপ্টেম্বর ২০২৬")
  String get formattedDateBn => BanglaDateFormatter.formatBengali(createdAt);

  /// Localized Bengali numeric date (e.g., "৩০/০৯/২০২৬")
  String get formattedNumericDateBn => BanglaDateFormatter.formatNumericBengali(createdAt);

  /// Formal header string stamped at top of vector PDF
  String get headerStampBn => 'নথি নং: $documentId | তারিখ: $formattedDateBn';

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'createdAt': createdAt.toIso8601String(),
        'headerStampBn': headerStampBn,
      };

  factory DocumentStamp.fromJson(Map<String, dynamic> json) => DocumentStamp(
        documentId: json['documentId'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
