import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../../share/domain/whatsapp_share_service.dart';
import '../../templates/domain/template_entity.dart';
import '../../vault/domain/agreement_record.dart';
import '../../vault/domain/vault_repository.dart';

/// PDF Preview and 1-Tap Share Screen
class PdfPreviewScreen extends StatelessWidget {
  final AgreementRecord record;
  final AgreementTemplate template;
  final VaultRepository vaultRepository;

  const PdfPreviewScreen({
    super.key,
    required this.record,
    required this.template,
    required this.vaultRepository,
  });

  void _shareViaWhatsApp(BuildContext context) {
    final message = WhatsAppShareService.formatShareMessage(record);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(AppColors.accentInt),
        content: Text(
          'হোয়াটসঅ্যাপ শেয়ার লিংক প্রস্তুত:\n$message',
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ডিজিটাল চুক্তিপত্র ও রসিদ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareViaWhatsApp(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // A4 Document Preview Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: const Color(AppColors.borderStrongInt)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Official Document Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.accentGoldInt).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: const Color(AppColors.accentGoldInt)),
                          ),
                          child: const Text(
                            'দ্বিপাক্ষিক লেনদেনের ডিজিটাল স্মারক ও অঙ্গীকারনামা',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(AppColors.accentGoldInt),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          record.titleBn,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: AppTypography.headlineLarge,
                            fontWeight: FontWeight.w700,
                            color: Color(AppColors.inkPrimaryInt),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'স্মারক নং: ${record.documentId} • তারিখ: ${record.formattedDateBn}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: AppTypography.labelSmall,
                            color: Color(AppColors.inkSecondaryInt),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(AppColors.accentInt), thickness: 1.5),
                  const SizedBox(height: 14),

                  // Parties Section
                  _buildSectionHeader('১. পক্ষগণের পরিচিতি'),
                  const SizedBox(height: 8),
                  _buildRow('প্রথম পক্ষ:', '${record.firstPartyName} (${record.firstPartyMobile})'),
                  _buildRow('দ্বিতীয় পক্ষ:', '${record.secondPartyName} (${record.secondPartyMobile})'),

                  const SizedBox(height: 16),

                  // Transaction Section
                  _buildSectionHeader('২. লেনদেনের বিবরণ ও অর্থ'),
                  const SizedBox(height: 8),
                  _buildRow('মোট টাকার পরিমাণ:', '৳${record.totalAmount} (${record.amountInWords})'),
                  if (record.dueAmount > 0)
                    _buildRow('অবশিষ্ট বকেয়া:', '৳${record.dueAmount}'),

                  const SizedBox(height: 16),

                  // Clauses Section
                  _buildSectionHeader('৩. আইনি শর্ত ও অঙ্গীকার'),
                  const SizedBox(height: 8),
                  for (final clause in template.clausesBn)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $clause',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: Color(AppColors.inkPrimaryInt),
                          height: 1.5,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Attestation & Integrity Seal
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.surfaceOverlayInt),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: const Color(AppColors.borderHairlineInt)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: const Color(AppColors.borderStrongInt)),
                          ),
                          child: const Icon(
                            Icons.qr_code_2,
                            size: 40,
                            color: Color(AppColors.inkPrimaryInt),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.verified, size: 14, color: Color(AppColors.successInt)),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'SHA-256 ডিজিটাল নিরাপত্তা সিলমোহর',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(AppColors.successInt),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                record.sha256Hash,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  color: Color(AppColors.inkSecondaryInt),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Statutory Disclaimer
                  Text(
                    AppStringsBn.legalDisclaimer,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      color: Color(AppColors.inkDisabledInt),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // WhatsApp 1-Tap Share Button
            ElevatedButton.icon(
              onPressed: () => _shareViaWhatsApp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Brand Green
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.send),
              label: const Text(
                AppStringsBn.shareBtn,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            // Return to Home
            OutlinedButton.icon(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('সংরক্ষিত ভল্টে ফিরে যান'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: AppTypography.titleMedium,
        fontWeight: FontWeight.w700,
        color: Color(AppColors.accentInt),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.inkSecondaryInt),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(AppColors.inkPrimaryInt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
