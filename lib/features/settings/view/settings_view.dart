import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/settings_controller.dart';

class SettingsView extends StatefulWidget {
  final SettingsController controller;

  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final TextEditingController _deviceNameController;

  @override
  void initState() {
    super.initState();
    _deviceNameController =
        TextEditingController(text: widget.controller.deviceName);
  }

  @override
  void didUpdateWidget(covariant SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.deviceName != _deviceNameController.text) {
      _deviceNameController.text = widget.controller.deviceName;
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = widget.controller;

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
              // Screen Header
              Text(
                l10n.settingsTitle,
                style: AppleTheme.title1.copyWith(
                  color: AppleTheme.resolvedLabel(context),
                ),
              ),
              const SizedBox(height: AppleTheme.spacing4),
              Text(
                l10n.settingsSubtitle,
                style: AppleTheme.callout.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    AppleTheme.secondaryLabel,
                    context,
                  ),
                ),
              ),

              const SizedBox(height: AppleTheme.spacing16),

              // 1. Language Section
              _buildSection(
                headerText: l10n.sectionLanguage,
                children: [
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.appLanguage,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _buildPopupButton(
                      context: context,
                      text: _getCurrentLanguageLabel(l10n, controller.locale),
                      onPressed: () => _showLanguagePicker(context, l10n),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppleTheme.spacing12),

              // 2. Virtual Display Configuration Section (macOS only)
              if (Platform.isMacOS) ...[
                _buildSection(
                  headerText: l10n.sectionVirtualConfig,
                footerText: controller.virtualHiDPI
                    ? l10n.hidpiEnabled
                    : l10n.hidpiDisabled,
                children: [
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.targetResolution,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _buildPopupButton(
                      context: context,
                      text: _getResolutionLabel(l10n, controller.resolutionPreset),
                      onPressed: () => _showResolutionPicker(context, l10n),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.refreshRate,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _buildPopupButton(
                      context: context,
                      text: controller.virtualFps == 120.0
                          ? '120 Hz (ProMotion)'
                          : '60 Hz',
                      onPressed: () => _showRefreshRatePicker(context, l10n),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.hidpiRetinaScaling,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _MacSwitch(
                      value: controller.virtualHiDPI,
                      onChanged: controller.setVirtualHiDPI,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppleTheme.spacing12),
            ],

              // 3. Video Streaming Quality Preset & Bitrate
              _buildSection(
                headerText: l10n.sectionQualityPreset,
                footerText: l10n.qualityPresetFooter(
                  config.width,
                  config.height,
                  config.effectiveFps,
                  config.effectiveBitrateKbps ~/ 1000,
                ),
                children: [
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.sectionQualityPreset,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _buildPopupButton(
                      context: context,
                      text: _getPresetLabel(l10n, config.preset),
                      onPressed: () => _showPresetPicker(context, l10n),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.targetBitrate,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 130,
                          child: CupertinoSlider(
                            value:
                                (config.effectiveBitrateKbps / 1000).toDouble(),
                            min: 5,
                            max: 50,
                            divisions: 9,
                            onChanged: (val) {
                              controller.updateBitrate((val * 1000).toInt());
                            },
                          ),
                        ),
                        const SizedBox(width: AppleTheme.spacing8),
                        SizedBox(
                          width: 58,
                          child: Text(
                            '${config.effectiveBitrateKbps ~/ 1000} Mbps',
                            style: AppleTheme.footnote.copyWith(
                              color: AppleTheme.resolvedSecondaryLabel(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.hardwareAcceleration,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _MacSwitch(
                      value: config.enableHardwareAcceleration,
                      onChanged: controller.toggleHardwareAcceleration,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.lowLatencyMode,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _MacSwitch(
                      value: config.lowLatencyMode,
                      onChanged: controller.toggleLowLatency,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppleTheme.spacing12),

              // 4. System & Platform Integration
              _buildSection(
                headerText: l10n.sectionIntegration,
                footerText: l10n.virtualDisplayHelper,
                children: [
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.deviceName,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: SizedBox(
                      width: 180,
                      child: CupertinoTextField(
                        controller: _deviceNameController,
                        textAlign: TextAlign.end,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        style: AppleTheme.body.copyWith(
                          color: AppleTheme.resolvedLabel(context),
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            AppleTheme.tertiarySystemFill,
                            context,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppleTheme.radiusSmall),
                        ),
                        onSubmitted: controller.setDeviceName,
                      ),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.virtualDisplayToggle,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _MacSwitch(
                      value: controller.enableVirtualDisplays,
                      onChanged: controller.toggleVirtualDisplays,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.autoConnect,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _MacSwitch(
                      value: controller.autoConnectLastDevice,
                      onChanged: controller.toggleAutoConnect,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(
                      l10n.startMinimized,
                      style: AppleTheme.body.copyWith(
                        color: AppleTheme.resolvedLabel(context),
                      ),
                    ),
                    child: _MacSwitch(
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

  Widget _buildSection({
    required String headerText,
    String? footerText,
    required List<Widget> children,
  }) {
    return CupertinoFormSection.insetGrouped(
      margin: EdgeInsets.zero,
      header: Padding(
        padding: const EdgeInsets.only(
          left: AppleTheme.spacing16,
          bottom: AppleTheme.spacing4,
          top: AppleTheme.spacing8,
        ),
        child: Text(
          headerText,
          style: AppleTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppleTheme.resolvedTertiaryLabel(context),
          ),
        ),
      ),
      footer: footerText != null
          ? Padding(
              padding: const EdgeInsets.only(
                left: AppleTheme.spacing16,
                right: AppleTheme.spacing16,
                top: 6.0,
                bottom: AppleTheme.spacing8,
              ),
              child: Text(
                footerText,
                style: AppleTheme.footnote.copyWith(
                  color: AppleTheme.resolvedTertiaryLabel(context),
                  height: 1.35,
                ),
              ),
            )
          : null,
      children: children,
    );
  }

  Widget _buildPopupButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: CupertinoDynamicColor.resolve(
        AppleTheme.tertiarySystemFill,
        context,
      ),
      borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
      minimumSize: const Size(0, 28),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppleTheme.body.copyWith(
              fontSize: 13,
              color: AppleTheme.resolvedLabel(context),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            CupertinoIcons.chevron_up_chevron_down,
            size: 12,
            color: CupertinoDynamicColor.resolve(
              AppleTheme.secondaryLabel,
              context,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentLanguageLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.languageSystem;
    return switch (locale.languageCode) {
      'en' => l10n.languageEnglish,
      'es' => l10n.languageSpanish,
      'de' => l10n.languageGerman,
      _ => locale.languageCode,
    };
  }

  String _getResolutionLabel(
    AppLocalizations l10n,
    VirtualResolutionPreset preset,
  ) {
    return switch (preset) {
      VirtualResolutionPreset.auto => l10n.resolutionAuto,
      VirtualResolutionPreset.fhd1080 => l10n.resolution1080p,
      VirtualResolutionPreset.qhd1440 => l10n.resolution1440p,
      VirtualResolutionPreset.uhd4k => l10n.resolution4k,
    };
  }

  String _getPresetLabel(AppLocalizations l10n, StreamQualityPreset preset) {
    return switch (preset) {
      StreamQualityPreset.economy720p30 => l10n.preset720p,
      StreamQualityPreset.balanced1080p60 => l10n.preset1080p,
      StreamQualityPreset.fidelity1440p60 => l10n.preset1440p,
      StreamQualityPreset.ultra4K60 => l10n.preset4k,
    };
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations l10n) {
    final languages = [
      (null, l10n.languageSystem),
      (const Locale('en'), l10n.languageEnglish),
      (const Locale('es'), l10n.languageSpanish),
      (const Locale('de'), l10n.languageGerman),
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(l10n.selectLanguageTitle),
        actions: languages.map((item) {
          final isSelected = (item.$1 == null && widget.controller.locale == null) ||
              (item.$1 != null &&
                  widget.controller.locale?.languageCode == item.$1?.languageCode);

          return CupertinoActionSheetAction(
            onPressed: () {
              widget.controller.setLocale(item.$1);
              Navigator.of(sheetContext).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.$2),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.checkmark, size: 16),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  void _showResolutionPicker(BuildContext context, AppLocalizations l10n) {
    final options = [
      (VirtualResolutionPreset.auto, l10n.resolutionAuto),
      (VirtualResolutionPreset.fhd1080, l10n.resolution1080p),
      (VirtualResolutionPreset.qhd1440, l10n.resolution1440p),
      (VirtualResolutionPreset.uhd4k, l10n.resolution4k),
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(l10n.targetResolution),
        actions: options.map((item) {
          final isSelected = widget.controller.resolutionPreset == item.$1;

          return CupertinoActionSheetAction(
            onPressed: () {
              widget.controller.setResolutionPreset(item.$1);
              Navigator.of(sheetContext).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.$2),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.checkmark, size: 16),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  void _showRefreshRatePicker(BuildContext context, AppLocalizations l10n) {
    final options = [
      (60.0, '60 Hz'),
      (120.0, '120 Hz (ProMotion)'),
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(l10n.refreshRate),
        actions: options.map((item) {
          final isSelected = widget.controller.virtualFps == item.$1;

          return CupertinoActionSheetAction(
            onPressed: () {
              widget.controller.setVirtualFps(item.$1);
              Navigator.of(sheetContext).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.$2),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.checkmark, size: 16),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  void _showPresetPicker(BuildContext context, AppLocalizations l10n) {
    final options = [
      (StreamQualityPreset.balanced1080p60, l10n.preset1080p),
      (StreamQualityPreset.fidelity1440p60, l10n.preset1440p),
      (StreamQualityPreset.ultra4K60, l10n.preset4k),
      (StreamQualityPreset.economy720p30, l10n.preset720p),
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(l10n.sectionQualityPreset),
        actions: options.map((item) {
          final isSelected = widget.controller.qualityConfig.preset == item.$1;

          return CupertinoActionSheetAction(
            onPressed: () {
              widget.controller.updatePreset(item.$1);
              Navigator.of(sheetContext).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.$2),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.checkmark, size: 16),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }
}

class _MacSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _MacSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.82,
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppleTheme.systemBlue,
      ),
    );
  }
}
