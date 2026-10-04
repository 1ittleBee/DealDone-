import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/signatures/domain/digital_signature.dart';

/// Specifies which finger impression was captured for Tipshoi (টিপসই).
enum ThumbprintFinger {
  leftThumb, // বাম বৃদ্ধাঙ্গুলি
  rightThumb, // ডান বৃদ্ধাঙ্গুলি
  other, // অন্যান্য
}

extension ThumbprintFingerExtension on ThumbprintFinger {
  String get titleBn {
    switch (this) {
      case ThumbprintFinger.leftThumb:
        return 'বাম বৃদ্ধাঙ্গুলি';
      case ThumbprintFinger.rightThumb:
        return 'ডান বৃদ্ধাঙ্গুলি';
      case ThumbprintFinger.other:
        return 'আঙ্গুল';
    }
  }
}

/// Represents an ink thumbprint (*টিপসই*) image impression captured via camera.
class TipshoiCapture {
  final String id;
  final String signerName;
  final PartyRole role;
  final ThumbprintFinger finger;
  final String imagePath;
  final DateTime capturedAt;
  final String? base64Thumbnail;
  final double aspectRatio;

  const TipshoiCapture({
    required this.id,
    required this.signerName,
    required this.role,
    this.finger = ThumbprintFinger.leftThumb,
    required this.imagePath,
    required this.capturedAt,
    this.base64Thumbnail,
    this.aspectRatio = 1.0, // Strictly square 1:1
  });

  TipshoiCapture copyWith({
    String? id,
    String? signerName,
    PartyRole? role,
    ThumbprintFinger? finger,
    String? imagePath,
    DateTime? capturedAt,
    String? base64Thumbnail,
    double? aspectRatio,
  }) {
    return TipshoiCapture(
      id: id ?? this.id,
      signerName: signerName ?? this.signerName,
      role: role ?? this.role,
      finger: finger ?? this.finger,
      imagePath: imagePath ?? this.imagePath,
      capturedAt: capturedAt ?? this.capturedAt,
      base64Thumbnail: base64Thumbnail ?? this.base64Thumbnail,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'signerName': signerName,
        'role': role.name,
        'finger': finger.name,
        'imagePath': imagePath,
        'capturedAt': capturedAt.toIso8601String(),
        if (base64Thumbnail != null) 'base64Thumbnail': base64Thumbnail,
        'aspectRatio': aspectRatio,
      };

  factory TipshoiCapture.fromJson(Map<String, dynamic> json) => TipshoiCapture(
        id: json['id'] as String,
        signerName: json['signerName'] as String? ?? '',
        role: PartyRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => PartyRole.firstParty,
        ),
        finger: ThumbprintFinger.values.firstWhere(
          (f) => f.name == json['finger'],
          orElse: () => ThumbprintFinger.leftThumb,
        ),
        imagePath: json['imagePath'] as String? ?? '',
        capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ?? DateTime.now(),
        base64Thumbnail: json['base64Thumbnail'] as String?,
        aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.0,
      );
}

/// Unified attestation record for a party: either by digital signature OR physical tipshoi.
class PartyAttestation {
  final PartyRole role;
  final String partyName;
  final DigitalSignature? signature;
  final TipshoiCapture? tipshoi;

  const PartyAttestation({
    required this.role,
    required this.partyName,
    this.signature,
    this.tipshoi,
  });

  /// True if the party has completed attestation via signature or tipshoi.
  bool get hasAttestation {
    final validSig = signature != null && signature!.isValid;
    final validTipshoi = tipshoi != null && tipshoi!.imagePath.isNotEmpty;
    return validSig || validTipshoi;
  }

  /// Returns null if valid, or a Bengali prompt error.
  String? validate() {
    if (!hasAttestation) {
      return 'স্বাক্ষর অথবা টিপসই প্রদান করুন';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'partyName': partyName,
        if (signature != null) 'signature': signature!.toJson(),
        if (tipshoi != null) 'tipshoi': tipshoi!.toJson(),
      };

  factory PartyAttestation.fromJson(Map<String, dynamic> json) => PartyAttestation(
        role: PartyRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => PartyRole.firstParty,
        ),
        partyName: json['partyName'] as String? ?? '',
        signature: json['signature'] != null
            ? DigitalSignature.fromJson(json['signature'] as Map<String, dynamic>)
            : null,
        tipshoi: json['tipshoi'] != null
            ? TipshoiCapture.fromJson(json['tipshoi'] as Map<String, dynamic>)
            : null,
      );
}
