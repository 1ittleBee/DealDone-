import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_validator.dart';
import 'agreement_record.dart';

/// Search engine supporting multi-field lookup across parties, phone numbers, and IDs.
class VaultSearchEngine {
  /// Evaluates whether an agreement record matches the user's search query.
  static bool matches(AgreementRecord record, String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final normalizedDigitsQuery = PartyValidator.normalizeDigits(query);

    // 1. Document ID match
    if (record.documentId.toLowerCase().contains(lowerQuery)) {
      return true;
    }

    // 2. Party names match (Bengali or English)
    if (record.firstPartyName.toLowerCase().contains(lowerQuery) ||
        record.secondPartyName.toLowerCase().contains(lowerQuery)) {
      return true;
    }

    // 3. Agreement title match
    if (record.titleBn.toLowerCase().contains(lowerQuery)) {
      return true;
    }

    // 4. Mobile number match (handles both Bengali numerals and ASCII digits)
    if (normalizedDigitsQuery.isNotEmpty) {
      final p1Digits = PartyValidator.normalizeDigits(record.firstPartyMobile);
      final p2Digits = PartyValidator.normalizeDigits(record.secondPartyMobile);
      if (p1Digits.contains(normalizedDigitsQuery) ||
          p2Digits.contains(normalizedDigitsQuery)) {
        return true;
      }
    }

    return false;
  }
}

/// Abstract contract for local vault storage.
abstract class VaultRepository {
  Future<void> saveAgreement(AgreementRecord record);
  Future<AgreementRecord?> getAgreement(String documentId);
  Future<List<AgreementRecord>> getAllAgreements();
  Future<List<AgreementRecord>> searchAgreements(String query);
  Future<bool> deleteAgreement(String documentId);
  Future<int> getCount();
}

/// In-memory/local encrypted storage implementation for the agreement vault.
class LocalVaultRepository implements VaultRepository {
  final Map<String, AgreementRecord> _storage = {};

  LocalVaultRepository([List<AgreementRecord>? initialRecords]) {
    if (initialRecords != null) {
      for (final r in initialRecords) {
        _storage[r.documentId] = r;
      }
    }
  }

  @override
  Future<void> saveAgreement(AgreementRecord record) async {
    _storage[record.documentId] = record;
  }

  @override
  Future<AgreementRecord?> getAgreement(String documentId) async {
    return _storage[documentId];
  }

  @override
  Future<List<AgreementRecord>> getAllAgreements() async {
    final list = _storage.values.toList();
    // Sort reverse-chronologically (newest first)
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<AgreementRecord>> searchAgreements(String query) async {
    final all = await getAllAgreements();
    return all.where((record) => VaultSearchEngine.matches(record, query)).toList();
  }

  @override
  Future<bool> deleteAgreement(String documentId) async {
    return _storage.remove(documentId) != null;
  }

  @override
  Future<int> getCount() async {
    return _storage.length;
  }
}
