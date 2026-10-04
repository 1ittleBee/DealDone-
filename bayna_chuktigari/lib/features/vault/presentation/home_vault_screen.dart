import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../../agreement_wizard/presentation/agreement_wizard_screen.dart';
import '../../pdf_generator/presentation/pdf_preview_screen.dart';
import '../../templates/data/template_repository.dart';
import '../../templates/domain/template_entity.dart';
import '../../templates/presentation/template_catalog_modal.dart';
import '../domain/agreement_record.dart';
import '../domain/vault_repository.dart';

/// Main Home / Vault Screen
class HomeVaultScreen extends StatefulWidget {
  final VaultRepository vaultRepository;

  const HomeVaultScreen({
    super.key,
    required this.vaultRepository,
  });

  @override
  State<HomeVaultScreen> createState() => _HomeVaultScreenState();
}

class _HomeVaultScreenState extends State<HomeVaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AgreementRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgreements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgreements([String query = '']) async {
    setState(() => _isLoading = true);
    final results = query.isEmpty
        ? await widget.vaultRepository.getAllAgreements()
        : await widget.vaultRepository.searchAgreements(query);

    setState(() {
      _records = results;
      _isLoading = false;
    });
  }

  void _onTemplateSelected(AgreementTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AgreementWizardScreen(
          template: template,
          vaultRepository: widget.vaultRepository,
        ),
      ),
    ).then((_) => _loadAgreements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              AppStringsBn.appName,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              AppStringsBn.appTagline,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: const Color(AppColors.surfaceRaisedInt),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _loadAgreements(val),
              decoration: InputDecoration(
                hintText: 'নাম, মোবাইল নম্বর বা স্মারক নং দিয়ে খুঁজুন...',
                hintStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: Color(AppColors.inkSecondaryInt),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(AppColors.accentInt)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _loadAgreements();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(AppColors.borderHairlineInt)),

          // Vault Records List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? _buildEmptyState()
                    : _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          TemplateCatalogModal.show(context, onSelect: _onTemplateSelected);
        },
        backgroundColor: const Color(AppColors.accentInt),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.post_add),
        label: const Text(
          AppStringsBn.newAgreementBtn,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(AppColors.accentInt).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                size: 44,
                color: Color(AppColors.accentInt),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'কোনো সংরক্ষিত চুক্তিপত্র নেই',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: AppTypography.headlineMedium,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.inkPrimaryInt),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'নিচের "নতুন চুক্তি তৈরি করুন" বাটনে চাপ দিয়ে খুব সহজেই আপনার প্রথম আইনি চুক্তিপত্র প্রস্তুত করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: AppTypography.bodyMedium,
                color: Color(AppColors.inkSecondaryInt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: _records.length,
      itemBuilder: (ctx, index) {
        final record = _records[index];
        final template = TemplateRepository.getById(record.templateId) ??
            TemplateRepository.getAllTemplates().first;

        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => PdfPreviewScreen(
                    record: record,
                    template: template,
                    vaultRepository: widget.vaultRepository,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.accentInt).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          record.documentId,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(AppColors.accentInt),
                          ),
                        ),
                      ),
                      Text(
                        record.formattedDateBn,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          color: Color(AppColors.inkSecondaryInt),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.titleBn,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: AppTypography.titleMedium,
                      fontWeight: FontWeight.w700,
                      color: Color(AppColors.inkPrimaryInt),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${record.firstPartyName} ↔ ${record.secondPartyName}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: Color(AppColors.inkSecondaryInt),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'টাকা: ৳${record.totalAmount}',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(AppColors.accentHighlightInt),
                        ),
                      ),
                      ElevatedButton.icon(
                        key: Key('view_pdf_btn_${record.documentId}'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => PdfPreviewScreen(
                                record: record,
                                template: template,
                                vaultRepository: widget.vaultRepository,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 15),
                        label: const Text(
                          AppStringsBn.viewPdfBtn,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.accentInt),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
