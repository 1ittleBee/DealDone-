import 'package:test/test.dart';
import 'package:bayna_chuktigari/core/utils/bangla_date_formatter.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/transaction_terms.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/wizard_state.dart';

void main() {
  group('Story 3.2: Transaction Terms & Real-Time Currency Transcription Tests', () {
    test('Translates numeric amounts into formal Bengali currency in words', () {
      final terms = TransactionTerms(
        totalAmount: 30000,
        advanceAmount: 10000,
        paymentMethod: PaymentMethod.bkash,
      );

      expect(terms.totalAmount, equals(30000));
      expect(terms.amountInWords, equals('ত্রিশ হাজার টাকা মাত্র'));
      expect(terms.advanceAmount, equals(10000));
      expect(terms.advanceAmountInWords, equals('দশ হাজার টাকা মাত্র'));
      expect(terms.dueAmount, equals(20000));
      expect(terms.dueAmountInWords, equals('বিশ হাজার টাকা মাত্র'));
    });

    test('Validates total amount requires positive non-zero value', () {
      const expectedError = 'টাকার পরিমাণ শূন্যের বেশি হতে হবে';

      expect(TransactionTerms.validateTotalAmount(null), equals(expectedError));
      expect(TransactionTerms.validateTotalAmount(0), equals(expectedError));
      expect(TransactionTerms.validateTotalAmount(-500), equals(expectedError));
      expect(TransactionTerms.validateTotalAmount(1), isNull);
      expect(TransactionTerms.validateTotalAmount(500000), isNull);
    });

    test('Validates advance payment does not exceed total amount', () {
      expect(
        TransactionTerms.validateAdvanceAmount(50000, 60000),
        equals('অগ্রিম মোট টাকার চেয়ে বেশি হতে পারে না'),
      );
      expect(
        TransactionTerms.validateAdvanceAmount(50000, -10),
        equals('অগ্রিম টাকার পরিমাণ সঠিক নয়'),
      );
      expect(TransactionTerms.validateAdvanceAmount(50000, 0), isNull);
      expect(TransactionTerms.validateAdvanceAmount(50000, 50000), isNull);
      expect(TransactionTerms.validateAdvanceAmount(50000, 25000), isNull);
    });

    test('BanglaDateFormatter formats dates with Bengali month names and numerals', () {
      final date = DateTime(2026, 9, 30);

      expect(BanglaDateFormatter.formatBengali(date), equals('৩০ সেপ্টেম্বর ২০২৬'));
      expect(BanglaDateFormatter.formatNumericBengali(date), equals('৩০/০৯/২০২৬'));
      expect(BanglaDateFormatter.toBengaliDigits(1234567890), equals('১২৩৪৫৬৭৮৯০'));
    });

    test('WizardDraftState validates Step 2 completion and serializes terms', () {
      var state = WizardDraftState(
        templateId: 'used_vehicle_gadget_sale',
        templateTitleBn: 'পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি',
        firstParty: const PartyDetails(
          name: 'করিম মিয়া',
          mobileNumber: '01711223344',
        ),
        secondParty: const PartyDetails(
          name: 'রহিম মোল্লা',
          mobileNumber: '01811223344',
        ),
      );

      expect(state.canProceedToStep2, isTrue);
      expect(state.isTermsValid, isFalse);
      expect(state.canProceedToStep3, isFalse);

      final terms = TransactionTerms(
        totalAmount: 150000,
        advanceAmount: 50000,
        paymentMethod: PaymentMethod.bank,
        paymentDueDate: DateTime(2026, 12, 31),
        paymentReference: 'CHQ-987654',
      );

      state = state.copyWith(
        currentStep: WizardStep.terms,
        terms: terms,
      );

      expect(state.isTermsValid, isTrue);
      expect(state.canProceedToStep3, isTrue);
      expect(state.terms?.amountInWords, equals('এক লক্ষ পঞ্চাশ হাজার টাকা মাত্র'));

      // Test JSON roundtrip
      final json = state.toJson();
      final restored = WizardDraftState.fromJson(json);

      expect(restored.terms?.totalAmount, equals(150000));
      expect(restored.terms?.advanceAmount, equals(50000));
      expect(restored.terms?.dueAmount, equals(100000));
      expect(restored.terms?.paymentMethod, equals(PaymentMethod.bank));
      expect(restored.terms?.paymentReference, equals('CHQ-987654'));
      expect(restored.canProceedToStep3, isTrue);
    });
  });
}
