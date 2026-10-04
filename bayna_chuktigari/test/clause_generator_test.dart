import 'package:test/test.dart';
import '../lib/features/templates/data/template_repository.dart';
import '../lib/features/templates/domain/clause_generator.dart';

void main() {
  group('Story 2.2: Clause Generator & Custom Conditions Tests', () {
    test('Populates mandatory clauses from template', () {
      final template = TemplateRepository.getById('personal_loan_promissory')!;
      final generated = ClauseGenerator.generateForTemplate(template);

      expect(generated.mandatoryClauses.length, equals(template.clausesBn.length));
      expect(generated.mandatoryClauses.first, contains('করজে হাসানা'));
      expect(generated.customConditions, isEmpty);
      expect(generated.statutoryDisclaimer, contains('The Contract Act, 1872'));
    });

    test('Allows appending up to 3 custom conditions', () {
      final template = TemplateRepository.getById('used_vehicle_gadget_sale')!;
      var generated = ClauseGenerator.generateForTemplate(template);

      generated = generated.addCustomCondition('যাবতীয় ট্রাফিক ফাইন অদ্য তারিখের পূর্ব পর্যন্ত বিক্রেতার।');
      generated = generated.addCustomCondition('৩ দিনের মধ্যে নাম পরিবর্তন (Name Transfer) সম্পন্ন হইবে।');
      generated = generated.addCustomCondition('মূল চাবি ২টি ক্রেতাকে বুঝিয়ে দেওয়া হলো।');

      expect(generated.customConditions.length, equals(3));
      final all = generated.getAllClauses();
      expect(all.length, equals(template.clausesBn.length + 3));
      expect(all.last, contains('বিশেষ শর্ত (3): মূল চাবি ২টি'));
    });

    test('Throws StateError if attempting to exceed 3 custom conditions', () {
      final template = TemplateRepository.getById('rental_flat_advance')!;
      var generated = ClauseGenerator.generateForTemplate(template);

      generated = generated.addCustomCondition('শর্ত ১');
      generated = generated.addCustomCondition('শর্ত ২');
      generated = generated.addCustomCondition('শর্ত ৩');

      expect(
        () => generated.addCustomCondition('শর্ত ৪'),
        throwsStateError,
      );
    });

    test('Throws ArgumentError if custom condition is blank', () {
      final template = TemplateRepository.getById('service_contractor_advance')!;
      final generated = ClauseGenerator.generateForTemplate(template);

      expect(
        () => generated.addCustomCondition('   '),
        throwsArgumentError,
      );
    });

    test('Serialization to/from JSON roundtrips cleanly', () {
      final template = TemplateRepository.getById('general_mutual_agreement')!;
      final generated = ClauseGenerator.generateForTemplate(template, ['কাস্টম শর্ত']);
      final json = generated.toJson();
      final roundtrip = GeneratedClauses.fromJson(json);

      expect(roundtrip.mandatoryClauses, equals(generated.mandatoryClauses));
      expect(roundtrip.customConditions, equals(generated.customConditions));
      expect(roundtrip.statutoryDisclaimer, equals(generated.statutoryDisclaimer));
    });
  });
}
