import 'package:test/test.dart';
import '../lib/core/constants/app_colors.dart';
import '../lib/core/theme/app_theme.dart';

void main() {
  group('Story 1.2: Design Tokens & App Theme Verification', () {
    test('Shape radii match DESIGN.md specifications', () {
      expect(AppTheme.radiusSm, equals(6.0));
      expect(AppTheme.radiusMd, equals(10.0));
      expect(AppTheme.radiusLg, equals(16.0));
    });

    test('Dark mode palette adheres to tokens', () {
      expect(AppTheme.backgroundDark, equals(0xFF0B1120));
      expect(AppTheme.cardDark, equals(0xFF1E293B));
      expect(AppTheme.textDark, equals(0xFFF8FAFC));
    });

    test('Typography line heights are configured safely for Bengali', () {
      expect(AppTypography.lineHeightBody, greaterThanOrEqualTo(1.6));
      expect(AppTypography.lineHeightStandard, greaterThanOrEqualTo(1.5));
    });
  });
}
