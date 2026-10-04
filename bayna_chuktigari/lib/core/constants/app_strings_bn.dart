/// Bengali UI Strings and Legal Notices
/// Formatted according to PRD and EXPERIENCE.md
class AppStringsBn {
  AppStringsBn._();

  // App Identity
  static const String appName = 'DealDone';
  static const String appTagline = 'সহজ বাংলা চুক্তি ও লেনদেনের প্রমাণ';
  static const String newAgreementBtn = 'নতুন চুক্তি তৈরি করুন';

  // Navigation & Headers
  static const String vaultTitle = 'সংরক্ষিত চুক্তি ও বায়না রসিদ';
  static const String templateCatalogTitle = 'চুক্তির ধরণ নির্বাচন করুন';
  static const String wizardStep1Title = 'পক্ষগণের বিবরণ';
  static const String wizardStep2Title = 'লেনদেনের শর্ত ও টাকা';
  static const String wizardStep3Title = 'প্রমাণ ও সংযুক্তি';
  static const String wizardStep4Title = 'ডিজিটাল স্বাক্ষর';
  static const String previewTitle = 'চুক্তিপত্রের খসড়া ও রসিদ';

  // Parties
  static const String party1Label = 'প্রথম পক্ষ (বিক্রেতা / ঋণদাতা / বাড়িওয়ালা)';
  static const String party2Label = 'দ্বিতীয় পক্ষ (ক্রেতা / ঋণগ্রহীতা / ভাড়াটিয়া)';
  static const String nameLabel = 'পূর্ণ নাম';
  static const String phoneLabel = 'মোবাইল নম্বর (১১ ডিজিট)';
  static const String nidLabel = 'জাতীয় পরিচয়পত্র (NID) নম্বর (ঐচ্ছিক)';

  // Validation Errors
  static const String phoneError = 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: ০১৭১২...);';
  static const String nameError = 'নাম প্রদান করা বাধ্যতামূলক';
  static const String amountError = 'সঠিক টাকার পরিমাণ দিন';

  // Currency Transcription
  static const String amountLabel = 'টাকার পরিমাণ (সংখ্যায়)';
  static const String amountInWordsPrefix = 'টাকা কথায়:';
  static const String amountOnlySuffix = 'টাকা মাত্র';

  // Signatures & Evidence
  static const String signPrompt = 'আঙুল দিয়ে স্ক্রিনে স্বাক্ষর করুন';
  static const String clearSign = 'মুছে ফেলুন';
  static const String acceptSign = 'স্বাক্ষর গ্রহণ';
  static const String tipshoiBtn = 'টিপসই যুক্ত করুন';
  static const String addPhotoBtn = 'ছবি / রসিদ সংযুক্তি';
  static const String viewPdfBtn = 'PDF দেখুন';

  // Verification & PDF
  static const String documentIdPrefix = 'স্মারক নং:';
  static const String timestampPrefix = 'তারিখ ও সময়:';
  static const String qrVerificationNote = 'স্বাক্ষরিত মূল কপি যাচাইয়ের জন্য QR কোড স্ক্যান করুন';
  static const String pdfWatermark = 'দ্বিপাক্ষিক লেনদেনের স্মারক ও অঙ্গীকারনামা';

  // WhatsApp & Share Message
  static const String shareBtn = 'হোয়াটসঅ্যাপে পাঠান';
  static const String shareMessage =
      'আসসালামু আলাইকুম। আমাদের আজকের লেনদেন সংক্রান্ত স্মারক ও রসিদের কপি সংযুক্ত করা হলো।';
  static const String viralFooter =
      '✓ এই ডিজিটাল চুক্তিপত্রটি তৈরি হয়েছে "DealDone" অ্যাপ দিয়ে।';

  // Statutory Disclaimers (Contract Act 1872 & Evidence Act 2022)
  static const String legalDisclaimer =
      'এই রসিদ ও অঙ্গীকারনামাটি The Contract Act, 1872 এর Section 10 এবং '
      'The Evidence (Amendment) Act, 2022 এর Section 85A ও Section 65B অনুযায়ী উভয় পক্ষের '
      'পারস্পরিক সম্মতিতে প্রস্তুতকৃত একটি বৈধ ডিজিটাল স্মারক। ইহা জমি বা ফ্ল্যাট হস্তান্তরের '
      'সাব-রেজিস্ট্রি দলিলের বিকল্প নহে। DealDone কোনো আইন উপদেষ্টা প্রতিষ্ঠান নয়; '
      'ইহা কেবল পারস্পরিক লেনদেনের ডিজিটাল প্রমাণ সংরক্ষণকারী সফটওয়্যার।';
}
