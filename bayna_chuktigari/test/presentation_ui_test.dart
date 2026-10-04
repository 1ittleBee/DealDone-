import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bayna_chuktigari/core/constants/app_strings_bn.dart';
import 'package:bayna_chuktigari/features/templates/presentation/template_catalog_modal.dart';
import 'package:bayna_chuktigari/features/vault/domain/agreement_record.dart';
import 'package:bayna_chuktigari/features/vault/domain/vault_repository.dart';
import 'package:bayna_chuktigari/features/vault/presentation/home_vault_screen.dart';
import 'package:bayna_chuktigari/main.dart';

void main() {
  group('Presentation Layer UI Tests', () {
    late LocalVaultRepository mockVault;

    setUp(() {
      mockVault = LocalVaultRepository([
        AgreementRecord(
          documentId: 'BC-2026-00001',
          titleBn: 'পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি',
          templateId: 'used_vehicle_gadget_sale',
          firstPartyName: 'মোঃ আব্দুল করিম',
          firstPartyMobile: '01712345678',
          secondPartyName: 'তানভীর আহমেদ',
          secondPartyMobile: '01898765432',
          totalAmount: 145000,
          dueAmount: 25000,
          createdAt: DateTime.now(),
          pdfPath: 'local://documents/BC-2026-00001.pdf',
          sha256Hash: 'dummy_hash_12345',
        ),
      ]);
    });

    testWidgets('HomeVaultScreen renders app header and agreement list', (tester) async {
      await tester.pumpWidget(BaynaChuktiApp(vaultRepository: mockVault));
      await tester.pumpAndSettle();

      // Verify App Title & Tagline
      expect(find.text(AppStringsBn.appName), findsOneWidget);
      expect(find.text(AppStringsBn.appTagline), findsOneWidget);

      // Verify FAB
      expect(find.text(AppStringsBn.newAgreementBtn), findsOneWidget);

      // Verify Seed Document rendered
      expect(find.text('BC-2026-00001'), findsOneWidget);
      expect(find.text('পুরাতন গাড়ি / পণ্য বিক্রয় চুক্তি'), findsOneWidget);
      expect(find.text('মোঃ আব্দুল করিম ↔ তানভীর আহমেদ'), findsOneWidget);
      expect(find.text('টাকা: ৳145000'), findsOneWidget);
      expect(find.text(AppStringsBn.viewPdfBtn), findsOneWidget);
    });

    testWidgets('Tapping view PDF button opens PdfPreviewScreen', (tester) async {
      await tester.pumpWidget(BaynaChuktiApp(vaultRepository: mockVault));
      await tester.pumpAndSettle();

      final pdfBtn = find.text(AppStringsBn.viewPdfBtn);
      expect(pdfBtn, findsOneWidget);
      await tester.tap(pdfBtn);
      await tester.pumpAndSettle();

      expect(find.text('ডিজিটাল চুক্তিপত্র ও রসিদ'), findsOneWidget);
    });

    testWidgets('Tapping FAB opens TemplateCatalogModal with templates', (tester) async {
      await tester.pumpWidget(BaynaChuktiApp(vaultRepository: mockVault));
      await tester.pumpAndSettle();

      // Tap FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify Modal opens with catalog title
      expect(find.text(AppStringsBn.templateCatalogTitle), findsOneWidget);
      expect(find.byType(TemplateCatalogModal), findsOneWidget);
    });

    testWidgets('Searching vault filters the displayed agreements', (tester) async {
      await tester.pumpWidget(BaynaChuktiApp(vaultRepository: mockVault));
      await tester.pumpAndSettle();

      // Enter search query that matches
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'আব্দুল করিম');
      await tester.pumpAndSettle();
      expect(find.text('BC-2026-00001'), findsOneWidget);

      // Enter query that does not match
      await tester.enterText(searchField, 'অপরিচিত ব্যক্তি');
      await tester.pumpAndSettle();
      expect(find.text('কোনো সংরক্ষিত চুক্তিপত্র নেই'), findsOneWidget);
    });
  });
}
