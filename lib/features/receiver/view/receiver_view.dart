import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../core/theme/liquid_glass.dart';
import '../controller/receiver_controller.dart';

class ReceiverView extends StatefulWidget {
  final ReceiverController controller;

  const ReceiverView({super.key, required this.controller});

  @override
  State<ReceiverView> createState() => _ReceiverViewState();
}

class _ReceiverViewState extends State<ReceiverView> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isConnected =
            widget.controller.status == ReceiverStatus.connected;

        if (isConnected) {
          return _buildActiveStreamingView(context);
        } else {
          return _buildStandbyView(context);
        }
      },
    );
  }

  Widget _buildStandbyView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppleTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receiver Mode', style: AppleTheme.title1.copyWith(color: AppleTheme.resolvedLabel(context))),
                  const SizedBox(height: AppleTheme.spacing4),
                  Text(
                    'Use this Windows machine as a high-performance secondary display.',
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppleTheme.spacing12,
                  vertical: AppleTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppleTheme.systemGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppleTheme.radiusPill),
                  border: Border.all(
                    color: AppleTheme.systemGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.antenna_radiowaves_left_right,
                      size: 14,
                      color: AppleTheme.systemGreen,
                    ),
                    SizedBox(width: AppleTheme.spacing8),
                    Text(
                      'Listening for Mac',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppleTheme.systemGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppleTheme.spacing24),

          // Standby Hero Card
          Container(
            width: double.infinity,
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
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppleTheme.systemBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.device_desktop,
                    size: 36,
                    color: AppleTheme.systemBlue,
                  ),
                ),
                const SizedBox(height: AppleTheme.spacing16),
                Text(
                  widget.controller.deviceName,
                  style: AppleTheme.title2.copyWith(color: AppleTheme.resolvedLabel(context)),
                ),
                const SizedBox(height: AppleTheme.spacing4),
                Text(
                  'Signaling Port: ${widget.controller.signalingServer.port} • mDNS Active',
                  style: AppleTheme.footnote.copyWith(color: AppleTheme.resolvedTertiaryLabel(context)),
                ),
                const SizedBox(height: AppleTheme.spacing24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: CupertinoDynamicColor.resolve(
                        AppleTheme.tertiarySystemFill,
                        context,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppleTheme.radiusMedium),
                      onPressed: () => _showRenameDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            size: 16,
                            color: AppleTheme.resolvedLabel(context),
                          ),
                          const SizedBox(width: AppleTheme.spacing8),
                          Text(
                            'Rename Receiver',
                            style: TextStyle(
                              color: AppleTheme.resolvedLabel(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppleTheme.spacing16),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppleTheme.radiusMedium),
                      onPressed: widget.controller.toggleFullscreen,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.controller.isFullscreen
                                ? CupertinoIcons.fullscreen_exit
                                : CupertinoIcons.fullscreen,
                            size: 16,
                          ),
                          const SizedBox(width: AppleTheme.spacing8),
                          Text(
                            widget.controller.isFullscreen
                                ? 'Exit Fullscreen'
                                : 'Enter Fullscreen',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppleTheme.spacing24),

          // Instruction Cards
          Text('HOW TO CONNECT', style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
          const SizedBox(height: AppleTheme.spacing8),
          Container(
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
              ),
            ),
            child: const Column(
              children: [
                _StepRow(
                  number: '1',
                  text: 'Open Native Display on your Mac.',
                ),
                SizedBox(height: AppleTheme.spacing12),
                _StepRow(
                  number: '2',
                  text: 'Select this Windows machine under "Available Displays".',
                ),
                SizedBox(height: AppleTheme.spacing12),
                _StepRow(
                  number: '3',
                  text:
                      'Click "Stream to Windows". Video will appear automatically with low-latency WebRTC.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStreamingView(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        if (!_showOverlay) setState(() => _showOverlay = true);
      },
      child: Stack(
        children: [
          // The Remote WebRTC Video View
          Positioned.fill(
            child: Container(
              color: CupertinoColors.black,
              child: RTCVideoView(
                widget.controller.webrtcManager.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              ),
            ),
          ),

          // Floating Liquid Glass Functional Controls Overlay
          if (_showOverlay)
            Positioned(
              top: AppleTheme.spacing16,
              left: AppleTheme.spacing16,
              right: AppleTheme.spacing16,
              child: LiquidGlassSurface(
                variant: LiquidGlassVariant.clear,
                borderRadius: AppleTheme.radiusLarge,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppleTheme.spacing16,
                  vertical: AppleTheme.spacing12,
                ),
                child: Row(
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
                    const Text(
                      'Connected • Display Stream Active',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: const Color(0x33FFFFFF),
                      borderRadius:
                          BorderRadius.circular(AppleTheme.radiusSmall),
                      onPressed: widget.controller.toggleFullscreen,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.controller.isFullscreen
                                ? CupertinoIcons.fullscreen_exit
                                : CupertinoIcons.fullscreen,
                            size: 14,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.controller.isFullscreen
                                ? 'Window'
                                : 'Fullscreen',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppleTheme.spacing12),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: CupertinoColors.destructiveRed.withValues(alpha: 0.8),
                      borderRadius:
                          BorderRadius.circular(AppleTheme.radiusSmall),
                      onPressed: widget.controller.disconnectSender,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.xmark,
                            size: 14,
                            color: CupertinoColors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Disconnect',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppleTheme.spacing12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _showOverlay = false),
                      child: const Icon(
                        CupertinoIcons.chevron_up,
                        size: 16,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final textController =
        TextEditingController(text: widget.controller.deviceName);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Rename Display Receiver'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: textController,
            autofocus: true,
            placeholder: 'Device Name',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                widget.controller.setDeviceName(textController.text.trim());
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppleTheme.systemBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppleTheme.spacing12),
        Expanded(
          child: Text(text, style: AppleTheme.body.copyWith(color: AppleTheme.resolvedLabel(context))),
        ),
      ],
    );
  }
}
