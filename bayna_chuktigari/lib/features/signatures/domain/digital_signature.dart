import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';

/// Represents a single 2D vector coordinate on the signature canvas.
class SignaturePoint {
  final double x;
  final double y;
  final int timestampMs;

  const SignaturePoint({
    required this.x,
    required this.y,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        't': timestampMs,
      };

  factory SignaturePoint.fromJson(Map<String, dynamic> json) => SignaturePoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        timestampMs: json['t'] as int? ?? 0,
      );
}

/// Represents a continuous uninterrupted finger stroke.
class SignatureStroke {
  final List<SignaturePoint> points;

  const SignatureStroke({required this.points});

  int get pointCount => points.length;

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
      };

  factory SignatureStroke.fromJson(Map<String, dynamic> json) => SignatureStroke(
        points: (json['points'] as List<dynamic>?)
                ?.map((p) => SignaturePoint.fromJson(p as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// Represents a captured on-screen digital vector signature for an agreement party.
class DigitalSignature {
  final String id;
  final String signerName;
  final PartyRole role;
  final List<SignatureStroke> strokes;
  final DateTime signedAt;
  final String? base64Png;

  static const int minPointThreshold = 15;

  const DigitalSignature({
    required this.id,
    required this.signerName,
    required this.role,
    required this.strokes,
    required this.signedAt,
    this.base64Png,
  });

  /// Total number of sampled coordinates across all strokes.
  int get totalPoints => strokes.fold(0, (sum, stroke) => sum + stroke.pointCount);

  /// True if signature meets the legal minimum 15-point attestation threshold.
  bool get isValid => totalPoints >= minPointThreshold;

  /// Validates signature adequacy.
  String? validate() {
    if (strokes.isEmpty || totalPoints == 0) {
      return 'স্বাক্ষর প্রদান করুন';
    }
    if (totalPoints < minPointThreshold) {
      return 'স্বাক্ষর সম্পন্ন করতে আরও স্পষ্ট করে আঁকুন (কমপক্ষে ১৫টি পয়েন্ট)';
    }
    return null;
  }

  /// Exports stroke points into standard SVG path commands.
  String toSvgPathData() {
    final buffer = StringBuffer();
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final first = stroke.points.first;
      buffer.write('M ${first.x} ${first.y} ');
      for (int i = 1; i < stroke.points.length; i++) {
        final pt = stroke.points[i];
        buffer.write('L ${pt.x} ${pt.y} ');
      }
    }
    return buffer.toString().trim();
  }

  DigitalSignature copyWith({
    String? id,
    String? signerName,
    PartyRole? role,
    List<SignatureStroke>? strokes,
    DateTime? signedAt,
    String? base64Png,
  }) {
    return DigitalSignature(
      id: id ?? this.id,
      signerName: signerName ?? this.signerName,
      role: role ?? this.role,
      strokes: strokes ?? this.strokes,
      signedAt: signedAt ?? this.signedAt,
      base64Png: base64Png ?? this.base64Png,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'signerName': signerName,
        'role': role.name,
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'signedAt': signedAt.toIso8601String(),
        if (base64Png != null) 'base64Png': base64Png,
      };

  factory DigitalSignature.fromJson(Map<String, dynamic> json) => DigitalSignature(
        id: json['id'] as String,
        signerName: json['signerName'] as String? ?? '',
        role: PartyRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => PartyRole.firstParty,
        ),
        strokes: (json['strokes'] as List<dynamic>?)
                ?.map((s) => SignatureStroke.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
        signedAt: DateTime.tryParse(json['signedAt'] as String? ?? '') ?? DateTime.now(),
        base64Png: json['base64Png'] as String?,
      );
}
