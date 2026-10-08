import 'package:flutter/cupertino.dart';

/// Semantic colors and typography strictly adhering to Apple Human Interface Guidelines (HIG)
class AppleTheme {
  // Apple System Accent Colors (Dynamic for Light and Dark)
  static const CupertinoDynamicColor systemBlue = CupertinoColors.systemBlue;
  static const CupertinoDynamicColor systemGreen = CupertinoColors.systemGreen;
  static const CupertinoDynamicColor systemOrange = CupertinoColors.systemOrange;
  static const CupertinoDynamicColor systemRed = CupertinoColors.systemRed;
  static const CupertinoDynamicColor systemPurple = CupertinoColors.systemPurple;
  static const CupertinoDynamicColor systemIndigo = CupertinoColors.systemIndigo;
  static const CupertinoDynamicColor systemTeal = CupertinoColors.systemTeal;
  static const CupertinoDynamicColor systemYellow = CupertinoColors.systemYellow;
  static const CupertinoDynamicColor systemGray = CupertinoColors.systemGrey;

  // Backgrounds
  static const CupertinoDynamicColor systemBackground =
      CupertinoColors.systemBackground;
  static const CupertinoDynamicColor secondarySystemBackground =
      CupertinoColors.secondarySystemBackground;
  static const CupertinoDynamicColor tertiarySystemBackground =
      CupertinoColors.tertiarySystemBackground;
  static const CupertinoDynamicColor systemGroupedBackground =
      CupertinoColors.systemGroupedBackground;
  static const CupertinoDynamicColor secondarySystemGroupedBackground =
      CupertinoColors.secondarySystemGroupedBackground;

  // Fills & Separators
  static const CupertinoDynamicColor separator = CupertinoColors.separator;
  static const CupertinoDynamicColor opaqueSeparator =
      CupertinoColors.opaqueSeparator;
  static const CupertinoDynamicColor systemFill = CupertinoColors.systemFill;
  static const CupertinoDynamicColor secondarySystemFill =
      CupertinoColors.secondarySystemFill;
  static const CupertinoDynamicColor tertiarySystemFill =
      CupertinoColors.tertiarySystemFill;

  // Labels
  static const CupertinoDynamicColor label = CupertinoColors.label;
  static const CupertinoDynamicColor secondaryLabel =
      CupertinoColors.secondaryLabel;
  static const CupertinoDynamicColor tertiaryLabel =
      CupertinoColors.tertiaryLabel;
  static const CupertinoDynamicColor quaternaryLabel =
      CupertinoColors.quaternaryLabel;

  // ---------------------------------------------------------------------------
  // Color Resolvers — always use these to get context-adaptive colors.
  // CupertinoDynamicColor.resolve() maps the token to light/dark automatically.
  // ---------------------------------------------------------------------------

  static Color resolvedLabel(BuildContext context) =>
      CupertinoDynamicColor.resolve(label, context);
  static Color resolvedSecondaryLabel(BuildContext context) =>
      CupertinoDynamicColor.resolve(secondaryLabel, context);
  static Color resolvedTertiaryLabel(BuildContext context) =>
      CupertinoDynamicColor.resolve(tertiaryLabel, context);
  static Color resolvedQuaternaryLabel(BuildContext context) =>
      CupertinoDynamicColor.resolve(quaternaryLabel, context);

  /// Typography scale following macOS & Apple HIG.
  ///
  /// **Note:** Colors are intentionally *omitted* from these constants.
  /// `CupertinoDynamicColor` tokens baked into a `const TextStyle` are never
  /// resolved against a `BuildContext`, which renders them as their
  /// light‑mode value (≈ black) even in Dark Mode.
  ///
  /// Instead, each widget site should either:
  /// 1. Rely on the inherited `DefaultTextStyle` / `CupertinoTheme` text color.
  /// 2. Explicitly resolve via `.copyWith(color: AppleTheme.resolvedLabel(context))`.
  static const TextStyle largeTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle monoNumber = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.1,
  );

  /// Radius tokens matching macOS Sonoma/Sequoia & Apple HIG
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusPill = 999.0;

  /// Spacing tokens
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
}
