import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../../share/domain/whatsapp_share_service.dart';
import '../../templates/domain/template_entity.dart';
import '../../vault/domain/agreement_record.dart';

/// Full-Page PDF Document Viewer Screen with pinch-to-zoom and authentic A4 layout.
class ContractPdfViewerScreen extends StatefulWidget {
  final AgreementRecord record;
  final AgreementTemplate template;

  const ContractPdfViewerScreen({
    super.key,
    required this.record,
    required this.template,
  });

  @override
  State<ContractPdfViewerScreen> createState() => _ContractPdfViewerScreenState();
}

class _ContractPdfViewerScreenState extends State<ContractPdfViewerScreen> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    final message = WhatsAppShareService.formatShareMessage(widget.record);
    final mobile = widget.record.secondPartyMobile.isNotEmpty
        ? widget.record.secondPartyMobile
        : widget.record.firstPartyMobile;

    final uri = WhatsAppShareService.generateWhatsAppClickToChatUri(mobile, message);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(AppColors.accentInt),
            content: Text(
              'হোয়াটসঅ্যাপ শেয়ার লিংক প্রস্তুত:\n$message',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final template = widget.template;

    return Scaffold(
      backgroundColor: const Color(0xFF202428), // Authentic PDF viewer canvas background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A1D),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStringsBn.pdfViewerTitle} (${record.documentId})',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Text(
              'A4 ভেক্টর ডকুমেন্ট • জুম করতে দুই আঙুল ব্যবহার করুন',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'রিসেট জুম (100%)',
            onPressed: _resetZoom,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: AppStringsBn.shareBtn,
            onPressed: () => _shareViaWhatsApp(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // PDF Document Interactive Canvas
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.6,
              maxScale: 3.5,
              boundaryMargin: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 595), // Standard A4 width constraint
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PDF Top Government Legal Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.accentGoldInt).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: const Color(AppColors.accentGoldInt), width: 1),
                          ),
                          child: const Text(
                            'দ্বিপাক্ষিক লেনদেনের ডিজিটাল স্মারক ও অঙ্গীকারনামা',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(AppColors.accentGoldInt),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title & Document Metadata
                        Text(
                          record.titleBn,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(AppColors.inkPrimaryInt),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'স্মারক নং: ${record.documentId}  |  তারিখ: ${record.formattedDateBn}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.inkSecondaryInt),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Color(AppColors.accentInt), thickness: 1.5),
                        const SizedBox(height: 12),

                        // 1. Parties Section
                        _buildSectionHeader('১. পক্ষগণের পরিচিতি ও বিবরণ'),
                        const SizedBox(height: 8),
                        _buildRow('প্রথম পক্ষ:', '${record.firstPartyName} (${record.firstPartyMobile})'),
                        const SizedBox(height: 4),
                        _buildRow('দ্বিতীয় পক্ষ:', '${record.secondPartyName} (${record.secondPartyMobile})'),

                        const SizedBox(height: 14),

                        // 2. Transaction Terms
                        _buildSectionHeader('২. লেনদেনের শর্ত ও বিবরণ'),
                        const SizedBox(height: 8),
                        _buildRow('মোট টাকার পরিমাণ:', '৳${record.totalAmount} (${record.amountInWords})'),
                        if (record.dueAmount > 0)
                          _buildRow('অবশিষ্ট বকেয়া:', '৳${record.dueAmount}'),

                        const SizedBox(height: 14),

                        // 3. Legal Clauses
                        _buildSectionHeader('৩. চুক্তির আইনি শর্তাবলী'),
                        const SizedBox(height: 8),
                        for (final clause in template.clausesBn)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(AppColors.accentInt),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    clause,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 12,
                                      height: 1.45,
                                      color: Color(AppColors.inkPrimaryInt),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // 4. Signatures & Tipshoi Stamping Grid
                        _buildSectionHeader('৪. স্বাক্ষর ও টিপসই অঙ্গীকারনামা'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
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
                            const SizedBox(width: 14),
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

                        const SizedBox(height: 18),

                        // 5. SHA-256 Digital Security Seal
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.surfaceRaisedInt),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: const Color(AppColors.borderHairlineInt)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(AppColors.borderHairlineInt)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.qr_code_2, size: 36, color: Color(AppColors.accentInt)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SHA-256 ডিজিটাল নিরাপত্তা সিলমোহর',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(AppColors.successInt),
                                      ),
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

                        const SizedBox(height: 14),

                        // Statutory Disclaimer
                        Text(
                          AppStringsBn.legalDisclaimer,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 9,
                            color: Color(AppColors.inkDisabledInt),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom PDF Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF161A1D),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_outlined, color: Colors.white70, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'পৃষ্ঠা ১ / ১ (A4 সাইজ)',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareViaWhatsApp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text(
                      'হোয়াটসঅ্যাপ শেয়ার',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                fontSize: 11,
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
                fontSize: 11,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(AppColors.surfaceRaisedInt),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: const Color(AppColors.borderHairlineInt)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: (hasRealFile || isMockTipshoi)
                    ? const Color(AppColors.accentGoldInt)
                    : const Color(AppColors.borderStrongInt),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm - 1),
              child: hasRealFile
                  ? Image.file(
                      File(tipshoiPath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.fingerprint, size: 44, color: Color(AppColors.accentGoldInt)),
                      ),
                    )
                  : (isMockTipshoi
                      ? const Center(
                          child: Icon(Icons.fingerprint, size: 44, color: Color(AppColors.accentGoldInt)),
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
                                    fontSize: 14,
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
                                  Container(width: 44, height: 1, color: const Color(AppColors.borderStrongInt)),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(AppColors.inkPrimaryInt),
            ),
          ),
          Text(
            roleLabel,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 9,
              color: Color(AppColors.inkSecondaryInt),
            ),
          ),
          if (hasRealFile || isMockTipshoi)
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
