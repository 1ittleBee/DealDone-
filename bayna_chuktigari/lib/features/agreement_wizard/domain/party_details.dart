/// Party roles in a legal agreement
enum PartyRole {
  firstParty, // প্রথম পক্ষ (দাতা / বিক্রেতা / ঋণদাতা / বাড়িওয়ালা)
  secondParty, // দ্বিতীয় পক্ষ (গ্রহীতা / ক্রেতা / ঋণগ্রহীতা / ভাড়াটিয়া)
  witness, // সাক্ষী
}

extension PartyRoleExtension on PartyRole {
  String get titleBn {
    switch (this) {
      case PartyRole.firstParty:
        return 'প্রথম পক্ষ';
      case PartyRole.secondParty:
        return 'দ্বিতীয় পক্ষ';
      case PartyRole.witness:
        return 'সাক্ষী';
    }
  }
}

/// Represents identification and contact details for a party in the agreement.
class PartyDetails {
  final String name;
  final String mobileNumber;
  final String? fatherOrSpouseName;
  final String? address;
  final String? nidNumber;
  final PartyRole role;

  const PartyDetails({
    required this.name,
    required this.mobileNumber,
    this.fatherOrSpouseName,
    this.address,
    this.nidNumber,
    this.role = PartyRole.firstParty,
  });

  PartyDetails copyWith({
    String? name,
    String? mobileNumber,
    String? fatherOrSpouseName,
    String? address,
    String? nidNumber,
    PartyRole? role,
  }) {
    return PartyDetails(
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      fatherOrSpouseName: fatherOrSpouseName ?? this.fatherOrSpouseName,
      address: address ?? this.address,
      nidNumber: nidNumber ?? this.nidNumber,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobileNumber': mobileNumber,
      if (fatherOrSpouseName != null && fatherOrSpouseName!.isNotEmpty)
        'fatherOrSpouseName': fatherOrSpouseName,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (nidNumber != null && nidNumber!.isNotEmpty) 'nidNumber': nidNumber,
      'role': role.name,
    };
  }

  factory PartyDetails.fromJson(Map<String, dynamic> json) {
    return PartyDetails(
      name: json['name'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      fatherOrSpouseName: json['fatherOrSpouseName'] as String?,
      address: json['address'] as String?,
      nidNumber: json['nidNumber'] as String?,
      role: PartyRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => PartyRole.firstParty,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyDetails &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mobileNumber == other.mobileNumber &&
          fatherOrSpouseName == other.fatherOrSpouseName &&
          address == other.address &&
          nidNumber == other.nidNumber &&
          role == other.role;

  @override
  int get hashCode =>
      name.hashCode ^
      mobileNumber.hashCode ^
      (fatherOrSpouseName?.hashCode ?? 0) ^
      (address?.hashCode ?? 0) ^
      (nidNumber?.hashCode ?? 0) ^
      role.hashCode;
}
