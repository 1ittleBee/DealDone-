import '../../../core/constants/app_strings_bn.dart';
import 'template_entity.dart';

/// Manages statutory legal clauses and custom conditions.
/// Implements FR-2 and Story 2.2.
class GeneratedClauses {
  final List<String> mandatoryClauses;
  final List<String> customConditions;
  final String statutoryDisclaimer;

  const GeneratedClauses({
    required this.mandatoryClauses,
    this.customConditions = const [],
    this.statutoryDisclaimer = AppStringsBn.legalDisclaimer,
  });

  /// Maximum allowed custom conditions per agreement
  static const int maxCustomConditions = 3;

  /// Returns a new instance with an added custom condition
  GeneratedClauses addCustomCondition(String condition) {
    final trimmed = condition.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('শর্তের বিবরণ খালি রাখা যাবে না');
    }
    if (customConditions.length >= maxCustomConditions) {
      throw StateError('সর্বোচ্চ $maxCustomConditions টি বিশেষ শর্ত যোগ করা যাবে');
    }
    return GeneratedClauses(
      mandatoryClauses: mandatoryClauses,
      customConditions: [...customConditions, trimmed],
      statutoryDisclaimer: statutoryDisclaimer,
    );
  }

  /// Returns all clauses combined in legal order for PDF rendering
  List<String> getAllClauses() {
    final list = <String>[...mandatoryClauses];
    if (customConditions.isNotEmpty) {
      for (int i = 0; i < customConditions.length; i++) {
        list.add('বিশেষ শর্ত (${i + 1}): ${customConditions[i]}');
      }
    }
    return List.unmodifiable(list);
  }

  Map<String, dynamic> toJson() => {
    'mandatory_clauses': mandatoryClauses,
    'custom_conditions': customConditions,
    'statutory_disclaimer': statutoryDisclaimer,
  };

  factory GeneratedClauses.fromJson(Map<String, dynamic> json) {
    return GeneratedClauses(
      mandatoryClauses: (json['mandatory_clauses'] as List<dynamic>).map((e) => e.toString()).toList(),
      customConditions: (json['custom_conditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      statutoryDisclaimer: json['statutory_disclaimer'] as String? ?? AppStringsBn.legalDisclaimer,
    );
  }
}

/// Domain utility generating clauses for a selected template
class ClauseGenerator {
  ClauseGenerator._();

  /// Generates initial clauses for [template]
  static GeneratedClauses generateForTemplate(AgreementTemplate template, [List<String>? initialCustomConditions]) {
    return GeneratedClauses(
      mandatoryClauses: List.unmodifiable(template.clausesBn),
      customConditions: initialCustomConditions != null
          ? List.unmodifiable(initialCustomConditions.take(GeneratedClauses.maxCustomConditions))
          : const [],
    );
  }
}
