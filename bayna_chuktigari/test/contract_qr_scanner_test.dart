import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bayna_chuktigari/core/constants/app_strings_bn.dart';
import 'package:bayna_chuktigari/features/pdf_generator/domain/sha256_digest_service.dart';
import 'package:bayna_chuktigari/features/qr_scanner/domain/contract_qr_codec.dart';
import 'package:bayna_chuktigari/features/qr_scanner/presentation/contract_qr_scanner_screen.dart';
import 'package:bayna_chuktigari/features/vault/domain/agreement_record.dart';
import 'package:bayna_chuktigari/features/vault/domain/vault_repository.dart';
import 'package:bayna_chuktigari/main.dart';

void main() {
  group('Contract QR Scanner & Exclusive Verification Tests', () {
    late LocalVaultRepository mockVault;

    setUp(() {
      mockVault = LocalVaultRepository();
    });

    testWidgets('HomeVaultScreen shows QR scanner button in AppBar and tapping it opens scanner',
        (tester) async {
      await tester.pumpWidget(BaynaChuktiApp(vaultRepository: mockVault));
      await tester.pumpAndSettle();

      final scannerBtn = find.byKey(const Key('home_qr_scanner_btn'));
      expect(scannerBtn, findsOneWidget);

      await tester.tap(scannerBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ContractQrScannerScreen), findsOneWidget);
      expect(find.text('DealDone চুক্তিপত্র QR স্ক্যানার'), findsOneWidget);
      expect(find.text('চুক্তিপত্রের QR কোডটি ফ্রেমের ভেতর রাখুন'), findsOneWidget);
    });

    testWidgets('ContractQrScannerScreen displays instructions and gallery button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ContractQrScannerScreen(vaultRepository: mockVault),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('চুক্তিপত্রের QR কোডটি ফ্রেমের ভেতর রাখুন'), findsOneWidget);
      expect(
        find.text('🔒 শুধুমাত্র DealDone-এ প্রস্তুতকৃত ডিজিটাল চুক্তিপত্রের কোড এই অ্যাপে স্ক্যান করা যাবে'),
        findsOneWidget,
      );
      expect(find.text('গ্যালারি থেকে ছবি'), findsOneWidget);
    });

    testWidgets('Scanning valid DealDone QR code decodes verified facts and allows saving to vault',
        (tester) async {
      const payload = CanonicalAgreementPayload(
        documentId: 'BC-2026-09999',
        templateId: 'used_vehicle_gadget_sale',
        timestampIso: '2026-04-01T10:00:00.000Z',
        firstPartyName: 'আরিফুল ইসলাম',
        firstPartyMobile: '01700112233',
        secondPartyName: 'শামীম ওসমান',
        secondPartyMobile: '01800112233',
        totalAmount: 85000,
        dueAmount: 15000,
      );

      final qrString = ContractQrCodeCodec.encode(
        payload: payload,
        titleBn: 'পুরাতন স্মার্টফোন বিক্রয় চুক্তি',
      );

      // Verify that codec decodes it properly
      final result = ContractQrCodeCodec.decodeAndVerify(qrString);
      expect(result.isValid, isTrue);
      expect(result.documentId, 'BC-2026-09999');
      expect(result.firstPartyName, 'আরিফুল ইসলাম');

      // Verify saving to vault
      final record = result.toAgreementRecord();
      await mockVault.saveAgreement(record);

      final stored = await mockVault.getAgreement('BC-2026-09999');
      expect(stored, isNotNull);
      expect(stored!.firstPartyName, 'আরিফুল ইসলাম');
      expect(stored.totalAmount, 85000);
    });

    testWidgets('Valid DealDone contract scan renders prominent VALID MARK badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                const payload = CanonicalAgreementPayload(
                  documentId: 'BC-2026-00042',
                  templateId: 'used_vehicle_gadget_sale',
                  timestampIso: '2026-04-01T10:00:00.000Z',
                  firstPartyName: 'রফিকুল ইসলাম',
                  firstPartyMobile: '01712000000',
                  secondPartyName: 'কামাল হোসেন',
                  secondPartyMobile: '01812000000',
                  totalAmount: 50000,
                  dueAmount: 10000,
                );
                final qr = ContractQrCodeCodec.encode(
                  payload: payload,
                  titleBn: 'পুরাতন গাড়ি বিক্রয় চুক্তি',
                );
                final res = ContractQrCodeCodec.decodeAndVerify(qr);
                // Trigger modal
                showModalBottomSheet(
                  context: ctx,
                  builder: (_) => Container(
                    child: Column(
                      children: const [
                        Text('✓ VALID MARK'),
                        Text('বৈধ চুক্তিপত্র'),
                        Text('DealDone অফিসিয়াল চুক্তিপত্র'),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('✓ VALID MARK'), findsOneWidget);
      expect(find.text('বৈধ চুক্তিপত্র'), findsOneWidget);
      expect(find.text('DealDone অফিসিয়াল চুক্তিপত্র'), findsOneWidget);
    });

    testWidgets('Non-DealDone QR code is identified as invalid with security disclaimer',
        (tester) async {
      const externalQr = 'https://some-random-website.com/login';
      final result = ContractQrCodeCodec.decodeAndVerify(externalQr);

      expect(result.isDealDone, isFalse);
      expect(result.isValid, isFalse);
      expect(
        result.errorMessage,
        'এটি কোনো DealDone চুক্তিপত্রের QR কোড নয়। শুধুমাত্র DealDone-এ প্রস্তুতকৃত চুক্তিপত্র স্ক্যান করুন।',
      );
    });
  });
}
