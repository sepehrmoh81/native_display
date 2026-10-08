import 'dart:io';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';

class NativeDisplayInfo {
  final int displayId;
  final String name;
  final int width;
  final int height;
  final double refreshRate;
  final bool isMain;
  final bool isBuiltIn;

  NativeDisplayInfo({
    required this.displayId,
    required this.name,
    required this.width,
    required this.height,
    required this.refreshRate,
    required this.isMain,
    required this.isBuiltIn,
  });

  factory NativeDisplayInfo.fromMap(Map<dynamic, dynamic> map) {
    return NativeDisplayInfo(
      displayId: (map['displayId'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? 'Display',
      width: (map['width'] as num?)?.toInt() ?? 1920,
      height: (map['height'] as num?)?.toInt() ?? 1080,
      refreshRate: (map['refreshRate'] as num?)?.toDouble() ?? 60.0,
      isMain: map['isMain'] as bool? ?? false,
      isBuiltIn: map['isBuiltIn'] as bool? ?? false,
    );
  }
}

class ScreenCaptureBridge {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.screenChannelName);

  /// Check if the macOS application has Screen Recording permissions
  static Future<bool> hasScreenRecordingPermission() async {
    if (!Platform.isMacOS) return true;
    try {
      final bool? hasPerm =
          await _channel.invokeMethod<bool>('hasScreenRecordingPermission');
      return hasPerm ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Trigger the macOS system prompt or navigate to Privacy & Security settings
  static Future<bool> requestScreenRecordingPermission() async {
    if (!Platform.isMacOS) return true;
    try {
      final bool? granted =
          await _channel.invokeMethod<bool>('requestScreenRecordingPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Get list of connected displays and their native resolutions and refresh rates
  static Future<List<NativeDisplayInfo>> getNativeDisplays() async {
    if (!Platform.isMacOS) return [];
    try {
      final List<dynamic>? displays =
          await _channel.invokeMethod<List<dynamic>>('getNativeDisplays');
      if (displays == null) return [];
      return displays
          .map((d) => NativeDisplayInfo.fromMap(d as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
