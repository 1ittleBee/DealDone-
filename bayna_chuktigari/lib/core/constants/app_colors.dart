/// App color tokens mapped directly from DESIGN.md
/// Visual Identity: Judicial Trust & Civil Dignity
class AppColors {
  AppColors._();

  // Primary Brand & Surfaces
  static const int surfaceBaseInt = 0xFFF8FAFC;      // Clean slate paper off-white
  static const int surfaceRaisedInt = 0xFFFFFFFF;    // Elevated pure white card surface
  static const int surfaceOverlayInt = 0xFFF1F5F9;   // Background overlay

  // Inks & Typography
  static const int inkPrimaryInt = 0xFF0F172A;       // Deep Judicial Slate Navy
  static const int inkSecondaryInt = 0xFF475569;     // Muted slate text
  static const int inkDisabledInt = 0xFF94A3B8;      // Disabled ink

  // Brand Accents
  static const int accentInt = 0xFF0D5C75;           // Deep Judicial Seal Teal
  static const int accentHoverInt = 0xFF0A475B;      // Darker interactive teal
  static const int accentHighlightInt = 0xFF0D9488;  // Verification emerald
  static const int accentGoldInt = 0xFFD97706;       // Restrained court seal amber
  static const int accentDarkInt = 0xFF14B8A6;       // Teal accent in dark mode

  // Borders & Dividers
  static const int borderHairlineInt = 0xFFE2E8F0;   // Document border hairline
  static const int borderStrongInt = 0xFFCBD5E1;     // Emphasized border

  // Semantic Status
  static const int successInt = 0xFF16A34A;          // Success green
  static const int warningInt = 0xFFF59E0B;          // Warning amber
  static const int dangerInt = 0xFFDC2626;           // Error / Danger red

  // Hex string equivalents for styling and tests
  static const String surfaceBaseHex = '#F8FAFC';
  static const String inkPrimaryHex = '#0F172A';
  static const String accentHex = '#0D5C75';
  static const String accentHighlightHex = '#0D9488';
  static const String accentGoldHex = '#D97706';
}
