import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/apple_theme.dart';
import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller;

  const SettingsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final config = controller.qualityConfig;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing24,
            vertical: AppleTheme.spacing20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppleTheme.title1.copyWith(color: AppleTheme.resolvedLabel(context))),
              const SizedBox(height: AppleTheme.spacing4),
              Text(
                'Configure display streaming quality, network performance, and platform integrations.',
                style: AppleTheme.callout.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    AppleTheme.secondaryLabel,
                    context,
                  ),
                ),
              ),

              const SizedBox(height: AppleTheme.spacing20),

              // Quality Preset Section
              CupertinoFormSection.insetGrouped(
                header: const Text('STREAMING QUALITY PRESET'),
                footer: Text(
                  'Current Target: ${config.width}×${config.height} @ ${config.effectiveFps} FPS (${config.effectiveBitrateKbps ~/ 1000} Mbps)',
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppleTheme.spacing12),
                    child: CupertinoSlidingSegmentedControl<StreamQualityPreset>(
                      groupValue: config.preset,
                      children: const {
                        StreamQualityPreset.economy720p30: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('720p 30fps', style: TextStyle(fontSize: 12)),
                        ),
                        StreamQualityPreset.balanced1080p60: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('1080p 60fps', style: TextStyle(fontSize: 12)),
                        ),
                        StreamQualityPreset.fidelity1440p60: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('1440p 60fps', style: TextStyle(fontSize: 12)),
                        ),
                        StreamQualityPreset.ultra4K60: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('4K 60fps', style: TextStyle(fontSize: 12)),
                        ),
                      },
                      onValueChanged: (preset) {
                        if (preset != null) controller.updatePreset(preset);
                      },
                    ),
                  ),
                ],
              ),

              // Bitrate & Performance Section
              CupertinoFormSection.insetGrouped(
                header: const Text('ENCODING & PERFORMANCE'),
                footer: const Text(
                  'Hardware acceleration leverages Apple VideoToolbox on macOS and NVENC/QuickSync on Windows.',
                ),
                children: [
                  CupertinoFormRow(
                    prefix: const Text('Target Bitrate'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 140,
                          child: CupertinoSlider(
                            value: (config.effectiveBitrateKbps / 1000).toDouble(),
                            min: 5,
                            max: 50,
                            divisions: 9,
                            onChanged: (val) {
                              controller.updateBitrate((val * 1000).toInt());
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${config.effectiveBitrateKbps ~/ 1000} Mbps',
                          style: AppleTheme.footnote.copyWith(color: AppleTheme.resolvedTertiaryLabel(context)),
                        ),
                      ],
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('Hardware Accelerated Encoding'),
                    child: CupertinoSwitch(
                      value: config.enableHardwareAcceleration,
                      onChanged: controller.toggleHardwareAcceleration,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('Ultra-Low Latency Mode'),
                    helper: const Text('Minimizes buffering for instant cursor responsiveness.'),
                    child: CupertinoSwitch(
                      value: config.lowLatencyMode,
                      onChanged: controller.toggleLowLatency,
                    ),
                  ),
                ],
              ),

              // System & Platform Integration Section
              CupertinoFormSection.insetGrouped(
                header: const Text('DESKTOP & INTEGRATION'),
                children: [
                  CupertinoFormRow(
                    prefix: const Text('Device Identifier'),
                    child: CupertinoTextField(
                      controller:
                          TextEditingController(text: controller.deviceName),
                      textAlign: TextAlign.end,
                      decoration: const BoxDecoration(),
                      onSubmitted: controller.setDeviceName,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('Virtual Display Extension'),
                    helper: const Text(
                      'Creates a virtual display canvas instead of mirroring the current desktop.',
                    ),
                    child: CupertinoSwitch(
                      value: controller.enableVirtualDisplays,
                      onChanged: controller.toggleVirtualDisplays,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('Auto-Connect on Launch'),
                    child: CupertinoSwitch(
                      value: controller.autoConnectLastDevice,
                      onChanged: controller.toggleAutoConnect,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('Start in Menu Bar or System Tray'),
                    child: CupertinoSwitch(
                      value: controller.startMinimizedToTray,
                      onChanged: controller.toggleStartMinimized,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
