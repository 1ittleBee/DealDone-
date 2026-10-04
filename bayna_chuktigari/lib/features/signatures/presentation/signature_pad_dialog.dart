import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings_bn.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/digital_signature.dart';
import '../domain/tipshoi_capture.dart';
import '../../agreement_wizard/domain/party_details.dart';

/// Modal dialog for capturing interactive on-screen vector signature or Tipshoi.
class SignaturePadDialog extends StatefulWidget {
  final String partyName;
  final String roleLabel;
  final Function(DigitalSignature? signature, TipshoiCapture? tipshoi) onSaved;

  const SignaturePadDialog({
    super.key,
    required this.partyName,
    required this.roleLabel,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String partyName,
    required String roleLabel,
    required Function(DigitalSignature? signature, TipshoiCapture? tipshoi) onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SignaturePadDialog(
        partyName: partyName,
        roleLabel: roleLabel,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  final List<Offset?> _points = [];
  bool _isTipshoiMode = false;
  String _selectedFinger = 'ডান বৃদ্ধাঙ্গুলি (Right Thumb)';

  bool get _hasValidPoints =>
      _points.where((p) => p != null).length >= DigitalSignature.minPointThreshold;

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  void _saveSignature() {
    final role = widget.roleLabel.contains('প্রথম') ? PartyRole.firstParty : PartyRole.secondParty;

    if (_isTipshoiMode) {
      final tipshoi = TipshoiCapture(
        id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
        signerName: widget.partyName,
        role: role,
        finger: _selectedFinger.contains('ডান')
            ? ThumbprintFinger.rightThumb
            : ThumbprintFinger.leftThumb,
        imagePath: 'local://tipshoi_${DateTime.now().millisecondsSinceEpoch}.png',
        capturedAt: DateTime.now(),
      );
      widget.onSaved(null, tipshoi);
      Navigator.pop(context);
    } else {
      if (!_hasValidPoints) return;
      final signaturePoints = _points
          .where((p) => p != null)
          .map((p) => SignaturePoint(
                x: p!.dx,
                y: p.dy,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ))
          .toList();

      final digitalSignature = DigitalSignature(
        id: 'sig_${DateTime.now().millisecondsSinceEpoch}',
        signerName: widget.partyName,
        role: role,
        strokes: [SignatureStroke(points: signaturePoints)],
        signedAt: DateTime.now(),
      );
      widget.onSaved(digitalSignature, null);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppColors.surfaceRaisedInt),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(AppColors.accentInt).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    _isTipshoiMode ? Icons.fingerprint : Icons.draw_outlined,
                    color: const Color(AppColors.accentInt),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTipshoiMode ? 'টিপসই (আঙুলের ছাপ)' : 'ডিজিটাল স্বাক্ষর',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: AppTypography.headlineMedium,
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.inkPrimaryInt),
                        ),
                      ),
                      Text(
                        '${widget.partyName} (${widget.roleLabel})',
                        style: const TextStyle(
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
            const SizedBox(height: 12),

            // Mode Selector Segment
            Container(
              decoration: BoxDecoration(
                color: const Color(AppColors.surfaceOverlayInt),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isTipshoiMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isTipshoiMode
                              ? const Color(AppColors.surfaceRaisedInt)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: !_isTipshoiMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: !_isTipshoiMode
                                  ? const Color(AppColors.accentInt)
                                  : const Color(AppColors.inkSecondaryInt),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'স্ক্রিনে স্বাক্ষর',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                fontWeight:
                                    !_isTipshoiMode ? FontWeight.w600 : FontWeight.w400,
                                color: !_isTipshoiMode
                                    ? const Color(AppColors.accentInt)
                                    : const Color(AppColors.inkSecondaryInt),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isTipshoiMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isTipshoiMode
                              ? const Color(AppColors.surfaceRaisedInt)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: _isTipshoiMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 16,
                              color: _isTipshoiMode
                                  ? const Color(AppColors.accentInt)
                                  : const Color(AppColors.inkSecondaryInt),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'টিপসই (অঙ্গুষ্ঠ)',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                fontWeight:
                                    _isTipshoiMode ? FontWeight.w600 : FontWeight.w400,
                                color: _isTipshoiMode
                                    ? const Color(AppColors.accentInt)
                                    : const Color(AppColors.inkSecondaryInt),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (!_isTipshoiMode) ...[
              // Vector Drawing Canvas
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _hasValidPoints
                        ? const Color(AppColors.accentHighlightInt)
                        : const Color(AppColors.borderStrongInt),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Stack(
                  children: [
                    // Canvas watermark / guideline
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          _points.isEmpty ? AppStringsBn.signPrompt : '',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: AppTypography.bodyMedium,
                            color: const Color(AppColors.inkDisabledInt).withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 1,
                        color: const Color(AppColors.borderHairlineInt),
                      ),
                    ),
                    // Gesture Detector for handwriting
                    GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _points.add(details.localPosition);
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _points.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _points.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter: _SignaturePainter(points: _points),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _hasValidPoints
                        ? '✓ বৈধ স্বাক্ষর শনাক্ত হয়েছে'
                        : 'কমপক্ষে ১৫টি বিন্দু বা স্পর্শ প্রয়োজন',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: _hasValidPoints
                          ? const Color(AppColors.successInt)
                          : const Color(AppColors.warningInt),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _points.isNotEmpty ? _clearCanvas : null,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(AppStringsBn.clearSign),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(AppColors.dangerInt),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Tipshoi Capture Card
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(AppColors.borderStrongInt)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.accentGoldInt).withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(AppColors.accentGoldInt),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 44,
                        color: Color(AppColors.accentGoldInt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: _selectedFinger,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'ডান বৃদ্ধাঙ্গুলি (Right Thumb)',
                          child: Text('ডান হাতের বৃদ্ধাঙ্গুলির টিপসই'),
                        ),
                        DropdownMenuItem(
                          value: 'বাম বৃদ্ধাঙ্গুলি (Left Thumb)',
                          child: Text('বাম হাতের বৃদ্ধাঙ্গুলির টিপসই'),
                        ),
                        DropdownMenuItem(
                          value: 'তর্জনী (Index Finger)',
                          child: Text('হাতের তর্জনী আঙুল'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFinger = val);
                      },
                    ),
                    const Text(
                      'টিপসই দেওয়ার জন্য নীল/কালো কালির ছাপ ক্যামেরায় ধারণ হবে',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: Color(AppColors.inkSecondaryInt),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('বাতিল'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isTipshoiMode || _hasValidPoints) ? _saveSignature : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.accentInt),
                    ),
                    child: const Text(AppStringsBn.acceptSign),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(AppColors.inkPrimaryInt)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 2.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
