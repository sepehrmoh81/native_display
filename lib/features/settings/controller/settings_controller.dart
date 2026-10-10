import 'package:flutter/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/webrtc/stream_quality.dart';

enum VirtualResolutionPreset {
  auto,
  fhd1080,
  qhd1440,
  uhd4k;

  int? get width => switch (this) {
        VirtualResolutionPreset.auto => null,
        VirtualResolutionPreset.fhd1080 => 1920,
        VirtualResolutionPreset.qhd1440 => 2560,
        VirtualResolutionPreset.uhd4k => 3840,
      };

  int? get height => switch (this) {
        VirtualResolutionPreset.auto => null,
        VirtualResolutionPreset.fhd1080 => 1080,
        VirtualResolutionPreset.qhd1440 => 1440,
        VirtualResolutionPreset.uhd4k => 2160,
      };
}

class SettingsController extends ChangeNotifier {
  // Virtual Display Settings
  VirtualResolutionPreset _resolutionPreset = VirtualResolutionPreset.auto;
  VirtualResolutionPreset get resolutionPreset => _resolutionPreset;

  double _virtualFps = 60.0;
  double get virtualFps => _virtualFps;

  bool _virtualHiDPI = true;
  bool get virtualHiDPI => _virtualHiDPI;

  // Stream Quality & Encoding
  StreamQualityConfig _qualityConfig = const StreamQualityConfig();
  StreamQualityConfig get qualityConfig => _qualityConfig;

  // Language & Localization
  Locale? _locale;
  Locale? get locale => _locale;

  // System & Device Settings
  String _deviceName = 'MacBook Pro';
  String get deviceName => _deviceName;

  bool _autoConnectLastDevice = false;
  bool get autoConnectLastDevice => _autoConnectLastDevice;

  bool _startMinimizedToTray = false;
  bool get startMinimizedToTray => _startMinimizedToTray;

  bool _enableVirtualDisplays = true;
  bool get enableVirtualDisplays => _enableVirtualDisplays;

  bool _autoRefreshRate = true;
  bool get autoRefreshRate => _autoRefreshRate;

  (int, int) resolveDisplayDimensions({int? receiverWidth, int? receiverHeight}) {
    if (_resolutionPreset == VirtualResolutionPreset.auto &&
        receiverWidth != null &&
        receiverHeight != null &&
        receiverWidth > 0 &&
        receiverHeight > 0) {
      return (receiverWidth, receiverHeight);
    }
    return (
      _resolutionPreset.width ?? 1920,
      _resolutionPreset.height ?? 1080,
    );
  }

  double resolveRefreshRate({int? receiverRefreshRate}) {
    if (_autoRefreshRate &&
        receiverRefreshRate != null &&
        receiverRefreshRate > 0) {
      return receiverRefreshRate.toDouble();
    }
    return _virtualFps;
  }

  void setResolutionPreset(VirtualResolutionPreset preset) {
    _resolutionPreset = preset;
    notifyListeners();
  }

  void setAutoRefreshRate(bool auto) {
    _autoRefreshRate = auto;
    notifyListeners();
  }

  void setVirtualFps(double fps) {
    _virtualFps = fps;
    _autoRefreshRate = false;
    _qualityConfig = _qualityConfig.copyWith(customFps: fps.round());
    notifyListeners();
  }

  void setVirtualHiDPI(bool enabled) {
    _virtualHiDPI = enabled;
    notifyListeners();
  }

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
    _virtualFps = fps.toDouble();
    _autoRefreshRate = false;
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

  void setLocale(Locale? locale) {
    _locale = locale;
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
