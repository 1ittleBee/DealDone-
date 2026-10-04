import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../../share/domain/whatsapp_share_service.dart';
import '../../templates/domain/template_entity.dart';
import '../../vault/domain/agreement_record.dart';
import '../../vault/domain/vault_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../qr_scanner/domain/contract_qr_codec.dart';
import '../domain/sha256_digest_service.dart';
import 'contract_pdf_viewer_screen.dart';

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

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    final message = WhatsAppShareService.formatShareMessage(record);
    final mobile = record.secondPartyMobile.isNotEmpty
        ? record.secondPartyMobile
        : record.firstPartyMobile;

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

    final uri = WhatsAppShareService.generateWhatsAppClickToChatUri(mobile, message);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      // SnackBar remains as fallback
    }
  }

  void _openPdfViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => ContractPdfViewerScreen(
          record: record,
          template: template,
        ),
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
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: AppStringsBn.viewAsPdfBtn,
            onPressed: () => _openPdfViewer(context),
          ),
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

                  const SizedBox(height: 16),

                  // Section 4: Signatures & Tipshoi Section
                  _buildSectionHeader('৪. পক্ষগণের স্বাক্ষর ও টিপসই'),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1st Party Attestation Box
                      Expanded(
                        child: _buildPartyAttestationBox(
                          roleLabel: 'প্রথম পক্ষ',
                          name: record.firstPartyName,
                          mobile: record.firstPartyMobile,
                          signature: record.firstPartySignature,
                          tipshoiPath: record.firstPartyTipshoiPath,
                          fingerLabel: record.firstPartyFinger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 2nd Party Attestation Box
                      Expanded(
                        child: _buildPartyAttestationBox(
                          roleLabel: 'দ্বিতীয় পক্ষ',
                          name: record.secondPartyName,
                          mobile: record.secondPartyMobile,
                          signature: record.secondPartySignature,
                          tipshoiPath: record.secondPartyTipshoiPath,
                          fingerLabel: record.secondPartyFinger,
                        ),
                      ),
                    ],
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm - 1),
                            child: QrImageView(
                              data: ContractQrCodeCodec.encode(
                                payload: CanonicalAgreementPayload(
                                  documentId: record.documentId,
                                  templateId: record.templateId,
                                  timestampIso: record.createdAt.toIso8601String(),
                                  firstPartyName: record.firstPartyName,
                                  firstPartyMobile: record.firstPartyMobile,
                                  secondPartyName: record.secondPartyName,
                                  secondPartyMobile: record.secondPartyMobile,
                                  totalAmount: record.totalAmount,
                                  dueAmount: record.dueAmount,
                                ),
                                titleBn: record.titleBn,
                              ),
                              version: QrVersions.auto,
                              size: 48,
                              padding: const EdgeInsets.all(2),
                            ),
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

            // View as PDF Button
            ElevatedButton.icon(
              key: const Key('view_as_pdf_btn'),
              onPressed: () => _openPdfViewer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.accentInt),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf, size: 20),
              label: const Text(
                AppStringsBn.viewAsPdfBtn,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),

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

  Widget _buildPartyAttestationBox({
    required String roleLabel,
    required String name,
    required String mobile,
    String? signature,
    String? tipshoiPath,
    String? fingerLabel,
  }) {
    final hasRealFile = tipshoiPath != null &&
        tipshoiPath.isNotEmpty &&
        !tipshoiPath.startsWith('local://') &&
        File(tipshoiPath).existsSync();
    final isMockTipshoi = tipshoiPath != null && tipshoiPath.isNotEmpty && !hasRealFile;
    final hasSignature = signature != null && signature.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(AppColors.surfaceRaisedInt),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: const Color(AppColors.borderHairlineInt)),
      ),
      child: Column(
        children: [
          // Thumbprint / Signature Stamp Area
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: (hasRealFile || isMockTipshoi)
                    ? const Color(AppColors.accentGoldInt)
                    : const Color(AppColors.borderStrongInt),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm - 1),
              child: hasRealFile
                  ? Image.file(
                      File(tipshoiPath),
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.fingerprint, size: 48, color: Color(AppColors.accentGoldInt)),
                      ),
                    )
                  : (isMockTipshoi
                      ? const Center(
                          child: Icon(Icons.fingerprint, size: 50, color: Color(AppColors.accentGoldInt)),
                        )
                      : (hasSignature
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  signature,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w700,
                                    color: Color(AppColors.accentInt),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 1,
                                    color: const Color(AppColors.borderStrongInt),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'স্বাক্ষর',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 10,
                                      color: Color(AppColors.inkSecondaryInt),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(AppColors.inkPrimaryInt),
            ),
          ),
          Text(
            roleLabel,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              color: Color(AppColors.inkSecondaryInt),
            ),
          ),
          if (hasRealFile || isMockTipshoi)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(AppColors.accentGoldInt).withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(AppColors.accentGoldInt), width: 0.5),
              ),
              child: Text(
                'টিপসই: ${fingerLabel ?? 'বৃদ্ধাঙ্গুলি'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.accentGoldInt),
                ),
              ),
            )
          else if (hasSignature)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(AppColors.successInt).withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(AppColors.successInt), width: 0.5),
              ),
              child: const Text(
                '✓ ডিজিটাল স্বাক্ষর',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.successInt),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
