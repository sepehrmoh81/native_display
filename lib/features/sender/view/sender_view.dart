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
                      Text('Extend Display', style: AppleTheme.title1.copyWith(color: AppleTheme.resolvedLabel(context))),
                      const SizedBox(height: AppleTheme.spacing4),
                      Text(
                        'Mirror or extend your Mac desktop to a Windows computer.',
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

              const SizedBox(height: AppleTheme.spacing24),

              // Error banner if any
              if (controller.errorMessage != null)
                _buildErrorBanner(context, controller.errorMessage!),

              // Discovered Receivers Section
              _buildReceiversSection(context),

              const SizedBox(height: AppleTheme.spacing24),

              // Source Display Selection
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

  Widget _buildStatusBadge(BuildContext context) {
    final (Color color, String text, IconData icon) = switch (controller.status) {
      SenderStatus.streaming => (
          AppleTheme.systemGreen,
          'Streaming Active',
          CupertinoIcons.checkmark_alt_circle_fill,
        ),
      SenderStatus.connecting => (
          AppleTheme.systemOrange,
          'Negotiating WebRTC...',
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
          'Ready to Connect',
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
                  style: AppleTheme.headline.copyWith(color: AppleTheme.resolvedLabel(context)),
                ),
                const SizedBox(height: AppleTheme.spacing2),
                Text(
                  'macOS requires explicit authorization to capture desktop displays via ScreenCaptureKit.',
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
            Text('AVAILABLE DISPLAYS (WINDOWS)', style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
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
                    style: AppleTheme.callout.copyWith(color: AppleTheme.resolvedSecondaryLabel(context)),
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
                              color: AppleTheme.systemGreen.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppleTheme.radiusSmall),
                            ),
                            child: Text(
                              '${receiver.screenWidth}×${receiver.screenHeight} @ ${receiver.refreshRate}Hz',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: CupertinoDynamicColor.resolve(AppleTheme.systemGreen, context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppleTheme.spacing12),
                      Text(
                        receiver.name,
                        style: AppleTheme.headline.copyWith(color: AppleTheme.resolvedLabel(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppleTheme.spacing2),
                      Text(
                        'IP: ${receiver.host}:${receiver.port}',
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

  Widget _buildStreamControls(
    BuildContext context,
    bool isStreaming,
    bool isConnecting,
  ) {
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
                Text('Disconnect Display', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  isConnecting
                      ? 'Connecting...'
                      : 'Stream to ${controller.selectedReceiver?.name ?? "Windows"}',
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
              Icon(CupertinoIcons.refresh, size: 16, color: AppleTheme.resolvedLabel(context)),
              const SizedBox(width: AppleTheme.spacing8),
              Text('Rescan LAN', style: TextStyle(color: AppleTheme.resolvedLabel(context), fontSize: 13)),
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
        Text('LOCAL CAPTURE PREVIEW', style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
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
                      const Text(
                        'LIVE STREAMING',
                        style: TextStyle(
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
