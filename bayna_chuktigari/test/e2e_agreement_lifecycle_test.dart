import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bayna_chuktigari/core/constants/app_strings_bn.dart';
import 'package:bayna_chuktigari/features/agreement_wizard/presentation/agreement_wizard_screen.dart';
import 'package:bayna_chuktigari/features/pdf_generator/presentation/pdf_preview_screen.dart';
import 'package:bayna_chuktigari/features/signatures/presentation/signature_pad_dialog.dart';
import 'package:bayna_chuktigari/features/templates/presentation/template_catalog_modal.dart';
import 'package:bayna_chuktigari/features/vault/domain/vault_repository.dart';
import 'package:bayna_chuktigari/features/vault/presentation/home_vault_screen.dart';
import 'package:bayna_chuktigari/main.dart';

void main() {
  group('End-to-End Agreement Creation Lifecycle Test', () {
    late LocalVaultRepository vaultRepository;

    setUp(() {
      // Start with an empty vault to test 0 to 1 document creation lifecycle
      vaultRepository = LocalVaultRepository([]);
    });

    testWidgets(
      'Full End-to-End Flow: Launch -> Select Template -> 4-Step Wizard -> Attestation -> PDF Preview -> WhatsApp Share -> Vault Save',
      (tester) async {
        // Set phone-like viewport
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // 1. App Launch
        await tester.pumpWidget(BaynaChuktiApp(vaultRepository: vaultRepository));
        await tester.pumpAndSettle();

        // Verify Home Screen with Empty State
        expect(find.text(AppStringsBn.appName), findsOneWidget);
        expect(find.text('কোনো সংরক্ষিত চুক্তিপত্র নেই'), findsOneWidget);

        // 2. Open Template Catalog Modal
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        expect(find.byType(TemplateCatalogModal), findsOneWidget);
        expect(find.text('পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি'), findsOneWidget);

        // 3. Select Template
        await tester.tap(find.text('পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি'));
        await tester.pumpAndSettle();

        // 4. Verify Wizard Step 1: Parties
        expect(find.byType(AgreementWizardScreen), findsOneWidget);
        expect(find.text('ধাপ ১ / ৪'), findsOneWidget);
        expect(find.text('পক্ষগণের বিবরণ'), findsOneWidget);

        // Fill Party 1 Details
        final nameFields = find.widgetWithText(TextField, AppStringsBn.nameLabel);
        final phoneFields = find.widgetWithText(TextField, AppStringsBn.phoneLabel);
        final nidFields = find.widgetWithText(TextField, AppStringsBn.nidLabel);

        await tester.enterText(nameFields.at(0), 'মোঃ করিম উল্লাহ');
        await tester.enterText(phoneFields.at(0), '01712345678');
        await tester.enterText(nidFields.at(0), '19901234567890');

        // Fill Party 2 Details
        await tester.enterText(nameFields.at(1), 'তানভীর আহমেদ');
        await tester.enterText(phoneFields.at(1), '01898765432');
        await tester.enterText(nidFields.at(1), '19929876543210');
        await tester.pumpAndSettle();

        // Proceed to Step 2
        final nextBtnStep1 = find.widgetWithText(ElevatedButton, 'পরবর্তী ধাপ');
        await tester.tap(nextBtnStep1);
        await tester.pumpAndSettle();

        // 5. Verify Wizard Step 2: Terms & Real-Time Currency Transcription
        expect(find.text('ধাপ ২ / ৪'), findsOneWidget);
        expect(find.text('লেনদেন ও শর্তাবলী'), findsOneWidget);

        final amountField = find.widgetWithText(TextField, AppStringsBn.amountLabel);
        final advanceField = find.widgetWithText(TextField, 'পরিশোধিত বা বায়না অর্থ (যদি থাকে)');

        // Enter Total Amount: ৳75,000
        await tester.enterText(amountField, '75000');
        await tester.pumpAndSettle();

        // Verify Dynamic Bengali Legal Currency in Words Transcription
        expect(find.textContaining('পঁচাত্তর হাজার টাকা মাত্র'), findsOneWidget);

        // Enter Advance Amount: ৳15,000
        await tester.enterText(advanceField, '15000');
        await tester.pumpAndSettle();

        // Proceed to Step 3
        final nextBtnStep2 = find.widgetWithText(ElevatedButton, 'পরবর্তী ধাপ');
        await tester.tap(nextBtnStep2);
        await tester.pumpAndSettle();

        // 6. Verify Wizard Step 3: Evidence & Attachments
        expect(find.text('ধাপ ৩ / ৪'), findsOneWidget);
        expect(find.text('প্রমাণপত্র ও ছবি'), findsOneWidget);

        // Add Evidence Photo
        final addPhotoBtn = find.widgetWithText(OutlinedButton, 'ছবি তুলুন বা ফাইল যুক্ত করুন');
        expect(addPhotoBtn, findsOneWidget);
        await tester.tap(addPhotoBtn);
        await tester.pumpAndSettle();

        // Verify attachment registered
        expect(find.text('রসিদ / প্রমাণের ছবি ১'), findsOneWidget);

        // Proceed to Step 4
        final nextBtnStep3 = find.widgetWithText(ElevatedButton, 'পরবর্তী ধাপ');
        await tester.tap(nextBtnStep3);
        await tester.pumpAndSettle();

        // 7. Verify Wizard Step 4: Digital Signatures & Attestation
        expect(find.text('ধাপ ৪ / ৪'), findsOneWidget);
        expect(find.text('ডিজিটাল স্বাক্ষর'), findsOneWidget);

        // --- Attest Party 1 (On-Screen Vector Signature) ---
        final signButtons = find.widgetWithText(ElevatedButton, 'স্বাক্ষর করুন');
        expect(signButtons, findsWidgets);

        await tester.tap(signButtons.first);
        await tester.pumpAndSettle();

        expect(find.byType(SignaturePadDialog), findsOneWidget);

        // Draw smooth vector stroke on canvas (generating >=15 stroke points)
        final canvasFinder = find.byKey(const Key('signature_canvas_gesture'));
        final gesture = await tester.startGesture(tester.getCenter(canvasFinder));
        for (int i = 0; i < 20; i++) {
          await gesture.moveBy(const Offset(4, 2));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tester.pumpAndSettle();

        // Accept Signature 1
        final acceptBtn1 = find.widgetWithText(ElevatedButton, AppStringsBn.acceptSign);
        expect(acceptBtn1, findsOneWidget);
        await tester.tap(acceptBtn1);
        await tester.pumpAndSettle();

        // Verify Party 1 Attestation Marked Complete
        expect(find.text('✓ ডিজিটাল স্বাক্ষর সম্পন্ন'), findsOneWidget);

        // --- Attest Party 2 (Tipshoi / Thumbprint Mode) ---
        final signButton2 = find.widgetWithText(ElevatedButton, 'স্বাক্ষর করুন');
        expect(signButton2, findsOneWidget);

        await tester.tap(signButton2);
        await tester.pumpAndSettle();

        expect(find.byType(SignaturePadDialog), findsOneWidget);

        // Switch to Tipshoi mode
        await tester.tap(find.text('টিপসই (অঙ্গুষ্ঠ)'));
        await tester.pumpAndSettle();

        // Accept Tipshoi
        final acceptBtn2 = find.widgetWithText(ElevatedButton, AppStringsBn.acceptSign);
        await tester.tap(acceptBtn2);
        await tester.pumpAndSettle();

        // Verify Party 2 Tipshoi Marked Complete
        expect(find.text('✓ টিপসই যুক্ত সম্পন্ন'), findsOneWidget);

        // 8. Finalize Agreement
        final finalizeBtn = find.widgetWithText(ElevatedButton, 'চুক্তিপত্র চূড়ান্ত করুন');
        expect(finalizeBtn, findsOneWidget);
        await tester.tap(finalizeBtn);
        await tester.pumpAndSettle();

        // 9. Verify PDF Preview & Share Screen
        expect(find.byType(PdfPreviewScreen), findsOneWidget);
        expect(find.text('ডিজিটাল চুক্তিপত্র ও রসিদ'), findsOneWidget);

        // Verify Sequential Document ID
        expect(find.textContaining('BC-2026-00001'), findsWidgets);

        // Verify Tamper-Evident SHA-256 Seal
        expect(find.text('SHA-256 ডিজিটাল নিরাপত্তা সিলমোহর'), findsOneWidget);

        // Verify Statutory Disclaimers
        expect(find.textContaining('The Contract Act, 1872'), findsOneWidget);
        expect(find.textContaining('The Evidence (Amendment) Act, 2022'), findsOneWidget);

        // Verify 1-Tap WhatsApp Share Trigger
        final whatsappShareBtn = find.widgetWithText(ElevatedButton, AppStringsBn.shareBtn);
        expect(whatsappShareBtn, findsOneWidget);
        await tester.ensureVisible(whatsappShareBtn);
        await tester.tap(whatsappShareBtn);
        await tester.pump();

        // Verify WhatsApp SnackBar with Click-to-Chat payload
        expect(find.textContaining('হোয়াটসঅ্যাপ শেয়ার লিংক প্রস্তুত:'), findsOneWidget);
        expect(find.textContaining('BC-2026-00001'), findsWidgets);

        // 10. Return to Home Vault
        final returnHomeBtn = find.widgetWithText(OutlinedButton, 'সংরক্ষিত ভল্টে ফিরে যান');
        await tester.ensureVisible(returnHomeBtn);
        await tester.tap(returnHomeBtn);
        await tester.pumpAndSettle();

        // 11. Verify Home Vault Screen Updates With The New Document
        expect(find.byType(HomeVaultScreen), findsOneWidget);
        expect(find.text('BC-2026-00001'), findsOneWidget);
        expect(find.text('মোঃ করিম উল্লাহ ↔ তানভীর আহমেদ'), findsOneWidget);
        expect(find.text('টাকা: ৳75000'), findsOneWidget);

        // 12. Verify Vault Search Capabilities
        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'করিম উল্লাহ');
        await tester.pumpAndSettle();
        expect(find.text('BC-2026-00001'), findsOneWidget);

        await tester.enterText(searchField, '01898765432');
        await tester.pumpAndSettle();
        expect(find.text('BC-2026-00001'), findsOneWidget);

        // Search non-existing
        await tester.enterText(searchField, 'অজানা পক্ষ');
        await tester.pumpAndSettle();
        expect(find.text('কোনো সংরক্ষিত চুক্তিপত্র নেই'), findsOneWidget);
      },
    );
  });
}
