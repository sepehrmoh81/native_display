import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bonsoir/bonsoir.dart';
import '../constants/app_constants.dart';
import 'models/peer_device.dart';

class DiscoveryService extends ChangeNotifier {
  final List<PeerDevice> _discoveredDevices = [];
  List<PeerDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  BonsoirBroadcast? _bonsoirBroadcast;
  BonsoirDiscovery? _bonsoirDiscovery;
  RawDatagramSocket? _udpSocket;
  Timer? _udpBroadcastTimer;
  Timer? _cleanupTimer;

  bool _isBroadcasting = false;
  bool get isBroadcasting => _isBroadcasting;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  /// Start broadcasting this device as a Receiver or Sender
  Future<void> startBroadcasting({
    required String deviceName,
    required int port,
    required AppMode mode,
    required DevicePlatform platform,
    int screenWidth = 1920,
    int screenHeight = 1080,
    int refreshRate = 60,
  }) async {
    if (_isBroadcasting) await stopBroadcasting();

    final selfDevice = PeerDevice(
      id: '${platform.name}-${Platform.localHostname}-$port',
      name: deviceName,
      host: await _getLocalIp(),
      port: port,
      mode: mode,
      platform: platform,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      refreshRate: refreshRate,
    );

    // 1. Bonsoir mDNS Broadcast
    try {
      final service = BonsoirService(
        name: deviceName,
        type: AppConstants.bonjourServiceType,
        port: port,
        attributes: {
          'id': selfDevice.id,
          'mode': mode.name,
          'platform': platform.name,
          'w': '$screenWidth',
          'h': '$screenHeight',
          'hz': '$refreshRate',
        },
      );
      _bonsoirBroadcast = BonsoirBroadcast(service: service);
      await _bonsoirBroadcast?.initialize();
      await _bonsoirBroadcast?.start();
    } catch (e) {
      debugPrint('[DiscoveryService] Bonsoir broadcast warning: $e');
    }

    // 2. UDP Broadcast Fallback for instant local network zero-config
    try {
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
      );
      _udpSocket?.broadcastEnabled = true;

      _udpBroadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        try {
          final data = utf8.encode(selfDevice.encode());
          _udpSocket?.send(
            data,
            InternetAddress('255.255.255.255'),
            AppConstants.udpBroadcastPort,
          );
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('[DiscoveryService] UDP broadcast warning: $e');
    }

    _isBroadcasting = true;
    notifyListeners();
  }

  /// Stop broadcasting
  Future<void> stopBroadcasting() async {
    _udpBroadcastTimer?.cancel();
    _udpBroadcastTimer = null;
    _udpSocket?.close();
    _udpSocket = null;

    try {
      await _bonsoirBroadcast?.stop();
    } catch (_) {}
    _bonsoirBroadcast = null;

    _isBroadcasting = false;
    notifyListeners();
  }

  /// Start scanning for available peers (e.g., Windows receivers)
  Future<void> startScanning() async {
    if (_isScanning) return;
    _discoveredDevices.clear();

    // 1. Bonsoir mDNS discovery
    try {
      _bonsoirDiscovery = BonsoirDiscovery(type: AppConstants.bonjourServiceType);
      await _bonsoirDiscovery?.initialize();
      _bonsoirDiscovery?.eventStream?.listen((event) {
        if (event is BonsoirDiscoveryServiceFoundEvent) {
          event.service.resolve(_bonsoirDiscovery!.serviceResolver);
        } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
          final s = event.service;
          final attrs = s.attributes;
          final host = s.hostAddress ?? s.hostname ?? '127.0.0.1';
          final device = PeerDevice(
            id: attrs['id'] ?? s.name,
            name: s.name,
            host: host,
            port: s.port,
            mode: attrs['mode'] == 'receiver' ? AppMode.receiver : AppMode.sender,
            platform: DevicePlatform.fromString(attrs['platform'] ?? 'unknown'),
            screenWidth: int.tryParse(attrs['w'] ?? '1920') ?? 1920,
            screenHeight: int.tryParse(attrs['h'] ?? '1080') ?? 1080,
            refreshRate: int.tryParse(attrs['hz'] ?? '60') ?? 60,
          );
          _addOrUpdateDevice(device);
        }
      });
      await _bonsoirDiscovery?.start();
    } catch (e) {
      debugPrint('[DiscoveryService] Bonsoir discovery warning: $e');
    }

    // 2. UDP Broadcast Listener
    try {
      final listener = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        AppConstants.udpBroadcastPort,
        reuseAddress: true,
      );
      listener.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final dg = listener.receive();
          if (dg != null) {
            try {
              final raw = utf8.decode(dg.data);
              final device = PeerDevice.decode(raw);
              // Use sender's real IP address from datagram
              final updated = PeerDevice(
                id: device.id,
                name: device.name,
                host: dg.address.address,
                port: device.port,
                mode: device.mode,
                platform: device.platform,
                screenWidth: device.screenWidth,
                screenHeight: device.screenHeight,
                refreshRate: device.refreshRate,
              );
              _addOrUpdateDevice(updated);
            } catch (_) {}
          }
        }
      });
    } catch (e) {
      debugPrint('[DiscoveryService] UDP listener warning: $e');
    }

    // Periodic cleanup of stale peers (not seen for > 10 seconds)
    _cleanupTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final now = DateTime.now();
      _discoveredDevices.removeWhere(
        (d) => now.difference(d.lastSeen) > const Duration(seconds: 10),
      );
      notifyListeners();
    });

    _isScanning = true;
    notifyListeners();
  }

  void _addOrUpdateDevice(PeerDevice device) {
    final idx = _discoveredDevices.indexWhere((d) => d.id == device.id);
    if (idx >= 0) {
      _discoveredDevices[idx] = device;
    } else {
      _discoveredDevices.add(device);
    }
    notifyListeners();
  }

  Future<void> stopScanning() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    try {
      await _bonsoirDiscovery?.stop();
    } catch (_) {}
    _bonsoirDiscovery = null;
    _isScanning = false;
    notifyListeners();
  }

  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  @override
  void dispose() {
    stopBroadcasting();
    stopScanning();
    super.dispose();
  }
}
