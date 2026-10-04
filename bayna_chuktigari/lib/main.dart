import 'package:flutter/material.dart';
import 'core/constants/app_strings_bn.dart';
import 'core/theme/app_theme.dart';
import 'features/vault/domain/agreement_record.dart';
import 'features/vault/domain/vault_repository.dart';
import 'features/vault/presentation/home_vault_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline vault repository with sample demo record
  final initialVault = LocalVaultRepository([
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
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      pdfPath: 'local://documents/BC-2026-00001.pdf',
      sha256Hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ),
  ]);

  runApp(DealDoneApp(vaultRepository: initialVault));
}

/// Root Application Widget for DealDone
class DealDoneApp extends StatelessWidget {
  final VaultRepository vaultRepository;

  const DealDoneApp({
    super.key,
    required this.vaultRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStringsBn.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: HomeVaultScreen(vaultRepository: vaultRepository),
    );
  }
}

/// Backward compatibility alias
typedef BaynaChuktiApp = DealDoneApp;
