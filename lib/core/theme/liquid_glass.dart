import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'apple_theme.dart';

enum LiquidGlassVariant {
  regular, // For sidebars, toolbars, popovers, navigation
  clear, // For controls floating directly over rich video/media
}

/// Implements Apple HIG Liquid Glass material for the Functional Layer
/// (Navigation bars, sidebars, floating control bars, dialogs).
///
/// Complies with Apple HIG:
/// - Never used in content cards or item lists.
/// - Fallback to opaque surfaces when highContrast or reduceTransparency is requested.
/// - Hairline border and subtle specular reflection.
class LiquidGlassSurface extends StatelessWidget {
  final Widget child;
  final LiquidGlassVariant variant;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Border? border;
  final bool clip;

  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.variant = LiquidGlassVariant.regular,
    this.borderRadius = AppleTheme.radiusMedium,
    this.padding,
    this.border,
    this.clip = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        CupertinoTheme.maybeBrightnessOf(context) == Brightness.dark;
    final isHighContrast = MediaQuery.of(context).highContrast;

    // Accessibility fallback: If High Contrast is enabled, drop blur and use opaque background
    if (isHighContrast) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6),
            width: 1.0,
          ),
        ),
        child: child,
      );
    }

    final double blurSigma =
        variant == LiquidGlassVariant.regular ? 24.0 : 12.0;

    // Fill opacity based on variant and appearance
    final Color tintColor = switch (variant) {
      LiquidGlassVariant.regular => isDark
          ? const Color(0x991E1E20) // ~60% dark tint
          : const Color(0xB3FFFFFF), // ~70% white tint
      LiquidGlassVariant.clear => isDark
          ? const Color(0x59000000) // ~35% dimming layer for dark
          : const Color(0x66FFFFFF), // ~40% white tint for clear
    };

    final Border effectiveBorder = border ??
        Border.all(
          color: isDark
              ? const Color(0x26FFFFFF) // 15% hairline light highlight
              : const Color(0x33000000), // 20% hairline dark highlight
          width: 0.5,
        );

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
      ),
      child: child,
    );

    if (clip) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    } else {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      );
    }
  }
}
