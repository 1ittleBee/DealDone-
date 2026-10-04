import 'package:test/test.dart';
import 'package:bayna_chuktigari/features/pdf_generator/domain/pdf_layout_engine.dart';

void main() {
  group('Story 5.1: Single-Page A4 Bengali Vector PDF Layout Engine Tests', () {
    test('Calculates standard A4 portrait dimensions and printable bounds', () {
      final metrics = PdfPageMetrics.standardA4(margin: 24.0);

      expect(metrics.pageWidth, closeTo(595.28, 0.01));
      expect(metrics.pageHeight, closeTo(841.89, 0.01));
      expect(metrics.printableWidth, closeTo(547.28, 0.01));
      expect(metrics.printableHeight, closeTo(793.89, 0.01));
    });

    test('Guarantees total section allocations fit within single A4 page height', () {
      final engine = PdfLayoutEngine();

      expect(engine.budgets.headerHeight, equals(75.0));
      expect(engine.budgets.partiesHeight, equals(130.0));
      expect(engine.budgets.termsHeight, equals(120.0));
      expect(engine.budgets.clausesHeight, equals(240.0));
      expect(engine.budgets.signaturesHeight, equals(140.0));
      expect(engine.budgets.footerHeight, equals(60.0));

      // Total height = 765.0
      expect(engine.budgets.totalAllocatedHeight, equals(765.0));

      // Must fit in printable height (793.89)
      expect(engine.validateSinglePageConstraint(), isTrue);
      expect(engine.remainingSlackHeight, greaterThan(20.0));
    });

    test('Enforces official Bengali document header and statutory notices', () {
      expect(
        PdfLayoutEngine.officialDocumentHeaderBn,
        equals('দ্বিপাক্ষিক লেনদেনের স্মারক ও অঙ্গীকারনামা'),
      );
      expect(
        PdfLayoutEngine.statutoryFooterNoticeBn,
        contains('The Contract Act 1872 ও The Evidence (Amendment) Act 2022'),
      );
    });
  });
}
