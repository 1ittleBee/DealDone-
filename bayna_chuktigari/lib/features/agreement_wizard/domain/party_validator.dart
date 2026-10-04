/// Validation utilities for Party information under Bangladeshi standards.
class PartyValidator {
  static const Map<String, String> _bnToEnDigits = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  /// Normalizes Bengali numerals (০-৯) to standard ASCII digits (0-9)
  /// and strips spaces and hyphens.
  static String normalizeDigits(String? input) {
    if (input == null) return '';
    String sanitized = input.trim();
    _bnToEnDigits.forEach((bn, en) {
      sanitized = sanitized.replaceAll(bn, en);
    });
    return sanitized.replaceAll(RegExp(r'[\s\-]'), '');
  }

  /// Normalizes a Bangladeshi mobile number (handles +880 / 880 prefix).
  static String normalizeMobile(String? input) {
    String digits = normalizeDigits(input);
    if (digits.startsWith('+880')) {
      digits = '0' + digits.substring(4);
    } else if (digits.startsWith('880')) {
      digits = '0' + digits.substring(3);
    }
    return digits;
  }

  /// Validates Bangladeshi party name.
  /// Returns null if valid, or a Bengali error message.
  static String? validateName(String? name) {
    if (name == null || name.trim().length < 2) {
      return 'নাম লিখুন';
    }
    return null;
  }

  /// Validates 11-digit Bangladeshi mobile numbers.
  /// Accepts formats starting with 013-019, including Bengali digits and +88 prefix.
  /// Returns null if valid, or a Bengali error message.
  static String? validateMobile(String? mobile) {
    if (mobile == null || mobile.trim().isEmpty) {
      return 'মোবাইল নম্বর লিখুন';
    }
    final normalized = normalizeMobile(mobile);
    final mobileRegex = RegExp(r'^01[3-9]\d{8}$');
    if (!mobileRegex.hasMatch(normalized)) {
      return 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন';
    }
    return null;
  }

  /// Validates Bangladeshi National ID (NID).
  /// NID is optional. If provided, it must be 10 (Smart), 13 (Old), or 17 (13+BirthYear) digits.
  /// Returns null if valid (or empty), or a Bengali error message.
  static String? validateNid(String? nid) {
    if (nid == null || nid.trim().isEmpty) {
      return null; // Optional
    }
    final normalized = normalizeDigits(nid);
    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return '১০, ১৩ বা ১৭ ডিজিটের জাতীয় পরিচয়পত্র নম্বর দিন';
    }
    final len = normalized.length;
    if (len == 10 || len == 13 || len == 17) {
      return null;
    }
    return '১০, ১৩ বা ১৭ ডিজিটের জাতীয় পরিচয়পত্র নম্বর দিন';
  }
}
