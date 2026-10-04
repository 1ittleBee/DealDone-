import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_validator.dart';
import 'package:bayna_chuktigari/features/signatures/domain/tipshoi_capture.dart';

/// Attestation role for secondary signers (Witnesses or Village Salish Arbiters).
enum AttestationRole {
  witness, // সাক্ষী
  salishdar, // শালিসদার / মুরুব্বি (Village Elder / Arbiter)
}

extension AttestationRoleExtension on AttestationRole {
  String get titleBn {
    switch (this) {
      case AttestationRole.witness:
        return 'সাক্ষী';
      case AttestationRole.salishdar:
        return 'শালিসদার / মুরুব্বি';
    }
  }

  String get sectionHeadingBn {
    switch (this) {
      case AttestationRole.witness:
        return 'সাক্ষীগণের বিবরণ ও স্বাক্ষর';
      case AttestationRole.salishdar:
        return 'শালিসদারগণের স্বাক্ষর ও মতামত';
    }
  }
}

/// Represents an attestation entry for a neutral witness or community elder.
class WitnessAttestation {
  final String id;
  final String name;
  final String mobileNumber;
  final AttestationRole role;
  final String? designation; // e.g., 'ইউপি সদস্য', 'গ্রাম্য প্রধান'
  final PartyAttestation attestation;

  const WitnessAttestation({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.role = AttestationRole.witness,
    this.designation,
    required this.attestation,
  });

  /// Validates name, mobile, and signature/tipshoi completion.
  String? validate() {
    final nameErr = PartyValidator.validateName(name);
    if (nameErr != null) return nameErr;

    final mobileErr = PartyValidator.validateMobile(mobileNumber);
    if (mobileErr != null) return mobileErr;

    if (!attestation.hasAttestation) {
      return '$name-এর স্বাক্ষর অথবা টিপসই প্রদান করুন';
    }
    return null;
  }

  bool get isValid => validate() == null;

  WitnessAttestation copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    AttestationRole? role,
    String? designation,
    PartyAttestation? attestation,
  }) {
    return WitnessAttestation(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      attestation: attestation ?? this.attestation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobileNumber': mobileNumber,
        'role': role.name,
        if (designation != null && designation!.isNotEmpty) 'designation': designation,
        'attestation': attestation.toJson(),
      };

  factory WitnessAttestation.fromJson(Map<String, dynamic> json) => WitnessAttestation(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        mobileNumber: json['mobileNumber'] as String? ?? '',
        role: AttestationRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => AttestationRole.witness,
        ),
        designation: json['designation'] as String?,
        attestation: PartyAttestation.fromJson(json['attestation'] as Map<String, dynamic>),
      );
}

/// Manages multi-party witness and village salish attestation records.
class MultiPartyAttestationManager {
  static const int maxStandardWitnesses = 2;
  static const int maxSalishdars = 3;

  final bool isSalishTemplate;
  final List<WitnessAttestation> _records;

  MultiPartyAttestationManager({
    this.isSalishTemplate = false,
    List<WitnessAttestation>? initial,
  }) : _records = List.from(initial ?? []);

  List<WitnessAttestation> get records => List.unmodifiable(_records);

  int get maxAllowed => isSalishTemplate ? maxSalishdars : maxStandardWitnesses;

  int get count => _records.length;

  bool get canAddMore => _records.length < maxAllowed;

  /// Adds a witness or salishdar attestation, enforcing role limits.
  void add(WitnessAttestation record) {
    if (_records.length >= maxAllowed) {
      final msg = isSalishTemplate
          ? 'সর্বোচ্চ $maxSalishdars জন শালিসদার যুক্ত করা যাবে'
          : 'সর্বোচ্চ $maxStandardWitnesses জন সাক্ষী যুক্ত করা যাবে';
      throw StateError(msg);
    }
    _records.add(record);
  }

  /// Removes a record by ID.
  bool remove(String id) {
    final before = _records.length;
    _records.removeWhere((r) => r.id == id);
    return _records.length < before;
  }

  /// True if all current records are valid.
  bool get areAllValid => _records.every((r) => r.isValid);
}
