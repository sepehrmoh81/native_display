import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../core/theme/liquid_glass.dart';
import '../controller/sender_controller.dart';
import 'display_selector.dart';

class SenderView extends StatelessWidget {
  final SenderController controller;

  const SenderView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isStreaming = controller.status == SenderStatus.streaming;
        final isConnecting = controller.status == SenderStatus.connecting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppleTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Recording Permission Banner (macOS)
              if (!controller.hasScreenPermission)
                _buildPermissionAlert(context),

              // Title Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extend Display',
                        style: AppleTheme.title1.copyWith(
                          color: AppleTheme.resolvedLabel(context),
                        ),
                      ),
                      const SizedBox(height: AppleTheme.spacing4),
                      Text(
                        'Turn your Windows PC into a true native second monitor for your Mac.',
                        style: AppleTheme.callout.copyWith(
                          color: CupertinoDynamicColor.resolve(
                            AppleTheme.secondaryLabel,
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildStatusBadge(context),
                ],
              ),

              const SizedBox(height: AppleTheme.spacing20),

              // Mode Switcher (Extend vs Mirror)
              _buildModeSwitcher(context),

              const SizedBox(height: AppleTheme.spacing24),

              // Error banner if any
              if (controller.errorMessage != null)
                _buildErrorBanner(context, controller.errorMessage!),

              // Discovered Receivers Section
              _buildReceiversSection(context),

              const SizedBox(height: AppleTheme.spacing24),

              // Configuration based on mode:
              // In Extend mode: Virtual Display configuration card (NO source picker)
              // In Mirror mode: Screen & Window picker
              if (controller.streamMode == SenderStreamMode.extend)
                _buildVirtualDisplayConfigCard(context)
              else
                DisplaySelector(
                  sources: controller.webrtcManager.availableSources,
                  selectedSource: controller.webrtcManager.selectedSource,
                  onSourceSelected: controller.selectSource,
                ),

              const SizedBox(height: AppleTheme.spacing24),

              // Streaming Controls & Preview
              _buildStreamControls(context, isStreaming, isConnecting),

              if (isStreaming) ...[
                const SizedBox(height: AppleTheme.spacing24),
                _buildLivePreview(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeSwitcher(BuildContext context) {
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
                  'Extend Desktop (Virtual Display)',
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
                  'Mirror Screen / Window',
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

  Widget _buildVirtualDisplayConfigCard(BuildContext context) {
    final receiver = controller.selectedReceiver;
    final currentRes = '${controller.virtualWidth}x${controller.virtualHeight}';

    return Container(
      padding: const EdgeInsets.all(AppleTheme.spacing20),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.secondarySystemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppleTheme.separator, context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.slider_horizontal_3,
                size: 18,
                color: AppleTheme.systemBlue,
              ),
              const SizedBox(width: AppleTheme.spacing8),
              Text(
                'VIRTUAL DISPLAY CONFIGURATION',
                style: AppleTheme.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppleTheme.resolvedTertiaryLabel(context),
                ),
              ),
              const Spacer(),
              if (Platform.isMacOS)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.openMacDisplaySettings,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.macwindow, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Arrange Displays in macOS Settings',
                        style: AppleTheme.footnote.copyWith(
                          color: AppleTheme.systemBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppleTheme.spacing16),

          // Resolution Selection
          Text(
            'Target Resolution',
            style: AppleTheme.headline.copyWith(
              color: AppleTheme.resolvedLabel(context),
            ),
          ),
          const SizedBox(height: AppleTheme.spacing8),
          Wrap(
            spacing: AppleTheme.spacing8,
            runSpacing: AppleTheme.spacing8,
            children: [
              if (receiver != null)
                _buildResolutionPill(
                  context: context,
                  label: 'Match Windows (${receiver.screenWidth}×${receiver.screenHeight})',
                  width: receiver.screenWidth,
                  height: receiver.screenHeight,
                  isSelected: controller.virtualWidth == receiver.screenWidth &&
                      controller.virtualHeight == receiver.screenHeight,
                ),
              _buildResolutionPill(
                context: context,
                label: '1080p FHD (1920×1080)',
                width: 1920,
                height: 1080,
                isSelected: currentRes == '1920x1080',
              ),
              _buildResolutionPill(
                context: context,
                label: '1440p QHD (2560×1440)',
                width: 2560,
                height: 1440,
                isSelected: currentRes == '2560x1440',
              ),
              _buildResolutionPill(
                context: context,
                label: '4K UHD (3840×2160)',
                width: 3840,
                height: 2160,
                isSelected: currentRes == '3840x2160',
              ),
            ],
          ),

          const SizedBox(height: AppleTheme.spacing16),
          Container(
            height: 1,
            color: CupertinoDynamicColor.resolve(AppleTheme.separator, context),
          ),
          const SizedBox(height: AppleTheme.spacing16),

          // Refresh Rate & HiDPI Settings Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refresh Rate',
                      style: AppleTheme.headline.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    const SizedBox(height: AppleTheme.spacing8),
                    CupertinoSlidingSegmentedControl<double>(
                      groupValue: controller.virtualFps,
                      children: {
                        60.0: Text(
                          '60 Hz',
                          style: AppleTheme.footnote.copyWith(
                            color: AppleTheme.resolvedLabel(context),
                          ),
                        ),
                        120.0: Text(
                          '120 Hz',
                          style: AppleTheme.footnote.copyWith(
                            color: AppleTheme.resolvedLabel(context),
                          ),
                        ),
                      },
                      onValueChanged: (fps) {
                        if (fps != null) controller.setVirtualFps(fps);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppleTheme.spacing24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HiDPI Retina Scaling',
                      style: AppleTheme.headline.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    const SizedBox(height: AppleTheme.spacing4),
                    Row(
                      children: [
                        Text(
                          controller.virtualHiDPI
                              ? 'Enabled (Sharp text)'
                              : 'Disabled (1x scaling)',
                          style: AppleTheme.footnote.copyWith(
                            color: CupertinoDynamicColor.resolve(
                              AppleTheme.secondaryLabel,
                              context,
                            ),
                          ),
                        ),
                        const Spacer(),
                        CupertinoSwitch(
                          value: controller.virtualHiDPI,
                          onChanged: controller.setVirtualHiDPI,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionPill({
    required BuildContext context,
    required String label,
    required int width,
    required int height,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.setVirtualResolution(width, height),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppleTheme.spacing12,
          vertical: AppleTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppleTheme.systemBlue.withValues(alpha: 0.15)
              : CupertinoDynamicColor.resolve(
                  AppleTheme.tertiarySystemFill,
                  context,
                ),
          borderRadius: BorderRadius.circular(AppleTheme.radiusPill),
          border: Border.all(
            color: isSelected
                ? AppleTheme.systemBlue
                : CupertinoDynamicColor.resolve(AppleTheme.separator, context),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppleTheme.footnote.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? AppleTheme.systemBlue
                : AppleTheme.resolvedLabel(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final (Color color, String text, IconData icon) = switch (controller.status) {
      SenderStatus.streaming => (
          AppleTheme.systemGreen,
          controller.streamMode == SenderStreamMode.extend
              ? 'Virtual Display Active'
              : 'Mirroring Active',
          CupertinoIcons.checkmark_alt_circle_fill,
        ),
      SenderStatus.connecting => (
          AppleTheme.systemOrange,
          'Creating Virtual Display...',
          CupertinoIcons.arrow_2_circlepath,
        ),
      SenderStatus.searching => (
          AppleTheme.systemBlue,
          'Scanning LAN',
          CupertinoIcons.radiowaves_right,
        ),
      SenderStatus.error => (
          AppleTheme.systemRed,
          'Connection Issue',
          CupertinoIcons.exclamationmark_circle_fill,
        ),
      SenderStatus.idle => (
          AppleTheme.systemGray,
          'Ready to Extend',
          CupertinoIcons.circle,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing12,
        vertical: AppleTheme.spacing8,
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

  Widget _buildPermissionAlert(BuildContext context) {
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
                  'Screen Recording Permission Required',
                  style: AppleTheme.headline.copyWith(
                    color: AppleTheme.resolvedLabel(context),
                  ),
                ),
                const SizedBox(height: AppleTheme.spacing2),
                Text(
                  'macOS requires explicit authorization to capture desktop displays. If you recently toggled this in System Settings, macOS requires you to fully quit (Cmd+Q) and relaunch the app for permissions to take effect.',
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
            child: const Text('Allow Access', style: TextStyle(fontSize: 13)),
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

  Widget _buildReceiversSection(BuildContext context) {
    final receivers = controller.availableReceivers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TARGET DISPLAY RECEIVER (WINDOWS)',
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
                    'Searching for Windows Receivers on your Wi-Fi/LAN...',
                    style: AppleTheme.callout.copyWith(
                      color: AppleTheme.resolvedSecondaryLabel(context),
                    ),
                  ),
                  const SizedBox(height: AppleTheme.spacing4),
                  Text(
                    'Ensure "Native Display" is open in Receiver mode on your Windows PC.',
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
                onTap: () {
                  controller.selectReceiver(receiver);
                  // Auto-preset virtual resolution to match receiver screen
                  controller.setVirtualResolution(
                    receiver.screenWidth,
                    receiver.screenHeight,
                  );
                },
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
    bool isStreaming,
    bool isConnecting,
  ) {
    final actionLabel = controller.streamMode == SenderStreamMode.extend
        ? 'Extend Desktop to ${controller.selectedReceiver?.name ?? "Windows"}'
        : 'Mirror Screen to ${controller.selectedReceiver?.name ?? "Windows"}';

    return Row(
      children: [
        if (isStreaming)
          CupertinoButton(
            color: CupertinoColors.destructiveRed,
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            onPressed: controller.stopStreaming,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.stop_fill, size: 16),
                SizedBox(width: AppleTheme.spacing8),
                Text('Disconnect Display',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )
        else
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
                  isConnecting ? 'Connecting...' : actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
              Icon(CupertinoIcons.refresh,
                  size: 16, color: AppleTheme.resolvedLabel(context)),
              const SizedBox(width: AppleTheme.spacing8),
              Text(
                'Rescan LAN',
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

  Widget _buildLivePreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.streamMode == SenderStreamMode.extend
              ? 'VIRTUAL DISPLAY LIVE PREVIEW'
              : 'LOCAL CAPTURE PREVIEW',
          style: AppleTheme.caption.copyWith(
            color: AppleTheme.resolvedTertiaryLabel(context),
          ),
        ),
        const SizedBox(height: AppleTheme.spacing8),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(
                AppleTheme.separator,
                context,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              RTCVideoView(
                controller.webrtcManager.localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              ),
              Positioned(
                top: AppleTheme.spacing8,
                right: AppleTheme.spacing8,
                child: LiquidGlassSurface(
                  variant: LiquidGlassVariant.clear,
                  borderRadius: AppleTheme.radiusPill,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppleTheme.systemGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.streamMode == SenderStreamMode.extend
                            ? 'VIRTUAL DISPLAY ACTIVE'
                            : 'LIVE STREAMING',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
