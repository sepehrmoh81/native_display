import 'dart:convert';
import '../../constants/app_constants.dart';

enum DevicePlatform {
  macos,
  windows,
  ios,
  android,
  unknown;

  static DevicePlatform fromString(String val) {
    return switch (val.toLowerCase()) {
      'macos' || 'darwin' => DevicePlatform.macos,
      'windows' => DevicePlatform.windows,
      'ios' => DevicePlatform.ios,
      'android' => DevicePlatform.android,
      _ => DevicePlatform.unknown,
    };
  }
}

class PeerDevice {
  final String id;
  final String name;
  final String host;
  final int port;
  final AppMode mode;
  final DevicePlatform platform;
  final int screenWidth;
  final int screenHeight;
  final int refreshRate;
  final DateTime lastSeen;

  PeerDevice({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.mode,
    required this.platform,
    this.screenWidth = 1920,
    this.screenHeight = 1080,
    this.refreshRate = 60,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  String get endpoint {
    final isIPv6 = host.contains(':') && !host.startsWith('[');
    final formattedHost = isIPv6 ? '[$host]' : host;
    return 'ws://$formattedHost:$port/ws';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'mode': mode.name,
        'platform': platform.name,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'refreshRate': refreshRate,
      };

  factory PeerDevice.fromJson(Map<String, dynamic> json) {
    return PeerDevice(
      id: json['id'] as String? ?? 'unknown-id',
      name: json['name'] as String? ?? 'Display Receiver',
      host: json['host'] as String? ?? '127.0.0.1',
      port: (json['port'] as num?)?.toInt() ?? AppConstants.defaultSignalingPort,
      mode: (json['mode'] == 'receiver') ? AppMode.receiver : AppMode.sender,
      platform: DevicePlatform.fromString(json['platform'] as String? ?? 'unknown'),
      screenWidth: (json['screenWidth'] as num?)?.toInt() ?? 1920,
      screenHeight: (json['screenHeight'] as num?)?.toInt() ?? 1080,
      refreshRate: (json['refreshRate'] as num?)?.toInt() ?? 60,
    );
  }

  String encode() => jsonEncode(toJson());

  factory PeerDevice.decode(String raw) =>
      PeerDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeerDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
