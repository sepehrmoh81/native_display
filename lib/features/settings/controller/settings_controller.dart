import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/webrtc/stream_quality.dart';

class SettingsController extends ChangeNotifier {
  StreamQualityConfig _qualityConfig = const StreamQualityConfig();
  StreamQualityConfig get qualityConfig => _qualityConfig;

  String _deviceName = 'MacBook Pro';
  String get deviceName => _deviceName;

  bool _autoConnectLastDevice = false;
  bool get autoConnectLastDevice => _autoConnectLastDevice;

  bool _startMinimizedToTray = false;
  bool get startMinimizedToTray => _startMinimizedToTray;

  bool _enableVirtualDisplays = true;
  bool get enableVirtualDisplays => _enableVirtualDisplays;

  void updatePreset(StreamQualityPreset preset) {
    _qualityConfig = _qualityConfig.copyWith(
      preset: preset,
      customBitrateKbps: preset.bitrateKbps,
      customFps: preset.fps,
    );
    notifyListeners();
  }

  void updateBitrate(int bitrateKbps) {
    _qualityConfig = _qualityConfig.copyWith(customBitrateKbps: bitrateKbps);
    notifyListeners();
  }

  void updateFps(int fps) {
    _qualityConfig = _qualityConfig.copyWith(customFps: fps);
    notifyListeners();
  }

  void toggleHardwareAcceleration(bool enable) {
    _qualityConfig = _qualityConfig.copyWith(enableHardwareAcceleration: enable);
    notifyListeners();
  }

  void toggleLowLatency(bool enable) {
    _qualityConfig = _qualityConfig.copyWith(lowLatencyMode: enable);
    notifyListeners();
  }

  void setDeviceName(String name) {
    _deviceName = name;
    notifyListeners();
  }

  void toggleAutoConnect(bool val) {
    _autoConnectLastDevice = val;
    notifyListeners();
  }

  void toggleStartMinimized(bool val) {
    _startMinimizedToTray = val;
    notifyListeners();
  }

  void toggleVirtualDisplays(bool val) {
    _enableVirtualDisplays = val;
    notifyListeners();
  }
}
