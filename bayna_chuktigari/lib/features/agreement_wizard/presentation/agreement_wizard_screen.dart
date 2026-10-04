import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/bangla_currency_words.dart';
import '../../../core/utils/bangla_date_formatter.dart';
import '../../pdf_generator/domain/document_id_generator.dart';
import '../../pdf_generator/domain/sha256_digest_service.dart';
import '../../pdf_generator/presentation/pdf_preview_screen.dart';
import '../../signatures/domain/digital_signature.dart';
import '../../signatures/domain/tipshoi_capture.dart';
import '../../signatures/presentation/signature_pad_dialog.dart';
import '../../templates/domain/template_entity.dart';
import '../../vault/domain/agreement_record.dart';
import '../../vault/domain/vault_repository.dart';
import '../domain/evidence_attachment.dart';
import '../domain/party_details.dart';
import '../domain/party_validator.dart';
import '../domain/transaction_terms.dart';
import '../domain/wizard_state.dart';

/// 4-Step Progressive Disclosure Agreement Wizard Screen
class AgreementWizardScreen extends StatefulWidget {
  final AgreementTemplate template;
  final VaultRepository vaultRepository;

  const AgreementWizardScreen({
    super.key,
    required this.template,
    required this.vaultRepository,
  });

  @override
  State<AgreementWizardScreen> createState() => _AgreementWizardScreenState();
}

class _AgreementWizardScreenState extends State<AgreementWizardScreen> {
  int _currentStepIndex = 0; // 0 to 3

  // Step 1 Controllers
  final _p1NameController = TextEditingController();
  final _p1PhoneController = TextEditingController();
  final _p1NidController = TextEditingController();

  final _p2NameController = TextEditingController();
  final _p2PhoneController = TextEditingController();
  final _p2NidController = TextEditingController();

  // Step 2 Controllers
  final _amountController = TextEditingController();
  final _advanceController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  String _currencyInWords = '';

  // Step 3 Attachments
  final List<EvidenceAttachment> _attachments = [];

  // Step 4 Signatures
  DigitalSignature? _p1Signature;
  TipshoiCapture? _p1Tipshoi;
  DigitalSignature? _p2Signature;
  TipshoiCapture? _p2Tipshoi;
  final _witnessNameController = TextEditingController();
  final _witnessPhoneController = TextEditingController();

  // Validation errors
  String? _p1PhoneError;
  String? _p2PhoneError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _p1NameController.dispose();
    _p1PhoneController.dispose();
    _p1NidController.dispose();
    _p2NameController.dispose();
    _p2PhoneController.dispose();
    _p2NidController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    _witnessNameController.dispose();
    _witnessPhoneController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text.trim();
    final normalized = PartyValidator.normalizeDigits(text);
    final val = int.tryParse(normalized);
    if (val != null && val > 0) {
      setState(() {
        _currencyInWords = BanglaCurrencyWords.convert(val);
        _amountError = null;
      });
    } else {
      setState(() {
        _currencyInWords = '';
      });
    }
  }

  bool _validateStep1() {
    final p1PhoneVal = PartyValidator.validateMobile(_p1PhoneController.text);
    final p2PhoneVal = PartyValidator.validateMobile(_p2PhoneController.text);

    setState(() {
      _p1PhoneError = p1PhoneVal;
      _p2PhoneError = p2PhoneVal;
    });

    if (_p1NameController.text.trim().isEmpty || _p2NameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('উভয় পক্ষের পূর্ণ নাম প্রদান করুন')),
      );
      return false;
    }

    if (p1PhoneVal != null || p2PhoneVal != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক ১১ ডিজিটের মোবাইল নম্বর প্রদান করুন')),
      );
      return false;
    }

    return true;
  }

  bool _validateStep2() {
    final totalNorm = PartyValidator.normalizeDigits(_amountController.text);
    final total = int.tryParse(totalNorm) ?? 0;
    if (total <= 0) {
      setState(() {
        _amountError = 'সঠিক টাকার পরিমাণ দিন';
      });
      return false;
    }

    final advNorm = PartyValidator.normalizeDigits(_advanceController.text);
    final adv = int.tryParse(advNorm) ?? 0;
    if (adv > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অগ্রিম টাকা মোট মূল্যের চেয়ে বেশি হতে পারে না')),
      );
      return false;
    }

    return true;
  }

  void _nextStep() {
    if (_currentStepIndex == 0 && !_validateStep1()) return;
    if (_currentStepIndex == 1 && !_validateStep2()) return;

    if (_currentStepIndex < 3) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      _finalizeAgreement();
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finalizeAgreement() async {
    final hasP1 = _p1Signature != null || _p1Tipshoi != null;
    final hasP2 = _p2Signature != null || _p2Tipshoi != null;

    if (!hasP1 || !hasP2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('উভয় পক্ষের স্বাক্ষর বা টিপসই সম্পন্ন করুন')),
      );
      return;
    }

    // Generate Document ID
    final count = await widget.vaultRepository.getCount();
    final docId = DocumentIdGenerator.generate(count + 1);

    // Generate SHA-256 Digest
    final totalAmount = int.tryParse(PartyValidator.normalizeDigits(_amountController.text)) ?? 0;
    final advanceAmount = int.tryParse(PartyValidator.normalizeDigits(_advanceController.text)) ?? 0;

    final digestPayload = CanonicalAgreementPayload(
      documentId: docId,
      templateId: widget.template.id,
      timestampIso: DateTime.now().toIso8601String(),
      firstPartyName: _p1NameController.text.trim(),
      firstPartyMobile: _p1PhoneController.text.trim(),
      secondPartyName: _p2NameController.text.trim(),
      secondPartyMobile: _p2PhoneController.text.trim(),
      totalAmount: totalAmount,
      dueAmount: totalAmount - advanceAmount,
    );
    final sha256 = digestPayload.computeSha256Digest();

    final record = AgreementRecord(
      documentId: docId,
      titleBn: widget.template.titleBn,
      templateId: widget.template.id,
      firstPartyName: _p1NameController.text.trim(),
      firstPartyMobile: _p1PhoneController.text.trim(),
      secondPartyName: _p2NameController.text.trim(),
      secondPartyMobile: _p2PhoneController.text.trim(),
      totalAmount: totalAmount,
      dueAmount: totalAmount - advanceAmount,
      createdAt: DateTime.now(),
      pdfPath: 'local://documents/$docId.pdf',
      sha256Hash: sha256,
    );

    // Save to Vault
    await widget.vaultRepository.saveAgreement(record);

    if (!mounted) return;

    // Navigate to PDF Preview
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => PdfPreviewScreen(
          record: record,
          template: widget.template,
          vaultRepository: widget.vaultRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const steps = WizardStep.values;
    final activeStep = steps[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.titleBn),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                activeStep.stepLabelBn,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          LinearProgressIndicator(
            value: (_currentStepIndex + 1) / 4.0,
            backgroundColor: const Color(AppColors.borderHairlineInt),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(AppColors.accentHighlightInt)),
            minHeight: 4,
          ),

          // Main Step Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeStep.titleBn,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: AppTypography.headlineMedium,
                      fontWeight: FontWeight.w700,
                      color: Color(AppColors.inkPrimaryInt),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_currentStepIndex == 0) _buildStep1Parties(),
                  if (_currentStepIndex == 1) _buildStep2Terms(),
                  if (_currentStepIndex == 2) _buildStep3Evidence(),
                  if (_currentStepIndex == 3) _buildStep4Signatures(),
                ],
              ),
            ),
          ),

          // Bottom Control Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(AppColors.surfaceRaisedInt),
              border: const Border(
                top: BorderSide(color: Color(AppColors.borderHairlineInt)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStepIndex > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      child: const Text('পেছনে'),
                    ),
                  ),
                if (_currentStepIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.accentInt),
                    ),
                    child: Text(_currentStepIndex == 3 ? 'চুক্তিপত্র চূড়ান্ত করুন' : 'পরবর্তী ধাপ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Parties ---
  Widget _buildStep1Parties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Party 1 Card
        _buildPartyCard(
          title: AppStringsBn.party1Label,
          nameController: _p1NameController,
          phoneController: _p1PhoneController,
          nidController: _p1NidController,
          phoneError: _p1PhoneError,
          tagColor: const Color(AppColors.accentInt),
        ),
        const SizedBox(height: 16),

        // Party 2 Card
        _buildPartyCard(
          title: AppStringsBn.party2Label,
          nameController: _p2NameController,
          phoneController: _p2PhoneController,
          nidController: _p2NidController,
          phoneError: _p2PhoneError,
          tagColor: const Color(AppColors.accentHighlightInt),
        ),
      ],
    );
  }

  Widget _buildPartyCard({
    required String title,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController nidController,
    String? phoneError,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.surfaceRaisedInt),
        border: Border.all(color: const Color(AppColors.borderHairlineInt)),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: AppTypography.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.inkPrimaryInt),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: AppStringsBn.nameLabel,
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: AppStringsBn.phoneLabel,
              prefixIcon: const Icon(Icons.phone_android_outlined),
              errorText: phoneError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nidController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppStringsBn.nidLabel,
              prefixIcon: Icon(Icons.credit_card_outlined),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2: Terms & Money ---
  Widget _buildStep2Terms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(AppColors.surfaceRaisedInt),
            border: Border.all(color: const Color(AppColors.borderHairlineInt)),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStringsBn.amountLabel,
                  prefixIcon: const Icon(Icons.payments_outlined),
                  errorText: _amountError,
                ),
              ),
              if (_currencyInWords.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.accentInt).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: const Color(AppColors.accentInt).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Color(AppColors.accentInt),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppStringsBn.amountInWordsPrefix} $_currencyInWords',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.accentInt),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _advanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'পরিশোধিত বা বায়না অর্থ (যদি থাকে)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(AppColors.borderHairlineInt)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(AppColors.inkSecondaryInt)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'লেনদেন বা হস্তান্তরের চূড়ান্ত তারিখ',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 11,
                                color: Color(AppColors.inkSecondaryInt),
                              ),
                            ),
                            Text(
                              BanglaDateFormatter.formatBengali(_dueDate),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(AppColors.inkPrimaryInt),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Statutory clauses note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(AppColors.surfaceOverlayInt),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Color(AppColors.accentInt)),
                  SizedBox(width: 6),
                  Text(
                    'আইনি সুরক্ষা ও বিধিসম্মত শর্তাবলী',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.accentInt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final clause in widget.template.clausesBn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $clause',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: Color(AppColors.inkSecondaryInt),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 3: Evidence & Attachments ---
  Widget _buildStep3Evidence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(AppColors.surfaceRaisedInt),
            border: Border.all(color: const Color(AppColors.borderHairlineInt)),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 48,
                color: Color(AppColors.accentInt),
              ),
              const SizedBox(height: 12),
              const Text(
                'রসিদ, জাতীয় পরিচয়পত্র বা পণ্যের ছবি সংযুক্ত করুন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: AppTypography.titleMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'সর্বোচ্চ ৩টি সংযুক্তি যুক্ত করা যাবে (ঐচ্ছিক)',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: Color(AppColors.inkSecondaryInt),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _attachments.length < 3
                    ? () {
                        setState(() {
                          _attachments.add(
                            EvidenceAttachment(
                              id: 'att_${_attachments.length + 1}',
                              filePath: 'local://evidence_${DateTime.now().millisecondsSinceEpoch}.jpg',
                              titleBn:
                                  'রসিদ / প্রমাণের ছবি ${BanglaDateFormatter.toBengaliDigits(_attachments.length + 1)}',
                              fileSizeBytes: 120 * 1024,
                              capturedAt: DateTime.now(),
                            ),
                          );
                        });
                      }
                    : null,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('ছবি তুলুন বা ফাইল যুক্ত করুন'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_attachments.isNotEmpty) ...[
          const Text(
            'সংযুক্ত প্রমাণাদি:',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _attachments.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.image_outlined, color: Color(AppColors.accentInt)),
                title: Text(_attachments[i].titleBn),
                subtitle: const Text('আকার: ১২০ KB • সংরক্ষিত'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(AppColors.dangerInt)),
                  onPressed: () => setState(() => _attachments.removeAt(i)),
                ),
              ),
            ),
        ],
      ],
    );
  }

  // --- Step 4: Digital Signatures & Attestation ---
  Widget _buildStep4Signatures() {
    final hasP1 = _p1Signature != null || _p1Tipshoi != null;
    final hasP2 = _p2Signature != null || _p2Tipshoi != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Party 1 Signature Card
        _buildSignatureTile(
          partyName: _p1NameController.text.isNotEmpty ? _p1NameController.text : 'প্রথম পক্ষ',
          roleLabel: 'প্রথম পক্ষ',
          isSigned: hasP1,
          modeLabel: _p1Tipshoi != null ? 'টিপসই যুক্ত' : (_p1Signature != null ? 'ডিজিটাল স্বাক্ষর' : ''),
          onTap: () {
            SignaturePadDialog.show(
              context,
              partyName: _p1NameController.text,
              roleLabel: 'প্রথম পক্ষ',
              onSaved: (sig, tip) {
                setState(() {
                  _p1Signature = sig;
                  _p1Tipshoi = tip;
                });
              },
            );
          },
        ),
        const SizedBox(height: 14),

        // Party 2 Signature Card
        _buildSignatureTile(
          partyName: _p2NameController.text.isNotEmpty ? _p2NameController.text : 'দ্বিতীয় পক্ষ',
          roleLabel: 'দ্বিতীয় পক্ষ',
          isSigned: hasP2,
          modeLabel: _p2Tipshoi != null ? 'টিপসই যুক্ত' : (_p2Signature != null ? 'ডিজিটাল স্বাক্ষর' : ''),
          onTap: () {
            SignaturePadDialog.show(
              context,
              partyName: _p2NameController.text,
              roleLabel: 'দ্বিতীয় পক্ষ',
              onSaved: (sig, tip) {
                setState(() {
                  _p2Signature = sig;
                  _p2Tipshoi = tip;
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Optional Witness Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(AppColors.surfaceRaisedInt),
            border: Border.all(color: const Color(AppColors.borderHairlineInt)),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.people_outline, size: 18, color: Color(AppColors.accentGoldInt)),
                  SizedBox(width: 8),
                  Text(
                    'সাক্ষীর বিবরণ (ঐচ্ছিক)',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: AppTypography.titleMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _witnessNameController,
                decoration: const InputDecoration(
                  labelText: 'সাক্ষীর নাম',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _witnessPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'সাক্ষীর মোবাইল নম্বর',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureTile({
    required String partyName,
    required String roleLabel,
    required bool isSigned,
    required String modeLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.surfaceRaisedInt),
        border: Border.all(
          color: isSigned
              ? const Color(AppColors.successInt)
              : const Color(AppColors.borderStrongInt),
          width: isSigned ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSigned
                  ? const Color(AppColors.successInt).withOpacity(0.12)
                  : const Color(AppColors.surfaceOverlayInt),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSigned ? Icons.check_circle : Icons.draw_outlined,
              color: isSigned
                  ? const Color(AppColors.successInt)
                  : const Color(AppColors.inkSecondaryInt),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partyName,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: AppTypography.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isSigned ? '✓ $modeLabel সম্পন্ন' : 'স্বাক্ষর বা টিপসই গৃহীত হয়নি',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: isSigned
                        ? const Color(AppColors.successInt)
                        : const Color(AppColors.warningInt),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSigned
                  ? const Color(AppColors.surfaceOverlayInt)
                  : const Color(AppColors.accentInt),
              foregroundColor: isSigned
                  ? const Color(AppColors.inkPrimaryInt)
                  : Colors.white,
              minimumSize: const Size(88, 38),
            ),
            child: Text(isSigned ? 'পুনরায় দিন' : 'স্বাক্ষর করুন'),
          ),
        ],
      ),
    );
  }
}
