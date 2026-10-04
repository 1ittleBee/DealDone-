import 'dart:io';
import 'package:test/test.dart';
import '../lib/core/constants/app_colors.dart';
import '../lib/core/constants/app_strings_bn.dart';
import '../lib/core/theme/app_theme.dart';

void main() {
  group('Story 1.1: Project Scaffolding & Design Tokens Verification', () {
    test('AppColors matches DESIGN.md tokens', () {
      expect(AppColors.surfaceBaseInt, equals(0xFFF8FAFC));
      expect(AppColors.inkPrimaryInt, equals(0xFF0F172A));
      expect(AppColors.accentInt, equals(0xFF0D5C75));
      expect(AppColors.accentHighlightInt, equals(0xFF0D9488));
      expect(AppColors.accentGoldInt, equals(0xFFD97706));
    });

    test('AppStringsBn contains mandatory statutory notices', () {
      expect(AppStringsBn.appName, equals('DealDone'));
      expect(AppStringsBn.legalDisclaimer, contains('The Contract Act, 1872'));
      expect(AppStringsBn.legalDisclaimer, contains('Section 10'));
      expect(AppStringsBn.legalDisclaimer, contains('The Evidence (Amendment) Act, 2022'));
      expect(AppStringsBn.legalDisclaimer, contains('Section 85A'));
      expect(AppStringsBn.legalDisclaimer, contains('Section 65B'));
      expect(AppStringsBn.legalDisclaimer, contains('সাব-রেজিস্ট্রি দলিলের বিকল্প নহে'));
    });

    test('AppTheme enforces accessibility and Bengali font family', () {
      expect(AppTheme.fontFamily, equals('HindSiliguri'));
      expect(AppTheme.minTouchTarget, greaterThanOrEqualTo(48.0));
      expect(AppTypography.lineHeightStandard, greaterThanOrEqualTo(1.5));
    });

    test('pubspec.yaml exists and registers HindSiliguri fonts', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final content = pubspecFile.readAsStringSync();
      expect(content, contains('name: bayna_chuktigari'));
      expect(content, contains('HindSiliguri'));
      expect(content, contains('HindSiliguri-Regular.ttf'));
      expect(content, contains('HindSiliguri-Bold.ttf'));
    });

    test('Core directory scaffolding exists per ARCHITECTURE-SPINE.md', () {
      expect(Directory('lib/core/constants').existsSync(), isTrue);
      expect(Directory('lib/core/theme').existsSync(), isTrue);
      expect(Directory('assets/fonts/HindSiliguri').existsSync(), isTrue);
    });
  });
}
