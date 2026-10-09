import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../l10n/app_localizations.dart';

class DisplaySelector extends StatelessWidget {
  final List<DesktopCapturerSource> sources;
  final DesktopCapturerSource? selectedSource;
  final ValueChanged<DesktopCapturerSource> onSourceSelected;

  const DisplaySelector({
    super.key,
    required this.sources,
    required this.selectedSource,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (sources.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppleTheme.spacing16),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.secondarySystemBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.info_circle,
              color: CupertinoDynamicColor.resolve(AppleTheme.systemOrange, context),
              size: 20,
            ),
            const SizedBox(width: AppleTheme.spacing12),
            Expanded(
              child: Text(
                l10n.noDisplaysFound,
                style: AppleTheme.footnote.copyWith(color: AppleTheme.resolvedTertiaryLabel(context)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppleTheme.spacing4,
            bottom: AppleTheme.spacing8,
          ),
          child: Text(
            l10n.sectionSourceDisplay,
            style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context)),
          ),
        ),
        Wrap(
          spacing: AppleTheme.spacing12,
          runSpacing: AppleTheme.spacing12,
          children: sources.map((source) {
            final isSelected = selectedSource?.id == source.id;
            final isScreen = source.type == SourceType.Screen;

            return GestureDetector(
              onTap: () => onSourceSelected(source),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 180,
                padding: const EdgeInsets.all(AppleTheme.spacing12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoDynamicColor.resolve(
                          AppleTheme.systemBlue.withValues(alpha: 0.12),
                          context,
                        )
                      : CupertinoDynamicColor.resolve(
                          AppleTheme.secondarySystemBackground,
                          context,
                        ),
                  borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? AppleTheme.systemBlue
                        : CupertinoDynamicColor.resolve(
                            AppleTheme.separator,
                            context,
                          ),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isScreen
                              ? CupertinoIcons.device_desktop
                              : CupertinoIcons.macwindow,
                          size: 18,
                          color: isSelected
                              ? CupertinoDynamicColor.resolve(AppleTheme.systemBlue, context)
                              : AppleTheme.resolvedSecondaryLabel(context),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 16,
                            color: CupertinoDynamicColor.resolve(AppleTheme.systemBlue, context),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppleTheme.spacing8),
                    Text(
                      source.name.isNotEmpty
                          ? source.name
                          : l10n.displayFallback(source.id),
                      style: AppleTheme.headline.copyWith(
                        fontSize: 13,
                        color: isSelected
                            ? CupertinoDynamicColor.resolve(AppleTheme.systemBlue, context)
                            : CupertinoDynamicColor.resolve(
                                AppleTheme.label,
                                context,
                              ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppleTheme.spacing2),
                    Text(
                      isScreen ? l10n.fullScreenDisplay : l10n.appWindow,
                      style: AppleTheme.footnote.copyWith(color: AppleTheme.resolvedTertiaryLabel(context)),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
