/// Geometric layout metrics and constraints ensuring an agreement fits on a single A4 page.
class PdfPageMetrics {
  final double pageWidth;
  final double pageHeight;
  final double margin;
  final double printableWidth;
  final double printableHeight;

  const PdfPageMetrics({
    required this.pageWidth,
    required this.pageHeight,
    required this.margin,
    required this.printableWidth,
    required this.printableHeight,
  });

  /// Standard A4 portrait metrics (points: 72 points per inch)
  factory PdfPageMetrics.standardA4({double margin = 24.0}) {
    const width = 595.28;
    const height = 841.89;
    return PdfPageMetrics(
      pageWidth: width,
      pageHeight: height,
      margin: margin,
      printableWidth: width - (margin * 2),
      printableHeight: height - (margin * 2),
    );
  }
}

/// Section height allocations ensuring zero overflow beyond a single A4 page.
class PdfSectionBudgets {
  final double headerHeight; // Title, Doc ID, Date
  final double partiesHeight; // 1st & 2nd Party 2-column grid
  final double termsHeight; // Amount, words, payment method
  final double clausesHeight; // Statutory clauses & custom conditions
  final double signaturesHeight; // Dual signatures / Tipshoi
  final double footerHeight; // SHA-256 QR code & legal notice

  const PdfSectionBudgets({
    this.headerHeight = 75.0,
    this.partiesHeight = 130.0,
    this.termsHeight = 120.0,
    this.clausesHeight = 240.0,
    this.signaturesHeight = 140.0,
    this.footerHeight = 60.0,
  });

  double get totalAllocatedHeight =>
      headerHeight + partiesHeight + termsHeight + clausesHeight + signaturesHeight + footerHeight;

  /// True if total content fits within the single A4 printable height budget.
  bool fitsWithinPrintableArea(PdfPageMetrics metrics) {
    return totalAllocatedHeight <= metrics.printableHeight;
  }
}

/// Pure Dart layout engine validating single-page A4 structure and official Bengali headers.
class PdfLayoutEngine {
  static const String officialDocumentHeaderBn = 'দ্বিপাক্ষিক লেনদেনের স্মারক ও অঙ্গীকারনামা';
  static const String statutoryFooterNoticeBn =
      'The Contract Act 1872 ও The Evidence (Amendment) Act 2022 এর আওতাধীন একটি বৈধ দ্বিপাক্ষিক চুক্তিপত্র।';

  final PdfPageMetrics metrics;
  final PdfSectionBudgets budgets;

  PdfLayoutEngine({
    PdfPageMetrics? metrics,
    PdfSectionBudgets? budgets,
  })  : metrics = metrics ?? PdfPageMetrics.standardA4(),
        budgets = budgets ?? const PdfSectionBudgets();

  /// Validates that the entire legal agreement fits within the single page constraint.
  bool validateSinglePageConstraint() {
    return budgets.fitsWithinPrintableArea(metrics);
  }

  /// Calculates available vertical slack space for flexible padding.
  double get remainingSlackHeight => metrics.printableHeight - budgets.totalAllocatedHeight;
}
