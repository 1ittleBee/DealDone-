/// Field input types supported by the template wizard
enum FieldType {
  text,
  textarea,
  number,
  phone,
  nid,
  date,
  select,
  boolean,
}

/// A single input field definition within an agreement template
class TemplateField {
  final String key;
  final String labelBn;
  final FieldType type;
  final bool required;
  final List<String>? options;

  const TemplateField({
    required this.key,
    required this.labelBn,
    required this.type,
    this.required = true,
    this.options,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label_bn': labelBn,
    'type': type.name,
    'required': required,
    if (options != null) 'options': options,
  };

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      key: json['key'] as String,
      labelBn: json['label_bn'] as String,
      type: FieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FieldType.text,
      ),
      required: json['required'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}

/// Category grouping for agreement templates
enum TemplateCategory {
  sales,
  finance,
  rental,
  services,
  general,
  arbitration,
}

/// Core agreement template definition
class AgreementTemplate {
  final String id;
  final String titleBn;
  final String titleEn;
  final TemplateCategory category;
  final String icon;
  final List<TemplateField> fields;
  final List<String> clausesBn;

  const AgreementTemplate({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.category,
    required this.icon,
    required this.fields,
    required this.clausesBn,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title_bn': titleBn,
    'title_en': titleEn,
    'category': category.name,
    'icon': icon,
    'fields': fields.map((f) => f.toJson()).toList(),
    'clauses_bn': clausesBn,
  };

  factory AgreementTemplate.fromJson(Map<String, dynamic> json) {
    return AgreementTemplate(
      id: json['id'] as String,
      titleBn: json['title_bn'] as String,
      titleEn: json['title_en'] as String,
      category: TemplateCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TemplateCategory.general,
      ),
      icon: json['icon'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map((f) => TemplateField.fromJson(f as Map<String, dynamic>))
          .toList(),
      clausesBn: (json['clauses_bn'] as List<dynamic>)
          .map((c) => c.toString())
          .toList(),
    );
  }
}
