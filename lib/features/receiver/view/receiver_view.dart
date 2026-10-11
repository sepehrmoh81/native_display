import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../core/theme/liquid_glass.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isConnected =
            widget.controller.status == ReceiverStatus.connected;

        if (isConnected) {
          return _buildActiveStreamingView(context, l10n);
        } else {
          return _buildStandbyView(context, l10n);
        }
      },
    );
  }

  Widget _buildStandbyView(BuildContext context, AppLocalizations l10n) {
    final isDiscoveryOn = widget.controller.isDiscoveryEnabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppleTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.receiverTitle,
                      style: AppleTheme.title1.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    const SizedBox(height: AppleTheme.spacing4),
                    Text(
                      l10n.receiverSubtitle,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge(context, l10n),
                  const SizedBox(width: AppleTheme.spacing12),
                  Semantics(
                    label: l10n.discoveryToggleLabel,
                    toggled: isDiscoveryOn,
                    child: CupertinoSwitch(
                      value: isDiscoveryOn,
                      onChanged: (val) =>
                          widget.controller.setDiscoveryEnabled(val),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppleTheme.spacing24),

          // Standby Hero Card (Active or Dormant depending on discovery state)
          if (isDiscoveryOn)
            _buildActiveStandbyCard(context, l10n)
          else
            _buildDormantStandbyCard(context, l10n),

          const SizedBox(height: AppleTheme.spacing24),

          // Instruction Cards
          Text(l10n.sectionHowToConnect, style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
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
            child: Column(
              children: [
                _StepRow(
                  number: '1',
                  text: l10n.step1Title,
                ),
                const SizedBox(height: AppleTheme.spacing12),
                _StepRow(
                  number: '2',
                  text: l10n.step2Title(widget.controller.deviceName),
                ),
                const SizedBox(height: AppleTheme.spacing12),
                _StepRow(
                  number: '3',
                  text: l10n.step3Title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AppLocalizations l10n) {
    final isDiscoveryOn = widget.controller.isDiscoveryEnabled;

    final (Color dotColor, String text) = switch (widget.controller.status) {
      ReceiverStatus.connected => (
        AppleTheme.systemBlue,
        l10n.receiverConnectedBadge,
      ),
      ReceiverStatus.listening when isDiscoveryOn => (
        AppleTheme.systemGreen,
        l10n.statusListening,
      ),
      ReceiverStatus.error => (
        AppleTheme.systemRed,
        widget.controller.errorMessage ?? l10n.statusError,
      ),
      _ => (
        AppleTheme.systemGray,
        l10n.statusDiscoveryDisabled,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing12,
        vertical: AppleTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.tertiarySystemFill,
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusPill),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.separator,
            context,
          ),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppleTheme.spacing8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppleTheme.resolvedLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStandbyCard(BuildContext context, AppLocalizations l10n) {
    return Container(
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
            style: AppleTheme.title2.copyWith(
              color: AppleTheme.resolvedLabel(context),
            ),
          ),
          const SizedBox(height: AppleTheme.spacing4),
          Text(
            l10n.receiverConnectionInfo(widget.controller.signalingServer.port),
            style: AppleTheme.footnote.copyWith(
              color: AppleTheme.resolvedTertiaryLabel(context),
            ),
          ),
          const SizedBox(height: AppleTheme.spacing8),
          // High-contrast display specs pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                AppleTheme.tertiarySystemFill,
                context,
              ),
              borderRadius: BorderRadius.circular(AppleTheme.radiusPill),
              border: Border.all(
                color: CupertinoDynamicColor.resolve(
                  AppleTheme.separator,
                  context,
                ),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.tv,
                  size: 12,
                  color: AppleTheme.systemBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  'Display: ${widget.controller.screenWidth}×${widget.controller.screenHeight} @ ${widget.controller.refreshRate}Hz',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppleTheme.resolvedLabel(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppleTheme.spacing20),
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
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                onPressed: () => _showRenameDialog(context, l10n),
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
                      l10n.renameDevice,
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
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: CupertinoDynamicColor.resolve(
                  AppleTheme.tertiarySystemFill,
                  context,
                ),
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                onPressed: widget.controller.toggleFullscreen,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.controller.isFullscreen
                          ? CupertinoIcons.fullscreen_exit
                          : CupertinoIcons.fullscreen,
                      size: 16,
                      color: AppleTheme.resolvedLabel(context),
                    ),
                    const SizedBox(width: AppleTheme.spacing8),
                    Text(
                      widget.controller.isFullscreen
                          ? l10n.exitFullscreen
                          : l10n.enterFullscreen,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppleTheme.resolvedLabel(context),
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildDormantStandbyCard(BuildContext context, AppLocalizations l10n) {
    return Container(
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
              color: CupertinoDynamicColor.resolve(
                AppleTheme.tertiarySystemFill,
                context,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.antenna_radiowaves_left_right,
              size: 36,
              color: CupertinoDynamicColor.resolve(
                AppleTheme.secondaryLabel,
                context,
              ),
            ),
          ),
          const SizedBox(height: AppleTheme.spacing16),
          Text(
            l10n.discoveryDisabledTitle,
            style: AppleTheme.title2.copyWith(
              color: AppleTheme.resolvedLabel(context),
            ),
          ),
          const SizedBox(height: AppleTheme.spacing8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              l10n.discoveryDisabledSubtitle,
              textAlign: TextAlign.center,
              style: AppleTheme.callout.copyWith(
                color: AppleTheme.resolvedSecondaryLabel(context),
              ),
            ),
          ),
          const SizedBox(height: AppleTheme.spacing20),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            onPressed: () => widget.controller.setDiscoveryEnabled(true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.power, size: 16),
                const SizedBox(width: AppleTheme.spacing8),
                Text(
                  l10n.enableDiscovery,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStreamingView(BuildContext context, AppLocalizations l10n) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            widget.controller.isFullscreen) {
          widget.controller.setFullscreen(false);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
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
                    Text(
                      l10n.receiverConnectedBadge,
                      style: const TextStyle(
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
                                ? l10n.windowedMode
                                : l10n.fullscreenMode,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.xmark,
                            size: 14,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.disconnect,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppleTheme.spacing12),
                    Semantics(
                      label: l10n.overlayHideControls,
                      button: true,
                      child: CupertinoButton(
                        minimumSize: const Size(28, 28),
                        padding: const EdgeInsets.all(6),
                        onPressed: () => setState(() => _showOverlay = false),
                        child: const Icon(
                          CupertinoIcons.chevron_up,
                          size: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  void _showRenameDialog(BuildContext context, AppLocalizations l10n) {
    final textController =
        TextEditingController(text: widget.controller.deviceName);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.renameDeviceTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: textController,
            autofocus: true,
            placeholder: l10n.deviceNamePlaceholder,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.save),
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
