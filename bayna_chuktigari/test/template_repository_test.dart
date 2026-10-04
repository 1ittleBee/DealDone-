import 'package:test/test.dart';
import '../lib/features/templates/data/template_repository.dart';
import '../lib/features/templates/domain/template_entity.dart';

void main() {
  group('Story 2.1: Template Repository Tests', () {
    test('Returns exactly 6 standardized agreement templates', () {
      final templates = TemplateRepository.getAllTemplates();
      expect(templates.length, equals(6));
    });

    test('Each template contains valid identifiers, titles, and fields', () {
      final templates = TemplateRepository.getAllTemplates();
      for (final template in templates) {
        expect(template.id, isNotEmpty);
        expect(template.titleBn, isNotEmpty);
        expect(template.titleEn, isNotEmpty);
        expect(template.fields, isNotEmpty);
        expect(template.clausesBn, isNotEmpty);
      }
    });

    test('Template categories are mapped properly', () {
      expect(TemplateRepository.getById('used_vehicle_gadget_sale')?.category, equals(TemplateCategory.sales));
      expect(TemplateRepository.getById('personal_loan_promissory')?.category, equals(TemplateCategory.finance));
      expect(TemplateRepository.getById('rental_flat_advance')?.category, equals(TemplateCategory.rental));
      expect(TemplateRepository.getById('service_contractor_advance')?.category, equals(TemplateCategory.services));
      expect(TemplateRepository.getById('general_mutual_agreement')?.category, equals(TemplateCategory.general));
      expect(TemplateRepository.getById('village_salish_aposhnama')?.category, equals(TemplateCategory.arbitration));
    });

    test('Village Salish template includes arbiter fields', () {
      final salish = TemplateRepository.getById('village_salish_aposhnama');
      expect(salish, isNotNull);
      final keys = salish!.fields.map((f) => f.key).toList();
      expect(keys, contains('arbiter_1_name'));
      expect(keys, contains('arbiter_2_name'));
      expect(keys, contains('dispute_category'));
    });

    test('Serialization to/from JSON roundtrips cleanly', () {
      final template = TemplateRepository.getAllTemplates().first;
      final json = template.toJson();
      final roundtrip = AgreementTemplate.fromJson(json);

      expect(roundtrip.id, equals(template.id));
      expect(roundtrip.titleBn, equals(template.titleBn));
      expect(roundtrip.fields.length, equals(template.fields.length));
      expect(roundtrip.clausesBn, equals(template.clausesBn));
    });
  });
}
