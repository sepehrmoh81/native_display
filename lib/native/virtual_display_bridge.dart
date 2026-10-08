import 'dart:io';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';

class VirtualDisplayInfo {
  final int displayId;
  final String name;
  final int width;
  final int height;
  final double refreshRate;
  final bool isVirtual;

  const VirtualDisplayInfo({
    required this.displayId,
    required this.name,
    required this.width,
    required this.height,
    required this.refreshRate,
    this.isVirtual = true,
  });

  factory VirtualDisplayInfo.fromMap(Map<dynamic, dynamic> map) {
    return VirtualDisplayInfo(
      displayId: (map['displayId'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? 'Virtual Monitor',
      width: (map['width'] as num?)?.toInt() ?? 1920,
      height: (map['height'] as num?)?.toInt() ?? 1080,
      refreshRate: (map['refreshRate'] as num?)?.toDouble() ?? 60.0,
      isVirtual: map['isVirtual'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'VirtualDisplayInfo(id: $displayId, name: "$name", ${width}x$height @ ${refreshRate}Hz)';
}

class VirtualDisplayBridge {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.virtualDisplayChannelName);

  /// Creates a native macOS virtual display with the specified dimensions and settings.
  static Future<VirtualDisplayInfo?> createVirtualDisplay({
    int width = 1920,
    int height = 1080,
    double refreshRate = 60.0,
    bool hiDPI = true,
    String name = 'NativeDisplay Virtual Monitor',
  }) async {
    if (!Platform.isMacOS) return null;
    try {
      final dynamic result = await _channel.invokeMethod('createVirtualDisplay', {
        'width': width,
        'height': height,
        'refreshRate': refreshRate,
        'hiDPI': hiDPI,
        'name': name,
      });

      if (result is Map) {
        return VirtualDisplayInfo.fromMap(result);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Destroys a virtual display by its display ID.
  static Future<bool> destroyVirtualDisplay(int displayId) async {
    if (!Platform.isMacOS) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>(
        'destroyVirtualDisplay',
        {'displayId': displayId},
      );
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Destroys all active virtual displays.
  static Future<void> destroyAllVirtualDisplays() async {
    if (!Platform.isMacOS) return;
    try {
      await _channel.invokeMethod<void>('destroyAllVirtualDisplays');
    } catch (_) {}
  }

  /// Retrieves list of currently active virtual display IDs.
  static Future<List<int>> getActiveVirtualDisplays() async {
    if (!Platform.isMacOS) return [];
    try {
      final List<dynamic>? list =
          await _channel.invokeMethod<List<dynamic>>('getActiveVirtualDisplays');
      return list?.map((e) => (e as num).toInt()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Opens macOS System Settings -> Displays so the user can easily arrange display positions.
  static Future<bool> openDisplaySettings() async {
    if (!Platform.isMacOS) return false;
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('openDisplaySettings');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }
}
