import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_validator.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/wizard_state.dart';

void main() {
  group('Story 3.1: Party Details & Validation Tests', () {
    test('Name validation enforces at least 2 characters', () {
      expect(PartyValidator.validateName(null), equals('নাম লিখুন'));
      expect(PartyValidator.validateName(''), equals('নাম লিখুন'));
      expect(PartyValidator.validateName('   '), equals('নাম লিখুন'));
      expect(PartyValidator.validateName('ক'), equals('নাম লিখুন'));
      expect(PartyValidator.validateName('করিম মিয়া'), isNull);
      expect(PartyValidator.validateName('Abdur Rahim'), isNull);
    });

    test('Mobile number validation accepts standard Bangladeshi 11-digit operators', () {
      final validNumbers = [
        '01712345678', // Grameenphone
        '01812345678', // Robi
        '01912345678', // Banglalink
        '01512345678', // Teletalk
        '01612345678', // Airtel
        '01312345678', // GP new
        '01412345678', // BL new
      ];

      for (final number in validNumbers) {
        expect(
          PartyValidator.validateMobile(number),
          isNull,
          reason: 'Expected $number to be valid',
        );
      }
    });

    test('Mobile number validation handles Bengali numerals, prefixes, and hyphens', () {
      // Bengali digits
      expect(PartyValidator.validateMobile('০১৭১২৩৪৫৬৭৮'), isNull);
      // With dashes and spaces
      expect(PartyValidator.validateMobile('01712-345678'), isNull);
      expect(PartyValidator.validateMobile('01712 345678'), isNull);
      // With +880 and 880 prefix
      expect(PartyValidator.validateMobile('+8801712345678'), isNull);
      expect(PartyValidator.validateMobile('8801812345678'), isNull);
      expect(PartyValidator.validateMobile('+৮৮০১৭১২-৩৪৫৬৭৮'), isNull);
    });

    test('Mobile number validation rejects invalid prefixes and incorrect lengths', () {
      const expectedError = 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন';

      expect(PartyValidator.validateMobile('01212345678'), equals(expectedError)); // Invalid prefix 012
      expect(PartyValidator.validateMobile('01112345678'), equals(expectedError)); // Invalid prefix 011
      expect(PartyValidator.validateMobile('01012345678'), equals(expectedError)); // Invalid prefix 010
      expect(PartyValidator.validateMobile('017123456'), equals(expectedError)); // Too short
      expect(PartyValidator.validateMobile('0171234567899'), equals(expectedError)); // Too long
      expect(PartyValidator.validateMobile('abcdefghijk'), equals(expectedError)); // Non-numeric
    });

    test('NID validation allows optional blank or valid 10, 13, 17 digit formats', () {
      const nidError = '১০, ১৩ বা ১৭ ডিজিটের জাতীয় পরিচয়পত্র নম্বর দিন';

      // Optional blank / null
      expect(PartyValidator.validateNid(null), isNull);
      expect(PartyValidator.validateNid(''), isNull);
      expect(PartyValidator.validateNid('   '), isNull);

      // 10 digits (Smart NID)
      expect(PartyValidator.validateNid('1234567890'), isNull);
      expect(PartyValidator.validateNid('১২৩৪৫৬৭৮৯০'), isNull);

      // 13 digits (Old NID)
      expect(PartyValidator.validateNid('1234567890123'), isNull);

      // 17 digits (Old NID with 4-digit birth year)
      expect(PartyValidator.validateNid('19851234567890123'), isNull);

      // Invalid lengths
      expect(PartyValidator.validateNid('123456789'), equals(nidError)); // 9 digits
      expect(PartyValidator.validateNid('12345678901'), equals(nidError)); // 11 digits
      expect(PartyValidator.validateNid('123456789012'), equals(nidError)); // 12 digits
      expect(PartyValidator.validateNid('12345678901234'), equals(nidError)); // 14 digits
      expect(PartyValidator.validateNid('123456789012345678'), equals(nidError)); // 18 digits
    });

    test('WizardDraftState accurately tracks Step 1 completion and serializes to JSON', () {
      final state = WizardDraftState(
        templateId: 'used_vehicle_gadget_sale',
        templateTitleBn: 'পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি',
      );

      expect(state.currentStep, equals(WizardStep.parties));
      expect(state.currentStep.stepLabelBn, equals('ধাপ ১ / ৪'));
      expect(state.isFirstPartyValid, isFalse);
      expect(state.isSecondPartyValid, isFalse);
      expect(state.canProceedToStep2, isFalse);

      final populatedState = state.copyWith(
        firstParty: const PartyDetails(
          name: 'মো. রফিকুল ইসলাম',
          mobileNumber: '01711223344',
          nidNumber: '1234567890',
          role: PartyRole.firstParty,
        ),
        secondParty: const PartyDetails(
          name: 'তানভীর আহমেদ',
          mobileNumber: '০১৭১১২২৩৩৪৪',
          role: PartyRole.secondParty,
        ),
      );

      expect(populatedState.isFirstPartyValid, isTrue);
      expect(populatedState.isSecondPartyValid, isTrue);
      expect(populatedState.canProceedToStep2, isTrue);

      final json = populatedState.toJson();
      final restored = WizardDraftState.fromJson(json);

      expect(restored.templateId, equals('used_vehicle_gadget_sale'));
      expect(restored.firstParty?.name, equals('মো. রফিকুল ইসলাম'));
      expect(restored.secondParty?.name, equals('তানভীর আহমেদ'));
      expect(restored.canProceedToStep2, isTrue);
    });
  });
}
