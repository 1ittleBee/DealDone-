import '../domain/template_entity.dart';

/// Repository providing offline access to the 6 core agreement templates.
/// Implements FR-1 and ARCH-1.
class TemplateRepository {
  TemplateRepository._();

  static final List<AgreementTemplate> _templates = [
    // 1. Used Product / Vehicle Sale
    const AgreementTemplate(
      id: 'used_vehicle_gadget_sale',
      titleBn: 'পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি',
      titleEn: 'Used Vehicle & Product Sale Agreement',
      category: TemplateCategory.sales,
      icon: 'motorcycle',
      fields: [
        TemplateField(key: 'seller_name', labelBn: 'বিক্রেতার নাম', type: FieldType.text),
        TemplateField(key: 'seller_nid', labelBn: 'বিক্রেতার NID নম্বর', type: FieldType.nid, required: false),
        TemplateField(key: 'seller_phone', labelBn: 'বিক্রেতার মোবাইল', type: FieldType.phone),
        TemplateField(key: 'buyer_name', labelBn: 'ক্রেতার নাম', type: FieldType.text),
        TemplateField(key: 'buyer_nid', labelBn: 'ক্রেতার NID নম্বর', type: FieldType.nid, required: false),
        TemplateField(key: 'buyer_phone', labelBn: 'ক্রেতার মোবাইল', type: FieldType.phone),
        TemplateField(key: 'item_description', labelBn: 'পণ্যের বিবরণ (মডেল/ব্র্যান্ড)', type: FieldType.textarea),
        TemplateField(key: 'identifier', labelBn: 'রেজিস্ট্রেশন / চেসিস / IMEI নম্বর', type: FieldType.text),
        TemplateField(key: 'total_price', labelBn: 'মোট বিক্রয়মূল্য (টাকা)', type: FieldType.number),
        TemplateField(key: 'advance_paid', labelBn: 'পরিশোধিত অর্থ (টাকা)', type: FieldType.number),
      ],
      clausesBn: [
        'বিক্রেতা নিশ্চয়তা প্রদান করিতেছেন যে উল্লেখিত পণ্যটি তাহার সম্পূর্ণ নিজস্ব মালিকানাধীন এবং ইহা কোনো প্রকার চোরাই, ঋণগ্রস্ত বা আইনি বিরোধপূর্ণ নহে।',
        'ক্রেতা পণ্যটি স্বচক্ষে দেখিয়া, পরীক্ষা-নিরীক্ষা করিয়া সন্তুষ্ট হইয়া চলন্ত অবস্থায় গ্রহণ করিলেন।',
        'অদ্য তারিখের পর উল্লেখিত পণ্য সংক্রান্ত যেকোনো দায়-দায়িত্ব বা আইনি ব্যবহার ক্রেতার ওপর বর্তাইবে।',
      ],
    ),

    // 2. Personal Loan & Promissory Note (Qard Hasan)
    const AgreementTemplate(
      id: 'personal_loan_promissory',
      titleBn: 'টাকা ধার ও পরিশোধের অঙ্গীকারনামা (করজে হাসানা)',
      titleEn: 'Personal Loan & Promissory Note',
      category: TemplateCategory.finance,
      icon: 'handshake',
      fields: [
        TemplateField(key: 'lender_name', labelBn: 'ঋণদাতার নাম', type: FieldType.text),
        TemplateField(key: 'lender_phone', labelBn: 'ঋণদাতার মোবাইল', type: FieldType.phone),
        TemplateField(key: 'borrower_name', labelBn: 'ঋণগ্রহীতার নাম', type: FieldType.text),
        TemplateField(key: 'borrower_nid', labelBn: 'ঋণগ্রহীতার NID নম্বর', type: FieldType.nid, required: false),
        TemplateField(key: 'borrower_phone', labelBn: 'ঋণগ্রহীতার মোবাইল', type: FieldType.phone),
        TemplateField(key: 'loan_amount', labelBn: 'ধারের পরিমাণ (টাকা)', type: FieldType.number),
        TemplateField(key: 'payment_mode', labelBn: 'লেনদেনের মাধ্যম (ক্যাশ/বিকাশ/ব্যাংক)', type: FieldType.text),
        TemplateField(key: 'due_date', labelBn: 'পরিশোধের শেষ তারিখ', type: FieldType.date),
      ],
      clausesBn: [
        'ঋণগ্রহীতা স্বেচ্ছায়, সজ্ঞানে উল্লেখিত অর্থ করজে হাসানা (সুদমুক্ত ঋণ) হিসেবে বুঝিয়া গ্রহণ করিলেন।',
        'ঋণগ্রহীতা অঙ্গীকার করিতেছেন যে তিনি উল্লেখিত শেষ তারিখের মধ্যে সম্পূর্ণ অর্থ ঋণদাতাকে পরিশোধ করিবেন।',
        'উভয় পক্ষ এই স্মারকটি নিজ দায়িত্বে ও পূর্ণ সম্মতিতে সম্পাদন করিলেন।',
      ],
    ),

    // 3. Rental Flat Advance & Booking
    const AgreementTemplate(
      id: 'rental_flat_advance',
      titleBn: 'বাসাভাড়া বুকিং ও অগ্রিম বায়না রশিদ',
      titleEn: 'Rental Flat Booking & Advance Slip',
      category: TemplateCategory.rental,
      icon: 'home',
      fields: [
        TemplateField(key: 'landlord_name', labelBn: 'বাড়িওয়ালার নাম', type: FieldType.text),
        TemplateField(key: 'landlord_phone', labelBn: 'বাড়িওয়ালার মোবাইল', type: FieldType.phone),
        TemplateField(key: 'tenant_name', labelBn: 'ভাড়াটিয়ার নাম', type: FieldType.text),
        TemplateField(key: 'tenant_phone', labelBn: 'ভাড়াটিয়ার মোবাইল', type: FieldType.phone),
        TemplateField(key: 'flat_address', labelBn: 'ভাড়া দেওয়া ফ্ল্যাটের ঠিকানা', type: FieldType.textarea),
        TemplateField(key: 'monthly_rent', labelBn: 'নির্ধারিত মাসিক ভাড়া (টাকা)', type: FieldType.number),
        TemplateField(key: 'advance_amount', labelBn: 'অগ্রিম বা বায়নার টাকা', type: FieldType.number),
        TemplateField(key: 'move_in_date', labelBn: 'বাসায় ওঠার নির্ধারিত তারিখ', type: FieldType.date),
      ],
      clausesBn: [
        'বাড়িওয়ালা উল্লেখিত ফ্ল্যাটটি ভাড়া দেওয়ার উদ্দেশ্যে ভাড়াটিয়ার নিকট হইতে অগ্রিম বায়নার টাকা বুঝিয়া পাইলেন।',
        'উভয় পক্ষ নির্ধারিত তারিখে মূল ভাড়া চুক্তিপত্র সম্পাদন এবং বাসায় ওঠার ব্যাপারে একমত পোষণ করিলেন।',
        'কোনো পক্ষ চুক্তি ভঙ্গ করিলে স্থানীয় রীতি অনুযায়ী নিষ্পত্তি করা হইবে।',
      ],
    ),

    // 4. Contractor & Freelance Service Advance
    const AgreementTemplate(
      id: 'service_contractor_advance',
      titleBn: 'কাজের অগ্রিম ও চুক্তিপত্র',
      titleEn: 'Contractor & Service Advance Agreement',
      category: TemplateCategory.services,
      icon: 'tools',
      fields: [
        TemplateField(key: 'client_name', labelBn: 'গ্রাহকের নাম', type: FieldType.text),
        TemplateField(key: 'contractor_name', labelBn: 'কারিগর / সেবাদাতার নাম', type: FieldType.text),
        TemplateField(key: 'work_description', labelBn: 'কাজের বিবরণ ও শর্ত', type: FieldType.textarea),
        TemplateField(key: 'total_cost', labelBn: 'মোট চুক্তি মূল্য (টাকা)', type: FieldType.number),
        TemplateField(key: 'advance_paid', labelBn: 'অগ্রিম প্রদত্ত অর্থ (টাকা)', type: FieldType.number),
        TemplateField(key: 'deadline', labelBn: 'কাজ সমাপ্তির তারিখ', type: FieldType.date),
      ],
      clausesBn: [
        'সেবাদাতা নির্ধারিত মানের কাজ উল্লেখিত সময়ের মধ্যে সম্পন্ন করিতে দায়বদ্ধ থাকিবেন।',
        'কাজ সন্তোষজনকভাবে সম্পন্ন হওয়ার পর গ্রাহক অবশিষ্ট বকেয়া পরিশোধ করিবেন।',
      ],
    ),

    // 5. General Mutual Agreement
    const AgreementTemplate(
      id: 'general_mutual_agreement',
      titleBn: 'সাধারণ পারস্পরিক অঙ্গীকারনামা',
      titleEn: 'General Mutual Agreement',
      category: TemplateCategory.general,
      icon: 'document',
      fields: [
        TemplateField(key: 'first_party_name', labelBn: 'প্রথম পক্ষের নাম', type: FieldType.text),
        TemplateField(key: 'first_party_phone', labelBn: 'প্রথম পক্ষের মোবাইল', type: FieldType.phone),
        TemplateField(key: 'second_party_name', labelBn: 'দ্বিতীয় পক্ষের নাম', type: FieldType.text),
        TemplateField(key: 'second_party_phone', labelBn: 'দ্বিতীয় পক্ষের মোবাইল', type: FieldType.phone),
        TemplateField(key: 'agreement_subject', labelBn: 'অঙ্গীকারনামার বিষয়বস্তু', type: FieldType.text),
        TemplateField(key: 'terms_description', labelBn: 'পারস্পরিক শর্তাবলীর বিবরণ', type: FieldType.textarea),
      ],
      clausesBn: [
        'উভয় পক্ষ স্বেচ্ছায়, সুস্থ মস্তিষ্কে এবং কোনো প্রকার চাপ ব্যতিরেকে এই পারস্পরিক অঙ্গীকারনামা সম্পাদন করিলেন।',
        'এই স্মারকটি উভয় পক্ষের পারস্পরিক বিশ্বাস, সম্মতি ও আইনগত দায়বদ্ধতার স্মারক হিসেবে গণ্য হইবে।',
      ],
    ),

    // 6. Village Salish & Dispute Settlement Record
    const AgreementTemplate(
      id: 'village_salish_aposhnama',
      titleBn: 'গ্রাম্য সালিশ ও সর্বসম্মত আপোষনামা',
      titleEn: 'Village Arbitration & Dispute Settlement Record',
      category: TemplateCategory.arbitration,
      icon: 'gavel',
      fields: [
        TemplateField(
          key: 'dispute_category',
          labelBn: 'বিরোধের বিষয় (সীমানা/ক্ষতিপূরণ/পারিবারিক)',
          type: FieldType.select,
          options: ['সীমানা বিরোধ', 'ফসল/সম্পত্তির ক্ষতিপূরণ', 'পারিবারিক আপোষ', 'টাকা লেনদেনের বিরোধ', 'অন্যান্য'],
        ),
        TemplateField(key: 'first_party_name', labelBn: 'বাদী পক্ষের নাম', type: FieldType.text),
        TemplateField(key: 'first_party_phone', labelBn: 'বাদী পক্ষের মোবাইল', type: FieldType.phone),
        TemplateField(key: 'second_party_name', labelBn: 'বিবাদী পক্ষের নাম', type: FieldType.text),
        TemplateField(key: 'second_party_phone', labelBn: 'বিবাদী পক্ষের মোবাইল', type: FieldType.phone),
        TemplateField(key: 'arbiter_1_name', labelBn: 'প্রধান সালিশদার / মুরুব্বি ১', type: FieldType.text),
        TemplateField(key: 'arbiter_2_name', labelBn: 'সালিশদার ২ (নাম ও মোবাইল)', type: FieldType.text),
        TemplateField(key: 'arbiter_3_name', labelBn: 'সালিশদার ৩ (ঐচ্ছিক)', type: FieldType.text, required: false),
        TemplateField(key: 'settlement_details', labelBn: 'সালিশের সর্বসম্মত সিদ্ধান্ত ও শর্তাবলী', type: FieldType.textarea),
        TemplateField(key: 'compensation_amount', labelBn: 'ক্ষতিপূরণ বা নিষ্পত্তির অর্থ (যদি থাকে)', type: FieldType.number, required: false),
      ],
      clausesBn: [
        'উভয় পক্ষ নিজ নিজ ইচ্ছায় ও স্বাধীন সম্মতিতে উপস্থিত গণ্যমান্য সালিশদার ও মুরুব্বিদের সিদ্ধান্ত মানিয়া লইলেন।',
        'অদ্য তারিখের সিদ্ধান্তের মাধ্যমে উল্লেখিত বিরোধটির চূড়ান্ত ও সর্বসম্মত নিষ্পত্তি ঘটিল; ভবিষ্যতে এই বিষয়ে কোনো পক্ষ নতুন করিয়া কোনো মামলা, অভিযোগ বা বিরোধ সৃষ্টি করিবেন না।',
        'উভয় পক্ষ এবং উপস্থিত সম্মানিত সালিশদারবৃন্দ সম্পূর্ণ সজ্ঞানে এই আপোষনামায় নিজ নিজ স্বাক্ষর ও টিপসই প্রদান করিলেন।',
      ],
    ),
  ];

  /// Returns all 6 standardized templates
  static List<AgreementTemplate> getAllTemplates() => List.unmodifiable(_templates);

  /// Find template by ID
  static AgreementTemplate? getById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filter templates by category
  static List<AgreementTemplate> getByCategory(TemplateCategory category) {
    return _templates.where((t) => t.category == category).toList();
  }
}
