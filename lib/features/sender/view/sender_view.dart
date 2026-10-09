import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/sender_controller.dart';
import 'display_selector.dart';

class SenderView extends StatelessWidget {
  final SenderController controller;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSwitchToReceiver;
  final bool? isMacOverride;

  const SenderView({
    super.key,
    required this.controller,
    this.onOpenSettings,
    this.onSwitchToReceiver,
    this.isMacOverride,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSupported = isMacOverride ?? Platform.isMacOS;

    // Sender view (Extend & Mirror) is exclusive to macOS for now
    if (!isSupported) {
      return _buildDisabledPlatformView(context, l10n);
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isStreaming = controller.status == SenderStatus.streaming;
        final isConnecting = controller.status == SenderStatus.connecting;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing24,
            vertical: AppleTheme.spacing20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Recording Permission Banner (macOS)
              if (!controller.hasScreenPermission)
                _buildPermissionAlert(context, l10n),

              // Title Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.senderTitle,
                          style: AppleTheme.title1.copyWith(
                            color: AppleTheme.resolvedLabel(context),
                          ),
                        ),
                        const SizedBox(height: AppleTheme.spacing4),
                        Text(
                          l10n.senderSubtitle,
                          style: AppleTheme.callout.copyWith(
                            color: CupertinoDynamicColor.resolve(
                              AppleTheme.secondaryLabel,
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppleTheme.spacing16),
                  _buildStatusBadge(context, l10n),
                ],
              ),

              const SizedBox(height: AppleTheme.spacing20),

              // Mode Switcher (Extend vs Mirror)
              _buildModeSwitcher(context, l10n),

              const SizedBox(height: AppleTheme.spacing20),

              // Error banner if any
              if (controller.errorMessage != null)
                _buildErrorBanner(context, controller.errorMessage!),

              // Discovered Receivers Section
              _buildReceiversSection(context, l10n),

              // In Mirror mode: Screen & Window picker
              if (controller.streamMode == SenderStreamMode.mirror) ...[
                const SizedBox(height: AppleTheme.spacing20),
                DisplaySelector(
                  sources: controller.webrtcManager.availableSources,
                  selectedSource: controller.webrtcManager.selectedSource,
                  onSourceSelected: controller.selectSource,
                ),
              ],

              const SizedBox(height: AppleTheme.spacing24),

              // Streaming Controls
              _buildStreamControls(context, l10n, isStreaming, isConnecting),

              // Settings hint when idle in Extend mode
              if (!isStreaming) ...[
                const SizedBox(height: AppleTheme.spacing20),
                _buildSettingsHint(context, l10n),
              ],

              // Active streaming status card (preview eliminated from sender screen)
              if (isStreaming) ...[
                const SizedBox(height: AppleTheme.spacing24),
                _buildActiveStreamCard(context, l10n),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeSwitcher(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.tertiarySystemFill,
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
      ),
      child: CupertinoSlidingSegmentedControl<SenderStreamMode>(
        groupValue: controller.streamMode,
        backgroundColor: CupertinoColors.transparent,
        thumbColor: CupertinoDynamicColor.resolve(
          AppleTheme.secondarySystemBackground,
          context,
        ),
        children: {
          SenderStreamMode.extend: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.rectangle_split_3x1, size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.modeExtend,
                  style: AppleTheme.callout.copyWith(
                    fontWeight: controller.streamMode == SenderStreamMode.extend
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: AppleTheme.resolvedLabel(context),
                  ),
                ),
              ],
            ),
          ),
          SenderStreamMode.mirror: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.tv, size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.modeMirror,
                  style: AppleTheme.callout.copyWith(
                    fontWeight: controller.streamMode == SenderStreamMode.mirror
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: AppleTheme.resolvedLabel(context),
                  ),
                ),
              ],
            ),
          ),
        },
        onValueChanged: (mode) {
          if (mode != null) {
            controller.setStreamMode(mode);
          }
        },
      ),
    );
  }

  Widget _buildReceiversSection(BuildContext context, AppLocalizations l10n) {
    final receivers = controller.availableReceivers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.sectionAvailableReceivers,
              style: AppleTheme.caption.copyWith(
                color: AppleTheme.resolvedTertiaryLabel(context),
              ),
            ),
            const Spacer(),
            if (controller.discoveryService.isScanning)
              const CupertinoActivityIndicator(radius: 7),
          ],
        ),
        const SizedBox(height: AppleTheme.spacing8),
        if (receivers.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppleTheme.spacing20),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                AppleTheme.secondarySystemBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.tv,
                    size: 32,
                    color: CupertinoDynamicColor.resolve(
                      AppleTheme.tertiaryLabel,
                      context,
                    ),
                  ),
                  const SizedBox(height: AppleTheme.spacing8),
                  Text(
                    l10n.searchingReceivers,
                    style: AppleTheme.callout.copyWith(
                      color: AppleTheme.resolvedSecondaryLabel(context),
                    ),
                  ),
                  const SizedBox(height: AppleTheme.spacing4),
                  Text(
                    l10n.searchingReceiversHint,
                    style: AppleTheme.footnote.copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppleTheme.tertiaryLabel,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: AppleTheme.spacing12,
            runSpacing: AppleTheme.spacing12,
            children: receivers.map((receiver) {
              final isSelected = controller.selectedReceiver?.id == receiver.id;

              return GestureDetector(
                onTap: () => controller.selectReceiver(receiver),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(AppleTheme.spacing16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CupertinoDynamicColor.resolve(
                            AppleTheme.systemBlue.withValues(alpha: 0.08),
                            context,
                          )
                        : CupertinoDynamicColor.resolve(
                            AppleTheme.secondarySystemBackground,
                            context,
                          ),
                    borderRadius:
                        BorderRadius.circular(AppleTheme.radiusMedium),
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
                          const Icon(
                            CupertinoIcons.device_desktop,
                            size: 20,
                            color: AppleTheme.systemBlue,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppleTheme.systemGreen.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppleTheme.radiusSmall),
                            ),
                            child: Text(
                              '${receiver.screenWidth}×${receiver.screenHeight} @ ${receiver.refreshRate}Hz',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: CupertinoDynamicColor.resolve(
                                  AppleTheme.systemGreen,
                                  context,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppleTheme.spacing12),
                      Text(
                        receiver.name,
                        style: AppleTheme.headline.copyWith(
                          color: AppleTheme.resolvedLabel(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppleTheme.spacing2),
                      Text(
                        'IP: ${receiver.host}:${receiver.port}',
                        style: AppleTheme.footnote.copyWith(
                          color: AppleTheme.resolvedTertiaryLabel(context),
                        ),
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

  Widget _buildStreamControls(
    BuildContext context,
    AppLocalizations l10n,
    bool isStreaming,
    bool isConnecting,
  ) {
    final targetName = controller.selectedReceiver?.name ?? '';
    final actionLabel = controller.streamMode == SenderStreamMode.extend
        ? l10n.startExtend(targetName)
        : l10n.startMirror(targetName);

    return Row(
      children: [
        if (isStreaming) ...[
          CupertinoButton(
            color: CupertinoColors.destructiveRed,
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            onPressed: controller.stopStreaming,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.stop_fill, size: 16),
                const SizedBox(width: AppleTheme.spacing8),
                Text(
                  l10n.disconnectDisplay,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (Platform.isMacOS && controller.streamMode == SenderStreamMode.extend) ...[
            const SizedBox(width: AppleTheme.spacing12),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: CupertinoDynamicColor.resolve(
                AppleTheme.tertiarySystemFill,
                context,
              ),
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              onPressed: controller.openMacDisplaySettings,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.macwindow, size: 16),
                  const SizedBox(width: AppleTheme.spacing8),
                  Text(
                    l10n.arrangeMacDisplays,
                    style: TextStyle(
                      color: AppleTheme.resolvedLabel(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else ...[
          CupertinoButton.filled(
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            onPressed: isConnecting ? null : controller.startStreaming,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isConnecting) ...[
                  const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                    radius: 8,
                  ),
                  const SizedBox(width: AppleTheme.spacing8),
                ] else ...[
                  const Icon(CupertinoIcons.play_fill, size: 16),
                  const SizedBox(width: AppleTheme.spacing8),
                ],
                Text(
                  isConnecting ? l10n.connecting : actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(width: AppleTheme.spacing16),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: CupertinoDynamicColor.resolve(
            AppleTheme.tertiarySystemFill,
            context,
          ),
          borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
          onPressed: () => controller.discoveryService.startScanning(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.refresh,
                size: 16,
                color: AppleTheme.resolvedLabel(context),
              ),
              const SizedBox(width: AppleTheme.spacing8),
              Text(
                l10n.rescanReceivers,
                style: TextStyle(
                  color: AppleTheme.resolvedLabel(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsHint(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.tertiarySystemFill,
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.separator,
            context,
          ),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            size: 18,
            color: CupertinoDynamicColor.resolve(
              AppleTheme.secondaryLabel,
              context,
            ),
          ),
          const SizedBox(width: AppleTheme.spacing12),
          Expanded(
            child: Text(
              l10n.senderSettingsHint,
              style: AppleTheme.callout.copyWith(
                color: AppleTheme.resolvedSecondaryLabel(context),
              ),
            ),
          ),
          if (onOpenSettings != null) ...[
            const SizedBox(width: AppleTheme.spacing12),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: CupertinoDynamicColor.resolve(
                AppleTheme.secondarySystemBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
              onPressed: onOpenSettings,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.gear_alt, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    l10n.openSettings,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppleTheme.resolvedLabel(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveStreamCard(BuildContext context, AppLocalizations l10n) {
    final receiver = controller.selectedReceiver;
    final isExtend = controller.streamMode == SenderStreamMode.extend;

    return Container(
      padding: const EdgeInsets.all(AppleTheme.spacing20),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.secondarySystemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.separator,
            context,
          ),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppleTheme.systemGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppleTheme.spacing8),
              Text(
                isExtend ? l10n.statusVirtualActive : l10n.statusMirrorActive,
                style: AppleTheme.headline.copyWith(
                  color: AppleTheme.resolvedLabel(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppleTheme.spacing8),
          Text(
            isExtend
                ? 'Desktop extended to ${receiver?.name ?? "secondary display"} with low-latency WebRTC.'
                : 'Display mirror active to ${receiver?.name ?? "target display"}.',
            style: AppleTheme.callout.copyWith(
              color: AppleTheme.resolvedSecondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AppLocalizations l10n) {
    final (Color color, String text, IconData icon) = switch (controller.status) {
      SenderStatus.streaming => (
          AppleTheme.systemGreen,
          controller.streamMode == SenderStreamMode.extend
              ? l10n.statusVirtualActive
              : l10n.statusMirrorActive,
          CupertinoIcons.checkmark_alt_circle_fill,
        ),
      SenderStatus.connecting => (
          AppleTheme.systemOrange,
          l10n.statusConnecting,
          CupertinoIcons.arrow_2_circlepath,
        ),
      SenderStatus.searching => (
          AppleTheme.systemBlue,
          l10n.statusScanning,
          CupertinoIcons.radiowaves_right,
        ),
      SenderStatus.error => (
          AppleTheme.systemRed,
          l10n.statusError,
          CupertinoIcons.exclamationmark_circle_fill,
        ),
      SenderStatus.idle => (
          AppleTheme.systemGreen,
          l10n.statusReady,
          CupertinoIcons.circle,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppleTheme.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppleTheme.spacing8),
          Text(
            text,
            style: AppleTheme.footnote.copyWith(
              fontWeight: FontWeight.w600,
              color: CupertinoDynamicColor.resolve(color as CupertinoDynamicColor, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionAlert(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppleTheme.spacing20),
      padding: const EdgeInsets.all(AppleTheme.spacing16),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.systemOrange.withValues(alpha: 0.12),
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        border: Border.all(color: AppleTheme.systemOrange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.lock_shield_fill,
            color: AppleTheme.systemOrange,
            size: 24,
          ),
          const SizedBox(width: AppleTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.senderPermissionTitle,
                  style: AppleTheme.headline.copyWith(
                    color: AppleTheme.resolvedLabel(context),
                  ),
                ),
                const SizedBox(height: AppleTheme.spacing2),
                Text(
                  l10n.senderPermissionMessage,
                  style: AppleTheme.callout.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      AppleTheme.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: controller.requestPermission,
            child: Text(l10n.senderPermissionButton, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppleTheme.spacing20),
      padding: const EdgeInsets.all(AppleTheme.spacing12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.systemRed.withValues(alpha: 0.12),
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        border: Border.all(color: AppleTheme.systemRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: AppleTheme.systemRed,
            size: 18,
          ),
          const SizedBox(width: AppleTheme.spacing12),
          Expanded(
            child: Text(
              error,
              style: AppleTheme.footnote.copyWith(
                color: CupertinoColors.destructiveRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledPlatformView(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(AppleTheme.spacing24),
        padding: const EdgeInsets.all(AppleTheme.spacing32),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.secondarySystemBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(AppleTheme.radiusLarge),
          border: Border.all(
            color: CupertinoDynamicColor.resolve(
              AppleTheme.separator,
              context,
            ),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  AppleTheme.tertiarySystemFill,
                  context,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.macwindow,
                size: 28,
                color: CupertinoDynamicColor.resolve(
                  AppleTheme.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: AppleTheme.spacing16),
            Text(
              l10n.senderMacOnlyTitle,
              style: AppleTheme.title2.copyWith(
                color: AppleTheme.resolvedLabel(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppleTheme.spacing8),
            Text(
              l10n.senderMacOnlyDescription,
              style: AppleTheme.callout.copyWith(
                color: AppleTheme.resolvedSecondaryLabel(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onSwitchToReceiver != null) ...[
              const SizedBox(height: AppleTheme.spacing20),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                onPressed: onSwitchToReceiver,
                child: Text(
                  l10n.switchToReceiver,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
