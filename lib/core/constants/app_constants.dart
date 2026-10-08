/// Application constants for Native Display
class AppConstants {
  static const String appName = 'Native Display';
  static const String bonjourServiceType = '_nativedisplay._tcp';
  static const int defaultSignalingPort = 8989;
  static const int udpBroadcastPort = 8990;

  // Stream defaults
  static const int defaultTargetFps = 60;
  static const int defaultBitrateKbps = 15000; // 15 Mbps for crisp desktop mirroring
  static const int defaultWidth = 1920;
  static const int defaultHeight = 1080;

  // Method channels
  static const String screenChannelName = 'com.nativedisplay.app/screen';
  static const String virtualDisplayChannelName = 'com.nativedisplay.app/virtual_display';
}

enum AppMode {
  sender,
  receiver,
}

enum StreamQualityPreset {
  balanced1080p60('1080p @ 60 FPS', 1920, 1080, 60, 15000),
  fidelity1440p60('1440p @ 60 FPS', 2560, 1440, 60, 25000),
  ultra4K60('4K @ 60 FPS', 3840, 2160, 60, 45000),
  economy720p30('720p @ 30 FPS (Low Bandwidth)', 1280, 720, 30, 5000);

  final String label;
  final int width;
  final int height;
  final int fps;
  final int bitrateKbps;

  const StreamQualityPreset(
    this.label,
    this.width,
    this.height,
    this.fps,
    this.bitrateKbps,
  );
}
