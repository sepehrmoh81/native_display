// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Native Display';

  @override
  String get appTagline => 'High-Performance Display Extension';

  @override
  String get systemReady => 'System Ready';

  @override
  String get displayActive => 'Display Active';

  @override
  String get navExtendDisplay => 'Extend Display';

  @override
  String get navReceiveDisplay => 'Receive Display';

  @override
  String get navDiagnostics => 'Diagnostics';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get senderTitle => 'Extend Display';

  @override
  String get senderSubtitle =>
      'Extend your desktop to a secondary display over low-latency Wi-Fi or LAN.';

  @override
  String get senderPermissionTitle => 'Screen Recording Permission Required';

  @override
  String get senderPermissionMessage =>
      'macOS requires screen recording authorization to capture displays. If recently granted in System Settings, quit and relaunch Native Display for changes to take effect.';

  @override
  String get senderPermissionButton => 'Grant Permission';

  @override
  String get modeExtend => 'Extend Display (Virtual)';

  @override
  String get modeMirror => 'Mirror Display or Window';

  @override
  String get sectionAvailableReceivers => 'AVAILABLE RECEIVERS';

  @override
  String get searchingReceivers => 'Searching for Display Receivers...';

  @override
  String get searchingReceiversHint =>
      'Ensure Native Display is open in Receive Display mode on your target computer on the same local network.';

  @override
  String get rescanReceivers => 'Scan Network';

  @override
  String get sectionVirtualConfig => 'VIRTUAL DISPLAY CONFIGURATION';

  @override
  String get arrangeMacDisplays => 'Arrange Displays in macOS Settings';

  @override
  String get targetResolution => 'Target Resolution';

  @override
  String matchReceiverResolution(int width, int height) {
    return 'Match Receiver ($width×$height)';
  }

  @override
  String get refreshRate => 'Refresh Rate';

  @override
  String get hidpiRetinaScaling => 'HiDPI Retina Scaling';

  @override
  String get hidpiEnabled => 'Enabled (Sharp text)';

  @override
  String get hidpiDisabled => 'Disabled (Standard 1× scaling)';

  @override
  String get resolutionAuto => 'Match Target Display (Auto)';

  @override
  String get resolution1080p => '1080p FHD (1920×1080)';

  @override
  String get resolution1440p => '1440p QHD (2560×1440)';

  @override
  String get resolution4k => '4K UHD (3840×2160)';

  @override
  String get senderSettingsHint =>
      'Virtual display resolution, refresh rate, and quality presets are managed in Settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get extendMacOnlyNotice =>
      'Virtual display extension is currently supported on macOS only. Mirror mode is active on this system.';

  @override
  String get sectionSourceDisplay => 'SELECT DISPLAY OR WINDOW';

  @override
  String get noDisplaysFound =>
      'No displays or windows found. Ensure screen recording permission is granted.';

  @override
  String get fullScreenDisplay => 'Full Screen Display';

  @override
  String get appWindow => 'Application Window';

  @override
  String displayFallback(String id) {
    return 'Display $id';
  }

  @override
  String startExtend(String name) {
    return 'Extend to $name';
  }

  @override
  String startMirror(String name) {
    return 'Mirror to $name';
  }

  @override
  String get disconnectDisplay => 'Disconnect Display';

  @override
  String get virtualDisplayPreview => 'VIRTUAL DISPLAY PREVIEW';

  @override
  String get capturePreview => 'LOCAL CAPTURE PREVIEW';

  @override
  String get badgeVirtualActive => 'VIRTUAL DISPLAY ACTIVE';

  @override
  String get badgeStreamingActive => 'LIVE STREAMING';

  @override
  String get statusVirtualActive => 'Virtual Display Active';

  @override
  String get statusMirrorActive => 'Mirroring Active';

  @override
  String get statusConnecting => 'Connecting Display...';

  @override
  String get statusScanning => 'Scanning Network...';

  @override
  String get statusError => 'Connection Issue';

  @override
  String get statusReady => 'Ready to Extend';

  @override
  String get receiverTitle => 'Receive Display';

  @override
  String get receiverSubtitle =>
      'Use this computer as a high-performance secondary display.';

  @override
  String get statusListening => 'Listening on Local Network';

  @override
  String receiverConnectionInfo(int port) {
    return 'Port: $port • Local Discovery Active';
  }

  @override
  String get renameDevice => 'Rename Device';

  @override
  String get renameDeviceTitle => 'Rename Display Receiver';

  @override
  String get deviceNamePlaceholder => 'Device Name';

  @override
  String get enterFullscreen => 'Enter Fullscreen';

  @override
  String get exitFullscreen => 'Exit Fullscreen';

  @override
  String get sectionHowToConnect => 'HOW TO CONNECT';

  @override
  String get step1Title => 'Open Native Display on your primary computer.';

  @override
  String step2Title(String deviceName) {
    return 'Select \"$deviceName\" under Available Receivers.';
  }

  @override
  String get step3Title =>
      'Click Extend or Mirror. Video will stream automatically with low-latency WebRTC.';

  @override
  String get receiverConnectedBadge => 'Connected • Display Stream Active';

  @override
  String get windowedMode => 'Windowed';

  @override
  String get fullscreenMode => 'Full Screen';

  @override
  String get diagnosticsTitle => 'Diagnostics & Performance';

  @override
  String get diagnosticsSubtitle =>
      'Real-time stream telemetry, network latency, and WebRTC pipeline metrics.';

  @override
  String get metricFramerate => 'STREAM FRAMERATE';

  @override
  String metricFramerateTarget(int fps) {
    return 'Target: $fps FPS';
  }

  @override
  String get metricLatency => 'NETWORK LATENCY';

  @override
  String get metricLatencyLow => 'Ultra-Low Latency';

  @override
  String get metricLatencyStandby => 'Standby';

  @override
  String get metricBandwidth => 'BANDWIDTH USAGE';

  @override
  String metricBandwidthAllocated(int bitrate) {
    return 'Allocated: $bitrate Mbps';
  }

  @override
  String get metricPacketLoss => 'PACKET LOSS';

  @override
  String get metricPacketLossNone => 'Zero Dropped Packets';

  @override
  String get metricPacketLossDetected => 'Network Congestion Detected';

  @override
  String get sectionStreamingPipeline => 'STREAMING PIPELINE';

  @override
  String get capturePipelineLabel => 'Screen Capture Pipeline';

  @override
  String get capturePipelineMac => 'Apple ScreenCaptureKit (macOS 12.3+)';

  @override
  String get capturePipelineWin => 'Desktop Duplication API (Windows)';

  @override
  String get videoCodecLabel => 'Video Codec';

  @override
  String get hardwareAccelerationLabel => 'Hardware Acceleration';

  @override
  String get hardwareAccelerationDetails =>
      'Enabled (Apple VideoToolbox / NVENC)';

  @override
  String get signalingProtocolLabel => 'Signaling Protocol';

  @override
  String signalingProtocolDetails(int port) {
    return 'WebSocket JSON-RPC (Port $port)';
  }

  @override
  String get discoveryProtocolLabel => 'Discovery Protocol';

  @override
  String get discoveryProtocolDetails => 'mDNS (Bonjour) + UDP Multicast';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Configure display streaming quality, network performance, and platform integrations.';

  @override
  String get sectionLanguage => 'LANGUAGE';

  @override
  String get appLanguage => 'App Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get sectionQualityPreset => 'STREAMING QUALITY PRESET';

  @override
  String qualityPresetFooter(int width, int height, int fps, int bitrate) {
    return 'Current Target: $width×$height @ $fps FPS ($bitrate Mbps)';
  }

  @override
  String get preset720p => '720p (30 FPS)';

  @override
  String get preset1080p => '1080p (60 FPS)';

  @override
  String get preset1440p => '1440p (60 FPS)';

  @override
  String get preset4k => '4K (60 FPS)';

  @override
  String get sectionEncoding => 'ENCODING & PERFORMANCE';

  @override
  String get sectionEncodingFooter =>
      'Hardware acceleration leverages Apple VideoToolbox on macOS and NVENC/QuickSync on Windows.';

  @override
  String get targetBitrate => 'Target Bitrate';

  @override
  String get hardwareAcceleration => 'Hardware Accelerated Encoding';

  @override
  String get lowLatencyMode => 'Ultra-Low Latency Mode';

  @override
  String get lowLatencyHelper =>
      'Minimizes buffering for instant cursor responsiveness.';

  @override
  String get sectionIntegration => 'SYSTEM & PREFERENCES';

  @override
  String get deviceName => 'Device Name';

  @override
  String get virtualDisplayToggle => 'Virtual Display Extension';

  @override
  String get virtualDisplayHelper =>
      'Creates an independent virtual display space instead of mirroring the current desktop.';

  @override
  String get autoConnect => 'Auto-Connect on Launch';

  @override
  String get startMinimized => 'Start in Menu Bar or System Tray';

  @override
  String trayStatus(String status) {
    return 'Native Display: $status';
  }

  @override
  String get trayOpenWindow => 'Open Native Display';

  @override
  String get trayStartStreaming => 'Start Streaming';

  @override
  String get trayStopStreaming => 'Stop Streaming';

  @override
  String get trayAvailableReceivers => 'Available Displays:';

  @override
  String get trayQuit => 'Quit Native Display';

  @override
  String get errorSelectReceiverFirst =>
      'Please select a target display receiver first.';

  @override
  String errorSignalingConnection(String error) {
    return 'Signaling connection error: $error';
  }

  @override
  String get errorPeerConnectionFailed =>
      'WebRTC peer connection failed to establish.';

  @override
  String get errorConnectionDropped => 'Connection dropped unexpectedly.';

  @override
  String get errorCreateVirtualDisplay =>
      'Failed to create native macOS virtual display.';

  @override
  String errorReceiverServiceStart(String error) {
    return 'Could not start receiver service: $error';
  }

  @override
  String get errorWebRtcNegotiation =>
      'Connection lost or WebRTC negotiation failed.';
}
