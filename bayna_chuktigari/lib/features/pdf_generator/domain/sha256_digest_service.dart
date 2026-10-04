import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:bayna_chuktigari/core/utils/bangla_date_formatter.dart';

/// Canonical representation of core agreement facts for tamper-evident hashing.
class CanonicalAgreementPayload {
  final String documentId;
  final String templateId;
  final String timestampIso;
  final String firstPartyName;
  final String firstPartyMobile;
  final String secondPartyName;
  final String secondPartyMobile;
  final int totalAmount;
  final int dueAmount;

  const CanonicalAgreementPayload({
    required this.documentId,
    required this.templateId,
    required this.timestampIso,
    required this.firstPartyName,
    required this.firstPartyMobile,
    required this.secondPartyName,
    required this.secondPartyMobile,
    required this.totalAmount,
    required this.dueAmount,
  });

  /// Produces deterministic canonical JSON string with strictly sorted keys.
  String toCanonicalJson() {
    final map = <String, dynamic>{
      'documentId': documentId.trim(),
      'dueAmount': dueAmount,
      'firstPartyMobile': firstPartyMobile.trim(),
      'firstPartyName': firstPartyName.trim(),
      'secondPartyMobile': secondPartyMobile.trim(),
      'secondPartyName': secondPartyName.trim(),
      'templateId': templateId.trim(),
      'timestampIso': timestampIso.trim(),
      'totalAmount': totalAmount,
    };
    return jsonEncode(map);
  }

  /// Computes the cryptographic SHA-256 digest over the canonical JSON representation.
  String computeSha256Digest() {
    final canonicalBytes = utf8.encode(toCanonicalJson());
    return sha256.convert(canonicalBytes).toString();
  }

  /// Formats the payload into a high-density, multi-line QR verification string
  /// conforming to Section 65B of Evidence (Amendment) Act 2022.
  String generateQrVerificationText() {
    final hash = computeSha256Digest();
    final totalBn = BanglaDateFormatter.toBengaliDigits(totalAmount);
    final dueBn = BanglaDateFormatter.toBengaliDigits(dueAmount);

    return 'DEALDONE-VERIFICATION\n'
        'ID: $documentId\n'
        '১ম পক্ষ: $firstPartyName ($firstPartyMobile)\n'
        '২য় পক্ষ: $secondPartyName ($secondPartyMobile)\n'
        'মোট টাকা: ৳$totalBn | বকেয়া: ৳$dueBn\n'
        'SHA256: $hash\n'
        'URI: dealdone://verify?id=$documentId&h=$hash';
  }

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'templateId': templateId,
        'timestampIso': timestampIso,
        'firstPartyName': firstPartyName,
        'firstPartyMobile': firstPartyMobile,
        'secondPartyName': secondPartyName,
        'secondPartyMobile': secondPartyMobile,
        'totalAmount': totalAmount,
        'dueAmount': dueAmount,
      };

  factory CanonicalAgreementPayload.fromJson(Map<String, dynamic> json) =>
      CanonicalAgreementPayload(
        documentId: json['documentId'] as String? ?? '',
        templateId: json['templateId'] as String? ?? '',
        timestampIso: json['timestampIso'] as String? ?? '',
        firstPartyName: json['firstPartyName'] as String? ?? '',
        firstPartyMobile: json['firstPartyMobile'] as String? ?? '',
        secondPartyName: json['secondPartyName'] as String? ?? '',
        secondPartyMobile: json['secondPartyMobile'] as String? ?? '',
        totalAmount: json['totalAmount'] as int? ?? 0,
        dueAmount: json['dueAmount'] as int? ?? 0,
      );
}

/// Service providing SHA-256 verification and tamper detection.
class Sha256DigestService {
  /// Computes the SHA-256 digest of the given canonical payload.
  static String calculateDigest(CanonicalAgreementPayload payload) {
    return payload.computeSha256Digest();
  }

  /// Verifies if a given hash matches the payload's re-computed digest.
  static bool verifyIntegrity(CanonicalAgreementPayload payload, String expectedHash) {
    final actualHash = payload.computeSha256Digest();
    return actualHash.toLowerCase() == expectedHash.trim().toLowerCase();
  }
}
