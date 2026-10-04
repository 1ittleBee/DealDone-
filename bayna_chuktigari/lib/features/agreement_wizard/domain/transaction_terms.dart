import 'package:bayna_chuktigari/core/utils/bangla_currency_words.dart';

/// Supported payment methods for transaction agreements in Bangladesh.
enum PaymentMethod {
  cash, // নগদ
  bkash, // বিকাশ (bKash)
  nagad, // নগদ (Nagad)
  bank, // ব্যাংক ট্রান্সফার / চেক
  other, // অন্যান্য
}

extension PaymentMethodExtension on PaymentMethod {
  String get titleBn {
    switch (this) {
      case PaymentMethod.cash:
        return 'নগদ / ক্যাশ';
      case PaymentMethod.bkash:
        return 'বিকাশ (bKash)';
      case PaymentMethod.nagad:
        return 'নগদ অ্যাপ';
      case PaymentMethod.bank:
        return 'ব্যাংক অ্যাকাউন্ট / চেক';
      case PaymentMethod.other:
        return 'অন্যান্য';
    }
  }
}

/// Represents financial terms and payment schedule of an agreement.
class TransactionTerms {
  final int totalAmount;
  final int advanceAmount;
  final PaymentMethod paymentMethod;
  final DateTime? paymentDueDate;
  final DateTime? deliveryDate;
  final String? paymentReference;
  final String? note;

  const TransactionTerms({
    required this.totalAmount,
    this.advanceAmount = 0,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentDueDate,
    this.deliveryDate,
    this.paymentReference,
    this.note,
  });

  /// Automatically computes the remaining due amount.
  int get dueAmount => totalAmount >= advanceAmount ? totalAmount - advanceAmount : 0;

  /// Pure Bengali monetary words translation for total amount.
  String get amountInWords => BanglaCurrencyWords.convert(totalAmount);

  /// Pure Bengali monetary words translation for advance payment.
  String get advanceAmountInWords => BanglaCurrencyWords.convert(advanceAmount);

  /// Pure Bengali monetary words translation for due balance.
  String get dueAmountInWords => BanglaCurrencyWords.convert(dueAmount);

  /// Validates total amount (> 0).
  static String? validateTotalAmount(int? amount) {
    if (amount == null || amount <= 0) {
      return 'টাকার পরিমাণ শূন্যের বেশি হতে হবে';
    }
    return null;
  }

  /// Validates advance amount (>= 0 and <= totalAmount).
  static String? validateAdvanceAmount(int? total, int? advance) {
    if (total == null || total <= 0) return null;
    if (advance == null || advance < 0) {
      return 'অগ্রিম টাকার পরিমাণ সঠিক নয়';
    }
    if (advance > total) {
      return 'অগ্রিম মোট টাকার চেয়ে বেশি হতে পারে না';
    }
    return null;
  }

  TransactionTerms copyWith({
    int? totalAmount,
    int? advanceAmount,
    PaymentMethod? paymentMethod,
    DateTime? paymentDueDate,
    DateTime? deliveryDate,
    String? paymentReference,
    String? note,
  }) {
    return TransactionTerms(
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      paymentReference: paymentReference ?? this.paymentReference,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'advanceAmount': advanceAmount,
      'paymentMethod': paymentMethod.name,
      if (paymentDueDate != null) 'paymentDueDate': paymentDueDate!.toIso8601String(),
      if (deliveryDate != null) 'deliveryDate': deliveryDate!.toIso8601String(),
      if (paymentReference != null && paymentReference!.isNotEmpty)
        'paymentReference': paymentReference,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  factory TransactionTerms.fromJson(Map<String, dynamic> json) {
    return TransactionTerms(
      totalAmount: json['totalAmount'] as int? ?? 0,
      advanceAmount: json['advanceAmount'] as int? ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (m) => m.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentDueDate: json['paymentDueDate'] != null
          ? DateTime.tryParse(json['paymentDueDate'] as String)
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.tryParse(json['deliveryDate'] as String)
          : null,
      paymentReference: json['paymentReference'] as String?,
      note: json['note'] as String?,
    );
  }
}
