import '../constants/app_constants.dart';

class StreamQualityConfig {
  final StreamQualityPreset preset;
  final int customBitrateKbps;
  final int customFps;
  final bool enableHardwareAcceleration;
  final bool lowLatencyMode;

  const StreamQualityConfig({
    this.preset = StreamQualityPreset.balanced1080p60,
    this.customBitrateKbps = 15000,
    this.customFps = 60,
    this.enableHardwareAcceleration = true,
    this.lowLatencyMode = true,
  });

  int get effectiveFps => customFps > 0 ? customFps : preset.fps;
  int get effectiveBitrateKbps =>
      customBitrateKbps > 0 ? customBitrateKbps : preset.bitrateKbps;
  int get width => preset.width;
  int get height => preset.height;

  StreamQualityConfig copyWith({
    StreamQualityPreset? preset,
    int? customBitrateKbps,
    int? customFps,
    bool? enableHardwareAcceleration,
    bool? lowLatencyMode,
  }) {
    return StreamQualityConfig(
      preset: preset ?? this.preset,
      customBitrateKbps: customBitrateKbps ?? this.customBitrateKbps,
      customFps: customFps ?? this.customFps,
      enableHardwareAcceleration:
          enableHardwareAcceleration ?? this.enableHardwareAcceleration,
      lowLatencyMode: lowLatencyMode ?? this.lowLatencyMode,
    );
  }
}

class StreamMetrics {
  final double fps;
  final double latencyMs;
  final double bitrateMbps;
  final int packetLossCount;
  final String codec;

  const StreamMetrics({
    this.fps = 0.0,
    this.latencyMs = 0.0,
    this.bitrateMbps = 0.0,
    this.packetLossCount = 0,
    this.codec = 'H.264',
  });
}
