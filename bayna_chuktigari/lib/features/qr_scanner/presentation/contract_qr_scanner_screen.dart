import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../../pdf_generator/presentation/pdf_preview_screen.dart';
import '../../templates/data/template_repository.dart';
import '../../vault/domain/vault_repository.dart';
import '../domain/contract_qr_codec.dart';

/// Full-Screen QR Scanner for verifying DealDone legal agreements.
class ContractQrScannerScreen extends StatefulWidget {
  final VaultRepository vaultRepository;

  const ContractQrScannerScreen({
    super.key,
    required this.vaultRepository,
  });

  @override
  State<ContractQrScannerScreen> createState() => _ContractQrScannerScreenState();
}

class _ContractQrScannerScreenState extends State<ContractQrScannerScreen> {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  bool get _isTestEnv =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _processScannedCode(rawValue);
        break;
      }
    }
  }

  void _processScannedCode(String code) {
    setState(() => _isProcessing = true);
    final result = ContractQrCodeCodec.decodeAndVerify(code);

    if (!result.isDealDone || !result.isValid) {
      _showInvalidQrDialog(result.errorMessage ?? 'অপ্রাসঙ্গিক বা অবৈধ QR কোড');
    } else {
      _showVerificationModal(result);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final barcodes = await _scannerController.analyzeImage(pickedFile.path);
    if (!mounted) return;

    if (barcodes != null && barcodes.barcodes.isNotEmpty) {
      final raw = barcodes.barcodes.first.rawValue;
      if (raw != null) {
        _processScannedCode(raw);
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(AppColors.dangerInt),
          content: Text(
            'নির্বাচিত ছবিতে কোনো QR কোড খুঁজে পাওয়া যায়নি।',
            style: TextStyle(fontFamily: AppTheme.fontFamily),
          ),
        ),
      );
    }
  }

  void _showInvalidQrDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: Row(
          children: const [
            Icon(Icons.gpp_bad_outlined, color: Color(AppColors.dangerInt), size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'অবৈধ QR কোড',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(AppColors.dangerInt),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: Color(AppColors.inkPrimaryInt),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(AppColors.accentGoldInt).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: const Color(AppColors.accentGoldInt), width: 0.8),
              ),
              child: const Text(
                '🔒 নিরাপত্তা সতর্কবার্তা: DealDone অ্যাপ শুধুমাত্র নিজস্ব ভেরিফায়েড ডিজিটাল চুক্তির QR কোড স্ক্যান ও প্রমাণ করতে পারে।',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  color: Color(AppColors.inkSecondaryInt),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.accentInt),
              foregroundColor: Colors.white,
            ),
            child: const Text('আবার স্ক্যান করুন'),
          ),
        ],
      ),
    );
  }

  void _showVerificationModal(ContractVerificationResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Official VALID MARK Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: const Color(AppColors.successInt), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppColors.successInt).withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Official Valid Mark Stamp Emblem
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.successInt),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(AppColors.successInt).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(AppColors.successInt),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '✓ VALID MARK',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'বৈধ চুক্তিপত্র',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(AppColors.successInt),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'DealDone অফিসিয়াল চুক্তিপত্র',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(AppColors.inkPrimaryInt),
                            ),
                          ),
                          Text(
                            'স্মারক নং: ${result.documentId}',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(AppColors.accentInt),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Contract details card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.surfaceRaisedInt),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: const Color(AppColors.borderHairlineInt)),
                ),
                child: Column(
                  children: [
                    // Status Badge with Valid Mark
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.successInt).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: const Color(AppColors.successInt), width: 0.8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle, size: 16, color: Color(AppColors.successInt)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'আইনি স্ট্যাটাস: এই চুক্তিপত্রটি ১০০% আসল ও অপরিবর্তিত (VALID)',
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
                    ),
                    _buildModalRow('চুক্তির শিরোনাম:', result.titleBn),
                    _buildModalRow('প্রথম পক্ষ:', '${result.firstPartyName} (${result.firstPartyMobile})'),
                    _buildModalRow('দ্বিতীয় পক্ষ:', '${result.secondPartyName} (${result.secondPartyMobile})'),
                    _buildModalRow('মোট লেনদেন:', '৳${result.totalAmount}'),
                    if (result.dueAmount > 0)
                      _buildModalRow('বকেয়া টাকা:', '৳${result.dueAmount}'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.security, size: 14, color: Color(AppColors.successInt)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'SHA-256: ${result.sha256Hash}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 10,
                              color: Color(AppColors.inkSecondaryInt),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () async {
                  final record = result.toAgreementRecord();
                  await widget.vaultRepository.saveAgreement(record);
                  if (mounted && ctx.mounted) {
                    Navigator.pop(ctx);
                    final template = TemplateRepository.getById(record.templateId) ??
                        TemplateRepository.getAllTemplates().first;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (c) => PdfPreviewScreen(
                          record: record,
                          template: template,
                          vaultRepository: widget.vaultRepository,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.accentInt),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text(
                  'চুক্তিপত্রটি দেখুন ও ভল্টে সেভ করুন',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isProcessing = false);
                },
                child: const Text('আরও স্ক্যান করুন'),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
                fontWeight: FontWeight.w600,
                color: Color(AppColors.inkPrimaryInt),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DealDone চুক্তিপত্র QR স্ক্যানার',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'ফ্ল্যাশলাইট',
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined),
            tooltip: 'ক্যামেরা পরিবর্তন',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (_isTestEnv)
            const Center(
              child: Text(
                'Camera View (Test Environment)',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),

          // Custom Scanner Overlay
          Column(
            children: [
              // Top Shade
              Container(
                height: 60,
                color: Colors.black.withOpacity(0.55),
              ),

              // Viewfinder Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 270,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),

                  // Viewfinder Target Box
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(AppColors.accentGoldInt),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Stack(
                      children: [
                        // Viewfinder corner marks
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(width: 20, height: 4, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(width: 4, height: 20, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(width: 20, height: 4, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(width: 4, height: 20, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(width: 20, height: 4, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(width: 4, height: 20, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(width: 20, height: 4, color: const Color(AppColors.accentInt)),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(width: 4, height: 20, color: const Color(AppColors.accentInt)),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      height: 270,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),

              // Bottom Shade & Instructions
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.55),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: const [
                          Text(
                            'চুক্তিপত্রের QR কোডটি ফ্রেমের ভেতর রাখুন',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '🔒 শুধুমাত্র DealDone-এ প্রস্তুতকৃত ডিজিটাল চুক্তিপত্রের কোড এই অ্যাপে স্ক্যান করা যাবে',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      // Gallery / Test Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImageFromGallery,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('গ্যালারি থেকে ছবি'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
