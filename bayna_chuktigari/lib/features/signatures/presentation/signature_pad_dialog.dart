import 'package:flutter/material.dart';
import 'package:bayna_chuktigari/core/constants/app_colors.dart';
import 'package:bayna_chuktigari/core/constants/app_strings_bn.dart';
import 'package:bayna_chuktigari/core/theme/app_theme.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/domain/party_details.dart';
import 'package:bayna_chuktigari/features/signatures/domain/digital_signature.dart';
import 'package:bayna_chuktigari/features/signatures/domain/tipshoi_capture.dart';

enum SignaturePadMode { draw, type, tipshoi }

/// Modal bottom sheet / dialog providing 3 signature options:
/// 1. Smooth Bezier finger drawing with friction smoothing
/// 2. Type-to-Sign (DocuSign style cursive auto-signature)
/// 3. Physical Tipshoi (thumbprint) capture
class SignaturePadDialog extends StatefulWidget {
  final String partyName;
  final String roleLabel;
  final Function(DigitalSignature?, TipshoiCapture?) onSaved;

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
    required Function(DigitalSignature?, TipshoiCapture?) onSaved,
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
  SignaturePadMode _mode = SignaturePadMode.draw;
  String _selectedFinger = 'ডান বৃদ্ধাঙ্গুলি (Right Thumb)';
  late final TextEditingController _typedNameController;

  @override
  void initState() {
    super.initState();
    _typedNameController = TextEditingController(text: widget.partyName);
  }

  @override
  void dispose() {
    _typedNameController.dispose();
    super.dispose();
  }

  bool get _hasValidPoints =>
      _points.where((p) => p != null).length >= 10;

  bool get _canSubmit {
    switch (_mode) {
      case SignaturePadMode.draw:
        return _hasValidPoints;
      case SignaturePadMode.type:
        return _typedNameController.text.trim().isNotEmpty;
      case SignaturePadMode.tipshoi:
        return true;
    }
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  void _saveSignature() {
    final role = widget.roleLabel.contains('প্রথম') ? PartyRole.firstParty : PartyRole.secondParty;

    if (_mode == SignaturePadMode.tipshoi) {
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
    } else if (_mode == SignaturePadMode.type) {
      final signerName = _typedNameController.text.trim().isNotEmpty
          ? _typedNameController.text.trim()
          : widget.partyName;
      final signaturePoints = <SignaturePoint>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < 20; i++) {
        signaturePoints.add(SignaturePoint(
          x: 20.0 + (i * 12.0),
          y: 50.0 + (i % 2 == 0 ? 6.0 : -6.0),
          timestampMs: now + (i * 20),
        ));
      }
      final digitalSignature = DigitalSignature(
        id: 'sig_${DateTime.now().millisecondsSinceEpoch}',
        signerName: signerName,
        role: role,
        strokes: [SignatureStroke(points: signaturePoints)],
        signedAt: DateTime.now(),
      );
      widget.onSaved(digitalSignature, null);
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
                    _mode == SignaturePadMode.tipshoi
                        ? Icons.fingerprint
                        : (_mode == SignaturePadMode.type
                            ? Icons.keyboard_outlined
                            : Icons.draw_outlined),
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
                        _mode == SignaturePadMode.tipshoi
                            ? 'টিপসই (আঙুলের ছাপ)'
                            : (_mode == SignaturePadMode.type
                                ? 'নাম টাইপ করে স্বাক্ষর'
                                : 'স্ক্রিনে ডিজিটাল স্বাক্ষর'),
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

            // 3-Way Mode Selector Segment
            Container(
              decoration: BoxDecoration(
                color: const Color(AppColors.surfaceOverlayInt),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  // Tab 1: Draw
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = SignaturePadMode.draw),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == SignaturePadMode.draw
                              ? const Color(AppColors.surfaceRaisedInt)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: _mode == SignaturePadMode.draw
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: _mode == SignaturePadMode.draw
                                  ? const Color(AppColors.accentInt)
                                  : const Color(AppColors.inkSecondaryInt),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'স্ক্রিনে স্বাক্ষর',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: _mode == SignaturePadMode.draw
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _mode == SignaturePadMode.draw
                                      ? const Color(AppColors.accentInt)
                                      : const Color(AppColors.inkSecondaryInt),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Tab 2: Type
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = SignaturePadMode.type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == SignaturePadMode.type
                              ? const Color(AppColors.surfaceRaisedInt)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: _mode == SignaturePadMode.type
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.keyboard_outlined,
                              size: 15,
                              color: _mode == SignaturePadMode.type
                                  ? const Color(AppColors.accentInt)
                                  : const Color(AppColors.inkSecondaryInt),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'টাইপ করুন',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: _mode == SignaturePadMode.type
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _mode == SignaturePadMode.type
                                      ? const Color(AppColors.accentInt)
                                      : const Color(AppColors.inkSecondaryInt),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Tab 3: Tipshoi
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = SignaturePadMode.tipshoi),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == SignaturePadMode.tipshoi
                              ? const Color(AppColors.surfaceRaisedInt)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: _mode == SignaturePadMode.tipshoi
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 15,
                              color: _mode == SignaturePadMode.tipshoi
                                  ? const Color(AppColors.accentInt)
                                  : const Color(AppColors.inkSecondaryInt),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'টিপসই (অঙ্গুষ্ঠ)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: _mode == SignaturePadMode.tipshoi
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _mode == SignaturePadMode.tipshoi
                                      ? const Color(AppColors.accentInt)
                                      : const Color(AppColors.inkSecondaryInt),
                                ),
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

            // Content Area based on Mode
            if (_mode == SignaturePadMode.draw) ...[
              // Vector Drawing Pad with Bezier smoothing
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(AppColors.borderStrongInt)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Stack(
                    children: [
                      // Guide watermark
                      if (_points.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gesture,
                                size: 36,
                                color: const Color(AppColors.inkSecondaryInt).withOpacity(0.35),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStringsBn.signPrompt,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  color: const Color(AppColors.inkSecondaryInt).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Baseline line
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 1,
                          color: const Color(AppColors.borderHairlineInt),
                        ),
                      ),
                      // Gesture Detector for handwriting with auto-interpolation
                      GestureDetector(
                        key: const Key('signature_canvas_gesture'),
                        onPanStart: (details) {
                          setState(() {
                            _points.add(details.localPosition);
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            final last = _points.isNotEmpty ? _points.last : null;
                            if (last != null) {
                              // Midpoint smoothing to mitigate screen friction
                              final mid = Offset(
                                (last.dx + details.localPosition.dx) / 2,
                                (last.dy + details.localPosition.dy) / 2,
                              );
                              _points.add(mid);
                            }
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
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _hasValidPoints
                          ? '✓ মসৃণ স্বাক্ষর গৃহীত হয়েছে'
                          : 'আঙুল দিয়ে স্ক্রিনে স্পষ্ট করে আঁকুন',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: _hasValidPoints
                            ? const Color(AppColors.successInt)
                            : const Color(AppColors.warningInt),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ] else if (_mode == SignaturePadMode.type) ...[
              // Type-to-Sign (DocuSign Cursive Style)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(AppColors.borderStrongInt)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _typedNameController,
                      decoration: const InputDecoration(
                        labelText: 'স্বাক্ষরের নাম লিখুন',
                        prefixIcon: Icon(Icons.drive_file_rename_outline),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ডিজিটাল ক্যালিগ্রাফি স্বাক্ষর নমুনা:',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: Color(AppColors.inkSecondaryInt),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.surfaceOverlayInt).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: const Color(AppColors.accentGoldInt)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _typedNameController.text.trim().isNotEmpty
                                ? _typedNameController.text.trim()
                                : widget.partyName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: Color(AppColors.accentInt),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2,
                            width: 140,
                            decoration: BoxDecoration(
                              color: const Color(AppColors.accentGoldInt),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '✓ DocuSign স্টাইলে ডিজিটাল বৈধ স্বাক্ষর',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              color: Color(AppColors.successInt),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Tipshoi Capture Card
              Container(
                height: 220,
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
                      width: 68,
                      height: 68,
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
                        size: 42,
                        color: Color(AppColors.accentGoldInt),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    onPressed: _canSubmit ? _saveSignature : null,
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

/// Smooth Bezier Curve Canvas Painter with liquid ink feel
class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(AppColors.inkPrimaryInt)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5
      ..isAntiAlias = true;

    final path = Path();
    bool isStarting = true;

    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      if (current == null) {
        isStarting = true;
        continue;
      }

      if (isStarting) {
        path.moveTo(current.dx, current.dy);
        isStarting = false;
      } else {
        final prev = points[i - 1];
        if (prev != null) {
          final midX = (prev.dx + current.dx) / 2;
          final midY = (prev.dy + current.dy) / 2;
          path.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
        }
      }
    }

    canvas.drawPath(path, paint);

    // Draw individual dot if tapped once
    for (int i = 0; i < points.length; i++) {
      if (points[i] != null &&
          (i == 0 || points[i - 1] == null) &&
          (i == points.length - 1 || points[i + 1] == null)) {
        canvas.drawCircle(points[i]!, 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
