import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../data/template_repository.dart';
import '../domain/template_entity.dart';

/// Modal sheet displaying the 6 standardized agreement templates
class TemplateCatalogModal extends StatelessWidget {
  final Function(AgreementTemplate selectedTemplate) onSelectTemplate;

  const TemplateCatalogModal({
    super.key,
    required this.onSelectTemplate,
  });

  static void show(BuildContext context, {required Function(AgreementTemplate) onSelect}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TemplateCatalogModal(onSelectTemplate: onSelect),
    );
  }

  IconData _getTemplateIcon(String iconKey) {
    switch (iconKey) {
      case 'motorcycle':
      case 'car':
        return Icons.two_wheeler_outlined;
      case 'handshake':
        return Icons.handshake_outlined;
      case 'home':
        return Icons.home_work_outlined;
      case 'grass':
      case 'agriculture':
        return Icons.agriculture_outlined;
      case 'gavel':
        return Icons.balance_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.sales:
        return const Color(0xFF0284C7);
      case TemplateCategory.finance:
        return const Color(0xFF0D9488);
      case TemplateCategory.rental:
        return const Color(0xFFD97706);
      case TemplateCategory.services:
        return const Color(0xFF16A34A);
      case TemplateCategory.general:
        return const Color(0xFF64748B);
      case TemplateCategory.arbitration:
        return const Color(0xFF7C3AED);
    }
  }

  String _getCategoryLabelBn(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.sales:
        return 'ক্রয়-বিক্রয়';
      case TemplateCategory.finance:
        return 'আর্থিক লেনদেন';
      case TemplateCategory.rental:
        return 'ভাড়া ও লিজ';
      case TemplateCategory.services:
        return 'সেবা চুক্তি';
      case TemplateCategory.general:
        return 'সাধারণ';
      case TemplateCategory.arbitration:
        return 'সালিশ ও আপোষ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = TemplateRepository.getAllTemplates();

    return Container(
      decoration: const BoxDecoration(
        color: Color(AppColors.surfaceRaisedInt),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Color(AppColors.borderStrongInt),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(AppColors.accentInt).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: Color(AppColors.accentInt),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringsBn.templateCatalogTitle,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: AppTypography.headlineMedium,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.inkPrimaryInt),
                      ),
                    ),
                    Text(
                      'আপনার লেনদেনের ধরন অনুযায়ী যেকোনো একটি নির্বাচন করুন',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: AppTypography.labelSmall,
                        color: Color(AppColors.inkSecondaryInt),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(AppColors.borderHairlineInt)),
          const SizedBox(height: 8),

          // Template List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: templates.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final template = templates[index];
                final catColor = _getCategoryColor(template.category);

                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTemplate(template);
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(AppColors.borderHairlineInt)),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      color: Color(AppColors.surfaceRaisedInt),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Icon(
                            _getTemplateIcon(template.icon),
                            color: catColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      template.titleBn,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: AppTypography.titleMedium,
                                        fontWeight: FontWeight.w600,
                                        color: Color(AppColors.inkPrimaryInt),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: catColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    ),
                                    child: Text(
                                      _getCategoryLabelBn(template.category),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: catColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${template.fields.length}টি তথ্য ক্ষেত্র • ${template.clausesBn.length}টি আইনি ধারা',
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: AppTypography.labelSmall,
                                  color: Color(AppColors.inkSecondaryInt),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(AppColors.inkDisabledInt),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
