/// Types of evidence attachments supported in Bayna contracts.
enum AttachmentType {
  nidCard, // জাতীয় পরিচয়পত্র (NID)
  paymentReceipt, // ব্যাংক রসিদ / মানি রিসিট
  productOrProperty, // পণ্য বা সম্পত্তির ছবি
  other, // অন্যান্য প্রমাণাদি
}

extension AttachmentTypeExtension on AttachmentType {
  String get titleBn {
    switch (this) {
      case AttachmentType.nidCard:
        return 'জাতীয় পরিচয়পত্র';
      case AttachmentType.paymentReceipt:
        return 'টাকা পরিশোধের রসিদ';
      case AttachmentType.productOrProperty:
        return 'পণ্য বা সম্পত্তির ছবি';
      case AttachmentType.other:
        return 'অন্যান্য প্রমাণাদি';
    }
  }
}

/// Represents an offline photo or document evidence attached to an agreement.
class EvidenceAttachment {
  final String id;
  final String filePath;
  final String titleBn;
  final AttachmentType type;
  final int fileSizeBytes;
  final DateTime capturedAt;
  final String? base64Thumbnail;

  const EvidenceAttachment({
    required this.id,
    required this.filePath,
    required this.titleBn,
    this.type = AttachmentType.other,
    required this.fileSizeBytes,
    required this.capturedAt,
    this.base64Thumbnail,
  });

  /// 300KB budget threshold (307,200 bytes)
  static const int maxFileSizeBytes = 300 * 1024;

  bool get isWithinSizeLimit => fileSizeBytes <= maxFileSizeBytes;

  EvidenceAttachment copyWith({
    String? id,
    String? filePath,
    String? titleBn,
    AttachmentType? type,
    int? fileSizeBytes,
    DateTime? capturedAt,
    String? base64Thumbnail,
  }) {
    return EvidenceAttachment(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      titleBn: titleBn ?? this.titleBn,
      type: type ?? this.type,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      capturedAt: capturedAt ?? this.capturedAt,
      base64Thumbnail: base64Thumbnail ?? this.base64Thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'titleBn': titleBn,
      'type': type.name,
      'fileSizeBytes': fileSizeBytes,
      'capturedAt': capturedAt.toIso8601String(),
      if (base64Thumbnail != null) 'base64Thumbnail': base64Thumbnail,
    };
  }

  factory EvidenceAttachment.fromJson(Map<String, dynamic> json) {
    return EvidenceAttachment(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      titleBn: json['titleBn'] as String? ?? 'প্রমাণপত্র',
      type: AttachmentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AttachmentType.other,
      ),
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ?? DateTime.now(),
      base64Thumbnail: json['base64Thumbnail'] as String?,
    );
  }
}

/// Pure Dart manager for adding, deleting, and enforcing rules on evidence attachments.
class AttachmentManager {
  static const int maxAttachments = 3;
  static const int maxFileSizeBytes = 300 * 1024; // 300 KB

  final List<EvidenceAttachment> _attachments;

  AttachmentManager([List<EvidenceAttachment>? initial])
      : _attachments = List.from(initial ?? []);

  List<EvidenceAttachment> get attachments => List.unmodifiable(_attachments);

  int get count => _attachments.length;

  bool get canAddMore => _attachments.length < maxAttachments;

  /// Adds a new attachment while enforcing limits.
  /// Throws [StateError] if already at 3 attachments.
  /// Throws [ArgumentError] if file size exceeds 300KB.
  void addAttachment(EvidenceAttachment attachment) {
    if (_attachments.length >= maxAttachments) {
      throw StateError('সর্বোচ্চ ৩টি ছবি বা প্রমাণপত্র যুক্ত করা যাবে');
    }
    if (attachment.fileSizeBytes > maxFileSizeBytes) {
      throw ArgumentError('ছবির সাইজ ৩০০ কেবি (300KB) এর চেয়ে কম হতে হবে');
    }
    _attachments.add(attachment);
  }

  /// Removes an attachment by its unique id.
  bool removeAttachment(String id) {
    final before = _attachments.length;
    _attachments.removeWhere((item) => item.id == id);
    return _attachments.length < before;
  }

  /// Clears all attachments.
  void clear() {
    _attachments.clear();
  }
}
