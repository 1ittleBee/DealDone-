import 'package:bayna_chuktigari/core/utils/bangla_currency_words.dart';
import 'package:bayna_chuktigari/core/utils/bangla_date_formatter.dart';

/// Represents a persistent agreement record stored in the local encrypted vault.
class AgreementRecord {
  final String documentId;
  final String titleBn;
  final String templateId;
  final String firstPartyName;
  final String firstPartyMobile;
  final String secondPartyName;
  final String secondPartyMobile;
  final int totalAmount;
  final int dueAmount;
  final DateTime createdAt;
  final String pdfPath;
  final String sha256Hash;

  const AgreementRecord({
    required this.documentId,
    required this.titleBn,
    required this.templateId,
    required this.firstPartyName,
    required this.firstPartyMobile,
    required this.secondPartyName,
    required this.secondPartyMobile,
    required this.totalAmount,
    this.dueAmount = 0,
    required this.createdAt,
    required this.pdfPath,
    required this.sha256Hash,
  });

  /// Amount in formal Bengali legal words.
  String get amountInWords => BanglaCurrencyWords.convert(totalAmount);

  /// Localized Bengali creation date.
  String get formattedDateBn => BanglaDateFormatter.formatBengali(createdAt);

  AgreementRecord copyWith({
    String? documentId,
    String? titleBn,
    String? templateId,
    String? firstPartyName,
    String? firstPartyMobile,
    String? secondPartyName,
    String? secondPartyMobile,
    int? totalAmount,
    int? dueAmount,
    DateTime? createdAt,
    String? pdfPath,
    String? sha256Hash,
  }) {
    return AgreementRecord(
      documentId: documentId ?? this.documentId,
      titleBn: titleBn ?? this.titleBn,
      templateId: templateId ?? this.templateId,
      firstPartyName: firstPartyName ?? this.firstPartyName,
      firstPartyMobile: firstPartyMobile ?? this.firstPartyMobile,
      secondPartyName: secondPartyName ?? this.secondPartyName,
      secondPartyMobile: secondPartyMobile ?? this.secondPartyMobile,
      totalAmount: totalAmount ?? this.totalAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      createdAt: createdAt ?? this.createdAt,
      pdfPath: pdfPath ?? this.pdfPath,
      sha256Hash: sha256Hash ?? this.sha256Hash,
    );
  }

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'titleBn': titleBn,
        'templateId': templateId,
        'firstPartyName': firstPartyName,
        'firstPartyMobile': firstPartyMobile,
        'secondPartyName': secondPartyName,
        'secondPartyMobile': secondPartyMobile,
        'totalAmount': totalAmount,
        'dueAmount': dueAmount,
        'createdAt': createdAt.toIso8601String(),
        'pdfPath': pdfPath,
        'sha256Hash': sha256Hash,
      };

  factory AgreementRecord.fromJson(Map<String, dynamic> json) => AgreementRecord(
        documentId: json['documentId'] as String? ?? '',
        titleBn: json['titleBn'] as String? ?? '',
        templateId: json['templateId'] as String? ?? '',
        firstPartyName: json['firstPartyName'] as String? ?? '',
        firstPartyMobile: json['firstPartyMobile'] as String? ?? '',
        secondPartyName: json['secondPartyName'] as String? ?? '',
        secondPartyMobile: json['secondPartyMobile'] as String? ?? '',
        totalAmount: json['totalAmount'] as int? ?? 0,
        dueAmount: json['dueAmount'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        pdfPath: json['pdfPath'] as String? ?? '',
        sha256Hash: json['sha256Hash'] as String? ?? '',
      );
}
