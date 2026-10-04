import 'evidence_attachment.dart';
import 'party_details.dart';
import 'party_validator.dart';
import 'transaction_terms.dart';

enum WizardStep {
  parties, // ধাপ ১ / ৪: পক্ষগণের তথ্য
  terms, // ধাপ ২ / ৪: চুক্তির শর্ত ও লেনদেন
  evidence, // ধাপ ৩ / ৪: ছবি ও প্রমাণাদি
  signatures, // ধাপ ৪ / ৪: ডিজিটাল স্বাক্ষর ও টিপসই
}

extension WizardStepExtension on WizardStep {
  int get stepNumber {
    switch (this) {
      case WizardStep.parties:
        return 1;
      case WizardStep.terms:
        return 2;
      case WizardStep.evidence:
        return 3;
      case WizardStep.signatures:
        return 4;
    }
  }

  String get stepLabelBn {
    const bnDigits = ['১', '২', '৩', '৪'];
    return 'ধাপ ${bnDigits[stepNumber - 1]} / ৪';
  }

  String get titleBn {
    switch (this) {
      case WizardStep.parties:
        return 'পক্ষগণের বিবরণ';
      case WizardStep.terms:
        return 'লেনদেন ও শর্তাবলী';
      case WizardStep.evidence:
        return 'প্রমাণপত্র ও ছবি';
      case WizardStep.signatures:
        return 'ডিজিটাল স্বাক্ষর';
    }
  }
}

/// Immutable draft state holding wizard step data.
class WizardDraftState {
  final String templateId;
  final String templateTitleBn;
  final WizardStep currentStep;
  final PartyDetails? firstParty;
  final PartyDetails? secondParty;
  final List<PartyDetails> witnesses;
  final TransactionTerms? terms;
  final List<EvidenceAttachment> attachments;

  const WizardDraftState({
    required this.templateId,
    required this.templateTitleBn,
    this.currentStep = WizardStep.parties,
    this.firstParty,
    this.secondParty,
    this.witnesses = const [],
    this.terms,
    this.attachments = const [],
  });

  /// Checks if First Party has valid mandatory information.
  bool get isFirstPartyValid {
    if (firstParty == null) return false;
    return PartyValidator.validateName(firstParty!.name) == null &&
        PartyValidator.validateMobile(firstParty!.mobileNumber) == null &&
        PartyValidator.validateNid(firstParty!.nidNumber) == null;
  }

  /// Checks if Second Party has valid mandatory information.
  bool get isSecondPartyValid {
    if (secondParty == null) return false;
    return PartyValidator.validateName(secondParty!.name) == null &&
        PartyValidator.validateMobile(secondParty!.mobileNumber) == null &&
        PartyValidator.validateNid(secondParty!.nidNumber) == null;
  }

  /// True if Step 1 is complete and user can proceed to Step 2.
  bool get canProceedToStep2 => isFirstPartyValid && isSecondPartyValid;

  /// Checks if Step 2 Transaction Terms are valid.
  bool get isTermsValid {
    if (terms == null) return false;
    return TransactionTerms.validateTotalAmount(terms!.totalAmount) == null &&
        TransactionTerms.validateAdvanceAmount(terms!.totalAmount, terms!.advanceAmount) == null;
  }

  /// True if user can proceed to Step 3.
  bool get canProceedToStep3 => canProceedToStep2 && isTermsValid;

  /// Checks if Step 3 attachments are valid (max 3, each <= 300KB).
  bool get isEvidenceValid {
    if (attachments.length > AttachmentManager.maxAttachments) return false;
    for (final att in attachments) {
      if (!att.isWithinSizeLimit) return false;
    }
    return true;
  }

  /// True if user can proceed to Step 4 (Digital Signatures).
  bool get canProceedToStep4 => canProceedToStep3 && isEvidenceValid;

  WizardDraftState copyWith({
    String? templateId,
    String? templateTitleBn,
    WizardStep? currentStep,
    PartyDetails? firstParty,
    PartyDetails? secondParty,
    List<PartyDetails>? witnesses,
    TransactionTerms? terms,
    List<EvidenceAttachment>? attachments,
  }) {
    return WizardDraftState(
      templateId: templateId ?? this.templateId,
      templateTitleBn: templateTitleBn ?? this.templateTitleBn,
      currentStep: currentStep ?? this.currentStep,
      firstParty: firstParty ?? this.firstParty,
      secondParty: secondParty ?? this.secondParty,
      witnesses: witnesses ?? this.witnesses,
      terms: terms ?? this.terms,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'templateTitleBn': templateTitleBn,
      'currentStep': currentStep.name,
      if (firstParty != null) 'firstParty': firstParty!.toJson(),
      if (secondParty != null) 'secondParty': secondParty!.toJson(),
      'witnesses': witnesses.map((w) => w.toJson()).toList(),
      if (terms != null) 'terms': terms!.toJson(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  factory WizardDraftState.fromJson(Map<String, dynamic> json) {
    return WizardDraftState(
      templateId: json['templateId'] as String? ?? '',
      templateTitleBn: json['templateTitleBn'] as String? ?? '',
      currentStep: WizardStep.values.firstWhere(
        (s) => s.name == json['currentStep'],
        orElse: () => WizardStep.parties,
      ),
      firstParty: json['firstParty'] != null
          ? PartyDetails.fromJson(json['firstParty'] as Map<String, dynamic>)
          : null,
      secondParty: json['secondParty'] != null
          ? PartyDetails.fromJson(json['secondParty'] as Map<String, dynamic>)
          : null,
      witnesses: (json['witnesses'] as List<dynamic>?)
              ?.map((w) => PartyDetails.fromJson(w as Map<String, dynamic>))
              .toList() ??
          const [],
      terms: json['terms'] != null
          ? TransactionTerms.fromJson(json['terms'] as Map<String, dynamic>)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => EvidenceAttachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
